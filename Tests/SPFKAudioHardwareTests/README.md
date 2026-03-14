# SPFKAudioHardwareTests

## Test Organization

Tests use Swift Testing tags defined in `Tags+AudioHardware.swift` to categorize suites:

| Tag | Suites | Description |
|-----|--------|-------------|
| `.unit` | `DefinitionTests` (12 suites), `MockPropertyTests` | Pure logic — no hardware, runs in milliseconds |
| `.hardware` | `NullDeviceTests`, `AudioDevicePropertyTests`, `AudioStreamTests`, `AudioHardwareManagerTests`, `DefaultAudioDeviceTests`, `SampleRateStateTests` | Requires NullAudioDevice driver |
| `.notification` | `AudioDeviceNotificationTests`, `AudioHardwareTests` | Hardware + async notification waits (timing-sensitive) |

All hardware and notification suites use `@Suite(.serialized)` because they share the global `AudioHardwareManager` singleton and NullAudioDevice state.

Mock-based unit tests (`MockPropertyTests`) also use `.serialized` because they swap the global `AudioBackend.current` backend.

## Mock Testing Infrastructure

The `AudioObjectBackend` protocol abstracts all CoreAudio C API calls. Tests can swap in `MockAudioBackend` via `AudioBackend._setForTesting()` to verify property access logic without hardware.

**Key files:**

- `Mocks/MockAudioBackend.swift` — In-memory property store keyed by `(objectID, selector, scope, element)`. Supports `register()`, `registerString()`, `registerArray()`, and tracks `setCalls` for verification.
- `Mocks/MockDeviceFactory.swift` — Creates mock-backed `AudioDevice` instances with minimum required properties pre-registered.

```swift
// Example: test that transportType maps UInt32 to enum
let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
    mock.register(objectID: id,
                  selector: kAudioDevicePropertyTransportType,
                  value: kAudioDeviceTransportTypeVirtual)
}
#expect(device.transportType == .virtual)
```

## Hardware Test Infrastructure

Hardware tests inherit from `NullDeviceTestCase` (or its parent `AudioHardwareTestCase`):

- `AudioHardwareTestCase` — Starts `AudioHardwareManager`, saves/restores default devices
- `NullDeviceTestCase` — Looks up the NullAudioDevice, provides `resetNullDeviceState()` and `createAggregateDevice()`

Each test calls `tearDown()` to reset device state (sample rate, volume, mute, stereo channels) ensuring test isolation.

## Running Tests

```bash
# Unit tests only (no hardware needed)
swift test --filter "DefinitionTests|MockPropertyTests"

# All tests (requires NullAudioDevice driver)
swift test
```

Note: The `.xctestplan` must have parallelization disabled due to the shared `AudioHardwareManager` singleton and NullAudioDevice state.

## Known Issues

### Sporadic CoreAudio crashes during hardware tests

Hardware tests that set device properties (volume, mute, etc.) can occasionally crash inside Apple's internal `LogVolumeChangeForClientSide` logging function. The crash occurs in `snprintf` → `__Balloc_D2A` (a memory allocator for float-to-string conversion) when `AudioObjectSetPropertyData` is called rapidly from Swift's cooperative thread pool.

This is an Apple framework bug — the crash is entirely within CoreAudio's internal logging path. `Task.yield()` calls have been added between property-set batches in `resetNullDeviceState()` and after `tearDown()` in notification tests to reduce the frequency, but cannot fully prevent it. If you see this crash, simply re-run the tests.

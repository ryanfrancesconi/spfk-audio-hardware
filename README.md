## SPFKAudioHardware

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-audio-hardware%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-audio-hardware)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-audio-hardware%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-audio-hardware)

A Swift concurrency-first abstraction over the Core Audio Hardware Abstraction Layer (HAL) for macOS. Provides a type-safe, `Sendable` interface to audio device management built on actors and `async`/`await`.

- Full `Sendable` and actor isolation throughout
- MIT License

## Requirements

- **Platforms:** macOS 13+
- **Swift:** 6.2+

### Quick Start

```swift
import SPFKAudioHardware

// Start the hardware manager (required before any device access)
let manager = AudioHardwareManager.shared
try await manager.start()

// Enumerate devices
let allDevices = try await manager.allDevices()
let outputs = try await manager.outputDevices()

// Access default devices
if let defaultOutput = await manager.defaultOutputDevice {
    print(defaultOutput.name)
}

// Clean up
try await manager.unregister()
```

### Features

- **Device enumeration** — query all devices, or filter by input, output, aggregate, Bluetooth, split, and more
- **Default device management** — get and promote default input, output, and system output devices
- **Volume and mute control** — per-channel scalar/dB volume, virtual main volume, balance, and mute state
- **Sample rate management** — coordinated async sample rate transitions via the `SampleRateState` actor
- **Aggregate devices** — create, configure, and destroy aggregate devices with clock source control
- **Stream formats** — enumerate and filter physical/virtual formats, access stream latency and direction
- **Channel layout** — physical/virtual channel counts, named channels, layout descriptions, and LFE support
- **Property notifications** — typed `AudioDeviceNotification`, `AudioStreamNotification`, and `AudioHardwareNotification` enums dispatched through `NotificationCenter`
- **Latency and safety offsets** — device, stream, and presentation latency; buffer frame size management

### Architecture

`AudioHardwareManager` is a singleton actor that owns the device lifecycle. It must be started before use and manages an internal `AudioDeviceCache` and `AudioObjectPool` for efficient device tracking and listener management.

**Key types:**

| Type | Role |
|------|------|
| `AudioHardwareManager` | Singleton actor — device enumeration, aggregate device creation, hardware event dispatch |
| `AudioDevice` | Represents a single audio device with properties for volume, sample rate, channels, streams, latency, and more |
| `AudioStream` | Represents an audio stream within a device — format enumeration, direction, latency |
| `SplitAudioDevice` | Matched input/output device pair (e.g. Bluetooth headphones with integrated mic) |
| `SampleRateState` | Actor coordinating async sample rate changes with hardware confirmation |
| `AudioObjectPool` | Internal singleton caching devices and streams, managing property listeners |
| `AudioObjectBackend` | Protocol abstracting CoreAudio C API calls — enables hardware-independent testing |
| `Scope` | Enum (`.input`, `.output`, `.global`, etc.) used throughout for directional property access |

**Notifications** are delivered as typed enums through `NotificationCenter`:

- `AudioHardwareNotification` — device list changes, default device changes
- `AudioDeviceNotification` — volume, mute, sample rate, name, and other per-device property changes
- `AudioStreamNotification` — stream format changes

**Backend abstraction:** All CoreAudio C API calls are routed through the `AudioObjectBackend` protocol via a global-replaceable accessor. In production, `CoreAudioBackend` delegates directly to the C functions. In tests, `MockAudioBackend` can be swapped in to verify property access logic without hardware. See the [test README](Tests/SPFKAudioHardwareTests/README.md) for details.

### Testing

Tests are organized into three tiers using Swift Testing tags:

| Tag | Description | Hardware required |
|-----|-------------|-------------------|
| `.unit` | Pure logic and mock-based tests | No |
| `.hardware` | Tests requiring NullAudioDevice or real audio hardware | Yes |
| `.notification` | Async notification tests (timing-sensitive) | Yes |

Unit tests (`.unit`) run in milliseconds with no hardware dependency. Hardware tests require Apple's NullAudioDevice driver and run serialized.

```bash
# Run only unit tests (no hardware needed)
swift test --filter "DefinitionTests|MockPropertyTests"

# Run all tests (requires NullAudioDevice driver)
swift test
```

### Dependencies

| Package | Purpose |
|---------|---------|
| [spfk-base](https://github.com/ryanfrancesconi/spfk-base) | Shared base utilities |
| [spfk-testing](https://github.com/ryanfrancesconi/spfk-testing) | Test utilities and resources (test target only) |

---

## History

SPFKAudioHardware is derived from [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) by Ruben Nine ([@rnine](https://github.com/rnine)). Open-sourced in March 2014 and archived in March 2025. Ryan Francesconi was a contributor and continued its development (as this package) after it was archived.

## About

Spongefork (SPFK) is the personal software projects of [Ryan Francesconi](https://github.com/ryanfrancesconi). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2016 to 2025 he was the lead macOS developer at [Audio Design Desk](https://add.app).

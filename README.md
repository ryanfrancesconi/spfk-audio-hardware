## SPFKAudioHardware

A Swift concurrency-first abstraction over the Core Audio Hardware Abstraction Layer (HAL) for macOS. Provides a type-safe, `Sendable` interface to audio device management built on actors and `async`/`await`.

- **Swift 6.2** / **macOS 12+**
- Full `Sendable` and actor isolation throughout
- MIT License

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
| `SplitAudioDevice` | Matched input/output device pair (e.g. Bluetooth headphones with integrated mic) |
| `SampleRateState` | Actor coordinating async sample rate changes with hardware confirmation |
| `AudioObjectPool` | Internal singleton caching devices and streams, managing property listeners |
| `Scope` | Enum (`.input`, `.output`, `.global`, etc.) used throughout for directional property access |

**Notifications** are delivered as typed enums through `NotificationCenter`:

- `AudioHardwareNotification` — device list changes, default device changes
- `AudioDeviceNotification` — volume, mute, sample rate, name, and other per-device property changes
- `AudioStreamNotification` — stream format changes

### Dependencies

| Package | Purpose |
|---------|---------|
| [spfk-base](https://github.com/ryanfrancesconi/spfk-base) | Shared base utilities |

---

## History

SPFKAudioHardware is derived from [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) by Ruben Nine ([@rnine](https://github.com/rnine)). Open-sourced in March 2014 and archived in March 2025. Ryan Francesconi was a contributor and continued its development (as this package) after it was archived.

## About

Spongefork (SPFK) is the personal software projects of [Ryan Francesconi](https://github.com/ryanfrancesconi). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2016 to 2025 he was the lead macOS developer at [Audio Design Desk](https://add.app).

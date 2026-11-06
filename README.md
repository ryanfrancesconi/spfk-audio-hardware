# SPFKAudioHardware

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-audio-hardware)](https://github.com/ryanfrancesconi/spfk-audio-hardware/tags)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-audio-hardware%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-audio-hardware)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-audio-hardware%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-audio-hardware)

Swift access to the Core Audio Hardware Abstraction Layer on macOS: audio devices, their
properties, and property-change notifications. Devices are `Sendable` and the manager is an actor,
with `async` reads and writes.

## Features

- List all devices, or filter by input, output, aggregate, Bluetooth, or matched input/output pairs
- Get and set the default input, output and system output devices
- List the devices another process is using
- Read and write device properties: name, UID, transport type, sample rate, volume (scalar and dB),
  balance, mute, channel counts and names, stream formats, latency, safety offset, buffer size,
  clock source, hog mode
- Change sample rate and wait for the device to confirm it (`SampleRateState`)
- Create and remove aggregate devices
- Hardware, device and stream property changes posted to `NotificationCenter` as
  `AudioHardwareNotification`, `AudioDeviceNotification` and `AudioStreamNotification`

## Usage

```swift
let hardware = AudioHardwareManager.shared
try await hardware.start()

let outputs = try await hardware.outputDevices()
let device = await hardware.defaultOutputDevice
try await device?.sampleRateUpdater.updateAndWait(sampleRate: 48000)
```

```swift
for await note in NotificationCenter.default.notifications(named: .deviceListChanged) {
    guard case let .deviceListChanged(_, event) = note.object as? AudioHardwareNotification else { continue }
    print(event.addedDevices, event.removedDevices)
}
```

## Notes

- Call `start()` before use. Nothing is observed until it has been called; calling it again is harmless.
- The manager's device list is a cache updated from HAL notifications and can lag the hardware.
  `AudioDevice.lookup(uid:)` queries the HAL directly.
- `setNominalSampleRate` returns before the rate has changed. Use `sampleRateUpdater` to wait for it.
- Notifications are posted on the main actor.

## License

MIT. Derived from [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) by Ruben Nine.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).

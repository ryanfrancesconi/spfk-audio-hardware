# SPFKAudioHardware

[![Version](https://img.shields.io/github/v/tag/ryanfrancesconi/spfk-audio-hardware)](https://github.com/ryanfrancesconi/spfk-audio-hardware/tags)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-audio-hardware%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-audio-hardware)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-audio-hardware%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-audio-hardware)

A Swift concurrency interface to the Core Audio Hardware Abstraction Layer on macOS: the audio
devices attached to the machine, their properties, and the changes the system reports about them.

The HAL is a C API of property selectors, scopes and listener callbacks on arbitrary threads. This
package presents it as `Sendable` device objects and actors, with `async` reads and writes and typed
notifications, so an app can list devices, follow the user's default output, or change a sample rate
without writing any of that plumbing. It is what an audio app embeds to manage the hardware it plays
and records through. ShadowTag uses it through spfk-audio-workspace, and it depends on neither
product.

## What it does

**Devices.** `AudioHardwareManager` lists every device, or only inputs, outputs, aggregates,
Bluetooth devices, or input/output pairs that belong together such as a headset's speaker and
microphone. It answers which devices are the system's default input, output and alert output, and
promotes a device to any of those roles. It can also list the devices another running process is
using.

**Properties.** An `AudioDevice` reads and writes what the HAL exposes for it: name and UID,
transport type, sample rates, per-channel and virtual main volume in scalar or decibels, balance,
mute, channel counts and names, stream formats, latency and safety offsets, buffer size, clock
source, and hog mode.

**Sample rates.** A sample-rate change is asynchronous in the HAL. `SampleRateState` requests one
and waits until the device reports it has arrived, so the caller resumes at the new rate.

**Aggregate devices.** Combine two devices into an aggregate with a chosen clock source, and remove
it again.

**Notifications.** Property changes on the system, on each device and on each stream are posted to
`NotificationCenter.default` as `AudioHardwareNotification`, `AudioDeviceNotification` and
`AudioStreamNotification`. A device-list change carries the devices added and removed.

## Usage

Start the manager once, then query it:

```swift
let hardware = AudioHardwareManager.shared
try await hardware.start()

let outputs = try await hardware.outputDevices()
let device = await hardware.defaultOutputDevice
try await device?.sampleRateUpdater.updateAndWait(sampleRate: 48000)
```

Follow device arrivals and departures:

```swift
for await note in NotificationCenter.default.notifications(named: .deviceListChanged) {
    guard case let .deviceListChanged(_, event) = note.object as? AudioHardwareNotification else { continue }
    print(event.addedDevices, event.removedDevices)
}
```

## Things to know

- Nothing is observed, and the device list is not kept current, until `start()` has been called.
  Calling it again from another consumer is harmless.
- The device list is a cache updated from HAL notifications, so it trails the hardware briefly.
  `AudioDevice.lookup(uid:)` asks the HAL directly, which is what to poll after creating or
  destroying an aggregate.
- `setNominalSampleRate` returns before the device has changed rate. Use the device's
  `sampleRateUpdater` when the next step depends on the new rate.
- Notifications are posted on the main actor.

## License

MIT. Derived from [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) by Ruben Nine, whose
copyright the license carries alongside this package's.

## About

Spongefork is the personal software projects of musician and developer [Ryan Francesconi](https://spongefork.com). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2026, Spongefork returns as his software container for more musical experimentation. In addition to [software releases](https://spongefork.com/shadowtag/), open source components can be found on his [GitHub page](https://github.com/ryanfrancesconi).

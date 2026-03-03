## SPFKAudioHardware

[![Platform](https://img.shields.io/badge/Platforms-macOS%2012+-brightgreen.svg?style=flat)](https://github.com/ryanfrancesconi/SPFKAudioHardware)
[![Swift 6.2.1](https://img.shields.io/badge/Swift-6.2.1-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/ryanfrancesconi/SPFKAudioHardware/LICENSE.md)

A Swift concurrency-first abstraction over the Core Audio Hardware Abstraction Layer (HAL) for macOS. Provides a type-safe, `Sendable` interface to audio device management built on actors and `async`/`await`.

### Features

- **Device enumeration** — query all devices, or filter by input, output, aggregate, Bluetooth, and more
- **Default device management** — get and promote default input, output, and system output devices
- **Volume and mute control** — per-channel scalar/dB volume, virtual main volume, balance, and mute state
- **Sample rate management** — coordinated async sample rate transitions via the `SampleRateState` actor
- **Aggregate devices** — create, configure, and destroy aggregate devices with clock source control
- **Stream formats** — enumerate and filter physical/virtual formats, access stream latency and direction
- **Channel layout** — physical/virtual channel counts, named channels, layout descriptions, and LFE support
- **Property notifications** — typed `AudioDeviceNotification`, `AudioStreamNotification`, and `AudioHardwareNotification` enums dispatched through `NotificationCenter`
- **Latency and safety offsets** — device, stream, and presentation latency; buffer frame size management

### Dependencies

| Package | Purpose |
|---------|---------|
| [spfk-base](https://github.com/ryanfrancesconi/spfk-base) | Shared base utilities |

---

## History

[SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) is a Swift framework that aims to make [Core Audio](https://developer.apple.com/documentation/coreaudio) use less tedious in macOS.

`SimplyCoreAudio` was written by Ruben Nine ([@rnine](https://github.com/rnine)) in 2013-2014 (open-sourced in March 2014 and archived in March 2025) and is licensed under the [MIT](https://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).

## About

Spongefork (SPFK) is the personal software projects of [Ryan Francesconi](https://github.com/ryanfrancesconi). Dedicated to creative sound manipulation, his first application, Spongefork, was released in 1999 for macOS 8. From 2016 to 2025 he was the lead macOS developer at [Audio Design Desk](https://add.app).

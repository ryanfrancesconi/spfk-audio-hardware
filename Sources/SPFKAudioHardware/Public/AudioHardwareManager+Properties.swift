// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

extension AudioHardwareManager {
    // MARK: - Device Enumeration

    /// All the audio device object identifiers currently available.
    ///
    /// - Note: This list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioObjectID` values.
    public var allDeviceIDs: [AudioObjectID] {
        get async { await observer.cache.allDeviceIDs }
    }

    /// All the audio devices currently available.
    ///
    /// - Note: This list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allDevices: [AudioDevice] {
        get async { await observer.cache.allDevices }
    }

    /// All the devices that have at least one input.
    ///
    /// - Note: This list may also include *Aggregate* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var inputDevices: [AudioDevice] {
        get async { await observer.cache.inputDevices }
    }

    /// All the devices that have at least one output.
    ///
    /// - Note: The list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var outputDevices: [AudioDevice] {
        get async { await observer.cache.outputDevices }
    }

    /// All the devices that support input and output.
    ///
    /// - Note: The list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allIODevices: [AudioDevice] {
        get async { await observer.cache.allIODevices }
    }

    /// All the devices that are real devices — not aggregate ones.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allNonAggregateDevices: [AudioDevice] {
        get async { await observer.cache.allNonAggregateDevices }
    }

    /// All the devices that are aggregate devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allAggregateDevices: [AudioDevice] {
        get async { await observer.cache.allAggregateDevices }
    }

    /// All the devices that are bluetooth devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var bluetoothDevices: [AudioDevice] {
        get async { await observer.cache.bluetoothDevices }
    }

    public var splitDevices: [SplitAudioDevice] {
        get async { await observer.cache.splitDevices }
    }
}

extension AudioHardwareManager {
    // MARK: - Default Devices

    /// The default input device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultInputDevice: AudioDevice? {
        get async { await observer.cache.defaultInputDevice }
    }

    /// The default output device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultOutputDevice: AudioDevice? {
        get async { await observer.cache.defaultOutputDevice }
    }

    /// The default system output device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultSystemOutputDevice: AudioDevice? {
        get async { await observer.cache.defaultSystemOutputDevice }
    }
}

extension AudioHardwareManager {
    public static func setSystemInputMute(_ shouldMute: Bool) -> OSStatus {
        let address = AudioObjectPropertyAddress(
            selector: kAudioHardwarePropertyProcessInputMute,
            scope: kAudioObjectPropertyScopeInput,
            element: kAudioObjectPropertyElementMain
        )

        var isMuted: UInt32 = shouldMute ? 1 : 0

        let status = AudioDevice.setPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            address: address,
            andValue: &isMuted
        )

        return status
    }
}

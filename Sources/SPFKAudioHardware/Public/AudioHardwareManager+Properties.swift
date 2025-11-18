// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

extension AudioHardwareManager {
    // MARK: - Device Enumeration

    /// All the audio device identifiers currently available.
    ///
    /// - Note: This list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioObjectID` values.
    public var allDeviceIDs: [AudioObjectID] {
        get async { await hardware.cache.allDeviceIDs }
    }

    /// All the audio devices currently available.
    ///
    /// - Note: This list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allDevices: [AudioDevice] {
        get async { await hardware.cache.allDevices }
    }

    /// All the devices that have at least one input.
    ///
    /// - Note: This list may also include *Aggregate* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allInputDevices: [AudioDevice] {
        get async { await hardware.cache.allInputDevices }
    }

    /// All the devices that have at least one output.
    ///
    /// - Note: The list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allOutputDevices: [AudioDevice] {
        get async { await hardware.cache.allOutputDevices }
    }

    /// All the devices that support input and output.
    ///
    /// - Note: The list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allIODevices: [AudioDevice] {
        get async { await hardware.cache.allIODevices }
    }

    /// All the devices that are real devices — not aggregate ones.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allNonAggregateDevices: [AudioDevice] {
        get async { await  hardware.cache.allNonAggregateDevices }
    }

    /// All the devices that are aggregate devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var allAggregateDevices: [AudioDevice] {
        get async { await hardware.cache.allAggregateDevices }
    }
}

extension AudioHardwareManager {
    // MARK: - Default Devices

    /// The default input device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultInputDevice: AudioDevice? {
        get async { await hardware.cache.defaultInputDevice }
    }

    /// The default output device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultOutputDevice: AudioDevice? {
        get async { await hardware.cache.defaultOutputDevice }
    }

    /// The default system output device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultSystemOutputDevice: AudioDevice? {
        get async { await hardware.cache.defaultSystemOutputDevice }
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

@MainActor
extension AudioHardwareManager {
    // MARK: - Device Enumeration

    /// All the audio device object identifiers currently available.
    ///
    /// - Note: This list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioObjectID` values.
    func allDeviceIDs() async throws -> [AudioObjectID] {
        try await cache.allDeviceIDs()
    }

    /// All the audio devices currently available.
    ///
    /// - Note: This list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public func allDevices() async throws -> [AudioDevice] {
        try await cache.allDevices()
    }

    /// All the devices that have at least one input.
    ///
    /// - Note: This list may also include *Aggregate* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public func inputDevices() async throws -> [AudioDevice] {
        try await cache.inputDevices()
    }

    /// All the devices that have at least one output.
    ///
    /// - Note: The list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public func outputDevices() async throws -> [AudioDevice] {
        try await cache.outputDevices()
    }

    /// All the devices that support input and output.
    ///
    /// - Note: The list may also include *Aggregate* and *Multi-Output* devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    func allIODevices() async throws -> [AudioDevice] {
        try await cache.allIODevices()
    }

    /// All the devices that are real devices — not aggregate ones.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public func nonAggregateDevices() async throws -> [AudioDevice] {
        try await cache.nonAggregateDevices()
    }

    /// All the devices that are aggregate devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public func aggregateDevices() async throws -> [AudioDevice] {
        try await cache.aggregateDevices()
    }

    /// All the devices that are bluetooth devices.
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public func bluetoothDevices() async throws -> [AudioDevice] {
        try await cache.bluetoothDevices()
    }

    public func splitDevices() async throws -> [SplitAudioDevice] {
        try await cache.splitDevices()
    }
}

@MainActor
extension AudioHardwareManager {
    // MARK: - Default Devices

    /// The default input device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultInputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .defaultInput)
        }
    }

    /// The default output device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultOutputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .defaultOutput)
        }
    }

    /// The default system output device.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var defaultSystemOutputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .alertOutput)
        }
    }
}

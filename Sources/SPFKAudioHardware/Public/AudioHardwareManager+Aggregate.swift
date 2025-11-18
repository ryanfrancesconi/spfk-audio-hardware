// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKBase

// MARK: - Create and Destroy Aggregate Devices

extension AudioHardwareManager {
    /// This routine creates a new aggregate audio device.
    ///
    /// - Parameter mainDevice: An audio device. This will also be the clock source.
    /// - Parameter secondDevice: An audio device.
    ///
    /// - Returns *(optional)* An aggregate `AudioDevice` if one can be created.
    public func createAggregateDevice(
        mainDevice: AudioDevice,
        secondDevice: AudioDevice?,
        named name: String,
        uid: String
    ) async throws -> AudioDevice {
        guard let mainDeviceUID = mainDevice.uid else {
            throw NSError(description: "Failed to get main device's UID")
        }

        var deviceList: [[String: Any]] = [
            [kAudioSubDeviceUIDKey: mainDeviceUID],
        ]

        // make sure same device isn't added twice
        if let secondDeviceUID = secondDevice?.uid, secondDeviceUID != mainDeviceUID {
            deviceList.append([kAudioSubDeviceUIDKey: secondDeviceUID])
        }

        let desc: [String: Any] = [
            kAudioAggregateDeviceNameKey: name,
            kAudioAggregateDeviceUIDKey: uid,
            kAudioAggregateDeviceSubDeviceListKey: deviceList,
            kAudioAggregateDeviceMainSubDeviceKey: mainDeviceUID,
        ]

        var deviceID: AudioDeviceID = 0
        let status = AudioHardwareCreateAggregateDevice(desc as CFDictionary, &deviceID)

        guard status == noErr else {
            throw NSError(description: "Failed creating aggregate device with error: (\(status.fourCharCodeToString()))")
        }

        guard let newDevice = await AudioDevice.lookup(by: deviceID) else {
            throw NSError(description: "Failed creating aggregate device")
        }

        return newDevice
    }

    /// Destroy the given audio aggregate device.
    ///
    /// The actual destruction of the device is asynchronous and may take place after
    /// the call to this routine has returned.
    ///
    /// - Parameter id: The `AudioObjectID` of the audio aggregate device to destroy.
    /// - Returns An `OSStatus` indicating success or failure.
    public func removeAggregateDevice(id deviceID: AudioObjectID) -> OSStatus {
        AudioHardwareDestroyAggregateDevice(deviceID)
    }
}

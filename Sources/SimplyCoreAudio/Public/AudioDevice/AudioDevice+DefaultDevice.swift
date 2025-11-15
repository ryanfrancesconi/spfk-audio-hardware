//
//  AudioDevice+DefaultDevice.swift
//
//  Created by Ruben Nine on 20/3/21.
//

import CoreAudio.AudioHardware
import Foundation

// MARK: - Public Functions & Properties

public extension AudioDevice {
    // MARK: - Default Device Properties

    /// Allows getting and setting this device as the default input device.
    var isDefaultInputDevice: Bool {
        get { AudioHardware.defaultDevice(of: .input) == self }
        set { _ = try? promote(to: .input) } // i don't like these as the error is ignored
    }

    /// Allows getting and setting this device as the default output device.
    var isDefaultOutputDevice: Bool {
        get { AudioHardware.defaultDevice(of: .output) == self }
        set { _ = try? promote(to: .output) }
    }

    /// Allows getting and setting this device as the default system output device.
    var isDefaultSystemOutputDevice: Bool {
        get { AudioHardware.defaultDevice(of: .systemOutput) == self }
        set { _ = try? promote(to: .systemOutput) }
    }

    /// Promote device to passed in type
    /// - Parameter deviceType: `AudioHardwareDefaultDeviceType`
    /// - Returns: `OSStatus` with error or noErr if succeeds
    func promote(to deviceType: DefaultDeviceType) throws -> OSStatus {
        promote(to: deviceType.propertySelector)
    }
}

// MARK: - Private Functions

private extension AudioDevice {
    func promote(to type: AudioObjectPropertySelector) -> OSStatus {
        let address = self.address(selector: type)

        var deviceID = UInt32(id)

        let status = setPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            address: address,
            andValue: &deviceID
        )

        return status
    }
}

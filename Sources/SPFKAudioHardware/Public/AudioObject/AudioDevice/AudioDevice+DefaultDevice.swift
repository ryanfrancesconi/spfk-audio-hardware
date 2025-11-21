// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

extension AudioDevice {
    /// Promote device to passed in selector type
    ///
    /// - Parameter type: `DefaultSelectorType`
    /// - Returns: `OSStatus` with error or noErr if succeeds
    @discardableResult public func promote(to type: DefaultSelectorType) throws -> OSStatus {
        promote(to: type.propertySelector)
    }

    /// Check if this device is set to a passed in `DefaultSelectorType`
    /// - Parameter type: `DefaultSelectorType` to check
    /// - Returns: `true` when the device is set to the type, `false` otherwise.
    public func isDefaultDevice(for type: DefaultSelectorType) async -> Bool {
        await Self.defaultDevice(of: type) == self
    }

    /// Promote device to passed in type
    /// - Parameter deviceType: `AudioObjectPropertySelector`
    /// - Returns: `OSStatus` with error or noErr if succeeds
    @discardableResult private func promote(to type: AudioObjectPropertySelector) -> OSStatus {
        let address = AudioObjectPropertyAddress(selector: type)

        var deviceID = UInt32(id)

        let status = Self.setPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            address: address,
            andValue: &deviceID
        )

        return status
    }
}

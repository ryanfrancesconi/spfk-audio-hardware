// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Volume Conversion Functions

public extension AudioDevice {
    /// Converts a scalar volume to a decibel *(dbFS)* volume for the given channel and scope.
    ///
    /// - Parameter volume: A scalar volume.
    /// - Parameter channel: A channel number.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the scalar volume converted in decibels.
    func scalarToDecibels(volume: Float32, channel: UInt32, scope: Scope) -> Float32? {
        guard let address = validAddress(selector: kAudioDevicePropertyVolumeScalarToDecibels,
                                         scope: scope.propertyScope,
                                         element: channel) else { return nil }

        var inOutVolume: Float32 = 0
        let status = getPropertyData(address, andValue: &inOutVolume)

        return kAudioHardwareNoError == status ? inOutVolume : nil
    }

    /// Converts a relative decibel *(dbFS)* volume to a scalar volume for the given channel and scope.
    ///
    /// - Parameter volume: A volume in relative decibels (dbFS).
    /// - Parameter channel: A channel number.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the decibels volume converted to scalar.
    func decibelsToScalar(volume: Float32, channel: UInt32, scope: Scope) -> Float32? {
        guard let address = validAddress(selector: kAudioDevicePropertyVolumeDecibelsToScalar,
                                         scope: scope.propertyScope,
                                         element: channel) else { return nil }

        var inOutVolume: Float32 = 0
        let status = getPropertyData(address, andValue: &inOutVolume)

        return kAudioHardwareNoError == status ? inOutVolume : nil
    }
}

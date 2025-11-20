// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKBase

extension AudioDevice {
    public static func defaultDevice(of deviceType: DefaultSelectorType) async -> AudioDevice? {
        let address = AudioObjectPropertyAddress(selector: deviceType.propertySelector)
        var deviceID = AudioDeviceID()

        let status = AudioDevice.getPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                                 address: address,
                                                 andValue: &deviceID)

        return await noErr == status ? AudioObjectPool.shared.lookup(id: deviceID) : nil
    }

    /// Returns an `AudioDevice` by providing a valid audio device unique identifier.
    ///
    /// - Parameter uid: An audio device unique identifier.
    ///
    /// - Note: If unique identifier is not valid, `nil` will be returned.
    public static func lookup(uid: String) async -> AudioDevice? {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDeviceForUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID = kAudioObjectUnknown
        var cfUID = (uid as CFString)

        let status: OSStatus = withUnsafeMutablePointer(to: &cfUID) { cfUIDPtr in
            withUnsafeMutablePointer(to: &deviceID) { deviceIDPtr in
                var translation = AudioValueTranslation(
                    mInputData: cfUIDPtr,
                    mInputDataSize: UInt32(MemoryLayout<CFString>.size),
                    mOutputData: deviceIDPtr,
                    mOutputDataSize: UInt32(MemoryLayout<AudioObjectID>.size)
                )

                return getPropertyData(
                    AudioObjectID(kAudioObjectSystemObject),
                    address: address,
                    andValue: &translation
                )
            }
        }

        if noErr != status || deviceID == kAudioObjectUnknown {
            return nil
        }

        return await AudioObjectPool.shared.lookup(id: deviceID)
    }
}

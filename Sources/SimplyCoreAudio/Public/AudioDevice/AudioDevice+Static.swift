// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

extension AudioDevice {
    public static func defaultDevice(of deviceType: DefaultSelectorType) -> AudioDevice? {
        let address = AudioDevice.address(selector: deviceType.propertySelector)
        var deviceID = AudioDeviceID()
        let status = AudioDevice.getPropertyData(AudioObjectID(kAudioObjectSystemObject), address: address, andValue: &deviceID)

        return noErr == status ? AudioDevice.lookup(by: deviceID) : nil
    }

    /// Returns an `AudioDevice` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    /// - Note: If identifier is not valid, `nil` will be returned.
    public static func lookup(by id: AudioObjectID) -> AudioDevice? {
        var instance: AudioDevice? = AudioObjectPool.shared.get(id)

        if instance == nil {
            instance = AudioDevice(id: id)
        }

        return instance
    }

    /// Returns an `AudioDevice` by providing a valid audio device unique identifier.
    ///
    /// - Parameter uid: An audio device unique identifier.
    ///
    /// - Note: If unique identifier is not valid, `nil` will be returned.
    public static func lookup(by uid: String) -> AudioDevice? {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDeviceForUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: Element.main.propertyElement
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

        return lookup(by: deviceID)
    }
}

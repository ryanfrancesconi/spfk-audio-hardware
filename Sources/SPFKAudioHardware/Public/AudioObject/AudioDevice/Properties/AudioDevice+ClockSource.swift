// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - 𝍄 Clock Source Functions

public extension AudioDevice {
    /// The current clock source identifier for this audio device.
    ///
    /// - Returns: *(optional)* A `UInt32` containing the clock source identifier.
    var clockSourceID: UInt32? {
        guard let address = validAddress(selector: kAudioDevicePropertyClockSource) else { return nil }
        return getProperty(address: address)
    }

    /// The current clock source name for this audio device.
    ///
    /// - Returns: *(optional)* A `String` containing the clock source name.
    var clockSourceName: String? {
        guard let clockSourceID else { return nil }
        return clockSourceName(clockSourceID: clockSourceID)
    }

    /// A list of all the clock source identifiers available for this audio device.
    ///
    /// - Returns: *(optional)* A `UInt32` array containing all the clock source identifiers.
    var clockSourceIDs: [UInt32]? {
        guard let address = validAddress(selector: kAudioDevicePropertyClockSources) else { return nil }

        var clockSourceIDs = [UInt32]()

        guard noErr == getPropertyDataArray(address, value: &clockSourceIDs, andDefaultValue: 0) else { return nil }

        return clockSourceIDs
    }

    /// A list of all the clock source names available for this audio device.
    ///
    /// - Returns: *(optional)* A `String` array containing all the clock source names.
    var clockSourceNames: [String]? {
        guard let clockSourceIDs else { return nil }

        return clockSourceIDs.map {
            // We expect clockSourceNameForClockSourceID to never fail in this case,
            // but in the unlikely case it does, we provide a default value.
            clockSourceName(clockSourceID: $0) ?? "Clock source \(String(describing: clockSourceID))"
        }
    }

    /// Returns the clock source name for a given clock source ID.
    ///
    /// - Parameter clockSourceID: A clock source ID.
    ///
    /// - Returns: *(optional)* A `String` with the source clock name.
    func clockSourceName(clockSourceID: UInt32) -> String? {
        var name: CFString = "" as CFString
        var clockSourceID = clockSourceID

        let status: OSStatus = withUnsafeMutablePointer(to: &clockSourceID) { clockSourceIDPtr in
            withUnsafeMutablePointer(to: &name) { namePtr in
                var translation = AudioValueTranslation(
                    mInputData: clockSourceIDPtr,
                    mInputDataSize: UInt32(MemoryLayout<UInt32>.size),
                    mOutputData: namePtr,
                    mOutputDataSize: UInt32(MemoryLayout<CFString>.size)
                )

                let address = AudioObjectPropertyAddress(
                    mSelector: kAudioDevicePropertyClockSourceNameForIDCFString,
                    mScope: kAudioObjectPropertyScopeGlobal,
                    mElement: kAudioObjectPropertyElementMain
                )

                return getPropertyData(address, andValue: &translation)
            }
        }

        return noErr == status ? (name as String) : nil
    }

    /// Sets the clock source for this audio device.
    ///
    /// - Parameter clockSourceID: A clock source ID.
    ///
    /// - Returns: `true` on success, `false` otherwise.
    @discardableResult func setClockSourceID(_ clockSourceID: UInt32) -> OSStatus {
        guard let address = validAddress(selector: kAudioDevicePropertyClockSource) else { return kAudioHardwareBadObjectError }
        return setProperty(address: address, value: clockSourceID)
    }
}

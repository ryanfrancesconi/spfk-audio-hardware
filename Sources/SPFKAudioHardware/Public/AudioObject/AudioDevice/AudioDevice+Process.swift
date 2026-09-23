// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio.AudioHardware
import Foundation
import SPFKBase

extension AudioDevice {
    /// The devices another process is running audio I/O on, on the `.input` or `.output` side.
    ///
    /// Empty when the process has no Core Audio connection. Throws where the system has no
    /// process objects, which callers should treat as "unknown" rather than "none".
    public static func devices(usedByProcess pid: pid_t, scope: Scope) async throws -> [AudioDevice] {
        var processIDs = [AudioObjectID]()
        let translateStatus = getPropertyDataArray(
            AudioObjectID(kAudioObjectSystemObject),
            address: AudioObjectPropertyAddress(selector: kAudioHardwarePropertyTranslatePIDToProcessObject),
            qualifierDataSize: UInt32(MemoryLayout<pid_t>.size),
            qualifierData: [UInt32(bitPattern: pid)],
            value: &processIDs,
            andDefaultValue: kAudioObjectUnknown
        )

        guard noErr == translateStatus else {
            throw NSError(description: "process lookup for pid \(pid) failed with error (\(translateStatus.fourCC))")
        }

        guard let processID = processIDs.first, processID != kAudioObjectUnknown else { return [] }

        var deviceIDs = [AudioObjectID]()
        let devicesStatus = getPropertyDataArray(
            processID,
            address: AudioObjectPropertyAddress(selector: kAudioProcessPropertyDevices, scope: scope.propertyScope),
            value: &deviceIDs,
            andDefaultValue: kAudioObjectUnknown
        )

        guard noErr == devicesStatus else {
            throw NSError(description: "device list for pid \(pid) failed with error (\(devicesStatus.fourCC))")
        }

        var devices = [AudioDevice]()
        for id in deviceIDs where id != kAudioObjectUnknown {
            devices.append(try await AudioObjectPool.shared.lookup(id: id))
        }
        return devices
    }
}

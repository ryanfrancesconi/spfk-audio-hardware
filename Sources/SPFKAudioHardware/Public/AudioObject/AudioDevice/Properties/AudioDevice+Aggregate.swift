// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Aggregate Device Functions

extension AudioDevice {
    /// Whether this device is a process-private aggregate created internally by the audio engine.
    ///
    /// Identified via the `"private"` key in the aggregate's composition dictionary
    /// (`kAudioAggregateDevicePropertyComposition`), which CoreAudio sets to `1` for
    /// process-private aggregates (e.g. AVAudioEngine's internal I/O device) and `0`
    /// for user-visible ones (e.g. Audio MIDI Setup aggregates).
    public var isPrivateAggregateDevice: Bool {
        guard classID == kAudioAggregateDeviceClassID else { return false }
        return aggregateComposition?["private"] as? Int == 1
    }

    /// - Returns: `true` if this device is an aggregate one, `false` otherwise.
    public var isAggregateDevice: Bool {
        get async {
            guard classID == kAudioAggregateDeviceClassID else { return false }

            guard let ownedAggregateDevices = await ownedAggregateDevices else { return false }
            return !ownedAggregateDevices.isEmpty
        }
    }

    /// All the subdevices of this aggregate device
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var ownedAggregateDevices: [AudioDevice]? {
        get async {
            guard classID == kAudioAggregateDeviceClassID else { return nil }

            guard let ownedObjectIDs, ownedObjectIDs.isNotEmpty else { return nil }

            let devices: [AudioDevice] = await ownedObjectIDs.async.compactMap {
                try? await AudioObjectPool.shared.lookup(id: $0)
            }.toArray()

            return devices
        }
    }

    /// All the subdevices of this aggregate device that support input
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var ownedAggregateInputDevices: [AudioDevice]? {
        get async {
            await ownedAggregateDevices?.filter {
                guard let channels = $0.layoutChannels(scope: .input) else { return false }
                return channels > 0
            }
        }
    }

    /// All the subdevices of this aggregate device that support output
    ///
    /// - Returns: An array of `AudioDevice` objects.
    public var ownedAggregateOutputDevices: [AudioDevice]? {
        get async {
            await ownedAggregateDevices?.filter {
                guard let channels = $0.layoutChannels(scope: .output) else { return false }
                return channels > 0
            }
        }
    }
}

// MARK: - Private

extension AudioDevice {
    /// Reads the `kAudioAggregateDevicePropertyComposition` dictionary for this device.
    var aggregateComposition: [String: Any]? {
        var ref: CFPropertyList? = nil
        var size = UInt32(MemoryLayout<CFPropertyList?>.size)
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioAggregateDevicePropertyComposition,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = withUnsafeMutablePointer(to: &ref) { ptr in
            AudioObjectGetPropertyData(objectID, &addr, 0, nil, &size, UnsafeMutableRawPointer(ptr))
        }
        guard status == noErr else { return nil }
        return ref as? [String: Any]
    }
}


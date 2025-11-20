// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Aggregate Device Functions

public extension AudioDevice {
    /// - Returns: `true` if this device is an aggregate one, `false` otherwise.
    var isAggregateDevice: Bool {
        get async {
            guard classID == kAudioAggregateDeviceClassID else { return false }
            
            guard let ownedAggregateDevices = await ownedAggregateDevices else { return false }
            return !ownedAggregateDevices.isEmpty
        }
    }

    /// All the subdevices of this aggregate device
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var ownedAggregateDevices: [AudioDevice]? {
        get async {
            guard classID == kAudioAggregateDeviceClassID else { return nil }

            guard let ownedObjectIDs, ownedObjectIDs.isNotEmpty else { return nil }
            
            let devices: [AudioDevice] = await ownedObjectIDs.async.compactMap {
                await AudioObjectPool.shared.lookup(id: $0)
            }.toArray()
            
            return devices
        }
    }

    /// All the subdevices of this aggregate device that support input
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var ownedAggregateInputDevices: [AudioDevice]? {
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
    var ownedAggregateOutputDevices: [AudioDevice]? {
        get async {
            await ownedAggregateDevices?.filter {
                guard let channels = $0.layoutChannels(scope: .output) else { return false }
                return channels > 0
            }
        }
    }
}

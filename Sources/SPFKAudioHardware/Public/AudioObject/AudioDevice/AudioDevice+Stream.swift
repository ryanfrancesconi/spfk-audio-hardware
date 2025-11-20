// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import AsyncAlgorithms
import CoreAudio
import Foundation

// MARK: - Stream Functions

public extension AudioDevice {
    /// Returns a list of streams for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* An array of `AudioStream` objects.
    func streams(scope: Scope) async -> [AudioStream]? {
        guard let address = validAddress(selector: kAudioDevicePropertyStreams,
                                         scope: scope.propertyScope) else { return nil }

        var streamIDs = [AudioStreamID]()

        guard noErr == getPropertyDataArray(address, value: &streamIDs, andDefaultValue: 0) else { return nil }

        return await streamIDs.async.compactMap {
            await AudioStream.lookup(id: $0)
        }.toArray()
    }
}

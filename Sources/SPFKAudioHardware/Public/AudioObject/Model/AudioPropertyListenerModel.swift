// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

public protocol AudioPropertyListenerModel: AudioObjectModel {
    var notificationType: any PropertyAddressNotification.Type { get }
}

extension AudioPropertyListenerModel {
    /// Returns an `AudioPropertyListenerModel` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    /// - Note: If identifier is not valid, `nil` will be returned.
    public static func lookup(by id: AudioObjectID) async -> Self? {
//        if let device: Self = await AudioObjectPool.shared.get(id) {
//            return device
//        }
//
//        do {
//            let device = try await Self(objectID: id)
//            try await AudioObjectPool.shared.insert(device, for: id)
//            return device
//
//        } catch {
//            Log.error(error)
//        }
//
//        return nil

        await AudioObjectPool.shared.lookup(by: id)
    }
}

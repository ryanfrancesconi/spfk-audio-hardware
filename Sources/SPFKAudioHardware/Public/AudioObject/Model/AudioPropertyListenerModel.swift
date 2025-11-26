// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

public protocol AudioPropertyListenerModel: AudioObjectModel, Sendable {
    var notificationType: any PropertyAddressNotification.Type { get }
}

extension AudioPropertyListenerModel {
    /// Returns an `AudioPropertyListenerModel` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    /// - Note: If identifier is not valid, `nil` will be returned.
    public static func lookup(id: AudioObjectID) async -> Self? {
        // the Self return informs the type
        await AudioObjectPool.shared.lookup(id: id)
    }
}

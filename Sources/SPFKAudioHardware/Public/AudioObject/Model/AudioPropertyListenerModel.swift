// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

/// An `AudioObjectModel` that can observe property changes via `AudioObjectPropertyListener`.
///
/// Conforming types provide a `notificationType` that maps raw `AudioObjectPropertyAddress`
/// callbacks into typed `PropertyAddressNotification` values (e.g., `AudioDeviceNotification`).
public protocol AudioPropertyListenerModel: AudioObjectModel, Sendable {
    /// The notification type used to map Core Audio property address changes
    /// into typed Swift notifications for this audio object.
    var notificationType: any PropertyAddressNotification.Type { get }
}

extension AudioPropertyListenerModel {
    /// Returns an `AudioPropertyListenerModel` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    /// - Note: If identifier is not valid, `nil` will be returned.
    public static func lookup(id: AudioObjectID) async throws -> Self {
        // the Self return informs the type
        try await AudioObjectPool.shared.lookup(id: id)
    }
}

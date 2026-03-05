// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKBase

/// Typed notifications for property changes on an `AudioStream`.
public enum AudioStreamNotification: Hashable, Sendable {
    /// Called whenever the audio stream `isActive` flag changes.
    case streamIsActiveDidChange(objectID: AudioObjectID)

    /// Called whenever the audio stream physical format changes.
    case streamPhysicalFormatDidChange(objectID: AudioObjectID)
}

extension AudioStreamNotification: PropertyAddressNotification {
    /// Maps a raw `AudioObjectPropertyAddress` to a typed `AudioStreamNotification` case.
    ///
    /// Returns `nil` for unrecognized property selectors.
    public init?(objectID: AudioObjectID, propertyAddress: AudioObjectPropertyAddress) {
        switch propertyAddress.mSelector {
        case kAudioStreamPropertyIsActive:
            self = .streamIsActiveDidChange(objectID: objectID)

        case kAudioStreamPropertyPhysicalFormat:
            self = .streamPhysicalFormatDidChange(objectID: objectID)

        default:
            Log.error("AudioStreamNotification: unhandled mSelector (\(propertyAddress.mSelector.fourCC))")
            return nil
        }
    }

    /// The `Notification.Name` for posting this notification via `NotificationCenter`.
    public var name: Notification.Name {
        switch self {
        case .streamIsActiveDidChange:
            .streamIsActiveDidChange
        case .streamPhysicalFormatDidChange:
            .streamPhysicalFormatDidChange
        }
    }
}

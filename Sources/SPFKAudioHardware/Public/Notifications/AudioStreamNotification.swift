// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

public enum AudioStreamNotification: Hashable {
    /// Called whenever the audio stream `isActive` flag changes.
    case streamIsActiveDidChange

    /// Called whenever the audio stream physical format changes.
    case streamPhysicalFormatDidChange
}

extension AudioStreamNotification: PropertyAddressNotification {
    public init?(propertyAddress: AudioObjectPropertyAddress) {
        switch propertyAddress.mSelector {
        case kAudioStreamPropertyIsActive:
            self = .streamIsActiveDidChange

        case kAudioStreamPropertyPhysicalFormat:
            self = .streamPhysicalFormatDidChange

        default:
            return nil
        }
    }

    public var name: Notification.Name {
        switch self {
        case .streamIsActiveDidChange:
            .streamIsActiveDidChange
        case .streamPhysicalFormatDidChange:
            .streamPhysicalFormatDidChange
        }
    }
}

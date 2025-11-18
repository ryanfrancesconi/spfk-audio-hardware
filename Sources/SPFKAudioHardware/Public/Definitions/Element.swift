// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

public enum Element {
    case main
    case custom(value: UInt32)
}

// MARK: - Internal Functions

extension Element {
    var propertyElement: AudioObjectPropertyElement {
        switch self {
        case .main:
            return kAudioObjectPropertyElementMain
        case let .custom(value):
            return value
        }
    }
}

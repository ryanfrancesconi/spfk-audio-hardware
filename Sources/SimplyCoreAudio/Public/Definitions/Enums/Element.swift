//
//  Element.swift
//
//  Created by Ruben Nine on 16/8/21.
//

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

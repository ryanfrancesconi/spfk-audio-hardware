// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

/// Indicates the scope used by an `AudioDevice` or `AudioStream`.
///
/// The scope specifies the section of the object in which to look for the property,
/// such as input, output, global, etc. Note that each class has a different set of
/// scopes. A subclass inherits its superclass's set of scopes.
///
/// - Please note that `AudioStream` only supports `input` and `output` scopes,
/// though an `AudioDevice` may, additionally, support `global` and `playthrough`.
public enum Scope: Sendable {
    /// The AudioObjectPropertyScope for properties that apply to the object as a
    /// whole. All objects have a global scope and for most it is their only scope.
    case global

    /// The AudioObjectPropertyScope for properties that apply to the input side of
    /// an object
    case input

    /// The AudioObjectPropertyScope for properties that apply to the output side of
    /// an object.
    case output

    /// The AudioObjectPropertyScope for properties that apply to the play through
    /// side of an object.
    case playthrough

    /// The wildcard value for AudioObjectPropertySelectors
    case wildcard

    /// The AudioObjectPropertyElement value for properties that apply to the main
    /// element or to the entire scope.
    case main
}

// MARK: - Internal Functions

// swiftformat:disable consecutiveSpaces
extension Scope {
    public init(propertyScope: AudioObjectPropertyScope) {
        switch propertyScope {
        case kAudioObjectPropertyScopeGlobal:       self = .global
        case kAudioObjectPropertyScopeInput:        self = .input
        case kAudioObjectPropertyScopeOutput:       self = .output
        case kAudioObjectPropertyScopePlayThrough:  self = .playthrough
        case kAudioObjectPropertyElementMain:       self = .main
        case kAudioObjectPropertyScopeWildcard:     self = .wildcard

        default:
            // Note, the default is only here to satisfy the switch to be exhaustive
            self = .wildcard
        }
    }

    var propertyScope: AudioObjectPropertyScope {
        switch self {
        case .global:       kAudioObjectPropertyScopeGlobal
        case .input:        kAudioObjectPropertyScopeInput
        case .output:       kAudioObjectPropertyScopeOutput
        case .playthrough:  kAudioObjectPropertyScopePlayThrough
        case .main:         kAudioObjectPropertyElementMain
        case .wildcard:     kAudioObjectPropertyScopeWildcard
        }
    }

    public var title: String {
        switch self {
        case .input:        "Input"
        case .output:       "Output"
        case .global:       "Global"
        case .playthrough:  "Playthrough"
        case .main:         "Main"
        case .wildcard:     "Wildcard"
        }
    }
}

// swiftformat:enable consecutiveSpaces

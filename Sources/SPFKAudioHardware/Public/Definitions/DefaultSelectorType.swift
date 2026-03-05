// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

public enum DefaultSelectorType: Hashable, Codable, CaseIterable, Sendable {
    /// The the default system input AudioDevice
    case defaultInput

    /// The default system output AudioDevice
    case defaultOutput

    /// The output AudioDevice to use for system related sound
    /// from the alert sound to digital call progress.
    case alertOutput

    /// The Core Audio property selector constant for this default device type.
    public var propertySelector: AudioObjectPropertySelector {
        switch self {
        case .defaultInput:
            kAudioHardwarePropertyDefaultInputDevice

        case .defaultOutput:
            kAudioHardwarePropertyDefaultOutputDevice

        case .alertOutput:
            kAudioHardwarePropertyDefaultSystemOutputDevice
        }
    }

    /// The `Notification.Name` posted when the system default for this device type changes.
    public var notificationName: Notification.Name {
        switch self {
        case .defaultInput:
            .defaultInputDeviceChanged

        case .defaultOutput:
            .defaultOutputDeviceChanged

        case .alertOutput:
            .defaultSystemOutputDeviceChanged
        }
    }
}

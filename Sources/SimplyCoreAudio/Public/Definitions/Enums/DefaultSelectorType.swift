import CoreAudio.AudioHardware
import Foundation

public enum DefaultSelectorType: Hashable, Codable, CaseIterable {
    /// The the default system input AudioDevice
    case defaultInput

    /// The default system output AudioDevice
    case defaultOutput

    /// The output AudioDevice to use for system related sound
    /// from the alert sound to digital call progress.
    case alertOutput

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

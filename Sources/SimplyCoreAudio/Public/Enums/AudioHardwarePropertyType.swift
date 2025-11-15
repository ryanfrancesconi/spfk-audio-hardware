import CoreAudio.AudioHardware
import Foundation

public enum AudioHardwareDefaultDeviceType {
    /// The AudioObjectID of the output AudioDevice to use for system related sound
    /// from the alert sound to digital call progress.
    case systemOutput

    /// The AudioObjectID of the default output AudioDevice
    case output

    /// The AudioObjectID of the default input AudioDevice
    case input

    public var propertySelector: AudioObjectPropertySelector {
        switch self {
        case .systemOutput:
            kAudioHardwarePropertyDefaultSystemOutputDevice
        case .output:
            kAudioHardwarePropertyDefaultOutputDevice
        case .input:
            kAudioHardwarePropertyDefaultInputDevice
        }
    }

    public var notificationName: Notification.Name {
        switch self {
        case .systemOutput:
            .defaultSystemOutputDeviceChanged
        case .output:
            .defaultOutputDeviceChanged
        case .input:
            .defaultInputDeviceChanged
        }
    }
}

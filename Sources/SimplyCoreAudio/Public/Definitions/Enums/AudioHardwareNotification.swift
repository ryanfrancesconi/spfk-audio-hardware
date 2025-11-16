// Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import CoreAudio.AudioHardware

public enum AudioHardwareNotification: Hashable {
    /// Called whenever the default system output device changes.
    case defaultSystemOutputDeviceChanged

    /// Called whenever the default input device changes.
    case defaultInputDeviceChanged

    /// Called whenever the default output device changes.
    case defaultOutputDeviceChanged

    /// Called whenever the list of hardware devices and device subdevices changes.
    /// (i.e., devices that are part of *Aggregate* or *Multi-Output* devices.)
    case deviceListChanged(addedDevices: [AudioDevice], removedDevices: [AudioDevice])

    public var name: Notification.Name {
        switch self {
        case .defaultSystemOutputDeviceChanged:
            .defaultSystemOutputDeviceChanged
        case .defaultInputDeviceChanged:
            .defaultInputDeviceChanged
        case .defaultOutputDeviceChanged:
            .defaultOutputDeviceChanged
        case .deviceListChanged:
            .deviceListChanged
        }
    }
}

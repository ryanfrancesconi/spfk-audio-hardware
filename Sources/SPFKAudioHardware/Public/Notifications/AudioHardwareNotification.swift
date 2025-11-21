// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import SPFKBase

public enum AudioHardwareNotification: Hashable, Sendable {
    /// Called whenever the default system output device changes.
    case defaultSystemOutputDeviceChanged(objectID: AudioObjectID)

    /// Called whenever the default input device changes.
    case defaultInputDeviceChanged(objectID: AudioObjectID)

    /// Called whenever the default output device changes.
    case defaultOutputDeviceChanged(objectID: AudioObjectID)

    /// Called whenever the list of hardware devices and device subdevices changes.
    /// (i.e., devices that are part of *Aggregate* or *Multi-Output* devices.)
    case deviceListChanged(objectID: AudioObjectID, event: DeviceStatusEvent)
}

extension AudioHardwareNotification: PropertyAddressNotification {
    public init?(objectID: AudioObjectID, propertyAddress: AudioObjectPropertyAddress) {
        switch propertyAddress.mSelector {
        case kAudioObjectPropertyOwnedObjects:
            self = .deviceListChanged(objectID: objectID, event: .init())

        case kAudioHardwarePropertyDefaultInputDevice:
            self = .defaultInputDeviceChanged(objectID: objectID)

        case kAudioHardwarePropertyDefaultOutputDevice:
            self = .defaultOutputDeviceChanged(objectID: objectID)

        case kAudioHardwarePropertyDefaultSystemOutputDevice:
            self = .defaultSystemOutputDeviceChanged(objectID: objectID)

        default:
            Log.error("AudioHardwareNotification: unhandled mSelector (\(propertyAddress.mSelector.fourCC))")
            return nil
        }
    }
}

extension AudioHardwareNotification {
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

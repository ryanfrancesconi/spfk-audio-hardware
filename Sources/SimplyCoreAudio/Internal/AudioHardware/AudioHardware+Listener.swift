// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import CoreAudio
import Foundation
import SimplyCoreAudioC

extension AudioHardware: SimplyCoreAudioC.PropertyListenerDelegate {
    func propertyListener(_ propertyListener: PropertyListener, eventReceived propertyAddress: AudioObjectPropertyAddress) {
        var notification: AudioHardwareNotification?

        switch propertyAddress.mSelector {
        case kAudioObjectPropertyOwnedObjects:
            // Obtain added and removed devices.
            var addedDevices: [AudioDevice] = []
            var removedDevices: [AudioDevice] = []

            // TODO: remove queue
            queue.sync {
                let latestDeviceList = allDevices

                addedDevices = latestDeviceList.filter { !cachedDevices.contains($0) }
                removedDevices = cachedDevices.filter { !latestDeviceList.contains($0) }
            }

            // Add new devices & remove old ones.
            updateKnownDevices(adding: addedDevices, andRemoving: removedDevices)

            notification = .deviceListChanged(addedDevices: addedDevices, removedDevices: removedDevices)

        case kAudioHardwarePropertyDefaultInputDevice:
            notification = .defaultInputDeviceChanged

        case kAudioHardwarePropertyDefaultOutputDevice:
            notification = .defaultOutputDeviceChanged

        case kAudioHardwarePropertyDefaultSystemOutputDevice:
            notification = .defaultSystemOutputDeviceChanged

        default:
            break
        }

        if let notification {
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: notification.name,
                    object: notification,
                    userInfo: nil
                )
            }
        }
    }
}

// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import CoreAudio
import Foundation
import SimplyCoreAudioC

class AudioDeviceListener: NSObject, SimplyCoreAudioC.PropertyListenerDelegate {
    var eventHandler: ((AudioDeviceNotification) -> Void)?

    init(eventHandler: ((AudioDeviceNotification) -> Void)?) {
        self.eventHandler = eventHandler
    }
    
    func propertyListener(_ propertyListener: PropertyListener, eventReceived propertyAddress: AudioObjectPropertyAddress) {
        guard let notification = AudioDeviceNotification(propertyAddress: propertyAddress) else { return }
        send(notification: notification)
    }

    private func send(notification: AudioDeviceNotification) {
        Task { @MainActor in
            eventHandler?(notification)
        }
    }
}

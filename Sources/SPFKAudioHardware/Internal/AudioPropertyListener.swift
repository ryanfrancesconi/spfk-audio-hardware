// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC

class AudioPropertyListener: NSObject {
    let objectID: AudioObjectID

    private(set) lazy var cListener: PropertyListener = {
        let cListener = PropertyListener(objectId: objectID)
        cListener.delegate = self
        return cListener
    }()

    var eventHandler: ((any PropertyAddressNotification) -> Void)?

    var notificationType: any PropertyAddressNotification.Type

    init<T: PropertyAddressNotification>(
        notificationType: T.Type,
        objectID: AudioObjectID,
        eventHandler: ((any PropertyAddressNotification) -> Void)?
    ) {
        self.notificationType = notificationType
        self.objectID = objectID
        self.eventHandler = eventHandler
    }

    func start() throws {
        // will lazy create here when referenced
        let status = cListener.start()

        guard noErr == status else {
            throw NSError(description: "failed to start listening for \(notificationType) with error \(status)")
        }
    }

    func stop() throws {
        let status = cListener.stop()

        guard noErr == status else {
            throw NSError(description: "failed to stop listening for \(notificationType) with error \(status)")
        }
    }
}

extension AudioPropertyListener: SPFKAudioHardwareC.PropertyListenerDelegate {
    func propertyListener(_ propertyListener: PropertyListener, eventReceived propertyAddress: AudioObjectPropertyAddress) {
        guard let notification = notificationType.init(propertyAddress: propertyAddress) else { return }
        send(notification: notification)
    }

    private func send(notification: any PropertyAddressNotification) {
        Task { @MainActor in
            eventHandler?(notification)
        }
    }
}

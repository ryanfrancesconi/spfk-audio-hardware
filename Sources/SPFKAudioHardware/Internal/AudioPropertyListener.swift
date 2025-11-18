// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

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

    deinit {
        Log.debug("- { \(self) }")
    }

    func start() throws {
        let status = cListener.start()
        guard status != PropertyListenerErrorCode.AlreadyListening.rawValue else { return }

        guard noErr == status else {
            throw NSError(description: "failed to start listening for (\(notificationType)) with error (\(status.fourCharCodeToString()))")
        }
    }

    func stop() throws {
        let status = cListener.stop()
        guard status != PropertyListenerErrorCode.AlreadyStopped.rawValue else { return }

        guard noErr == status else {
            throw NSError(description: "failed to stop listening for (\(notificationType)) with error (\(status.fourCharCodeToString()))")
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

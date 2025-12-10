// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

// MARK: listening via objc class

final class C_AudioObjectPropertyListener: NSObject, @unchecked Sendable {
    let objectID: AudioObjectID

    var eventHandler: ((any PropertyAddressNotification) -> Void)?
    var notificationType: any PropertyAddressNotification.Type

    var isListening: Bool { cListener.isListening }

    private lazy var cListener: PropertyListener = {
        var cListener: PropertyListener = .init(objectId: objectID)
        cListener.delegate = self
        return cListener
    }()

    init(
        notificationType: (some PropertyAddressNotification).Type,
        objectID: AudioObjectID,
        eventHandler: ((any PropertyAddressNotification) -> Void)?
    ) {
        self.notificationType = notificationType
        self.objectID = objectID
        self.eventHandler = eventHandler
    }

    deinit {
        cListener.delegate = nil
        Log.debug("- { \(self) (\(objectID)) }")
    }

    func start() throws {
        let status = cListener.start()

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "failed to start listening to \(objectID) for (\(notificationType)) with error (\(status.fourCC))")
        }
    }

    func stop() throws {
        let status = cListener.stop()

        guard kAudioHardwareNoError == status else {
            let msg = "failed to stop listening to \(objectID) for (\(notificationType)) with error (\(status.fourCC))"

            throw NSError(description: msg)
        }
    }
}

extension C_AudioObjectPropertyListener: SPFKAudioHardwareC.PropertyListenerDelegate {
    func propertyListener(_ propertyListener: PropertyListener, eventReceived propertyAddress: AudioObjectPropertyAddress) {
        callback(with: propertyAddress)
    }
}

extension C_AudioObjectPropertyListener {
    // callback from the proc
    func callback(with propertyAddress: AudioObjectPropertyAddress) {
        guard let notification = notificationType.init(
            objectID: objectID,
            propertyAddress: propertyAddress
        ) else {
            // ignore unhandled events
            return
        }

        send(notification: notification)
    }

    private func send(notification: any PropertyAddressNotification) {
        guard let eventHandler else { return }

        Task { @MainActor in
            eventHandler(notification)
        }
    }
}

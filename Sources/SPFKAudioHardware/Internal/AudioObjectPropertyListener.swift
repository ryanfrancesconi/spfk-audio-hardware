// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

final class AudioObjectPropertyListener {
    let objectID: AudioObjectID

    var eventHandler: ((any PropertyAddressNotification) -> Void)?
    var notificationType: any PropertyAddressNotification.Type

    public private(set) var isListening: Bool = false

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
        // Log.debug("- { \(self) }")
    }

    func start() throws {
        guard !isListening else {
            Log.error("Error: already listening")
            return
        }

        var address: AudioObjectPropertyAddress = .wildcard
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let status = AudioObjectAddPropertyListener(objectID, &address, _propertyListenerProc, selfPtr)

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "failed to start listening for (\(notificationType)) with error (\(status.fourCharCodeToString()))")
        }

        isListening = true
    }

    func stop() throws {
        guard isListening else {
            Log.error("Error: wasn't listening")
            return
        }

        var address: AudioObjectPropertyAddress = .wildcard
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let status = AudioObjectRemovePropertyListener(objectID, &address, _propertyListenerProc, selfPtr)

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "failed to stop listening for (\(notificationType)) with error (\(status.fourCharCodeToString()))")
        }

        isListening = false
    }
}

extension AudioObjectPropertyListener {
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
        Task { @MainActor in
            eventHandler?(notification)
        }
    }
}

/// @convention(c)
private func _propertyListenerProc(
    objectID: UInt32,
    numInAddresses: UInt32,
    inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    clientData: Optional<UnsafeMutableRawPointer>
) -> OSStatus {
    // passing self is required
    guard let clientData else {
        return kAudioHardwareBadObjectError
    }

    let _self = Unmanaged<AudioObjectPropertyListener>.fromOpaque(clientData).takeUnretainedValue()
    let address: AudioObjectPropertyAddress = inAddresses.pointee
    _self.callback(with: address)

    return kAudioHardwareNoError
}

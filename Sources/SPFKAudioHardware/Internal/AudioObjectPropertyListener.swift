// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

final class AudioObjectPropertyListener {
    let objectID: AudioObjectID

    var eventHandler: ((any PropertyAddressNotification) -> Void)?

    private func send(notification: any PropertyAddressNotification) {
        guard let eventHandler else { return }
        
        Task { @MainActor in eventHandler(notification) }
    }

    public private(set) var isListening: Bool = false

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
        guard !isListening else {
            Log.error("Error: already listening")
            return
        }

        let status = addListener()

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "failed to start listening for (\(notificationType)) with error (\(status.fourCC))")
        }

        isListening = true
    }

    func stop() throws {
        guard isListening else {
            Log.error("Error: wasn't listening")
            return
        }

        let status = removeListener()

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "failed to stop listening for (\(notificationType)) with error (\(status.fourCC))")
        }

        isListening = false
    }
}

extension AudioObjectPropertyListener {
    private var selfPtr: UnsafeMutableRawPointer { Unmanaged.passUnretained(self).toOpaque() }

    private func addListener() -> OSStatus {
        var address: AudioObjectPropertyAddress = .wildcard
        return AudioObjectAddPropertyListener(objectID, &address, _propertyListenerProc, selfPtr)
    }

    private func removeListener() -> OSStatus {
        var address: AudioObjectPropertyAddress = .wildcard
        return AudioObjectRemovePropertyListener(objectID, &address, _propertyListenerProc, selfPtr)
    }

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
}

/// @convention(c)
private func _propertyListenerProc(
    objectID: UInt32,
    numInAddresses: UInt32,
    inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    clientData: Optional<UnsafeMutableRawPointer>
) -> OSStatus {
    // passing self is required to call back to class
    guard let clientData else { return kAudioHardwareBadObjectError }

    let _self = Unmanaged<AudioObjectPropertyListener>.fromOpaque(clientData).takeUnretainedValue()
    let address: AudioObjectPropertyAddress = inAddresses.pointee
    _self.callback(with: address)

    return kAudioHardwareNoError
}

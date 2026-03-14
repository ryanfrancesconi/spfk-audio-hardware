// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

/// Closure type for handling property address change notifications.
typealias PropertyAddressNotificationEventHandler = (any PropertyAddressNotification) -> Void

/// Manages a Core Audio property listener for a specific `AudioObjectID`.
///
/// Registers a wildcard `AudioObjectPropertyListener` via `AudioObjectAddPropertyListener`,
/// which receives callbacks for all property changes on the target audio object. Incoming
/// `AudioObjectPropertyAddress` values are mapped to typed `PropertyAddressNotification`
/// instances (e.g., `AudioDeviceNotification`, `AudioStreamNotification`) using the
/// provided `notificationType`, and forwarded to the `eventHandler` closure.
///
/// Used by `AudioHardwareManager` to observe system-level hardware events and by
/// `AudioObjectPool` to observe per-device and per-stream property changes.
///
/// - Note: The C callback bridge uses `Unmanaged.passUnretained(self)` to pass a reference
///   through the `clientData` pointer. The caller is responsible for ensuring this listener
///   instance remains alive for the duration of listening.
final class AudioObjectPropertyListener {
    let objectID: AudioObjectID

    var eventHandler: PropertyAddressNotificationEventHandler?

    private func send(notification: any PropertyAddressNotification) {
        eventHandler?(notification)
    }

    private(set) var isListening: Bool = false

    var notificationType: any PropertyAddressNotification.Type

    /// Creates a new property listener for the given audio object.
    ///
    /// - Parameters:
    ///   - notificationType: The `PropertyAddressNotification` type used to map raw
    ///     `AudioObjectPropertyAddress` values into typed notifications.
    ///   - objectID: The Core Audio object to observe.
    ///   - eventHandler: A closure invoked with each typed notification when a property changes.
    init(
        notificationType: (some PropertyAddressNotification).Type,
        objectID: AudioObjectID,
        eventHandler: PropertyAddressNotificationEventHandler?
    ) {
        self.notificationType = notificationType
        self.objectID = objectID
        self.eventHandler = eventHandler
    }

    deinit {
        eventHandler = nil
        try? stop()
    }

    /// Registers the property listener with Core Audio.
    ///
    /// Calls `AudioObjectAddPropertyListener` with a wildcard address to receive
    /// all property change callbacks for the target object.
    ///
    /// - Throws: If `AudioObjectAddPropertyListener` returns an error status.
    func start() throws {
        guard !isListening else {
            return
        }

        let status = addListener()

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "failed to start listening for (\(notificationType)) with error (\(status.fourCC))")
        }

        isListening = true
    }

    /// Removes the property listener from Core Audio.
    ///
    /// Calls `AudioObjectRemovePropertyListener` to unregister the callback.
    ///
    /// - Throws: If `AudioObjectRemovePropertyListener` returns an error status.
    func stop() throws {
        guard isListening else {
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
    /// An unretained pointer to `self`, used as the `clientData` argument for Core Audio listener registration.
    private var selfPtr: UnsafeMutableRawPointer { Unmanaged.passUnretained(self).toOpaque() }

    /// Registers a wildcard property listener with Core Audio for `objectID`.
    private func addListener() -> OSStatus {
        var address: AudioObjectPropertyAddress = .wildcard
        return AudioBackend.current.addPropertyListener(objectID, address: &address, listener: _propertyListenerProc, clientData: selfPtr)
    }

    /// Removes the wildcard property listener from Core Audio for `objectID`.
    private func removeListener() -> OSStatus {
        var address: AudioObjectPropertyAddress = .wildcard
        return AudioBackend.current.removePropertyListener(objectID, address: &address, listener: _propertyListenerProc, clientData: selfPtr)
    }

    /// Called by the C callback proc for each changed property address.
    ///
    /// Attempts to initialize a typed notification from the raw `AudioObjectPropertyAddress`.
    /// If the address maps to a known notification case, the notification is forwarded
    /// to `eventHandler`. Unrecognized addresses are silently ignored.
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

/// The `@convention(c)` callback function passed to `AudioObjectAddPropertyListener`.
///
/// Core Audio invokes this function on its own thread whenever one or more properties
/// change on the observed audio object. The `clientData` pointer is recovered as an
/// unretained reference to `AudioObjectPropertyListener`, which then processes each
/// changed address through its `callback(with:)` method.
private func _propertyListenerProc(
    objectID _: UInt32,
    numInAddresses: UInt32,
    inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    clientData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let clientData else { return kAudioHardwareBadObjectError }

    let _self = Unmanaged<AudioObjectPropertyListener>.fromOpaque(clientData).takeUnretainedValue()

    for i in 0 ..< Int(numInAddresses) {
        let address = inAddresses[i]
        _self.callback(with: address)
    }

    return kAudioHardwareNoError
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKBase

public actor AudioHardwareManager {
    public static let shared = AudioHardwareManager()
    private init() {}

    let objectID: AudioObjectID = .init(kAudioObjectSystemObject)

    var notificationType: any PropertyAddressNotification.Type {
        AudioHardwareNotification.self
    }

    var cache = AudioDeviceCache()

    var listener: AudioObjectPropertyListener?
}

// MARK: - Lifecycle

extension AudioHardwareManager {
    var isListening: Bool { listener != nil }

    /// Start must be called to begin listening for hardware events
    public func start() async throws {
        guard !isListening else {
            Log.error("Error: already started")
            return
        }

        Log.debug("Starting listening...")

        listener = AudioObjectPropertyListener(
            notificationType: notificationType,
            objectID: objectID,
            eventHandler: { [weak self] notification in
                guard let self else { return }

                Task { @MainActor in
                    try await callback(with: notification)
                }
            }
        )

        try listener?.start()
        try await cache.start()
    }

    /// Stops listening for hardware property changes and clears the device cache listeners.
    ///
    /// After calling this, no further hardware notifications will be received until `start()` is called again.
    /// The cached device data remains available but will not be updated.
    public func stop() async throws {
        guard isListening else {
            Log.error("Error: not started")
            return
        }

        Log.debug("Stopping listening...")

        try await cache.stop()

        try listener?.stop()
        listener?.eventHandler = nil
        listener = nil
    }

    /// Stops listening and fully tears down the device cache, removing all pooled objects.
    ///
    /// Unlike `stop()`, this also unregisters all cached devices and streams from the
    /// `AudioObjectPool`. Call this during application shutdown or when the audio system
    /// is no longer needed.
    public func unregister() async throws {
        try await stop()
        try await cache.unregister()
        Log.debug("⛔️ (shared) - { \(self) }")
    }
}

// MARK: - Event Handler

extension AudioHardwareManager {
    @MainActor
    private func callback(with notification: any PropertyAddressNotification) async throws {
        guard let hardwareNotification = notification as? AudioHardwareNotification else {
            return
        }

        switch hardwareNotification {
        case .deviceListChanged:
            // fill in added and removed devices from the cache
            let event = try await cache.update()
            try Task.checkCancellation()

            guard event.removedDevices.isNotEmpty || event.addedDevices.isNotEmpty else {
                Log.error("No changes detected")
                return
            }

            let notification: AudioHardwareNotification =
                .deviceListChanged(objectID: objectID, event: event)

            post(notification: notification)

        default:
            try Task.checkCancellation()

            post(notification: hardwareNotification)
        }
    }

    @MainActor
    private func post(notification: AudioHardwareNotification) {
        NotificationCenter.default.post(
            name: notification.name,
            object: notification,
            userInfo: nil
        )
    }
}

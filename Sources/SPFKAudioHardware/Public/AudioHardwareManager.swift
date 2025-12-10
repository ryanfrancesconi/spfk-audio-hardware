// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKAudioHardwareC
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

    var updateTask: Task<Void, Error>?
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

                Task {
                    try await callback(with: notification)
                }
            }
        )

        try listener?.start()
        try await cache.start()
    }

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

    public func unregister() async throws {
        try await stop()
        try await cache.unregister()
        Log.debug("⛔️ (shared) - { \(self) }")
    }
}

// MARK: - Event Handler

extension AudioHardwareManager {
    private func callback(with notification: any PropertyAddressNotification) async throws {
        guard let hardwareNotification = notification as? AudioHardwareNotification else {
            return
        }

        updateTask?.cancel()

        let task = Task<Void, Error> {
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

                await Self.post(notification: notification)

            default:
                try Task.checkCancellation()

                await Self.post(notification: hardwareNotification)
            }
        }

        updateTask = task

        let result = await task.result

        switch result {
        case .success:
            break
            
        case let .failure(error):
            Log.error(error)
        }
    }

    @MainActor private static func post(notification: AudioHardwareNotification) {
        NotificationCenter.default.post(
            name: notification.name,
            object: notification,
            userInfo: nil
        )
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKAudioHardwareC
import SPFKBase

final class AudioHardwareObserver: NSObject {
    public var notificationType: any PropertyAddressNotification.Type { AudioHardwareNotification.self }

    var eventHandler: ((AudioHardwareNotification) -> Void)?

    let objectID: AudioObjectID = AudioObjectID(kAudioObjectSystemObject)

    var listener: AudioObjectPropertyListener?

    public var isListening: Bool { listener != nil }

    var cache = AudioDeviceCache()
    var updateTask: Task<Void, Error>?

    init(eventHandler: ((AudioHardwareNotification) -> Void)? = nil) {
        super.init()
        self.eventHandler = eventHandler
    }

    func start() async throws {
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
                    self.callback(with: notification)
                }
            }
        )

        try listener?.start()
        try await cache.start()
    }

    func stop() async throws {
        guard isListening else {
            Log.error("Error: not started")
            return
        }

        Log.debug("Stopping listening...")

        try await cache.stop()

        try listener?.stop()
        listener?.eventHandler = nil
        self.listener = nil
    }
}

// MARK: - objc interop

extension AudioHardwareObserver {
    func callback(with notification: any PropertyAddressNotification) {
        guard let hardwareNotification = notification as? AudioHardwareNotification else {
            return
        }

        switch hardwareNotification {
        case .deviceListChanged:
            updateTask?.cancel()
            updateTask = Task<Void, Error> {
                // fill in added and removed devices from the cache
                let event = try await cache.update()
                let notification: AudioHardwareNotification = .deviceListChanged(objectID: objectID, event: event)
                send(notification: notification)
            }
        default:
            send(notification: hardwareNotification)
        }
    }

    private func send(notification: AudioHardwareNotification) {
        Task { @MainActor in
            eventHandler?(notification)
        }
    }
}

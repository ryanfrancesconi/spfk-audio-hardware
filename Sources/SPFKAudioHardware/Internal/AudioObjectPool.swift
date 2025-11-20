// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

/// Singleton AudioObjectPool which stores devices and streams. Everything is internal except
/// for the lookup()
public actor AudioObjectPool {
    public static let shared = AudioObjectPool()

    private var pool = [AudioObjectID: any AudioPropertyListenerModel]()
    private var listeners = [AudioObjectID: AudioObjectPropertyListener]()

    public static var postNotifications: Bool = true

    private init() {}

    func get<O: AudioPropertyListenerModel>(_ id: AudioObjectID) -> O? {
        pool[id] as? O
    }

    func insert<O: AudioPropertyListenerModel>(_ audioObject: O, for id: AudioObjectID) throws {
        pool[id] = audioObject
    }

    func remove(_ id: AudioObjectID) throws {
        pool.removeValue(forKey: id)

        try listeners[id]?.stop()

        listeners.removeValue(forKey: id)
    }

    func removeAll() throws {
        stopListening()

        guard pool.isNotEmpty else {
            Log.debug("No objects in pool")
            return
        }

        pool.removeAll()
    }
}

extension AudioObjectPool {
    func startListening() async {
        guard pool.isNotEmpty else {
            Log.error("No objects in pool")
            return
        }

        Log.debug("adding listeners for", pool.count, "devices")

        for item in pool {
            let id = item.key

            guard listeners[id] == nil else {
                // Log.error("Already have listener for", id)
                continue
            }

            let audioObject = item.value

            let listener = AudioObjectPropertyListener(
                notificationType: audioObject.notificationType,
                objectID: id,
                eventHandler: { [weak self] notification in
                    guard let self else { return }

                    Task { @MainActor in
                        await self.received(id: id, notification: notification)
                    }
                }
            )

            do {
                try listener.start()
                listeners[id] = listener

            } catch let error as NSError {
                Log.error(error)
            }
        }
    }

    func stopListening() {
        Log.debug("removing listeners for", pool.count, "devices")

        for listener in listeners {
            do {
                try listener.value.stop()
                listener.value.eventHandler = nil

            } catch let error as NSError {
                Log.error(error)
            }
        }

        listeners.removeAll()
    }
}

extension AudioObjectPool {
    private func received(id: AudioObjectID, notification: any PropertyAddressNotification) {
        Log.debug("🔊 \(id)", notification)

        guard Self.postNotifications else { return }

        NotificationCenter.default.post(
            name: notification.name,
            object: notification
        )
    }
}

extension AudioObjectPool {
    /// Returns an `AudioPropertyListenerModel` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    /// - Note: If identifier is not valid, `nil` will be returned.
    public func lookup<O: AudioPropertyListenerModel>(id: AudioObjectID) async -> O? {
        if let device: O = get(id) {
            return device
        }

        do {
            let device = try await O(objectID: id)
            try insert(device, for: id)
            return device

        } catch {
            Log.error(error)
        }

        return nil
    }
}

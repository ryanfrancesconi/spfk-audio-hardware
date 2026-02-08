// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

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

    private init() {}

    func get<O: AudioPropertyListenerModel>(_ id: AudioObjectID) -> O? {
        pool[id] as? O
    }

    func insert(_ audioObject: some AudioPropertyListenerModel, for id: AudioObjectID) {
        guard pool[id]?.objectID != audioObject.objectID else {
            return // already in the pool
        }

        pool[id] = audioObject

        Log.debug("✅ \(audioObject)")
    }

    func remove(_ id: AudioObjectID) {
        do {
            try listeners[id]?.stop()
        } catch {
            Log.error(error)
        }

        let removedListener = listeners.removeValue(forKey: id)
        let removedPoolItem = pool.removeValue(forKey: id)

        _ = removedListener; _ = removedPoolItem

//        Log.debug("⛔️ listener objectID", removedListener?.objectID, "pool item", removedPoolItem)
//        Log.debug("ℹ updated \(pool.count) pool, \(listeners.count) listeners")
    }

    func removeAll() {
        stopListening()

        guard pool.isNotEmpty else {
            // Log.debug("No objects in pool")
            return
        }

        pool.removeAll()
    }
}

extension AudioObjectPool {
    func startListening() {
        guard pool.isNotEmpty else {
            Log.error("No objects in pool")
            return
        }

        for item in pool {
            startListening(to: item.value)
        }
    }

    func startListening(to audioObject: any AudioPropertyListenerModel) {
        let id = audioObject.objectID

        guard listeners[id] == nil else {
            // Log.error("Already have listener for", id)
            return
        }

        let listener = AudioObjectPropertyListener(
            notificationType: audioObject.notificationType,
            objectID: id,
            eventHandler: { [weak self] notification in
                guard let self else { return }

                Task { await received(id: id, notification: notification) }
            }
        )

        do {
            try listener.start()
            listeners[id] = listener
            Log.debug("Added listener for \(audioObject)")

        } catch let error as NSError {
            Log.error("Error adding listener for \(audioObject)", error)
        }
    }

    func stopListening() {
        guard listeners.isNotEmpty else { return }

        Log.debug("removing \(listeners.count) listeners for", pool.count, "devices")

        for listener in listeners {
            do {
                try listener.value.stop()
            } catch let error as NSError {
                Log.error(error)
            }

            listener.value.eventHandler = nil
        }

        listeners.removeAll()
    }
}

extension AudioObjectPool {
    @MainActor private func received(id: AudioObjectID, notification: any PropertyAddressNotification) {
        // Log.debug("🔊 \(id)", notification)

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
    public func lookup<O: AudioPropertyListenerModel>(id: AudioObjectID) async throws -> O {
        if let device: O = get(id) {
            return device
        }

        let device = try await O(objectID: id)
        insert(device, for: id)

        return device
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

actor AudioObjectPool {
    /// Singleton AudioObjectPool
    internal static let shared = AudioObjectPool()

    private var pool = [AudioObjectID: any AudioPropertyListenerModel]()

    private var listeners = [AudioObjectID: AudioPropertyListener]()

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
        pool.removeAll()

        stopListening()
    }

    func startListening() async {
        for item in pool {
            let id = item.key

            guard listeners[id] == nil else {
                // Log.error("Already have listener for", id)
                continue
            }

            let audioObject = item.value

            let listener = AudioPropertyListener(
                notificationType: audioObject.notificationType,
                objectID: id,
                eventHandler: { [weak self] notification in
                    guard let self else { return }

//                    NotificationCenter.default.post(
//                        name: notification.name,
//                        object: self, // This device
//                        userInfo: [
//                            notification.name: notification,
//                            "id": id,
//                        ]
//                    )

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
        for listener in listeners {
            do {
                try listener.value.stop()
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
            object: self, // This device
            userInfo: [
                notification.name: notification,
                "id": id,
            ]
        )
    }
}

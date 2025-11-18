// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

actor AudioObjectPool {
    /// Singleton AudioObjectPool
    internal static let shared = AudioObjectPool()

    private var pool = [AudioObjectID: any AudioObjectModel]()
    private init() {}

    func get<O: AudioObjectModel>(_ id: AudioObjectID) -> O? {
        pool[id] as? O
    }

    func set<O: AudioObjectModel>(_ audioObject: O, for id: AudioObjectID) {
        pool[id] = audioObject
    }

    func remove(_ id: AudioObjectID) {
        pool.removeValue(forKey: id)
    }
}

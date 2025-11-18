// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import SPFKBase

protocol AudioPropertyListenerModel: AudioObjectModel {
    var listener: AudioPropertyListener? { get }
}

extension AudioPropertyListenerModel {
    public func startListening() async {
        do {
            await AudioObjectPool.shared.set(self, for: objectID)
            try listener?.start()
        } catch {
            Log.error(error)
        }
    }

    public func stopListening() async {
        do {
            try listener?.stop()
            await AudioObjectPool.shared.remove(objectID)
            
        } catch {
            Log.error(error)
        }
    }
}

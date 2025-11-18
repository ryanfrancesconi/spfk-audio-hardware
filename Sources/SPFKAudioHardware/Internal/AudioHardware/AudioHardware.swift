// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

final class AudioHardware {
    var cache: AudioDeviceCache { listener.cache }

    var listener = AudioHardwareListener { notification in
        NotificationCenter.default.post(
            name: notification.name,
            object: notification,
            userInfo: nil
        )
    }
}

// MARK: - Internal Functions

extension AudioHardware {
    func startListening() async {
        Log.debug("start")

        do {
            try await listener.start()
        } catch {
            Log.error(error)
        }
    }

    func stopListening() async {
        Log.debug("stop")

        do {
            try await listener.stop()
        } catch {
            Log.error(error)
        }
    }
}

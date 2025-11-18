// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

final class AudioHardware {
    var cache: AudioDeviceCache { listener.cache }

    var eventHandler: ((AudioHardwareNotification) -> Void)?

    lazy var listener = AudioHardwareListener { [weak self] in
        self?.eventHandler?($0)
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

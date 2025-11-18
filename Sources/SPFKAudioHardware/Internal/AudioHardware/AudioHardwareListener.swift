// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKAudioHardwareC
import SPFKBase

class AudioHardwareListener: NSObject {
    var eventHandler: ((AudioHardwareNotification) -> Void)?

    let objectID: AudioObjectID = AudioObjectID(kAudioObjectSystemObject)

    private(set) lazy var cListener: PropertyListener = {
        Log.debug("Creating PropertyListener")

        let cListener = PropertyListener(objectId: objectID)
        cListener.delegate = self
        return cListener
    }()

    var cache = AudioDeviceCache()
    var updateTask: Task<Void, Error>?

    init(eventHandler: ((AudioHardwareNotification) -> Void)?) {
        super.init()
        self.eventHandler = eventHandler
    }

    deinit {
        cListener.delegate = nil
    }

    func start() async throws {
        // will lazy create here when referenced
        let status = cListener.start()

        guard noErr == status else {
            throw NSError(description: "failed to start hardware monitoring with error \(status)")
        }

        try await cache.start()
    }

    func stop() async throws {
        try await cache.stop()

        let status = cListener.stop()

        guard noErr == status else {
            throw NSError(description: "failed to stop hardware monitoring with error \(status)")
        }
    }
}

// MARK: - objc interop

extension AudioHardwareListener: SPFKAudioHardwareC.PropertyListenerDelegate {
    func propertyListener(
        _ propertyListener: PropertyListener,
        eventReceived propertyAddress: AudioObjectPropertyAddress
    ) {
        switch propertyAddress.mSelector {
        case kAudioObjectPropertyOwnedObjects:
            updateTask?.cancel()
            updateTask = Task<Void, Error> {
                // Obtain added and removed devices.
                let event = try await cache.update()
                let notification: AudioHardwareNotification = .deviceListChanged(event: event)
                send(notification: notification)
            }

        case kAudioHardwarePropertyDefaultInputDevice:
            send(notification: .defaultInputDeviceChanged)

        case kAudioHardwarePropertyDefaultOutputDevice:
            send(notification: .defaultOutputDeviceChanged)

        case kAudioHardwarePropertyDefaultSystemOutputDevice:
            send(notification: .defaultSystemOutputDeviceChanged)

        default:
            break
        }
    }

    private func send(notification: AudioHardwareNotification) {
        Task { @MainActor in
            eventHandler?(notification)
        }
    }
}

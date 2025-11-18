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

        await cache.start()
    }

    func stop() async throws {
        await cache.stop()

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
        Task {
            switch propertyAddress.mSelector {
            case kAudioObjectPropertyOwnedObjects:

                // Obtain added and removed devices.
                let event = await cache.update()

                let notification: AudioHardwareNotification = .deviceListChanged(event: event)

                await send(notification: notification)

            case kAudioHardwarePropertyDefaultInputDevice:
                await send(notification: .defaultInputDeviceChanged)

            case kAudioHardwarePropertyDefaultOutputDevice:
                await send(notification: .defaultOutputDeviceChanged)

            case kAudioHardwarePropertyDefaultSystemOutputDevice:
                await send(notification: .defaultSystemOutputDeviceChanged)

            default:
                break
            }
        }
    }

    @MainActor private func send(notification: AudioHardwareNotification) {
        eventHandler?(notification)
    }
}

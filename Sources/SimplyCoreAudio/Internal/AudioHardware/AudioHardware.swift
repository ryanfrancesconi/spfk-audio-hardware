// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import CoreAudio
import Foundation
import os.log
import SimplyCoreAudioC

final class AudioHardware: NSObject {
    // MARK: - Fileprivate Properties

    var cachedDevices = [AudioDevice]()

    // TODO: remove queue
    fileprivate lazy var queueLabel = (Bundle.main.bundleIdentifier ?? "SimplyCoreAudio").appending(".audioHardware")
    lazy var queue = DispatchQueue(label: queueLabel, qos: .default, attributes: .concurrent)

    // MARK: - Private Properties

    private lazy var cListener: PropertyListener = {
        let cListener = PropertyListener(objectId: AudioObjectID(kAudioObjectSystemObject))
        cListener.delegate = self
        return cListener
    }()

    deinit {
        cListener.delegate = nil
    }
}

// MARK: - Internal Functions

extension AudioHardware {
    public var isRegisteredForNotifications: Bool {
        cListener.isListening == true
    }

    func enableDeviceMonitoring() {
        registerForNotifications()
        updateKnownDevices(adding: allDevices, andRemoving: [])
    }

    func disableDeviceMonitoring() {
        updateKnownDevices(adding: [], andRemoving: cachedDevices)
        unregisterForNotifications()
    }

    func updateKnownDevices(adding addedDevices: [AudioDevice], andRemoving removedDevices: [AudioDevice]) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cachedDevices.append(contentsOf: addedDevices)
            self?.cachedDevices.removeAll { removedDevices.contains($0) }
        }
    }
}

private extension AudioHardware {
    // MARK: - Notification Book-keeping

    func registerForNotifications() {
        let status = cListener.start()

        guard noErr == status else {
            print("failed to start listener with error", status)
            return
        }
    }

    func unregisterForNotifications() {
        let status = cListener.stop()

        guard noErr == status else {
            print("failed to stop listener with error", status)
            return
        }
    }
}

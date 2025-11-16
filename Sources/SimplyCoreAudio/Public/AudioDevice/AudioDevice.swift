//
//  AudioDevice.swift
//
//  Created by Ruben Nine on 7/7/15.
//

import CoreAudio
import Foundation
import os.log
import SimplyCoreAudioC

/// This class represents an audio device managed by [Core Audio](https://developer.apple.com/documentation/coreaudio).
///
/// Devices may be physical or virtual. For a comprehensive list of supported types, please refer to `TransportType`.
public final class AudioDevice: AudioObject {
    // MARK: - Static Private Properties

    private static let deviceClassIDs: Set<AudioClassID> = [
        kAudioDeviceClassID,
        kAudioSubDeviceClassID,
        kAudioAggregateDeviceClassID,
        kAudioEndPointClassID,
        kAudioEndPointDeviceClassID,
    ]

    // MARK: - Private Properties

    private var cachedDeviceName: String?

    private var isRegisteredForNotifications: Bool { cListener.isListening }

    private lazy var cListener: PropertyListener = {
        let cListener = PropertyListener(objectId: objectID)
        cListener.delegate = listener
        return cListener
    }()

    /// event broker to avoid AudioDevice needing to subclass NSObject
    private lazy var listener: AudioDeviceListener = {
        var listener = AudioDeviceListener { [weak self] audioDeviceNotification in
            guard let self else { return }

            Task { @MainActor in
                // userInfo convention:
                // [deviceVolumeDidChange: deviceVolumeDidChange(channel: AudioObjectPropertyElement, scope: Scope)]

                NotificationCenter.default.post(
                    name: audioDeviceNotification.name,
                    object: self, // This device
                    userInfo: [audioDeviceNotification.name: audioDeviceNotification]
                )
            }
        }

        return listener
    }()

    // MARK: - Lifecycle Functions

    /// Initializes an `AudioDevice` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    init?(id: AudioObjectID) {
        super.init(objectID: id)

        guard let classID, Self.deviceClassIDs.contains(classID) else { return nil }

        AudioObjectPool.shared.set(self, for: objectID)
        registerForNotifications()

        cachedDeviceName = super.name
    }

    deinit {
        unregisterForNotifications()
        AudioObjectPool.shared.remove(objectID)
    }

    // MARK: - AudioObject Overrides

    /// The audio device's name as reported by Core Audio.
    ///
    /// - Returns: An audio device's name.
    override public var name: String { super.name ?? cachedDeviceName ?? "<Unknown Device Name>" }
}

extension AudioDevice {
    // MARK: - Notification Book-keeping

    func registerForNotifications() {
        print("registerForNotifications", name)
        let status = cListener.start()

        guard noErr == status else {
            print("failed to start listener with error", status)
            return
        }
    }

    func unregisterForNotifications() {
        print("unregisterForNotifications", name)
        let status = cListener.stop()

        guard noErr == status else {
            print("failed to stop listener with error", status)
            return
        }
    }
}

extension AudioDevice: CustomStringConvertible {
    /// Returns a `String` representation of self.
    public var description: String {
        return "\(name) (\(id))"
    }
}

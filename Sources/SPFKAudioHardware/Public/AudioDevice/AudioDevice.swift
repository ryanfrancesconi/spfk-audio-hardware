// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

/// This class represents an audio device managed by [Core Audio](https://developer.apple.com/documentation/coreaudio).
///
/// Devices may be physical or virtual. For a comprehensive list of supported types, please refer to `TransportType`.
public final class AudioDevice: AudioObject, AudioPropertyListenerModel {
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

    /// event broker to avoid AudioDevice needing to subclass NSObject
    private(set) lazy var listener: AudioPropertyListener? = {
        var listener = AudioPropertyListener(
            notificationType: AudioDeviceNotification.self,
            objectID: objectID
        ) { [weak self] notification in
            guard let self else { return }

            // userInfo convention:
            // [deviceVolumeDidChange: deviceVolumeDidChange(channel: AudioObjectPropertyElement, scope: Scope)]

            NotificationCenter.default.post(
                name: notification.name,
                object: self, // This device
                userInfo: [notification.name: notification]
            )
        }

        return listener
    }()

    // MARK: - Lifecycle Functions

    /// Initializes an `AudioDevice` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    init(id: AudioObjectID) async throws {
        super.init(objectID: id)

        guard let classID else {
            throw NSError(description: "classID is nil")
        }

        guard Self.deviceClassIDs.contains(classID) else {
            throw NSError(description: "Unknown classID (\(classID))")
        }

        // AudioObjectPool.shared.set(self, for: objectID)
        cachedDeviceName = super.name

        await startListening()
    }

    deinit {
        // AudioObjectPool.shared.remove(objectID)
    }

    // MARK: - AudioObject Overrides

    /// The audio device's name as reported by Core Audio.
    ///
    /// - Returns: An audio device's name.
    override public var name: String { super.name ?? cachedDeviceName ?? "<Unknown Device Name>" }
}

extension AudioDevice: CustomStringConvertible {
    /// Returns a `String` representation of self.
    public var description: String {
        return "\(name) (\(id))"
    }
}

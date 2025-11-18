// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

/// This class represents an audio device managed by [Core Audio](https://developer.apple.com/documentation/coreaudio).
///
/// Devices may be physical or virtual. For a comprehensive list of supported types, please refer to `TransportType`.
public final class AudioDevice: AudioPropertyListenerModel {
    var notificationType: any PropertyAddressNotification.Type { AudioDeviceNotification.self }

    // MARK: - Static Private Properties

    public static let supportedClassIDs: Set<AudioClassID> = [
        kAudioDeviceClassID,
        kAudioSubDeviceClassID,
        kAudioAggregateDeviceClassID,
        kAudioEndPointClassID,
        kAudioEndPointDeviceClassID,
    ]

    private var _deviceName: String?

    public static func isSupported(classID: AudioClassID) -> Bool {
        Self.supportedClassIDs.contains(classID)
    }

    // MARK: - Requirements

    public var objectID: AudioObjectID

    /// Initializes an `AudioDevice` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    public init(objectID: AudioObjectID) async throws {
        self.objectID = objectID

        guard let classID else {
            throw NSError(description: "classID is nil")
        }

        guard Self.supportedClassIDs.contains(classID) else {
            throw NSError(description: "Unknown classID (\(classID.fourCharCodeToString() ?? "\(classID)"))")
        }

        _deviceName = self.name
    }

    // MARK: - AudioObject Overrides

    /// The audio device's name as reported by Core Audio.
    ///
    /// - Returns: An audio device's name.
    public var name: String { objectName ?? _deviceName ?? "<Unknown Device Name>" }
}

extension AudioDevice: CustomStringConvertible {
    /// Returns a `String` representation of self.
    public var description: String {
        return "\(name) (\(id))"
    }
}

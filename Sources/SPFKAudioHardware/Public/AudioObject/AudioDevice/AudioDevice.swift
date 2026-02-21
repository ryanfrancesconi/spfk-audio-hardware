// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

/// This class represents an audio device managed by [Core Audio](https://developer.apple.com/documentation/coreaudio).
///
/// Devices may be physical or virtual. For a comprehensive list of supported types, please refer to `TransportType`.
public final class AudioDevice: AudioPropertyListenerModel, Sendable {
    public var notificationType: any PropertyAddressNotification.Type { AudioDeviceNotification.self }

    // MARK: - Static Private Properties

    public static let supportedClassIDs: Set<AudioClassID> = [
        kAudioDeviceClassID,
        kAudioSubDeviceClassID,
        kAudioAggregateDeviceClassID,
        kAudioEndPointClassID,
        kAudioEndPointDeviceClassID,
    ]

    private nonisolated(unsafe) var _deviceName: String = ""

    public static func isSupported(classID: AudioClassID) -> Bool {
        supportedClassIDs.contains(classID)
    }

    // MARK: - Requirements

    public let sampleRateUpdater = SampleRateState()

    public let objectID: AudioObjectID

    /// Initializes an `AudioDevice` by providing a valid audio device identifier.
    ///
    /// - Parameter id: An audio device identifier.
    public init(objectID: AudioObjectID) async throws {
        self.objectID = objectID

        await sampleRateUpdater.update(objectID: objectID)

        guard let classID else {
            throw NSError(description: "classID is nil")
        }

        guard Self.supportedClassIDs.contains(classID) else {
            throw NSError(description: "Unknown classID (\(classID.fourCC))")
        }

        _deviceName = objectName ?? "<Unknown Device Name>"
    }

    // MARK: - AudioObject Overrides

    /// The audio device's name as reported by Core Audio.
    ///
    /// - Returns: An audio device's name.
    public var name: String { _deviceName }

    public var nameAndID: String { "\(_deviceName) (\(objectID))" }
}

extension AudioDevice: CustomStringConvertible {
    /// Returns a `String` representation of self.
    public var description: String {
        "\(name) (\(id)) (\(uid ?? "uid is nil"))"
    }
}

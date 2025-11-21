// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

/// This class represents an audio stream that belongs to an audio object managed by
/// [Core Audio](https://developer.apple.com/documentation/coreaudio).
public final class AudioStream: AudioPropertyListenerModel, Sendable {
    public var notificationType: any PropertyAddressNotification.Type { AudioStreamNotification.self }

    // MARK: - Requirements

    public let objectID: AudioObjectID

    /// Initializes an `AudioStream` by providing a valid `AudioObjectID` referencing an existing audio stream.
    public init(objectID: AudioObjectID) async throws {
        self.objectID = objectID

        guard isAudioStream else {
            return
        }

        guard (try? await owningObject()) != nil else {
            throw NSError(description: "owningObject can't be nil")
        }
    }
}

// MARK: - Public Functions

public extension AudioStream {
    /// All the available physical formats for this audio stream matching the current physical format's sample rate.
    ///
    /// - Note: By default, both mixable and non-mixable streams are returned, however,  non-mixable
    /// streams can be filtered out by setting `includeNonMixable` to `false`.
    ///
    /// - Parameter includeNonMixable: Whether to include non-mixable streams in the returned array. Defaults to `true`.
    ///
    /// - SeeAlso: `availableVirtualFormatsMatchingCurrentNominalSampleRate(_:)`
    ///
    /// - Returns: *(optional)* An array of `AudioStreamBasicDescription` structs.
    func availablePhysicalFormatsMatchingCurrentNominalSampleRate(_ includeNonMixable: Bool = true) -> [AudioStreamBasicDescription]? {
        guard let physicalFormats = availablePhysicalFormats, let physicalFormat else { return nil }

        var filteredFormats = physicalFormats.filter { format -> Bool in
            format.mSampleRateRange.mMinimum >= physicalFormat.mSampleRate &&
                format.mSampleRateRange.mMaximum <= physicalFormat.mSampleRate
        }.map { $0.mFormat }

        if !includeNonMixable {
            filteredFormats = filteredFormats.filter { $0.mFormatFlags & kAudioFormatFlagIsNonMixable == 0 }
        }

        return filteredFormats
    }

    /// All the available virtual formats for this audio stream matching the current virtual format's sample rate.
    ///
    /// - Note: By default, both mixable and non-mixable streams are returned, however,  non-mixable
    /// streams can be filtered out by setting `includeNonMixable` to `false`.
    ///
    /// - Parameter includeNonMixable: Whether to include non-mixable streams in the returned array. Defaults to `true`.
    ///
    /// - SeeAlso: `availablePhysicalFormatsMatchingCurrentNominalSampleRate(_:)`
    ///
    /// - Returns: *(optional)* An array of `AudioStreamBasicDescription` structs.
    func availableVirtualFormatsMatchingCurrentNominalSampleRate(_ includeNonMixable: Bool = true) -> [AudioStreamBasicDescription]? {
        guard let virtualFormats = availableVirtualFormats, let virtualFormat else { return nil }

        var filteredFormats = virtualFormats.filter { format -> Bool in
            format.mSampleRateRange.mMinimum >= virtualFormat.mSampleRate &&
                format.mSampleRateRange.mMaximum <= virtualFormat.mSampleRate
        }.map { $0.mFormat }

        if !includeNonMixable {
            filteredFormats = filteredFormats.filter { $0.mFormatFlags & kAudioFormatFlagIsNonMixable == 0 }
        }

        return filteredFormats
    }
}

extension AudioStream: CustomStringConvertible {
    /// Returns a `String` representation of self.
    public var description: String {
        return "\(objectName ?? "Stream \(objectID)") (\(objectID))"
    }
}

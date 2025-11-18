// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

/// This class represents a [Core Audio](https://developer.apple.com/documentation/coreaudio) managed audio object.
/// In [Core Audio](https://developer.apple.com/documentation/coreaudio), audio objects are referenced by its
/// `AudioObjectID` and belong to a specific `AudioClassID`.
///
/// For more information, please refer to [Core Audio](https://developer.apple.com/documentation/coreaudio)'s
/// documentation or source code.
public class AudioObject: AudioObjectModel {
    // MARK: - Internal Properties

    public let objectID: AudioObjectID

    // MARK: - Public Properties

    /// The `AudioClassID` that identifies the class of this audio object.
    ///
    /// - Returns: *(optional)* An `AudioClassID`.
    public lazy var classID: AudioClassID? = {
        guard let address = validAddress(selector: kAudioObjectPropertyClass) else { return nil }

        var klassID = AudioClassID()

        guard noErr == getPropertyData(address, andValue: &klassID) else { return nil }

        return klassID
    }()

    /// The audio object that owns this audio object.
    ///
    /// - Returns: *(optional)* An `AudioObject`.
    public lazy var owningObject: AudioObject? = {
        guard let address = validAddress(selector: kAudioObjectPropertyOwner) else { return nil }

        var objectID = AudioObjectID()

        guard noErr == getPropertyData(address, andValue: &objectID) else { return nil }

        return AudioObject(objectID: objectID)
    }()

    /// The audio device that owns this audio object.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var owningDevice: AudioDevice? {
        get async {
            guard let object = owningObject, object.classID == kAudioDeviceClassID else { return nil }

            return await AudioDevice.lookup(by: object.objectID)
        }
    }

    /// The audio object's name as reported by Core Audio.
    ///
    /// - Returns: *(optional)* An audio object's name.
    public var name: String? {
        var name: CFString = "" as CFString

        guard let address = validAddress(selector: kAudioObjectPropertyName) else { return nil }
        guard noErr == getPropertyData(address, andValue: &name) else { return nil }

        return name as String
    }

    // MARK: - Init

    init(objectID: AudioObjectID) {
        self.objectID = objectID
    }
}

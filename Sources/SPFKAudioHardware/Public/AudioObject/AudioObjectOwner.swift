import CoreAudio
import Foundation

/// Represents the owning audio object in Core Audio's object hierarchy.
///
/// In Core Audio, every audio object (device, stream, etc.) has an owner. This class
/// wraps the owner's `AudioObjectID` so it can be inspected to determine its class
/// (e.g., whether the owner is itself an `AudioDevice`).
public final class AudioObjectOwner: AudioObjectModel {
    public let objectID: AudioObjectID

    public init(objectID: AudioObjectID) async throws {
        self.objectID = objectID
    }
}

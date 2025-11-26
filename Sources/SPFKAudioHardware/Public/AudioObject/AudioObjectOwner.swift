import CoreAudio
import Foundation

public final class AudioObjectOwner: AudioObjectModel {
    public let objectID: AudioObjectID

    public init(objectID: AudioObjectID) async throws {
        self.objectID = objectID
    }
}

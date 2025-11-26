import CoreAudio.AudioHardware
import Foundation

/// Input and output devices that have matching `modelUID` values such
/// as for bluetooth headphones that have an integrated mic.
public struct SplitAudioDevice: Sendable {
    public let input: AudioDevice
    public let output: AudioDevice
    public let name: String
    public let modelUID: String

    public init(input: AudioDevice, output: AudioDevice) throws {
        guard let modelUID = output.modelUID else {
            throw NSError(description: "the modelUID can't be nil")
        }

        guard input.modelUID == modelUID else {
            throw NSError(description: "the modelUID must match for both devices but they are input.modelUID \(input.modelUID ?? "nil") and output.modelUID \(output.modelUID ?? "nil")")
        }

        guard input.uid != output.uid else {
            throw NSError(description: "The input and output are the same device.")
        }

        self.input = input
        self.output = output

        name = output.objectName ?? input.objectName ?? "<Unknown Split Device Name>"
        self.modelUID = modelUID
    }

    public func contains(device: AudioDevice) -> Bool {
        input == device || output == device
    }

    public func contains(uid: String) -> Bool {
        input.uid == uid || output.uid == uid
    }

    public func device(scope: Scope) -> AudioDevice {
        switch scope {
        case .input: input
        case .output: output
        default:
            output
        }
    }

    public func objectID(scope: Scope) -> AudioObjectID {
        switch scope {
        case .input: input.objectID
        case .output: output.objectID
        default:
            AudioObjectID(kAudioHardwareBadObjectError)
        }
    }

    public func getNominalSampleRates(scope: Scope) -> [Float64]? {
        switch scope {
        case .input: input.getNominalSampleRates(scope: .input)
        case .output: output.getNominalSampleRates(scope: .output)
        default:
            nil
        }
    }
}

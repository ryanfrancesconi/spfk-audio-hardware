// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
@testable import SPFKAudioHardware

/// Factory for creating `AudioDevice` instances backed by `MockAudioBackend`.
///
/// Pre-registers the minimum required properties (`kAudioObjectPropertyClass`
/// and `kAudioObjectPropertyName`) needed by `AudioDevice.init(objectID:)`,
/// installs the mock backend, and returns both the device and mock for test use.
enum MockDeviceFactory {
    /// Creates a mock-backed `AudioDevice` with the given properties.
    ///
    /// - Parameters:
    ///   - objectID: The fake audio object ID to use. Defaults to 42.
    ///   - name: The device name. Defaults to "Mock Device".
    ///   - classID: The audio class ID. Defaults to `kAudioDeviceClassID`.
    ///   - additionalSetup: An optional closure to register additional properties
    ///     on the mock before the device is created.
    /// - Returns: A tuple of the created `AudioDevice` and its `MockAudioBackend`.
    static func makeDevice(
        objectID: AudioObjectID = 42,
        name: String = "Mock Device",
        classID: AudioClassID = kAudioDeviceClassID,
        additionalSetup: (MockAudioBackend, AudioObjectID) -> Void = { _, _ in }
    ) async throws -> (device: AudioDevice, mock: MockAudioBackend) {
        let mock = MockAudioBackend()

        // Register minimum required properties for AudioDevice.init
        mock.register(objectID: objectID,
                      selector: kAudioObjectPropertyClass,
                      value: classID)

        mock.registerString(objectID: objectID,
                            selector: kAudioObjectPropertyName,
                            value: name)

        // Let caller register additional properties
        additionalSetup(mock, objectID)

        // Install mock backend
        AudioBackendAccessor._setBackendForTesting(mock)

        // Create device — init calls classID, objectName, sampleRateUpdater.update
        let device = try await AudioDevice(objectID: objectID)

        return (device, mock)
    }
}

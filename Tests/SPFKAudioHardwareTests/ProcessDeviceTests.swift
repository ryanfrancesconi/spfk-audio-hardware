// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import Testing

@testable import SPFKAudioHardware

/// `AudioDevice.devices(usedByProcess:scope:)` against `MockAudioBackend`, which ignores the PID
/// qualifier, so these cover the chain after the translation rather than the translation itself.
@Suite(.serialized)
final class ProcessDeviceTests {
    private let processID: AudioObjectID = 7001
    private let deviceID: AudioObjectID = 7002

    deinit {
        AudioBackend._reset()
    }

    private func install(processObject: AudioObjectID, outputDevices: [AudioObjectID]) {
        let mock = MockAudioBackend()
        mock.registerArray(objectID: AudioObjectID(kAudioObjectSystemObject),
                           selector: kAudioHardwarePropertyTranslatePIDToProcessObject,
                           values: [processObject])
        mock.registerArray(objectID: processObject,
                           selector: kAudioProcessPropertyDevices,
                           scope: kAudioObjectPropertyScopeOutput,
                           values: outputDevices)
        mock.register(objectID: deviceID, selector: kAudioObjectPropertyClass, value: kAudioDeviceClassID)
        mock.registerString(objectID: deviceID, selector: kAudioObjectPropertyName, value: "Process Output")
        mock.register(objectID: deviceID, selector: kAudioDevicePropertyNominalSampleRate, value: Float64(44100))
        AudioBackend._setForTesting(mock)
    }

    @Test func resolvesTheProcessOutputDeviceAndItsRate() async throws {
        install(processObject: processID, outputDevices: [deviceID])

        let devices = try await AudioDevice.devices(usedByProcess: 123, scope: .output)

        #expect(devices.map(\.objectID) == [deviceID])
        #expect(devices.first?.nominalSampleRate == 44100)
    }

    @Test func processWithoutCoreAudioConnectionHasNoDevices() async throws {
        install(processObject: kAudioObjectUnknown, outputDevices: [deviceID])

        let devices = try await AudioDevice.devices(usedByProcess: 123, scope: .output)

        #expect(devices.isEmpty)
    }
}

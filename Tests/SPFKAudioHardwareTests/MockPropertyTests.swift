// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Testing

@testable import SPFKAudioHardware

/// Hardware-independent tests for property access logic.
///
/// These verify the validAddress → getProperty → type conversion → return chain
/// using `MockAudioBackend` instead of real CoreAudio hardware.
@Suite(.serialized, .tags(.unit))
final class MockPropertyTests {
    deinit {
        AudioBackendAccessor._resetBackend()
    }

    // MARK: - General Information Properties

    @Test func deviceName() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice(name: "Test Speaker")
        #expect(device.name == "Test Speaker")
    }

    @Test func transportTypeMapsUInt32ToEnum() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyTransportType,
                          value: kAudioDeviceTransportTypeVirtual)
        }
        #expect(device.transportType == .virtual)
    }

    @Test func transportTypeBuiltIn() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyTransportType,
                          value: kAudioDeviceTransportTypeBuiltIn)
        }
        #expect(device.transportType == .builtIn)
    }

    @Test func transportTypeReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.transportType == nil)
    }

    @Test func uidReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.uid == nil)
    }

    @Test func uidReturnsStringWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.registerString(objectID: id,
                                selector: kAudioDevicePropertyDeviceUID,
                                value: "TestDevice_UID")
        }
        #expect(device.uid == "TestDevice_UID")
    }

    @Test func modelUIDReturnsStringWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.registerString(objectID: id,
                                selector: kAudioDevicePropertyModelUID,
                                value: "TestModel_UID")
        }
        #expect(device.modelUID == "TestModel_UID")
    }

    @Test func manufacturerReturnsStringWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.registerString(objectID: id,
                                selector: kAudioObjectPropertyManufacturer,
                                value: "Test Manufacturer")
        }
        #expect(device.manufacturer == "Test Manufacturer")
    }

    @Test func isAliveReturnsTrueWhenPropertySet() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyDeviceIsAlive,
                          value: UInt32(1))
        }
        #expect(device.isAlive)
    }

    @Test func isAliveReturnsFalseWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(!device.isAlive)
    }

    @Test func isRunningReturnsFalseWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(!device.isRunning)
    }

    @Test func isRunningReturnsTrueWhenSet() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyDeviceIsRunning,
                          value: UInt32(1))
        }
        #expect(device.isRunning)
    }

    @Test func isRunningSomewhereReturnsFalseWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(!device.isRunningSomewhere)
    }

    // MARK: - Volume Properties

    @Test func volumeReturnsNilForUnregisteredChannel() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.volume(channel: 5, scope: .output) == nil)
    }

    @Test func volumeReturnsValueWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyVolumeScalar,
                          scope: kAudioObjectPropertyScopeOutput,
                          element: 0,
                          value: Float32(0.75))
        }
        #expect(device.volume(channel: 0, scope: .output) == 0.75)
    }

    @Test func setVolumeCallsThrough() async throws {
        let (device, mock) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyVolumeScalar,
                          scope: kAudioObjectPropertyScopeOutput,
                          element: 0,
                          value: Float32(0.5),
                          settable: true)
        }

        let status = device.setVolume(0.75, channel: 0, scope: .output)
        #expect(status == kAudioHardwareNoError)

        // Verify the mock recorded the set call
        let key = MockAudioBackend.PropertyKey(
            objectID: device.objectID,
            selector: kAudioDevicePropertyVolumeScalar,
            scope: kAudioObjectPropertyScopeOutput,
            element: 0
        )
        #expect(mock.setCalls[key] != nil)

        // Verify the new value was stored and can be read back
        #expect(device.volume(channel: 0, scope: .output) == 0.75)
    }

    @Test func setVolumeFailsWhenNotSettable() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyVolumeScalar,
                          scope: kAudioObjectPropertyScopeOutput,
                          element: 0,
                          value: Float32(0.5),
                          settable: false)
        }

        let status = device.setVolume(0.75, channel: 0, scope: .output)
        #expect(status != kAudioHardwareNoError)
    }

    @Test func setVolumeFailsWhenPropertyMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()

        let status = device.setVolume(0.75, channel: 0, scope: .output)
        #expect(status == kAudioHardwareBadObjectError)
    }

    // MARK: - Mute Properties

    @Test func isMutedReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.isMuted(channel: 0, scope: .output) == nil)
    }

    @Test func isMutedReturnsTrueWhenSet() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyMute,
                          scope: kAudioObjectPropertyScopeOutput,
                          element: 0,
                          value: UInt32(1))
        }
        #expect(device.isMuted(channel: 0, scope: .output) == true)
    }

    @Test func isMutedReturnsFalseWhenCleared() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyMute,
                          scope: kAudioObjectPropertyScopeOutput,
                          element: 0,
                          value: UInt32(0))
        }
        #expect(device.isMuted(channel: 0, scope: .output) == false)
    }

    // MARK: - Preferred Channels

    @Test func preferredChannelsForStereoParsesArray() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.registerArray(objectID: id,
                               selector: kAudioDevicePropertyPreferredChannelsForStereo,
                               scope: kAudioObjectPropertyScopeOutput,
                               values: [UInt32(1), UInt32(2)])
        }

        let channels = device.preferredChannelsForStereo(scope: .output)
        #expect(channels?.left == 1)
        #expect(channels?.right == 2)
    }

    @Test func preferredChannelsReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.preferredChannelsForStereo(scope: .output) == nil)
    }

    // MARK: - Sample Rate Properties

    @Test func nominalSampleRateReturnsValueWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyNominalSampleRate,
                          value: Float64(48000))
        }
        #expect(device.nominalSampleRate == 48000)
    }

    @Test func nominalSampleRateReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.nominalSampleRate == nil)
    }

    @Test func actualSampleRateReturnsValueWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyActualSampleRate,
                          value: Float64(44100))
        }
        #expect(device.actualSampleRate == 44100)
    }

    // MARK: - Latency & Buffer Size

    @Test func safetyOffsetReturnsValueWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertySafetyOffset,
                          scope: kAudioObjectPropertyScopeOutput,
                          value: UInt32(128))
        }
        #expect(device.safetyOffset(scope: .output) == 128)
    }

    @Test func safetyOffsetReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.safetyOffset(scope: .output) == nil)
    }

    @Test func bufferFrameSizeReturnsValueWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyBufferFrameSize,
                          scope: kAudioObjectPropertyScopeOutput,
                          value: UInt32(512))
        }
        #expect(device.bufferFrameSize(scope: .output) == 512)
    }

    // MARK: - Hog Mode

    @Test func hogModePIDReturnsValueWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyHogMode,
                          scope: kAudioObjectPropertyScopeWildcard,
                          value: Int32(-1))
        }
        #expect(device.hogModePID == -1)
    }

    @Test func hogModePIDReturnsNilWhenMissing() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.hogModePID == nil)
    }

    // MARK: - VolumeInfo (Direct C Call Path)

    @Test func volumeInfoReturnsNilWhenNoProperties() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice()
        #expect(device.volumeInfo(channel: 0, scope: .output) == nil)
    }

    @Test func volumeInfoReturnsDataWhenRegistered() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice { mock, id in
            // Register volume scalar property as existing and settable
            mock.register(objectID: id,
                          selector: kAudioDevicePropertyVolumeScalar,
                          scope: kAudioObjectPropertyScopeOutput,
                          element: 0,
                          value: Float32(0.5),
                          settable: true)
        }

        let info = device.volumeInfo(channel: 0, scope: .output)
        #expect(info != nil)
        #expect(info?.hasVolume == true)
        #expect(info?.canSetVolume == true)
        #expect(info?.volume == 0.5)
    }

    // MARK: - Supported Class IDs

    @Test func deviceCreationWithSubDeviceClassID() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice(
            classID: kAudioSubDeviceClassID
        )
        #expect(device.objectID == 42)
    }

    @Test func deviceCreationWithAggregateClassID() async throws {
        let (device, _) = try await MockDeviceFactory.makeDevice(
            classID: kAudioAggregateDeviceClassID
        )
        #expect(device.objectID == 42)
    }

    @Test func deviceCreationWithUnsupportedClassIDFails() async throws {
        let mock = MockAudioBackend()
        mock.register(objectID: 42,
                      selector: kAudioObjectPropertyClass,
                      value: AudioClassID(0x12345678))
        mock.registerString(objectID: 42,
                            selector: kAudioObjectPropertyName,
                            value: "Bad Device")
        AudioBackendAccessor._setBackendForTesting(mock)

        await #expect(throws: Error.self) {
            _ = try await AudioDevice(objectID: 42)
        }
    }

    // MARK: - Multiple Devices

    @Test func multipleDevicesWithDifferentIDs() async throws {
        let mock = MockAudioBackend()

        // Device 1
        mock.register(objectID: 10, selector: kAudioObjectPropertyClass, value: kAudioDeviceClassID)
        mock.registerString(objectID: 10, selector: kAudioObjectPropertyName, value: "Device A")
        mock.registerString(objectID: 10, selector: kAudioDevicePropertyDeviceUID, value: "uid_a")

        // Device 2
        mock.register(objectID: 20, selector: kAudioObjectPropertyClass, value: kAudioDeviceClassID)
        mock.registerString(objectID: 20, selector: kAudioObjectPropertyName, value: "Device B")
        mock.registerString(objectID: 20, selector: kAudioDevicePropertyDeviceUID, value: "uid_b")

        AudioBackendAccessor._setBackendForTesting(mock)

        let deviceA = try await AudioDevice(objectID: 10)
        let deviceB = try await AudioDevice(objectID: 20)

        #expect(deviceA.name == "Device A")
        #expect(deviceB.name == "Device B")
        #expect(deviceA.uid == "uid_a")
        #expect(deviceB.uid == "uid_b")
        #expect(deviceA != deviceB)
    }
}

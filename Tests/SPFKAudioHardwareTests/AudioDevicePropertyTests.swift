// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import SPFKBase
import Testing

@testable import SPFKAudioHardware

/// Additional property tests for AudioDevice covering volume conversion,
/// latency calculations, channels, and stream formats.
@Suite(.serialized)
final class AudioDevicePropertyTests: NullDeviceTestCase {
    // MARK: - Volume Conversion

    @Test(arguments: [Scope.output, Scope.input])
    func scalarToDecibelsConversion(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let dB = nullDevice.scalarToDecibels(volume: 0.5, channel: 0, scope: scope)

        // The Null Audio Device may not support volume conversion properties.
        // If supported, validate the converted value; otherwise just verify no crash.
        if let dB {
            #expect(dB < 0, "Half volume scalar should convert to negative dB")

            let dBMin = nullDevice.scalarToDecibels(volume: 0.0, channel: 0, scope: scope)
            if let dBMin {
                #expect(dBMin < dB, "Zero scalar volume should be lower dB than 0.5")
            }
        }

        // Invalid channel should return nil regardless
        #expect(nullDevice.scalarToDecibels(volume: 0.5, channel: 5, scope: scope) == nil)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func decibelsToScalarConversion(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let scalar = nullDevice.decibelsToScalar(volume: -70.5, channel: 0, scope: scope)

        // The Null Audio Device may not support volume conversion properties.
        if let scalar {
            #expect(scalar >= 0 && scalar <= 1, "Scalar volume should be between 0 and 1")
        }

        // Invalid channel should return nil regardless
        #expect(nullDevice.decibelsToScalar(volume: -70.5, channel: 5, scope: scope) == nil)

        try await tearDown()
    }

    // MARK: - Latency

    @Test(arguments: [Scope.output, Scope.input])
    func presentationLatency(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let latency = await nullDevice.presentationLatency(scope: scope)
        #expect(latency != nil, "presentationLatency should be non-nil for null device")

        if let latency {
            #expect(latency >= 0, "Latency in seconds should be non-negative")
            #expect(latency < 1, "Latency should be less than 1 second")
        }

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func deviceLatencyComponents(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let deviceLatency = nullDevice.deviceLatency(scope: scope)
        #expect(deviceLatency != nil)

        let safetyOffset = nullDevice.safetyOffset(scope: scope)
        #expect(safetyOffset != nil)

        let bufferSize = nullDevice.bufferFrameSize(scope: scope)
        #expect(bufferSize != nil)

        // Total latency should be the sum of components
        let totalLatency = await nullDevice.latency(scope: scope)

        let streamLatency = await nullDevice.streams(scope: scope)?.compactMap(\.latency).reduce(0, +) ?? 0

        let expectedSum = (deviceLatency ?? 0) + (safetyOffset ?? 0) + (bufferSize ?? 0) + streamLatency
        #expect(totalLatency == expectedSum, "Total latency should equal sum of components")

        try await tearDown()
    }

    @Test func bufferFrameSizeRange() async throws {
        let nullDevice = try #require(nullDevice)

        let range = nullDevice.bufferFrameSizeRange(scope: .output)

        if let range {
            #expect(range.isNotEmpty, "Buffer frame size range should not be empty")

            // Range should be sorted
            let sorted = range.sorted()
            #expect(range == sorted, "Range should be sorted")

            // Each value should be a power of 2 or aligned
            for size in range {
                #expect(size > 0, "Buffer size should be positive")
            }
        }

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func setBufferFrameSize(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let originalSize = try #require(nullDevice.bufferFrameSize(scope: scope))

        // Set to 512 (default for null device)
        let status = nullDevice.setBufferFrameSize(512, scope: scope)
        #expect(kAudioHardwareNoError == status)
        #expect(nullDevice.bufferFrameSize(scope: scope) == 512)

        // Restore original
        nullDevice.setBufferFrameSize(originalSize, scope: scope)

        try await tearDown()
    }

    // MARK: - Channels

    @Test(arguments: [Scope.output, Scope.input])
    func namedChannels(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let channels = await nullDevice.namedChannels(scope: scope)
        let physicalCount = await nullDevice.physicalChannels(scope: scope)

        #expect(UInt32(channels.count) == physicalCount, "Named channels count should match physical channel count")

        for channel in channels {
            #expect(channel.scope == scope)
        }

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func virtualChannels(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let virtualCount = await nullDevice.virtualChannels(scope: scope)
        #expect(virtualCount == 2, "Null device should have 2 virtual channels per scope")

        try await tearDown()
    }

    @Test func layoutChannels() async throws {
        let nullDevice = try #require(nullDevice)

        let outputChannels = nullDevice.layoutChannels(scope: .output)
        let inputChannels = nullDevice.layoutChannels(scope: .input)

        #expect(outputChannels == 2, "Null device should have 2 output layout channels")
        #expect(inputChannels == 2, "Null device should have 2 input layout channels")

        try await tearDown()
    }

    @Test func layoutChannelDescriptions() async throws {
        let nullDevice = try #require(nullDevice)

        let descriptions = nullDevice.layoutChannelDescriptions(scope: .output)

        if let descriptions {
            #expect(descriptions.isNotEmpty, "Should have channel descriptions")
        }

        try await tearDown()
    }

    @Test func preferredChannelsDescription() async throws {
        let nullDevice = try #require(nullDevice)

        let description = await nullDevice.preferredChannelsDescription(scope: .output)

        // May be nil if channels don't have names
        Log.debug("preferredChannelsDescription:", description ?? "nil")

        try await tearDown()
    }

    // MARK: - Stream Properties

    @Test(arguments: [Scope.output, Scope.input])
    func streamPhysicalFormat(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let streams = try #require(await nullDevice.streams(scope: scope))
        let stream = try #require(streams.first)

        let format = try #require(stream.physicalFormat)
        #expect(format.mSampleRate > 0, "Sample rate should be positive")
        #expect(format.mChannelsPerFrame > 0, "Should have at least one channel")

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func streamVirtualFormat(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let streams = try #require(await nullDevice.streams(scope: scope))
        let stream = try #require(streams.first)

        let format = try #require(stream.virtualFormat)
        #expect(format.mSampleRate > 0, "Sample rate should be positive")
        #expect(format.mChannelsPerFrame > 0, "Should have at least one channel")

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func streamAvailableFormats(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let streams = try #require(await nullDevice.streams(scope: scope))
        let stream = try #require(streams.first)

        let physicalFormats = try #require(stream.availablePhysicalFormats)
        #expect(physicalFormats.isNotEmpty, "Should have available physical formats")

        let virtualFormats = try #require(stream.availableVirtualFormats)
        #expect(virtualFormats.isNotEmpty, "Should have available virtual formats")

        try await tearDown()
    }

    // MARK: - Data Sources

    @Test(arguments: [Scope.output, Scope.input])
    func dataSourceLookup(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let sources = nullDevice.dataSources(scope: scope)

        if let sources {
            #expect(sources.isNotEmpty, "Null device should have data sources")

            for sourceID in sources {
                let name = nullDevice.dataSourceName(dataSourceID: sourceID, scope: scope)
                #expect(name != nil, "Data source \(sourceID) should have a name")
            }
        }

        try await tearDown()
    }

    // MARK: - Device Description

    @Test func deviceDescription() async throws {
        let nullDevice = try #require(nullDevice)

        let description = nullDevice.description
        #expect(description.contains("Null Audio Device"), "Description should contain device name")
        #expect(description.contains(String(nullDevice.objectID)), "Description should contain objectID")

        try await tearDown()
    }

    @Test func deviceNameAndID() async throws {
        let nullDevice = try #require(nullDevice)

        let nameAndID = nullDevice.nameAndID
        #expect(nameAndID.contains("Null Audio Device"))
        #expect(nameAndID.contains(String(nullDevice.objectID)))

        try await tearDown()
    }

    // MARK: - Aggregate Device Properties

    @Test func aggregateDeviceProperties() async throws {
        let device = try await createAggregateDevice(in: 0.3)

        let isAggregate = await device.isAggregateDevice
        #expect(isAggregate, "Created device should be aggregate")

        let ownedDevices = await device.ownedAggregateDevices
        #expect(ownedDevices != nil, "Aggregate device should have owned devices")

        let isCADefault = await device.isCADefaultDeviceAggregate()
        #expect(!isCADefault, "Test aggregate should not be CA default aggregate")

        let status = await hardwareManager.removeAggregateDevice(id: device.id)
        #expect(kAudioHardwareNoError == status)

        try await tearDown()
    }

    @Test func nonAggregateDeviceIsNotAggregate() async throws {
        let nullDevice = try #require(nullDevice)

        let isAggregate = await nullDevice.isAggregateDevice
        #expect(!isAggregate, "Null device should not be aggregate")

        try await tearDown()
    }

    // MARK: - Notification Enum

    @Test func audioDeviceNotificationGetDevice() async throws {
        let nullDevice = try #require(nullDevice)

        let notification = AudioDeviceNotification.deviceNameDidChange(objectID: nullDevice.objectID)
        let device = await notification.getAudioDevice()
        #expect(device == nullDevice)

        try await tearDown()
    }

    @Test func audioDeviceNotificationName() async throws {
        let notification = AudioDeviceNotification.deviceVolumeDidChange(
            objectID: 42,
            channel: 0,
            scope: .output
        )

        #expect(notification.name == .deviceVolumeDidChange)

        let muteNotification = AudioDeviceNotification.deviceMuteDidChange(
            objectID: 42,
            channel: 0,
            scope: .input
        )

        #expect(muteNotification.name == .deviceMuteDidChange)
    }

    // MARK: - Default Device

    @Test func defaultDevices() async throws {
        let defaultInput = await hardwareManager.defaultInputDevice
        let defaultOutput = await hardwareManager.defaultOutputDevice
        let defaultSystemOutput = await hardwareManager.defaultSystemOutputDevice

        // At least one default device should exist
        #expect(
            defaultInput != nil || defaultOutput != nil || defaultSystemOutput != nil,
            "At least one default device should exist"
        )

        if let defaultOutput {
            #expect(defaultOutput.isAlive, "Default output should be alive")
        }

        try await tearDown()
    }

    // MARK: - Owning Object

    @Test func streamOwningDevice() async throws {
        let nullDevice = try #require(nullDevice)

        let streams = try #require(await nullDevice.streams(scope: .output))
        let stream = try #require(streams.first)

        let owningObject = try await stream.owningObject()
        #expect(owningObject != nil, "Stream should have an owning object")

        try await tearDown()
    }
}

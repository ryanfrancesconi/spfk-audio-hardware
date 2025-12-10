// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
@testable import SPFKAudioHardware
import SPFKBase
import Testing

class NullDeviceTestCase: AudioHardwareTestCase {
    let nullDevice_name = "Null Audio Device"
    let nullDevice_manufacturer = "Apple Inc."
    let nullDevice_uid = "NullAudioDevice_UID"
    let nullDevice_modelUID = "NullAudioDevice_ModelUID"
    let nullDevice_configurationApplication = "com.apple.audio.AudioMIDISetup"

    var nullDevice: AudioDevice?

    override init() async throws {
        try await super.init()
        nullDevice = try await AudioDevice.lookup(uid: nullDevice_uid)
        try await resetNullDeviceState()
    }

    override func tearDown() async throws {
        try await resetNullDeviceState()

        try await super.tearDown()
        Log.debug("tearDown complete")
    }

    deinit {
        Log.debug("- { NullDeviceTestCase }")
    }

    func resetNullDeviceState() async throws {
        let nullDevice = try #require(nullDevice)

        nullDevice.unsetHogMode()
        try await nullDevice.sampleRateUpdater.updateAndWait(sampleRate: 44100)

        #expect(
            kAudioHardwareNoError == nullDevice.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 2), scope: .output)
        )

        #expect(
            kAudioHardwareNoError == nullDevice.setMute(false, channel: 0, scope: .output)
        )

        #expect(
            kAudioHardwareNoError == nullDevice.setMute(false, channel: 0, scope: .input)
        )

        #expect(
            kAudioHardwareNoError == nullDevice.setVolume(0.5, channel: 0, scope: .output)
        )

        #expect(
            kAudioHardwareNoError == nullDevice.setVolume(0.5, channel: 0, scope: .input)
        )

        #expect(
            kAudioHardwareNoError == nullDevice.setVirtualMainVolume(0.5, scope: .output)
        )

        #expect(
            kAudioHardwareNoError == nullDevice.setVirtualMainVolume(0.5, scope: .input)
        )
    }
}

extension NullDeviceTestCase {
    static let aggregateDeviceName = "NullDeviceAggregate"
    static let aggregateDeviceUID = "NullDeviceAggregate_UID"

    func createAggregateDevice(in delay: TimeInterval = 0) async throws -> AudioDevice {
        let nullDevice = try #require(nullDevice)

        let allDevices = try await hardwareManager.allDevices()

        if let existing = allDevices.first(where: {
            $0.uid == Self.aggregateDeviceUID
        }) {
            Log.error("Device exists attempting to remove it...")

            let status = await hardwareManager.removeAggregateDevice(id: existing.id)

            #expect(kAudioHardwareNoError == status)
        }

        if delay > 0 {
            try await Task.sleep(seconds: delay)
        }

        let device = try await hardwareManager.createAggregateDevice(
            mainDevice: nullDevice,
            secondDevice: nil,
            named: Self.aggregateDeviceName,
            uid: Self.aggregateDeviceUID
        )

        return device
    }

    func promoteAndWaitForEvent(device: AudioDevice, to selectorType: DefaultSelectorType) async throws {
        let notificationName = selectorType.notificationName

        let action = Task<OSStatus?, Error> {
            try await Task.sleep(for: .seconds(0.5))
            let status = try device.promote(to: selectorType)
            return status
        }

        let success = try await withThrowingTaskGroup(of: Bool.self, returning: Bool.self) { taskGroup in
            // wait task
            taskGroup.addTask {
                print("waiting for", notificationName)
                let notification = try await NotificationCenter.wait(for: notificationName)

                return notification.name == notificationName
            }

            // timeout check
            taskGroup.addTask {
                try await Task.sleep(seconds: 5)
                print("* Test timed out")
                return false
            }

            let value = try await taskGroup.next() == true
            taskGroup.cancelAll()

            return value
        }

        #expect(success)

        let result = await action.result

        switch result {
        case let .success(status):
            #expect(noErr == status)

        case let .failure(error):
            throw error
        }
    }
}

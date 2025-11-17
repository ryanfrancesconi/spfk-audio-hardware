// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import Numerics
@testable import SPFKAudioHardware
import Testing

@Suite(.serialized)
final class AudioHardwareTests: SCATestCase {
    let deviceName = "NullDeviceAggregate"
    let deviceUID = "NullDeviceAggregate_UID"

    @Test func createAndDestroyAggregateDevice() async throws {
        let nullDevice = try getNullDevice()
        let uid = "testCreateAggregateAudioDevice-12345"

        guard let device = simplyCA.createAggregateDevice(
            mainDevice: nullDevice,
            secondDevice: nil,
            named: "testCreateAggregateAudioDevice",
            uid: uid
        ) else {
            Issue.record("Failed creating device")
            return
        }

        try await Task.sleep(for: .seconds(1))

        #expect(device.isAggregateDevice)
        #expect(device.ownedAggregateDevices?.count == 1)

        try await wait(sec: 1)

        #expect(noErr == simplyCA.removeAggregateDevice(id: device.id))

        try await wait(sec: 1)
    }

    @Test func deviceListChanged() async throws {
        let task = Task<Bool, Error> {
            let notification = try await NotificationCenter.wait(for: .deviceListChanged)

            guard let hardwareNotification = notification.object as? AudioHardwareNotification else { return false }

            guard case let .deviceListChanged(addedDevices: addedDevices, removedDevices: _) = hardwareNotification else {
                return false
            }

            let firstAddedDevice = try #require(addedDevices.first)
            let passed = firstAddedDevice.uid == deviceUID && firstAddedDevice.name == deviceName
            return passed
        }

        let device = try #require(try await createAggregateDevice(in: 1))

        #expect(try await task.value)
        task.cancel()

        #expect(noErr == simplyCA.removeAggregateDevice(id: device.id))
    }

    @Test(arguments: DefaultSelectorType.allCases)
    func defaultIODeviceChanged(selectorType: DefaultSelectorType) async throws {
        // this is the event that will trigger
        let aggregateDevice = try #require(try await createAggregateDevice(in: 0))

        try await promoteAndWaitForEvent(device: aggregateDevice, to: selectorType)

        #expect(AudioDevice.defaultDevice(of: selectorType) == aggregateDevice)

        #expect(noErr == simplyCA.removeAggregateDevice(id: aggregateDevice.id))
    }
}

extension AudioHardwareTests {
    func createAggregateDevice(in delay: TimeInterval = 0.2) async throws -> AudioDevice? {
        let nullDevice = try getNullDevice()

        // make sure this happens after the notification handlers are in place
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }

        return simplyCA.createAggregateDevice(
            mainDevice: nullDevice,
            secondDevice: nil,
            named: deviceName,
            uid: deviceUID
        )
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
                try await Task.sleep(for: .seconds(5))
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

//    @Test func testHardwareNotificationsAreNotDuplicated() async throws {
//        let simplyCA2 = AudioHardwareManager()
//        let simplyCA3 = AudioHardwareManager()
//
//        let task1 = Task<Bool, Error> {
//            let notification = try await wait(for: .deviceListChanged)
//            return true
//        }
//
//        let task2 = Task<Bool, Error> {
//            let notification = try await wait(for: .deviceListChanged)
//            return true
//        }
//
//        let task3 = Task<Bool, Error> {
//            let notification = try await wait(for: .deviceListChanged)
//            return true
//        }
//
//        try await Task.sleep(for: .seconds(2))
//
//        #expect(try await task1.value)
//        #expect(try await task2.value)
//        #expect(try await task3.value)
//
//        try await cleanup()
//    }

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import Numerics
@testable import SPFKAudioHardware
import SPFKBase
import Testing

@Suite(.serialized)
final class AudioHardwareTests: NullDeviceTestCase {
    let aggregateDeviceName = "NullDeviceAggregate"
    let aggregateDeviceUID = "NullDeviceAggregate_UID"

    @Test func createAndDestroyAggregateDevice() async throws {
        let device = try #require(try await createAggregateDevice(in: 1))

        try await Task.sleep(for: .seconds(1))

        let isAggregateDevice = await device.isAggregateDevice

        #expect(isAggregateDevice)
        await #expect(device.ownedAggregateDevices?.count == 1)

        try await wait(sec: 1)

        #expect(noErr == hardware.removeAggregateDevice(id: device.id))

        try await wait(sec: 1)

        try await tearDown()
    }

    @Test func deviceListChanged() async throws {
        let task = Task<Bool, Error> {
            let notification = try await NotificationCenter.wait(for: .deviceListChanged)

            guard let hardwareNotification = notification.object as? AudioHardwareNotification else { return false }

            guard case let .deviceListChanged(event: event) = hardwareNotification else {
                return false
            }

            let firstAddedDevice = try #require(event.addedDevices.first)
            let passed = firstAddedDevice.uid == aggregateDeviceUID && firstAddedDevice.name == aggregateDeviceName
            return passed
        }

        let device = try #require(try await createAggregateDevice(in: 1))

        #expect(try await task.value)
        task.cancel()

        #expect(noErr == hardware.removeAggregateDevice(id: device.id))

        try await tearDown()
    }

    @Test(arguments: DefaultSelectorType.allCases)
    func defaultIODeviceChanged(selectorType: DefaultSelectorType) async throws {
        // this is the event that will trigger
        let aggregateDevice = try #require(try await createAggregateDevice(in: 0))

        try await promoteAndWaitForEvent(device: aggregateDevice, to: selectorType)

        await #expect(AudioDevice.defaultDevice(of: selectorType) == aggregateDevice)

        #expect(noErr == hardware.removeAggregateDevice(id: aggregateDevice.id))

        try await tearDown()
    }
}

extension AudioHardwareTests {
    func createAggregateDevice(in delay: TimeInterval = 0) async throws -> AudioDevice? {
        let nullDevice = try #require(nullDevice)

        if let existing = await hardware.allDevices.first(where: {
            $0.uid == aggregateDeviceUID
        }) {
            Log.error("Device exists attempting to remove it...")

            #expect(noErr == hardware.removeAggregateDevice(id: existing.id))
        }

        // make sure this happens after the notification handlers are in place
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }

        return try await hardware.createAggregateDevice(
            mainDevice: nullDevice,
            secondDevice: nil,
            named: aggregateDeviceName,
            uid: aggregateDeviceUID
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

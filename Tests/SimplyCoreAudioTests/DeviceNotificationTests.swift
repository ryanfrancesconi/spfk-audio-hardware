// Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation
@testable import SimplyCoreAudio
import Testing

@Suite(.serialized)
final class DeviceNotificationTests: SCATestCase {
    lazy var nullDevice = try? getNullDevice()
    let deviceName = "NullDeviceAggregate"
    let deviceUID = "NullDeviceAggregate_UID"
    var aggregateDevice: AudioDevice?

    override init() async throws {
        try await super.init()
    }

    @Test func deviceListChanged() async throws {
        let task = Task<Bool, Error> {
            let notification = try await wait(for: .deviceListChanged)

            let addedDevices = try #require(notification.userInfo?["addedDevices"] as? [AudioDevice])
            let firstAddedDevice = try #require(addedDevices.first)

            let passed = firstAddedDevice.uid == deviceUID && firstAddedDevice.name == deviceName
            return passed
        }

        try await createAggregateDevice(in: 1)

        #expect(try await task.value)

        try await cleanup()
    }

    @Test(arguments: [DefaultDeviceType.input, DefaultDeviceType.output, DefaultDeviceType.systemOutput])
    func defaultIODeviceChanged(propertyType: DefaultDeviceType) async throws {
        try await testWithTimeout(propertyType: propertyType)
    }
}

extension DeviceNotificationTests {
    func createAggregateDevice(in delay: TimeInterval = 0.2) async throws {
        try await cleanup()

        let nullDevice = try #require(nullDevice)

        // make sure this happens after the notification handlers are in place
        try await Task.sleep(for: .seconds(delay))

        aggregateDevice = simplyCA.createAggregateDevice(
            mainDevice: nullDevice,
            secondDevice: nil,
            named: deviceName,
            uid: deviceUID
        )
    }

    func cleanup() async throws {
        if let existingDevice = simplyCA.allAggregateDevices.first(where: { device in
            device.uid == deviceUID
        }) {
            if noErr != simplyCA.removeAggregateDevice(id: existingDevice.id) {
                Issue.record("Failed to remove existing device")
            }

            try await Task.sleep(for: .seconds(1))
        }
    }

    func test(propertyType: DefaultDeviceType) async throws {
        let notificationName = propertyType.notificationName

        let task = Task<Bool, Error> {
            let notification = try await wait(for: notificationName)

            return notification.name == notificationName &&
                simplyCA.getDevice(of: propertyType) == aggregateDevice
        }

        let action = Task<OSStatus?, Error> {
            try await Task.sleep(for: .seconds(0.5))
            let status = try aggregateDevice?.promote(to: propertyType)
            return status
        }

        #expect(try await task.value)

        let result = await action.result

        switch result {
        case let .success(status):
            #expect(noErr == status)

        case let .failure(error):
            throw error
        }

        try await cleanup()
    }

    func testWithTimeout(propertyType: DefaultDeviceType) async throws {
        try await createAggregateDevice()

        let notificationName = propertyType.notificationName

        let action = Task<OSStatus?, Error> {
            try await Task.sleep(for: .seconds(1))
            let status = try aggregateDevice?.promote(to: propertyType)
            return status
        }

        let success = try await withThrowingTaskGroup(of: Bool.self, returning: Bool.self) { taskGroup in
            taskGroup.addTask {
                let notification = try await self.wait(for: notificationName)

                return notification.name == notificationName &&
                    self.simplyCA.getDevice(of: propertyType) == self.aggregateDevice
            }

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

        try await cleanup()
    }
}

// extension DeviceNotificationTests {
//    @Test func testHardwareNotificationsAreNotDuplicated() async throws {
//        let simplyCA2 = SimplyCoreAudio()
//        let simplyCA3 = SimplyCoreAudio()
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
// }

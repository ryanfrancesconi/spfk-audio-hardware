// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import Numerics
@testable import SPFKAudioHardware
import SPFKBase
import Testing

@Suite(.serialized)
final class AudioHardwareTests: NullDeviceTestCase {
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
            let passed = firstAddedDevice.uid == Self.aggregateDeviceUID && firstAddedDevice.name == Self.aggregateDeviceName
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

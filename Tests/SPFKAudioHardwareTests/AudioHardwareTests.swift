// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import Numerics
import SPFKBase
import Testing

@testable import SPFKAudioHardware

@Suite(.serialized)
final class AudioHardwareTests: NullDeviceTestCase {
    @Test func createAndDestroyAggregateDevice() async throws {
        let device = try await createAggregateDevice(in: 1)

        let isAggregateDevice = await device.isAggregateDevice

        #expect(isAggregateDevice)
        await #expect(device.ownedAggregateDevices?.count == 1)

        let status = await hardwareManager.removeAggregateDevice(id: device.id)
        #expect(kAudioHardwareNoError == status)

        try await tearDown()
        
        try await wait(sec: 10)
    }

    @Test func deviceListChanged() async throws {
        // Copy only static constants locally to avoid capturing self in the Task closure.
        let expectedUID = Self.aggregateDeviceUID
        let expectedName = Self.aggregateDeviceName

        let task = Task<Bool, Error>(priority: nil) { @Sendable () -> Bool in
            let notification = try await NotificationCenter.wait(for: .deviceListChanged)

            guard let anyObject = notification.object else { return false }
            guard let hardwareNotification = anyObject as? AudioHardwareNotification else { return false }

            switch hardwareNotification {
            case .deviceListChanged(objectID: _, event: let event):
                guard let firstAddedDevice = event.addedDevices.first else { return false }
                return firstAddedDevice.uid == expectedUID && firstAddedDevice.name == expectedName
            default:
                return false
            }
        }

        let device = try await createAggregateDevice(in: 1)

        #expect(try await task.value)

        task.cancel()

        let status = await hardwareManager.removeAggregateDevice(id: device.id)

        #expect(kAudioHardwareNoError == status)

        try await tearDown()
    }

    @Test(arguments: DefaultSelectorType.allCases)
    func defaultIODeviceChanged(selectorType: DefaultSelectorType) async throws {
        // this is the event that will trigger
        let device = try await createAggregateDevice(in: 0)

        try await promoteAndWaitForEvent(device: device, to: selectorType)

        await #expect(AudioDevice.defaultDevice(of: selectorType) == device)

        let status = await hardwareManager.removeAggregateDevice(id: device.id)

        #expect(kAudioHardwareNoError == status)

        try await tearDown()
    }
}

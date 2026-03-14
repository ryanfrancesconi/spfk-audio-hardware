// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase
import Testing

@testable import SPFKAudioHardware

@Suite(.serialized, .tags(.hardware, .notification))
final class AudioDeviceNotificationTests: NullDeviceTestCase {
    @Test(arguments: [Scope.output, Scope.input])
    func volumeDidChangeNotification(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let task = Task<(objectID: AudioObjectID, channel: UInt32, scope: Scope), Error> { @Sendable in
            try await Self.waitForDeviceOption(named: .deviceVolumeDidChange)
        }

        #expect(
            kAudioHardwareNoError == nullDevice.setVirtualMainVolume(1, scope: scope)
        )

        let result = await task.result

        switch result {
        case let .success((objectID: objectID, channel: channel, scope: resultScope)):
            #expect(objectID == nullDevice.objectID)
            #expect(channel == 0)
            #expect(resultScope == scope)

        case let .failure(error):
            throw error
        }

        try await tearDown()
        await Task.yield()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func muteDidChangeNotification(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let task = Task<(objectID: AudioObjectID, channel: UInt32, scope: Scope), Error> { @Sendable in
            try await Self.waitForDeviceOption(named: .deviceMuteDidChange)
        }

        #expect(
            kAudioHardwareNoError == nullDevice.setMute(true, channel: 0, scope: scope)
        )

        let result = await task.result

        switch result {
        case let .success((objectID: objectID, channel: channel, scope: resultScope)):
            #expect(objectID == nullDevice.objectID)
            #expect(channel == 0)
            #expect(resultScope == scope)

        case let .failure(error):
            throw error
        }

        #expect(nullDevice.isMuted(channel: 0, scope: scope) == true)

        try await tearDown()
        await Task.yield()
    }

    @Test func deviceListening() async throws {
        await AudioObjectPool.shared.stopListening()
        await AudioObjectPool.shared.startListening()
        await AudioObjectPool.shared.stopListening()

        try await tearDown()
        await Task.yield()
    }

    @Test func audioDeviceCacheUpdate() async throws {
        for _ in 0 ..< 2 {
            // Wait for the device-added notification instead of a fixed sleep.
            let addTask = Task<Bool, Error> { @Sendable in
                let notification = try await NotificationCenter.wait(for: .deviceListChanged, timeout: 5)
                return notification.object is AudioHardwareNotification
            }

            let device = try await createAggregateDevice()

            #expect(try await addTask.value)

            // Wait for the device-removed notification instead of a fixed sleep.
            let removeTask = Task<Bool, Error> { @Sendable in
                let notification = try await NotificationCenter.wait(for: .deviceListChanged, timeout: 5)
                return notification.object is AudioHardwareNotification
            }

            let status = await hardwareManager.removeAggregateDevice(id: device.id)
            #expect(kAudioHardwareNoError == status)

            #expect(try await removeTask.value)
        }
    }
}

extension AudioDeviceNotificationTests {
    static func waitForDeviceOption(named notificationName: Notification.Name) async throws -> (
        objectID: AudioObjectID, channel: UInt32, scope: Scope
    ) {
        let notification: Notification = try await NotificationCenter.wait(for: notificationName, timeout: 3)

        guard let deviceNotification = notification.object as? AudioDeviceNotification else {
            throw NSError(description: "Failed to get properties for \(notificationName)")
        }

        switch deviceNotification {
        case let .deviceVolumeDidChange(objectID: objectID, channel: channel, scope: scope):
            return (objectID: objectID, channel: channel, scope: scope)

        case let .deviceMuteDidChange(objectID: objectID, channel: channel, scope: scope):
            return (objectID: objectID, channel: channel, scope: scope)

        default:
            throw NSError(description: "failed to get correct event")
        }
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
@testable import SPFKAudioHardware
import Testing

@Suite(.serialized)
final class AudioDeviceNotificationTests: NullDeviceTestCase {
    @Test(arguments: [48000])
    func sampleRateDidChangeNotification(targetSampleRate: Float64) async throws {
        let nullDevice = try #require(nullDevice)

        try await nullDevice.update(sampleRate: targetSampleRate)

        #expect(targetSampleRate == nullDevice.nominalSampleRate)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func volumeDidChangeNotification(scopeToTest: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let task = Task<(objectID: AudioObjectID, channel: UInt32, scope: Scope), Error> {
            try await waitForDeviceOption(named: .deviceVolumeDidChange)
        }

        nullDevice.setVirtualMainVolume(1, scope: scopeToTest)

        let result = await task.result

        switch result {
        case let .success((objectID: objectID, channel: channel, scope: scope)):
            #expect(objectID == nullDevice.objectID)
            #expect(channel == 0)
            #expect(scope == scopeToTest)

        case let .failure(error):
            throw error
        }

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func muteDidChangeNotification(scopeToTest: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let task = Task<(objectID: AudioObjectID, channel: UInt32, scope: Scope), Error> {
            try await waitForDeviceOption(named: .deviceMuteDidChange)
        }

        nullDevice.setMute(true, channel: 0, scope: scopeToTest)

        let result = await task.result

        switch result {
        case let .success((objectID: objectID, channel: channel, scope: scope)):
            #expect(objectID == nullDevice.objectID)
            #expect(channel == 0)
            #expect(scope == scopeToTest)

        case let .failure(error):
            throw error
        }

        #expect(nullDevice.isMuted(channel: 0, scope: scopeToTest) == true)

        try await tearDown()
    }

    @Test func deviceListening() async throws {
        await AudioObjectPool.shared.stopListening()
        try await wait(sec: 0.2)
        await AudioObjectPool.shared.startListening()
        try await wait(sec: 0.2)
        await AudioObjectPool.shared.stopListening()

        try await tearDown()
    }
}

extension AudioDeviceNotificationTests {
    func waitForDeviceOption(named notificationName: Notification.Name) async throws -> (objectID: AudioObjectID, channel: UInt32, scope: Scope) {
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

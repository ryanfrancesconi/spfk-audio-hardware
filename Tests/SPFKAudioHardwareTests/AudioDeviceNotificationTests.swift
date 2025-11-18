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

        let nominalSampleRates = try #require(nullDevice.nominalSampleRates)

        #expect(nominalSampleRates.contains(targetSampleRate))

        let task = Task<Float64?, Error> {
            let notification: Notification = try await NotificationCenter.wait(for: .deviceNominalSampleRateDidChange)

            let id: AudioObjectID = try #require(notification.userInfo?["id"] as? AudioObjectID)
            let device: AudioDevice = try #require(await AudioDevice.lookup(by: id))

            return device.nominalSampleRate
        }

        nullDevice.setNominalSampleRate(targetSampleRate)

        let result = await task.result

        switch result {
        case let .success(newSampleRate):
            #expect(targetSampleRate == newSampleRate)

        case let .failure(error):
            throw error
        }

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func volumeDidChangeNotification(scopeToTest: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        let task = Task<(channel: UInt32, scope: Scope), Error> {
            try await waitForDeviceOption(named: .deviceVolumeDidChange)
        }

        nullDevice.setVirtualMainVolume(1, scope: scopeToTest)

        let result = await task.result

        switch result {
        case let .success((channel: channel, scope: scope)):
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

        let task = Task<(channel: UInt32, scope: Scope), Error> {
            try await waitForDeviceOption(named: .deviceMuteDidChange)
        }

        nullDevice.setMute(true, channel: 0, scope: scopeToTest)

        let result = await task.result

        switch result {
        case let .success((channel: channel, scope: scope)):
            #expect(channel == 0)
            #expect(scope == scopeToTest)

        case let .failure(error):
            throw error
        }

        #expect(nullDevice.isMuted(channel: 0, scope: scopeToTest) == true)

        try await tearDown()
    }
}

extension AudioDeviceNotificationTests {
    func waitForDeviceOption(named notificationName: Notification.Name) async throws -> (channel: UInt32, scope: Scope) {
        let notification: Notification = try await NotificationCenter.wait(for: notificationName)

        guard let deviceNotification = notification.userInfo?[notificationName] as? AudioDeviceNotification else {
            throw NSError(description: "Failed to get properties for \(notificationName)")
        }

        switch deviceNotification {
        case let .deviceVolumeDidChange(channel: channel, scope: scope):
            return (channel: channel, scope: scope)

        case let .deviceMuteDidChange(channel: channel, scope: scope):
            return (channel: channel, scope: scope)

        default:
            throw NSError(description: "failed to get correct event")
        }
    }
}

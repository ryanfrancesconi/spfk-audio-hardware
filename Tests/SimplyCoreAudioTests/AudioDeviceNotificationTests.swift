// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation
@testable import SimplyCoreAudio
import Testing

@Suite(.serialized)
final class AudioDeviceNotificationTests: SCATestCase {
    lazy var nullDevice = try? getNullDevice()

    @Test(arguments: [48000])
    func sampleRateDidChangeNotification(targetSampleRate: Float64) async throws {
        let device = try getNullDevice()

        let nominalSampleRates = try #require(device.nominalSampleRates)

        #expect(nominalSampleRates.contains(targetSampleRate))

        let task = Task<Float64?, Error> {
            let notification: Notification = try await NotificationCenter.wait(for: .deviceNominalSampleRateDidChange)
            let device = try #require(notification.object as? AudioDevice)
            return device.nominalSampleRate
        }

        device.setNominalSampleRate(targetSampleRate)

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
        let device = try getNullDevice()

        let task = Task<(channel: UInt32, scope: Scope), Error> {
            try await waitForDeviceOption(named: .deviceVolumeDidChange)
        }

        device.setVirtualMainVolume(1, scope: scopeToTest)

        let result = await task.result

        switch result {
        case let .success((channel: channel, scope: scope)):
            #expect(channel == 0)
            #expect(scope == scopeToTest)

        case let .failure(error):
            throw error
        }
    }

    @Test(arguments: [Scope.output, Scope.input])
    func muteDidChangeNotification(scopeToTest: Scope) async throws {
        let device = try getNullDevice()

        let task = Task<(channel: UInt32, scope: Scope), Error> {
            try await waitForDeviceOption(named: .deviceMuteDidChange)
        }

        device.setMute(true, channel: 0, scope: scopeToTest)

        let result = await task.result

        switch result {
        case let .success((channel: channel, scope: scope)):
            #expect(channel == 0)
            #expect(scope == scopeToTest)

        case let .failure(error):
            throw error
        }

        #expect(device.isMuted(channel: 0, scope: scopeToTest) == true)
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

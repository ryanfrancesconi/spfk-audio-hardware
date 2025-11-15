// Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation
@testable import SimplyCoreAudio
import Testing

@Suite(.serialized)
final class DeviceOptionsNotificationTests: SCATestCase {
    @Test(arguments: [48000])
    func testDeviceSampleRateDidChangeNotification(targetSampleRate: Float64) async throws {
        let nullDevice = try getNullDevice()

        let nominalSampleRates = try #require(nullDevice.nominalSampleRates)

        #expect(nominalSampleRates.contains(targetSampleRate))

        let task = Task<Float64?, Error> {
            let notification: Notification = try await wait(for: .deviceNominalSampleRateDidChange)

            let device = try #require(notification.object as? AudioDevice)

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
    func testDeviceVolumeDidChangeNotification(scopeToTest: Scope) async throws {
        let nullDevice = try getNullDevice()

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
    }

    @Test(arguments: [Scope.output, Scope.input])
    func testDeviceMuteDidChangeNotification(scopeToTest: Scope) async throws {
        let nullDevice = try getNullDevice()

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
    }
}

extension DeviceOptionsNotificationTests {
    func waitForDeviceOption(named name: Notification.Name) async throws -> (channel: UInt32, scope: Scope) {
        let notification: Notification = try await wait(for: name)

        let channel = try #require(notification.userInfo?["channel"] as? UInt32)
        let scope = try #require(notification.userInfo?["scope"] as? Scope)

        return (channel: channel, scope: scope)
    }
}

// Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation
@testable import SimplyCoreAudio
import Testing

class SCATestCase {
    var simplyCA: SimplyCoreAudio
    var defaultInputDevice: AudioDevice?
    var defaultOutputDevice: AudioDevice?
    var defaultSystemOutputDevice: AudioDevice?

    public init() async throws {
        simplyCA = SimplyCoreAudio()
        saveDefaultDevices()
        try resetNullDeviceState()
    }

    deinit {
        restoreDefaultDevices()
        try? resetNullDeviceState()
    }

    func getNullDevice() throws -> AudioDevice {
        try #require(
            AudioDevice.lookup(by: "NullAudioDevice_UID")
        )
    }

    func tearDown() async throws {
        try resetNullDeviceState()
        try await Task.sleep(for: .seconds(1))
        print(#function)
    }

    func resetNullDeviceState() throws {
        let device = try getNullDevice()

        device.unsetHogMode()

        if device.nominalSampleRate != 44100 {
            device.setNominalSampleRate(44100)
        }

        device.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 2), scope: .output)
        device.setMute(false, channel: 0, scope: .output)
        device.setMute(false, channel: 0, scope: .input)
        device.setVolume(0.5, channel: 0, scope: .output)
        device.setVolume(0.5, channel: 0, scope: .input)
        device.setVirtualMainVolume(0.5, scope: .output)
        device.setVirtualMainVolume(0.5, scope: .input)
    }

    func wait(for notificationName: Notification.Name) async throws -> Notification {
        let asyncSequence = NotificationCenter.default.notifications(named: notificationName)
        let iterator = asyncSequence.makeAsyncIterator()

        guard let notification = await iterator.next() else {
            throw NSError(domain: "failed to get notification", code: 0)
        }

        print(notification)

        return notification
    }

    func remove(aggregateDeviceUID deviceUID: String) async throws {
        if let existingDevice = simplyCA.allAggregateDevices.first(where: { device in
            device.uid == deviceUID
        }) {
            if noErr != simplyCA.removeAggregateDevice(id: existingDevice.id) {
                Issue.record("Failed to remove existing device")
            }

            try await Task.sleep(for: .seconds(1))
            return
        } else {
            print("didn't find device of UID", deviceUID)
        }
    }
}

// MARK: - Private Functions

private extension SCATestCase {
    func saveDefaultDevices() {
        defaultInputDevice = simplyCA.defaultInputDevice
        defaultOutputDevice = simplyCA.defaultOutputDevice
        defaultSystemOutputDevice = simplyCA.defaultSystemOutputDevice
    }

    func restoreDefaultDevices() {
        defaultInputDevice?.isDefaultInputDevice = true
        defaultOutputDevice?.isDefaultOutputDevice = true
        defaultSystemOutputDevice?.isDefaultSystemOutputDevice = true
    }
}

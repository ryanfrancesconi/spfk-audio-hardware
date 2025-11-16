// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
@testable import SPFKAudioHardware
import Testing

class SCATestCase {
    var simplyCA: SimplyCoreAudio

    private var defaultInputDevice: AudioDevice?
    private var defaultOutputDevice: AudioDevice?
    private var defaultSystemOutputDevice: AudioDevice?

    public init() async throws {
        simplyCA = SimplyCoreAudio()
        saveDefaultDevices()
        try resetNullDeviceState()
    }

    deinit {
        restoreDefaultDevices()
        try? resetNullDeviceState()
    }

    func tearDown() async throws {
        try resetNullDeviceState()
        try await wait(sec: 1)
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

    func getNullDevice() throws -> AudioDevice {
        try #require(
            AudioDevice.lookup(by: "NullAudioDevice_UID")
        )
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

extension SCATestCase {
    public func wait(sec seconds: TimeInterval) async throws {
        try await Task.sleep(seconds: seconds)
    }
}

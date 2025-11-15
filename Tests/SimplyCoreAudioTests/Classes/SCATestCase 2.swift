
import Foundation
@testable import SimplyCoreAudio
import Testing

class SCATestCase2 {
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

    func resetNullDeviceState() throws {
        let device = try getNullDevice()

        device.unsetHogMode()

        if device.nominalSampleRate != 44100 {
            device.setNominalSampleRate(44100)
            // wait(for: 1)
            // try await Task.sleep(for: .seconds(1))
        }

        device.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 2), scope: .output)
        device.setMute(false, channel: 0, scope: .output)
        device.setMute(false, channel: 0, scope: .input)
        device.setVolume(0.5, channel: 0, scope: .output)
        device.setVolume(0.5, channel: 0, scope: .input)
        device.setVirtualMainVolume(0.5, scope: .output)
        device.setVirtualMainVolume(0.5, scope: .input)
    }
}

// MARK: - Private Functions

private extension SCATestCase2 {
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

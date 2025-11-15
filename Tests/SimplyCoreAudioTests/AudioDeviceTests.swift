// Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation
import Numerics
@testable import SimplyCoreAudio
import Testing

@Suite(.serialized)
final class AudioDeviceTests: SCATestCase {
    @Test func testDeviceLookUp() async throws {
        let device = try getNullDevice()
        let deviceUID = try #require(device.uid)

        #expect(AudioDevice.lookup(by: device.id) == device)
        #expect(AudioDevice.lookup(by: deviceUID) == device)
    }

    @Test func testSettingDefaultDevice() async throws {
        let device = try getNullDevice()

        device.isDefaultInputDevice = true

        #expect(device.isDefaultInputDevice)
        #expect(simplyCA.defaultInputDevice == device)

        device.isDefaultOutputDevice = true

        #expect(device.isDefaultOutputDevice)
        #expect(simplyCA.defaultOutputDevice == device)

        device.isDefaultSystemOutputDevice = true

        #expect(device.isDefaultSystemOutputDevice)
        #expect(simplyCA.defaultSystemOutputDevice == device)
    }

    @Test func testGeneralDeviceInformation() async throws {
        let device = try getNullDevice()

        #expect(device.name == "Null Audio Device")
        #expect(device.manufacturer == "Apple Inc.")
        #expect(device.uid == "NullAudioDevice_UID")
        #expect(device.modelUID == "NullAudioDevice_ModelUID")
        #expect(device.configurationApplication == "com.apple.audio.AudioMIDISetup")
        #expect(device.transportType == .virtual)

        #expect(!device.isInputOnlyDevice)
        #expect(!device.isOutputOnlyDevice)
        #expect(!device.isHidden)

        #expect(device.isJackConnected(scope: .output) == nil)
        #expect(device.isJackConnected(scope: .input) == nil)

        #expect(device.isAlive)
        #expect(!device.isRunning)
        #expect(!device.isRunningSomewhere)

        #expect(device.channels(scope: .output) == 2)
        #expect(device.channels(scope: .input) == 2)

        #expect(device.ownedObjectIDs != nil)
        #expect(device.controlList != nil)
        #expect(device.relatedDevices != nil)
    }

    @Test func testLFE() async throws {
        let device = try getNullDevice()

        #expect(device.shouldOwniSub == nil)
        device.shouldOwniSub = true
        #expect(device.shouldOwniSub == nil)

        #expect(device.lfeMute == nil)
        device.lfeMute = true
        #expect(device.lfeMute == nil)

        #expect(device.lfeVolume == nil)
        device.lfeVolume = 1.0
        #expect(device.lfeVolume == nil)

        #expect(device.lfeVolumeDecibels == nil)
        device.lfeVolumeDecibels = 6.0
        #expect(device.lfeVolumeDecibels == nil)
    }

    @Test func testInputOutputLayout() async throws {
        let device = try getNullDevice()

        #expect(device.layoutChannels(scope: .output) == 2)
        #expect(device.layoutChannels(scope: .input) == 2)

        #expect(device.channels(scope: .output) == 2)
        #expect(device.channels(scope: .input) == 2)

        #expect(!device.isInputOnlyDevice)
        #expect(!device.isOutputOnlyDevice)
    }

    @Test func testVolumeInfo() async throws {
        let device = try getNullDevice()
        var volumeInfo: VolumeInfo!

        #expect(device.setMute(false, channel: 0, scope: .output))

        volumeInfo = device.volumeInfo(channel: 0, scope: .output)
        #expect(volumeInfo.hasVolume == true)
        #expect(volumeInfo.canSetVolume == true)
        #expect(volumeInfo.canMute == true)
        #expect(volumeInfo.isMuted == false)
        #expect(volumeInfo.canPlayThru == false)
        #expect(volumeInfo.isPlayThruSet == false)

        #expect(device.setVolume(0, channel: 0, scope: .output))
        volumeInfo = device.volumeInfo(channel: 0, scope: .output)
        #expect(volumeInfo.volume == 0)

        #expect(device.setVolume(0.5, channel: 0, scope: .output))
        volumeInfo = device.volumeInfo(channel: 0, scope: .output)
        #expect(volumeInfo.volume == 0.5)

        #expect(device.volumeInfo(channel: 1, scope: .output) == nil)
        #expect(device.volumeInfo(channel: 2, scope: .output) == nil)
        #expect(device.volumeInfo(channel: 3, scope: .output) == nil)
        #expect(device.volumeInfo(channel: 4, scope: .output) == nil)

        #expect(device.volumeInfo(channel: 0, scope: .input) != nil)

        #expect(device.volumeInfo(channel: 1, scope: .input) == nil)
        #expect(device.volumeInfo(channel: 2, scope: .input) == nil)
        #expect(device.volumeInfo(channel: 3, scope: .input) == nil)
        #expect(device.volumeInfo(channel: 4, scope: .input) == nil)
    }

    @Test func testVolume() async throws {
        let device = try getNullDevice()

        // Output scope
        #expect(device.setVolume(0, channel: 0, scope: .output))
        #expect(device.volume(channel: 0, scope: .output) == 0)

        #expect(device.setVolume(0.5, channel: 0, scope: .output))
        #expect(device.volume(channel: 0, scope: .output) == 0.5)

        #expect(!device.setVolume(0.5, channel: 1, scope: .output))
        #expect(device.volume(channel: 1, scope: .output) == nil)

        #expect(!device.setVolume(0.5, channel: 2, scope: .output))
        #expect(device.volume(channel: 2, scope: .output) == nil)

        // Input scope
        #expect(device.setVolume(0, channel: 0, scope: .input))
        #expect(device.volume(channel: 0, scope: .input) == 0)

        #expect(device.setVolume(0.5, channel: 0, scope: .input))
        #expect(device.volume(channel: 0, scope: .input) == 0.5)

        #expect(!device.setVolume(0.5, channel: 1, scope: .input))
        #expect(device.volume(channel: 1, scope: .input) == nil)

        #expect(!device.setVolume(0.5, channel: 2, scope: .input))
        #expect(device.volume(channel: 2, scope: .input) == nil)
    }

    @Test func testVolumeInDecibels() async throws {
        let device = try getNullDevice()

        // Output scope
        #expect(device.canSetVolume(channel: 0, scope: .output))
        #expect(device.setVolume(0, channel: 0, scope: .output))
        #expect(device.volumeInDecibels(channel: 0, scope: .output) == -96)
        #expect(device.setVolume(0.5, channel: 0, scope: .output))
        #expect(device.volumeInDecibels(channel: 0, scope: .output) == -70.5)

        #expect(!device.canSetVolume(channel: 1, scope: .output))
        #expect(!device.setVolume(0.5, channel: 1, scope: .output))
        #expect(device.volumeInDecibels(channel: 1, scope: .output) == nil)

        #expect(!device.canSetVolume(channel: 2, scope: .output))
        #expect(!device.setVolume(0.5, channel: 2, scope: .output))
        #expect(device.volumeInDecibels(channel: 2, scope: .output) == nil)

        // Input scope
        #expect(device.canSetVolume(channel: 0, scope: .input))
        #expect(device.setVolume(0, channel: 0, scope: .input))
        #expect(device.volumeInDecibels(channel: 0, scope: .input) == -96)
        #expect(device.setVolume(0.5, channel: 0, scope: .input))
        #expect(device.volumeInDecibels(channel: 0, scope: .input) == -70.5)

        #expect(!device.canSetVolume(channel: 1, scope: .input))
        #expect(!device.setVolume(0.5, channel: 1, scope: .input))
        #expect(device.volumeInDecibels(channel: 1, scope: .input) == nil)

        #expect(!device.canSetVolume(channel: 2, scope: .input))
        #expect(!device.setVolume(0.5, channel: 2, scope: .input))
        #expect(device.volumeInDecibels(channel: 2, scope: .input) == nil)
    }

    @Test func testMute() async throws {
        let device = try getNullDevice()

        // Output scope
        #expect(device.canMute(channel: 0, scope: .output))
        #expect(device.setMute(true, channel: 0, scope: .output))
        #expect(device.isMuted(channel: 0, scope: .output) == true)
        #expect(device.setMute(false, channel: 0, scope: .output))
        #expect(device.isMuted(channel: 0, scope: .output) == false)

        #expect(!device.canMute(channel: 1, scope: .output))
        #expect(!device.setMute(true, channel: 1, scope: .output))
        #expect(device.isMuted(channel: 1, scope: .output) == nil)

        #expect(!device.canMute(channel: 2, scope: .output))
        #expect(!device.setMute(true, channel: 2, scope: .output))
        #expect(device.isMuted(channel: 2, scope: .output) == nil)

        // Input scope
        #expect(device.canMute(channel: 0, scope: .input))
        #expect(device.setMute(true, channel: 0, scope: .input))
        #expect(device.isMuted(channel: 0, scope: .input) == true)
        #expect(device.setMute(false, channel: 0, scope: .input))
        #expect(device.isMuted(channel: 0, scope: .input) == false)

        #expect(!device.canMute(channel: 1, scope: .input))
        #expect(!device.setMute(true, channel: 1, scope: .input))
        #expect(device.isMuted(channel: 1, scope: .input) == nil)

        #expect(!device.canMute(channel: 2, scope: .input))
        #expect(!device.setMute(true, channel: 2, scope: .input))
        #expect(device.isMuted(channel: 2, scope: .input) == nil)
    }

    @Test(arguments: [Scope.output, Scope.input])
    func testMainChannelMute(scope: Scope) async throws {
        let device = try getNullDevice()

        #expect(device.canMuteMainChannel(scope: scope) == true)
        #expect(device.setMute(false, channel: 0, scope: scope))
        #expect(device.isMainChannelMuted(scope: scope) == false)
        #expect(device.setMute(true, channel: 0, scope: scope))
        #expect(device.isMainChannelMuted(scope: scope) == true)

        #expect(device.canMuteMainChannel(scope: scope) == true)
        #expect(device.setMute(false, channel: 0, scope: scope))
        #expect(device.isMainChannelMuted(scope: scope) == false)
        #expect(device.setMute(true, channel: 0, scope: scope))
        #expect(device.isMainChannelMuted(scope: scope) == true)
    }

    @Test(arguments: [Scope.output, Scope.input])
    func testPreferredChannelsForStereo(scope: Scope) async throws {
        let device = try getNullDevice()
        var preferredChannels = try #require(device.preferredChannelsForStereo(scope: scope))

        #expect(preferredChannels.left == 1)
        #expect(preferredChannels.right == 2)

        #expect(device.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 1), scope: scope))
        preferredChannels = try #require(device.preferredChannelsForStereo(scope: scope))
        #expect(preferredChannels.left == 1)
        #expect(preferredChannels.right == 1)

        #expect(device.setPreferredChannelsForStereo(channels: StereoPair(left: 2, right: 2), scope: scope))
        preferredChannels = try #require(device.preferredChannelsForStereo(scope: scope))
        #expect(preferredChannels.left == 2)
        #expect(preferredChannels.right == 2)

        #expect(device.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 2), scope: scope))
        preferredChannels = try #require(device.preferredChannelsForStereo(scope: scope))
        #expect(preferredChannels.left == 1)
        #expect(preferredChannels.right == 2)
    }

    @Test(arguments: [Scope.output, Scope.input])
    func testVirtualMainVolumeOutput(scope: Scope) async throws {
        let nullDevice = try getNullDevice()

        let devices = simplyCA.allDevices.filter {
            $0 != nullDevice &&
                $0.canSetVirtualMainVolume(scope: scope)
        }

        for device in devices {
            #expect(device.setVirtualMainVolume(0.0, scope: scope))
            #expect(device.virtualMainVolume(scope: scope) == 0.0)

            var dB = try #require(device.virtualMainVolumeInDecibels(scope: scope))
            #expect(dB < 0)
            print(scope, device.name, "dB", dB)

            #expect(device.setVirtualMainVolume(0.5, scope: scope))
            #expect(device.virtualMainVolume(scope: scope)?.isApproximatelyEqual(to: 0.5, relativeTolerance: 0.001) == true)

            dB = try #require(device.virtualMainVolumeInDecibels(scope: scope))
            #expect(dB < 0)
            print(scope, device.name, "dB", dB)
        }
    }

    @Test func testVirtualMainBalance() async throws {
        let device = try getNullDevice()

        #expect(!device.canSetVirtualMainBalance(scope: .output))
        #expect(!device.canSetVirtualMainBalance(scope: .input))

        #expect(!device.setVirtualMainBalance(0.0, scope: .output))
        #expect(device.virtualMainBalance(scope: .output) == nil)

        #expect(!device.setVirtualMainBalance(0.0, scope: .input))
        #expect(device.virtualMainBalance(scope: .input) == nil)
    }

    @Test func testSampleRate() async throws {
        let device = try getNullDevice()

        #expect(device.nominalSampleRates == [44100, 48000])

        #expect(device.setNominalSampleRate(44100))
        sleep(1)
        #expect(device.nominalSampleRate == 44100)
        #expect(device.actualSampleRate == 44100)

        #expect(device.setNominalSampleRate(48000))
        sleep(1)
        #expect(device.nominalSampleRate == 48000)
        #expect(device.actualSampleRate == 48000)
    }

    @Test func testInvalidSampleRate() async throws {
        let device = try getNullDevice()

        #expect(device.nominalSampleRates == [44100, 48000])
        #expect(!device.setNominalSampleRate(24000))
        #expect(!device.setNominalSampleRate(96000))
    }

    @Test func testDataSource() async throws {
        let device = try getNullDevice()

        #expect(device.dataSource(scope: .output) != nil)
        #expect(device.dataSource(scope: .input) != nil)
    }

    @Test func testDataSources() async throws {
        let device = try getNullDevice()

        #expect(device.dataSources(scope: .output) != nil)
        #expect(device.dataSources(scope: .input) != nil)
    }

    @Test func testDataSourceName() async throws {
        let device = try getNullDevice()

        #expect(device.dataSourceName(dataSourceID: 0, scope: .output) == "Data Source Item 0")
        #expect(device.dataSourceName(dataSourceID: 1, scope: .output) == "Data Source Item 1")
        #expect(device.dataSourceName(dataSourceID: 2, scope: .output) == "Data Source Item 2")
        #expect(device.dataSourceName(dataSourceID: 3, scope: .output) == "Data Source Item 3")
        #expect(device.dataSourceName(dataSourceID: 4, scope: .output) == nil)

        #expect(device.dataSourceName(dataSourceID: 0, scope: .input) == "Data Source Item 0")
        #expect(device.dataSourceName(dataSourceID: 1, scope: .input) == "Data Source Item 1")
        #expect(device.dataSourceName(dataSourceID: 2, scope: .input) == "Data Source Item 2")
        #expect(device.dataSourceName(dataSourceID: 3, scope: .input) == "Data Source Item 3")
        #expect(device.dataSourceName(dataSourceID: 4, scope: .input) == nil)
    }

    @Test func testClockSource() async throws {
        let device = try getNullDevice()

        #expect(device.clockSourceID == nil)
        #expect(device.clockSourceIDs == nil)
        #expect(device.clockSourceName == nil)
        #expect(device.clockSourceNames == nil)
        #expect(device.clockSourceName(clockSourceID: 0) == nil)
        #expect(!device.setClockSourceID(0))
    }

    @Test func testTotalLatency() async throws {
        let device = try getNullDevice()

        #expect(device.latency(scope: .output) == 512)
        #expect(device.latency(scope: .input) == 512)
    }

    @Test func testSafetyOffset() async throws {
        let device = try getNullDevice()

        #expect(device.safetyOffset(scope: .output) == 0)
        #expect(device.safetyOffset(scope: .input) == 0)
    }

    @Test func testBufferFrameSize() async throws {
        let device = try getNullDevice()

        // The IO buffer is generally 512 by default. Also the case
        // for the NullAudio.driver
        #expect(device.bufferFrameSize(scope: .output) == 512)
        #expect(device.bufferFrameSize(scope: .input) == 512)
    }

    @Test func testHogMode() async throws {
        let device = try getNullDevice()

        #expect(device.hogModePID == -1)
        #expect(device.setHogMode())
        #expect(device.hogModePID == pid_t(ProcessInfo.processInfo.processIdentifier))
        #expect(device.unsetHogMode())
        #expect(device.hogModePID == -1)
    }

    @Test func testStreams() async throws {
        let device = try getNullDevice()

        #expect(device.streams(scope: .output) != nil)
        #expect(device.streams(scope: .input) != nil)
    }

    @Test func testCreateAndDestroyAggregateDevice() async throws {
        let nullDevice = try getNullDevice()
        let uid = "testCreateAggregateAudioDevice-12345"

        try await remove(aggregateDeviceUID: uid)

        try await Task.sleep(for: .seconds(1))

        guard let device = simplyCA.createAggregateDevice(
            mainDevice: nullDevice,
            secondDevice: nil,
            named: "testCreateAggregateAudioDevice",
            uid: uid
        ) else {
            Issue.record("Failed creating device")
            return
        }

        try await Task.sleep(for: .seconds(1))

        #expect(device.isAggregateDevice)
        #expect(device.ownedAggregateDevices?.count == 1)

        try await remove(aggregateDeviceUID: uid)

        try await Task.sleep(for: .seconds(1))
    }
}

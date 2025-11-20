// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import Numerics
@testable import SPFKAudioHardware
import SPFKBase
import Testing

@Suite(.serialized)
final class AudioDeviceTests: NullDeviceTestCase {
    @Test func deviceLookUp() async throws {
        let nullDevice = try #require(nullDevice)
        let deviceUID = try #require(nullDevice.uid)

        await #expect(AudioObjectPool.shared.lookup(id: nullDevice.id) == nullDevice)
        await #expect(AudioDevice.lookup(uid: deviceUID) == nullDevice)
        try await tearDown()
    }

    @Test(arguments: DefaultSelectorType.allCases)
    func promoteDevice(deviceType: DefaultSelectorType) async throws {
        let nullDevice = try #require(nullDevice)

        print(deviceType)

        let err = try nullDevice.promote(to: deviceType)
        #expect(noErr == err)

        let isDefaultDevice = await nullDevice.isDefaultDevice(for: deviceType)
        #expect(isDefaultDevice)

        try await wait(sec: 1)

        try await tearDown()
    }

    @Test func generalDeviceInformation() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.name == "Null Audio Device")
        #expect(nullDevice.manufacturer == "Apple Inc.")
        #expect(nullDevice.uid == "NullAudioDevice_UID")
        #expect(nullDevice.modelUID == "NullAudioDevice_ModelUID")
        #expect(nullDevice.configurationApplication == "com.apple.audio.AudioMIDISetup")
        #expect(nullDevice.transportType == .virtual)

        let isInputOnlyDevice = await nullDevice.isInputOnlyDevice
        let isOutputOnlyDevice = await nullDevice.isOutputOnlyDevice

        #expect(isInputOnlyDevice == false)
        #expect(isOutputOnlyDevice == false)
        #expect(!nullDevice.isHidden)

        #expect(nullDevice.isJackConnected(scope: .output) == nil)
        #expect(nullDevice.isJackConnected(scope: .input) == nil)

        #expect(nullDevice.isAlive)
        #expect(!nullDevice.isRunning)
        #expect(!nullDevice.isRunningSomewhere)

        await #expect(nullDevice.channels(scope: .output) == 2)
        await #expect(nullDevice.channels(scope: .input) == 2)

        #expect(nullDevice.ownedObjectIDs != nil)
        #expect(nullDevice.controlList != nil)
        await #expect(nullDevice.relatedDevices != nil)

        try await tearDown()
    }

    @Test func lfe() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.shouldOwniSub == nil)
        nullDevice.shouldOwniSub = true
        #expect(nullDevice.shouldOwniSub == nil)

        #expect(nullDevice.lfeMute == nil)
        nullDevice.lfeMute = true
        #expect(nullDevice.lfeMute == nil)

        #expect(nullDevice.lfeVolume == nil)
        nullDevice.lfeVolume = 1.0
        #expect(nullDevice.lfeVolume == nil)

        #expect(nullDevice.lfeVolumeDecibels == nil)
        nullDevice.lfeVolumeDecibels = 6.0
        #expect(nullDevice.lfeVolumeDecibels == nil)

        try await tearDown()
    }

    @Test func inputOutputLayout() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.layoutChannels(scope: .output) == 2)
        #expect(nullDevice.layoutChannels(scope: .input) == 2)

        await #expect(nullDevice.channels(scope: .output) == 2)
        await #expect(nullDevice.channels(scope: .input) == 2)

        let isInputOnlyDevice = await nullDevice.isInputOnlyDevice
        let isOutputOnlyDevice = await nullDevice.isOutputOnlyDevice

        #expect(!isInputOnlyDevice)
        #expect(!isOutputOnlyDevice)

        try await tearDown()
    }

    @Test func volumeInfo() async throws {
        let nullDevice = try #require(nullDevice)
        var volumeInfo: VolumeInfo!

        #expect(nullDevice.setMute(false, channel: 0, scope: .output))

        volumeInfo = nullDevice.volumeInfo(channel: 0, scope: .output)
        #expect(volumeInfo.hasVolume == true)
        #expect(volumeInfo.canSetVolume == true)
        #expect(volumeInfo.canMute == true)
        #expect(volumeInfo.isMuted == false)
        #expect(volumeInfo.canPlayThru == false)
        #expect(volumeInfo.isPlayThruSet == false)

        #expect(nullDevice.setVolume(0, channel: 0, scope: .output))
        volumeInfo = nullDevice.volumeInfo(channel: 0, scope: .output)
        #expect(volumeInfo.volume == 0)

        #expect(nullDevice.setVolume(0.5, channel: 0, scope: .output))
        volumeInfo = nullDevice.volumeInfo(channel: 0, scope: .output)
        #expect(volumeInfo.volume == 0.5)

        #expect(nullDevice.volumeInfo(channel: 1, scope: .output) == nil)
        #expect(nullDevice.volumeInfo(channel: 2, scope: .output) == nil)
        #expect(nullDevice.volumeInfo(channel: 3, scope: .output) == nil)
        #expect(nullDevice.volumeInfo(channel: 4, scope: .output) == nil)

        #expect(nullDevice.volumeInfo(channel: 0, scope: .input) != nil)
        #expect(nullDevice.volumeInfo(channel: 1, scope: .input) == nil)
        #expect(nullDevice.volumeInfo(channel: 2, scope: .input) == nil)
        #expect(nullDevice.volumeInfo(channel: 3, scope: .input) == nil)
        #expect(nullDevice.volumeInfo(channel: 4, scope: .input) == nil)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func volume(scopeToTest: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.setVolume(0, channel: 0, scope: scopeToTest))
        #expect(nullDevice.volume(channel: 0, scope: scopeToTest) == 0)

        #expect(nullDevice.setVolume(0.5, channel: 0, scope: scopeToTest))
        #expect(nullDevice.volume(channel: 0, scope: scopeToTest) == 0.5)

        #expect(!nullDevice.setVolume(0.5, channel: 1, scope: scopeToTest))
        #expect(nullDevice.volume(channel: 1, scope: scopeToTest) == nil)

        #expect(!nullDevice.setVolume(0.5, channel: 2, scope: .output))
        #expect(nullDevice.volume(channel: 2, scope: scopeToTest) == nil)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func volumeInDecibels(scopeToTest: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.canSetVolume(channel: 0, scope: scopeToTest))
        #expect(nullDevice.setVolume(0, channel: 0, scope: scopeToTest))
        #expect(nullDevice.volumeInDecibels(channel: 0, scope: scopeToTest) == -96)
        #expect(nullDevice.setVolume(0.5, channel: 0, scope: scopeToTest))
        #expect(nullDevice.volumeInDecibels(channel: 0, scope: scopeToTest) == -70.5)

        #expect(!nullDevice.canSetVolume(channel: 1, scope: scopeToTest))
        #expect(!nullDevice.setVolume(0.5, channel: 1, scope: scopeToTest))
        #expect(nullDevice.volumeInDecibels(channel: 1, scope: scopeToTest) == nil)

        #expect(!nullDevice.canSetVolume(channel: 2, scope: scopeToTest))
        #expect(!nullDevice.setVolume(0.5, channel: 2, scope: scopeToTest))
        #expect(nullDevice.volumeInDecibels(channel: 2, scope: scopeToTest) == nil)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func mute(scopeToTest: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.canMute(channel: 0, scope: scopeToTest))
        #expect(nullDevice.setMute(true, channel: 0, scope: scopeToTest))
        #expect(nullDevice.isMuted(channel: 0, scope: scopeToTest) == true)
        #expect(nullDevice.setMute(false, channel: 0, scope: scopeToTest))
        #expect(nullDevice.isMuted(channel: 0, scope: scopeToTest) == false)

        #expect(!nullDevice.canMute(channel: 1, scope: scopeToTest))
        #expect(!nullDevice.setMute(true, channel: 1, scope: scopeToTest))
        #expect(nullDevice.isMuted(channel: 1, scope: scopeToTest) == nil)

        #expect(!nullDevice.canMute(channel: 2, scope: scopeToTest))
        #expect(!nullDevice.setMute(true, channel: 2, scope: scopeToTest))
        #expect(nullDevice.isMuted(channel: 2, scope: scopeToTest) == nil)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func mainChannelMute(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.canMuteMainChannel(scope: scope) == true)
        #expect(nullDevice.setMute(false, channel: 0, scope: scope))
        #expect(nullDevice.isMainChannelMuted(scope: scope) == false)
        #expect(nullDevice.setMute(true, channel: 0, scope: scope))
        #expect(nullDevice.isMainChannelMuted(scope: scope) == true)

        #expect(nullDevice.canMuteMainChannel(scope: scope) == true)
        #expect(nullDevice.setMute(false, channel: 0, scope: scope))
        #expect(nullDevice.isMainChannelMuted(scope: scope) == false)
        #expect(nullDevice.setMute(true, channel: 0, scope: scope))
        #expect(nullDevice.isMainChannelMuted(scope: scope) == true)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func preferredChannelsForStereo(scope: Scope) async throws {
        let nullDevice = try #require(nullDevice)
        var preferredChannels = try #require(nullDevice.preferredChannelsForStereo(scope: scope))

        #expect(preferredChannels.left == 1)
        #expect(preferredChannels.right == 2)

        #expect(nullDevice.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 1), scope: scope))
        preferredChannels = try #require(nullDevice.preferredChannelsForStereo(scope: scope))

        #expect(preferredChannels.left == 1)
        #expect(preferredChannels.right == 1)

        #expect(nullDevice.setPreferredChannelsForStereo(channels: StereoPair(left: 2, right: 2), scope: scope))
        preferredChannels = try #require(nullDevice.preferredChannelsForStereo(scope: scope))

        #expect(preferredChannels.left == 2)
        #expect(preferredChannels.right == 2)

        #expect(nullDevice.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 2), scope: scope))
        preferredChannels = try #require(nullDevice.preferredChannelsForStereo(scope: scope))
        #expect(preferredChannels.left == 1)
        #expect(preferredChannels.right == 2)

        try await tearDown()
    }

    @Test(arguments: [Scope.output, Scope.input])
    func virtualMainVolumeOutput(scope: Scope) async throws {
        let devices = await hardwareManager.allDevices.filter {
            $0.canSetVirtualMainVolume(scope: scope)
        }

        for device in devices {
            #expect(device.setVirtualMainVolume(0.0, scope: scope))
            #expect(device.virtualMainVolume(scope: scope) == 0.0)

            guard let dB = device.virtualMainVolumeInDecibels(scope: scope) else {
                Log.error("Failed virtualMainVolumeInDecibels for", device.name)
                continue
            }

            Log.debug(dB, "for", device.name, scope)
            
            #expect(dB < 0)

            #expect(device.setVirtualMainVolume(0.5, scope: scope))
            let virtualMainVolume = try #require(device.virtualMainVolume(scope: scope))

            #expect(
                virtualMainVolume.isApproximatelyEqual(to: 0.5, relativeTolerance: 0.001) == true,
                "virtualMainVolume is \(virtualMainVolume) for \(device.name) \(scope)"
            )

            let dB2 = try #require(device.virtualMainVolumeInDecibels(scope: scope))
            #expect(dB2 < 0)
        }

        try await tearDown()
    }

    @Test func virtualMainBalance() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(!nullDevice.canSetVirtualMainBalance(scope: .output))
        #expect(!nullDevice.canSetVirtualMainBalance(scope: .input))

        #expect(!nullDevice.setVirtualMainBalance(0.0, scope: .output))
        #expect(nullDevice.virtualMainBalance(scope: .output) == nil)

        #expect(!nullDevice.setVirtualMainBalance(0.0, scope: .input))
        #expect(nullDevice.virtualMainBalance(scope: .input) == nil)

        try await tearDown()
    }

    @Test func sampleRate() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.nominalSampleRates == [44100, 48000])

        #expect(nullDevice.setNominalSampleRate(44100))
        try await wait(sec: 1)

        #expect(nullDevice.nominalSampleRate == 44100)
        #expect(nullDevice.actualSampleRate == 44100)

        #expect(nullDevice.setNominalSampleRate(48000))
        try await wait(sec: 1)

        #expect(nullDevice.nominalSampleRate == 48000)
        #expect(nullDevice.actualSampleRate == 48000)

        try await tearDown()
    }

    @Test func invalidSampleRate() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.nominalSampleRates == [44100, 48000])
        #expect(!nullDevice.setNominalSampleRate(24000))
        #expect(!nullDevice.setNominalSampleRate(96000))

        try await tearDown()
    }

    @Test func dataSource() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.dataSource(scope: .output) != nil)
        #expect(nullDevice.dataSource(scope: .input) != nil)

        try await tearDown()
    }

    @Test func dataSources() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.dataSources(scope: .output) != nil)
        #expect(nullDevice.dataSources(scope: .input) != nil)

        try await tearDown()
    }

    @Test func dataSourceName() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.dataSourceName(dataSourceID: 0, scope: .output) == "Data Source Item 0")
        #expect(nullDevice.dataSourceName(dataSourceID: 1, scope: .output) == "Data Source Item 1")
        #expect(nullDevice.dataSourceName(dataSourceID: 2, scope: .output) == "Data Source Item 2")
        #expect(nullDevice.dataSourceName(dataSourceID: 3, scope: .output) == "Data Source Item 3")
        #expect(nullDevice.dataSourceName(dataSourceID: 4, scope: .output) == nil)

        #expect(nullDevice.dataSourceName(dataSourceID: 0, scope: .input) == "Data Source Item 0")
        #expect(nullDevice.dataSourceName(dataSourceID: 1, scope: .input) == "Data Source Item 1")
        #expect(nullDevice.dataSourceName(dataSourceID: 2, scope: .input) == "Data Source Item 2")
        #expect(nullDevice.dataSourceName(dataSourceID: 3, scope: .input) == "Data Source Item 3")
        #expect(nullDevice.dataSourceName(dataSourceID: 4, scope: .input) == nil)

        try await tearDown()
    }

    @Test func clockSource() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.clockSourceID == nil)
        #expect(nullDevice.clockSourceIDs == nil)
        #expect(nullDevice.clockSourceName == nil)
        #expect(nullDevice.clockSourceNames == nil)
        #expect(nullDevice.clockSourceName(clockSourceID: 0) == nil)
        #expect(!nullDevice.setClockSourceID(0))

        try await tearDown()
    }

    @Test func totalLatency() async throws {
        let nullDevice = try #require(nullDevice)

        await #expect(nullDevice.latency(scope: .output) == 512)
        await #expect(nullDevice.latency(scope: .input) == 512)

        try await tearDown()
    }

    @Test func safetyOffset() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.safetyOffset(scope: .output) == 0)
        #expect(nullDevice.safetyOffset(scope: .input) == 0)

        try await tearDown()
    }

    @Test func bufferFrameSize() async throws {
        let nullDevice = try #require(nullDevice)

        // The IO buffer is generally 512 by default. Also the case
        // for the NullAudio.driver
        #expect(nullDevice.bufferFrameSize(scope: .output) == 512)
        #expect(nullDevice.bufferFrameSize(scope: .input) == 512)

        try await tearDown()
    }

    @Test func hogMode() async throws {
        let nullDevice = try #require(nullDevice)

        #expect(nullDevice.hogModePID == -1)
        #expect(nullDevice.setHogMode())
        #expect(nullDevice.hogModePID == pid_t(ProcessInfo.processInfo.processIdentifier))
        #expect(nullDevice.unsetHogMode())
        #expect(nullDevice.hogModePID == -1)

        try await tearDown()
    }

    @Test func streams() async throws {
        let nullDevice = try #require(nullDevice)

        await #expect(nullDevice.streams(scope: .output)?.count == 1)
        await #expect(nullDevice.streams(scope: .input)?.count == 1)

        try await tearDown()
    }
}

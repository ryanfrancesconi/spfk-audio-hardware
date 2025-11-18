// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
@testable import SPFKAudioHardware
import SPFKBase
import Testing

class NullDeviceTestCase: SCATestCase {
    let nullDevice_name = "Null Audio Device"
    let nullDevice_manufacturer = "Apple Inc."
    let nullDevice_uid = "NullAudioDevice_UID"
    let nullDevice_modelUID = "NullAudioDevice_ModelUID"
    let nullDevice_configurationApplication = "com.apple.audio.AudioMIDISetup"

    var nullDevice: AudioDevice?

    override public init() async throws {
        try await super.init()
        nullDevice = await AudioDevice.lookup(by: nullDevice_uid)
        try await resetNullDeviceState()
    }

    override func tearDown() async throws {
        try await resetNullDeviceState()

        try await super.tearDown()
        // try await wait(sec: 0.5)
        Log.debug("tearDown complete")
    }
    
    deinit {
        Log.debug("- { NullDeviceTestCase }")
    }

    func resetNullDeviceState() async throws {
        let nullDevice = try #require(nullDevice)

        nullDevice.unsetHogMode()

        if nullDevice.nominalSampleRate != 44100 {
            nullDevice.setNominalSampleRate(44100)
        }

        nullDevice.setPreferredChannelsForStereo(channels: StereoPair(left: 1, right: 2), scope: .output)
        nullDevice.setMute(false, channel: 0, scope: .output)
        nullDevice.setMute(false, channel: 0, scope: .input)
        nullDevice.setVolume(0.5, channel: 0, scope: .output)
        nullDevice.setVolume(0.5, channel: 0, scope: .input)
        nullDevice.setVirtualMainVolume(0.5, scope: .output)
        nullDevice.setVirtualMainVolume(0.5, scope: .input)
    }
}

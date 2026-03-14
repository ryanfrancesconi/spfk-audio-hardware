// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import SPFKBase
import Testing

@testable import SPFKAudioHardware

@Suite(.serialized, .tags(.hardware))
final class DefaultAudioDeviceTests: AudioHardwareTestCase {
    @Test(arguments: [Scope.output, Scope.input])
    func preferredChannelsForStereoAllDevices(scope: Scope) async throws {
        let devices = try await hardwareManager.allDevices()

        #expect(devices.isNotEmpty, "Should have at least one audio device")

        for device in devices {
            let preferredChannels = device.preferredChannelsForStereo(scope: scope)

            if let preferredChannels {
                #expect(preferredChannels.left > 0, "\(device.name) left channel should be > 0")
                #expect(preferredChannels.right > 0, "\(device.name) right channel should be > 0")
            }

            Log.debug(device.name, preferredChannels)
        }
    }
}

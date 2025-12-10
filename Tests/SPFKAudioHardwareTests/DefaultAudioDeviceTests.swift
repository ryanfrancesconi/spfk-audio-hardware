// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
import SPFKBase
import Testing

@testable import SPFKAudioHardware

@Suite(.serialized)
final class DefaultAudioDeviceTests: AudioHardwareTestCase {
    @Test(arguments: [Scope.output, Scope.input])
    func preferredChannelsForStereoAllDevices(scope: Scope) async throws {
        let devices = try await hardwareManager.allDevices()

        for device in devices {
            let preferredChannels = device.preferredChannelsForStereo(scope: scope)

            Log.debug(device.name, preferredChannels)
        }
    }
}

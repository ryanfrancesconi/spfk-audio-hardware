// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation
@testable import SPFKAudioHardware
import Testing

@Suite(.serialized)
final class AudioDeviceAsyncTests: NullDeviceTestCase {
    @Test(arguments: [48000])
    func sampleRateDidChangeNotification(targetSampleRate: Float64) async throws {
        let nullDevice = try #require(nullDevice)

        try await nullDevice.update(sampleRate: targetSampleRate)
        #expect(targetSampleRate == nullDevice.nominalSampleRate)
        
        try await tearDown()
    }
}

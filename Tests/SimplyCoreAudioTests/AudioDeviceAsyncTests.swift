// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation
@testable import SimplyCoreAudio
import Testing

@Suite(.serialized)
final class AudioDeviceAsyncTests: SCATestCase {
    @Test(arguments: [48000])
    func sampleRateDidChangeNotification(targetSampleRate: Float64) async throws {
        let device = try getNullDevice()
        try await device.update(sampleRate: targetSampleRate)

        #expect(targetSampleRate == device.nominalSampleRate)
    }
}

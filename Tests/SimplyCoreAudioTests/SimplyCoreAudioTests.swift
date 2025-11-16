// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

@testable import SimplyCoreAudio
import Testing

@Suite(.serialized)
class SimplyCoreAudioTests: SCATestCase {
    @Test func testDeviceEnumeration() throws {
        let device = try getNullDevice()

        #expect(simplyCA.allDevices.contains(device))
        #expect(simplyCA.allDeviceIDs.contains(device.id))
        #expect(simplyCA.allInputDevices.contains(device))
        #expect(simplyCA.allOutputDevices.contains(device))
        #expect(simplyCA.allIODevices.contains(device))
        #expect(simplyCA.allNonAggregateDevices.contains(device))
        #expect(!simplyCA.allAggregateDevices.contains(device))
    }
}

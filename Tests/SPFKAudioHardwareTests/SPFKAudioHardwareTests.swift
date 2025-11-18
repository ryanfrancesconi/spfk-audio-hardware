// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

@testable import SPFKAudioHardware
import SPFKBase
import Testing

@Suite(.serialized)
class AudioHardwareManagerTests: NullDeviceTestCase {
    @Test func testMultipleInstances() async throws {
        var hm1: AudioHardwareManager? = await AudioHardwareManager()
        Log.debug(hm1)

        var hm2: AudioHardwareManager? = await AudioHardwareManager()
        Log.debug(hm2)

        var hm3: AudioHardwareManager? = await AudioHardwareManager()
        Log.debug(hm3)

        hm1 = nil
        hm2 = nil
        hm3 = nil
    }

    @Test func testDeviceEnumeration() async throws {
        let nullDevice = try #require(nullDevice)

        await #expect(hardware.allDevices.contains(nullDevice))
        await #expect(hardware.allDeviceIDs.contains(nullDevice.id))
        await #expect(hardware.allInputDevices.contains(nullDevice))
        await #expect(hardware.allOutputDevices.contains(nullDevice))
        await #expect(hardware.allIODevices.contains(nullDevice))
        await #expect(hardware.allNonAggregateDevices.contains(nullDevice))
        await #expect(hardware.allAggregateDevices.contains(nullDevice) == false)
    }
}

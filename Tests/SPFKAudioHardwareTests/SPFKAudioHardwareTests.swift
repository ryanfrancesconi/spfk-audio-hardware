// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
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

        let aggregateDevice = try await createAggregateDevice(in: 0.3)

        let allDevices = await hardware.allDevices
        let allDeviceIDs = await hardware.allDeviceIDs
        let allInputDevices = await hardware.allInputDevices
        let allOutputDevices = await hardware.allOutputDevices
        let allIODevices = await hardware.allIODevices
        let allNonAggregateDevices = await hardware.allNonAggregateDevices
        let allAggregateDevices = await hardware.allAggregateDevices

        Log.debug("allDevices", allDevices)
        Log.debug("allInputDevices", allInputDevices)
        Log.debug("allOutputDevices", allOutputDevices)
        Log.debug("allIODevices", allIODevices)
        Log.debug("allNonAggregateDevices", allNonAggregateDevices)
        Log.debug("allAggregateDevices", allAggregateDevices)

        #expect(allDevices.contains(nullDevice))
        #expect(allDeviceIDs.contains(nullDevice.id))
        #expect(allInputDevices.contains(nullDevice))
        #expect(allOutputDevices.contains(nullDevice))
        #expect(allIODevices.contains(nullDevice))
        #expect(allNonAggregateDevices.contains(nullDevice))
        #expect(allAggregateDevices.contains(nullDevice) == false)

        if let aggregateDevice {
            #expect(allAggregateDevices.contains(aggregateDevice))

            #expect(noErr == hardware.removeAggregateDevice(id: aggregateDevice.id))
        }
    }
}

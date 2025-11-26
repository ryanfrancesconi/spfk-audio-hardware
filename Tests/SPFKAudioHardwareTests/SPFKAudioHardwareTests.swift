// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
@testable import SPFKAudioHardware
import SPFKBase
import Testing

@Suite(.serialized)
class AudioHardwareManagerTests: NullDeviceTestCase {
    @Test func allDevices() async throws {
        let allDevices = await hardwareManager.allDevices

        Log.debug("Found", allDevices.count, "devices: ", allDevices)

        try await tearDown()
    }

    @Test(arguments: [Scope.input, Scope.output])
    func splitDevices(scope: Scope) async throws {
        let devices = await hardwareManager.splitDevices

        for device in devices {
            let sampleRates = device.getNominalSampleRates(scope: scope) ?? []

            Log.debug(scope, device.name, "(\(device.objectID(scope: scope)))", sampleRates)

            for sampleRate in sampleRates {
                do {
                    try await device.device(scope: scope).updateAndWait(sampleRate: sampleRate)
                } catch {
                    Log.error(error)
                }
            }
        }

        try await tearDown()
    }

    @Test func deviceEnumeration() async throws {
        let nullDevice = try #require(nullDevice)

        let aggregateDevice = try await createAggregateDevice(in: 0.3)

        let allDevices = await hardwareManager.allDevices
        let allDeviceIDs = await hardwareManager.allDeviceIDs
        let allInputDevices = await hardwareManager.inputDevices
        let allOutputDevices = await hardwareManager.outputDevices
        let allIODevices = await hardwareManager.allIODevices
        let allNonAggregateDevices = await hardwareManager.allNonAggregateDevices
        let allAggregateDevices = await hardwareManager.allAggregateDevices

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

        #expect(allAggregateDevices.contains(aggregateDevice))

        let status = await hardwareManager.removeAggregateDevice(id: aggregateDevice.id)
        #expect(kAudioHardwareNoError == status)

        try await tearDown()
    }
}

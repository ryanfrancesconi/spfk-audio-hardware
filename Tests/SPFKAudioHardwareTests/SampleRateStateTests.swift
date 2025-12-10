// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase
import Testing

@testable import SPFKAudioHardware

@Suite(.serialized)
final class SampleRateStateTests: NullDeviceTestCase {
    @Test(arguments: [44100, 48000])
    func updateAndWait(sampleRate: Float64) async throws {
        let nullDevice = try #require(nullDevice)

        try await nullDevice.sampleRateUpdater.updateAndWait(sampleRate: sampleRate)

        #expect(sampleRate == nullDevice.nominalSampleRate)

        try await tearDown()
    }

    @Test(arguments: [22050, 96000])
    func verifyInvalidThrows(sampleRate: Float64) async throws {
        let nullDevice = try #require(nullDevice)

        do {
            try await nullDevice.sampleRateUpdater.updateAndWait(sampleRate: sampleRate)
        } catch {
            Log.debug("✅", error)
            #expect(error.localizedDescription.contains("doesn't support \(sampleRate)"))
        }

        try await tearDown()
    }

    @Test func mutableState() async throws {
        let outputDevices = try await hardwareManager.outputDevices()

        guard let device = outputDevices.filter({
            guard let rates = $0.nominalSampleRates else { return false }
            return rates.count > 3
        }).first else { return }

        let currentSampleRate = try #require(device.nominalSampleRate)
        let testRates = try #require(device.nominalSampleRates).filter { $0 != currentSampleRate }

        Log.debug("Testing \(device.nameAndID) at \(currentSampleRate), supports \(device.nominalSampleRates ?? [])")

        await withTaskGroup { taskGroup in
            for sampleRate in testRates {
                taskGroup.addTask {
                    do {
                        try await device.sampleRateUpdater.updateAndWait(sampleRate: sampleRate)
                    } catch {
                        Log.error(error)
                    }
                }
            }
        }

        try await device.sampleRateUpdater.updateAndWait(sampleRate: currentSampleRate)

        try await tearDown()
    }
}

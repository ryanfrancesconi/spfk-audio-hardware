// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import AsyncAlgorithms
import CoreAudio
import Foundation
import SPFKBase
import SwiftExtensions

actor AudioDeviceCache {
    var cachedDevices = [AudioDevice]()

    var allDeviceIDs: [AudioObjectID] {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain,
        )

        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        var allIDs = [AudioObjectID]()

        let status = AudioDevice.getPropertyDataArray(
            systemObjectID,
            address: address,
            value: &allIDs,
            andDefaultValue: 0,
        )

        return noErr == status ? allIDs : []
    }

    var allDevices: [AudioDevice] {
        get async {
            let ids = allDeviceIDs

            let allDevices: [AudioDevice] = await ids.async.compactMap {
                await AudioObjectPool.shared.lookup(id: $0)
            }.toArray()

            return allDevices
        }
    }
}

extension AudioDeviceCache {
    func start() async throws {
        try await updateKnownDevices(
            DeviceStatusEvent(addedDevices: allDevices),
        )
    }

    func stop() async throws {
        try await updateKnownDevices(
            DeviceStatusEvent(removedDevices: cachedDevices),
        )
    }

    func unregister() async throws {
        // Log.debug("unregister", cachedDevices.count, "devices")

        try await stop()

        cachedDevices.removeAll()

        try await AudioObjectPool.shared.removeAll()
    }

    func update() async throws -> DeviceStatusEvent {
        let latestDeviceList = await allDevices

        // compare added and removed devices.
        var addedDevices: [AudioDevice] = []
        var removedDevices: [AudioDevice] = []

        addedDevices = latestDeviceList.filter { !cachedDevices.contains($0) }
        removedDevices = cachedDevices.filter { !latestDeviceList.contains($0) }

        guard removedDevices.isNotEmpty || addedDevices.isNotEmpty else {
            throw NSError(description: "No changes detected")
        }

        let status = DeviceStatusEvent(
            addedDevices: addedDevices,
            removedDevices: removedDevices,
        )

        // Add new devices & remove old ones.
        try await updateKnownDevices(status)

        // Log.debug("+added \(addedDevices.count) -removed \(removedDevices.count)")

        return status
    }

    private func updateKnownDevices(_ devices: DeviceStatusEvent) async throws {
        cachedDevices.append(contentsOf: devices.addedDevices)
        cachedDevices.removeAll { devices.removedDevices.contains($0) }

        // Log.debug("Removing", devices.removedDevices.count, "devices...")
        for device in devices.removedDevices {
            try await AudioObjectPool.shared.remove(device.id)
        }

        if cachedDevices.count > 0 {
            await AudioObjectPool.shared.startListening()
        }
    }
}

extension AudioDeviceCache {
    var inputDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                await $0.physicalChannels(scope: .input) > 0
            }.toArray()
        }
    }

    var outputDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                await $0.physicalChannels(scope: .output) > 0
            }.toArray()
        }
    }

    var allIODevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                let hasInput = await $0.physicalChannels(scope: .input) > 0
                let hasOutput = await $0.physicalChannels(scope: .output) > 0

                return hasInput && hasOutput
            }.toArray()
        }
    }

    var nonAggregateDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                guard let classID = $0.classID else { return false }
                let isNotAggregate = await !$0.isAggregateDevice

                return AudioDevice.isSupported(classID: classID)
                    && isNotAggregate

            }.toArray()
        }
    }

    var aggregateDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter { await $0.isAggregateDevice }
                .toArray()
        }
    }

    var bluetoothDevices: [AudioDevice] {
        get async {
            await allDevices.filter { $0.transportType == .bluetooth }
        }
    }

    /// Search for input and output devices that have matching `modelUID` values such
    /// as for bluetooth headphones that have an integrated mic which is registered as
    /// a different device.
    var splitDevices: [SplitAudioDevice] {
        get async {
            var out = [SplitAudioDevice]()

            let allDevices = await allDevices

            let modelUIDs = allDevices.compactMap(\.modelUID)
                .removingDuplicates()

            for modelUIDs in modelUIDs {
                let matches = allDevices.filter { $0.modelUID == modelUIDs }

                let input = await matches.async.first {
                    await $0.isInputOnlyDevice
                }
                let output = await matches.async.first {
                    await $0.isOutputOnlyDevice
                }

                if let input, let output,
                   let device = try? SplitAudioDevice(
                       input: input,
                       output: output,
                   )
                {
                    out.append(device)
                }
            }
            return out
        }
    }
}

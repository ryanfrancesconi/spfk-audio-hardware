// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import AsyncAlgorithms
import CoreAudio
import Foundation
import SPFKBase
import SwiftExtensions

actor AudioDeviceCache {
    var cachedDevices = [AudioDevice]()

    func allDeviceIDs() throws -> [AudioObjectID] {
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

        guard noErr == status else {
            throw NSError(description: "Failed to get allDeviceIDs with status (\(status.fourCC))")
        }

        return allIDs
    }
}

extension AudioDeviceCache {
    func start() async throws {
        let devices = try await allDevices()

        try await updateKnownDevices(
            DeviceStatusEvent(addedDevices: devices),
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

        await AudioObjectPool.shared.removeAll()
    }

    func update() async throws -> DeviceStatusEvent {
        let latestDeviceList = try await allDevices()

        Log.debug("🔊 \(cachedDevices.count) latestDeviceList: ", latestDeviceList.map(\.objectID).sorted())
        Log.debug("🔈 \(cachedDevices.count) cachedDevices: ", cachedDevices.map(\.objectID).sorted())

        // compare added and removed devices.

        let addedDevices: [AudioDevice] = latestDeviceList.filter { !cachedDevices.contains($0) }
        let removedDevices: [AudioDevice] = cachedDevices.filter { !latestDeviceList.contains($0) }

        guard removedDevices.isNotEmpty || addedDevices.isNotEmpty else {
            throw NSError(description: "No changes detected...")
        }

        let status = DeviceStatusEvent(
            addedDevices: addedDevices,
            removedDevices: removedDevices,
        )

        // Add new devices & remove old ones.
        try await updateKnownDevices(status)

        Log.debug("✅ added \(addedDevices.map(\.nameAndID))) ⛔️ removed \(removedDevices.map(\.nameAndID))")

        return status
    }

    private func updateKnownDevices(_ event: DeviceStatusEvent) async throws {
        cachedDevices.append(contentsOf: event.addedDevices)
        cachedDevices.removeAll { event.removedDevices.contains($0) }

        // Log.debug("Removing", devices.removedDevices.count, "devices...")
        for device in event.removedDevices {
            await AudioObjectPool.shared.remove(device.id)
        }

        if cachedDevices.count > 0 {
            await AudioObjectPool.shared.startListening()
        }

        Log.debug("🔈 updated \(cachedDevices.count) cachedDevice: ", cachedDevices.map(\.objectID).sorted())
    }
}

extension AudioDeviceCache {}

extension AudioDeviceCache {
    func allDevices() async throws -> [AudioDevice] {
        let ids = try allDeviceIDs()

        var out = [AudioDevice]()

        for id in ids {
            do {
                let device: AudioDevice = try await AudioObjectPool.shared.lookup(id: id)
                out.append(device)
            } catch {
                Log.error(error)
            }
        }

        assert(ids.count == out.count)

        return out
    }

    func inputDevices() async throws -> [AudioDevice] {
        let devices = try await allDevices()

        return await devices.async.filter {
            await $0.physicalChannels(scope: .input) > 0
        }.toArray()
    }

    func outputDevices() async throws -> [AudioDevice] {
        let devices = try await allDevices()

        return await devices.async.filter {
            await $0.physicalChannels(scope: .output) > 0
        }.toArray()
    }

    func allIODevices() async throws -> [AudioDevice] {
        let devices = try await allDevices()

        return await devices.async.filter {
            let hasInput = await $0.physicalChannels(scope: .input) > 0
            let hasOutput = await $0.physicalChannels(scope: .output) > 0

            return hasInput && hasOutput
        }.toArray()
    }

    func nonAggregateDevices() async throws -> [AudioDevice] {
        let devices = try await allDevices()

        return await devices.async.filter {
            guard let classID = $0.classID else { return false }
            let isNotAggregate = await !$0.isAggregateDevice

            return AudioDevice.isSupported(classID: classID)
                && isNotAggregate

        }.toArray()
    }

    func aggregateDevices() async throws -> [AudioDevice] {
        let devices = try await allDevices()

        return await devices.async.filter { await $0.isAggregateDevice }
            .toArray()
    }

    func bluetoothDevices() async throws -> [AudioDevice] {
        let devices = try await allDevices()

        return devices.filter { $0.transportType == .bluetooth }
    }

    /// Search for input and output devices that have matching `modelUID` values such
    /// as for bluetooth headphones that have an integrated mic which is registered as
    /// a different device.
    func splitDevices() async throws -> [SplitAudioDevice] {
        var out = [SplitAudioDevice]()

        let devices = try await allDevices()

        let modelUIDs = devices.compactMap(\.modelUID)
            .removingDuplicates()

        for modelUIDs in modelUIDs {
            let matches = devices.filter { $0.modelUID == modelUIDs }

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

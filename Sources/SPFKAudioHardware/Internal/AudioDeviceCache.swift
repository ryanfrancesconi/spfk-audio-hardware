// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import AsyncAlgorithms
import CoreAudio
import Foundation
import SPFKBase

actor AudioDeviceCache {
    var cachedDevices = [AudioDevice]()

    var allDeviceIDs: [AudioObjectID] {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: Element.main.propertyElement
        )

        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        var allIDs = [AudioObjectID]()

        let status = AudioDevice.getPropertyDataArray(
            systemObjectID,
            address: address,
            value: &allIDs,
            andDefaultValue: 0
        )

        return noErr == status ? allIDs : []
    }

    var allDevices: [AudioDevice] {
        get async {
            let ids = allDeviceIDs

            let allDevices: [AudioDevice] = await ids.async.compactMap {
                await AudioObjectPool.shared.lookup(by: $0)
            }.toArray()

            return allDevices
        }
    }
}

extension AudioDeviceCache {
    func unregister() async throws {
        Log.debug("unregister", cachedDevices.count, "devices")

        try await stop()

        cachedDevices.removeAll()

        try await AudioObjectPool.shared.removeAll()
    }

    func update() async throws -> DeviceStatusEvent {
        let latestDeviceList = await allDevices

        // Obtain added and removed devices.
        var addedDevices: [AudioDevice] = []
        var removedDevices: [AudioDevice] = []

        addedDevices = latestDeviceList.filter { !cachedDevices.contains($0) }
        removedDevices = cachedDevices.filter { !latestDeviceList.contains($0) }

        let status = DeviceStatusEvent(addedDevices: addedDevices, removedDevices: removedDevices)

        try Task.checkCancellation()

        // Add new devices & remove old ones.
        try await updateKnownDevices(status)

        Log.debug("+added \(addedDevices.count) -removed \(removedDevices.count)")

        return status
    }

    private func updateKnownDevices(_ devices: DeviceStatusEvent) async throws {
        cachedDevices.append(contentsOf: devices.addedDevices)
        cachedDevices.removeAll { devices.removedDevices.contains($0) }

        Log.debug("Removing", devices.removedDevices.count, "devices...")
        for device in devices.removedDevices {
            try await AudioObjectPool.shared.remove(device.id)
        }

        if cachedDevices.count > 0 {
            await AudioObjectPool.shared.startListening()
        }
    }

    func start() async throws {
        try await updateKnownDevices(DeviceStatusEvent(addedDevices: allDevices))
    }

    func stop() async throws {
        try await updateKnownDevices(DeviceStatusEvent(removedDevices: cachedDevices))
    }
}

extension AudioDeviceCache {
    var allInputDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                await $0.channels(scope: .input) > 0
            }.toArray()
        }
    }

    var allOutputDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter { await $0.channels(scope: .output) > 0 }.toArray()
        }
    }

    var allIODevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                let hasInput = await $0.channels(scope: .input) > 0
                let hasOutput = await $0.channels(scope: .output) > 0

                return hasInput && hasOutput
            }.toArray()
        }
    }

    var allNonAggregateDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter {
                guard let classID = $0.classID else { return false }
                let isNotAggregate = await !$0.isAggregateDevice

                return AudioDevice.isSupported(classID: classID) && isNotAggregate

            }.toArray()
        }
    }

    var allAggregateDevices: [AudioDevice] {
        get async {
            await allDevices.async.filter { await $0.isAggregateDevice }.toArray()
        }
    }
}

extension AudioDeviceCache {
    var defaultInputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .defaultInput)
        }
    }

    var defaultOutputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .defaultOutput)
        }
    }

    var defaultSystemOutputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .alertOutput)
        }
    }
}

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
            await allDeviceIDs.async.compactMap {
                await AudioDevice.lookup(by: $0)
            }.toArray()
        }
    }
}

extension AudioDeviceCache {
    func unregisterKnownDevices() async {
        let allDevices = await allDevices

        Log.debug("unregister", allDevices.count, "devices")

        for device in allDevices {
            await device.stopListening()
        }
    }

    func update() async -> DeviceStatusEvent {
        // Obtain added and removed devices.
        var addedDevices: [AudioDevice] = []
        var removedDevices: [AudioDevice] = []

        let latestDeviceList = await allDevices

        addedDevices = latestDeviceList.filter { !cachedDevices.contains($0) }
        removedDevices = cachedDevices.filter { !latestDeviceList.contains($0) }

        let status = DeviceStatusEvent(addedDevices: addedDevices, removedDevices: removedDevices)

        // Add new devices & remove old ones.
        updateKnownDevices(status)

        return status
    }

    func updateKnownDevices(_ devices: DeviceStatusEvent) {
        cachedDevices.append(contentsOf: devices.addedDevices)
        cachedDevices.removeAll { devices.removedDevices.contains($0) }
    }

    func start() async {
        await updateKnownDevices(DeviceStatusEvent(addedDevices: allDevices))
    }

    func stop() {
        updateKnownDevices(DeviceStatusEvent(removedDevices: cachedDevices))
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
            await allDevices.async.filter { await !$0.isAggregateDevice }.toArray()
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
            await AudioDevice.defaultDevice(of: .alertOutput)
        }
    }

    var defaultSystemOutputDevice: AudioDevice? {
        get async {
            await AudioDevice.defaultDevice(of: .alertOutput)
        }
    }
}

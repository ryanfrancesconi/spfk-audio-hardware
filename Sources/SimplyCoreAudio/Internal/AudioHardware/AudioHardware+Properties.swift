// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import CoreAudio
import Foundation

extension AudioHardware {
    var allDeviceIDs: [AudioObjectID] {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: Element.main.propertyElement
        )

        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        var allIDs = [AudioObjectID]()
        let status = AudioDevice.getPropertyDataArray(systemObjectID, address: address, value: &allIDs, andDefaultValue: 0)

        return noErr == status ? allIDs : []
    }

    var allDevices: [AudioDevice] {
        allDeviceIDs.compactMap { AudioDevice.lookup(by: $0) }
    }
}

extension AudioHardware {
    var allInputDevices: [AudioDevice] {
        allDevices.filter { $0.channels(scope: .input) > 0 }
    }

    var allOutputDevices: [AudioDevice] {
        allDevices.filter { $0.channels(scope: .output) > 0 }
    }

    var allIODevices: [AudioDevice] {
        allDevices.filter { $0.channels(scope: .input) > 0 && $0.channels(scope: .output) > 0 }
    }

    var allNonAggregateDevices: [AudioDevice] {
        allDevices.filter { !$0.isAggregateDevice }
    }

    var allAggregateDevices: [AudioDevice] {
        allDevices.filter { $0.isAggregateDevice }
    }
}

extension AudioHardware {
    var defaultInputDevice: AudioDevice? {
        AudioDevice.defaultDevice(of: .defaultInput)
    }

    var defaultOutputDevice: AudioDevice? {
        AudioDevice.defaultDevice(of: .alertOutput)
    }

    var defaultSystemOutputDevice: AudioDevice? {
        AudioDevice.defaultDevice(of: .alertOutput)
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import Testing

@testable import SPFKAudioHardware

// MARK: - TransportType Tests

@Suite(.tags(.unit))
struct TransportTypeTests {
    @Test func rawValues() {
        #expect(TransportType.unknown.rawValue == "Unknown")
        #expect(TransportType.builtIn.rawValue == "Built-In")
        #expect(TransportType.aggregate.rawValue == "Aggregate")
        #expect(TransportType.virtual.rawValue == "Virtual")
        #expect(TransportType.pci.rawValue == "PCI")
        #expect(TransportType.usb.rawValue == "USB")
        #expect(TransportType.fireWire.rawValue == "FireWire")
        #expect(TransportType.bluetooth.rawValue == "Bluetooth")
        #expect(TransportType.bluetoothLE.rawValue == "Bluetooth LE")
        #expect(TransportType.hdmi.rawValue == "HDMI")
        #expect(TransportType.displayPort.rawValue == "DisplayPort")
        #expect(TransportType.airPlay.rawValue == "AirPlay")
        #expect(TransportType.avb.rawValue == "AVB")
        #expect(TransportType.thunderbolt.rawValue == "Thunderbolt")
        #expect(TransportType.network.rawValue == "Network")
        #expect(TransportType.other.rawValue == "Other")
    }

    @Test func fromBuiltIn() {
        #expect(TransportType.from(kAudioDeviceTransportTypeBuiltIn) == .builtIn)
    }

    @Test func fromAggregate() {
        #expect(TransportType.from(kAudioDeviceTransportTypeAggregate) == .aggregate)
    }

    @Test func fromVirtual() {
        #expect(TransportType.from(kAudioDeviceTransportTypeVirtual) == .virtual)
    }

    @Test func fromPCI() {
        #expect(TransportType.from(kAudioDeviceTransportTypePCI) == .pci)
    }

    @Test func fromUSB() {
        #expect(TransportType.from(kAudioDeviceTransportTypeUSB) == .usb)
    }

    @Test func fromFireWire() {
        #expect(TransportType.from(kAudioDeviceTransportTypeFireWire) == .fireWire)
    }

    @Test func fromBluetooth() {
        #expect(TransportType.from(kAudioDeviceTransportTypeBluetooth) == .bluetooth)
    }

    @Test func fromBluetoothLE() {
        #expect(TransportType.from(kAudioDeviceTransportTypeBluetoothLE) == .bluetoothLE)
    }

    @Test func fromHDMI() {
        #expect(TransportType.from(kAudioDeviceTransportTypeHDMI) == .hdmi)
    }

    @Test func fromDisplayPort() {
        #expect(TransportType.from(kAudioDeviceTransportTypeDisplayPort) == .displayPort)
    }

    @Test func fromAirPlay() {
        #expect(TransportType.from(kAudioDeviceTransportTypeAirPlay) == .airPlay)
    }

    @Test func fromAVB() {
        #expect(TransportType.from(kAudioDeviceTransportTypeAVB) == .avb)
    }

    @Test func fromThunderbolt() {
        #expect(TransportType.from(kAudioDeviceTransportTypeThunderbolt) == .thunderbolt)
    }

    @Test func fromUnknown() {
        #expect(TransportType.from(kAudioDeviceTransportTypeUnknown) == .unknown)
    }

    @Test func fromUnrecognizedConstantDefaultsToUnknown() {
        #expect(TransportType.from(0xDEAD_BEEF) == .unknown)
    }

    @Test func initFromRawValue() {
        #expect(TransportType(rawValue: "USB") == .usb)
        #expect(TransportType(rawValue: "Built-In") == .builtIn)
        #expect(TransportType(rawValue: "Nonexistent") == nil)
    }
}

// MARK: - TerminalType Tests

@Suite(.tags(.unit))
struct TerminalTypeTests {
    @Test func rawValues() {
        #expect(TerminalType.unknown.rawValue == "Unknown")
        #expect(TerminalType.line.rawValue == "Line")
        #expect(TerminalType.digitalAudioInterface.rawValue == "Digital Audio Interface")
        #expect(TerminalType.speaker.rawValue == "Speaker")
        #expect(TerminalType.headphones.rawValue == "Headphones")
        #expect(TerminalType.lfeSpeaker.rawValue == "LFE Speaker")
        #expect(TerminalType.receiverSpeaker.rawValue == "Receiver Speaker")
        #expect(TerminalType.microphone.rawValue == "Microphone")
        #expect(TerminalType.headsetMicrophone.rawValue == "Headset Microphone")
        #expect(TerminalType.receiverMicrophone.rawValue == "Receiver Microphone")
        #expect(TerminalType.tty.rawValue == "TTY")
        #expect(TerminalType.hdmi.rawValue == "HDMI")
        #expect(TerminalType.displayPort.rawValue == "DisplayPort")
    }

    @Test func fromLine() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeLine) == .line)
    }

    @Test func fromDigitalAudioInterface() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeDigitalAudioInterface) == .digitalAudioInterface)
    }

    @Test func fromSpeaker() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeSpeaker) == .speaker)
    }

    @Test func fromHeadphones() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeHeadphones) == .headphones)
    }

    @Test func fromLFESpeaker() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeLFESpeaker) == .lfeSpeaker)
    }

    @Test func fromReceiverSpeaker() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeReceiverSpeaker) == .receiverSpeaker)
    }

    @Test func fromMicrophone() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeMicrophone) == .microphone)
    }

    @Test func fromHeadsetMicrophone() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeHeadsetMicrophone) == .headsetMicrophone)
    }

    @Test func fromReceiverMicrophone() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeReceiverMicrophone) == .receiverMicrophone)
    }

    @Test func fromTTY() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeTTY) == .tty)
    }

    @Test func fromHDMI() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeHDMI) == .hdmi)
    }

    @Test func fromDisplayPort() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeDisplayPort) == .displayPort)
    }

    @Test func fromUnknown() {
        #expect(TerminalType.from(kAudioStreamTerminalTypeUnknown) == .unknown)
    }

    @Test func fromUnrecognizedConstantDefaultsToUnknown() {
        #expect(TerminalType.from(0xDEAD_BEEF) == .unknown)
    }

    @Test func initFromRawValue() {
        #expect(TerminalType(rawValue: "Speaker") == .speaker)
        #expect(TerminalType(rawValue: "Microphone") == .microphone)
        #expect(TerminalType(rawValue: "Nonexistent") == nil)
    }
}

// MARK: - DefaultSelectorType Tests

@Suite(.tags(.unit))
struct DefaultSelectorTypeTests {
    @Test func allCasesCount() {
        #expect(DefaultSelectorType.allCases.count == 3)
    }

    @Test func propertySelectorMapping() {
        #expect(DefaultSelectorType.defaultInput.propertySelector == kAudioHardwarePropertyDefaultInputDevice)
        #expect(DefaultSelectorType.defaultOutput.propertySelector == kAudioHardwarePropertyDefaultOutputDevice)
        #expect(DefaultSelectorType.alertOutput.propertySelector == kAudioHardwarePropertyDefaultSystemOutputDevice)
    }

    @Test func notificationNameMapping() {
        #expect(DefaultSelectorType.defaultInput.notificationName == .defaultInputDeviceChanged)
        #expect(DefaultSelectorType.defaultOutput.notificationName == .defaultOutputDeviceChanged)
        #expect(DefaultSelectorType.alertOutput.notificationName == .defaultSystemOutputDeviceChanged)
    }

    @Test func codableRoundTrip() throws {
        for selectorType in DefaultSelectorType.allCases {
            let data = try JSONEncoder().encode(selectorType)
            let decoded = try JSONDecoder().decode(DefaultSelectorType.self, from: data)
            #expect(decoded == selectorType)
        }
    }

    @Test func hashable() {
        let set: Set<DefaultSelectorType> = [.defaultInput, .defaultOutput, .alertOutput, .defaultInput]
        #expect(set.count == 3)
    }
}

// MARK: - VolumeInfo Tests

@Suite(.tags(.unit))
struct VolumeInfoTests {
    @Test func defaultValues() {
        let info = VolumeInfo()

        #expect(info.volume == nil)
        #expect(info.hasVolume == false)
        #expect(info.canSetVolume == false)
        #expect(info.canMute == false)
        #expect(info.isMuted == false)
        #expect(info.canPlayThru == false)
        #expect(info.isPlayThruSet == false)
    }

    @Test func mutability() {
        var info = VolumeInfo()

        info.volume = 0.75
        info.hasVolume = true
        info.canSetVolume = true
        info.canMute = true
        info.isMuted = true
        info.canPlayThru = true
        info.isPlayThruSet = true

        #expect(info.volume == 0.75)
        #expect(info.hasVolume == true)
        #expect(info.canSetVolume == true)
        #expect(info.canMute == true)
        #expect(info.isMuted == true)
        #expect(info.canPlayThru == true)
        #expect(info.isPlayThruSet == true)
    }
}

// MARK: - DeviceStatusEvent Tests

@Suite(.tags(.unit))
struct DeviceStatusEventTests {
    @Test func defaultInit() {
        let event = DeviceStatusEvent()

        #expect(event.addedDevices.isEmpty)
        #expect(event.removedDevices.isEmpty)
        #expect(event.allDevices.isEmpty)
    }

    @Test func hashable() {
        let a = DeviceStatusEvent()
        let b = DeviceStatusEvent()

        #expect(a == b)
    }
}

// MARK: - Notification Name Tests

@Suite(.tags(.unit))
struct NotificationNameTests {
    @Test func hardwareNotificationNames() {
        #expect(Notification.Name.defaultInputDeviceChanged.rawValue == "SPFKAudioHardware.defaultInputDeviceChanged")
        #expect(Notification.Name.defaultOutputDeviceChanged.rawValue == "SPFKAudioHardware.defaultOutputDeviceChanged")
        #expect(Notification.Name.defaultSystemOutputDeviceChanged.rawValue == "SPFKAudioHardware.defaultSystemOutputDeviceChanged")
        #expect(Notification.Name.deviceListChanged.rawValue == "SPFKAudioHardware.deviceListChanged")
    }

    @Test func deviceNotificationNames() {
        #expect(Notification.Name.deviceNominalSampleRateDidChange.rawValue == "SPFKAudioHardware.deviceNominalSampleRateDidChange")
        #expect(Notification.Name.deviceVolumeDidChange.rawValue == "SPFKAudioHardware.deviceVolumeDidChange")
        #expect(Notification.Name.deviceMuteDidChange.rawValue == "SPFKAudioHardware.deviceMuteDidChange")
        #expect(Notification.Name.deviceNameDidChange.rawValue == "SPFKAudioHardware.deviceNameDidChange")
        #expect(Notification.Name.deviceIsAliveDidChange.rawValue == "SPFKAudioHardware.deviceIsAliveDidChange")
        #expect(Notification.Name.deviceIsRunningDidChange.rawValue == "SPFKAudioHardware.deviceIsRunningDidChange")
        #expect(Notification.Name.deviceHogModeDidChange.rawValue == "SPFKAudioHardware.deviceHogModeDidChange")
        #expect(Notification.Name.deviceProcessorOverload.rawValue == "SPFKAudioHardware.deviceProcessorOverload")
        #expect(Notification.Name.deviceIOStoppedAbnormally.rawValue == "SPFKAudioHardware.deviceIOStoppedAbnormally")
    }

    @Test func streamNotificationNames() {
        #expect(Notification.Name.streamIsActiveDidChange.rawValue == "SPFKAudioHardware.streamIsActiveDidChange")
        #expect(Notification.Name.streamPhysicalFormatDidChange.rawValue == "SPFKAudioHardware.streamPhysicalFormatDidChange")
    }

    @Test func namesAreUnique() {
        let names: [Notification.Name] = [
            .defaultInputDeviceChanged,
            .defaultOutputDeviceChanged,
            .defaultSystemOutputDeviceChanged,
            .deviceListChanged,
            .deviceNominalSampleRateDidChange,
            .deviceAvailableNominalSampleRatesDidChange,
            .deviceClockSourceDidChange,
            .deviceNameDidChange,
            .deviceOwnedObjectsDidChange,
            .deviceVolumeDidChange,
            .deviceMuteDidChange,
            .deviceIsAliveDidChange,
            .deviceIsRunningDidChange,
            .deviceIsRunningSomewhereDidChange,
            .deviceIsJackConnectedDidChange,
            .devicePreferredChannelsForStereoDidChange,
            .deviceHogModeDidChange,
            .deviceProcessorOverload,
            .deviceIOStoppedAbnormally,
            .streamIsActiveDidChange,
            .streamPhysicalFormatDidChange,
            .prun,
        ]

        let nameSet = Set(names)
        #expect(nameSet.count == names.count, "All notification names should be unique")
    }
}

// MARK: - AudioHardwareNotification Parsing Tests

@Suite(.tags(.unit))
struct AudioHardwareNotificationParsingTests {
    @Test func parseDefaultInputDevice() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioHardwareNotification(objectID: 42, propertyAddress: address)
        #expect(notification == .defaultInputDeviceChanged(objectID: 42))
    }

    @Test func parseDefaultOutputDevice() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioHardwareNotification(objectID: 42, propertyAddress: address)
        #expect(notification == .defaultOutputDeviceChanged(objectID: 42))
    }

    @Test func parseDefaultSystemOutputDevice() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultSystemOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioHardwareNotification(objectID: 42, propertyAddress: address)
        #expect(notification == .defaultSystemOutputDeviceChanged(objectID: 42))
    }

    @Test func parseOwnedObjects() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyOwnedObjects,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioHardwareNotification(objectID: 42, propertyAddress: address)
        #expect(notification != nil)

        if case let .deviceListChanged(objectID, _) = notification {
            #expect(objectID == 42)
        } else {
            Issue.record("Expected .deviceListChanged")
        }
    }

    @Test func parseUnrecognizedSelectorReturnsNil() {
        let address = AudioObjectPropertyAddress(
            mSelector: 0xDEAD_BEEF,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioHardwareNotification(objectID: 42, propertyAddress: address)
        #expect(notification == nil)
    }

    @Test func notificationNames() {
        #expect(AudioHardwareNotification.defaultInputDeviceChanged(objectID: 1).name == .defaultInputDeviceChanged)
        #expect(AudioHardwareNotification.defaultOutputDeviceChanged(objectID: 1).name == .defaultOutputDeviceChanged)
        #expect(AudioHardwareNotification.defaultSystemOutputDeviceChanged(objectID: 1).name == .defaultSystemOutputDeviceChanged)
        #expect(AudioHardwareNotification.deviceListChanged(objectID: 1, event: .init()).name == .deviceListChanged)
    }
}

// MARK: - AudioDeviceNotification Parsing Tests

@Suite(.tags(.unit))
struct AudioDeviceNotificationParsingTests {
    @Test func parseNominalSampleRate() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyNominalSampleRate,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceNominalSampleRateDidChange(objectID: 100))
    }

    @Test func parseAvailableNominalSampleRates() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyAvailableNominalSampleRates,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceAvailableNominalSampleRatesDidChange(objectID: 100))
    }

    @Test func parseClockSource() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyClockSource,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceClockSourceDidChange(objectID: 100))
    }

    @Test func parseName() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceNameDidChange(objectID: 100))
    }

    @Test func parseOwnedObjects() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyOwnedObjects,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceOwnedObjectsDidChange(objectID: 100))
    }

    @Test func parseVolumeWithScopeAndChannel() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: 0
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceVolumeDidChange(objectID: 100, channel: 0, scope: .output))
    }

    @Test func parseVolumeInputScope() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioObjectPropertyScopeInput,
            mElement: 1
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceVolumeDidChange(objectID: 100, channel: 1, scope: .input))
    }

    @Test func parseMuteWithScopeAndChannel() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: 0
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceMuteDidChange(objectID: 100, channel: 0, scope: .output))
    }

    @Test func parseIsAlive() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsAlive,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceIsAliveDidChange(objectID: 100))
    }

    @Test func parseIsRunning() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunning,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceIsRunningDidChange(objectID: 100))
    }

    @Test func parseIsRunningSomewhere() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceIsRunningSomewhereDidChange(objectID: 100))
    }

    @Test func parseJackIsConnected() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyJackIsConnected,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceIsJackConnectedDidChange(objectID: 100))
    }

    @Test func parsePreferredChannelsForStereo() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyPreferredChannelsForStereo,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .devicePreferredChannelsForStereoDidChange(objectID: 100))
    }

    @Test func parseHogMode() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyHogMode,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceHogModeDidChange(objectID: 100))
    }

    @Test func parseProcessorOverload() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDeviceProcessorOverload,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceProcessorOverload(objectID: 100))
    }

    @Test func parseIOStoppedAbnormally() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyIOStoppedAbnormally,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == .deviceIOStoppedAbnormally(objectID: 100))
    }

    @Test func parseMainSubDeviceReturnsNil() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioAggregateDevicePropertyMainSubDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == nil)
    }

    @Test func parseUnrecognizedSelectorReturnsNil() {
        let address = AudioObjectPropertyAddress(
            mSelector: 0xDEAD_BEEF,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioDeviceNotification(objectID: 100, propertyAddress: address)
        #expect(notification == nil)
    }

    @Test func notificationNameMapping() {
        let cases: [(AudioDeviceNotification, Notification.Name)] = [
            (.deviceNominalSampleRateDidChange(objectID: 1), .deviceNominalSampleRateDidChange),
            (.deviceAvailableNominalSampleRatesDidChange(objectID: 1), .deviceAvailableNominalSampleRatesDidChange),
            (.deviceClockSourceDidChange(objectID: 1), .deviceClockSourceDidChange),
            (.deviceNameDidChange(objectID: 1), .deviceNameDidChange),
            (.deviceOwnedObjectsDidChange(objectID: 1), .deviceOwnedObjectsDidChange),
            (.deviceVolumeDidChange(objectID: 1, channel: 0, scope: .output), .deviceVolumeDidChange),
            (.deviceMuteDidChange(objectID: 1, channel: 0, scope: .input), .deviceMuteDidChange),
            (.deviceIsAliveDidChange(objectID: 1), .deviceIsAliveDidChange),
            (.deviceIsRunningDidChange(objectID: 1), .deviceIsRunningDidChange),
            (.deviceIsRunningSomewhereDidChange(objectID: 1), .deviceIsRunningSomewhereDidChange),
            (.deviceIsJackConnectedDidChange(objectID: 1), .deviceIsJackConnectedDidChange),
            (.devicePreferredChannelsForStereoDidChange(objectID: 1), .devicePreferredChannelsForStereoDidChange),
            (.deviceHogModeDidChange(objectID: 1), .deviceHogModeDidChange),
            (.deviceProcessorOverload(objectID: 1), .deviceProcessorOverload),
            (.deviceIOStoppedAbnormally(objectID: 1), .deviceIOStoppedAbnormally),
        ]

        for (notification, expectedName) in cases {
            #expect(notification.name == expectedName)
        }
    }
}

// MARK: - AudioStreamNotification Parsing Tests

@Suite(.tags(.unit))
struct AudioStreamNotificationParsingTests {
    @Test func parseStreamIsActive() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioStreamPropertyIsActive,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioStreamNotification(objectID: 200, propertyAddress: address)
        #expect(notification == .streamIsActiveDidChange(objectID: 200))
    }

    @Test func parseStreamPhysicalFormat() {
        let address = AudioObjectPropertyAddress(
            mSelector: kAudioStreamPropertyPhysicalFormat,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioStreamNotification(objectID: 200, propertyAddress: address)
        #expect(notification == .streamPhysicalFormatDidChange(objectID: 200))
    }

    @Test func parseUnrecognizedSelectorReturnsNil() {
        let address = AudioObjectPropertyAddress(
            mSelector: 0xDEAD_BEEF,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioStreamNotification(objectID: 200, propertyAddress: address)
        #expect(notification == nil)
    }

    @Test func notificationNames() {
        #expect(AudioStreamNotification.streamIsActiveDidChange(objectID: 1).name == .streamIsActiveDidChange)
        #expect(AudioStreamNotification.streamPhysicalFormatDidChange(objectID: 1).name == .streamPhysicalFormatDidChange)
    }
}

// MARK: - Hashable / Equatable Tests

@Suite(.tags(.unit))
struct NotificationHashableTests {
    @Test func audioHardwareNotificationEquality() {
        let a = AudioHardwareNotification.defaultInputDeviceChanged(objectID: 42)
        let b = AudioHardwareNotification.defaultInputDeviceChanged(objectID: 42)
        let c = AudioHardwareNotification.defaultInputDeviceChanged(objectID: 99)

        #expect(a == b)
        #expect(a != c)
    }

    @Test func audioDeviceNotificationEquality() {
        let a = AudioDeviceNotification.deviceVolumeDidChange(objectID: 42, channel: 0, scope: .output)
        let b = AudioDeviceNotification.deviceVolumeDidChange(objectID: 42, channel: 0, scope: .output)
        let c = AudioDeviceNotification.deviceVolumeDidChange(objectID: 42, channel: 0, scope: .input)
        let d = AudioDeviceNotification.deviceVolumeDidChange(objectID: 42, channel: 1, scope: .output)

        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test func audioDeviceNotificationDifferentCasesNotEqual() {
        let volume = AudioDeviceNotification.deviceVolumeDidChange(objectID: 42, channel: 0, scope: .output)
        let mute = AudioDeviceNotification.deviceMuteDidChange(objectID: 42, channel: 0, scope: .output)

        #expect(volume != mute)
    }

    @Test func audioStreamNotificationEquality() {
        let a = AudioStreamNotification.streamIsActiveDidChange(objectID: 42)
        let b = AudioStreamNotification.streamIsActiveDidChange(objectID: 42)
        let c = AudioStreamNotification.streamPhysicalFormatDidChange(objectID: 42)

        #expect(a == b)
        #expect(a != c)
    }

    @Test func audioHardwareNotificationHashable() {
        let set: Set<AudioHardwareNotification> = [
            .defaultInputDeviceChanged(objectID: 1),
            .defaultOutputDeviceChanged(objectID: 1),
            .defaultSystemOutputDeviceChanged(objectID: 1),
            .defaultInputDeviceChanged(objectID: 1), // duplicate
        ]

        #expect(set.count == 3)
    }

    @Test func audioDeviceNotificationHashable() {
        let set: Set<AudioDeviceNotification> = [
            .deviceVolumeDidChange(objectID: 1, channel: 0, scope: .output),
            .deviceVolumeDidChange(objectID: 1, channel: 0, scope: .input),
            .deviceVolumeDidChange(objectID: 1, channel: 0, scope: .output), // duplicate
            .deviceMuteDidChange(objectID: 1, channel: 0, scope: .output),
        ]

        #expect(set.count == 3)
    }
}

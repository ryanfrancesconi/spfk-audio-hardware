// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import Testing

@testable import SPFKAudioHardware

// MARK: - TransportType Tests

@Suite
struct TransportTypeTests {
    @Test func fromUnrecognizedConstantDefaultsToUnknown() {
        #expect(TransportType.from(0xDEAD_BEEF) == .unknown)
    }
}

// MARK: - TerminalType Tests

@Suite
struct TerminalTypeTests {
    @Test func fromUnrecognizedConstantDefaultsToUnknown() {
        #expect(TerminalType.from(0xDEAD_BEEF) == .unknown)
    }
}

// MARK: - Notification Name Tests

@Suite
struct NotificationNameTests {
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

@Suite
struct AudioHardwareNotificationParsingTests {
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
}

// MARK: - AudioDeviceNotification Parsing Tests

@Suite
struct AudioDeviceNotificationParsingTests {
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
}

// MARK: - AudioStreamNotification Parsing Tests

@Suite
struct AudioStreamNotificationParsingTests {
    @Test func parseUnrecognizedSelectorReturnsNil() {
        let address = AudioObjectPropertyAddress(
            mSelector: 0xDEAD_BEEF,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let notification = AudioStreamNotification(objectID: 200, propertyAddress: address)
        #expect(notification == nil)
    }
}

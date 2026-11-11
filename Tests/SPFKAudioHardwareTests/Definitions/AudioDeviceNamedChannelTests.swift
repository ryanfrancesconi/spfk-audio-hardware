// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import Testing

@testable import SPFKAudioHardware

@Suite
struct AudioDeviceNamedChannelTests {
    @Test func descriptionWithName() {
        let channel = AudioDeviceNamedChannel(channel: 0, name: "Left", scope: .output)
        #expect(channel.description == "1 - Left")
    }

    @Test func descriptionWithoutName() {
        let channel = AudioDeviceNamedChannel(channel: 0, name: nil, scope: .input)
        #expect(channel.description == "1 - Input")
    }

    @Test func descriptionWithEmptyName() {
        let channel = AudioDeviceNamedChannel(channel: 0, name: "", scope: .input)
        #expect(channel.description == "1 - Input")
    }

    @Test func descriptionChannelNumbering() {
        let channel = AudioDeviceNamedChannel(channel: 5, name: "Surround", scope: .output)
        #expect(channel.description == "6 - Surround")
    }

    @Test func nameIsTrimmed() {
        let channel = AudioDeviceNamedChannel(channel: 0, name: "  Left  ", scope: .output)
        #expect(channel.name == "Left")
    }
}

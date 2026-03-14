// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import Testing

@testable import SPFKAudioHardware

@Suite(.tags(.unit))
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

    @Test func equality() {
        let a = AudioDeviceNamedChannel(channel: 0, name: "Left", scope: .output)
        let b = AudioDeviceNamedChannel(channel: 0, name: "Left", scope: .output)
        let c = AudioDeviceNamedChannel(channel: 1, name: "Left", scope: .output)

        #expect(a == b)
        #expect(a != c)
    }

    @Test func scopeIsPreserved() {
        let outputChannel = AudioDeviceNamedChannel(channel: 0, name: "Left", scope: .output)
        let inputChannel = AudioDeviceNamedChannel(channel: 0, name: "Left", scope: .input)

        #expect(outputChannel.scope == .output)
        #expect(inputChannel.scope == .input)
        #expect(outputChannel != inputChannel)
    }
}

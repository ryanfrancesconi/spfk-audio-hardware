// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Input/Output Layout Functions

public extension AudioDevice {
    /// Whether the device has only inputs but no outputs.
    ///
    /// - Returns: `true` when the device is input only, `false` otherwise.
    var isInputOnlyDevice: Bool {
        get async {
            let output = await channels(scope: .output) > 0
            let input = await channels(scope: .input) > 0

            return !output && input
        }
    }

    /// Whether the device has only outputs but no inputs.
    ///
    /// - Returns: `true` when the device is output only, `false` otherwise.
    var isOutputOnlyDevice: Bool {
        get async {
            let output = await channels(scope: .output) > 0
            let input = await channels(scope: .input) > 0

            return output && !input
        }
    }

    /// The number of layout channels for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `UInt32` with the number of layout channels.
    func layoutChannels(scope: Scope) -> UInt32? {
        guard let address = validAddress(selector: kAudioDevicePropertyPreferredChannelLayout,
                                         scope: scope.propertyScope) else { return nil }

        var result = AudioChannelLayout()
        let status = getPropertyData(address, andValue: &result)

        return noErr == status ? result.mNumberChannelDescriptions : nil
    }

    /// The number of channels for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: A `UInt32` with the number of channels.
    func channels(scope: Scope) async -> UInt32 {
        guard let streams = await streams(scope: scope) else { return 0 }

        return streams.map { $0.physicalFormat?.mChannelsPerFrame ?? 0 }.reduce(0, +)
    }

    /// A human readable name for the channel number and scope specified.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `String` with the name of the channel.
    func name(channel: UInt32, scope: Scope) -> String? {
        guard let address = validAddress(selector: kAudioObjectPropertyElementName,
                                         scope: scope.propertyScope,
                                         element: channel) else { return nil }

        guard let name: String = getProperty(address: address) else { return nil }

        return name.isEmpty ? nil : name
    }

    /// Whether the audio device's jack is connected for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` when jack is connected, `false` otherwise.
    func isJackConnected(scope: Scope) -> Bool? {
        guard let address = validAddress(selector: kAudioDevicePropertyJackIsConnected,
                                         scope: scope.propertyScope) else { return nil }

        return getProperty(address: address)
    }

    /// - Returns: A collection of named channels
    func namedChannels(scope: Scope) async -> [AudioDeviceNamedChannel] {
        var out = [AudioDeviceNamedChannel]()

        let channelCount = await channels(scope: scope)

        guard channelCount > 0 else { return [] }

        for i in 0 ..< channelCount {
            let string = name(channel: i, scope: scope)?.trimmingCharacters(in: .whitespacesAndNewlines)

            let deviceChannel = AudioDeviceNamedChannel(
                channel: i,
                name: string,
                scope: scope
            )

            out.append(deviceChannel)
        }

        return out
    }
}

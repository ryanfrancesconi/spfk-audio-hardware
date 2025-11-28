// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Input/Output Layout Functions

extension AudioDevice {
    /// Whether the audio device's jack is connected for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` when jack is connected, `false` otherwise.
    public func isJackConnected(scope: Scope) -> Bool? {
        guard
            let address = validAddress(
                selector: kAudioDevicePropertyJackIsConnected,
                scope: scope.propertyScope,
            )
        else { return nil }

        return getProperty(address: address)
    }

    /// Whether the device has only inputs but no outputs.
    ///
    /// - Returns: `true` when the device is input only, `false` otherwise.
    public var isInputOnlyDevice: Bool {
        get async {
            let output = await physicalChannels(scope: .output) > 0
            let input = await physicalChannels(scope: .input) > 0

            return !output && input
        }
    }

    /// Whether the device has only outputs but no inputs.
    ///
    /// - Returns: `true` when the device is output only, `false` otherwise.
    public var isOutputOnlyDevice: Bool {
        get async {
            let output = await physicalChannels(scope: .output) > 0
            let input = await physicalChannels(scope: .input) > 0

            return output && !input
        }
    }

    public func isOnly(scope: Scope) async -> Bool {
        switch scope {
        case .input:
            await isInputOnlyDevice

        case .output:
            await isOutputOnlyDevice

        default: false
        }
    }

    /// The number of layout channels for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `UInt32` with the number of layout channels.
    public func layoutChannels(scope: Scope) -> UInt32? {
        guard
            let address = validAddress(
                selector: kAudioDevicePropertyPreferredChannelLayout,
                scope: scope.propertyScope,
            )
        else { return nil }

        var result = AudioChannelLayout()
        let status = getPropertyData(address, andValue: &result)

        return noErr == status ? result.mNumberChannelDescriptions : nil
    }

    public func layoutChannelDescriptions(scope: Scope) -> [AudioChannelDescription]? {
        guard
            let address = validAddress(
                selector: kAudioDevicePropertyPreferredChannelLayout,
                scope: scope.propertyScope,
            )
        else { return nil }

        var result = AudioChannelLayout()
        var status = getPropertyData(address, andValue: &result)

        guard noErr == status else { return nil }

        var mChannelDescriptions = [AudioChannelDescription]()
        status = getPropertyDataArray(address, value: &mChannelDescriptions, andDefaultValue: .init())

        return mChannelDescriptions
    }

    /// The number of physical channels for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: A `UInt32` with the number of channels.
    public func physicalChannels(scope: Scope) async -> UInt32 {
        guard let streams = await streams(scope: scope) else { return 0 }

        return streams.compactMap {
            $0.physicalFormat?.mChannelsPerFrame
        }.reduce(0, +)
    }

    /// The number of virtual channels for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: A `UInt32` with the number of channels.
    public func virtualChannels(scope: Scope) async -> UInt32 {
        guard let streams = await streams(scope: scope) else { return 0 }

        return streams.compactMap {
            $0.virtualFormat?.mChannelsPerFrame
        }.reduce(0, +)
    }

    /// A human readable name for the channel number and scope specified.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `String` with the name of the channel.
    public func name(channel: UInt32, scope: Scope) -> String? {
        guard
            let address = validAddress(
                selector: kAudioObjectPropertyElementName,
                scope: scope.propertyScope,
                element: channel,
            )
        else { return nil }

        guard let name: String = getProperty(address: address) else { return nil }

        return name.isEmpty ? nil : name
    }

    /// - Returns: A collection of named channels
    public func namedChannels(scope: Scope) async -> [AudioDeviceNamedChannel] {
        var out = [AudioDeviceNamedChannel]()

        let channelCount = await physicalChannels(scope: scope)

        guard channelCount > 0 else {
            return []
        }

        for i in 0 ..< channelCount {
            let string = name(channel: i, scope: scope)

            let deviceChannel = AudioDeviceNamedChannel(
                channel: i,
                name: string,
                scope: scope,
            )

            out.append(deviceChannel)
        }

        return out
    }
}

extension [AudioDevice] {
    public func isOnly(scope: Scope) async -> [AudioDevice] {
        await async.filter { await $0.isOnly(scope: scope) }.toArray()
    }
}

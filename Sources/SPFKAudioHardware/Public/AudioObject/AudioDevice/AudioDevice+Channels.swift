// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
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

    /// Whether this device exclusively supports the given scope (input-only or output-only).
    ///
    /// - Parameter scope: `.input` or `.output`. Returns `false` for other scopes.
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
        guard let descriptions = preferredChannelLayoutDescriptions(scope: scope) else { return nil }

        return UInt32(descriptions.count)
    }

    /// The preferred channel layout descriptions for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* An array of `AudioChannelDescription` structs.
    public func layoutChannelDescriptions(scope: Scope) -> [AudioChannelDescription]? {
        preferredChannelLayoutDescriptions(scope: scope)
    }

    /// The channel descriptions of `kAudioDevicePropertyPreferredChannelLayout`.
    ///
    /// The payload is a variable-length `AudioChannelLayout`: a 12-byte header followed by
    /// `mNumberChannelDescriptions` entries, so its size has to come from the property itself.
    /// A layout that names its channels by `mChannelLayoutTag` carries no descriptions and
    /// returns an empty array.
    private func preferredChannelLayoutDescriptions(scope: Scope) -> [AudioChannelDescription]? {
        guard
            let address = validAddress(
                selector: kAudioDevicePropertyPreferredChannelLayout,
                scope: scope.propertyScope,
            )
        else { return nil }

        // AudioChannelLayout declares a trailing array of one, so subtracting that entry
        // leaves the header.
        let headerSize = MemoryLayout<AudioChannelLayout>.size - MemoryLayout<AudioChannelDescription>.size

        var size = UInt32(0)

        guard noErr == getPropertyDataSize(address, andSize: &size), size >= UInt32(headerSize) else {
            return nil
        }

        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(size),
            alignment: MemoryLayout<AudioChannelLayout>.alignment
        )
        defer { buffer.deallocate() }

        guard noErr == getPropertyDataBytes(address, size: &size, into: buffer) else { return nil }

        let declared = Int(buffer.loadUnaligned(fromByteOffset: headerSize - MemoryLayout<UInt32>.size,
                                                as: UInt32.self))

        // The byte count is authoritative — a declared count beyond it would read off the end.
        let available = (Int(size) - headerSize) / MemoryLayout<AudioChannelDescription>.size

        guard declared > 0, available > 0 else { return [] }

        return (0 ..< min(declared, available)).map {
            buffer.loadUnaligned(fromByteOffset: headerSize + $0 * MemoryLayout<AudioChannelDescription>.size,
                                 as: AudioChannelDescription.self)
        }
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
    /// Filters the array to devices that exclusively support the given scope.
    public func isOnly(scope: Scope) async -> [AudioDevice] {
        await async.filter { await $0.isOnly(scope: scope) }.toArray()
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Individual Channel Functions

extension AudioDevice {
    /// A `VolumeInfo` struct containing information about a particular channel and scope combination.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `VolumeInfo` struct.
    public func volumeInfo(channel: UInt32, scope: Scope) -> VolumeInfo? {
        // Obtain volume info
        var address: AudioObjectPropertyAddress
        var hasAnyProperty = false

        address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: scope.propertyScope,
            mElement: channel
        )

        var volumeInfo = VolumeInfo()

        if AudioObjectHasProperty(id, &address) {
            var canSetVolumeBoolean = DarwinBoolean(false)
            var status = AudioObjectIsPropertySettable(id, &address, &canSetVolumeBoolean)

            if noErr == status {
                volumeInfo.canSetVolume = canSetVolumeBoolean.boolValue
                volumeInfo.hasVolume = true

                var volume = Float32(0)
                status = getPropertyData(address, andValue: &volume)

                if noErr == status {
                    volumeInfo.volume = volume
                    hasAnyProperty = true
                }
            }
        }

        // Obtain mute info
        address.mSelector = kAudioDevicePropertyMute

        if AudioObjectHasProperty(id, &address) {
            var canMuteBoolean = DarwinBoolean(false)
            var status = AudioObjectIsPropertySettable(id, &address, &canMuteBoolean)

            if noErr == status {
                volumeInfo.canMute = canMuteBoolean.boolValue

                var isMutedValue = UInt32(0)
                status = getPropertyData(address, andValue: &isMutedValue)

                if noErr == status {
                    volumeInfo.isMuted = Bool(isMutedValue)
                    hasAnyProperty = true
                }
            }
        }

        // Obtain play thru info
        address.mSelector = kAudioDevicePropertyPlayThru

        if AudioObjectHasProperty(id, &address) {
            var canPlayThruBoolean = DarwinBoolean(false)
            var status = AudioObjectIsPropertySettable(id, &address, &canPlayThruBoolean)

            if noErr == status {
                volumeInfo.canPlayThru = canPlayThruBoolean.boolValue

                var isPlayThruSetValue = UInt32(0)
                status = getPropertyData(address, andValue: &isPlayThruSetValue)

                if noErr == status {
                    volumeInfo.isPlayThruSet = Bool(isPlayThruSetValue)
                    hasAnyProperty = true
                }
            }
        }

        return hasAnyProperty ? volumeInfo : nil
    }

    /// The scalar volume for a given channel and scope.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the scalar volume.
    public func volume(channel: UInt32, scope: Scope) -> Float32? {
        guard let address = validAddress(selector: kAudioDevicePropertyVolumeScalar,
                                         scope: scope.propertyScope,
                                         element: channel) else { return nil }

        return getProperty(address: address)
    }

    /// The volume in decibels *(dbFS)* for a given channel and scope.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the volume in decibels.
    public func volumeInDecibels(channel: UInt32, scope: Scope) -> Float32? {
        guard let address = validAddress(selector: kAudioDevicePropertyVolumeDecibels,
                                         scope: scope.propertyScope,
                                         element: channel) else { return nil }

        return getProperty(address: address)
    }

    /// Sets the channel's volume for a given scope.
    ///
    /// - Parameter volume: The new volume as a scalar value ranging from 0 to 1.
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: An `OSStatus` indicating success or failure.
    public func setVolume(_ volume: Float32, channel: UInt32, scope: Scope) -> OSStatus {
        guard let address = validAddress(selector: kAudioDevicePropertyVolumeScalar,
                                         scope: scope.propertyScope,
                                         element: channel) else { return kAudioHardwareBadObjectError }

        return setProperty(address: address, value: volume)
    }

    /// Mutes a channel for a given scope.
    ///
    /// - Parameter shouldMute: Whether channel should be muted or not.
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: An `OSStatus` indicating success or failure.
    public func setMute(_ shouldMute: Bool, channel: UInt32, scope: Scope) -> OSStatus {
        guard let address = validAddress(selector: kAudioDevicePropertyMute,
                                         scope: scope.propertyScope,
                                         element: channel) else { return kAudioHardwareBadObjectError }

        return setProperty(address: address, value: shouldMute)
    }

    /// Whether a channel is muted for a given scope.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* `true` if channel is muted, false otherwise.
    public func isMuted(channel: UInt32, scope: Scope) -> Bool? {
        guard let address = validAddress(selector: kAudioDevicePropertyMute,
                                         scope: scope.propertyScope,
                                         element: channel) else { return nil }

        return getProperty(address: address)
    }

    /// Whether the main channel is muted for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` when muted, `false` otherwise.
    public func isMainChannelMuted(scope: Scope) -> Bool? {
        isMuted(channel: kAudioObjectPropertyElementMain, scope: scope)
    }

    /// Whether a channel can be muted for a given scope.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` if channel can be muted, `false` otherwise.
    public func canMute(channel: UInt32, scope: Scope) -> Bool {
        volumeInfo(channel: channel, scope: scope)?.canMute ?? false
    }

    /// Whether the main volume can be muted for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` when the volume can be muted, `false` otherwise.
    public func canMuteMainChannel(scope: Scope) -> Bool {
        if canMute(channel: kAudioObjectPropertyElementMain, scope: scope) {
            return true
        }

        guard let preferredChannelsForStereo = preferredChannelsForStereo(scope: scope) else { return false }
        guard canMute(channel: preferredChannelsForStereo.0, scope: scope) else { return false }
        guard canMute(channel: preferredChannelsForStereo.1, scope: scope) else { return false }

        return true
    }

    /// Whether a channel's volume can be set for a given scope.
    ///
    /// - Parameter channel: A channel.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` if the channel's volume can be set, `false` otherwise.
    public func canSetVolume(channel: UInt32, scope: Scope) -> Bool {
        volumeInfo(channel: channel, scope: scope)?.canSetVolume ?? false
    }

    /// A list of channel numbers that best represent the preferred stereo channels
    /// used by this device. In most occasions this will be channels 1 and 2.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: A `StereoPair` tuple containing the channel numbers.
    public func preferredChannelsForStereo(scope: Scope) -> StereoPair? {
        guard let address = validAddress(
            selector: kAudioDevicePropertyPreferredChannelsForStereo,
            scope: scope.propertyScope
        ) else { return nil }

        var preferredChannels = [UInt32]()
        let status = getPropertyDataArray(address, value: &preferredChannels, andDefaultValue: 0)

        guard noErr == status, preferredChannels.count == 2 else { return nil }

        return (left: preferredChannels[0], right: preferredChannels[1])
    }

    /// Attempts to set the new preferred channels for stereo for a given scope.
    ///
    /// - Parameter channels: A `StereoPair` representing the preferred channels.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: An `OSStatus` indicating success or failure.
    public func setPreferredChannelsForStereo(channels: StereoPair, scope: Scope) -> OSStatus {
        guard let address = validAddress(
            selector: kAudioDevicePropertyPreferredChannelsForStereo,
            scope: scope.propertyScope
        ) else { return kAudioHardwareBadObjectError }

        var preferredChannels = [channels.left, channels.right]
        return setPropertyDataArray(address, andValue: &preferredChannels)
    }

    /// A human-readable description of the preferred stereo channel pair for a given scope.
    ///
    /// Returns a string like `"1 - Left + 2 - Right"` by joining the descriptions
    /// of the preferred stereo channels.
    ///
    /// - Parameter scope: A scope.
    /// - Returns: *(optional)* A formatted string, or `nil` if preferred channels are unavailable.
    public func preferredChannelsDescription(scope: Scope) async -> String? {
        guard let preferredChannelsForStereo = preferredChannelsForStereo(scope: scope) else { return nil }

        var namedChannels = await namedChannels(scope: scope).filter {
            $0.channel == preferredChannelsForStereo.left ||
                $0.channel == preferredChannelsForStereo.right
        }

        namedChannels = namedChannels.sorted(by: { lhs, rhs -> Bool in
            lhs.channel < rhs.channel
        })

        let stringValues = namedChannels.map {
            $0.description
        }

        return stringValues.joined(separator: " + ")
    }
}

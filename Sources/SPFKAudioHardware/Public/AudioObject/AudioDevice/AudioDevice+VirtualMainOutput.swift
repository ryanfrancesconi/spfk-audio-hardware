// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import AudioToolbox
import CoreAudio
import Foundation

// MARK: - Virtual Main Output Volume / Balance Functions

public extension AudioDevice {
    /// Whether the main volume can be set for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` when the volume can be set, `false` otherwise.
    func canSetVirtualMainVolume(scope: Scope) -> Bool {
        guard validAddress(
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            scope: scope.propertyScope
        ) != nil else { return false }

        return true
    }

    /// Sets the virtual main volume for a given scope.
    ///
    /// - Parameter volume: The new volume as a scalar value ranging from 0 to 1.
    /// - Parameter scope: A scope.
    /// - Returns: `true` on success, `false` otherwise.
    func setVirtualMainVolume(_ volume: Float32, scope: Scope) -> OSStatus {
        guard let address = validAddress(
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            scope: scope.propertyScope
        ) else { return kAudioHardwareBadObjectError }

        return setProperty(address: address, value: volume)
    }

    /// The virtual main scalar volume for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the scalar volume.
    func virtualMainVolume(scope: Scope) -> Float32? {
        guard let address = validAddress(
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            scope: scope.propertyScope
        ) else { return nil }

        return getProperty(address: address)
    }

    /// The virtual main volume in decibels for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the volume in decibels.
    func virtualMainVolumeInDecibels(scope: Scope) -> Float32? {
        var referenceChannel: UInt32

        if canSetVolume(channel: kAudioObjectPropertyElementMain, scope: scope) {
            referenceChannel = kAudioObjectPropertyElementMain
        } else {
            guard let channels = preferredChannelsForStereo(scope: scope) else { return nil }
            referenceChannel = channels.0
        }

        guard let mainVolume = virtualMainVolume(scope: scope) else { return nil }

        return scalarToDecibels(volume: mainVolume, channel: referenceChannel, scope: scope)
    }

    /// Whether the main balance can be set for a given scope.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` when the balance can be set, `false` otherwise.
    func canSetVirtualMainBalance(scope: Scope) -> Bool {
        guard validAddress(
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainBalance,
            scope: scope.propertyScope
        ) != nil else { return false }

        return true
    }

    /// The virtual main balance for a given scope.
    ///
    /// The range is from 0 (all power to the left) to 1 (all power to the right) with the value of 0.5 signifying
    /// that the channels have equal power.
    ///
    /// - Parameter scope: A scope.
    ///
    /// - Returns: *(optional)* A `Float32` value with the stereo balance.
    func virtualMainBalance(scope: Scope) -> Float32? {
        guard let address = validAddress(
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainBalance,
            scope: scope.propertyScope
        ) else { return nil }

        return getProperty(address: address)
    }

    /// Sets the new virtual main balance for a given scope.
    ///
    /// The range is from 0 (all power to the left) to 1 (all power to the right) with the value of 0.5 signifying
    /// that the channels have equal power.
    /// setVirtualMainBalance
    /// - Parameter value: The new balance.
    /// - Parameter scope: A scope.
    ///
    /// - Returns: `true` on success, `false` otherwise.
    func setVirtualMainBalance(_ value: Float32, scope: Scope) -> OSStatus {
        guard let address = validAddress(
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainBalance,
            scope: scope.propertyScope
        ) else { return kAudioHardwareBadObjectError }

        return setProperty(address: address, value: value)
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

// MARK: - Hog Mode Functions 'oink'

public extension AudioDevice {
    /// Indicates the `pid` that currently owns exclusive access to the audio device or
    /// a value of `-1` indicating that the device is currently available to all processes.
    ///
    /// - Returns: *(optional)* A `pid_t` value.
    var hogModePID: pid_t? {
        guard let address = validAddress(
            selector: kAudioDevicePropertyHogMode,
            scope: kAudioObjectPropertyScopeWildcard
        ) else { return nil }

        var pid = pid_t()
        let status = getPropertyData(address, andValue: &pid)

        return noErr == status ? pid : nil
    }

    /// Toggles hog mode on/off
    ///
    /// - Returns: `true` on success, `false` otherwise.
    private func toggleHogMode() -> OSStatus {
        guard let address = validAddress(
            selector: kAudioDevicePropertyHogMode,
            scope: kAudioObjectPropertyScopeWildcard
        ) else { return kAudioHardwareBadObjectError }

        return setProperty(address: address, value: 0)
    }

    /// Attempts to set the `pid` that currently owns exclusive access to the
    /// audio device.
    ///
    /// - Returns: `true` on success, `false` otherwise.
    @discardableResult
    func setHogMode() -> OSStatus {
        guard hogModePID != pid_t(ProcessInfo.processInfo.processIdentifier) else { return kAudioHardwareBadObjectError }

        return toggleHogMode()
    }

    /// Attempts to make the audio device available to all processes by setting
    /// the hog mode to `-1`.
    ///
    /// - Returns: `true` on success, `false` otherwise.
    @discardableResult
    func unsetHogMode() -> OSStatus {
        guard hogModePID == pid_t(ProcessInfo.processInfo.processIdentifier) else { return kAudioHardwareBadObjectError }

        return toggleHogMode()
    }
}

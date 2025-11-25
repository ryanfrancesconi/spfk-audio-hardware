// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation

/// List of supported `SimplyCoreAudio` notifications.
extension Notification.Name {
    // MARK: - Audio Hardware Notifications

    /// Called whenever the default input device changes.
    public static let defaultInputDeviceChanged = Self("defaultInputDeviceChanged")

    /// Called whenever the default output device changes.
    public static let defaultOutputDeviceChanged = Self("defaultOutputDeviceChanged")

    /// Called whenever the default system output device changes.
    public static let defaultSystemOutputDeviceChanged = Self("defaultSystemOutputDeviceChanged")

    /// Called whenever the list of hardware devices and device subdevices changes.
    /// (i.e., devices that are part of *Aggregate* or *Multi-Output* devices.)
    ///
    /// Returned `userInfo` object will contain the keys `addedDevices` and `removedDevices`.
    public static let deviceListChanged = Self("deviceListChanged")

    // MARK: - Audio Device Notifications

    /// Called whenever the audio device's sample rate changes.
    public static let deviceNominalSampleRateDidChange = Self("deviceNominalSampleRateDidChange")

    /// Called whenever the audio device's list of nominal sample rates changes.
    ///
    /// - Note: This will typically happen on *Aggregate* and *Multi-Output* devices when adding or removing other
    /// audio devices (either physical or virtual.)
    public static let deviceAvailableNominalSampleRatesDidChange = Self("deviceAvailableNominalSampleRatesDidChange")

    /// Called whenever the audio device's clock source changes.
    public static let deviceClockSourceDidChange = Self("deviceClockSourceDidChange")

    /// Called whenever the audio device's name changes.
    public static let deviceNameDidChange = Self("deviceNameDidChange")

    /// Called whenever the list of owned audio devices on this audio device changes.
    ///
    /// - Note: This will typically happen on *Aggregate* and *Multi-Output* devices when adding or removing other
    /// audio devices (either physical or virtual.)
    public static let deviceOwnedObjectsDidChange = Self("deviceOwnedObjectsDidChange")

    /// Called whenever the audio device's volume for a given channel and scope changes.
    ///
    /// Returned `userInfo` object will contain the keys `channel` and `scope`.
    public static let deviceVolumeDidChange = Self("deviceVolumeDidChange")

    /// Called whenever the audio device's mute state for a given channel and scope changes.
    ///
    /// Returned `userInfo` object will contain the keys `channel` and `scope`.
    public static let deviceMuteDidChange = Self("deviceMuteDidChange")

    /// Called whenever the audio device's *is alive* property changes.
    public static let deviceIsAliveDidChange = Self("deviceIsAliveDidChange")

    /// Called whenever the audio device's *is running* property changes.
    public static let deviceIsRunningDidChange = Self("deviceIsRunningDidChange")

    /// Called whenever the audio device's *is running somewhere* property changes.
    public static let deviceIsRunningSomewhereDidChange = Self("deviceIsRunningSomewhereDidChange")

    /// Called whenever the audio device's *is jack connected* property changes.
    public static let deviceIsJackConnectedDidChange = Self("deviceIsJackConnectedDidChange")

    /// Called whenever the audio device's *preferred channels for stereo* property changes.
    public static let devicePreferredChannelsForStereoDidChange = Self("devicePreferredChannelsForStereoDidChange")

    /// Called whenever the audio device's *hog mode* property changes.
    public static let deviceHogModeDidChange = Self("deviceHogModeDidChange")

    /// Called when the AudioDevice detects that an IO cycle has
    /// run past its deadline. Note that the notification for this property is
    /// usually sent from the AudioDevice's IO thread.
    public static let deviceProcessorOverload = Self("deviceProcessorOverload")

    /// Called when IO on the device has stopped outside of the
    /// normal mechanisms. This typically comes up when IO is stopped after
    /// AudioDeviceStart has returned successfully but prior to the notification for
    /// kAudioDevicePropertyIsRunning being sent.
    public static let deviceIOStoppedAbnormally = Self("deviceIOStoppedAbnormally")

    // MARK: - Audio Stream Notifications

    /// Called whenever the audio stream `isActive` flag changes.
    public static let streamIsActiveDidChange = Self("streamIsActiveDidChange")

    /// Called whenever the audio stream physical format changes.
    public static let streamPhysicalFormatDidChange = Self("streamPhysicalFormatDidChange")
}

extension Notification.Name {
    fileprivate init(_ name: String) {
        self.init(rawValue: "SPFKAudioHardware.\(name)")
    }
}

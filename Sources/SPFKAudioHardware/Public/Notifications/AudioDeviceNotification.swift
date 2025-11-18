// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

public enum AudioDeviceNotification: Hashable {
    /// Called whenever the audio device's sample rate changes.
    case deviceNominalSampleRateDidChange

    /// Called whenever the audio device's list of nominal sample rates changes.
    ///
    /// - Note: This will typically happen on *Aggregate* and *Multi-Output* devices when adding or removing other
    /// audio devices (either physical or virtual.)
    case deviceAvailableNominalSampleRatesDidChange

    /// Called whenever the audio device's clock source changes.
    case deviceClockSourceDidChange

    /// Called whenever the audio device's name changes.
    case deviceNameDidChange

    /// Called whenever the list of owned audio devices on this audio device changes.
    ///
    /// - Note: This will typically happen on *Aggregate* and *Multi-Output* devices when adding or removing other
    /// audio devices (either physical or virtual.)
    case deviceOwnedObjectsDidChange

    /// Called whenever the audio device's volume for a given channel and scope changes.
    /// Event will contain  `channel` and `scope`.
    case deviceVolumeDidChange(channel: AudioObjectPropertyElement, scope: Scope)

    /// Called whenever the audio device's mute state for a given channel and scope changes.
    /// Event will contain  `channel` and `scope`.
    case deviceMuteDidChange(channel: AudioObjectPropertyElement, scope: Scope)

    /// Called whenever the audio device's *is alive* property changes.
    case deviceIsAliveDidChange

    /// Called whenever the audio device's *is running* property changes.
    case deviceIsRunningDidChange

    /// Called whenever the audio device's *is running somewhere* property changes.
    case deviceIsRunningSomewhereDidChange

    /// Called whenever the audio device's *is jack connected* property changes.
    case deviceIsJackConnectedDidChange

    /// Called whenever the audio device's *preferred channels for stereo* property changes.
    case devicePreferredChannelsForStereoDidChange

    /// Called whenever the audio device's *hog mode* property changes.
    case deviceHogModeDidChange

    /// Called when the AudioDevice detects that an IO cycle has
    /// run past its deadline. Note that the notification for this property is
    /// usually sent from the AudioDevice's IO thread.
    case deviceProcessorOverload

    /// Called when IO on the device has stopped outside of the
    /// normal mechanisms. This typically comes up when IO is stopped after
    /// AudioDeviceStart has returned successfully but prior to the notification for
    /// kAudioDevicePropertyIsRunning being sent.
    case deviceIOStoppedAbnormally
}

extension AudioDeviceNotification: PropertyAddressNotification {
    public init?(propertyAddress: AudioObjectPropertyAddress) {
        switch propertyAddress.mSelector {
        case kAudioDevicePropertyNominalSampleRate:
            self = .deviceNominalSampleRateDidChange

        case kAudioDevicePropertyAvailableNominalSampleRates:
            self = .deviceAvailableNominalSampleRatesDidChange

        case kAudioDevicePropertyClockSource:
            self = .deviceClockSourceDidChange

        case kAudioObjectPropertyName:
            self = .deviceNameDidChange

        case kAudioObjectPropertyOwnedObjects:
            self = .deviceOwnedObjectsDidChange

        case kAudioDevicePropertyVolumeScalar:
            self = .deviceVolumeDidChange(channel: propertyAddress.mElement, scope: Scope(propertyScope: propertyAddress.mScope))

        case kAudioDevicePropertyMute:
            self = .deviceMuteDidChange(channel: propertyAddress.mElement, scope: Scope(propertyScope: propertyAddress.mScope))

        case kAudioDevicePropertyDeviceIsAlive:
            self = .deviceIsAliveDidChange

        case kAudioDevicePropertyDeviceIsRunning:
            self = .deviceIsRunningDidChange

        case kAudioDevicePropertyDeviceIsRunningSomewhere:
            self = .deviceIsRunningSomewhereDidChange

        case kAudioDevicePropertyJackIsConnected:
            self = .deviceIsJackConnectedDidChange

        case kAudioDevicePropertyPreferredChannelsForStereo:
            self = .devicePreferredChannelsForStereoDidChange

        case kAudioDevicePropertyHogMode:
            self = .deviceHogModeDidChange

        case kAudioDeviceProcessorOverload:
            self = .deviceProcessorOverload

        case kAudioDevicePropertyIOStoppedAbnormally:
            self = .deviceIOStoppedAbnormally

        default:
            return nil
        }
    }
}

// MARK: For NotificationCenter events

extension AudioDeviceNotification {
    public var name: Notification.Name {
        switch self {
        case .deviceNominalSampleRateDidChange:
            .deviceNominalSampleRateDidChange
        case .deviceAvailableNominalSampleRatesDidChange:
            .deviceAvailableNominalSampleRatesDidChange
        case .deviceClockSourceDidChange:
            .deviceClockSourceDidChange
        case .deviceNameDidChange:
            .deviceNameDidChange
        case .deviceOwnedObjectsDidChange:
            .deviceOwnedObjectsDidChange
        case .deviceVolumeDidChange:
            .deviceVolumeDidChange
        case .deviceMuteDidChange:
            .deviceMuteDidChange
        case .deviceIsAliveDidChange:
            .deviceIsAliveDidChange
        case .deviceIsRunningDidChange:
            .deviceIsRunningDidChange
        case .deviceIsRunningSomewhereDidChange:
            .deviceIsRunningSomewhereDidChange
        case .deviceIsJackConnectedDidChange:
            .deviceIsJackConnectedDidChange
        case .devicePreferredChannelsForStereoDidChange:
            .devicePreferredChannelsForStereoDidChange
        case .deviceHogModeDidChange:
            .deviceHogModeDidChange
        case .deviceProcessorOverload:
            .deviceProcessorOverload
        case .deviceIOStoppedAbnormally:
            .deviceIOStoppedAbnormally
        }
    }
}

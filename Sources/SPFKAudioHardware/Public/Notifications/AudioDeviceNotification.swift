// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation
import SPFKBase

public enum AudioDeviceNotification: Hashable, Sendable {
    /// Called whenever the audio device's sample rate changes.
    case deviceNominalSampleRateDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's list of nominal sample rates changes.
    ///
    /// - Note: This will typically happen on *Aggregate* and *Multi-Output* devices when adding or removing other
    /// audio devices (either physical or virtual.)
    case deviceAvailableNominalSampleRatesDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's clock source changes.
    case deviceClockSourceDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's name changes.
    case deviceNameDidChange(objectID: AudioObjectID)

    /// Called whenever the list of owned audio devices on this audio device changes.
    ///
    /// - Note: This will typically happen on *Aggregate* and *Multi-Output* devices when adding or removing other
    /// audio devices (either physical or virtual.)
    case deviceOwnedObjectsDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's volume for a given channel and scope changes.
    /// Event will contain  `channel` and `scope`.
    case deviceVolumeDidChange(objectID: AudioObjectID, channel: AudioObjectPropertyElement, scope: Scope)

    /// Called whenever the audio device's mute state for a given channel and scope changes.
    /// Event will contain  `channel` and `scope`.
    case deviceMuteDidChange(objectID: AudioObjectID, channel: AudioObjectPropertyElement, scope: Scope)

    /// Called whenever the audio device's *is alive* property changes.
    case deviceIsAliveDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's *is running* property changes.
    case deviceIsRunningDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's *is running somewhere* property changes.
    case deviceIsRunningSomewhereDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's *is jack connected* property changes.
    case deviceIsJackConnectedDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's *preferred channels for stereo* property changes.
    case devicePreferredChannelsForStereoDidChange(objectID: AudioObjectID)

    /// Called whenever the audio device's *hog mode* property changes.
    case deviceHogModeDidChange(objectID: AudioObjectID)

    /// Called when the AudioDevice detects that an IO cycle has
    /// run past its deadline. Note that the notification for this property is
    /// usually sent from the AudioDevice's IO thread.
    case deviceProcessorOverload(objectID: AudioObjectID)

    /// Called when IO on the device has stopped outside of the
    /// normal mechanisms. This typically comes up when IO is stopped after
    /// AudioDeviceStart has returned successfully but prior to the notification for
    /// kAudioDevicePropertyIsRunning being sent.
    case deviceIOStoppedAbnormally(objectID: AudioObjectID)
}

extension AudioDeviceNotification: PropertyAddressNotification {
    public init?(objectID: AudioObjectID, propertyAddress: AudioObjectPropertyAddress) {
        switch propertyAddress.mSelector {
        case kAudioDevicePropertyNominalSampleRate:
            self = .deviceNominalSampleRateDidChange(objectID: objectID)

        case kAudioDevicePropertyAvailableNominalSampleRates:
            self = .deviceAvailableNominalSampleRatesDidChange(objectID: objectID)

        case kAudioDevicePropertyClockSource:
            self = .deviceClockSourceDidChange(objectID: objectID)

        case kAudioObjectPropertyName:
            self = .deviceNameDidChange(objectID: objectID)

        case kAudioObjectPropertyOwnedObjects:
            self = .deviceOwnedObjectsDidChange(objectID: objectID)

        case kAudioDevicePropertyVolumeScalar:
            self = .deviceVolumeDidChange(
                objectID: objectID,
                channel: propertyAddress.mElement,
                scope: Scope(propertyScope: propertyAddress.mScope)
            )

        case kAudioDevicePropertyMute:
            self = .deviceMuteDidChange(
                objectID: objectID,
                channel: propertyAddress.mElement,
                scope: Scope(propertyScope: propertyAddress.mScope)
            )

        case kAudioDevicePropertyDeviceIsAlive:
            self = .deviceIsAliveDidChange(objectID: objectID)

        case kAudioDevicePropertyDeviceIsRunning:
            self = .deviceIsRunningDidChange(objectID: objectID)

        case kAudioDevicePropertyDeviceIsRunningSomewhere:
            self = .deviceIsRunningSomewhereDidChange(objectID: objectID)

        case kAudioDevicePropertyJackIsConnected:
            self = .deviceIsJackConnectedDidChange(objectID: objectID)

        case kAudioDevicePropertyPreferredChannelsForStereo:
            self = .devicePreferredChannelsForStereoDidChange(objectID: objectID)

        case kAudioDevicePropertyHogMode:
            self = .deviceHogModeDidChange(objectID: objectID)

        case kAudioDeviceProcessorOverload:
            self = .deviceProcessorOverload(objectID: objectID)

        case kAudioDevicePropertyIOStoppedAbnormally:
            self = .deviceIOStoppedAbnormally(objectID: objectID)

        case kAudioAggregateDevicePropertyMainSubDevice:
            Log.error("kAudioAggregateDevicePropertyMainSubDevice")
            return nil

        default:
            Log.error("AudioDeviceNotification: unhandled mSelector (\(propertyAddress.mSelector.fourCC))")
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

extension AudioDeviceNotification {
    public func getAudioDevice() async -> AudioDevice? {
        var id: AudioObjectID

        switch self {
        case let .deviceNominalSampleRateDidChange(objectID: objectID):
            id = objectID
        case let .deviceAvailableNominalSampleRatesDidChange(objectID: objectID):
            id = objectID
        case let .deviceClockSourceDidChange(objectID: objectID):
            id = objectID
        case let .deviceNameDidChange(objectID: objectID):
            id = objectID
        case let .deviceOwnedObjectsDidChange(objectID: objectID):
            id = objectID
        case let .deviceVolumeDidChange(objectID: objectID, channel: _, scope: _):
            id = objectID
        case let .deviceMuteDidChange(objectID: objectID, channel: _, scope: _):
            id = objectID
        case let .deviceIsAliveDidChange(objectID: objectID):
            id = objectID
        case let .deviceIsRunningDidChange(objectID: objectID):
            id = objectID
        case let .deviceIsRunningSomewhereDidChange(objectID: objectID):
            id = objectID
        case let .deviceIsJackConnectedDidChange(objectID: objectID):
            id = objectID
        case let .devicePreferredChannelsForStereoDidChange(objectID: objectID):
            id = objectID
        case let .deviceHogModeDidChange(objectID: objectID):
            id = objectID
        case let .deviceProcessorOverload(objectID: objectID):
            id = objectID
        case let .deviceIOStoppedAbnormally(objectID: objectID):
            id = objectID
        }

        return await AudioObjectPool.shared.lookup(id: id)
    }
}

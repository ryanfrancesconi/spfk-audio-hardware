// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKAudioHardwareC
import SPFKBase

extension AudioStream {
    /// Returns whether this audio stream is enabled and doing I/O.
    ///
    /// - Returns: `true` when enabled, `false` otherwise.
    public var active: Bool {
        guard let address = validAddress(selector: kAudioStreamPropertyIsActive) else { return false }

        var active: UInt32 = 0
        guard noErr == getPropertyData(address, andValue: &active) else { return false }

        return active == 1
    }

    /// Specifies the first element in the owning device that corresponds to the element one of this stream.
    ///
    /// - Returns: *(optional)* A `UInt32`.
    public var startingChannel: UInt32? {
        guard let address = validAddress(selector: kAudioStreamPropertyStartingChannel) else { return nil }

        var startingChannel: UInt32 = 0
        guard noErr == self.getPropertyData(address, andValue: &startingChannel) else { return nil }

        return startingChannel
    }

    /// Describes the general kind of functionality attached to this stream.
    ///
    /// - Return: A `TerminalType`.
    public var terminalType: TerminalType {
        guard let address = validAddress(selector: kAudioStreamPropertyTerminalType) else { return .unknown }

        var terminalType: UInt32 = 0
        guard noErr == getPropertyData(address, andValue: &terminalType) else { return .unknown }

        return .from(terminalType)
    }

    /// The latency in frames for this stream.
    ///
    /// Note that the owning `AudioDevice` may have additional latency so it should be
    /// queried as well. If both the device and the stream say they have latency,
    /// then the total latency for the stream is the device latency summed with the
    /// stream latency.
    ///
    /// - Returns: *(optional)* A `UInt32` value with the latency in frames.
    public var latency: UInt32? {
        guard let address = validAddress(selector: kAudioStreamPropertyLatency) else { return nil }

        var latency: UInt32 = 0
        guard noErr == getPropertyData(address, andValue: &latency) else { return nil }

        return latency
    }

    /// The audio stream's scope.
    ///
    /// For output streams, and to continue using the same `Scope` concept used by `AudioDevice`,
    /// this will be `Scope.output`, likewise, for input streams, `Scope.input` will be returned.
    ///
    /// - Returns: *(optional)* A `Scope`.
    public var scope: Scope? {
        guard let address = validAddress(selector: kAudioStreamPropertyDirection) else { return nil }

        var propertyScope: UInt32 = 0
        guard noErr == getPropertyData(address, andValue: &propertyScope) else { return nil }

        switch propertyScope {
        case 0: return .output
        case 1: return .input
        default: return nil
        }
    }

    /// An `AudioStreamBasicDescription` that describes the current data format for this audio stream.
    ///
    /// - SeeAlso: `virtualFormat`
    ///
    /// - Returns: *(optional)* An `AudioStreamBasicDescription`.
    public var physicalFormat: AudioStreamBasicDescription? {
        get {
            var asbd = AudioStreamBasicDescription()
            guard noErr == getStreamPropertyData(kAudioStreamPropertyPhysicalFormat, andValue: &asbd) else { return nil }

            return asbd
        }

        set {
            var asbd = newValue

            if noErr != setStreamPropertyData(kAudioStreamPropertyPhysicalFormat, andValue: &asbd) {
                Log.debug("Error setting physicalFormat to", newValue)
            }
        }
    }

    /// An `AudioStreamBasicDescription` that describes the current virtual data format for this audio stream.
    ///
    /// - SeeAlso: `physicalFormat`
    ///
    /// - Returns: *(optional)* An `AudioStreamBasicDescription`.
    public var virtualFormat: AudioStreamBasicDescription? {
        get {
            var asbd = AudioStreamBasicDescription()
            guard noErr == getStreamPropertyData(kAudioStreamPropertyVirtualFormat, andValue: &asbd) else { return nil }

            return asbd
        }

        set {
            var asbd = newValue

            if noErr != setStreamPropertyData(kAudioStreamPropertyVirtualFormat, andValue: &asbd) {
                Log.debug("Error setting virtualFormat to", newValue)
            }
        }
    }
}

extension AudioStream {
    func getAvailablePhysicalFormats() -> [AudioStreamRangedDescription]? {
        guard let scope else { return nil }

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioStreamPropertyAvailablePhysicalFormats,
            mScope: scope.propertyScope,
            mElement: Element.main.propertyElement
        )

        guard AudioObjectHasProperty(objectID, &address) else { return nil }

        var asrd = [AudioStreamRangedDescription]()
        guard noErr == getPropertyDataArray(address, value: &asrd, andDefaultValue: AudioStreamRangedDescription()) else {
            return nil
        }

        return asrd
    }

    func getAvailableVirtualFormats() -> [AudioStreamRangedDescription]? {
        guard let scope else { return nil }

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioStreamPropertyAvailableVirtualFormats,
            mScope: scope.propertyScope,
            mElement: Element.main.propertyElement
        )

        guard AudioObjectHasProperty(objectID, &address) else { return nil }

        var asrd = [AudioStreamRangedDescription]()
        guard noErr == getPropertyDataArray(address, value: &asrd, andDefaultValue: AudioStreamRangedDescription()) else {
            return nil
        }

        return asrd
    }
}

// MARK: - Private Functions

private extension AudioStream {
    /// This is an specialized version of `getPropertyData` that only requires passing an `AudioObjectPropertySelector`
    /// instead of an `AudioObjectPropertyAddress`. The scope is computed from the stream's `Scope`, and the element
    /// is assumed to be `kAudioObjectPropertyElementMain`.
    ///
    /// Additionally, the property address is validated before calling `getPropertyData`.
    ///
    /// - Parameter selector: The `AudioObjectPropertySelector` that points to the property we want to get.
    /// - Parameter value: The value that will be returned.
    ///
    /// - Returns: An `OSStatus` with `noErr` on success, or an error code other than `noErr` when it fails.
    func getStreamPropertyData<T>(_ selector: AudioObjectPropertySelector, andValue value: inout T) -> OSStatus? {
        guard let scope else { return nil }

        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope.propertyScope,
            mElement: Element.main.propertyElement
        )

        guard AudioObjectHasProperty(objectID, &address) else { return nil }

        return getPropertyData(address, andValue: &value)
    }

    /// This is an specialized version of `setPropertyData` that only requires passing an `AudioObjectPropertySelector`
    /// instead of an `AudioObjectPropertyAddress`. The scope is computed from the stream's `Scope`, and the element
    /// is assumed to be `kAudioObjectPropertyElementMain`.
    ///
    /// Additionally, the property address is validated before calling `setPropertyData`.
    ///
    /// - Parameter selector: The `AudioObjectPropertySelector` that points to the property we want to set.
    /// - Parameter value: The new value we want to set.
    ///
    /// - Returns: An `OSStatus` with `noErr` on success, or an error code other than `noErr` when it fails.
    func setStreamPropertyData<T>(_ selector: AudioObjectPropertySelector, andValue value: inout T) -> OSStatus? {
        guard let scope else { return nil }

        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope.propertyScope,
            mElement: Element.main.propertyElement
        )

        guard AudioObjectHasProperty(objectID, &address) else { return nil }

        return setPropertyData(address, andValue: &value)
    }
}

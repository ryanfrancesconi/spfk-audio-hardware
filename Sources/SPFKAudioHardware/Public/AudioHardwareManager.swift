// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import Atomics
import CoreAudio
import Foundation
import SPFKBase

/// This class provides convenient audio hardware-related functions (e.g. obtaining all devices managed by
/// [Core Audio](https://developer.apple.com/documentation/coreaudio)) and allows audio hardware-related notifications
/// to work. Additionally, you may create and remove aggregate devices using this class.
///
/// - Important: If you are interested in receiving hardware-related notifications, remember to keep a strong reference
/// to an object of this class.
public final class AudioHardwareManager {
    // MARK: - Private Static Properties

    private static var sharedHardware: AudioHardware!
    private static let instances = ManagedAtomic<Int>(0)

    // MARK: - Private Properties

    let hardware: AudioHardware

    private var instanceId: Int

    // MARK: - Lifecycle

    public init() async {
        instanceId = Self.instances.load(ordering: .acquiring)

        if instanceId == 0 {
            Self.sharedHardware = AudioHardware()
            await Self.sharedHardware.startListening()
        }

        Self.instances.wrappingIncrement(ordering: .acquiring)

        hardware = Self.sharedHardware

        Log.debug("+ { \(self) }")
    }

    public func dispose() async {
        Self.instances.wrappingDecrement(ordering: .acquiring)

        if Self.instances.load(ordering: .acquiring) == 0 {
            await Self.sharedHardware.cache.unregisterKnownDevices()
            await Self.sharedHardware.stopListening()

            Self.sharedHardware = nil

            Log.debug("- { \(self) }")
        }
    }

    deinit {
        Log.debug("- { \(self) }")
    }
}

extension AudioHardwareManager: CustomStringConvertible {
    public var description: String {
        "AudioHardwareManager instanceId: \(instanceId)"
    }
}

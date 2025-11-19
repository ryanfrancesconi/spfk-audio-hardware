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

    private static var sharedHardware: AudioHardwareListener!
    private static let instances = ManagedAtomic<Int>(0)

    public var eventHandler: ((AudioHardwareNotification) -> Void)?

    // MARK: - Private Properties

    let hardware: AudioHardwareListener

    private var instanceId: Int

    public var postNotifications: Bool = true

    // MARK: - Lifecycle

    public init() async {
        instanceId = Self.instances.load(ordering: .acquiring)

        if instanceId == 0 {
            Self.sharedHardware = AudioHardwareListener()

            do {
                try await Self.sharedHardware.start()
            } catch {
                Log.error(error)
            }
        }

        Self.instances.wrappingIncrement(ordering: .acquiring)

        hardware = Self.sharedHardware

        hardware.eventHandler = { [weak self] notification in
            guard let self else { return }

            eventHandler?(notification)

            guard postNotifications else { return }

            NotificationCenter.default.post(
                name: notification.name,
                object: notification,
                userInfo: nil
            )
        }

        Log.debug("+ { \(self) }")
    }

    public func dispose() async {
        Self.instances.wrappingDecrement(ordering: .acquiring)

        if Self.instances.load(ordering: .acquiring) == 0 {
            do {
                try await Self.sharedHardware.stop()

                try await Self.sharedHardware.cache.unregister()
            } catch {
                Log.error(error)
            }

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

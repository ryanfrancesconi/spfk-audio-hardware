// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

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
    public var eventHandler: ((AudioHardwareNotification) -> Void)?
    public var postNotifications: Bool = true

    var observer: AudioHardwareObserver { AudioHardwareObserver.shared }

    // MARK: - Lifecycle

    private static let instances = ManagedAtomic<Int>(0)
    private var instanceId: Int

    public init() async {
        instanceId = Self.instances.load(ordering: .acquiring)

        if instanceId == 0 {
            observer.eventHandler = { [weak self] notification in
                guard let self else { return }
                send(notification: notification)
            }

            do {
                try await observer.start()
            } catch {
                Log.error(error)
            }

            Log.debug("🏁 (shared) + { \(self) }")
        }

        Self.instances.wrappingIncrement(ordering: .acquiring)

        Log.debug("+ { \(self) }")
    }

    public func dispose() async {
        Self.instances.wrappingDecrement(ordering: .acquiring)

        if Self.instances.load(ordering: .acquiring) == 0 {
            do {
                observer.eventHandler = nil
                try await observer.stop()
                try await observer.cache.unregister()
            } catch {
                Log.error(error)
            }

            Log.debug("⛔️ (shared) - { \(self) }")
        }
    }

    private func send(notification: AudioHardwareNotification) {
        eventHandler?(notification)

        guard postNotifications else { return }

        NotificationCenter.default.post(
            name: notification.name,
            object: notification,
            userInfo: nil
        )
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

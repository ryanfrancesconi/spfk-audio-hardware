//
//  SimplyCoreAudio.swift
//
//  Created by Ruben Nine on 20/3/21.
//

import Atomics
import CoreAudio
import Foundation

/// This class provides convenient audio hardware-related functions (e.g. obtaining all devices managed by
/// [Core Audio](https://developer.apple.com/documentation/coreaudio)) and allows audio hardware-related notifications
/// to work. Additionally, you may create and remove aggregate devices using this class.
///
/// - Important: If you are interested in receiving hardware-related notifications, remember to keep a strong reference
/// to an object of this class.
public final class SimplyCoreAudio {
    // MARK: - Private Static Properties

    private static var sharedHardware: AudioHardware!
    private static let instances = ManagedAtomic<Int>(0)

    // MARK: - Private Properties

    let hardware: AudioHardware

    private var instanceId: Int

    // MARK: - Lifecycle

    public init() {
        instanceId = Self.instances.load(ordering: .acquiring)

        if instanceId == 0 {
            Self.sharedHardware = AudioHardware()
            Self.sharedHardware.enableDeviceMonitoring()
        }

        Self.instances.wrappingIncrement(ordering: .acquiring)

        hardware = Self.sharedHardware
    }

    deinit {
        Self.instances.wrappingDecrement(ordering: .acquiring)

        if Self.instances.load(ordering: .acquiring) == 0 {
            Self.sharedHardware.disableDeviceMonitoring()
            Self.sharedHardware = nil
        }
    }
}

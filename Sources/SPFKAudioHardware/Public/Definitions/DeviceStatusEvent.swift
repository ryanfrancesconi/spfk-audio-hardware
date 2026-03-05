// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

/// Describes which audio devices were added or removed during a device list change event.
///
/// Delivered as part of an `AudioHardwareNotification.deviceListChanged` notification.
public struct DeviceStatusEvent: Hashable, Sendable {
    /// The devices that were added to the system.
    public private(set) var addedDevices: [AudioDevice]

    /// The devices that were removed from the system.
    public private(set) var removedDevices: [AudioDevice]

    /// All affected devices (both added and removed).
    public var allDevices: [AudioDevice] {
        addedDevices + removedDevices
    }

    /// Creates a device status event.
    ///
    /// - Parameters:
    ///   - addedDevices: Devices that were added. Defaults to an empty array.
    ///   - removedDevices: Devices that were removed. Defaults to an empty array.
    public init(addedDevices: [AudioDevice] = [], removedDevices: [AudioDevice] = []) {
        self.addedDevices = addedDevices
        self.removedDevices = removedDevices
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

/// A typed representation of a Core Audio property change notification.
///
/// Conforming enums (e.g., `AudioDeviceNotification`, `AudioStreamNotification`,
/// `AudioHardwareNotification`) map raw `AudioObjectPropertyAddress` values from
/// Core Audio callbacks into strongly-typed Swift cases, each with an associated
/// `Notification.Name` for use with `NotificationCenter`.
public protocol PropertyAddressNotification: Hashable, Sendable {
    /// The `Notification.Name` used when posting this notification to `NotificationCenter`.
    var name: Notification.Name { get }

    /// Creates a typed notification from a raw Core Audio property address.
    ///
    /// Returns `nil` if the property selector is not recognized by this type.
    ///
    /// - Parameters:
    ///   - objectID: The `AudioObjectID` that changed.
    ///   - propertyAddress: The property address describing which property changed.
    init?(objectID: AudioObjectID, propertyAddress: AudioObjectPropertyAddress)
}

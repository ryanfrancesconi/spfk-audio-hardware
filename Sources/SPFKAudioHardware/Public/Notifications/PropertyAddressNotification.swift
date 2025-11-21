// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

public protocol PropertyAddressNotification: Hashable, Sendable {
    var name: Notification.Name { get }

    init?(objectID: AudioObjectID, propertyAddress: AudioObjectPropertyAddress)
}

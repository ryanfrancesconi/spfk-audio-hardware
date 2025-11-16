// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation

public enum AudioStreamNotification: Hashable {
    /// Called whenever the audio stream `isActive` flag changes.
    case streamIsActiveDidChange

    /// Called whenever the audio stream physical format changes.
    case streamPhysicalFormatDidChange
}

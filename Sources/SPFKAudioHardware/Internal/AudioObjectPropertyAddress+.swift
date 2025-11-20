// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware

extension AudioObjectPropertyAddress {
    static var wildcard: AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertySelectorWildcard,
            mScope: kAudioObjectPropertyScopeWildcard,
            mElement: kAudioObjectPropertyElementWildcard
        )
    }

    /// A helper constructor for the AudioObjectPropertyAddress struct.
    /// - Parameters:
    ///   - selector: An AudioObjectPropertySelector four char code that identifies a property
    ///   - scope: An AudioObjectPropertyScope with a default value of kAudioObjectPropertyScopeGlobal
    ///   - element: An AudioObjectPropertyElement with a default value of kAudioObjectPropertyElementMain
    /// - Returns: An AudioObjectPropertyAddress collects these three parts that identify a specific
    /// property together in a struct for easy transmission.
    init(
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) {
        if #available(macOS 15, *) {
            self = PropertyAddress(selector, scope: scope, element: element)
        } else {
            self.init(mSelector: selector, mScope: scope, mElement: element)
        }
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation

/// Provides a single object that contains a channel name with its index and scope
public struct AudioDeviceNamedChannel: CustomStringConvertible, Equatable {
    public var description: String {
        var value = "\(scope.title) \(channel)"

        // MacBook air speakers Left channel is named "1". That's dumb.
        if let name, name != "", name != String(channel) {
            value = "\(channel + 1) - " + name
        }

        return value
    }

    public var channel: UInt32
    public var name: String?
    public var scope: Scope

    public init(channel: UInt32, name: String? = nil, scope: Scope) {
        self.channel = channel
        self.name = name
        self.scope = scope
    }
}

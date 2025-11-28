// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation

/// Provides a single object that contains a channel name with its index and scope
public struct AudioDeviceNamedChannel: CustomStringConvertible, Equatable, Sendable {
    public var description: String {
        var name: String? = name
        if name == "" { name = nil }
        let localName = name ?? "Input"

        return "\(channel + 1) - " + localName
    }

    public let channel: UInt32
    public let name: String?
    public let scope: Scope

    public init(channel: UInt32, name: String? = nil, scope: Scope) {
        self.channel = channel
        self.name = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scope = scope
    }
}

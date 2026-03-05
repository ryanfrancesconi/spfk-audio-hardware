// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import Foundation

/// Provides a single object that contains a channel name with its index and scope
public struct AudioDeviceNamedChannel: CustomStringConvertible, Equatable, Sendable {
    /// A formatted string in the form `"<1-based channel> - <name>"`, e.g. `"1 - Left"`.
    /// Falls back to `"Input"` if the channel has no name.
    public var description: String {
        var name: String? = name
        if name == "" { name = nil }
        let localName = name ?? "Input"

        return "\(channel + 1) - " + localName
    }

    public let channel: UInt32
    public let name: String?
    public let scope: Scope

    /// Creates a named channel entry.
    ///
    /// - Parameters:
    ///   - channel: The zero-based channel index.
    ///   - name: The channel name reported by Core Audio, or `nil` if unnamed.
    ///   - scope: The scope (input/output) this channel belongs to.
    public init(channel: UInt32, name: String? = nil, scope: Scope) {
        self.channel = channel
        self.name = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scope = scope
    }
}

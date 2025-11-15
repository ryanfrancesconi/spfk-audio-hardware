import Foundation

extension AudioDevice {
    /// Provides a single object that contains a channel name with its index and scope
    public struct NamedChannel: CustomStringConvertible, Equatable {
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

    /// - Returns: A collection of named channels
    public func namedChannels(scope: Scope) -> [NamedChannel] {
        var out = [NamedChannel]()

        let channelCount = channels(scope: scope)

        guard channelCount > 0 else { return [] }

        for i in 0 ..< channelCount {
            let string = name(channel: i, scope: scope)?.trimmingCharacters(in: .whitespacesAndNewlines)

            let deviceChannel = NamedChannel(
                channel: i,
                name: string,
                scope: scope
            )

            out.append(deviceChannel)
        }
        return out
    }
}

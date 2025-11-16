import Foundation

extension NotificationCenter {
    static func wait(for notificationName: Notification.Name) async throws -> Notification {
        let asyncSequence = NotificationCenter.default.notifications(named: notificationName)
        let iterator = asyncSequence.makeAsyncIterator()

        guard let notification = await iterator.next() else {
            throw NSError(description: "Failed to get \(notificationName)")
        }

        print(notification)

        return notification
    }
}

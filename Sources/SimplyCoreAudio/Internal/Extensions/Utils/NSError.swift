// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation

extension NSError {
    convenience init(
        description: String,
        domain: String = Bundle.main.bundleIdentifier ?? "SimplyCoreAudio",
        code: Int = 1
    ) {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
        ]

        self.init(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
    }
}

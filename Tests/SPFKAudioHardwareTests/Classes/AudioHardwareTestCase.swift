// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SPFKAudioHardware by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SPFKAudioHardware

import Foundation
@testable import SPFKAudioHardware
import SPFKBase
import Testing

/// Base for suites that touch Core Audio. The manager's lifecycle and the default devices
/// belong to ``HardwareStateTrait``, which every subclass suite must carry.
class AudioHardwareTestCase {
    let hardwareManager: AudioHardwareManager = .shared

    init() async throws {}

    deinit {
        Log.debug("- { AudioHardwareTestCase }")
    }
}

extension AudioHardwareTestCase {
    func wait(sec seconds: TimeInterval) async throws {
        try await Task.sleep(seconds: seconds)
    }

    /// Polls `condition` until it holds or `seconds` elapses.
    ///
    /// Core Audio applies property changes asynchronously with no bounded latency, so a fixed
    /// sleep races the device. Poll instead, and assert the value after this returns.
    func wait(sec seconds: TimeInterval, until condition: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(seconds)

        while !condition(), Date() < deadline {
            try await Task.sleep(seconds: 0.01)
        }
    }
}

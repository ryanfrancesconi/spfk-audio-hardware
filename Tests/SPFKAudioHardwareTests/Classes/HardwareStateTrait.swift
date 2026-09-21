// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import Foundation
@testable import SPFKAudioHardware
import SPFKBase
import Testing

/// Starts `AudioHardwareManager.shared` around each test case and returns Core Audio to the
/// state it found, whether the test passes, fails or throws.
///
/// A failure while restoring is recorded as an issue on the test rather than thrown, so one
/// failed step does not skip the steps after it.
struct HardwareStateTrait: SuiteTrait, TestTrait, TestScoping {
    let resetsNullDevice: Bool

    /// Recursive so the scope reaches each test case; a suite trait is otherwise consulted
    /// only for the suite itself.
    var isRecursive: Bool { true }

    func scopeProvider(for test: Test, testCase: Test.Case?) -> Self? {
        testCase == nil ? nil : self
    }

    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        let manager = AudioHardwareManager.shared
        try await manager.start()

        let defaultInput = await manager.defaultInputDevice
        let defaultOutput = await manager.defaultOutputDevice
        let defaultSystemOutput = await manager.defaultSystemOutputDevice

        defer {
            await restore(
                manager: manager,
                defaults: [
                    (defaultInput, .defaultInput),
                    (defaultOutput, .defaultOutput),
                    (defaultSystemOutput, .alertOutput),
                ]
            )
        }

        if resetsNullDevice {
            try await NullDeviceTestCase.resetNullDeviceState()
        }

        try await function()
    }

    private func restore(manager: AudioHardwareManager, defaults: [(AudioDevice?, DefaultSelectorType)]) async {
        if resetsNullDevice {
            // The null device rejects property writes while it is still a sub-device of an aggregate.
            await Self.recordingIssues { try await NullDeviceTestCase.removeAggregateDeviceIfPresent() }
            await Self.recordingIssues { try await NullDeviceTestCase.resetNullDeviceState() }
        }

        await Self.recordingIssues {
            for (device, selector) in defaults {
                try device?.promote(to: selector)
            }
        }

        await Self.recordingIssues { try await manager.unregister() }
        await Task.yield()
    }

    private static func recordingIssues(_ body: () async throws -> Void) async {
        do {
            try await body()
        } catch {
            Issue.record(error)
        }
    }
}

extension Trait where Self == HardwareStateTrait {
    /// Manager lifecycle and default devices.
    static var hardwareState: Self { .init(resetsNullDevice: false) }

    /// As ``hardwareState``, plus the Null Audio Device's properties and any aggregate built on it.
    static var nullDeviceState: Self { .init(resetsNullDevice: true) }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SPFKAudioHardware by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SPFKAudioHardware

import Foundation
@testable import SPFKAudioHardware
import SPFKBase
import Testing

class SCATestCase {
    var hardware: AudioHardwareManager

    private var defaultInputDevice: AudioDevice?
    private var defaultOutputDevice: AudioDevice?
    private var defaultSystemOutputDevice: AudioDevice?

    public init() async throws {
        hardware = await AudioHardwareManager()
        await saveDefaultDevices()
    }

    public func tearDown() async throws {
        try restoreDefaultDevices()
        await hardware.dispose()
    }

    deinit {
        Log.debug("- { SCATestCase }")
    }
}

// MARK: - Private Functions

private extension SCATestCase {
    func saveDefaultDevices() async {
        defaultInputDevice = await hardware.defaultInputDevice
        defaultOutputDevice = await hardware.defaultOutputDevice
        defaultSystemOutputDevice = await hardware.defaultSystemOutputDevice
    }

    func restoreDefaultDevices() throws {
        try defaultInputDevice?.promote(to: .defaultInput)
        try defaultOutputDevice?.promote(to: .defaultOutput)
        try defaultSystemOutputDevice?.promote(to: .alertOutput)
    }
}

extension SCATestCase {
    public func wait(sec seconds: TimeInterval) async throws {
        try await Task.sleep(seconds: seconds)
    }
}

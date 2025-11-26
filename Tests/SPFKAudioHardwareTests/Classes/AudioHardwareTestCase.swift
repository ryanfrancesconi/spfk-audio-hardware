// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SPFKAudioHardware by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SPFKAudioHardware

import Foundation
@testable import SPFKAudioHardware
import SPFKBase
import Testing

class AudioHardwareTestCase {
    let hardwareManager: AudioHardwareManager = .shared

    private var defaultInputDevice: AudioDevice?
    private var defaultOutputDevice: AudioDevice?
    private var defaultSystemOutputDevice: AudioDevice?

    init() async throws {
        try await hardwareManager.start()
        await saveDefaultDevices()
    }

    func tearDown() async throws {
        try restoreDefaultDevices()
        try await hardwareManager.dispose()
    }

    deinit {
        Log.debug("- { AudioHardwareTestCase }")
    }
}

// MARK: - Private Functions

extension AudioHardwareTestCase {
    fileprivate func saveDefaultDevices() async {
        defaultInputDevice = await hardwareManager.defaultInputDevice
        defaultOutputDevice = await hardwareManager.defaultOutputDevice
        defaultSystemOutputDevice = await hardwareManager.defaultSystemOutputDevice
    }

    fileprivate func restoreDefaultDevices() throws {
        try defaultInputDevice?.promote(to: .defaultInput)
        try defaultOutputDevice?.promote(to: .defaultOutput)
        try defaultSystemOutputDevice?.promote(to: .alertOutput)
    }
}

extension AudioHardwareTestCase {
    func wait(sec seconds: TimeInterval) async throws {
        try await Task.sleep(seconds: seconds)
    }
}

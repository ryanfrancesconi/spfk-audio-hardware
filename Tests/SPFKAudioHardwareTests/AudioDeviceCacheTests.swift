// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKAudioHardware

extension HardwareSuite {
    @Suite(.serialized, .tags(.hardware))
    struct AudioDeviceCacheTests {
        /// Core Audio posts a device-list change with no net change, so this is an ordinary outcome.
        @Test func anUnchangedDeviceListIsAnEmptyEvent() async throws {
            let cache = AudioDeviceCache()
            try await cache.start()

            let event = try await cache.update()
            #expect(event.addedDevices.isEmpty)
            #expect(event.removedDevices.isEmpty)
        }
    }
}

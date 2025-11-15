//
//  SimplyCoreAudioTests.swift
//
//  Created by Ruben Nine on 20/3/21.
//

import Testing
@testable import SimplyCoreAudio

class SimplyCoreAudioTests: SCATestCase2 {
    @Test func testDeviceEnumeration() throws {
        let device = try getNullDevice()

        #expect(simplyCA.allDevices.contains(device))
        #expect(simplyCA.allDeviceIDs.contains(device.id))
        #expect(simplyCA.allInputDevices.contains(device))
        #expect(simplyCA.allOutputDevices.contains(device))
        #expect(simplyCA.allIODevices.contains(device))
        #expect(simplyCA.allNonAggregateDevices.contains(device))
        #expect(!simplyCA.allAggregateDevices.contains(device))
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
import Foundation
import Testing

@testable import SPFKAudioHardware

@Suite
struct ScopeTests {
    @Test func propertyScopeRoundTrip() {
        let cases: [(Scope, AudioObjectPropertyScope)] = [
            (.global, kAudioObjectPropertyScopeGlobal),
            (.input, kAudioObjectPropertyScopeInput),
            (.output, kAudioObjectPropertyScopeOutput),
            (.playthrough, kAudioObjectPropertyScopePlayThrough),
            (.main, kAudioObjectPropertyElementMain),
            (.wildcard, kAudioObjectPropertyScopeWildcard),
        ]

        for (scope, constant) in cases {
            #expect(scope.propertyScope == constant, "propertyScope for \(scope)")
            #expect(Scope(propertyScope: constant) == scope, "init(propertyScope:) for \(scope)")
        }
    }

    @Test func unrecognizedPropertyScopeDefaultsToWildcard() {
        let scope = Scope(propertyScope: 0xDEAD_BEEF)
        #expect(scope == .wildcard)
    }
}

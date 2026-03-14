// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

/// Thread-safe, global-replaceable backend for CoreAudio calls.
///
/// In production, this always returns `CoreAudioBackend`. For testing,
/// `MockAudioBackend` can be installed via `_setForTesting`.
enum AudioBackend {
    nonisolated(unsafe) private static var _current: any AudioObjectBackend = CoreAudioBackend()

    static var current: any AudioObjectBackend { _current }

    /// Test-only entry point. NOT thread-safe during concurrent access.
    /// Must be called before any audio objects are created.
    static func _setForTesting(_ backend: any AudioObjectBackend) {
        _current = backend
    }

    static func _reset() {
        _current = CoreAudioBackend()
    }
}

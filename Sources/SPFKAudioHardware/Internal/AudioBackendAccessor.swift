// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

/// Thread-safe, global-replaceable backend for CoreAudio calls.
///
/// In production, this always returns `CoreAudioBackend`. For testing,
/// `MockAudioBackend` can be installed via `_setBackendForTesting`.
enum AudioBackendAccessor {
    nonisolated(unsafe) private static var _backend: any AudioObjectBackend = CoreAudioBackend()

    static var backend: any AudioObjectBackend { _backend }

    /// Test-only entry point. NOT thread-safe during concurrent access.
    /// Must be called before any audio objects are created.
    static func _setBackendForTesting(_ backend: any AudioObjectBackend) {
        _backend = backend
    }

    static func _resetBackend() {
        _backend = CoreAudioBackend()
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import Testing

extension Tag {
    /// Tests that require the NullAudioDevice driver or real audio hardware.
    @Tag static var hardware: Self

    /// Tests that wait for async notifications (NotificationCenter, Task.sleep delays).
    /// These are the most timing-sensitive and flaky tests.
    @Tag static var notification: Self
}

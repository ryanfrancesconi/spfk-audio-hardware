// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import Testing

/// Container for every suite that touches real Core Audio state.
///
/// `.serialized` applies recursively to nested suites, so only one of them runs at a time.
/// Marking each suite `.serialized` on its own does not do this — siblings still run
/// concurrently, and they share `AudioHardwareManager.shared` and one Null Audio Device.
@Suite(.serialized)
enum HardwareSuite {}

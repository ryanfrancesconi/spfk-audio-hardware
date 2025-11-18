// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import Foundation

// MARK: - Deprecated APIs

extension AudioDevice {
    // MARK: - Default Device Properties

//    /// Allows getting and setting this device as the default input device.
//    public var isDefaultInputDevice: Bool {
//        get { AudioDevice.defaultDevice(of: .defaultInput) == self }
//        set { _ = try? promote(to: .defaultInput) } // i don't like these as the error is ignored
//    }
//
//    /// Allows getting and setting this device as the default output device.
//    public var isDefaultOutputDevice: Bool {
//        get { AudioDevice.defaultDevice(of: .defaultOutput) == self }
//        set { _ = try? promote(to: .defaultOutput) }
//    }
//
//    /// Allows getting and setting this device as the default system output device.
//    public var isDefaultSystemOutputDevice: Bool {
//        get { AudioDevice.defaultDevice(of: .alertOutput) == self }
//        set { _ = try? promote(to: .alertOutput) }
//    }
}

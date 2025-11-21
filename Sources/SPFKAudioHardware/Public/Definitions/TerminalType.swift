// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation

/// Indicates the terminal type used by an `AudioStream`.
public enum TerminalType: String {
    /// Unknown
    case unknown = "Unknown"

    /// The ID for a terminal type of a line level stream.
    /// Note that this applies to both input streams and output streams.
    case line = "Line"

    /// A stream from/to a digital audio interface as defined by ISO 60958 (aka SPDIF or AES/EBU).
    /// Note that this applies to both input streams and output streams.
    case digitalAudioInterface = "Digital Audio Interface"

    /// Speaker
    case speaker = "Speaker"

    /// Headphones
    case headphones = "Headphones"

    /// Speaker for low frequency effects
    case lfeSpeaker = "LFE Speaker"

    /// A speaker on a telephone handset receiver
    case receiverSpeaker = "Receiver Speaker"

    /// A microphone
    case microphone = "Microphone"

    /// A microphone attached to an headset
    case headsetMicrophone = "Headset Microphone"

    /// A microphone on a telephone handset receiver
    case receiverMicrophone = "Receiver Microphone"

    /// A device providing a TTY signal
    case tty = "TTY"

    /// A stream from/to an HDMI port
    case hdmi = "HDMI"

    /// A stream from/to an DisplayPort port
    case displayPort = "DisplayPort"
}

// MARK: - Internal Functions

extension TerminalType {
    static func from(_ constant: UInt32) -> TerminalType {
        switch constant {
        case kAudioStreamTerminalTypeLine:
            .line
        case kAudioStreamTerminalTypeDigitalAudioInterface:
            .digitalAudioInterface
        case kAudioStreamTerminalTypeSpeaker:
            .speaker
        case kAudioStreamTerminalTypeHeadphones:
            .headphones
        case kAudioStreamTerminalTypeLFESpeaker:
            .lfeSpeaker
        case kAudioStreamTerminalTypeReceiverSpeaker:
            .receiverSpeaker
        case kAudioStreamTerminalTypeMicrophone:
            .microphone
        case kAudioStreamTerminalTypeHeadsetMicrophone:
            .headsetMicrophone
        case kAudioStreamTerminalTypeReceiverMicrophone:
            .receiverMicrophone
        case kAudioStreamTerminalTypeTTY:
            .tty
        case kAudioStreamTerminalTypeHDMI:
            .hdmi
        case kAudioStreamTerminalTypeDisplayPort:
            .displayPort
        case kAudioStreamTerminalTypeUnknown:
            fallthrough
        default:
            .unknown
        }
    }
}

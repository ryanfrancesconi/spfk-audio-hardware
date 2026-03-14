// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio

/// Abstracts the CoreAudio Hardware Abstraction Layer C API boundary.
///
/// This protocol provides a seam between the property access logic in
/// `AudioObjectModel` extensions and the actual CoreAudio C functions.
/// The default implementation (`CoreAudioBackend`) delegates directly to
/// the system C functions. A mock implementation can be substituted for testing.
protocol AudioObjectBackend: Sendable {
    // MARK: - Property Existence

    /// Whether the given audio object has the specified property.
    func hasProperty(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress
    ) -> Bool

    /// Whether the given property on the audio object can be set.
    func isPropertySettable(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        isSettable: inout DarwinBoolean
    ) -> OSStatus

    // MARK: - Get Property Data

    func getPropertyDataSize(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: inout UInt32
    ) -> OSStatus

    func getPropertyData(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: inout UInt32,
        data: UnsafeMutableRawPointer
    ) -> OSStatus

    // MARK: - Set Property Data

    func setPropertyData(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: UInt32,
        data: UnsafeRawPointer
    ) -> OSStatus

    // MARK: - Listeners

    func addPropertyListener(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        listener: AudioObjectPropertyListenerProc,
        clientData: UnsafeMutableRawPointer?
    ) -> OSStatus

    func removePropertyListener(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        listener: AudioObjectPropertyListenerProc,
        clientData: UnsafeMutableRawPointer?
    ) -> OSStatus
}

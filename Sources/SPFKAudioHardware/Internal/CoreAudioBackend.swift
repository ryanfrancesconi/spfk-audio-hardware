// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio

/// Production implementation that delegates directly to CoreAudio C functions.
/// This is a zero-behavioral-change wrapper.
struct CoreAudioBackend: AudioObjectBackend {
    func hasProperty(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress
    ) -> Bool {
        AudioObjectHasProperty(objectID, &address)
    }

    func isPropertySettable(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        isSettable: inout DarwinBoolean
    ) -> OSStatus {
        AudioObjectIsPropertySettable(objectID, &address, &isSettable)
    }

    func getPropertyDataSize(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: inout UInt32
    ) -> OSStatus {
        AudioObjectGetPropertyDataSize(objectID, &address, qualifierDataSize, qualifierData, &dataSize)
    }

    func getPropertyData(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: inout UInt32,
        data: UnsafeMutableRawPointer
    ) -> OSStatus {
        AudioObjectGetPropertyData(objectID, &address, qualifierDataSize, qualifierData, &dataSize, data)
    }

    func setPropertyData(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: UInt32,
        data: UnsafeRawPointer
    ) -> OSStatus {
        AudioObjectSetPropertyData(objectID, &address, qualifierDataSize, qualifierData, dataSize, data)
    }

    func addPropertyListener(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        listener: AudioObjectPropertyListenerProc,
        clientData: UnsafeMutableRawPointer?
    ) -> OSStatus {
        AudioObjectAddPropertyListener(objectID, &address, listener, clientData)
    }

    func removePropertyListener(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        listener: AudioObjectPropertyListenerProc,
        clientData: UnsafeMutableRawPointer?
    ) -> OSStatus {
        AudioObjectRemovePropertyListener(objectID, &address, listener, clientData)
    }
}

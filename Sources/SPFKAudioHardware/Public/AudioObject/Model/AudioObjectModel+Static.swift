// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import CoreFoundation
import SPFKBase

// MARK: - Get

extension AudioObjectModel {
    static func getPropertyDataArraySize(_ objectID: AudioObjectID,
                                         address: AudioObjectPropertyAddress,
                                         qualifierDataSize: UInt32?,
                                         qualifierData: inout [UInt32],
                                         andSize size: inout UInt32) -> OSStatus {
        var address = address
        var qualifierData = qualifierData
        let qualifierDataSize = qualifierDataSize ?? UInt32(0)

        let status: OSStatus = qualifierData.withUnsafeMutableBufferPointer { bufferPtr in
            AudioBackend.current.getPropertyDataSize(objectID,
                                                             address: &address,
                                                             qualifierDataSize: qualifierDataSize,
                                                             qualifierData: bufferPtr.baseAddress,
                                                             dataSize: &size)
        }

        return status
    }

    static func getPropertyDataSize<Q>(_ objectID: AudioObjectID,
                                       address: AudioObjectPropertyAddress,
                                       qualifierDataSize: UInt32?,
                                       qualifierData: inout Q,
                                       andSize size: inout UInt32) -> OSStatus {
        var address = address
        var qualifierData = qualifierData

        let status: OSStatus = withUnsafeMutablePointer(to: &qualifierData) { qualifierDataPtr in
            AudioBackend.current.getPropertyDataSize(objectID,
                                                             address: &address,
                                                             qualifierDataSize: qualifierDataSize ?? UInt32(0),
                                                             qualifierData: qualifierDataPtr,
                                                             dataSize: &size)
        }

        return status
    }
}

extension AudioObjectModel {
    static func getPropertyData<T>(_ objectID: AudioObjectID,
                                   address: AudioObjectPropertyAddress,
                                   andValue value: inout T) -> OSStatus {
        // CFString must be handled separately — it reads a reference type, not raw bytes of T.
        if value as? String != nil {
            return getStringPropertyData(objectID, address: address, andValue: &value)
        }

        // The backend uses UnsafeMutableRawPointer, so we can write directly into
        // the inout value for any T without per-type branching.
        var address = address
        var size = UInt32(MemoryLayout<T>.size)

        return withUnsafeMutablePointer(to: &value) { valuePtr in
            AudioBackend.current.getPropertyData(
                objectID,
                address: &address,
                qualifierDataSize: 0,
                qualifierData: nil,
                dataSize: &size,
                data: valuePtr
            )
        }
    }

    private static func getStringPropertyData<T>(_ objectID: AudioObjectID,
                                                 address: AudioObjectPropertyAddress,
                                                 andValue value: inout T) -> OSStatus {
        guard let string = value as? String else { return kAudioHardwareBadObjectError }

        var address = address
        var size = UInt32(MemoryLayout<T>.size)
        var cfString = string as CFString

        let returnValue = withUnsafeMutablePointer(to: &cfString) { cfStringPTR in
            let status = AudioBackend.current.getPropertyData(objectID, address: &address, qualifierDataSize: UInt32(0), qualifierData: nil, dataSize: &size, data: cfStringPTR)
            guard status == kAudioHardwareNoError else { return status }

            guard let erasedValue = cfStringPTR.pointee as? T else { return kAudioHardwareBadObjectError }

            value = erasedValue // assign inout T

            return status
        }

        return returnValue
    }
}

extension AudioObjectModel {
    static func getPropertyDataArray<T>(_ objectID: AudioObjectID,
                                        address: AudioObjectPropertyAddress,
                                        qualifierDataSize: UInt32?,
                                        qualifierData: inout [UInt32],
                                        value: inout [T],
                                        andDefaultValue defaultValue: T) -> OSStatus {
        var size = UInt32(0)
        let sizeStatus = getPropertyDataArraySize(objectID,
                                                  address: address,
                                                  qualifierDataSize: qualifierDataSize,
                                                  qualifierData: &qualifierData,
                                                  andSize: &size)

        if kAudioHardwareNoError == sizeStatus {
            value = [T](repeating: defaultValue, count: Int(size) / MemoryLayout<T>.size)
        } else {
            return sizeStatus
        }

        var address = address
        let qualifierDataSize = qualifierDataSize ?? UInt32(0)

        let status: OSStatus = value.withUnsafeMutableBufferPointer { bufferPtr in
            guard let baseAddress = bufferPtr.baseAddress else { return kAudioHardwareBadObjectError }
            return AudioBackend.current.getPropertyData(objectID, address: &address, qualifierDataSize: qualifierDataSize, qualifierData: &qualifierData, dataSize: &size, data: baseAddress)
        }

        return status
    }

    static func getPropertyDataArray<T>(_ objectID: AudioObjectID,
                                        address: AudioObjectPropertyAddress,
                                        value: inout [T],
                                        andDefaultValue defaultValue: T) -> OSStatus {
        var qualifierData: [UInt32] = []

        return getPropertyDataArray(objectID,
                                    address: address,
                                    qualifierDataSize: nil,
                                    qualifierData: &qualifierData,
                                    value: &value,
                                    andDefaultValue: defaultValue)
    }
}

// MARK: - Set

extension AudioObjectModel {
    static func setPropertyData<T>(_ objectID: AudioObjectID,
                                   address: AudioObjectPropertyAddress,
                                   andValue value: inout T) -> OSStatus {
        var address = address
        let size = UInt32(MemoryLayout<T>.size)
        var value = value

        let status: OSStatus = withUnsafeMutablePointer(to: &value) { valuePtr in
            AudioBackend.current.setPropertyData(objectID, address: &address, qualifierDataSize: UInt32(0), qualifierData: nil, dataSize: size, data: valuePtr)
        }

        return status
    }

    static func setPropertyDataArray<T>(_ objectID: AudioObjectID,
                                        address: AudioObjectPropertyAddress,
                                        andValue value: inout [T]) -> OSStatus {
        var address = address
        let size = UInt32(value.count * MemoryLayout<T>.size)

        let status: OSStatus = value.withUnsafeMutableBufferPointer { bufferPtr in
            guard let baseAddress = bufferPtr.baseAddress else { return kAudioHardwareBadObjectError }
            return AudioBackend.current.setPropertyData(objectID, address: &address, qualifierDataSize: UInt32(0), qualifierData: nil, dataSize: size, data: baseAddress)
        }

        return status
    }
}

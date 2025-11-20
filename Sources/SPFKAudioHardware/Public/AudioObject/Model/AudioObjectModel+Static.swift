// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

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

        let status: OSStatus = AudioObjectGetPropertyDataSize(objectID,
                                                              &address,
                                                              qualifierDataSize,
                                                              &qualifierData,
                                                              &size)

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
            AudioObjectGetPropertyDataSize(objectID,
                                           &address,
                                           qualifierDataSize ?? UInt32(0),
                                           qualifierDataPtr,
                                           &size)
        }

        return status
    }
}

extension AudioObjectModel {
    static func getPropertyData<T>(_ objectID: AudioObjectID,
                                   address: AudioObjectPropertyAddress,
                                   andValue value: inout T) -> OSStatus {
        /// check the output of AudioObjectGetPropertyData and set the inout value T
        func verify<Q>(status: OSStatus, typedValue: Q) -> OSStatus {
            guard status == kAudioHardwareNoError else { return status }
            guard let erasedValue = typedValue as? T else { return kAudioHardwareBadObjectError }
            value = erasedValue // assign inout T
            return status
        }

        // `AudioObjectGetPropertyData` doesn't want object types as generics.
        // These are the explicit types that currently in use.
        // Is there a better way to handle this?

        var address = address
        var size = UInt32(MemoryLayout<T>.size)
        let inQualifierDataSize: UInt32 = 0

        if value as? String != nil {
            // CFString must be handled differently
            return getStringPropertyData(objectID, address: address, andValue: &value)

        } else if var typedValue = value as? UInt32 {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else if var typedValue = value as? Int32 {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else if var typedValue = value as? Float32 {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else if var typedValue = value as? Float64 {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else if var typedValue = value as? AudioValueTranslation {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else if var typedValue = value as? AudioStreamBasicDescription {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else if var typedValue = value as? AudioChannelLayout {
            let status = AudioObjectGetPropertyData(objectID, &address, inQualifierDataSize, nil, &size, &typedValue)
            return verify(status: status, typedValue: typedValue)

        } else {
            assertionFailure("Unhandled type: \(value.self) \(value)")
        }

        return kAudioHardwareBadObjectError
    }

    private static func getStringPropertyData<T>(_ objectID: AudioObjectID,
                                                 address: AudioObjectPropertyAddress,
                                                 andValue value: inout T) -> OSStatus {
        guard let string = value as? String else { return kAudioHardwareBadObjectError }

        var address = address
        var size = UInt32(MemoryLayout<T>.size)
        var cfString = string as CFString

        let returnValue = withUnsafeMutablePointer(to: &cfString) { cfStringPTR in
            let status = AudioObjectGetPropertyData(objectID, &address, UInt32(0), nil, &size, cfStringPTR)
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
            return AudioObjectGetPropertyData(objectID, &address, qualifierDataSize, &qualifierData, &size, baseAddress)
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
            AudioObjectSetPropertyData(objectID, &address, UInt32(0), nil, size, valuePtr)
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
            return AudioObjectSetPropertyData(objectID, &address, UInt32(0), nil, size, baseAddress)
        }

        return status
    }
}

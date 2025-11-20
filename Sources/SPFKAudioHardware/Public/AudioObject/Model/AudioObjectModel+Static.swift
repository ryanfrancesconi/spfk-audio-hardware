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
        var theAddress = address
        var qualifierData = qualifierData
        let qualifierDataSize = qualifierDataSize ?? UInt32(0)

        let status: OSStatus = AudioObjectGetPropertyDataSize(objectID,
                                                              &theAddress,
                                                              qualifierDataSize,
                                                              &qualifierData,
                                                              &size)

        assert(status == kAudioHardwareNoError)
        return status
    }

    static func getPropertyDataSize<Q>(_ objectID: AudioObjectID,
                                       address: AudioObjectPropertyAddress,
                                       qualifierDataSize: UInt32?,
                                       qualifierData: inout Q,
                                       andSize size: inout UInt32) -> OSStatus {
        var theAddress = address
        var qualifierData = qualifierData

        let status: OSStatus = withUnsafeMutablePointer(to: &qualifierData) { qualifierDataPtr in
            AudioObjectGetPropertyDataSize(objectID,
                                           &theAddress,
                                           qualifierDataSize ?? UInt32(0),
                                           qualifierDataPtr,
                                           &size)
        }

        assert(status == kAudioHardwareNoError)
        return status
    }
}

extension AudioObjectModel {
//    static func address(selector: AudioObjectPropertySelector,
//                        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
//                        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain) -> AudioObjectPropertyAddress {
//        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
//    }

//    static func address(selector: AudioObjectPropertySelector,
//                        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
//                        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain) -> AudioObjectPropertyAddress {
//        AudioObjectPropertyAddress(selector: selector, scope: scope, element: element)
//    }

    static func getPropertyData<T>(_ objectID: AudioObjectID,
                                   address: AudioObjectPropertyAddress,
                                   andValue value: inout T) -> OSStatus {
        var theAddress = address
        var size = UInt32(MemoryLayout<T>.size)
        var status: OSStatus = kAudioHardwareBadObjectError

        func verify<Q>(status: OSStatus, localValue: Q) -> OSStatus {
            guard status == kAudioHardwareNoError else { return status }

            guard let unwrapped = localValue as? T else { return kAudioHardwareBadObjectError }
            // assign inout T
            value = unwrapped
            return status
        }

        // TODO: what is a better way to do this? a macro?

        if value as? String != nil {
            // CFString must be handled differently
            return getPropertyStringData(objectID, address: address, andValue: &value)

        } else if var localValue = value as? UInt32 {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else if var localValue = value as? Int32 {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else if var localValue = value as? Float32 {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else if var localValue = value as? Float64 {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else if var localValue = value as? AudioValueTranslation {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else if var localValue = value as? AudioStreamBasicDescription {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else if var localValue = value as? AudioChannelLayout {
            status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &localValue)
            status = verify(status: status, localValue: localValue)

        } else {
            assertionFailure("Unhandled type: \(value.self) \(value)")
        }

        return status
    }

    private static func getPropertyStringData<T>(_ objectID: AudioObjectID,
                                                 address: AudioObjectPropertyAddress,
                                                 andValue value: inout T) -> OSStatus {
        guard let localValue = value as? String else { return kAudioHardwareBadObjectError }

        var theAddress = address
        var size = UInt32(MemoryLayout<T>.size)
        var cfValue = localValue as CFString

        let returnValue = withUnsafeMutablePointer(to: &cfValue) { ptr in
            let status = AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, ptr)
            guard status == kAudioHardwareNoError else { return status }

            guard let unwrapped = ptr.pointee as? T else { return kAudioHardwareBadObjectError }

            // assign inout T
            value = unwrapped

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

        var theAddress = address
        let qualifierDataSize = qualifierDataSize ?? UInt32(0)

        let status: OSStatus = value.withUnsafeMutableBufferPointer { bufferPtr in
            guard let baseAddress = bufferPtr.baseAddress else { return kAudioHardwareBadObjectError }
            return AudioObjectGetPropertyData(objectID, &theAddress, qualifierDataSize, &qualifierData, &size, baseAddress)
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
        var theAddress = address
        let size = UInt32(MemoryLayout<T>.size)
        var value = value

        let status: OSStatus = withUnsafeMutablePointer(to: &value) { valuePtr in
            AudioObjectSetPropertyData(objectID, &theAddress, UInt32(0), nil, size, valuePtr)
        }

        return status
    }

    static func setPropertyDataArray<T>(_ objectID: AudioObjectID,
                                        address: AudioObjectPropertyAddress,
                                        andValue value: inout [T]) -> OSStatus {
        var theAddress = address
        let size = UInt32(value.count * MemoryLayout<T>.size)

        let status: OSStatus = value.withUnsafeMutableBufferPointer { bufferPtr in
            guard let baseAddress = bufferPtr.baseAddress else { return kAudioHardwareBadObjectError }
            return AudioObjectSetPropertyData(objectID, &theAddress, UInt32(0), nil, size, baseAddress)
        }

        return status
    }
}

// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio.AudioHardware
import SPFKBase

// MARK: - Class Functions

extension AudioObjectModel {
    static func address(selector: AudioObjectPropertySelector,
                        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
                        element: AudioObjectPropertyElement = Element.main.propertyElement) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
    }

    static func getPropertyDataSize<Q>(_ objectID: AudioObjectID,
                                       address: AudioObjectPropertyAddress,
                                       qualifierDataSize: UInt32?,
                                       qualifierData: inout [Q],
                                       andSize size: inout UInt32) -> (OSStatus) {
        var theAddress = address

        return AudioObjectGetPropertyDataSize(objectID,
                                              &theAddress,
                                              qualifierDataSize ?? UInt32(0),
                                              &qualifierData,
                                              &size)
    }

    static func getPropertyDataSize<Q>(_ objectID: AudioObjectID,
                                       address: AudioObjectPropertyAddress,
                                       qualifierDataSize: UInt32?,
                                       qualifierData: inout Q,
                                       andSize size: inout UInt32) -> (OSStatus) {
        var theAddress = address

        return AudioObjectGetPropertyDataSize(objectID,
                                              &theAddress,
                                              qualifierDataSize ?? UInt32(0),
                                              &qualifierData,
                                              &size)
    }

    static func getPropertyDataSize(_ objectID: AudioObjectID,
                                    address: AudioObjectPropertyAddress,
                                    andSize size: inout UInt32) -> (OSStatus) {
        var nilValue: ExpressibleByNilLiteral?

        return getPropertyDataSize(objectID,
                                   address: address,
                                   qualifierDataSize: nil,
                                   qualifierData: &nilValue,
                                   andSize: &size)
    }

    static func getPropertyData<T>(_ objectID: AudioObjectID,
                                   address: AudioObjectPropertyAddress,
                                   andValue value: inout T) -> OSStatus {
        var theAddress = address
        var size = UInt32(MemoryLayout<T>.size)

        return AudioObjectGetPropertyData(objectID, &theAddress, UInt32(0), nil, &size, &value)
    }

    static func getPropertyDataArray<T, Q>(_ objectID: AudioObjectID,
                                           address: AudioObjectPropertyAddress,
                                           qualifierDataSize: UInt32?,
                                           qualifierData: inout Q,
                                           value: inout [T],
                                           andDefaultValue defaultValue: T) -> OSStatus {
        var size = UInt32(0)

        let sizeStatus = getPropertyDataSize(objectID,
                                             address: address,
                                             qualifierDataSize: qualifierDataSize,
                                             qualifierData: &qualifierData,
                                             andSize: &size)

        if noErr == sizeStatus {
            value = [T](repeating: defaultValue, count: Int(size) / MemoryLayout<T>.size)
        } else {
            return sizeStatus
        }

        var theAddress = address

        return AudioObjectGetPropertyData(objectID,
                                          &theAddress,
                                          qualifierDataSize ?? UInt32(0),
                                          &qualifierData,
                                          &size,
                                          &value)
    }

    static func getPropertyDataArray<T, Q>(_ objectID: AudioObjectID,
                                           address: AudioObjectPropertyAddress,
                                           qualifierDataSize: UInt32?,
                                           qualifierData: inout [Q],
                                           value: inout [T],
                                           andDefaultValue defaultValue: T) -> OSStatus {
        var size = UInt32(0)
        let sizeStatus = getPropertyDataSize(objectID,
                                             address: address,
                                             qualifierDataSize: qualifierDataSize,
                                             qualifierData: &qualifierData,
                                             andSize: &size)

        if noErr == sizeStatus {
            value = [T](repeating: defaultValue, count: Int(size) / MemoryLayout<T>.size)
        } else {
            return sizeStatus
        }

        var theAddress = address

        return AudioObjectGetPropertyData(objectID,
                                          &theAddress,
                                          qualifierDataSize ?? UInt32(0),
                                          &qualifierData,
                                          &size,
                                          &value)
    }

    static func getPropertyDataArray<T>(_ objectID: AudioObjectID,
                                        address: AudioObjectPropertyAddress,
                                        value: inout [T],
                                        andDefaultValue defaultValue: T) -> OSStatus {
        var nilValue: ExpressibleByNilLiteral?

        return getPropertyDataArray(objectID,
                                    address: address,
                                    qualifierDataSize: nil,
                                    qualifierData: &nilValue,
                                    value: &value,
                                    andDefaultValue: defaultValue)
    }
}

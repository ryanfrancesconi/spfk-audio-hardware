// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

/// This protocol represents a [Core Audio](https://developer.apple.com/documentation/coreaudio) managed audio object.
/// In [Core Audio](https://developer.apple.com/documentation/coreaudio), audio objects are referenced by its
/// `AudioObjectID` and belong to a specific `AudioClassID`.
///
/// For more information, please refer to [Core Audio](https://developer.apple.com/documentation/coreaudio)'s
/// documentation or source code.
public protocol AudioObjectModel: Hashable {
    var objectID: AudioObjectID { get }
    init(objectID: AudioObjectID) async throws
}

extension AudioObjectModel {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    /// The hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
    }
}

extension AudioObjectModel {
    public var isAudioDevice: Bool {
        classID == kAudioDeviceClassID
    }

    public var isAudioStream: Bool {
        classID == kAudioStreamClassID
    }

    /// The `AudioClassID` that identifies the class of this audio object.
    ///
    /// - Returns: *(optional)* An `AudioClassID`.
    public var classID: AudioClassID? { // was lazy var
        guard let address = validAddress(selector: kAudioObjectPropertyClass) else { return nil }

        var acid = AudioClassID()

        guard kAudioHardwareNoError == getPropertyData(address, andValue: &acid) else { return nil }

        return acid
    }

    /// The audio object that owns this audio object.
    ///
    /// - Returns: *(optional)* An `AudioObjectOwner`.
    public func owningObject() async throws -> AudioObjectOwner? { // was lazy var
        guard let address = validAddress(selector: kAudioObjectPropertyOwner) else { return nil }

        var objectID = AudioObjectID()

        guard kAudioHardwareNoError == getPropertyData(address, andValue: &objectID) else { return nil }

        return try await AudioObjectOwner(objectID: objectID)
    }

    /// The audio device that owns this audio object.
    ///
    /// - Returns: *(optional)* An `AudioDevice`.
    public var owningDevice: AudioDevice? {
        get async {
            guard let object = try? await owningObject() else {
                Log.error("owningObject is nil")
                return nil
            }

            guard object.isAudioDevice else {
                Log.error("object.classID \(classID?.fourCharCodeToString() ?? String(describing: classID)) isn't an Audio Device")
                return nil
            }

            return await AudioObjectPool.shared.lookup(id: object.objectID)
        }
    }

    /// The audio object's name as reported by Core Audio.
    ///
    /// - Returns: *(optional)* An audio object's name.
    public var objectName: String? {
        var name: CFString = "" as CFString

        guard let address = validAddress(selector: kAudioObjectPropertyName) else { return nil }
        guard kAudioHardwareNoError == getPropertyData(address, andValue: &name) else { return nil }
        return name as String
    }
}

extension AudioObjectModel {
    func validAddress(
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) -> AudioObjectPropertyAddress? {
        var address = AudioObjectPropertyAddress(selector: selector, scope: scope, element: element)

        guard AudioObjectHasProperty(objectID, &address) else { return nil }

        return address
    }
}

extension AudioObjectModel {
    func getPropertyData<T>(_ address: AudioObjectPropertyAddress,
                            andValue value: inout T) -> OSStatus {
        Self.getPropertyData(objectID, address: address, andValue: &value)
    }

    func getPropertyDataArray<T>(_ address: AudioObjectPropertyAddress,
                                 qualifierDataSize: UInt32?,
                                 qualifierData: inout [UInt32],
                                 value: inout [T],
                                 andDefaultValue defaultValue: T) -> OSStatus {
        Self.getPropertyDataArray(objectID,
                                  address: address,
                                  qualifierDataSize: qualifierDataSize,
                                  qualifierData: &qualifierData,
                                  value: &value,
                                  andDefaultValue: defaultValue)
    }

    func getPropertyDataArray<T>(_ address: AudioObjectPropertyAddress,
                                 value: inout [T],
                                 andDefaultValue defaultValue: T) -> OSStatus {
        Self.getPropertyDataArray(objectID,
                                  address: address,
                                  value: &value,
                                  andDefaultValue: defaultValue)
    }

    func setPropertyData<T>(_ address: AudioObjectPropertyAddress,
                            andValue value: inout T) -> OSStatus {
        Self.setPropertyData(objectID, address: address, andValue: &value)
    }

    func setPropertyDataArray<T>(_ address: AudioObjectPropertyAddress,
                                 andValue value: inout [T]) -> OSStatus {
        Self.setPropertyDataArray(objectID, address: address, andValue: &value)
    }
}

extension AudioObjectModel {
    private func getProperty<T>(address: AudioObjectPropertyAddress, defaultValue: T) -> T? {
        var value = defaultValue
        let status = getPropertyData(address, andValue: &value)

        guard status == kAudioHardwareNoError else {
            Log.error("Failed to getProperty at address (\(address) with status (\(status.fourCharCodeToString())")
            return nil
        }

        return value
    }

    func getProperty(address: AudioObjectPropertyAddress) -> UInt32? {
        getProperty(address: address, defaultValue: UInt32(0))
    }

    func getProperty(address: AudioObjectPropertyAddress) -> Float32? {
        getProperty(address: address, defaultValue: Float32(0.0))
    }

    func getProperty(address: AudioObjectPropertyAddress) -> Float64? {
        getProperty(address: address, defaultValue: Float64(0.0))
    }

    func getProperty(address: AudioObjectPropertyAddress) -> String? {
        getProperty(address: address, defaultValue: "" as CFString) as String?
    }

    func getProperty(address: AudioObjectPropertyAddress) -> Bool? {
        guard let value = getProperty(address: address, defaultValue: UInt32(0)) else { return nil }
        return Bool(value)
    }

    func setProperty<T>(address: AudioObjectPropertyAddress, value: T) -> OSStatus {
        let status: OSStatus

        if let unwrappedValue = value as? Bool {
            var newValue: UInt32 = unwrappedValue == true ? 1 : 0
            status = setPropertyData(address, andValue: &newValue)

        } else if let unwrappedValue = value as? String {
            var newValue: CFString = unwrappedValue as CFString
            status = setPropertyData(address, andValue: &newValue)

        } else {
            var newValue = value
            status = setPropertyData(address, andValue: &newValue)
        }

        return status
    }
}

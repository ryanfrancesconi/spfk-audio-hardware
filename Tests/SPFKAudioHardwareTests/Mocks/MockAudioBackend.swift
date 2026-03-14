// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware

import CoreAudio
@testable import SPFKAudioHardware

/// A mock backend that returns preconfigured property data for testing.
///
/// Stores properties keyed by `(objectID, selector, scope, element)` and returns
/// them through the `AudioObjectBackend` protocol interface. Supports registering
/// scalar values, string (CFString) values, and array values.
///
/// Usage:
/// ```swift
/// let mock = MockAudioBackend()
/// mock.register(objectID: 42, selector: kAudioDevicePropertyTransportType, value: kAudioDeviceTransportTypeVirtual)
/// AudioBackendAccessor._setBackendForTesting(mock)
/// ```
final class MockAudioBackend: AudioObjectBackend, @unchecked Sendable {
    // MARK: - PropertyKey

    struct PropertyKey: Hashable {
        let objectID: AudioObjectID
        let selector: AudioObjectPropertySelector
        let scope: AudioObjectPropertyScope
        let element: AudioObjectPropertyElement
    }

    // MARK: - Storage

    /// Raw byte storage for each property.
    private var properties = [PropertyKey: Data]()

    /// String values stored separately for proper CFString handling.
    private var stringProperties = [PropertyKey: String]()

    /// Which properties exist (for hasProperty queries).
    private var existingProperties = Set<PropertyKey>()

    /// Which properties are settable.
    private var settableProperties = Set<PropertyKey>()

    /// Records of set calls for verification.
    private(set) var setCalls = [PropertyKey: Data]()

    // MARK: - Registration API

    /// Register a scalar property value (UInt32, Int32, Float32, Float64, etc.).
    func register<T>(
        objectID: AudioObjectID,
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
        value: T,
        settable: Bool = false
    ) {
        let key = PropertyKey(objectID: objectID, selector: selector, scope: scope, element: element)
        existingProperties.insert(key)

        var mutableValue = value
        let data = withUnsafeBytes(of: &mutableValue) { Data($0) }
        properties[key] = data

        if settable {
            settableProperties.insert(key)
        }
    }

    /// Register a CFString property (e.g., UID, name, manufacturer).
    ///
    /// String properties are stored separately and written through the CFString
    /// reference mechanism with proper ARC semantics when `getPropertyData` is called.
    func registerString(
        objectID: AudioObjectID,
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
        value: String,
        settable: Bool = false
    ) {
        let key = PropertyKey(objectID: objectID, selector: selector, scope: scope, element: element)
        existingProperties.insert(key)
        stringProperties[key] = value

        if settable { settableProperties.insert(key) }
    }

    /// Register an array property (e.g., preferredChannelsForStereo, clockSourceIDs).
    func registerArray<T>(
        objectID: AudioObjectID,
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
        values: [T],
        settable: Bool = false
    ) {
        let key = PropertyKey(objectID: objectID, selector: selector, scope: scope, element: element)
        existingProperties.insert(key)

        let data = values.withUnsafeBufferPointer { bufferPtr in
            Data(bytes: bufferPtr.baseAddress!, count: MemoryLayout<T>.stride * values.count)
        }
        properties[key] = data

        if settable { settableProperties.insert(key) }
    }

    /// Mark a property as existing but with no data (for hasProperty-only checks).
    func markExists(
        objectID: AudioObjectID,
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) {
        let key = PropertyKey(objectID: objectID, selector: selector, scope: scope, element: element)
        existingProperties.insert(key)
    }

    // MARK: - AudioObjectBackend Conformance

    func hasProperty(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress
    ) -> Bool {
        let key = PropertyKey(objectID: objectID, selector: address.mSelector,
                              scope: address.mScope, element: address.mElement)
        return existingProperties.contains(key)
    }

    func isPropertySettable(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        isSettable: inout DarwinBoolean
    ) -> OSStatus {
        let key = PropertyKey(objectID: objectID, selector: address.mSelector,
                              scope: address.mScope, element: address.mElement)
        guard existingProperties.contains(key) else { return kAudioHardwareBadObjectError }
        isSettable = DarwinBoolean(settableProperties.contains(key))
        return kAudioHardwareNoError
    }

    func getPropertyDataSize(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: inout UInt32
    ) -> OSStatus {
        let key = PropertyKey(objectID: objectID, selector: address.mSelector,
                              scope: address.mScope, element: address.mElement)

        if stringProperties[key] != nil {
            dataSize = UInt32(MemoryLayout<CFString>.size)
            return kAudioHardwareNoError
        }

        guard let data = properties[key] else { return kAudioHardwareBadObjectError }
        dataSize = UInt32(data.count)
        return kAudioHardwareNoError
    }

    func getPropertyData(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: inout UInt32,
        data: UnsafeMutableRawPointer
    ) -> OSStatus {
        let key = PropertyKey(objectID: objectID, selector: address.mSelector,
                              scope: address.mScope, element: address.mElement)

        // Handle CFString properties with proper ARC semantics
        if let string = stringProperties[key] {
            let cfString = string as CFString
            // Write the CFString reference into the data pointer using ARC-safe assignment.
            // The data pointer is expected to point to a CFString variable.
            let typedPtr = data.assumingMemoryBound(to: CFString.self)
            typedPtr.pointee = cfString
            dataSize = UInt32(MemoryLayout<CFString>.size)
            return kAudioHardwareNoError
        }

        guard let stored = properties[key] else { return kAudioHardwareBadObjectError }
        let copySize = min(Int(dataSize), stored.count)
        stored.withUnsafeBytes { ptr in
            data.copyMemory(from: ptr.baseAddress!, byteCount: copySize)
        }
        dataSize = UInt32(stored.count)
        return kAudioHardwareNoError
    }

    func setPropertyData(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        qualifierDataSize: UInt32,
        qualifierData: UnsafeRawPointer?,
        dataSize: UInt32,
        data: UnsafeRawPointer
    ) -> OSStatus {
        let key = PropertyKey(objectID: objectID, selector: address.mSelector,
                              scope: address.mScope, element: address.mElement)
        guard settableProperties.contains(key) else { return kAudioHardwareBadObjectError }
        let newData = Data(bytes: data, count: Int(dataSize))
        setCalls[key] = newData
        properties[key] = newData
        return kAudioHardwareNoError
    }

    func addPropertyListener(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        listener: AudioObjectPropertyListenerProc,
        clientData: UnsafeMutableRawPointer?
    ) -> OSStatus {
        kAudioHardwareNoError
    }

    func removePropertyListener(
        _ objectID: AudioObjectID,
        address: inout AudioObjectPropertyAddress,
        listener: AudioObjectPropertyListenerProc,
        clientData: UnsafeMutableRawPointer?
    ) -> OSStatus {
        kAudioHardwareNoError
    }
}

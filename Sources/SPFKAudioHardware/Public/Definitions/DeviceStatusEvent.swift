// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

public struct DeviceStatusEvent: Hashable, Sendable {
    public private(set) var addedDevices: [AudioDevice]
    public private(set) var removedDevices: [AudioDevice]
    
    public init(addedDevices: [AudioDevice] = [], removedDevices: [AudioDevice] = []) {
        self.addedDevices = addedDevices
        self.removedDevices = removedDevices
    }
}

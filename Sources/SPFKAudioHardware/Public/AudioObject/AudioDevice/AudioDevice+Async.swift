// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

extension AudioDevice {
    /// Update the device sample rate and wait for the completion.
    /// Errors will be thrown if the sample rate isn't available.
    /// - Parameter sampleRate: Sample rate to set.
    public func update(sampleRate: Double) async throws {
        guard let nominalSampleRates, nominalSampleRates.contains(sampleRate) else {
            throw NSError(description: "\(name) doesn't support \(sampleRate) Hz")
        }

        let task = Task<Float64?, Error> {
            let notification: Notification = try await NotificationCenter.wait(for: .deviceNominalSampleRateDidChange, timeout: 5)

            Log.debug(notification)

            guard let deviceNotification = notification.object as? AudioDeviceNotification else {
                return nil
            }

            guard case let .deviceNominalSampleRateDidChange(objectID) = deviceNotification else {
                return nil
            }

            guard let device: AudioDevice = await AudioObjectPool.shared.lookup(id: objectID) else {
                return nil
            }

            return device.nominalSampleRate
        }

        let status = setNominalSampleRate(sampleRate)

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "(kAudioDevicePropertyNominalSampleRate) Action failed to update \(name)'s sample rate to \(sampleRate) with error \(status.fourCharCodeToString()).")
        }

        let result = await task.result

        switch result {
        case let .success(newSampleRate):
            guard let newSampleRate, sampleRate == newSampleRate else {
                throw NSError(description: "Device wasn't updated. Failed to update \(name)'s sample rate to \(sampleRate).")
            }

        case let .failure(error):
            throw error
        }

        // OK
    }
    
    // TODO: more setters
}

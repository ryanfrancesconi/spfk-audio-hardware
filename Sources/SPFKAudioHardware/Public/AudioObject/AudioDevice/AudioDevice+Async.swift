// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

extension AudioDevice {
    /// Update the device sample rate and wait for the completion.
    /// Errors will be thrown if the sample rate requested isn't compatible.
    /// - Parameter sampleRate: Sample rate to set.
    public func updateAndWait(sampleRate: Double) async throws {
        guard sampleRate != nominalSampleRate else {
            Log.error("\(nameAndID) is already set to \(sampleRate). Ignoring this call.")
            return
        }

        let benchmark = Benchmark(label: "\((#file as NSString).lastPathComponent):\(#function)"); defer { benchmark.stop() }

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
            throw NSError(description: "(kAudioDevicePropertyNominalSampleRate) Action failed to update \(nameAndID)'s sample rate to \(sampleRate) with error \(status.fourCC).")
        }

        let result = await task.result

        switch result {
        case let .success(newSampleRate):
            guard let newSampleRate, sampleRate == newSampleRate else {
                throw NSError(description: "Failed to update \(nameAndID)'s sample rate to \(sampleRate). Device wasn't updated.")
            }

        case let .failure(error):
            throw NSError(description: "\(nameAndID) Failed to update to \(sampleRate) Hz. " + error.localizedDescription)
        }

        // OK
        Log.debug("\(nameAndID) has updated to \(sampleRate) Hz.")
    }

    // TODO: more setters
}

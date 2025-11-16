// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

import Foundation

extension AudioDevice {
    /// Update the device sample rate and wait for the completion.
    /// Errors will be thrown if the sample rate isn't available.
    /// - Parameter sampleRate: Sample rate to set.
    public func update(sampleRate: Double) async throws {
        guard let nominalSampleRates, nominalSampleRates.contains(sampleRate) else {
            throw NSError(description: "\(name) doesn't support \(sampleRate) Hz")
        }

        let task = Task<Float64?, Error> {
            let notification: Notification = try await NotificationCenter.wait(for: .deviceNominalSampleRateDidChange)
            let device = notification.object as? AudioDevice
            return device?.nominalSampleRate
        }

        guard setNominalSampleRate(sampleRate) else {
            throw NSError(description: "Failed to update device sample rate to \(sampleRate).")
        }

        let result = await task.result

        switch result {
        case let .success(newSampleRate):
            guard let newSampleRate, sampleRate == newSampleRate else {
                throw NSError(description: "Failed to update device sample rate to \(sampleRate).")
            }

        case let .failure(error):
            throw error
        }

        // OK
    }
}

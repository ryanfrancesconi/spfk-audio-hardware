// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audio-hardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

import CoreAudio
import Foundation
import SPFKBase

/// Manages asynchronous sample rate changes for an `AudioDevice`.
///
/// When a sample rate change is requested via `updateAndWait(sampleRate:)`, this actor
/// sets the nominal sample rate on the device and then waits for Core Audio to confirm
/// the change via a `deviceNominalSampleRateDidChange` notification before returning.
public actor SampleRateState {
    var updateTask: Task<Float64?, Error>?

    /// The `AudioObjectID` of the device this state is associated with.
    public var objectID: AudioObjectID?

    /// Associates this state with a specific audio device.
    ///
    /// Called during `AudioDevice` initialization to bind the state to its device.
    ///
    /// - Parameter objectID: The device's `AudioObjectID`.
    public func update(objectID: AudioObjectID) {
        self.objectID = objectID
    }

    /// Update the device sample rate and wait for the completion.
    /// Errors will be thrown if the sample rate requested isn't compatible.
    /// - Parameter sampleRate: Sample rate to set.
    public func updateAndWait(sampleRate requestedRate: Double) async throws {
        updateTask?.cancel()

        guard let objectID else {
            throw NSError(description: "device hasn't been set")
        }

        let device = try await AudioDevice.lookup(id: objectID)

        guard let nominalSampleRate = device.nominalSampleRate else {
            throw NSError(description: "nominalSampleRate is nil")
        }

        let nameAndID = device.nameAndID

        guard requestedRate != nominalSampleRate else {
            Log.error("\(nameAndID) is already set to \(requestedRate). Ignoring this call.")
            return
        }

        let benchmark = Benchmark(label: "\((#file as NSString).lastPathComponent):\(#function) sampleRate(\(requestedRate))"); defer { benchmark.stop() }

        guard let nominalSampleRates = device.nominalSampleRates,
              nominalSampleRates.contains(requestedRate)
        else {
            throw NSError(description: "\(nameAndID) doesn't support \(requestedRate) Hz")
        }

        let task = Task<Float64?, Error> {
            let notification: Notification = try await NotificationCenter.wait(for: .deviceNominalSampleRateDidChange, timeout: 10)

            Log.debug(notification)

            guard let deviceNotification = notification.object as? AudioDeviceNotification else {
                return nil
            }

            guard case let .deviceNominalSampleRateDidChange(objectID) = deviceNotification else {
                return nil
            }

            let device: AudioDevice = try await AudioObjectPool.shared.lookup(id: objectID)

            return device.nominalSampleRate
        }
        updateTask = task

        guard !task.isCancelled else {
            throw CancellationError()
        }

        let status = device.setNominalSampleRate(requestedRate)

        guard kAudioHardwareNoError == status else {
            throw NSError(description: "(kAudioDevicePropertyNominalSampleRate) Action failed to update \(nameAndID)'s sample rate to \(requestedRate) with error \(status.fourCC).")
        }

        let result = await task.result

        switch result {
        case let .success(newSampleRate):
            guard let newSampleRate, requestedRate == newSampleRate else {
                throw NSError(description: "Failed to update \(nameAndID)'s sample rate to \(requestedRate). Device is set to \(newSampleRate?.string ?? "nil").")
            }

        case let .failure(error):
            throw NSError(description: "\(nameAndID) Failed to update to \(requestedRate) Hz. " + error.localizedDescription)
        }

        // OK
        Log.debug("\(nameAndID) has updated to \(requestedRate) Hz.")
        updateTask = nil
    }
}

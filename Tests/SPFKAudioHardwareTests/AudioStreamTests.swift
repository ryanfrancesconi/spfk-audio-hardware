import AudioToolbox
@testable import SPFKAudioHardware
import Testing

class AudioStreamTests: NullDeviceTestCase {
    @Test func testProperties() async throws {
        let nullDevice = try #require(nullDevice)
        
        let outputStreams = try #require(await nullDevice.streams(scope: .output))
        let inputStreams = try #require(await nullDevice.streams(scope: .input))

        #expect(outputStreams.count == 1)
        #expect(inputStreams.count == 1)

        let outputStream = try #require(outputStreams.first)
        #expect(outputStream.active)
        #expect(outputStream.startingChannel != nil)
        #expect(outputStream.scope == .output)
        #expect(outputStream.terminalType == .speaker)
        #expect(outputStream.latency == 0)
        #expect(outputStream.availableVirtualFormats != nil)
        #expect(outputStream.availableVirtualFormatsMatchingCurrentNominalSampleRate() != nil)
        #expect(outputStream.availableVirtualFormatsMatchingCurrentNominalSampleRate(true) != nil)
        #expect(outputStream.availableVirtualFormatsMatchingCurrentNominalSampleRate(false) != nil)
        #expect(outputStream.availablePhysicalFormats != nil)
        #expect(outputStream.availablePhysicalFormatsMatchingCurrentNominalSampleRate() != nil)
        #expect(outputStream.availablePhysicalFormatsMatchingCurrentNominalSampleRate(true) != nil)
        #expect(outputStream.availablePhysicalFormatsMatchingCurrentNominalSampleRate(false) != nil)

        outputStream.virtualFormat = nil
        #expect(outputStream.virtualFormat != nil)

        outputStream.physicalFormat = nil
        #expect(outputStream.physicalFormat != nil)

        let inputStream = try #require(inputStreams.first)
        #expect(inputStream.active)
        #expect(inputStream.startingChannel != nil)
        #expect(inputStream.scope == .input)
        #expect(inputStream.terminalType == .microphone)
        #expect(inputStream.latency == 0)
        #expect(inputStream.availableVirtualFormats != nil)
        #expect(inputStream.availableVirtualFormatsMatchingCurrentNominalSampleRate() != nil)
        #expect(inputStream.availableVirtualFormatsMatchingCurrentNominalSampleRate(true) != nil)
        #expect(inputStream.availableVirtualFormatsMatchingCurrentNominalSampleRate(false) != nil)
        #expect(inputStream.availablePhysicalFormats != nil)
        #expect(inputStream.availablePhysicalFormatsMatchingCurrentNominalSampleRate() != nil)
        #expect(inputStream.availablePhysicalFormatsMatchingCurrentNominalSampleRate(true) != nil)
        #expect(inputStream.availablePhysicalFormatsMatchingCurrentNominalSampleRate(false) != nil)

        inputStream.virtualFormat = nil
        #expect(inputStream.virtualFormat != nil)

        inputStream.physicalFormat = nil
        #expect(inputStream.physicalFormat != nil)
        
        try await tearDown()
    }
}

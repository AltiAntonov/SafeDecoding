import Foundation
import Testing
@testable import SafeDecoding

private struct CleanUser: Decodable, Equatable {
    let id: Int
    let name: String
}

private enum DecoderSuiteUnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

private struct OptionalUser: Decodable {
    @SafeDecodable var name: String?
}

private struct FallbackOnlyUser: Decodable {
    @SafeFallbackDecodable<DecoderSuiteUnknownRoleFallback> var role: String
}

@Test
func safeJSONDecoderReturnsDecodedValueAndEmptyReportForCleanPayload() throws {
    let data = #"{"id":1,"name":"Ava"}"#.data(using: .utf8)!

    let result = try SafeJSONDecoder().decode(CleanUser.self, from: data)

    #expect(result.value == CleanUser(id: 1, name: "Ava"))
    #expect(result.report.issues.isEmpty)
    #expect(result.report.hasIssues == false)
}

@Test
func safeJSONDecoderCapturesBrokenOptionalFieldReport() throws {
    let data = #"{"name":42}"#.data(using: .utf8)!

    let result = try SafeJSONDecoder().decode(OptionalUser.self, from: data)

    #expect(result.value.name == nil)
    #expect(result.report.issues.count == 1)
    #expect(result.report.issues[0].fieldPath == "name")
}

@Test
func safeJSONDecoderCapturesBrokenFallbackBackedFieldReport() throws {
    let data = #"{"role":42}"#.data(using: .utf8)!

    let result = try SafeJSONDecoder().decode(FallbackOnlyUser.self, from: data)

    #expect(result.value.role == "Unknown")
    #expect(result.report.issues.count == 1)
    #expect(result.report.issues[0].fieldPath == "role")
}

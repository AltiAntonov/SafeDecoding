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

private struct MixedUser: Decodable {
    @SafeDecodable var name: String?
    @SafeFallbackDecodable<DecoderSuiteUnknownRoleFallback> var role: String
}

private struct StrictUser: Decodable {
    let id: Int
}

private struct SnakeCaseUser: Decodable, Equatable {
    let displayName: String
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

@Test
func safeJSONDecoderCapturesMixedWrapperIssuesInEmissionOrder() throws {
    let data = #"{"name":42,"role":42}"#.data(using: .utf8)!

    let result = try SafeJSONDecoder().decode(MixedUser.self, from: data)

    #expect(result.value.name == nil)
    #expect(result.value.role == "Unknown")
    #expect(result.report.issues.map(\.fieldPath) == ["name", "role"])
}

@Test
func safeJSONDecoderRethrowsTopLevelDecodeFailures() {
    let data = #"{}"#.data(using: .utf8)!

    do {
        _ = try SafeJSONDecoder().decode(StrictUser.self, from: data)
        Issue.record("Expected top-level decode to throw")
    } catch let error as DecodingError {
        guard case let .keyNotFound(codingKey, _) = error else {
            Issue.record("Expected keyNotFound, got \(error)")
            return
        }

        #expect(codingKey.stringValue == "id")
    } catch {
        Issue.record("Expected DecodingError, got \(error)")
    }
}

@Test
func safeJSONDecoderRespectsInjectedKeyDecodingStrategy() throws {
    let data = #"{"display_name":"Ava Stone"}"#.data(using: .utf8)!
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

    let result = try SafeJSONDecoder(jsonDecoder: jsonDecoder).decode(SnakeCaseUser.self, from: data)

    #expect(result.value == SnakeCaseUser(displayName: "Ava Stone"))
    #expect(result.report.issues.isEmpty)
}

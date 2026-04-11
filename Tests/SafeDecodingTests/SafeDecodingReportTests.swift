import Foundation
import Testing
@testable import SafeDecoding

private enum ReportSuiteUnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

private struct OptionalUser: Decodable {
    @SafeDecodable var name: String?
}

private struct MixedUser: Decodable {
    @SafeDecodable var name: String?
    @SafeFallbackDecodable<ReportSuiteUnknownRoleFallback> var role: String
}

private struct OuterUser: Decodable {
    let profile: Profile

    struct Profile: Decodable {
        @SafeDecodable var nickname: String?
    }
}

private struct StrictUser: Decodable {
    let id: Int
}

@Test
func reportStartsEmptyWhenInitializedWithNoIssues() {
    let report = SafeDecodingReport(issues: [])

    #expect(report.issues.isEmpty)
    #expect(report.hasIssues == false)
}

@Test
func reportExposesIssuesWhenInitializedWithValues() {
    let issue = SafeDecodingIssue(fieldPath: "name", errorDescription: "typeMismatch")
    let report = SafeDecodingReport(issues: [issue])

    #expect(report.issues == [issue])
    #expect(report.hasIssues == true)
}

@Test
func captureReturnsEmptyReportForCleanPayload() throws {
    let data = #"{"name":"Ava"}"#.data(using: .utf8)!

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(OptionalUser.self, from: data)
    }

    #expect(result.value.name == "Ava")
    #expect(result.report.issues.isEmpty)
    #expect(result.report.hasIssues == false)
}

@Test
func captureReturnsReportForBrokenOptionalField() throws {
    let data = #"{"name":42}"#.data(using: .utf8)!

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(OptionalUser.self, from: data)
    }

    #expect(result.value.name == nil)
    #expect(result.report.issues.count == 1)
    #expect(result.report.issues[0].fieldPath == "name")
}

@Test
func captureReturnsIssuesInEmissionOrderForMixedWrappers() throws {
    let data = #"{"name":42,"role":42}"#.data(using: .utf8)!

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(MixedUser.self, from: data)
    }

    #expect(result.value.name == nil)
    #expect(result.value.role == "Unknown")
    #expect(result.report.issues.map(\.fieldPath) == ["name", "role"])
}

@Test
func capturePreservesNestedCodingPaths() throws {
    let data = #"{"profile":{"nickname":42}}"#.data(using: .utf8)!

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(OuterUser.self, from: data)
    }

    #expect(result.value.profile.nickname == nil)
    #expect(result.report.issues.count == 1)
    #expect(result.report.issues[0].fieldPath == "profile.nickname")
}

@Test
func captureRethrowsTopLevelDecodeFailures() {
    let data = #"{}"#.data(using: .utf8)!

    #expect(throws: DecodingError.self) {
        _ = try SafeDecodingDiagnostics.capture {
            try JSONDecoder().decode(StrictUser.self, from: data)
        }
    }
}

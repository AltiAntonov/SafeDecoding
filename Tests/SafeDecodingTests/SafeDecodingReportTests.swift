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

private struct FallbackOnlyUser: Decodable {
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

private struct CompositionSnapshot: Equatable {
    let innerName: String?
    let outerRole: String
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
    let expectedIssue = SafeDecodingIssue(
        fieldPath: "name",
        errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: name. Debug description: Expected to decode String but found number instead."
    )

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(OptionalUser.self, from: data)
    }

    #expect(result.value.name == nil)
    #expect(result.report.issues == [expectedIssue])
}

@Test
func captureReturnsOneIssueForBrokenFallbackBackedField() throws {
    let data = #"{"role":42}"#.data(using: .utf8)!
    let expectedIssue = SafeDecodingIssue(
        fieldPath: "role",
        errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: role. Debug description: Expected to decode String but found number instead."
    )

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(FallbackOnlyUser.self, from: data)
    }

    #expect(result.value.role == "Unknown")
    #expect(result.report.issues == [expectedIssue])
}

@Test
func captureReturnsIssuesInEmissionOrderForMixedWrappers() throws {
    let data = #"{"name":42,"role":42}"#.data(using: .utf8)!
    let expectedIssues = [
        SafeDecodingIssue(
            fieldPath: "name",
            errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: name. Debug description: Expected to decode String but found number instead."
        ),
        SafeDecodingIssue(
            fieldPath: "role",
            errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: role. Debug description: Expected to decode String but found number instead."
        )
    ]

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(MixedUser.self, from: data)
    }

    #expect(result.value.name == nil)
    #expect(result.value.role == "Unknown")
    #expect(result.report.issues == expectedIssues)
}

@Test
func capturePreservesNestedCodingPaths() throws {
    let data = #"{"profile":{"nickname":42}}"#.data(using: .utf8)!
    let expectedIssue = SafeDecodingIssue(
        fieldPath: "profile.nickname",
        errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: profile.nickname. Debug description: Expected to decode String but found number instead."
    )

    let result = try SafeDecodingDiagnostics.capture {
        try JSONDecoder().decode(OuterUser.self, from: data)
    }

    #expect(result.value.profile.nickname == nil)
    #expect(result.report.issues == [expectedIssue])
}

@Test
func captureComposesWithNestedIssueHandlers() throws {
    let innerData = #"{"name":42}"#.data(using: .utf8)!
    let outerData = #"{"role":42}"#.data(using: .utf8)!
    var outerIssues: [SafeDecodingIssue] = []
    var innerIssues: [SafeDecodingIssue] = []

    let result = try SafeDecodingDiagnostics.withIssueHandler({ outerIssues.append($0) }) {
        try SafeDecodingDiagnostics.capture {
            let innerUser = try SafeDecodingDiagnostics.withIssueHandler({ innerIssues.append($0) }) {
                try JSONDecoder().decode(OptionalUser.self, from: innerData)
            }

            let outerUser = try JSONDecoder().decode(FallbackOnlyUser.self, from: outerData)

            return CompositionSnapshot(innerName: innerUser.name, outerRole: outerUser.role)
        }
    }

    let expectedInnerIssue = SafeDecodingIssue(
        fieldPath: "name",
        errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: name. Debug description: Expected to decode String but found number instead."
    )
    let expectedOuterIssue = SafeDecodingIssue(
        fieldPath: "role",
        errorDescription: "DecodingError.typeMismatch: expected value of type String. Path: role. Debug description: Expected to decode String but found number instead."
    )

    #expect(result.value == CompositionSnapshot(innerName: nil, outerRole: "Unknown"))
    #expect(result.report.issues == [expectedInnerIssue, expectedOuterIssue])
    #expect(innerIssues == [expectedInnerIssue])
    #expect(outerIssues == [expectedOuterIssue])
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

import Foundation
import Testing
@testable import SafeDecoding

private struct OptionalUser: Decodable {
    @SafeDecodable var name: String?
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

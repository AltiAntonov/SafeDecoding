import Foundation
import Testing
@testable import SafeDecoding

private struct User: Decodable {
    @SafeDecodable var name: String?
}

private enum DiagnosticsSuiteUnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

private struct MixedWrapperUser: Decodable {
    @SafeDecodable var name: String?
    @SafeFallbackDecodable<DiagnosticsSuiteUnknownRoleFallback> var role: String
}

@Test
func typeMismatchEmitsDiagnosticWithCodingPath() throws {
    let data = #"{"name":42}"#.data(using: .utf8)!
    var issues: [SafeDecodingIssue] = []

    try SafeDecodingDiagnostics.withIssueHandler({ issues.append($0) }) {
        _ = try JSONDecoder().decode(User.self, from: data)
    }

    #expect(issues.count == 1)
    #expect(issues[0].fieldPath == "name")
    #expect(issues[0].errorDescription.contains("typeMismatch"))
}

@Test
func handlerIsRestoredAfterScopedOverrideReturns() throws {
    let first = SafeDecodingIssue(fieldPath: "first", errorDescription: "first")
    let second = SafeDecodingIssue(fieldPath: "second", errorDescription: "second")
    var outerIssues: [SafeDecodingIssue] = []
    var innerIssues: [SafeDecodingIssue] = []

    SafeDecodingDiagnostics.withIssueHandler({ outerIssues.append($0) }) {
        SafeDecodingDiagnostics.withIssueHandler({ innerIssues.append($0) }) {
            SafeDecodingDiagnostics.emit(first)
        }

        SafeDecodingDiagnostics.emit(second)
    }

    #expect(innerIssues == [first])
    #expect(outerIssues == [second])
}

@Test
func diagnosticsCaptureOptionalAndFallbackWrapperIssuesPredictably() throws {
    let data = #"{"name":42,"role":42}"#.data(using: .utf8)!
    var issues: [SafeDecodingIssue] = []

    let user = try SafeDecodingDiagnostics.withIssueHandler({ issues.append($0) }) {
        try JSONDecoder().decode(MixedWrapperUser.self, from: data)
    }

    #expect(user.name == nil)
    #expect(user.role == "Unknown")
    #expect(issues.count == 2)
    #expect(issues.map(\.fieldPath) == ["name", "role"])
    #expect(issues.allSatisfy { $0.errorDescription.contains("typeMismatch") })
}

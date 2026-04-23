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
func decodingErrorDescriptionUsesStablePackageFormatting() {
    let context = DecodingError.Context(
        codingPath: [AnyCodingKey(stringValue: "name")],
        debugDescription: "Expected to decode String but found number instead."
    )

    let description = SafeDecodingDiagnostics.description(
        for: DecodingError.typeMismatch(String.self, context),
        fallbackPath: "name"
    )

    #expect(
        description
            == "DecodingError.typeMismatch: expected value of type String. Path: name. Debug description: Expected to decode String but found number instead."
    )
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
func withIssueHandlerStillCapturesEmittedIssuesDirectly() throws {
    let data = #"{"name":42}"#.data(using: .utf8)!
    var issues: [SafeDecodingIssue] = []

    let user = try SafeDecodingDiagnostics.withIssueHandler({ issues.append($0) }) {
        try JSONDecoder().decode(User.self, from: data)
    }

    #expect(user.name == nil)
    #expect(issues.count == 1)
    #expect(issues[0].fieldPath == "name")
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

private struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

import Foundation
import Testing
@testable import SafeDecoding

enum UnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

private struct User: Decodable {
    @SafeFallbackDecodable<UnknownRoleFallback> var role: String
}

@Test
func fallbackBackedFieldUsesDecodedValueWhenPresent() throws {
    let data = #"{"role":"Admin"}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.role == "Admin")
}

@Test
func brokenFallbackBackedFieldUsesFallbackValue() throws {
    let data = #"{"role":42}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.role == "Unknown")
}

@Test
func brokenFallbackBackedFieldEmitsDiagnosticForRole() throws {
    let data = #"{"role":42}"#.data(using: .utf8)!
    var issues: [SafeDecodingIssue] = []

    let user = try SafeDecodingDiagnostics.withIssueHandler({ issue in
        issues.append(issue)
    }, perform: {
        try JSONDecoder().decode(User.self, from: data)
    })

    #expect(user.role == "Unknown")
    #expect(issues.count == 1)
    #expect(issues[0].fieldPath == "role")
}

@Test
func missingFallbackBackedFieldUsesFallbackValue() throws {
    let data = #"{}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.role == "Unknown")
}

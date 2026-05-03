import Foundation
import Testing
@testable import SafeDecoding

enum UnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

private enum AccessLevel: String, Decodable {
    case admin
    case member
}

private enum UnknownAccessLevelFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = AccessLevel.member
}

private struct User: Decodable {
    @SafeFallbackDecodable<UnknownRoleFallback> var role: String
}

private struct NestedProfile: Decodable {
    @SafeFallbackDecodable<UnknownRoleFallback> var role: String
}

private struct NestedUser: Decodable {
    let profile: NestedProfile
}

private struct NestedMembership: Decodable {
    @SafeFallbackDecodable<UnknownAccessLevelFallback> var accessLevel: AccessLevel
}

private struct NestedMembershipUser: Decodable {
    let membership: NestedMembership
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

@Test
func nullFallbackBackedFieldUsesFallbackValue() throws {
    let data = #"{"role":null}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.role == "Unknown")
}

@Test
func nullFallbackBackedFieldEmitsDiagnosticForRole() throws {
    let data = #"{"role":null}"#.data(using: .utf8)!
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
func nestedBrokenFallbackBackedFieldUsesFallbackValue() throws {
    let data = #"{"profile":{"role":42}}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(NestedUser.self, from: data)

    #expect(user.profile.role == "Unknown")
}

@Test
func nestedBrokenFallbackBackedEnumUsesFallbackValue() throws {
    let data = #"{"membership":{"accessLevel":"owner"}}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(NestedMembershipUser.self, from: data)

    #expect(user.membership.accessLevel == .member)
}

import Foundation
import Testing
@testable import SafeDecoding

private enum OptionalSuiteUnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

private enum Visibility: String, Decodable {
    case `public`
    case `private`
}

@Test
func safeFieldDecodesValidString() throws {
    let data = #"{"name":"Ava"}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.name == "Ava")
}

private struct User: Decodable {
    @SafeDecodable var name: String?
}

@Test
func missingSafeFieldDefaultsToNil() throws {
    let data = #"{}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.name == nil)
}

@Test
func brokenSafeFieldDoesNotFailWholeModel() throws {
    let data = #"{"id":1,"name":42}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(BrokenFieldUser.self, from: data)

    #expect(user.id == 1)
    #expect(user.name == nil)
}

private struct BrokenFieldUser: Decodable {
    let id: Int
    @SafeDecodable var name: String?
}

private struct MixedWrapperUser: Decodable {
    let id: Int
    @SafeDecodable var name: String?
    @SafeFallbackDecodable<OptionalSuiteUnknownRoleFallback> var role: String
}

private struct NestedProfile: Decodable {
    @SafeDecodable var name: String?
}

private struct NestedUser: Decodable {
    let id: Int
    let profile: NestedProfile
}

private struct NestedPreferences: Decodable {
    @SafeDecodable var visibility: Visibility?
}

private struct NestedPreferencesUser: Decodable {
    let preferences: NestedPreferences
}

@Test
func brokenOptionalFieldStillFallsBackToNilAlongsideFallbackBackedField() throws {
    let data = #"{"id":1,"name":42,"role":42}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(MixedWrapperUser.self, from: data)

    #expect(user.id == 1)
    #expect(user.name == nil)
    #expect(user.role == "Unknown")
}

@Test
func nestedBrokenSafeFieldDoesNotFailWholeModel() throws {
    let data = #"{"id":1,"profile":{"name":42}}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(NestedUser.self, from: data)

    #expect(user.id == 1)
    #expect(user.profile.name == nil)
}

@Test
func nestedBrokenWrappedEnumFallsBackToNil() throws {
    let data = #"{"preferences":{"visibility":"friends-only"}}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(NestedPreferencesUser.self, from: data)

    #expect(user.preferences.visibility == nil)
}

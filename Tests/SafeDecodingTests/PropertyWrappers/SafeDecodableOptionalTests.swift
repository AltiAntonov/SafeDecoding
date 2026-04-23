import Foundation
import Testing
@testable import SafeDecoding

private enum OptionalSuiteUnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
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

@Test
func brokenOptionalFieldStillFallsBackToNilAlongsideFallbackBackedField() throws {
    let data = #"{"id":1,"name":42,"role":42}"#.data(using: .utf8)!

    let user = try JSONDecoder().decode(MixedWrapperUser.self, from: data)

    #expect(user.id == 1)
    #expect(user.name == nil)
    #expect(user.role == "Unknown")
}

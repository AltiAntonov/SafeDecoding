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

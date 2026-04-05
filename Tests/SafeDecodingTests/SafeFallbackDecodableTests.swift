import Foundation
import Testing
@testable import SafeDecoding

enum UnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "Unknown"
}

@Test
func fallbackProviderExposesTypedFallbackValue() {
    #expect(UnknownRoleFallback.fallbackValue == "Unknown")
}

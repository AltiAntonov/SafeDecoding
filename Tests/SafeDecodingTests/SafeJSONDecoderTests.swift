import Foundation
import Testing
@testable import SafeDecoding

private struct CleanUser: Decodable, Equatable {
    let id: Int
    let name: String
}

@Test
func safeJSONDecoderReturnsDecodedValueAndEmptyReportForCleanPayload() throws {
    let data = #"{"id":1,"name":"Ava"}"#.data(using: .utf8)!

    let result = try SafeJSONDecoder().decode(CleanUser.self, from: data)

    #expect(result.value == CleanUser(id: 1, name: "Ava"))
    #expect(result.report.issues.isEmpty)
    #expect(result.report.hasIssues == false)
}

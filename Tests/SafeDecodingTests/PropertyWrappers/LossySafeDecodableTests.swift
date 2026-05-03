import Foundation
import Testing
@testable import SafeDecoding

private struct LossyUser: Decodable, Equatable {
    let id: Int
    let name: String
}

private struct LossyResponse: Decodable {
    @LossySafeDecodable var users: [LossyUser]
}

private struct StrictResponse: Decodable {
    let users: [LossyUser]
}

@Test
func lossyArrayDecodesFullyValidElementsUnchanged() throws {
    let data = #"{"users":[{"id":1,"name":"Ava"},{"id":2,"name":"Noah"}]}"#.data(using: .utf8)!

    let response = try JSONDecoder().decode(LossyResponse.self, from: data)

    #expect(response.users == [
        LossyUser(id: 1, name: "Ava"),
        LossyUser(id: 2, name: "Noah")
    ])
}

@Test
func missingLossyArrayDefaultsToEmptyArray() throws {
    let data = #"{}"#.data(using: .utf8)!

    let response = try JSONDecoder().decode(LossyResponse.self, from: data)

    #expect(response.users.isEmpty)
}

@Test
func malformedLossyElementIsSkippedWhileLaterElementsStillDecode() throws {
    let data = #"{"users":[{"id":1,"name":"Ava"},{"id":"oops","name":"Broken"},{"id":2,"name":"Noah"}]}"#.data(using: .utf8)!

    let response = try JSONDecoder().decode(LossyResponse.self, from: data)

    #expect(response.users == [
        LossyUser(id: 1, name: "Ava"),
        LossyUser(id: 2, name: "Noah")
    ])
}

@Test
func nonArrayLossyFieldRecoversToEmptyArrayAndReportsFieldIssue() throws {
    let data = #"{"users":{"id":1,"name":"Ava"}}"#.data(using: .utf8)!
    var issues: [SafeDecodingIssue] = []

    let response = try SafeDecodingDiagnostics.withIssueHandler({ issues.append($0) }) {
        try JSONDecoder().decode(LossyResponse.self, from: data)
    }

    #expect(response.users.isEmpty)
    #expect(issues.count == 1)
    #expect(issues[0].fieldPath == "users")
}

@Test
func lossyArrayReportsIndexedIssuePathsForSkippedElements() throws {
    let data = #"{"users":[{"id":1,"name":"Ava"},{"id":"oops","name":"Broken"},{"id":2,"name":"Noah"},{"id":"nope","name":"Broken Twice"}]}"#.data(using: .utf8)!
    var issues: [SafeDecodingIssue] = []

    let response = try SafeDecodingDiagnostics.withIssueHandler({ issues.append($0) }) {
        try JSONDecoder().decode(LossyResponse.self, from: data)
    }

    #expect(response.users == [
        LossyUser(id: 1, name: "Ava"),
        LossyUser(id: 2, name: "Noah")
    ])
    #expect(issues.count == 2)
    #expect(issues.map(\.fieldPath) == ["users.1.id", "users.3.id"])
}

@Test
func strictArrayStillThrowsForMalformedElement() {
    let data = #"{"users":[{"id":1,"name":"Ava"},{"id":"oops","name":"Broken"}]}"#.data(using: .utf8)!

    do {
        _ = try JSONDecoder().decode(StrictResponse.self, from: data)
        Issue.record("Expected strict array decode to throw")
    } catch let error as DecodingError {
        guard case let .typeMismatch(type, context) = error else {
            Issue.record("Expected typeMismatch, got \(error)")
            return
        }

        #expect(String(describing: type) == "Int")
        #expect(context.codingPath.map(\.stringValue) == ["users", "Index 1", "id"])
    } catch {
        Issue.record("Expected DecodingError, got \(error)")
    }
}

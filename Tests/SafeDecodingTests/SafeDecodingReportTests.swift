import Testing
@testable import SafeDecoding

@Test
func reportStartsEmptyWhenInitializedWithNoIssues() {
    let report = SafeDecodingReport(issues: [])

    #expect(report.issues.isEmpty)
    #expect(report.hasIssues == false)
}

@Test
func reportExposesIssuesWhenInitializedWithValues() {
    let issue = SafeDecodingIssue(fieldPath: "name", errorDescription: "typeMismatch")
    let report = SafeDecodingReport(issues: [issue])

    #expect(report.issues == [issue])
    #expect(report.hasIssues == true)
}

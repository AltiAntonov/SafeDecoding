//
//  SafeDecodingReport.swift
//  SafeDecoding
//
//  Structured report for issues captured during safe decoding.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// A structured collection of issues emitted during a scoped safe decode operation.
public struct SafeDecodingReport: Sendable, Equatable {
    /// The issues emitted during the captured decode operation.
    public let issues: [SafeDecodingIssue]

    /// Indicates whether the report contains any captured issues.
    public var hasIssues: Bool { issues.isEmpty == false }

    /// Creates a report from the provided captured issues.
    ///
    /// - Parameter issues: The issues emitted during the captured decode operation.
    public init(issues: [SafeDecodingIssue]) {
        self.issues = issues
    }
}

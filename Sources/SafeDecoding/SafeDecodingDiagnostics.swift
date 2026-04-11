//
//  SafeDecodingDiagnostics.swift
//  SafeDecoding
//
//  Placeholder diagnostics for safe decoding failures.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// Emits lightweight diagnostics for values recovered by safe decoding.
public enum SafeDecodingDiagnostics {
    /// Handles a single decoding issue emitted during safe decoding recovery.
    public typealias IssueHandler = (SafeDecodingIssue) -> Void

    private static let threadDictionaryKey = "SafeDecodingDiagnostics.issueHandler"

    private final class IssueHandlerBox {
        let handler: IssueHandler

        init(_ handler: @escaping IssueHandler) {
            self.handler = handler
        }
    }

    private static func defaultIssueHandler(_ issue: SafeDecodingIssue) {
        print("[SafeDecoding] \(issue.fieldPath): \(issue.errorDescription)")
    }

    private static var issueHandlerBox: IssueHandlerBox? {
        Thread.current.threadDictionary[threadDictionaryKey] as? IssueHandlerBox
    }

    /// Emits an issue through the current scoped handler, or the default printer.
    ///
    /// - Parameter issue: The issue to emit.
    public static func emit(_ issue: SafeDecodingIssue) {
        issueHandlerBox?.handler(issue) ?? defaultIssueHandler(issue)
    }

    /// Runs `operation` with a temporary issue handler scoped to the current thread.
    ///
    /// The default placeholder handler remains in place for all other threads and once the scope exits.
    /// Because the override is thread-scoped rather than task-scoped, work that hops to another thread
    /// will use that thread's current handler instead.
    ///
    /// - Parameters:
    ///   - handler: The temporary handler that receives emitted issues on the current thread.
    ///   - operation: The operation to run while the handler override is active.
    /// - Returns: The result produced by `operation`.
    /// - Throws: Any error thrown by `operation`.
    public static func withIssueHandler<Result>(
        _ handler: @escaping IssueHandler,
        perform operation: () throws -> Result
    ) rethrows -> Result {
        let threadDictionary = Thread.current.threadDictionary
        let previous = threadDictionary[threadDictionaryKey]
        threadDictionary[threadDictionaryKey] = IssueHandlerBox(handler)

        defer {
            if let previous {
                threadDictionary[threadDictionaryKey] = previous
            } else {
                threadDictionary.removeObject(forKey: threadDictionaryKey as NSString)
            }
        }

        return try operation()
    }

    /// Runs `operation` while capturing all emitted issues into a report.
    ///
    /// - Parameter operation: The operation to run while collecting emitted issues.
    /// - Returns: The value returned by `operation` and the issues captured during its execution.
    /// - Throws: Any error thrown by `operation`.
    public static func capture<Result>(
        perform operation: () throws -> Result
    ) rethrows -> (value: Result, report: SafeDecodingReport) {
        var issues: [SafeDecodingIssue] = []
        let value = try withIssueHandler({ issues.append($0) }) {
            try operation()
        }

        return (value: value, report: SafeDecodingReport(issues: issues))
    }
}

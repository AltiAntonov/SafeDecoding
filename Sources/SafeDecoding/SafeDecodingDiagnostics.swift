//
//  SafeDecodingDiagnostics.swift
//  SafeDecoding
//
//  Placeholder diagnostics for safe decoding failures.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public enum SafeDecodingDiagnostics {
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

    public static func emit(_ issue: SafeDecodingIssue) {
        issueHandlerBox?.handler(issue) ?? defaultIssueHandler(issue)
    }

    /// Runs `operation` with a temporary issue handler scoped to the current thread.
    /// The default placeholder handler remains in place for all other threads and once the scope exits.
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
}

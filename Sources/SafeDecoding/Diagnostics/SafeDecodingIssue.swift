//
//  SafeDecodingIssue.swift
//  SafeDecoding
//
//  Lightweight payload describing a safe decoding issue.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// A lightweight description of a field-level decoding recovery.
public struct SafeDecodingIssue: Sendable, Equatable {
    /// The stable field path for the recovery site.
    ///
    /// Paths use dotted keys, and arrays use numeric indexes such as `users.1.id`.
    public let fieldPath: String

    /// A textual description of the underlying decode error.
    public let errorDescription: String

    /// Creates a new decoding issue payload.
    ///
    /// - Parameters:
    ///   - fieldPath: The stable field path for the recovery site.
    ///   - errorDescription: A textual description of the underlying decode error.
    public init(fieldPath: String, errorDescription: String) {
        self.fieldPath = fieldPath
        self.errorDescription = errorDescription
    }
}

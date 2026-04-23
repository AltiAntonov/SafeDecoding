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
    /// The dotted coding path for the field that failed to decode.
    public let fieldPath: String

    /// A textual description of the underlying decode error.
    public let errorDescription: String

    /// Creates a new decoding issue payload.
    ///
    /// - Parameters:
    ///   - fieldPath: The dotted coding path for the field that failed to decode.
    ///   - errorDescription: A textual description of the underlying decode error.
    public init(fieldPath: String, errorDescription: String) {
        self.fieldPath = fieldPath
        self.errorDescription = errorDescription
    }
}

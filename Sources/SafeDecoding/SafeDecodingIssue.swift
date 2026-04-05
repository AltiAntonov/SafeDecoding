//
//  SafeDecodingIssue.swift
//  SafeDecoding
//
//  Lightweight payload describing a safe decoding issue.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public struct SafeDecodingIssue: Sendable, Equatable {
    public let fieldPath: String
    public let errorDescription: String

    public init(fieldPath: String, errorDescription: String) {
        self.fieldPath = fieldPath
        self.errorDescription = errorDescription
    }
}

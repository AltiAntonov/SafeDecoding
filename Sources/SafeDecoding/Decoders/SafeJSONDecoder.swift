//
//  SafeJSONDecoder.swift
//  SafeDecoding
//
//  App-level JSON decoding entry point with structured safe decoding reports.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// Decodes JSON values while capturing safe decoding issues into a report.
public struct SafeJSONDecoder {
    /// The underlying JSON decoder used for standard `Decodable` behavior.
    public var jsonDecoder: JSONDecoder

    /// Creates a safe JSON decoder backed by the provided `JSONDecoder`.
    ///
    /// - Parameter jsonDecoder: The configured JSON decoder to use for decoding.
    public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }

    /// Decodes a JSON value and captures any safe decoding issues emitted during decoding.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - data: The JSON data to decode.
    /// - Returns: The decoded value and the report captured during decoding.
    /// - Throws: Any unrecoverable error thrown by the underlying `JSONDecoder`.
    public func decode<Value: Decodable>(
        _ type: Value.Type,
        from data: Data
    ) throws -> (value: Value, report: SafeDecodingReport) {
        try SafeDecodingDiagnostics.capture {
            try jsonDecoder.decode(type, from: data)
        }
    }
}

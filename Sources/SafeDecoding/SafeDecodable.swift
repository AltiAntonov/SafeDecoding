//
//  SafeDecodable.swift
//  SafeDecoding
//
//  Property wrapper for safe optional decoding.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// A property wrapper that isolates decode failures for optional-like values.
@propertyWrapper
public struct SafeDecodable<Value: Decodable> {
    /// The decoded value, or `nil`-like fallback when decoding fails.
    public var wrappedValue: Value

    /// Creates a wrapper with an already decoded value.
    ///
    /// - Parameter wrappedValue: The value to expose from the wrapper.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension SafeDecodable: Decodable where Value: ExpressibleByNilLiteral {
    /// Decodes the wrapped value and falls back to `nil`-like semantics on failure.
    ///
    /// - Parameter decoder: The decoder for the wrapped property.
    /// - Throws: Any error thrown while asking the decoder for a single-value container.
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Value.self)
        } catch {
            let fieldPath = decoder.codingPath.map(\.stringValue).joined(separator: ".")
            SafeDecodingDiagnostics.emit(
                SafeDecodingIssue(
                    fieldPath: fieldPath.isEmpty ? "<root>" : fieldPath,
                    errorDescription: SafeDecodingDiagnostics.description(
                        for: error,
                        fallbackPath: fieldPath.isEmpty ? "<root>" : fieldPath
                    )
                )
            )

            self.wrappedValue = nil
        }
    }
}

public extension SafeDecodable where Value: ExpressibleByNilLiteral {
    /// Creates a wrapper whose value starts at `nil`.
    init() {
        self.wrappedValue = nil
    }
}

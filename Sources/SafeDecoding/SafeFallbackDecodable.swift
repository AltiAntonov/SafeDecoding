//
//  SafeFallbackDecodable.swift
//  SafeDecoding
//
//  Property wrapper for safe decoding with a typed fallback value.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// A property wrapper that decodes required values with a typed fallback provider.
@propertyWrapper
public struct SafeFallbackDecodable<Fallback: SafeDecodingFallbackProvider> {
    /// The decoded value, or the fallback provider's value when decoding fails.
    public var wrappedValue: Fallback.Value

    /// Creates a wrapper with an already decoded value.
    ///
    /// - Parameter wrappedValue: The value to expose from the wrapper.
    public init(wrappedValue: Fallback.Value) {
        self.wrappedValue = wrappedValue
    }

    /// Creates a wrapper initialized with the fallback provider's value.
    public init() {
        self.wrappedValue = Fallback.fallbackValue
    }
}

extension SafeFallbackDecodable: Decodable {
    /// Decodes the wrapped value and falls back to the provider value on failure.
    ///
    /// - Parameter decoder: The decoder for the wrapped property.
    /// - Throws: Any error thrown while asking the decoder for a single-value container.
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Fallback.Value.self)
        } catch {
            let fieldPath = decoder.codingPath.map(\.stringValue).joined(separator: ".")
            SafeDecodingDiagnostics.emit(
                SafeDecodingIssue(
                    fieldPath: fieldPath.isEmpty ? "<root>" : fieldPath,
                    errorDescription: String(describing: error)
                )
            )
            self.wrappedValue = Fallback.fallbackValue
        }
    }
}

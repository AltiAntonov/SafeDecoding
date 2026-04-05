//
//  SafeFallbackDecodable.swift
//  SafeDecoding
//
//  Property wrapper for safe decoding with a typed fallback value.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

@propertyWrapper
public struct SafeFallbackDecodable<Fallback: SafeDecodingFallbackProvider> {
    public var wrappedValue: Fallback.Value

    public init(wrappedValue: Fallback.Value) {
        self.wrappedValue = wrappedValue
    }

    public init() {
        self.wrappedValue = Fallback.fallbackValue
    }
}

extension SafeFallbackDecodable: Decodable {
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

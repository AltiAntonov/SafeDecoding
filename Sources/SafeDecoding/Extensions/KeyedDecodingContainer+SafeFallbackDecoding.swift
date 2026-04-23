//
//  KeyedDecodingContainer+SafeFallbackDecoding.swift
//  SafeDecoding
//
//  Safe wrapper decode helpers for typed fallback values.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public extension KeyedDecodingContainer {
    /// Decodes a `SafeFallbackDecodable` wrapper and supplies the provider value when the key is absent.
    ///
    /// - Parameters:
    ///   - type: The wrapper type to decode.
    ///   - key: The key to decode from.
    /// - Returns: A decoded wrapper, or a fallback-backed wrapper when the key is missing.
    /// - Throws: Any error thrown while obtaining a decoder for a present key.
    func decode<Fallback>(
        _ type: SafeFallbackDecodable<Fallback>.Type,
        forKey key: Key
    ) throws -> SafeFallbackDecodable<Fallback>
    where Fallback: SafeDecodingFallbackProvider {
        guard contains(key) else {
            return SafeFallbackDecodable<Fallback>()
        }

        return try SafeFallbackDecodable<Fallback>(from: try superDecoder(forKey: key))
    }
}

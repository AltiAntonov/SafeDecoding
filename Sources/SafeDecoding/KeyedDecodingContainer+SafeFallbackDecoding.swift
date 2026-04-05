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

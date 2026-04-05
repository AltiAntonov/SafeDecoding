//
//  KeyedDecodingContainer+SafeFallbackDecoding.swift
//  SafeDecoding
//
//  Safe fallback wrapper decode helpers for missing keys.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public extension KeyedDecodingContainer {
    func decode<Fallback>(
        _ type: SafeFallbackDecodable<Fallback>.Type,
        forKey key: Key
    ) throws -> SafeFallbackDecodable<Fallback> {
        try decodeIfPresent(type, forKey: key) ?? SafeFallbackDecodable<Fallback>()
    }
}

//
//  KeyedDecodingContainer+SafeDecoding.swift
//  SafeDecoding
//
//  Safe wrapper decode helpers for missing keys.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public extension KeyedDecodingContainer {
    func decode<T>(
        _ type: SafeDecodable<T>.Type,
        forKey key: Key
    ) throws -> SafeDecodable<T>
    where T: Decodable & ExpressibleByNilLiteral {
        try decodeIfPresent(type, forKey: key) ?? SafeDecodable<T>()
    }
}

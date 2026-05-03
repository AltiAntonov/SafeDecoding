//
//  KeyedDecodingContainer+LossySafeDecoding.swift
//  SafeDecoding
//
//  Safe wrapper decode helpers for lossy arrays.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public extension KeyedDecodingContainer {
    /// Decodes a `LossySafeDecodable` wrapper and supplies an empty wrapper when the key is absent.
    ///
    /// - Parameters:
    ///   - type: The wrapper type to decode.
    ///   - key: The key to decode from.
    /// - Returns: A decoded wrapper, or an empty wrapper when the key is missing.
    /// - Throws: Any error thrown while decoding a present wrapped value.
    func decode<Element>(
        _ type: LossySafeDecodable<Element>.Type,
        forKey key: Key
    ) throws -> LossySafeDecodable<Element>
    where Element: Decodable {
        try decodeIfPresent(type, forKey: key) ?? LossySafeDecodable<Element>()
    }
}

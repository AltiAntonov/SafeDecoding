//
//  SafeDecodingFallbackProvider.swift
//  SafeDecoding
//
//  Typed fallback values for safe fallback decoding.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// Supplies a typed fallback value for `SafeFallbackDecodable`.
public protocol SafeDecodingFallbackProvider {
    /// The decoded value type produced by this fallback provider.
    associatedtype Value: Decodable

    /// The value to use when decoding the wrapped property fails.
    static var fallbackValue: Value { get }
}

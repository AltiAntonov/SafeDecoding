//
//  SafeDecodingFallbackProvider.swift
//  SafeDecoding
//
//  Typed fallback values for safe fallback decoding.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

public protocol SafeDecodingFallbackProvider {
    associatedtype Value: Decodable
    static var fallbackValue: Value { get }
}

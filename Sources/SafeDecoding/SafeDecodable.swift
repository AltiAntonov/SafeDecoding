//
//  SafeDecodable.swift
//  SafeDecoding
//
//  Property wrapper for safe optional decoding.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

@propertyWrapper
public struct SafeDecodable<Value: Decodable> {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension SafeDecodable: Decodable where Value: ExpressibleByNilLiteral {
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Value.self)
        } catch {
            let fieldPath = decoder.codingPath.map(\.stringValue).joined(separator: ".")
            SafeDecodingDiagnostics.emit(
                SafeDecodingIssue(
                    fieldPath: fieldPath.isEmpty ? "<root>" : fieldPath,
                    errorDescription: String(describing: error)
                )
            )

            self.wrappedValue = nil
        }
    }
}

public extension SafeDecodable where Value: ExpressibleByNilLiteral {
    init() {
        self.wrappedValue = nil
    }
}

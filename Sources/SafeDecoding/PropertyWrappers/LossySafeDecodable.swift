//
//  LossySafeDecodable.swift
//  SafeDecoding
//
//  Property wrapper for lossy array decoding.
//  Copyright (c) 2026 Altimir Antonov.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

/// A property wrapper that will decode arrays with element-level recovery.
@propertyWrapper
public struct LossySafeDecodable<Element: Decodable> {
    /// The decoded array value.
    public var wrappedValue: [Element]

    /// Creates a wrapper with an already decoded array value.
    ///
    /// - Parameter wrappedValue: The array to expose from the wrapper.
    public init(wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }

    /// Creates a wrapper initialized to an empty array.
    public init() {
        self.wrappedValue = []
    }
}

extension LossySafeDecodable: Decodable {
    /// Decodes an array value with lossy semantics.
    ///
    /// - Parameter decoder: The decoder for the wrapped property.
    /// - Throws: Never rethrows element failures; only recovers and emits issues.
    public init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()
            var elements: [Element] = []

            while container.isAtEnd == false {
                let currentIndex = container.currentIndex

                do {
                    elements.append(try container.decode(Element.self))
                } catch {
                    let fallbackPath = "\(Self.baseFieldPath(from: decoder)).\(currentIndex)"
                    let fieldPath = Self.fieldPath(for: error, fallbackPath: fallbackPath)

                    SafeDecodingDiagnostics.emit(
                        SafeDecodingIssue(
                            fieldPath: fieldPath,
                            errorDescription: SafeDecodingDiagnostics.description(
                                for: error,
                                fallbackPath: fieldPath
                            )
                        )
                    )

                    _ = try container.decode(LossyDiscardingDecodable.self)
                }
            }

            self.wrappedValue = elements
        } catch {
            let fallbackPath = Self.baseFieldPath(from: decoder)
            let fieldPath = Self.fieldPath(for: error, fallbackPath: fallbackPath)

            SafeDecodingDiagnostics.emit(
                SafeDecodingIssue(
                    fieldPath: fieldPath,
                    errorDescription: SafeDecodingDiagnostics.description(
                        for: error,
                        fallbackPath: fieldPath
                    )
                )
            )

            self.wrappedValue = []
        }
    }
}

private extension LossySafeDecodable {
    static func baseFieldPath(from decoder: Decoder) -> String {
        let fallbackPath = decoder.codingPath.isEmpty ? "<root>" : decoder.codingPath.map(\.stringValue).joined(separator: ".")
        return SafeDecodingDiagnostics.normalizedFieldPath(from: decoder.codingPath, fallbackPath: fallbackPath)
    }

    static func fieldPath(for error: Error, fallbackPath: String) -> String {
        switch error {
        case let DecodingError.typeMismatch(_, context):
            return SafeDecodingDiagnostics.normalizedFieldPath(from: context.codingPath, fallbackPath: fallbackPath)
        case let DecodingError.valueNotFound(_, context):
            return SafeDecodingDiagnostics.normalizedFieldPath(from: context.codingPath, fallbackPath: fallbackPath)
        case let DecodingError.keyNotFound(_, context):
            return SafeDecodingDiagnostics.normalizedFieldPath(from: context.codingPath, fallbackPath: fallbackPath)
        case let DecodingError.dataCorrupted(context):
            return SafeDecodingDiagnostics.normalizedFieldPath(from: context.codingPath, fallbackPath: fallbackPath)
        default:
            return fallbackPath
        }
    }
}

private struct LossyDiscardingDecodable: Decodable {
    init(from decoder: Decoder) throws {
        if var container = try? decoder.unkeyedContainer() {
            while container.isAtEnd == false {
                _ = try? container.decode(LossyDiscardingDecodable.self)
            }
            return
        }

        if let container = try? decoder.container(keyedBy: DynamicCodingKey.self) {
            for key in container.allKeys {
                _ = try? container.decode(LossyDiscardingDecodable.self, forKey: key)
            }
            return
        }

        _ = try? decoder.singleValueContainer()
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

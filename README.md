<div align="center">
  <h1>SafeDecoding</h1>
  <p><strong>Resilient JSON decoding for Swift Decodable models when real-world payloads are messy.</strong></p>
  <p>
    <a href="https://swiftpackageindex.com/AltiAntonov/SafeDecoding">
      <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAltiAntonov%2FSafeDecoding%2Fbadge%3Ftype%3Dswift-versions" alt="Swift version compatibility">
    </a>
    <a href="https://swiftpackageindex.com/AltiAntonov/SafeDecoding">
      <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAltiAntonov%2FSafeDecoding%2Fbadge%3Ftype%3Dplatforms" alt="Platform compatibility">
    </a>
    <img src="https://img.shields.io/badge/License-MIT-34C759" alt="MIT License">
    <a href="https://github.com/AltiAntonov/SafeDecoding/actions/workflows/swift.yml"><img src="https://github.com/AltiAntonov/SafeDecoding/actions/workflows/swift.yml/badge.svg" alt="Swift workflow"></a>
  </p>
  <p>
    <a href="#features">Features</a> ·
    <a href="#installation">Installation</a> ·
    <a href="#quick-start">Quick Start</a> ·
    <a href="#when-to-use">When To Use</a> ·
    <a href="#good-fits">Good Fits</a> ·
    <a href="#weaker-fits">Weaker Fits</a> ·
    <a href="#runtime-semantics">Runtime Semantics</a> ·
    <a href="#documentation">Documentation</a> ·
    <a href="#testing">Testing</a>
  </p>
</div>

## Features

- `@SafeDecodable` for optional field failure isolation
- `SafeDecodingFallbackProvider` for typed fallback values on required fields
- `@SafeFallbackDecodable` for fallback-backed required-value decoding
- `SafeJSONDecoder` for app-level JSON decode plus report capture
- missing safe fields decode to `nil`
- broken safe fields do not fail the whole model
- broken fallback-backed fields emit placeholder diagnostics and use the provider value
- placeholder diagnostics for decode issues in `0.1.0` and the unreleased `0.3.0`

The current public API is intentionally centered on:

- `SafeDecodable`
- `SafeDecodingFallbackProvider`
- `SafeFallbackDecodable`
- `SafeJSONDecoder`
- `SafeDecodingReport`
- `SafeDecodingDiagnostics`
- `SafeDecodingIssue`

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/AltiAntonov/SafeDecoding.git", from: "0.4.0")
]
```

Then add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SafeDecoding", package: "SafeDecoding")
    ]
)
```

## Quick Start

```swift
import SafeDecoding

enum UnknownRoleFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "unknown"
}

struct User: Decodable {
    let id: Int
    @SafeDecodable var name: String?
    @SafeFallbackDecodable<UnknownRoleFallback> var role: String
}
```

If `name` is missing or malformed, decoding still succeeds and `name` becomes `nil`.
If `role` is present but malformed, decoding still succeeds and `role` becomes `"unknown"`.

For example, this dirty payload still decodes:

```json
{
  "id": 7,
  "name": 404,
  "role": 42
}
```

`name` falls back to `nil`, while `role` falls back to the typed provider value.

## Safe JSON Decoder

Use `SafeJSONDecoder` as the app-level entry point when you want the decoded value and a structured report in one call.

```swift
let result = try SafeJSONDecoder().decode(User.self, from: data)

let user = result.value
let report = result.report
```

`SafeJSONDecoder` is a convenience wrapper around `JSONDecoder` and `SafeDecodingDiagnostics.capture`. It does not implement a custom decoder and it does not reconstruct partial models when standard `Decodable` initialization fails.

You can inject a configured `JSONDecoder`:

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

let safeDecoder = SafeJSONDecoder(jsonDecoder: decoder)
let result = try safeDecoder.decode(User.self, from: data)
```

## Reports

Use `SafeDecodingDiagnostics.capture` when you want structured issue inspection around an existing decode call. `SafeJSONDecoder` is the higher-level convenience wrapper for app code that wants the same report alongside the decoded value.

```swift
let result = try SafeDecodingDiagnostics.capture {
    try JSONDecoder().decode(User.self, from: data)
}

let user = result.value
let report = result.report

if report.hasIssues {
    for issue in report.issues {
        print(issue.fieldPath, issue.errorDescription)
    }
}
```

This keeps the decoded model usable while giving the caller explicit access to the recovered-field issues.

## Typed Fallbacks

Use `SafeDecodingFallbackProvider` when the field is required by your model shape but upstream data is noisy.

```swift
import SafeDecoding

enum UnknownCountryFallback: SafeDecodingFallbackProvider {
    static let fallbackValue = "ZZ"
}

struct Shipment: Decodable {
    let id: String
    @SafeFallbackDecodable<UnknownCountryFallback> var destinationCountryCode: String
}
```

Dirty vendor payload:

```json
{
  "id": "shp_4815",
  "destinationCountryCode": 404
}
```

Decoded result:

```swift
let shipment = try JSONDecoder().decode(Shipment.self, from: data)
shipment.destinationCountryCode // "ZZ"
```

The fallback provider is explicit and typed, so the call site makes the recovery behavior visible in the model declaration instead of burying it in custom decoding code.

## When To Use

Use `SafeDecoding` when:

- you consume third-party or drift-prone APIs
- one broken field should not discard the whole payload
- you want typed defaults for required fields without writing custom `init(from:)`
- you want to stay in the `Codable` model

## Good Fits

- third-party APIs with inconsistent optional field quality
- apps that want to preserve valid model data instead of failing the whole decode
- codebases that prefer a small wrapper-based entry point over manual parsing
- models that need explicit fallback values such as `"unknown"`, `"ZZ"`, or sentinel enums
- teams that want placeholder diagnostics today and richer reporting later

## Weaker Fits

- strict backend contracts you fully control
- schema validation workflows
- rich reporting pipelines that need more than placeholder diagnostics
- cases where silent fallback values would hide contract breakage you should fail fast on

## Runtime Semantics

- `@SafeDecodable` is scoped to optional-like wrapped values
- `@SafeFallbackDecodable` uses the decoded value when decoding succeeds
- if a fallback-backed field is present but malformed, a placeholder diagnostic is emitted and the provider value is used
- the `0.3.0` reporting API is additive and non-breaking relative to `0.2.0`
- missing safe fields decode to `nil`
- broken safe fields emit a placeholder diagnostic and fall back to `nil`
- diagnostics are intentionally lightweight in `0.1.0` through `0.3.0`

## Documentation

`README.md` is the primary package documentation for the currently shipped package surface.

Swift Package Index metadata is configured in `.spi.yml` so the package page can reflect the current target and author metadata cleanly.

## Testing

`0.1.0` ships with Swift Testing coverage for valid values, missing keys, broken values, and diagnostic capture.
`0.2.0` extends that coverage to typed fallback-backed decoding behavior, and `0.3.0` adds report capture coverage.

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
- missing safe fields decode to `nil`
- broken safe fields do not fail the whole model
- placeholder diagnostics for decode issues in `0.1.0`

The current public API is intentionally centered on:

- `SafeDecodable`
- `SafeDecodingDiagnostics`
- `SafeDecodingIssue`

## Installation

Add `SafeDecoding` to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/AltiAntonov/SafeDecoding.git", from: "0.1.0")
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

struct User: Decodable {
    let id: Int
    @SafeDecodable var name: String?
}
```

If `name` is missing or malformed, decoding still succeeds and `name` becomes `nil`.

## When To Use

Use `SafeDecoding` when:

- you consume third-party or drift-prone APIs
- one broken field should not discard the whole payload
- you want to stay in the `Codable` model

## Good Fits

- third-party APIs with inconsistent optional field quality
- apps that want to preserve valid model data instead of failing the whole decode
- codebases that prefer a small wrapper-based entry point over manual parsing
- teams that want placeholder diagnostics today and richer reporting later

## Weaker Fits

- strict backend contracts you fully control
- schema validation workflows
- rich reporting pipelines that need more than placeholder diagnostics
- packages that need fallback values for non-optional fields today

## Runtime Semantics

- `@SafeDecodable` in `0.1.0` is scoped to optional-like wrapped values
- missing safe fields decode to `nil`
- broken safe fields emit a placeholder diagnostic and fall back to `nil`
- diagnostics are intentionally lightweight in `0.1.0`

## Documentation

`README.md` is the primary package documentation for `0.1.0`.

Swift Package Index metadata is configured in `.spi.yml` so the package page can reflect the current target and author metadata cleanly.

## Testing

`0.1.0` ships with Swift Testing coverage for valid values, missing keys, broken values, and diagnostic capture.

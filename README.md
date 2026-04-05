<div align="center">
  <h1>SafeDecoding</h1>
  <p><strong>Resilient JSON decoding for Swift Decodable models when real-world payloads are messy.</strong></p>
</div>

## Features

- `@SafeDecodable` for optional field failure isolation
- missing safe fields decode to `nil`
- broken safe fields do not fail the whole model
- placeholder diagnostics for decode issues in `0.1.0`

## Installation

```swift
.package(url: "https://github.com/AltiAntonov/SafeDecoding.git", from: "0.1.0")
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

## Weaker Fits

- strict backend contracts you fully control
- schema validation workflows
- rich reporting pipelines that need more than placeholder diagnostics

## Testing

`0.1.0` ships with Swift Testing coverage for valid values, missing keys, broken values, and diagnostic capture.

# Changelog

All notable changes to this project will be documented in this file.

## 0.3.1

### Fixed

- stabilized safe decoding issue descriptions across platforms by avoiding platform-dependent `DecodingError` stringification
- fixed GitHub CI failures in report tests caused by macOS and Linux formatting `DecodingError` differently

### Breaking Changes

- None. `0.3.1` is source-compatible with `0.3.0`.

## 0.3.0

### Added

- `SafeDecodingReport` for structured access to issues emitted during a scoped decode
- `SafeDecodingDiagnostics.capture` for capturing decoded values and reports together

### Changed

- docs now show how to inspect `report.issues` instead of relying only on placeholder print output

### Breaking Changes

- None. `0.3.0` is additive and source-compatible with `0.2.0`.

## 0.2.0

### Added

- `SafeDecodingFallbackProvider` for typed fallback values on required decoded fields
- `@SafeFallbackDecodable` for fallback-backed decoding that preserves model decoding when a present value is malformed
- README documentation for the new typed fallback-backed API, including dirty JSON examples and unreleased installation guidance

### Changed

- release metadata and roadmap notes now describe `0.2.0` as an additive, non-breaking update from `0.1.0`

### Breaking Changes

- None. `0.2.0` is source-compatible with `0.1.0` and adds the fallback-backed API without removing or renaming existing surface area.

## 0.1.0

### Added

- initial `SafeDecoding` package scaffold
- `@SafeDecodable` for optional safe field decoding
- missing-key support for optional wrapped fields
- placeholder safe decoding diagnostics
- Swift Testing coverage for the initial wrapper behavior

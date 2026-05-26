# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added

- MIT `LICENSE` file.

### Changed

- `fx.invoke` now pass-through Result-shaped return values (fixes ox_lib callback error handling).
- `ox_lib` is optional for the core library; required only for callback examples.
- Result values are tagged to avoid misidentifying domain tables as Results.
- Documentation for `fx.wrap` return shapes and optional `ox_lib` usage.

### Fixed

- README installation step numbering and missing `mapErr` in the API table.

## [1.0.0] - 2025

Initial release: Result type, `fx.wrap`, `fx.invoke`, `fx.invokeExport`, pipeline, and error parsing for FiveM Lua.

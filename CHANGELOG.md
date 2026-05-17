# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedBrex<T>(...)` — wraps a otel_brex call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutBrexInstrumentation()` / `Async()`.

# lua-effect Documentation

Effect-style data and error flow for FiveM Lua. This library improves error propagation across resource boundaries so you get real error messages instead of FiveM's generic "an error occurred in resource X".

## Documentation Index

| Document | Audience | Description |
|----------|----------|-------------|
| [Getting Started](getting-started.md) | Users | Installation, setup, and first steps |
| [API Reference](api-reference.md) | Users | Complete API with types and examples |
| [Exports & Callbacks](exports-and-callbacks.md) | Users | FiveM exports, cross-resource calls, ox_lib callbacks |
| [Result Type](result-type.md) | Users | Result pattern, composition, and error handling |
| [Error Handling](error-handling.md) | Users | Error parsing, metadata, and propagation |
| [Implementation Guide](implementation-guide.md) | Agents | Rules and patterns for AI-assisted implementation |

## Quick Links

- **Define an export:** `exports('name', fx.wrap(function(arg) ... end))`
- **Call an export:** `fx.invokeExport('resource', 'name', arg)` → returns `Result`
- **Unwrap or throw:** `fx.invokeExportUnwrap('resource', 'name', arg)` → value or throws
- **Local function:** `fx.invoke(fn, ...)` → returns `Result`

## Dependencies

- [ox_lib](https://coxdocs.dev/ox_lib) (required)
- FiveM/CitizenFX

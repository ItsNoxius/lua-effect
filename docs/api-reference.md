# API Reference

## Result Type

| Function | Signature | Description |
|----------|-----------|-------------|
| `fx.ok` | `(value: any) -> Result` | Create a success result |
| `fx.err` | `(err: string \| table) -> Result` | Create a failure result. Parses raw errors into message + metadata. |
| `fx.isOk` | `(r: Result) -> boolean` | `true` if result is success |
| `fx.isErr` | `(r: Result) -> boolean` | `true` if result is failure |
| `fx.unwrap` | `(r: Result, level?: number) -> any` | Return value or throw with error message |
| `fx.assertResult` | `(r: Result, message?: string, level?: number) -> any` | Like `assert`: unwrap or throw with optional custom message |
| `fx.unwrapOr` | `(r: Result, default: any) -> any` | Return value or `default` on failure |
| `fx.map` | `(r: Result, fn: (v) -> any) -> Result` | Apply `fn` to value if success; pass through error |
| `fx.mapErr` | `(r: Result, fn: (err) -> string \| table) -> Result` | Transform error if failure |
| `fx.andThen` | `(r: Result, fn: (v) -> Result) -> Result` | Chain: if success, run `fn(value)` and return its result |
| `fx.orElse` | `(r: Result, fn: (err) -> Result) -> Result` | Recover: if failure, run `fn(error)` and return its result |
| `fx.getErrorInfo` | `(r: Result) -> ParsedError \| nil` | Parsed error metadata (message, location, file, line, resource) or nil if Ok |

### Result Structure

- **Success:** `{ ok = true, value = any }`
- **Failure:** `{ ok = false, error = string, errorMeta?: ParsedError }`
  - `error` — message only (no path)
  - `errorMeta` — optional: `{ message, location, file, line, resource }`

---

## Try (Wrapping error/assert)

| Function | Signature | Description |
|----------|-----------|-------------|
| `fx.try` | `(fn: (...any) -> any) -> (...any) -> Result` | Wrap a function so it returns Result instead of throwing |
| `fx.tryCall` | `(fn: () -> any) -> Result` | Execute a function once and return Result |

---

## FiveM Exports & Local Invoke

| Function | Signature | Description |
|----------|-----------|-------------|
| `fx.wrap` | `(fn: (...any) -> any) -> (...any) -> any` | Wrap for exports/callbacks. Catches throws, returns `Result.err`. FiveM will not log SCRIPT ERROR in the called resource. |
| `fx.invoke` | `(fn: function, ...any) -> Result` | Call a local function, return Result |
| `fx.invokeUnwrap` | `(fn: function, ...any) -> any` | Call a local function, return value or throw |
| `fx.invokeExport` | `(resource: string, export: string, ...any) -> Result` | Call an export, return Result |
| `fx.invokeExportUnwrap` | `(resource: string, export: string, ...any) -> any` | Call an export, return value or throw |

---

## Pipeline

| Function | Signature | Description |
|----------|-----------|-------------|
| `fx.pipe` | `(value: any, ...fn: (any) -> any) -> any` | Pass value through functions. Short-circuits on Result error. |
| `fx.pipeWith` | `(fn: () -> any, ...transform: (any) -> any) -> any` | Run `fn()` first, then pipe its result through the rest |

---

## Error Parsing

| Function | Signature | Description |
|----------|-----------|-------------|
| `fx.parseError` | `(message: any) -> ParsedError` | Parse error string into `{ message, location?, file?, line?, resource? }` |

### ParsedError

```lua
{
    message = string,   -- Clean message (trace stripped)
    location = string, -- "file:line" when parseable
    file = string,     -- File path when parseable
    line = number,     -- Line number when parseable
    resource = string  -- Resource name for @resource/path (FiveM)
}
```

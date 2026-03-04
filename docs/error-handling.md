# Error Handling

## Message vs Metadata

When an error is captured (e.g. from `fx.wrap`, `fx.invoke`, `fx.invokeExport`), raw errors like `@example_resource/server.lua:23: Missing divisor` are parsed into:

- **`result.error`** — message only: `"Missing divisor"`
- **`result.errorMeta`** — optional metadata when parseable

## errorMeta Structure

```lua
{
    message = "Missing divisor",
    location = "@example_resource/server.lua:23",
    file = "@example_resource/server.lua",
    line = 23,
    resource = "example_resource"
}
```

- `message` — clean message for display
- `location` — `"file:line"` for logging/debugging
- `file` — file path
- `line` — line number
- `resource` — FiveM resource name (when path is `@resource/path`)

## Accessing Metadata

```lua
local result = fx.invokeExport('my-resource', 'divide', 10, 0)
if fx.isErr(result) then
    print(result.error)  -- "Missing divisor" or "Cannot divide by zero"
    if result.errorMeta then
        print('  Resource:', result.errorMeta.resource)
        print('  Line:', result.errorMeta.line)
        print('  Location:', result.errorMeta.location)
    end
end
```

Or use `fx.getErrorInfo`:

```lua
local info = fx.getErrorInfo(result)
if info then
    print(info.message, info.resource, info.line)
end
```

## Parsing Raw Errors

For arbitrary error strings:

```lua
local parsed = fx.parseError("@resource/file.lua:42: Some error")
-- { message = "Some error", location = "...", file = "...", line = 42, resource = "resource" }
```

## Error Propagation Flow

1. Export throws → `fx.wrap` catches, returns `Result.err`
2. No throw in called resource → no SCRIPT ERROR there
3. `invokeExport` receives `Result.err`, returns it to caller
4. Caller uses `result.error` (message) and `result.errorMeta` (metadata)

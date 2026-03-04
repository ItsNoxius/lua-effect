# Implementation Guide (for Agents)

This document helps AI assistants implement `lua-effect` correctly when editing or creating FiveM Lua resources.

---

## Core Rules

1. **Exports must use `fx.wrap`** — Any function passed to `exports('name', fn)` must be wrapped: `exports('name', fx.wrap(fn))`.

2. **Call exports via `fx.invokeExport` or `fx.invokeExportUnwrap`** — Do not rely on raw `exports['resource']:exportName(args)` when you need proper error messages.

3. **Resource names use folder names** — Use `example_resource` not `example-resource` when the folder is `example_resource`. FiveM identifies resources by folder name.

4. **No `stripFirst` / no self parameter** — FiveM does not pass the exports table as the first argument. Export functions receive only caller-provided args: `function(userId)` not `function(self, userId)`.

5. **`result.error` is message-only** — Path/location is in `result.errorMeta` when available.

---

## Decision Tree

### Defining an export

```
Is this an export (exports('name', fn))?
  YES → Use fx.wrap: exports('name', fx.wrap(function(...) ... end))
  NO  → No wrap needed
```

### Calling an export

```
Do you need proper error messages / Result handling?
  YES → Use fx.invokeExport or fx.invokeExportUnwrap
  NO  → Raw exports['resource']:name(args) is fine (unchanged behavior)
```

### Local functions that may throw

```
Do you want Result instead of throw?
  YES → Use fx.invoke(fn, ...) or fx.invokeUnwrap(fn, ...)
  NO  → Call fn(...) directly
```

---

## Code Patterns

### Export definition (correct)

```lua
exports('getUser', fx.wrap(function(userId)
    assert(userId and userId > 0, 'Invalid user ID: ' .. tostring(userId))
    return GetUser(userId)
end))
```

### Export definition (incorrect)

```lua
-- WRONG: no fx.wrap
exports('getUser', function(userId) ... end)

-- WRONG: stripFirst / self (removed from API)
exports('getUser', fx.wrap(function(self, userId) ... end, true))
```

### Calling an export (correct)

```lua
-- Result-based
local result = fx.invokeExport('my_resource', 'getUser', 123)
if fx.isOk(result) then
    use(result.value)
else
    print(result.error)
end

-- Unwrap (throws on error)
local user = fx.invokeExportUnwrap('my_resource', 'getUser', 123)
```

### ox_lib callback (correct)

```lua
-- Server
lib.callback.register('name', fx.wrap(function(source, playerId)
    return GetData(playerId)
end))

-- Client (with Result)
local result = fx.invoke(lib.callback.await, 'name', false, playerId)
```

---

## Manifest Requirements

```lua
dependencies {
    'ox_lib',
    'lua-effect',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@lua-effect/fx.lua',
}
```

---

## Common Mistakes

| Mistake | Fix |
|--------|-----|
| Export without `fx.wrap` | Wrap: `fx.wrap(function(...) ... end)` |
| Using `example-resource` when folder is `example_resource` | Use folder name: `example_resource` |
| Expecting `self` as first export arg | FiveM omits it; use `function(arg1, arg2)` |
| Printing `result.error` and expecting path | Path is in `result.errorMeta` |
| Calling `fx.invokeExportUnwrap` without pcall when errors possible | Use pcall or handle via `fx.invokeExport` + `fx.isErr` |

---

## API Quick Reference

| Use case | API |
|----------|-----|
| Define export | `exports('name', fx.wrap(fn))` |
| Call export, get Result | `fx.invokeExport(resource, export, ...)` |
| Call export, get value or throw | `fx.invokeExportUnwrap(resource, export, ...)` |
| Call local fn, get Result | `fx.invoke(fn, ...)` |
| Call local fn, get value or throw | `fx.invokeUnwrap(fn, ...)` |
| Check success | `fx.isOk(result)` |
| Check failure | `fx.isErr(result)` |
| Get value | `result.value` |
| Get error message | `result.error` |
| Get error metadata | `result.errorMeta` or `fx.getErrorInfo(result)` |
| Create Result | `fx.ok(value)`, `fx.err(message)` |

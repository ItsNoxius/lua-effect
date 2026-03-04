# Getting Started

## Installation

1. Add `lua-effect` to your server's `resources` folder.
2. Add dependencies to your resource's `fxmanifest.lua`:

```lua
fx_version 'cerulean'
game 'gta5'

dependencies {
    'ox_lib',
    'lua-effect',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@lua-effect/fx.lua',
}
```

3. Use `fx` (global) or require:

```lua
local fx = require('@lua-effect.fx')
```

## Minimal Example

### Exporting (resource that defines the export)

```lua
exports('getUser', fx.wrap(function(userId)
    local user = GetUserFromDb(userId)
    assert(user, 'User not found: ' .. tostring(userId))
    return user
end))
```

### Invoking (resource that calls the export)

```lua
-- Option A: Handle Result explicitly
local result = fx.invokeExport('my-database', 'getUser', 123)
if fx.isOk(result) then
    print('User:', result.value.name)
else
    print('Error:', result.error)
end

-- Option B: Unwrap (throws on error, like a normal call)
local user = fx.invokeExportUnwrap('my-database', 'getUser', 123)
```

## What Problem Does This Solve?

Without `fx`, when an export throws an error, FiveM returns a generic message like *"an error occurred in resource X"* instead of the actual error. With `fx.wrap` and `fx.invokeExport`, the real error message is preserved and returned as a `Result` value.

## Next Steps

- [API Reference](api-reference.md) — Full function list
- [Exports & Callbacks](exports-and-callbacks.md) — Cross-resource patterns
- [Result Type](result-type.md) — Composing with Result

# fx — Effect-style data and error flow for FiveM Lua

A Lua library for FiveM inspired by [Effect](https://effect.website/) that improves data flow and error propagation across resources.

## The problem

When resource A calls an export from resource B and B throws an error, FiveM often returns a generic message like *"an error occurred in resource X"* instead of the actual error message. This makes debugging difficult.

## The solution

`fx` treats errors as values (like Effect’s `Result` type) instead of exceptions. When you use `fx.invoke` (local) or `fx.invokeExport` (exports), thrown errors are caught and returned as Result values with the actual message, instead of FiveM's generic "an error occurred in resource X".

You can keep using standard Lua `error()` and `assert()`; `fx` does not change how exports behave.

### Backwards compatibility

- **Raw `exports.resource:name()`**: Unchanged. Returns the same values, throws on error (FiveM will still show its generic message for throws).
- **Direct function calls**: Unchanged. Call any function normally; no wrapping required.
- **`fx.invoke(fn, ...)`**: Local functions. Catches throws and returns a Result. Zero overhead when calling the function directly.
- **`fx.invokeExport(resource, export, ...)`**: Exports. Same Result-based error handling.
- **`fx.wrap(fn)`**: For exports and callbacks. Catches throws and returns Result.err so errors propagate as values across resource boundaries.

---

## Installation

Requires [ox_lib](https://coxdocs.dev/ox_lib).
2. Add it as a dependency in your resource’s `fxmanifest.lua`:

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

Then use `fx` (global) or inline require:

```lua
local fx = require('@lua-effect.fx')
```

---

## Quick start

### Exporting (resource that defines the export)

Wrap with `fx.wrap` so errors propagate as values instead of throwing:

```lua
-- In your database resource
exports('getUser', fx.wrap(function(userId)
    local user = GetUserFromDb(userId)
    assert(user, 'User not found: ' .. tostring(userId))
    return user
end))
```

### Invoking (resource that calls the export)

**Option 1: Return value or throw** (same behavior as direct call, but with correct error messages):

```lua
local user = fx.invokeExportUnwrap('my-database', 'getUser', 123)
-- If the export fails, you get the real error: "User not found: 123"
```

**Option 2: Handle the result explicitly**:

```lua
local result = fx.invokeExport('my-database', 'getUser', 123)
if fx.isOk(result) then
    print('User:', result.value.name)
else
    print('Error:', result.error)
end
```

### Local functions

Same function, call directly or via `fx.invoke` — no wrapping, no overhead:

```lua
local function loadConfig(path)
    local data = LoadResourceFile(GetCurrentResourceName(), path)
    assert(data, 'Config not found: ' .. path)
    return json.decode(data)
end

-- Direct call: normal return/throw
local config = loadConfig('config.json')

-- Via fx.invoke: Result with proper error message
local result = fx.invoke(loadConfig, 'config.json')
if fx.isOk(result) then
    use(result.value)
end
```

### Nested invocation (single resource)

Local functions can call each other via `fx.invoke` / `fx.invokeUnwrap`:

```lua
local function validateId(id)
    assert(id and id > 0, 'Invalid ID')
    return id
end

local function fetchUser(id)
    local validId = fx.invokeUnwrap(validateId, id)
    return { id = validId, name = 'User ' .. validId }
end

-- Export uses nested local calls
exports('getUser', fx.wrap(function(userId)
    return fx.invokeUnwrap(fetchUser, userId)
end))
```

### Cross-scope callbacks (server ↔ client)

Use [ox_lib](https://coxdocs.dev/ox_lib/Modules/Callback) with `fx.wrap` for handlers:

```lua
-- Server: lib.callback.register with fx.wrap
lib.callback.register('myresource:getPlayerData', fx.wrap(function(source, playerId)
    assert(playerId, 'Player ID required')
    return GetPlayerData(playerId)
end))

-- Client: lib.callback.await (wrap with fx.invoke for Result)
local result = fx.invoke(lib.callback.await, 'myresource:getPlayerData', false, playerId)
```

---

## API reference

### Result type

| Function | Description |
|----------|-------------|
| `fx.ok(value)` | Create a success result |
| `fx.err(message)` | Create a failure result |
| `fx.isOk(result)` | Returns `true` if result is success |
| `fx.isErr(result)` | Returns `true` if result is failure |
| `fx.unwrap(result)` | Return value or throw with the error message |
| `fx.assertResult(result, msg?)` | Like `assert`: return value or throw (optional custom message) |
| `fx.unwrapOr(result, default)` | Return value or `default` on failure |
| `fx.map(result, fn)` | Apply `fn` to the value if success |
| `fx.andThen(result, fn)` | Chain: if success, run `fn(value)` and return its result |
| `fx.orElse(result, fn)` | Recover: if failure, run `fn(error)` and return its result |

### Try (wrapping `error` / `assert`)

| Function | Description |
|----------|-------------|
| `fx.try(fn)` | Wrap a function so it returns a Result instead of throwing |
| `fx.tryCall(fn)` | Run a function once and return a Result |

### FiveM exports & local invoke

| Function | Description |
|----------|-------------|
| `fx.wrap(fn)` | Wrap for exports/callbacks; catches throws, returns Result.err |
| `fx.invoke(fn, ...)` | Call a local function, return Result |
| `fx.invokeUnwrap(fn, ...)` | Call a local function, return value or throw on error |
| `fx.invokeExport(resource, export, ...)` | Call an export, return Result |
| `fx.invokeExportUnwrap(resource, export, ...)` | Call an export, return value or throw on error |

Call functions directly for normal behavior; use `fx.invoke` or `fx.invokeExport` when you want Result-based error handling. No wrapping required.

### Pipeline

| Function | Description |
|----------|-------------|
| `fx.pipe(value, fn1, fn2, ...)` | Pass `value` through `fn1`, then `fn2`, etc. Short-circuits on Result error. |
| `fx.pipeWith(fn, fn1, fn2, ...)` | Run `fn()` first, then pipe its result through the rest |

```lua
-- Simple transform chain
fx.pipe(5, function(x) return x * 2 end, function(x) return x + 10 end)

-- With Result: short-circuits on first error
local result = fx.pipe(jsonStr, parseJson, function(d) return getField(d, 'count') end, validatePositive)

-- pipeWith: first step may fail (e.g. load file)
local cfg = fx.pipeWith(loadConfig, getMaxPlayers)
```

Example: `example/example_pipeline/`.

### Error parsing

| Function | Description |
|----------|-------------|
| `fx.parseError(message)` | Parse error into `{ message, location?, file?, line? }` — message is clean, location is "file:line" |
| `fx.getErrorInfo(result)` | For failed results, returns parsed `{ message, location?, file?, line? }` or nil |

---

## Migration guide

### Before (errors get lost)

```lua
-- resource-a/server.lua
exports('getPlayerData', function(playerId)
    local data = GetData(playerId)
    assert(data, 'Player not found')
    return data
end)

-- resource-b/server.lua
local data = exports['resource-a']:getPlayerData(123)  -- Generic error on failure
```

### After (errors preserved)

```lua
-- resource-a/server.lua
exports('getPlayerData', fx.wrap(function(playerId)
    local data = GetData(playerId)
    assert(data, 'Player not found')
    return data
end))

-- resource-b/server.lua
local data = fx.invokeExportUnwrap('resource-a', 'getPlayerData', 123)  -- Real error message
```

### Using `fx.try` for one-off blocks

```lua
local result = fx.tryCall(function()
    local json = LoadResourceFile(GetCurrentResourceName(), 'data.json')
    return json.decode(json)
end)

if fx.isOk(result) then
    use(result.value)
else
    print('Parse failed:', result.error)
end
```

### Composing with `pipe` and `andThen`

```lua
local result = fx.tryCall(function()
    return GetUserInput()
end)

local processed = fx.andThen(result, function(user)
    return fx.tryCall(function()
        return validateAndSave(user)
    end)
end)
```

---

## License

MIT

# Result Type

`fx` uses a Result type: either success (`Ok`) or failure (`Err`). Errors are values, not exceptions, so they can be safely passed across FiveM resource boundaries.

## Structure

```lua
-- Success
{ ok = true, value = any }

-- Failure
{ ok = false, error = string, errorMeta?: ParsedError }
```

- `error` — message only (path/location stripped for display)
- `errorMeta` — optional metadata: `{ message, location, file, line, resource }`

## Creating Results

```lua
local ok = fx.ok({ name = 'Alice' })
local err = fx.err('Something went wrong')
```

## Checking

```lua
if fx.isOk(result) then
    -- use result.value
end

if fx.isErr(result) then
    -- use result.error, result.errorMeta
end
```

## Unwrapping

```lua
-- Throw on error (use when you want to propagate)
local value = fx.unwrap(result)

-- Default on error
local value = fx.unwrapOr(result, defaultValue)

-- Custom message when throwing
local value = fx.assertResult(result, 'Custom error message')
```

## Transforming

### map — transform success value

```lua
local nameResult = fx.map(userResult, function(user) return user.name end)
```

### mapErr — transform error

```lua
local friendly = fx.mapErr(result, function(err) return 'Failed: ' .. err end)
```

### andThen — chain Result-returning functions

```lua
local result = fx.andThen(loadUser(123), function(user)
    return saveUser(user)
end)
```

### orElse — recover from failure

```lua
local result = fx.orElse(failedResult, function(err)
    return fx.ok(getDefaultValue())
end)
```

## Pipeline

Chain operations with automatic short-circuit on error:

```lua
local result = fx.pipe(
    jsonStr,
    parseJson,
    function(d) return getField(d, 'count') end,
    validatePositive
)
```

With an initial function that may fail:

```lua
local cfg = fx.pipeWith(loadConfig, getMaxPlayers)
```

## Try

Wrap one-off blocks that may throw:

```lua
local result = fx.tryCall(function()
    local json = LoadResourceFile(GetCurrentResourceName(), 'data.json')
    return json.decode(json)
end)
```

Wrap a function for reuse:

```lua
local safeLoad = fx.try(loadConfig)
local result = safeLoad('config.json')
```

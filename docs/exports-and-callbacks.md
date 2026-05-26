# Exports & Callbacks

## Defining Exports

Always wrap export functions with `fx.wrap` so errors propagate as values instead of throwing:

```lua
exports('getUser', fx.wrap(function(userId)
    local user = GetUserFromDb(userId)
    assert(user, 'User not found: ' .. tostring(userId))
    return user
end))
```

### Why fx.wrap?

- Catches any `error()` or `assert()` and returns `Result.err` instead of throwing
- FiveM will not log SCRIPT ERROR in the called resource
- The caller receives the actual error message via `fx.invokeExport` or `fx.invokeExportUnwrap`

### fx.wrap return shapes

`fx.wrap` is asymmetric by design:

| Outcome | Return value |
|---------|--------------|
| Success | **Raw value** — whatever your function returned |
| Failure | **`Result.err`** — `{ ok = false, error = string, errorMeta? }` |

When calling a wrapped export via **`fx.invokeExport`**, the invoke layer normalizes both paths into a `Result`. When calling **raw** (`exports['resource']:name(...)`), you must handle both shapes:

```lua
local ret = exports['my-resource']:getUser(123)
if type(ret) == 'table' and ret.ok == false then
    print('Error:', ret.error)
else
    print('User:', ret.name)
end
```

Prefer `fx.invokeExport` or `fx.invokeExportUnwrap` at call sites so you always get a consistent `Result`.

### FiveM Export Behavior

FiveM does **not** pass the exports table as a first argument when invoking exports. Your function receives only the arguments the caller provides. Use `function(userId)` not `function(self, userId)`.

---

## Calling Exports

### Option 1: Result-based (recommended)

```lua
local result = fx.invokeExport('my-resource', 'getUser', 123)
if fx.isOk(result) then
    print(result.value.name)
else
    print('Error:', result.error)
    if result.errorMeta then
        print('  Resource:', result.errorMeta.resource, 'Line:', result.errorMeta.line)
    end
end
```

### Option 2: Unwrap (throws on error)

```lua
local user = fx.invokeExportUnwrap('my-resource', 'getUser', 123)
-- Throws with real error message if export fails
```

### Option 3: Raw call (wrapped export)

```lua
local ret = exports['my-resource']:getUser(123)
-- Success: raw user object. Failure (fx.wrap): Result.err table — not a throw.
-- Prefer fx.invokeExport for consistent Result handling.
```

---

## Nested Local Calls

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

exports('getUser', fx.wrap(function(userId)
    return fx.invokeUnwrap(fetchUser, userId)
end))
```

---

## ox_lib Callbacks (Server ↔ Client)

Requires [ox_lib](https://coxdocs.dev/ox_lib) in resources that use callbacks. Add `ox_lib` to `dependencies` and `@ox_lib/init.lua` to `shared_scripts` in those resources only.

Use `fx.wrap` for callback handlers and `fx.invoke` when awaiting:

```lua
-- Server: register callback
lib.callback.register('myresource:getPlayerData', fx.wrap(function(source, playerId)
    assert(playerId, 'Player ID required')
    return GetPlayerData(playerId)
end))

-- Client: await callback (wrap with fx.invoke for Result)
local result = fx.invoke(lib.callback.await, 'myresource:getPlayerData', false, playerId)
if fx.isOk(result) then
    use(result.value)
end
```

---

## Resource Names

Use the resource **folder name** (e.g. `example_resource`), not a display name. FiveM identifies resources by their folder name.

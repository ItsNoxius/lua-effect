-- Example: fx.pipe and fx.pipeWith for composable data flow
-- Pipeline short-circuits on Result errors; unwraps Result success for the next step

-- Simple pipe: transform a value through a series of functions
local function double(x) return x * 2 end
local function addTen(x) return x + 10 end
local function formatResult(x) return 'Result: ' .. tostring(x) end

local result = fx.pipe(5, double, addTen, formatResult)
print('[pipeline] Simple pipe:', result)

-- Pipe with Result-returning functions (short-circuits on error)
local function parseJson(str)
    local ok, data = pcall(json.decode, str)
    return ok and fx.ok(data) or fx.err('Invalid JSON')
end

local function getField(data, key)
    if data and data[key] ~= nil then
        return fx.ok(data[key])
    end
    return fx.err('Missing field: ' .. tostring(key))
end

local function validatePositive(n)
    if type(n) == 'number' and n > 0 then
        return fx.ok(n)
    end
    return fx.err('Expected positive number, got: ' .. tostring(n))
end

-- Success path
local jsonStr = '{"count": 42}'
local parsed = fx.pipe(jsonStr, parseJson, function(d) return getField(d, 'count') end, validatePositive)
if fx.isOk(parsed) then
    print('[pipeline] Parsed count:', parsed.value)
else
    print('[pipeline] Parse error:', parsed.error)
end

-- Error path (short-circuits at invalid JSON)
local badResult = fx.pipe('not json', parseJson, function(d) return getField(d, 'count') end, validatePositive)
if fx.isErr(badResult) then
    print('[pipeline] Expected error:', badResult.error)
end

-- pipeWith: first step may fail (e.g. load resource)
local function loadConfig()
    local data = LoadResourceFile(GetCurrentResourceName(), 'config.json')
    if not data or data == '' then
        return fx.err('Config not found')
    end
    local ok, cfg = pcall(json.decode, data)
    return ok and fx.ok(cfg) or fx.err('Invalid config')
end

local function getMaxPlayers(cfg)
    return cfg.maxPlayers and fx.ok(cfg.maxPlayers) or fx.err('maxPlayers not set')
end

-- pipeWith runs loadConfig() first, then pipes through the rest
local configResult = fx.pipeWith(loadConfig, getMaxPlayers)
if fx.isOk(configResult) then
    print('[pipeline] pipeWith maxPlayers:', configResult.value)
else
    print('[pipeline] pipeWith error (config may not exist):', configResult.error)
end

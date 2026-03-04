-- Example: Calling exports (invokeExport) and local nested functions (invoke)
-- Demonstrates both cross-resource and single-resource invocation patterns

-- Local helper - formats a user for display
local function formatUser(user)
    assert(user and user.name, 'Invalid user object')
    return user.name .. ' (id: ' .. user.id .. ')'
end

-- Local helper - fetches from export and formats (nested: invokeExport -> invoke)
local function fetchAndFormatUser(userId)
    local user = fx.invokeExportUnwrap('example-resource', 'getUser', userId)
    return fx.invokeUnwrap(formatUser, user)
end

CreateThread(function()
    Wait(1000)  -- Ensure example-resource is loaded

    -- === EXPORTS (cross-resource) ===

    -- Method 1: invokeExportUnwrap - get value or throw with real error message
    local ok, user = pcall(fx.invokeExportUnwrap, 'example-resource', 'getUser', 42)
    if ok then
        print('[caller] Export - got user:', user.name)
    else
        print('[caller] Export - error:', user)
    end

    -- Method 2: invokeExport - handle Result explicitly
    local result = fx.invokeExport('example-resource', 'getUser', 0)
    if fx.isOk(result) then
        print('[caller] User:', result.value.name)
    else
        print('[caller] Got proper error message:', result.error)
    end

    -- Method 3: invokeExport - divide (assert message propagation)
    local divResult = fx.invokeExport('example-resource', 'divide', 10, 0)
    if fx.isErr(divResult) then
        print('[caller] Divide error:', divResult.error)
    end

    -- Method 4: invokeExport - nested export (getUserWithBalance internally uses fx.invoke)
    local balanceResult = fx.invokeExport('example-resource', 'getUserWithBalance', 42)
    if fx.isOk(balanceResult) then
        print('[caller] User with balance:', balanceResult.value.user.name, balanceResult.value.balance)
    end

    -- === LOCAL FUNCTIONS (single resource, nested invocation) ===

    -- Method 5: invoke - local function only
    local fmtResult = fx.invoke(formatUser, { id = 1, name = 'Test' })
    if fx.isOk(fmtResult) then
        print('[caller] Local format:', fmtResult.value)
    end

    -- Method 6: invoke - nested local calls (fetchAndFormatUser -> invokeExport -> invoke)
    local formatted = fx.invokeUnwrap(fetchAndFormatUser, 42)
    print('[caller] Nested local+export:', formatted)

    -- Method 7: Raw invocation - unchanged behavior
    local user = exports['example-resource']:getUser(42)
    print('[caller] Raw call - got user:', user and user.name or 'nil')
end)

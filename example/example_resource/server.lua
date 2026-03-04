-- Example: Using fx for exports and nested local function invocation
-- Demonstrates both cross-resource exports and local fx.invoke within a single resource

-- Local helper - validates user ID (used internally via fx.invoke)
local function validateUserId(userId)
    assert(userId and userId > 0, 'Invalid user ID: ' .. tostring(userId))
    return userId
end

-- Local helper - fetches user data (calls validateUserId via fx.invoke)
local function fetchUser(userId)
    local id = fx.invokeUnwrap(validateUserId, userId)
    return { id = id, name = 'User ' .. id }
end

-- Export: getUser - uses local fetchUser via fx.invoke
exports('getUser', fx.wrap(function(userId)
    return fx.invokeUnwrap(fetchUser, userId)
end))

-- Export: divide - standalone, errors on divide by zero
exports('divide', fx.wrap(function(a, b)
    assert(b ~= nil, 'Missing divisor')
    assert(b ~= 0, 'Cannot divide by zero')
    return a / b
end))

-- Export: getUserWithBalance - nested local calls (validate -> fetch -> calculate)
local function getBalance(userId)
    local user = fx.invokeUnwrap(fetchUser, userId)
    return user.id * 100  -- fake balance
end

exports('getUserWithBalance', fx.wrap(function(userId)
    local user = fx.invokeUnwrap(fetchUser, userId)
    local balance = fx.invokeUnwrap(getBalance, userId)
    return { user = user, balance = balance }
end))

print('[example_resource] Loaded - exports: getUser, divide, getUserWithBalance')

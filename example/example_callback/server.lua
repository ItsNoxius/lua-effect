-- Example: Server callbacks with ox_lib + fx.wrap
-- Client calls via lib.callback.await; wrap with fx.invoke for Result
-- Docs: https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server

lib.callback.register('example-callback:getPlayerData', fx.wrap(function(source, playerId)
    assert(playerId and playerId > 0, 'Invalid player ID: ' .. tostring(playerId))
    return { id = playerId, name = 'Player ' .. playerId, source = source }
end))

lib.callback.register('example-callback:getServerConfig', fx.wrap(function(source)
    return { maxPlayers = 32, version = '1.0' }
end))

CreateThread(function()
    Wait(2000)
    local players = GetPlayers()
    if #players > 0 then
        local targetId = tonumber(players[1])
        local result = fx.invoke(lib.callback.await, 'example-callback:getNearbyVehicles', targetId, 50.0)
        if fx.isOk(result) then
            print('[example-callback] Server got client vehicles:', #result.value)
        else
            print('[example-callback] Server callback error:', result.error)
        end
    end
end)

print('[example-callback] Server loaded - callbacks: getPlayerData, getServerConfig')

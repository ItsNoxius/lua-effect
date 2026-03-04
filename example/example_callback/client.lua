-- Example: Client callbacks with ox_lib + fx.wrap
-- Server calls via lib.callback.await; wrap with fx.invoke for Result
-- Docs: https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client

lib.callback.register('example-callback:getNearbyVehicles', fx.wrap(function(radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicles = {}
    local handle, vehicle = FindFirstVehicle()
    local success
    repeat
        if vehicle ~= ped and DoesEntityExist(vehicle) then
            local vehCoords = GetEntityCoords(vehicle)
            local dist = #(coords - vehCoords)
            if dist <= (radius or 50.0) then
                vehicles[#vehicles + 1] = vehicle
            end
        end
        success, vehicle = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return vehicles
end))

CreateThread(function()
    Wait(3000)
    local result = fx.invoke(lib.callback.await, 'example-callback:getPlayerData', false, GetPlayerServerId(PlayerId()))
    if fx.isOk(result) then
        print('[example-callback] Client got player data:', result.value.name)
    else
        print('[example-callback] Client callback error:', result.error)
    end

    local config = fx.invokeUnwrap(lib.callback.await, 'example-callback:getServerConfig', false)
    print('[example-callback] Client got config:', config.maxPlayers)
end)

print('[example-callback] Client loaded - callback: getNearbyVehicles')

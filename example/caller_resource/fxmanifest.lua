fx_version 'cerulean'
game 'gta5'

name 'caller-resource'
description 'Calls example-resource exports - demonstrates proper error propagation'
version '1.0.0'

dependencies {
    'ox_lib',
    'lua-effect',
    'example-resource',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@lua-effect/fx.lua',
}

server_scripts {
    'server.lua',
}

fx_version 'cerulean'
game 'gta5'

name 'example-pipeline'
description 'Example: fx.pipe and fx.pipeWith for composable data flow'
version '1.0.0'

dependencies {
    'ox_lib',
    'lua-effect',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@lua-effect/fx.lua',
}

server_scripts {
    'server.lua',
}

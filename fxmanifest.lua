fx_version 'cerulean'
game 'gta5'

name 'lua-effect'
description 'Effect-style data and error flow for FiveM - proper error propagation across resources'
version '1.0.0'
author ''

dependencies {
    'ox_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
    'fx.lua',
}

files {
    'fx.lua',
    'fx/**/*.lua',
}
---# fx - Effect-style data and error flow for FiveM Lua
---
---Requires ox_lib. Use in fxmanifest:
---  shared_scripts { '@ox_lib/init.lua', '@lua-effect/fx.lua' }
---
---Then: local fx = require('@lua-effect.fx')
---
---Or: local fx = require('lua-effect.fx')

local fx = require('fx.init')

-- Register for inline require (no manifest import needed)
package.loaded['@lua-effect.fx'] = fx
package.loaded['lua-effect.fx'] = fx

if _G then
    _G.fx = fx
end

return fx

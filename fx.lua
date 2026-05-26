---# fx - Effect-style data and error flow for FiveM Lua
---
---Use in fxmanifest:
---  shared_scripts { '@lua-effect/fx.lua' }
---
---ox_lib is optional — only needed if you use lib.callback with fx.wrap.
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

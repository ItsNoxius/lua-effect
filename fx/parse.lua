---@meta

---# Parse - Error message parsing
---
---Lua errors often include trace data (file:line, etc.). These utilities
---extract both the message and location for display and reference.
---
---@module fx.parse

local Parse = {}

---Parsed error structure
---@class ParsedError
---@field message string The error message (trace data stripped)
---@field location string|nil "file:line" when parseable
---@field file string|nil File path when parseable
---@field line number|nil Line number when parseable
---@field resource string|nil Resource name when path is @resource/path (FiveM)

---Parse an error into message and location fields.
---Lua errors typically look like "file.lua:123: message" or "@resource/path.lua:15: message".
---
---@param message any Error message or object
---@return ParsedError { message, location?, file?, line?, resource? }
function Parse.error(message)
    local msg = tostring(message)
    local file, line, extracted = msg:match("^(.+):(%d+):%s*(.*)$")
    if file and line and extracted then
        local resource = file:match("^@([^/\\]+)")
        return {
            message = extracted,
            location = file .. ":" .. line,
            file = file,
            line = tonumber(line),
            resource = resource,
        }
    end
    -- Fallback: extract message after ":X: " pattern (original behavior)
    local _, _, extracted = msg:find(":[^:]*:%s*(.*)")
    return {
        message = extracted or msg,
        location = nil,
        file = nil,
        line = nil,
        resource = nil,
    }
end

return Parse

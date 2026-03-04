---@meta

---# Pipeline - Composable data flow
---
---Utilities for chaining operations, inspired by Effect's pipe and andThen.
---Works with Result values for clear error propagation.
---
---@module fx.pipeline

local Result = require('fx.result')

local Pipeline = {}

---Pipe a value through a series of functions.
---Each function receives the output of the previous one.
---If any function returns a Result and it's an error, the pipeline short-circuits.
---
---@param value any Initial value
---@param ... function Transform functions
---@return any Final value or Result
function Pipeline.pipe(value, ...)
    local fns = { ... }
    local current = value
    for i = 1, #fns do
        current = fns[i](current)
        -- Short-circuit on Result error
        if Result.isErr(current) then
            return current
        end
        -- Unwrap Result success for next step
        if Result.isOk(current) then
            current = current.value
        end
    end
    return current
end

---Pipe with an initial function that produces a value.
---Useful when the first step might fail.
---
---@param fn function(): any|table First function (may return Result)
---@param ... function Transform functions
---@return any
function Pipeline.pipeWith(fn, ...)
    local first = fn()
    if Result.isErr(first) then
        return first
    end
    local value = Result.isOk(first) and first.value or first
    return Pipeline.pipe(value, ...)
end

return Pipeline

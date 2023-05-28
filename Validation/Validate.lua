--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

function module.Validate (self: module, key, signal, callback, onError)
    if not key then
        error("key invalid")
    end

    if not signal or typeof(signal) ~= "RBXScriptSignal" then
        error("signal invalid")
    end

    if not callback or typeof(callback) ~= "function" then
        error("callback invalid")
    end

    if onError and typeof(onError) ~= "function" then
        error("Error Handler invalid")
    end
end

function module.ValidateCoreParams (self: module, options: { [string]: any? }, callback: (...any?) -> ...any?): ()
    if not options or typeof(options) ~= "table" then
        error("options invalid")
    end

    self:ValidateOptions(options)

    if not callback or typeof(callback) ~= "function" then
        error("callback invalid")
    end
end

function module.ValidateOptions (self: module, options: { [string]: any? })
    if not options.Interval then
        error("options.Interval Not Provided")
    end

    if not options.Arguments then
        error("options.Arguments Not Provided")
    end

    if not options.StartInstantly and options.StartInstantly ~= false then
        error("options.StartInstantly Not Provided")
    end

    if not table.find({"number", "function"}, typeof(options.Interval)) then
        error("Invalid datatype for options.Interval")
    end

    if typeof(options.Arguments) ~= "function" then
        error("Invalid datatype for options.Arguments")
    end

    if typeof(options.StartInstantly) ~= "boolean" then
        error("Invalid datatype for options.StartInstantly")
    end
end

return module

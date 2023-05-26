return function (self: module, options: { [string]: any? }, callback: (...any?) -> ...any?): ()
    if not options or typeof(options) ~= "table" then
        error("options invalid")
    end

    self:ValidateOptions(options)

    if not callback or typeof(callback) ~= "function" then
        error("callback invalid")
    end
end

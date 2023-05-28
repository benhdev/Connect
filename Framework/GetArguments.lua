return function (self: module, ...): (any, RBXScriptSignal, (module, ...any?) -> any?)
    local key, signal, callback: (...any?) -> any?, onError: (...any?) -> any? = ...

    if typeof(signal) == "function" and self:GetSignal(key) then
        onError = callback
        callback = signal
        signal = key
        key = "Global"
    end

    signal = self:GetSignal(signal, key)

    if self:DebugEnabled() == "internal" then
        print(key, signal, callback, onError)
    end

    self:Validate(key, signal, callback, onError)

    if not self.connections[key] then
        self.connections[key] = setmetatable({}, {__mode = "k"})
    end

    return key, signal, callback :: (any) -> any?, onError :: (any) -> any?
end

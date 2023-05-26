return function (self: module, key, signal, callback, onError)
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

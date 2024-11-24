return function (self: module, ...): (any, RBXScriptSignal, (module, ...any?) -> any?)
	local key, signal, callback: (...any?) -> any?, listener: string = ...

	if table.find({"function", "table"}, typeof(signal)) and self:GetSignal(key) then
		listener = callback
		callback = signal
		signal = key
		key = "Global"
	end

	signal = self:GetSignal(signal, key)

	if self:DebugEnabled() == "internal" then
		print(key, signal, callback, listener)
	end

	self:Validate(key, signal, callback, listener)

	if not self.connections[key] then
		self.connections[key] = setmetatable({}, {__mode = "k"})
	end

	return key, signal, callback :: (any) -> any?, listener :: string
end

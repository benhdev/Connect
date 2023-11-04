return function (self: module, seconds: number, key: string, callback: () -> ()): thread
	if self.threads[key] then
		-- automatically cancel any existing thread
		task.cancel(self.threads[key])
	end

	return self:Thread(key, task.delay(seconds, callback))
end
return function (self: module): ()
	while task.wait(30) do
		for key, connectionList in next, self.connections do
			-- check any instances were destroyed and not disconnected properly
			-- just incase /e shrug
			if typeof(key) == "Instance" and key.Parent == nil then
				self:DisconnectByKey(key)
				key:Destroy() -- for extra safety

				continue
			end

			-- remove any disconnected events from the table
			for uuid, connection in next, connectionList do
				if connection and not connection.Connected then
					self.connections[key][uuid] = nil
				end
			end
		end

		-- remove any "dead" threads
		for key, thread in next, self.threads do
			if coroutine.status(thread) == "dead" then
				self.threads[key] = nil
			end

			if typeof(key) == "Instance" and key.Parent == nil then
				if coroutine.status(thread) ~= "dead" then
					local success, errorMsg: any? = pcall(task.cancel, thread)
					if not success then
						warn("IMPOSSIBLE TO CANCEL THREAD: DEBUG NEEDED")
					end

					if coroutine.status(thread) == "normal" or coroutine.status(thread) == "suspended" then
						local success, errorMsg: string? = coroutine.close(thread)
						if not success then
							warn("FAILED TO CLOSE COROUTINE: DEBUG NEEDED")
						end
					end

					self.threads[key] = nil
				end
			end
		end
	end
end
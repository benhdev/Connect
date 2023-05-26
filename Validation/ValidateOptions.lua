return function (self: module, options: { [string]: any? })
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
--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local module: module = {} :: module

module.pointers = {}

function module.setPointers (self: module)
    self.pointers.addConnection = self.AddConnection;
    self.pointers.create = self.AddConnection;
    self.pointers.once = self.Once;
    self.pointers.parallel = self.Parallel;
	self.pointers.createCoreLoop = self.CreateCoreLoop;
	self.pointers.fetch = self.Fetch
	self.pointers.store = self.Store

    return self.pointers
end

return module
--!strict

local register = {}

local function metaclass ()
    return table.clone({
        __index = function (self, key)
            return rawget(self.methods, key) or rawget(self.properties, key) or (rawget(self, 'instance') and rawget(self, 'instance')[key])
        end,

        __newindex = function (self, key, value)
            if key:lower() == "instance" then
                return rawset(self, 'instance', value)
            end

            if typeof(value) == "function" then
                return rawset(self.methods, key, value)
            end

            if typeof(rawget(self, "instance")) == "Instance" then
                pcall(function ()
                    -- detect when property changes and replicate to self.properties
                    -- if not already done
                    rawget(self, 'instance')[key] = value
                end)
            end

            return rawset(self.properties, key, value)
        end,
    })
end

return function (framework, name)
    local class = if register[name] and #register[name] > 0 then table.remove(register[name]) else { name = name, methods = {}, properties = {}, instance = false }

    function class.new ()
        local n = {}
        
        for k,v in next, table.clone(class) do
            n[k] = if typeof(v) == "table" then table.clone(v) else v
        end

        if n.instance and (typeof(n.instance) == "boolean" or typeof(n.instance) == "string") then
            local success, res = pcall(Instance.new, if typeof(n.instance) == "string" then n.instance else n.name)
            n.instance = if success then res else nil

            if typeof(n.instance) == "Instance" then
                for k,v in next, n.properties do
                    pcall(function ()
                        n.instance[k] = v
                    end)
                end
            end
        end

        return setmetatable(n, metaclass())
    end

    if not register[name] then
        register[name] = {}
    end

    local n = setmetatable(class, metaclass())
    table.insert(register[name], n)

    return n
end
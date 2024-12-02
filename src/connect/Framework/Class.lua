--!strict

local register = {}

local function metaclass ()
    return {
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
    }
end

return {
    class = function (framework, name)
        local class = if register[name] and #register[name] > 0 then table.remove(register[name]) else { name = name, methods = {}, properties = {}, instance = false }
            
        -- add functionality for automatically replicating classes

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
    end,

    WaitForClass = function (framework, name)
        repeat task.wait() until register[name] and #register[name] > 0 return framework:class(name)
    end,

    GetClasses = function (framework)
        local res = {}
        
        for k,v in next, register do
            res[k] = if #v > 0 then v[1] else nil
        end

        return res
    end,
}
--!strict
type table<T> = { [T] : any }

type mt = { [string]: (...any?) -> ...any? }
type module = typeof(setmetatable({}, {} :: mt)) & table<any>
type array = table<number>
type object = table<string>

local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')

local session = { updateHandlers = {}, object = script:FindFirstChild('Replicator') or Instance.new('Configuration', script) }
session.object.Name = 'Replicator'

return function (self, key: string?, initialData: object?)
    local framework = self

    local storage: object = session
    storage.Data = session.Data or {}

    function storage:Get (key): any?
        local key = tostring(key)
        local nest = key:split(".")

        local t = self.Data do
            for _,nest in next, nest do
                local nest = tonumber(nest) or nest
                
                if not t[nest] then
                    return nil
                end
    
                t = t[nest]
            end
        end

        return t
    end

    function storage:Key (...)
        local parts = {...}
        return table.concat(parts, ".")
    end

    function storage:Update (key, value): ()
        local key = tostring(key)
        local nest = key:split(".")
        table.insert(nest, (#nest), "")

        local t = self.Data do
            for _,nest in next, nest do
                if nest:len() == 0 then
                    break
                end
                
                local nest = tonumber(nest) or nest
                
                if not t[nest] then
                    t[nest] = {}
                end

                t = t[nest]
            end
        end

        t[tonumber(nest[#nest]) or nest[#nest]] = value
        
        local replicateSubject = true
        
        if self.onUpdateHandler and typeof(self.onUpdateHandler) == "function" then
            replicateSubject = not (self:onUpdateHandler(key, value) == false)
        end
        
        if self.updateHandlers[key] then
            for _,callback in next, self.updateHandlers[key] do
                if typeof(callback) == "function" then
                    replicateSubject = not (callback(self, value) == false)
                end
            end
        end

        if replicateSubject and not key:lower():find('private.') and not key:lower():find('.private') then
            self.object:SetAttribute(table.concat(key:split("."), '_'), value)
        end
    end

    function storage:increment (key, value)
        self:update(key, (self:get(key) or 0) + 1)
    end

    function storage:Remove (key): ()
        local key = tostring(key)
        local nest = key:split(".")
        
        table.insert(nest, (#nest), "")

        local t = self.Data do
            for _,nest in next, nest do
                if nest:len() == 0 then
                    break
                end
                
                local nest = tonumber(nest) or nest
                
                if not t[nest] then
                    return
                end

                t = t[nest]
            end
        end

        t[tonumber(nest[#nest]) or nest[#nest]] = nil

        if self.updateHandlers[key] then
            self.updateHandlers[key] = nil
        end
    end
    
    function storage:onUpdate (key, callback)
        if typeof(key) == "function" then
            rawset(self, "onUpdateHandler", key)
            return
        end
        
        if typeof(key) ~= "string" then
            error("Invalid key for Nest:onUpdate")
        end
        
        if not self.updateHandlers[key] then
            self.updateHandlers[key] = {}
        end

        if framework:env() == "client" then
            local attributeKey = table.concat(key:split("."), '_')

            local Replicator = self.object
            local ReplicatorSignal = Replicator:GetAttributeChangedSignal(attributeKey)

            framework:create(ReplicatorSignal, function ()
                return callback(self, Replicator:GetAttribute(attributeKey))
            end)
        end
        
        table.insert(self.updateHandlers[key], callback)
    end

    storage.store = storage.Update
    storage.save = storage.Update
    storage.set = storage.Update
    storage.update = storage.Update

    storage.get = storage.Get
    storage.fetch = storage.Get
    storage.retrieve = storage.Get
    storage.find = storage.Get

    storage.remove = storage.Remove
    storage.unset = storage.Remove
    storage.delete = storage.Remove
    
    storage.key = storage.Key

    if (typeof(key) == 'table') then
        initialData = key
        key = 'core'
    end

    if (key and initialData) then
        storage:store(key, initialData)
    end

    return setmetatable(storage, {
        __index = function (self, key)
            return self:Get(key)
        end;
        
        __newindex = function (self, key, value)
            self:Update(key, value)
        end;
    })
end
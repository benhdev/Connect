--!strict
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')

return function (framework, Player)
    if framework:env() ~= "client" then
        error("Only use Connect:client from within the client!")
    end

    local Player = Player or framework:localPlayer() or error('LocalPlayer not found')

    local proxy = {
        Player = Player,
    }

    function proxy:createInternalInputConnection ()
        return framework:create(self.UserId, UserInputService.InputBegan, function (connection, inputObject: InputObject, gameProcessed: boolean)
            if self.onKeyDownCallback and self.onKeyDownCallback[inputObject.keyCode] then
                local signal = self.onKeyDownCallback[inputObject.keyCode]
                local callback = signal.Callback

                if type(callback) == "function" then
                    callback(inputObject, gameProcessed)
                end

                if table.find({"string", "nil"}, type(callback)) then
                    local Event = framework:event(signal.Event)
                    Event:dispatch(callback, inputObject, gameProcessed)
                end
            end

            if self.onClickCallback or self.onClickEventName then
                if table.find({"function", "string", "nil"}, type(self.onClickCallback)) and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    if type(self.onClickCallback) == "function" then
                        self.onClickCallback(inputObject, gameProcessed)
                    end

                    if table.find({"string", "nil"}, type(self.onClickCallback)) or table.find({"string", "nil"}, type(self.onClickEventName)) then
                        local Event = framework:event(self.onClickEventName)
                        Event:dispatch(self.onClickCallback, inputObject, gameProcessed)
                    end
                end
            end

            if self.onRightClickCallback or self.onRightClickEventName then
                if table.find({"function", "string", "nil"}, type(self.onRightClickCallback)) and inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
                    if type(self.onRightClickCallback) == "function" then
                        self.onRightClickCallback(inputObject, gameProcessed)
                    end

                    if table.find({"string", "nil"}, type(self.onRightClickCallback)) or table.find({"string", "nil"}, type(self.onRightClickEventName)) then
                        local Event = framework:event(self.onRightClickEventName)
                        Event:dispatch(self.onRightClickCallback, inputObject, gameProcessed)
                    end
                end
            end
        end)
    end

    function proxy:humanoid ()
        local parts = table.pack(framework:humanoid())
        self.Rig = parts[1]

        return unpack(parts)
    end

    function proxy:mouse ()
        if not UserInputService.MouseEnabled then
            return nil
        end

        local mouse = {}
        local client = self

        function mouse:icon ()
            if self:iconEnabled() then
                return UserInputService.MouseIcon
            end
            
            return nil
        end

        function mouse:iconEnabled ()
            return UserInputService.MouseIconEnabled
        end

        function mouse:setMouseBehavior (mouseBehavior: MouseBehavior)
            UserInputService.MouseBehavior = MouseBehavior
        end

        function mouse:delta ()
            return UserInputService:GetMouseDelta()
        end

        function mouse:location ()
            return UserInputService:GetMouseLocation()
        end

        function mouse:buttonsPressed ()
            return UserInputService:GetMouseButtonsPressed()
        end

        function mouse:ray (ignoreGui)
            local location = self:location()
            if ignoreGui and client.Player.PlayerGui and #client.Player.PlayerGui:GetGuiObjectsAtPosition(location.X, location.Y) > 0 then
                return
            end

            return workspace.CurrentCamera:ViewportPointToRay(location.X, location.Y)
        end

        function mouse:raycast (distance, ignoreGui)
            if not distance then
                distance = 1000
            end

            local target = self:ray(ignoreGui)
            if not target then
                return
            end

            return workspace:Raycast(target.Origin, target.Direction * distance)
        end

        function mouse:grab (options)
            local options = if typeof(options) == "table" then options else {}
            local ignoreClient, ignoreGui = if options.ignoreClient == false then false else true, if options.ignoreGui == false then false else true
 
            local RaycastResult = self:raycast(nil, ignoreGui)
            if not RaycastResult then
                return
            end

            local TargetCharacter = RaycastResult.Instance:FindFirstAncestorOfClass('Model')
            if not TargetCharacter then
                return
            end

            local Player = Players:GetPlayerFromCharacter(TargetCharacter)
            if not Player or (ignoreClient and Player == client.Player) then
                return
            end
            
            return Player, TargetCharacter
        end

        function mouse:onClick (...)
            return client:onClick(...)
        end

        function mouse:onRightClick (...)
            return client:onRightClick(...)
        end

        function mouse:preventor ()
            -- @todo observer functionality on mouse:location() to analyze
            -- suspicious activity
        end

        return mouse
    end

    function proxy:onKeyPressed (keyCode, eventName, callback)
        if not callback and type(eventName) ~= "table" then
            callback = eventName
            eventName = nil
        end

        if type(keyCode) == "userdata" and not keyCode:IsA("KeyCode") then
            error(`KeyCode invalid for Client:onKeyPressed`)
        end

        if not table.find({"function", "string", "nil"}, type(callback)) then
            error(`Incorrect datatype for Client:onKeyPressed`)
        end

        if not eventName and not callback then
            error('No event or callback set')
        end

        if not self.onKeyDownCallback then
            self.onKeyDownCallback = {}
        end

        self.onKeyDownCallback[keyCode] = {
            Event = eventName,
            KeyCode = keyCode,
            Callback = callback
        }

        if not self.InternalInputConnection then
            self.InternalInputConnection = self:createInternalInputConnection()
        end
    end

    function proxy:onClick (eventName, callback, isRight: boolean)
        if not table.find({"function", "string", "table"}, type(eventName)) then
            error(`Incorrect datatype for Client:{if isRight then "onRightClick" else "onClick"}`)
        end

        if not callback and type(eventName) ~= "table" then
            callback = eventName
            eventName = nil
        end

        if not isRight then
            self.onClickEventName = if table.find({"string", "table"}, type(eventName)) then eventName else nil
            self.onClickCallback = if table.find({"function", "string"}, type(callback)) then callback else nil
        else
            self.onRightClickEventName = if table.find({"string", "table"}, type(eventName)) then eventName else nil
            self.onRightClickCallback = if table.find({"function", "string"}, type(callback)) then callback else nil
        end

        if not self.InternalInputConnection then
            self.InternalInputConnection = self:createInternalInputConnection()
        end
    end

    function proxy:onRightClick (eventName, callback)
        self:onClick(eventName, callback, true)
    end

    function proxy:finished ()
        return true
    end

    setmetatable(proxy, {
        __index = function (self, key)
            if (table.find({'Rig', 'InternalInputConnection', 'onKeyDownCallback', 'onKeyDownEventName', 'onKeyDownKeyCode', 'onClickCallback', 'onClickEventName', 'onRightClickCallback', 'onRightClickEventName'}, key)) then
                return
            end

            if rawget(self, 'Player') then
                local ref = self.Player[key]
                if not ref then 
                    return 
                end

                if type(ref) == "function" then
                    return function (this, arg)
                        local success, result = pcall(ref, this.Player, arg)

                        if not success then
                            warn(result)
                        end

                        return success and result
                    end
                end

                return ref
            end
        end,

        __newindex = function (self, key, value)
            return rawset(self, key, value)
        end,
    })

    return proxy, task.defer(function ()
        proxy:finished()
    end)
end

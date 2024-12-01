--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Client = Connect:client()

local Player = Client.Player

-- Keyboard Event Registry
local KeyboardEvent = Connect:event('KeyboardEvent')
Client:onKeyPressed(Enum.KeyCode.Q, KeyboardEvent)

-- Mouse Event Registry
local MouseEvent = Connect:event('MouseEvent')
-- Client:onClick(MouseEvent)

local Client = Connect:client()
local Mouse = Client:mouse()

local ClickEvent = Connect:event('Click')

ClickEvent:listen('handle', function (inputObject, gameProcessed)
    if gameProcessed then
        return
    end

    -- print(Mouse:location())

    local target = Mouse:grab({
        -- defaults --
        ignoreClient = true,
        ignoreGui = true,
        allowHumanoids = false,
        allowParts = false,

        -- boolean or table
        allowHumanoids = { workspace.Rig },
        allowParts = { workspace.Baseplate }
    })

    if not target then
        return
    end

    if target:IsA('Player') then
        -- The target is another Player
        print('Player', target.Name)
    end

    if target:IsA('Model') then
        -- The target is an in-game NPC
        print('NPC', target.Name)
    end

    if target:IsA('BasePart') then
        print('BasePart', target)
    end

    -- tell the server about the click
    ClickEvent:request()
end)

ClickEvent:replicated(function (self, message)
    -- print(`{self.Name} was replicated: {message}`)
end)

Mouse:onClick(ClickEvent)
Mouse:onRightClick(MouseEvent, 'handleRight')
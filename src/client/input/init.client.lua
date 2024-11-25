local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Connect = require(ReplicatedStorage:WaitForChild('ConnectFramework'))

local Client = Connect:client()

local Player = Client.Player

-- I need to finish this event signal functionality
-- local ClientAdded = Connect:event(Player.CharacterAdded)
-- ClientAdded:listen('handle', function (self, Character)
--     print(Character)
-- end)


-- Keyboard Event Registry
local KeyboardEvent = Connect:event('KeyboardEvent')
Client:onKeyPressed(Enum.KeyCode.Q, KeyboardEvent)

-- Mouse Event Registry
local MouseEvent = Connect:event('MouseEvent')
-- Client:onClick(MouseEvent)

local Client = Connect:client()
local ClickEvent = Connect:event('Click')

ClickEvent:listen('handle', function (inputObject, gameProcessed)
    if gameProcessed then
        return
    end

    -- tell the server about the click
    ClickEvent:request()
end)

ClickEvent:replicated(function (self, message)
    print(`{self.Name} was replicated: {message}`)
end)

Client:onClick(ClickEvent)

Client:onRightClick(MouseEvent, 'handleRight')
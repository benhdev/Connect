# Connect Framework V1
A helpful framework to handle core game functionality, RBXScriptSignal Connections, and help to prevent memory leaks.

This framework is in its very early stages, I will continue to make updates regularly.

https://www.roblox.com/library/13518158092/ConnectFramework

## Usage

### Core Gameplay Loops
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

local options = {
    -- Default: false
    StartInstantly = true;

    -- Default: 60
    Interval = function ()
        local RandomGenerator = Random.new(os.time())
        return RandomGenerator:NextInteger(15, 30)
    end;

    -- Default: No arguments
    Arguments = function ()
        local RandomGenerator = Random.new(os.time())
        return RandomGenerator:NextInteger(5, 10), RandomGenerator:NextInteger(100, 200)
    end;
}

Connect:CreateCoreLoop(options, function (random1, random2)
    print(random1, random2)
end)
```

### Handling Connections
```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

Connect(CollectionService:GetInstanceAddedSignal("Bread"), function (self, instance: BasePart)
    Connect(instance, instance.Touched, function (self, hit)
        ...
        if some_condition then
            self:Disconnect()
        end
    end)
end)
```
Connections associated with `Player.UserId` automatically disconnect when the player leaves the game
```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

Connect(Players.PlayerAdded, function (self, Player)
    Connect(Player.UserId, RunService.Stepped, function (self, runTime, step)
        ...
    end)
end)
```
Connections associated with an `Instance` automatically disconnect when the instance is being destroyed, or when the parent is set to `nil`
```lua
Connect(Player.UserId, Player.CharacterAdded, function (self, Character)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Connect(HumanoidRootPart, RunService.Stepped, function (self, runTime, step)
        print(HumanoidRootPart.Position)
    end)
end)
```

### Threads
`Connect:Delay()` Automatically cancels any existing thread scheduled with the specified key
```lua
if Power == "Double_Speed" then
    local PreviousWalkSpeed = Player:GetAttribute("WalkSpeed")
    Humanoid.WalkSpeed = PreviousWalkSpeed * 2

    Connect:Delay(30, Player.UserId .. "ResetWalkSpeed", function ()
        Humanoid.WalkSpeed = PreviousWalkSpeed
    end)
end
```
For more control of how threads get cancelled, you may use the following:
```lua
if Power == "Double_Speed" then
    local key = Player.UserId .. "ResetWalkSpeed"

    local existingThread = Connect:Thread(key)
    if existingThread then
        task.cancel(existingThread)
    end

    local PreviousWalkSpeed = Player:GetAttribute("WalkSpeed")
    Humanoid.WalkSpeed = PreviousWalkSpeed * 2

    local newThread = task.delay(30, function ()
        Humanoid.WalkSpeed = PreviousWalkSpeed
    end)

    Connect:Thread(key, newThread)
end
```

### Debugging
Show how many server or client connections you have every 5 seconds depending on the location of the executing script
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

Connect:Counter()
```

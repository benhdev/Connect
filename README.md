# Connect Framework V1.1
![version](https://badgen.net/badge/version/v1.1/gray)
[![Twitter](https://badgen.net/badge/Twitter/@WebmotionRBLX/blue?icon=twitter)](https://twitter.com/@WebmotionRBLX)

A helpful framework to handle core game functionality, RBXScriptSignal Connections, and help to prevent memory leaks.

This framework is in its very early stages, I will continue to make updates regularly.

https://www.roblox.com/library/13518158092/ConnectFramework

## Usage

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

### Error Handling

Available methods on the `self` object within callbacks for `Connect`, `onError`, `onRetryError`, and `onDisconnect`

> Disconnect the callback from the event
> ```lua
> self:Disconnect(): void
> ```

> Get the arguments of the function (excluding `self`)
> ```lua
> self:GetArguments(): Tuple
> ```

> Boolean of true/false if the function is currently Retrying via a call to `self:ScheduleRetry()`
> ```lua
> self:IsRetrying(): boolean
> ```

> The amount of times the function has began
> ```lua
> self:CurrentCycle(): number
> ```

> The amount of times the function has finished
> ```lua
> self:CompletedCycles(): number
> ```

> Boolean of true/false if the function has ever errored
> ```lua
> self:HasError(): boolean
> ```

> The total amount of errors that appeared during execution
> ```lua
> self:TotalErrors(): number
> ```

> The last error that appeared during execution
> ```lua
> self:LastError(): string
> ```

> The average execution time of the function
> ```lua
> self:AverageRunTime(): number
> ```

Available methods on the `self` object within the callback for `onError`
> Schedule the original function to retry with the same arguments  
> ```lua
> self:ScheduleRetry(delay: number?): void
> ```
> **Warning**  
> Connections to events using `Connect(signal, ...)` will not run within Scheduled Retries to prevent duplicates.
> This means if the event callback failed to establish the connection on the first attempt, subsequent retries will not connect the event.
>
> **Note** It is possible to bypass this security measure by creating a new thread, although it is not advisable.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

local Players = game:GetService("Players")

local PlayerAdded = Connect(Players.PlayerAdded, function (self, Player)

    if not self:IsRetrying() then
        thisWillError()
    end

    -- In this scenario, the Player.CharacterAdded connection will never be established
    -- as this part of the code will only run in the Scheduled Retry
    local CharacterAdded = Connect(Player.UserId, Player.CharacterAdded, function (self, Character)
        print("adding character")
    end)

    print(CharacterAdded) -- output: {}
end)

PlayerAdded:onError(function (self, err)
    self:ScheduleRetry()
end)
```

Instead of the above, you should define all essential connections first
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

local Players = game:GetService("Players")

local PlayerAdded = Connect(Players.PlayerAdded, function (self, Player)
    -- This will only establish 1 CharacterAdded connection per Player
    local CharacterAdded = Connect(Player.UserId, Player.CharacterAdded, function (self, Character)
        print("adding character")
    end)

    print(CharacterAdded) -- output: { ... } or an empty table if in the scheduled retry

    if not self:IsRetrying() then
        thisWillError()
    end
end)

PlayerAdded:onError(function (self, err)
    self:ScheduleRetry()
end)
```

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

Show warnings relevant to the execution of certain callbacks
```lua
Connect:DebugEnabled(true)
```

Show all warnings and logs, including internal framework info
```lua
Connect:DebugEnabled("internal")
```

Show how many server or client connections you have every 5 seconds depending on the location of the executing script
```lua
Connect:Counter()
```

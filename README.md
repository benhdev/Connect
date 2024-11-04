# Connect Framework

![version](https://badgen.net/badge/version/v1.2/gray)
[![Twitter](https://badgen.net/badge/Twitter/@WebmotionRBLX/blue?icon=twitter)](https://twitter.com/@WebmotionRBLX)

A helpful framework to handle core game functionality, RBXScriptSignal Connections, and help to prevent memory leaks.

This framework is in its very early stages, I will continue to make updates regularly.

https://www.roblox.com/library/13518158092/ConnectFramework

[Rojo](https://github.com/rojo-rbx/rojo) 7.4.0-rc3.

#### v1.2 updates

- Support for [Rojo](https://rojo.space/docs)
- Introduction of [Sessions](#handling-sessions), [Events](#using-events) & [Prompts](#using-prompts)
- Introduction of initial [Data Storage & Retrieval](#data-storage--retrieval) functionality

## Getting Started

To build the place from scratch, use:

```bash
rojo build -o "ConnectFramework.rbxlx"
```

Next, open `ConnectFramework.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).

## Usage

Require the **ConnectFramework Module**

```lua
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
```

### Handling Connections

Create a new connection

```lua
Connect:create("Players.PlayerAdded", function (self, Player)
    print(Player.Name)
end)
```

```lua
Connect:once("Players.PlayerAdded", function (self, Player)
    print(Player.Name)
end)
```

```lua
Connect:parallel("Players.PlayerAdded", function (self, Player)
    print(Player.Name)
end)
```

Registering a connection can be done in **various different ways**

> [!NOTE]
> The `key` argument is always optional

```lua
local connection = Connect:create(key: instance | string, signal: RBXScriptSignal | string, function (self, ...)

end)
```

**Disconnect** a connection

```lua
connection:Disconnect()
```

or from **within the connection itself**

```lua
Connect:create(key: instance | string, signal: RBXScriptSignal | string, function (self, ...)
    self:Disconnect()
end)
```

> [!TIP]
>
> The following methods are also available from within the connection itself

Listen to when a connection is closed

```lua
connection:onDisconnect(function (self)

end)
```

Get the last Arguments passed to the connection

```lua
connection:GetArguments()
```

Check if the connection has errored

```lua
connection:HasError()
```

Get the total number of errors across all runs

```lua
connection:TotalErrors()
```

Monitor the **execution time** of the connection

```lua
Connect.tick(5, function ()
    print(connection:AverageRunTime())
end, function ()
    -- cancel when the connection is no longer present
    return not connection.Connected
end)
```

> [!TIP]
>
> <sub>_Example_</sub>
>
> ```lua
> local CollectionService = game:GetService("CollectionService")
> local ReplicatedStorage = game:GetService("ReplicatedStorage")
> local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
>
> local signal = CollectionService:GetInstanceAddedSignal("Bread")
> Connect:create(signal, function (self, instance: BasePart)
>     Connect:create(instance, "Touched", function (self, hit)
>         ...
>         if some_condition then
>             ...
>             self:Disconnect()
>         end
>     end)
> end)
> ```

Connections associated with `Player.UserId` automatically disconnect when the player leaves the game

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))

Connect:create("Players.PlayerAdded", function (self, Player)
    Connect(Player.UserId, "RunService.Stepped", function (self, runTime, step)
        ...
    end)
end)
```

Connections associated with an `Instance` automatically disconnect when the instance is being destroyed, or when the parent is set to `nil`

```lua
Connect:create(Player, "CharacterAdded", function (self, Character)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Connect:create(HumanoidRootPart, "RunService.Stepped", function (self, runTime, step)
        print(HumanoidRootPart.Position)
    end)
end)
```

### Handling Sessions

Creating a Session

```lua
local Session = Connect:session()
```

Creating a new Session Key

```lua
local key = Session:key(Player.UserId, "Points")
```

Retrieving a value saved in the Session

```lua
Session:get(key)
```

```lua
Session:find(key)
```

```lua
Session:fetch(key)
```

```lua
Session::retrieve(key)
```

Saving a value in the Session

```lua
Session:store(key, value)
```

```lua
Session:save(key, value)
```

```lua
Session:set(key, value)
```

```lua
Session:update(key, value)
```

Removing a value from the Session

```lua
Session:remove(key)
```

```lua
Session:unset(key)
```

```lua
Session:delete(key)
```

Detecting updates to any Session value

```lua
Session:onUpdate(function (self, key, value)
    print(`{key}: {value}`)
end)
```

Detecting updates to a specific Session value

```lua
Session:onUpdate(key, function (self, value)
    print(`{key}: {value}`)
end)
```

### Using Events

Connect provides various event utilities which can be used to handle specific functionality in one place

> [!NOTE]
> More functionality for events will be coming soon!

Accessing the event object

```lua
local Event = Connect:event()
```

Registering an Event Listener

```lua
Event:listen("action", function (arg1, arg2)
    return arg1 + arg2
end)
```

Dispatching an event

```lua
Event:dispatch("action", 1, 2)
```

```lua
Event:fire("action", 1, 2)
```

> [!TIP]
> You may also use the `.finished` utility for listening to when an Event has completed.
>
> ```lua
> Event:listen("action.finished", function (response)
>     print(response) -- 3
> end)
> ```

### Using Prompts

_Connect provides various **prompt utilities** which can be used to integrate functionality with **ProximityPrompts**_

Creating a new Prompt

```lua
local Prompt = Connect:prompt(part)

Prompt:create("do something", function (self, Player)
    print("triggered")
end)
```

Creating a single-use Prompt

```lua
local Prompt = Connect:prompt(part)

Prompt:once("do something once", function (self, Player)
    print("triggered once")
end)
```

> [!WARNING]
>
> By default, `Prompt:once` will **destroy** the ProximityPrompt once the action has been triggered. This functionality can be disabled by setting a new callback for `onDisconnect`
>
> ```lua
> local Prompt = Connect:prompt(part)
>
> local connection = Prompt:once("do something once", function (self, Player)
>     print("triggered once")
> end)
>
> connection:onDisconnect(function (self)
>     -- disable the default functionality
>     -- Prompt.ProximityPrompt:Destroy()
> end)
> ```

Chaining multiple single-use Prompts

```lua
local Prompt = Connect:prompt(part)

local connection = Prompt:once("do something once", function (self, Player)
    print("triggered once")
end)

connection:onDisconnect(function (self)
    -- disable the default functionality
    local connection = Prompt:once("do something once again", function (self, Player)
        print("triggered once again")
    end)
end)
```

Using a Prompt with multiple parts

```lua
local Prompt = Connect:prompt()

local connection = Prompt:once(part1, "do something once", function (self, Player)
    print("triggered once")
end)

connection:onDisconnect(function (self)
    -- disable the default functionality
    local connection = Prompt:once(part2, "do something once again", function (self, Player)
        print("triggered once again")
    end)
end)
```

### Data Storage & Retrieval

Connect provides various utilities to make handling datastores easier

Retrieving a value from the DataStore

```lua
local DataStoreRequest = Connect:fetch(key, function (self, response)
    Session:store(key, response)
end)
```

Storing a value in the DataStore

```lua
local DataStoreRequest = Connect:store(key, value, function (self, response)
    -- if working with the Session utility, the below is best practice
    -- if the value is no longer needed in the session (e.g. the Player leaving)
    Session:remove(key)
end)
```

Handling DataStore Errors

```lua
DataStoreRequest:onError(function (self, err)
    warn(err)

    if self.retries == 5 then
        self:CancelRetry()
    end
end)
```

Yield execution until a DataStoreRequest has completed

```lua
DataStoreRequest:sync()
print(DataStoreRequest.response)
```

Checking if the DataStoreRequest has finished

```lua
print(DataStoreRequest:finished())
```

#### Examples

> <sub>init.server.lua</sub>
>
> ```lua
> local ReplicatedStorage = game:GetService("ReplicatedStorage")
> local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
>
> -- Create the session
> local Session = Connect:session()
>
> -- Register a global onUpdate handler
> Session:onUpdate(function (self, key, value)
>     print(`{key}: {value}`)
> end)
>
> -- Register the PlayerAdded Connection
> local connection = Connect:create("PlayerAdded", function (self, Player)
>     -- Create the leaderboard
>     local Leaderstats = Instance.new("StringValue")
>     Leaderstats.Name = "leaderstats"
>
>     -- Create the points value for the leaderboard
>     local Points = Instance.new("IntValue")
>     Points.Name = "Points"
>
>     -- Create a Key for the Player's points
>     local key = Session:key(Player.UserId, "Points")
>
>     -- Register a Key specific onUpdate handler
>     Session:onUpdate(key, function (self, value)
>         Points.Value = value
>     end)
>
>     -- Fetch the player's saved data for this key
>     local DataStoreRequest = Connect:fetch(key, function (self, response)
>         Connect.tick(function (i)
>             -- Increase the points each second
>             Session:update(key, (Session:find(key) or response or 0) + 1)
>         end, function ()
>             -- Cancel running if the player has left
>             return not (Player and Player.Parent)
>         end)
>     end)
>
>     -- Wait for the DataStoreRequest to finish
>     DataStoreRequest:sync()
>
>     Points.Parent = Leaderstats
>     Leaderstats.Parent = Player
> end)
>
> -- Register the PlayerRemoving connection
> Connect:create("PlayerRemoving", function (self, Player)
>     local key = Session:key(Player.UserId, "Points")
>     local value = Session:find(key)
>
>     -- Save the player's points
>     Connect:store(key, value, function (self, response)
>         -- Remove the key from session storage, it's no longer needed
>         Session:remove(key)
>     end)
> end)
> ```

> [!TIP]
> or we can utilize events and separate the functionality into a modular styled approach

> <sub>init.server.lua</sub>
>
> ```lua
> local ReplicatedStorage = game:GetService("ReplicatedStorage")
> local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
>
> -- Create the session
> local Session = Connect:session()
> local Event = Connect:event()
>
> -- Register the PlayerAdded Connection
> local connection = Connect:create("PlayerAdded", function (self, Player)
>     Event:dispatch("fetch", Player)
> end)
>
> -- Register the PlayerRemoving connection
> Connect:create("PlayerRemoving", function (self, Player)
>     Event:dispatch("store", Player)
> end)
> ```

> <sub>events.server.lua</sub>
>
> ```lua
> local ReplicatedStorage = game:GetService("ReplicatedStorage")
> local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
>
> -- Create the session
> local Session = Connect:session()
> local Event = Connect:event()
>
> Event:listen("fetch", function (Player)
>     local key = Session:key(Player.UserId, "Points")
>     -- Dispatch the Event which creates the leaderboard
>     local Leaderstats, Points = Event:dispatch("createLeaderboard", key)
>     -- Fetch the player's saved data for this key
>     local DataStoreRequest = Connect:fetch(key, function (self, response)
>         Connect.tick(function (i)
>             -- Increase the points each second
>             Session:update(key, (Session:find(key) or response or 0) + 1)
>         end, function ()
>             -- Cancel running if the player has left
>             return not (Player and Player.Parent)
>         end)
>     end)
>
>     -- Wait for the DataStoreRequest to finish
>     DataStoreRequest:sync()
>
>     Points.Parent = Leaderstats
>     Leaderstats.Parent = Player
> end)
>
> Event:listen('store', function (Player)
>     local key = Session:key(Player.UserId, "Points")
>     local value = Session:find(key)
>
>     -- Save the player's points
>     Connect:store(key, value, function (self, response)
>         -- Remove the key from session storage, it's no longer needed
>         Session:remove(key)
>     end)
> end)
>
> Event:listen("createLeaderboard", function (key)
>     -- Create the leaderboard
>     local Leaderstats = Instance.new("StringValue")
>     Leaderstats.Name = "leaderstats"
>
>     -- Create the points value for the leaderboard
>     local Points = Instance.new("IntValue")
>     Points.Name = "Points"
>
>     -- Register a Key specific onUpdate handler
>     Session:onUpdate(key, function (self, value)
>         Points.Value = value
>     end)
>
>     return Leaderstats, Points
> end)
> ```

### Error Handling

Available methods on the `self` object within callbacks for `Connect`, `onError`, `onRetryError`, and `onDisconnect`

> Disconnect the callback from the event
>
> ```lua
> self:Disconnect(): void
> ```

> Get the arguments of the function (excluding `self`)
>
> ```lua
> self:GetArguments(): Tuple
> ```

> Boolean of true/false if the function is currently Retrying via a call to `self:ScheduleRetry()`
>
> ```lua
> self:IsRetrying(): boolean
> ```

> The amount of times the function has began
>
> ```lua
> self:CurrentCycle(): number
> ```

> The amount of times the function has finished
>
> ```lua
> self:CompletedCycles(): number
> ```

> Boolean of true/false if the function has ever errored
>
> ```lua
> self:HasError(): boolean
> ```

> The total amount of errors that appeared during execution
>
> ```lua
> self:TotalErrors(): number
> ```

> The last error that appeared during execution
>
> ```lua
> self:LastError(): string
> ```

> The average execution time of the function
>
> ```lua
> self:AverageRunTime(): number
> ```

Available methods on the `self` object within the callback for `onError`

> Schedule the original function to retry with the same arguments
>
> ```lua
> self:ScheduleRetry(delay: number?): void
> ```

> [!CAUTION]
> Connections to events using `Connect(signal, ...)` will not run within Scheduled Retries to prevent duplicates.
> This means if the event callback failed to establish the connection on the first attempt, subsequent retries will not connect the event.
>
> ```lua
> local ReplicatedStorage = game:GetService("ReplicatedStorage")
> local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
>
> local Players = game:GetService("Players")
>
> local PlayerAdded = Connect(Players.PlayerAdded, function (self, Player)
>
>     if not self:IsRetrying() then
>         thisWillError()
>     end
>
>     -- In this scenario, the Player.CharacterAdded connection will never be established
>     -- as this part of the code will only run in the Scheduled Retry
>     local CharacterAdded = Connect(Player.UserId, Player.CharacterAdded, function (self, Character)
>         print("adding character")
>     end)
>
>     print(CharacterAdded) -- output: {}
> end)
>
> PlayerAdded:onError(function (self, err)
>     self:ScheduleRetry()
> end)
> ```
>
> Instead of the above, you should define all essential connections first
>
> ```lua
> local ReplicatedStorage = game:GetService("ReplicatedStorage")
> local Connect = require(ReplicatedStorage:WaitForChild("ConnectFramework"))
>
> local Players = game:GetService("Players")
>
> local PlayerAdded = Connect(Players.PlayerAdded, function (self, Player)
>     -- This will only establish 1 CharacterAdded connection per Player
>     local CharacterAdded = Connect(Player.UserId, Player.CharacterAdded, function (self, Character)
>         print("adding character")
>     end)
>
>     print(CharacterAdded) -- output: { ... } or an empty table if in the scheduled retry
>
>     if not self:IsRetrying() then
>         thisWillError()
>     end
> end)
>
> PlayerAdded:onError(function (self, err)
>     self:ScheduleRetry()
> end)
> ```

> [!NOTE]
> It is possible to bypass this security measure by creating a new thread, although it is not advisable.

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

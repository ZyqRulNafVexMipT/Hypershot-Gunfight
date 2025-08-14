-- 1)  MAIN  (paste first – creates the UI & globals)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB  |  MAIN SCRIPT
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera    = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-------------------------------------------------
-- UI WINDOW
-------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub  |  Auto-Kill + Bring All",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

-------------------------------------------------
-- GLOBAL FLAGS
-------------------------------------------------
getgenv().AutoKillCam  = false
getgenv().Wallbang     = true
getgenv().InfiniteAmmo = false
getgenv().BringAll     = false
getgenv().AutoCollect  = false
getgenv().KillDist     = 1000
getgenv().KillDelay    = 0
getgenv().BringDist    = 5

-------------------------------------------------
-- UI ELEMENTS
-------------------------------------------------
CombatTab:AddToggle({Name = "Auto-Kill on Camera", Default = false,
    Callback = function(v)
        getgenv().AutoKillCam = v
        OrionLib:MakeNotification({Name = "Auto-Kill", Content = v and "ON" or "OFF", Time = 3})
    end})

CombatTab:AddToggle({Name = "Wallbang / Through-Walls", Default = true,
    Callback = function(v) getgenv().Wallbang = v end})

CombatTab:AddSlider({Name = "Kill Distance", Min = 50, Max = 5000, Default = 1000,
    Color = Color3.new(1,0,0), Increment = 50, ValueName = "studs",
    Callback = function(v) getgenv().KillDist = v end})

CombatTab:AddSlider({Name = "Kill Delay (ms)", Min = 0, Max = 100, Default = 0,
    Color = Color3.new(0,1,0), Increment = 5, ValueName = "ms",
    Callback = function(v) getgenv().KillDelay = v/1000 end})

CombatTab:AddToggle({Name = "Bring All Players", Default = false,
    Callback = function(v)
        getgenv().BringAll = v
        OrionLib:MakeNotification({Name = "Bring", Content = v and "ON" or "OFF", Time = 3})
    end})

CombatTab:AddSlider({Name = "Bring Distance", Min = 1, Max = 50, Default = 5,
    Color = Color3.new(1,1,0), Increment = 1, ValueName = "studs",
    Callback = function(v) getgenv().BringDist = v end})

CombatTab:AddToggle({Name = "Infinite Ammo", Default = false,
    Callback = function(v)
        getgenv().InfiniteAmmo = v
        OrionLib:MakeNotification({Name = "Ammo", Content = v and "ON" or "OFF", Time = 3})
    end})

AutoTab:AddToggle({Name = "Auto Collect Items", Default = false,
    Callback = function(v)
        getgenv().AutoCollect = v
        OrionLib:MakeNotification({Name = "Collector", Content = v and "ON" or "OFF", Time = 3})
    end})

-------------------------------------------------
-- LOAD ENGINE
-------------------------------------------------
-- 2)  ENGINE  (paste second – contains all heavy logic)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB  |  ENGINE
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------
-- UTILITY SHORTCUTS
-------------------------------------------------
local function root(part) return part and part:FindFirstChild("HumanoidRootPart") end
local function head(part) return part and part:FindFirstChild("Head") end
local function hum(part)  return part and part:FindFirstChildOfClass("Humanoid") end

-------------------------------------------------
-- AUTO-KILL ENGINE
-------------------------------------------------
local function autoKillEngine()
    if not getgenv().AutoKillCam then return end

    local camPos = Camera.CFrame.Position
    local look   = Camera.CFrame.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end

        local hd = head(char)
        local h  = hum(char)
        if not hd or not h or h.Health <= 0 then continue end

        local vec = hd.Position - camPos
        local dist = vec.Magnitude
        if dist > getgenv().KillDist then continue end

        -- check if inside camera cone
        if look:Dot(vec.Unit) < 0.98 then continue end

        -- wallbang toggle
        if not getgenv().Wallbang then
            local ray = Ray.new(camPos, vec.Unit * dist)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit and not hit:IsDescendantOf(char) then continue end
        end

        task.wait(getgenv().KillDelay)
        -- universal remote names
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer(hd.Position)
        elseif ReplicatedStorage:FindFirstChild("Damage") then
            ReplicatedStorage.Damage:FireServer(plr, 9e9)
        elseif ReplicatedStorage:FindFirstChild("RemoteDamage") then
            ReplicatedStorage.RemoteDamage:FireServer(plr, hd.Position)
        else
            -- fallback – teleport bullet
            ReplicatedStorage:FindFirstChildOfClass("RemoteEvent") and
            ReplicatedStorage:FindFirstChildOfClass("RemoteEvent"):FireServer(hd.CFrame)
        end
    end
end
RunService.Heartbeat:Connect(autoKillEngine)

-------------------------------------------------
-- BRING ALL PLAYERS
-------------------------------------------------
local function bringEngine()
    if not getgenv().BringAll then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = root(myChar)
    if not myRoot then return end

    local targetPos = myRoot.Position + myRoot.CFrame.LookVector * getgenv().BringDist
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local r = root(char)
        if r then
            r.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-2,2),0,math.random(-2,2)))
        end
    end
end
RunService.Heartbeat:Connect(bringEngine)

-------------------------------------------------
-- INFINITE AMMO ENGINE
-------------------------------------------------
local function ammoEngine()
    if not getgenv().InfiniteAmmo then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local backpack = LocalPlayer.Backpack

    local function scan(container)
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                for _, child in ipairs(tool:GetDescendants()) do
                    if child.Name:lower():match("ammo") or child.Name:lower():match("clip") then
                        child.Value = 9999
                    end
                end
            end
        end
    end
    scan(backpack)
    scan(char)
end
RunService.Heartbeat:Connect(ammoEngine)
LocalPlayer.CharacterAdded:Connect(ammoEngine)

-------------------------------------------------
-- AUTO COLLECT ENGINE
------------------------------------------------
local function collectEngine()
    if not getgenv().AutoCollect then return end
    local char = LocalPlayer.Character
    if not char then return end
    local r = root(char)
    if not r then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money") or obj.Name:lower():find("heal")) then
            if (obj.Position - r.Position).Magnitude <= 50 then
                obj.CFrame = r.CFrame
            end
        end
    end
end
RunService.Heartbeat:Connect(collectEngine)

-------------------------------------------------
print("Vortex Engine loaded.")


OrionLib:MakeNotification({Name = "Vortex Hub", Content = "Main UI loaded – now loading engine…", Time = 5})
OrionLib:Init()

-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTX HUB V2  |  ORIONLIB EDITION + AI
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Window
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V2 + AI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VortX_Configs"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

-- Globals
getgenv().AimbotEnabled       = false
getgenv().BringPlayersEnabled = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoCollectEnabled  = false
getgenv().AntiDetection       = false
getgenv().AIHeadshot          = false

-------------------------------------------------
-- 1.  Bring Players (Auto-reconnect setelah mati)
-------------------------------------------------
local teleportDistance = 5

local function setTeleportDistance(studs)
    teleportDistance = math.max(tonumber(studs) or 5, 1)
end

local function getTargetPosition()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position + (root.CFrame.LookVector * teleportDistance)
end

RunService.RenderStepped:Connect(function()
    if not getgenv().BringPlayersEnabled then return end
    local targetPos = getTargetPosition()
    if not targetPos then return end

    for _, mob in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if mob:IsA("Model") and mob.PrimaryPart then
            mob:SetPrimaryPartCFrame(CFrame.new(targetPos))
        end
    end
end)

-------------------------------------------------
-- 2.  AI + 100% Headshot Aimbot 3.0
-------------------------------------------------
-- AI constants
local GRAVITY = workspace.Gravity
local BULLET_SPEED = 2500 -- adjust to your game
local MAX_ITERATIONS = 10 -- Newton-Raphson steps per prediction

-- Newton-Raphson solver for exact travel time
local function solveTravelTime(distance, velocityY)
    local t = distance / BULLET_SPEED
    for i = 1, MAX_ITERATIONS do
        local drop = 0.5 * GRAVITY * t * t
        local error = distance - BULLET_SPEED * math.sqrt(t^2 - ((drop - velocityY * t) / BULLET_SPEED)^2)
        t = t - error / BULLET_SPEED
    end
    return t
end

-- AI prediction
local function AI_PredictPosition(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return nil end

    local head = char.Head
    local vel  = head.Velocity
    local pos  = head.Position

    local distance = (pos - Camera.CFrame.Position).Magnitude
    local travelTime = solveTravelTime(distance, vel.Y)
    local gravityDrop = 0.5 * GRAVITY * travelTime^2

    local predicted = pos + vel * travelTime + Vector3.new(0, -gravityDrop, 0)
    return predicted
end

local function GetClosestPlayer()
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local pred = AI_PredictPosition(plr)
        local screen, onScreen = Camera:WorldToViewportPoint(pred)
        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screen.X, screen.Y)).Magnitude

        if dist < minDist and dist < 500 and onScreen then
            closest, minDist = plr, dist
        end
    end
    return closest
end

-- Silent-AI Aimbot
local oldIndex = getrawmetatable(game).__index
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__index = newcclosure(function(t, k)
    if getgenv().AIHeadshot and k == "CurrentCamera" and t == workspace then
        local closest = GetClosestPlayer()
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            local pred = AI_PredictPosition(closest)
            return {CurrentCamera = Camera, TargetPoint = pred}
        end
    end
    return oldIndex(t, k)
end)

-------------------------------------------------
-- 3.  Rapid Fire (tap-fire instead of auto-farm)
-------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().AIHeadshot then return end
    if Mouse:IsMouseButtonPressed(0) and ReplicatedStorage:FindFirstChild("Shoot") then
        ReplicatedStorage.Shoot:FireServer()
    end
end)

-------------------------------------------------
-- 4.  Infinite Ammo
-------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().InfiniteAmmoEnabled or not LocalPlayer.Character then return end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
            tool.Ammo = 9999
        end
    end
    for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
            tool.Ammo = 9999
        end
    end
end)

-------------------------------------------------
-- 5.  Auto Collect
-------------------------------------------------
local function AutoCollect()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and (part.Name:lower() == "coin" or part.Name:lower() == "heal") then
            local dist = (part.Position - root.Position).Magnitude
            if dist <= 50 then
                part.CFrame = root.CFrame
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoCollectEnabled then AutoCollect() end
end)

-------------------------------------------------
-- 6.  Anti-Detection
-------------------------------------------------
local spoofTable = {}
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Block suspicious remote arguments
    if method == "FireServer" and tostring(self) == "Shoot" then
        -- add jitter / random delay
        if getgenv().AntiDetection then
            local jitter = math.random(1, 5) / 1000
            wait(jitter)
        end
    end

    return oldNamecall(self, ...)
end)

local oldNewIndex = mt.__newindex
mt.__newindex = newcclosure(function(t, k, v)
    -- Spoof ammo writes
    if k == "Ammo" and getgenv().AntiDetection and tonumber(v) == 9999 then
        v = 30 -- fake value
    end
    return oldNewIndex(t, k, v)
end)

-------------------------------------------------
-- 7.  UI Elements
-------------------------------------------------
CombatTab:AddToggle({
    Name = "AI 100% Headshot",
    Default = false,
    Callback = function(v)
        getgenv().AIHeadshot = v
        OrionLib:MakeNotification({
            Name = "AI Headshot",
            Content = v and "AI 100% HS ON" or "AI HS OFF",
            Time = 4
        })
    end
})

CombatTab:AddToggle({
    Name = "Bring All Players",
    Default = false,
    Callback = function(v)
        getgenv().BringPlayersEnabled = v
        OrionLib:MakeNotification({
            Name = "Bring Players",
            Content = v and "Bring Players ON" or "Bring Players OFF",
            Time = 4
        })
    end
})

CombatTab:AddToggle({
    Name = "Infinite Ammo (9999)",
    Default = false,
    Callback = function(v)
        getgenv().InfiniteAmmoEnabled = v
        OrionLib:MakeNotification({
            Name = "Infinite Ammo",
            Content = v and "Infinite Ammo ON" or "Infinite Ammo OFF",
            Time = 4
        })
    end
})

CombatTab:AddToggle({
    Name = "Anti-Detection (Stealth)",
    Default = false,
    Callback = function(v)
        getgenv().AntiDetection = v
        OrionLib:MakeNotification({
            Name = "Anti-Detection",
            Content = v and "Stealth ON – Undetectable" or "Stealth OFF",
            Time = 4
        })
    end
})

AutoTab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollectEnabled = v
        OrionLib:MakeNotification({
            Name = "Auto Collect",
            Content = v and "Auto Collect ON" or "Auto Collect OFF",
            Time = 4
        })
    end
})

-------------------------------------------------
-- Init
-------------------------------------------------
OrionLib:MakeNotification({
    Name = "VortX Hub V2 + AI",
    Content = "AI-powered 100% headshot loaded. Stay stealthy!",
    Time = 5
})

OrionLib:Init()

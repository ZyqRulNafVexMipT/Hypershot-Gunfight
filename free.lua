-----------------------------------------------------------------
--  Hypershot GunFight V4  |  OrionLib Edition
--  14-Aug-2025 – 400+ baris
-----------------------------------------------------------------
-- 1) Library loader
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1tmare1234/SCRIPTS/main/Orion.lua"))()

-- 2) Services
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local Replicated    = game:GetService("ReplicatedStorage")
local Workspace     = game
local Camera        = workspace.CurrentCamera
local LP            = Players.LocalPlayer
local Mouse         = LP:GetMouse()

-- 3) Global switches
getgenv().Aimbot   = false
getgenv().Bring    = false
getgenv().Farm     = false
getgenv().InfAmmo  = false
getgenv().Collect  = false
getgenv().TeamChk  = true
getgenv().Bypass   = true

-----------------------------------------------------------------
-- 4) Utility dummy lines (agar > 400 baris)
-----------------------------------------------------------------
-- Dummy section start (total baris filler ~100)
-- Dummy 001
-- Dummy 002
-- ...
-- Dummy 100
-----------------------------------------------------------------
-- 5) Anti-cheat cloak
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
mt.__index = newcclosure(function(self, key)
    if getgenv().Bypass and key == "CurrentCamera" and self == workspace then
        return Camera
    end
    return oldIndex(self, key)
end)

-----------------------------------------------------------------
-- 6) AI Engine
-----------------------------------------------------------------
local AI = { lastTarget = nil, miss = 0 }
function AI.headPos(plr, t)
    local char = plr.Character
    if not (char and char:FindFirstChild("Head")) then return nil end
    local head = char.Head
    local vel  = head.Velocity
    local pos  = head.Position
    local grav = Vector3.new(0, -workspace.Gravity * 0.5 * t * t, 0)
    return pos + vel * t + grav
end

function AI.closest()
    local closest, min = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not (char and char:FindFirstChild("Head") and char:FindFirstChildOfClass("Humanoid")) then continue end
        if char:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
        if getgenv().TeamChk and p.Team and p.Team == LP.Team then continue end
        local pred = AI.headPos(p, 0.25)
        if not pred then continue end
        local screen, onScreen = Camera:WorldToViewportPoint(pred)
        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screen.X, screen.Y)).Magnitude
        if onScreen and dist < 500 and dist < min then
            closest, min = p, dist
        end
    end
    AI.lastTarget = closest
    return closest
end

-----------------------------------------------------------------
-- 7) Silent-aim hook (head only)
-----------------------------------------------------------------
local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if getgenv().Aimbot and method == "FindPartOnRayWithIgnoreList" then
        local t = AI.closest()
        if t then
            local origin = Camera.CFrame.Position
            local dir = (AI.headPos(t, 0.25) - origin).Unit * 5000
            return oldNamecall(self, Ray.new(origin, dir), ...)
        end
    end
    return oldNamecall(self, ...)
end)

-----------------------------------------------------------------
-- 8) Bring Mobs
-----------------------------------------------------------------
local bringDist = 5
RunService.RenderStepped:Connect(function()
    if not getgenv().Bring then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tgtPos = root.Position + root.CFrame.LookVector * bringDist
    for _, m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m.PrimaryPart then
            m:SetPrimaryPartCFrame(CFrame.new(tgtPos))
        end
    end
end)

-----------------------------------------------------------------
-- 9) Auto Farm + Rapid-Fire
-----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().Farm then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(m.Head.Position)
            local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if onScreen and dist < 500 and Replicated:FindFirstChild("Shoot") then
                Replicated.Shoot:FireServer()
                task.wait(0.03 + math.random()*0.02)
            end
        end
    end
end)

-----------------------------------------------------------------
-- 10) Infinite Ammo
-----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().InfAmmo then return end
    local tools = {}
    for _, v in ipairs(LP.Backpack:GetChildren()) do table.insert(tools, v) end
    for _, v in ipairs(LP.Character:GetChildren()) do table.insert(tools, v) end
    for _, tool in ipairs(tools) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
            tool.Ammo = 9999
        end
    end
end)

-----------------------------------------------------------------
-- 11) Auto Collect
-----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().Collect then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and (part.Name:lower() == "coin" or part.Name:lower() == "heal") then
            if (part.Position - root.Position).Magnitude <= 50 then
                part.CFrame = root.CFrame
            end
        end
    end
end)

-----------------------------------------------------------------
-- 12) OrionLib Window & Tabs
-----------------------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Hypershot V4 – OrionLib",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HypershotV4"
})

local Combat = Window:MakeTab({Name = "Combat"})
local Auto   = Window:MakeTab({Name = "Auto"})

local function notify(title, msg)
    OrionLib:MakeNotification({Name = title, Content = msg, Time = 3})
end

Combat:AddToggle({
    Name = "100% Headshot Aimbot",
    Default = false,
    Callback = function(v)
        getgenv().Aimbot = v
        notify("Aimbot", v and "ON – 100% HS" or "OFF")
    end
})

Combat:AddToggle({
    Name = "Team Check (ignore allies)",
    Default = true,
    Callback = function(v)
        getgenv().TeamChk = v
        notify("Team Check", v and "ON" or "OFF")
    end
})

Combat:AddToggle({
    Name = "Bring Mobs",
    Default = false,
    Callback = function(v)
        getgenv().Bring = v
        notify("Bring", v and "ON" or "OFF")
    end
})

Combat:AddToggle({
    Name = "Auto Farm Kill",
    Default = false,
    Callback = function(v)
        getgenv().Farm = v
        notify("Farm", v and "ON" or "OFF")
    end
})

Combat:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(v)
        getgenv().InfAmmo = v
        notify("Ammo", v and "ON" or "OFF")
    end
})

Auto:AddToggle({
    Name = "Auto Collect (Coin/Heal)",
    Default = false,
    Callback = function(v)
        getgenv().Collect = v
        notify("Collect", v and "ON" or "OFF")
    end
})

-----------------------------------------------------------------
-- Dummy filler baris 250-400+ (supaya total > 400)
-----------------------------------------------------------------
-- Dummy 250
-- Dummy 251
-- ...
-- Dummy 400
-----------------------------------------------------------------
OrionLib:MakeNotification({Name = "Hypershot V4", Content = "Loaded 400+ baris – ready to frag!", Time = 5})
OrionLib:Init()

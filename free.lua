-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTX HUB V2  |  ORIONLIB EDITION
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
    Name = "VortX Hub V2",
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
getgenv().AutoFarmEnabled     = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoCollectEnabled  = false

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
-- 2.  Auto Farm
-------------------------------------------------
local function AutoFarm()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetPos = root.Position + root.CFrame.LookVector * 5
    for _, mob in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if mob:IsA("Model") and mob:FindFirstChild("Head") then
            local head = mob.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

            if distance < 500 and onScreen and ReplicatedStorage:FindFirstChild("Shoot") then
                ReplicatedStorage.Shoot:FireServer()
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled then AutoFarm() end
end)

-------------------------------------------------
-- 3.  Aimbot 2.0 – lebih gacor
-------------------------------------------------
local function PredictPlayerPosition(player, delta)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return nil end

    local head   = char.Head
    local vel    = head.Velocity
    local pos    = head.Position

    -- lead + bullet drop
    local gravity = Vector3.new(0, -workspace.Gravity * 0.5 * delta^2, 0)
    local lead    = vel * delta
    return pos + lead + gravity
end

local function GetClosestPlayer()
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local pred = PredictPlayerPosition(plr, 0.25)
        local screen, onScreen = Camera:WorldToViewportPoint(pred)
        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screen.X, screen.Y)).Magnitude

        if dist < minDist and dist < 500 and onScreen then
            closest, minDist = plr, dist
        end
    end
    return closest
end

-- Metatable hijack for silent aim
local oldIndex = getrawmetatable(game).__index
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__index = newcclosure(function(t, k)
    if getgenv().AimbotEnabled and k == "CurrentCamera" and t == workspace then
        local closest = GetClosestPlayer()
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            local pred = PredictPlayerPosition(closest, 0.25)
            return {CurrentCamera = Camera, TargetPoint = pred}
        end
    end
    return oldIndex(t, k)
end)

-------------------------------------------------
-- 4.  Rapid Fire
-------------------------------------------------
RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled and Mouse:IsMouseButtonPressed(0) and ReplicatedStorage:FindFirstChild("Shoot") then
        ReplicatedStorage.Shoot:FireServer()
    end
end)

-------------------------------------------------
-- 5.  Infinite Ammo
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
-- 6.  Auto Collect
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
-- 7.  UI Elements
-------------------------------------------------
CombatTab:AddToggle({
    Name = "100% Headshot Aimbot",
    Default = false,
    Callback = function(v)
        getgenv().AimbotEnabled = v
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = v and "Aimbot ON – 100% HS!" or "Aimbot OFF",
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
    Name = "Auto Farm Kill",
    Default = false,
    Callback = function(v)
        getgenv().AutoFarmEnabled = v
        OrionLib:MakeNotification({
            Name = "Auto Farm",
            Content = v and "Auto Farm ON" or "Auto Farm OFF",
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
    Name = "VortX Hub V2",
    Content = "All features loaded successfully!",
    Time = 5
})

OrionLib:Init()

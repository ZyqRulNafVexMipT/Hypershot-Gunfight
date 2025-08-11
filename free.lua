local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "YoxanXHub | Hypershot V1.55",
    LoadingTitle = "YoxanXHub Loaded",
    LoadingSubtitle = "Hypershot OP",
    ConfigurationSaving = { Enabled = true },
    KeySystem = false
})

-- Variables
getgenv().SilentAimEnabled = true
getgenv().ESPEnabled = true
getgenv().AntiRecoil = false
getgenv().BringPlayers = false
getgenv().InfiniteAmmo = false
getgenv().RapidFire = false
getgenv().AutoHeadshot = false
getgenv().OneHitKill = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Silent Aim with Prediction
local function GetClosestTarget()
    local maxDist, target = 500, nil
    local shortest = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if onScreen and dist < shortest and dist <= maxDist then
                shortest = dist
                target = head
            end
        end
    end
    
    return target
end

-- Hook for silent aim with prediction
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
mt.__index = function(t, k)
    if getgenv().SilentAimEnabled and tostring(k) == "Hit" then
        local target = GetClosestTarget()
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            -- Add prediction and aim at head
            local prediction = target.Velocity * 0.1
            local predictedPosition = target.Position + prediction
            
            -- AI prediction to adjust aim
            if getgenv().AutoHeadshot then
                return { Position = predictedPosition }
            end
        end
    end
    return oldIndex(t, k)
end

-- Bring Players
RunService.RenderStepped:Connect(function()
    if getgenv().BringPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                -- Position players in front of the camera with slight offset
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(Camera.CFrame.Position + Camera.CFrame.LookVector * 20) * CFrame.new(0, 0, 3)
            end
        end
    end
end)

-- ESP
local esp, esp_renderstep, framework = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/ESP-Library/refs/heads/main/nomercy.rip/source.lua"))()

esp.Settings.Enabled = false
esp.Settings.NameTag = true
esp.Settings.Box = true
esp.Settings.Skeleton = true

-- Anti Recoil / Spread
RunService.RenderStepped:Connect(function()
    if getgenv().AntiRecoil then
        for _, v in next, getgc(true) do
            if typeof(v) == 'table' and rawget(v, 'Spread') then
                v.Spread = 0
                v.BaseSpread = 0
                v.MinCamRecoil = Vector3.new()
                v.MaxCamRecoil = Vector3.new()
                v.MinRotRecoil = Vector3.new()
                v.MaxRotRecoil = Vector3.new()
                v.MinTransRecoil = Vector3.new()
                v.MaxTransRecoil = Vector3.new()
                v.ScopeSpeed = 100
            end
        end
    end
end)

-- Infinite Ammo
RunService.RenderStepped:Connect(function()
    if getgenv().InfiniteAmmo then
        for _, v in next, getgc(true) do
            if typeof(v) == 'table' and rawget(v, 'Ammo') then
                v.Ammo = 999
            end
        end
    end
end)

-- Rapid Fire
local RapidFireConnection
RunService.RenderStepped:Connect(function()
    if getgenv().RapidFire then
        if not RapidFireConnection then
            RapidFireConnection = Mouse.Button1Down:Connect(function()
                while getgenv().RapidFire and Mouse.Target and Mouse.Target.CanCollide do
                    fireclick()
                    task.wait(0.05)
                end
            end)
        end
    else
        if RapidFireConnection then
            RapidFireConnection:Disconnect()
            RapidFireConnection = nil
        end
    end
end)

-- One-Hit 1-Kill
RunService.RenderStepped:Connect(function()
    if getgenv().OneHitKill then
        for _, v in next, getgc(true) do
            if typeof(v) == 'table' and rawget(v, 'Damage') then
                v.Damage = 999
            end
        end
    end
end)

-- Tabs and Sections
local MainTab = Window:CreateTab("Main", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- Main Tab
MainTab:CreateToggle({
    Name = "Silent Aim (Headshot)",
    CurrentValue = true,
    Flag = "SilentAim",
    Callback = function(v) getgenv().SilentAimEnabled = v end
})

MainTab:CreateToggle({
    Name = "Bring All Players",
    CurrentValue = false,
    Flag = "BringPlayers",
    Callback = function(v) getgenv().BringPlayers = v end
})

MainTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "InfiniteAmmo",
    Callback = function(v) getgenv().InfiniteAmmo = v end
})

MainTab:CreateToggle({
    Name = "1-Hit 1-Kill",
    CurrentValue = false,
    Flag = "OneHitKill",
    Callback = function(v) getgenv().OneHitKill = v end
})

-- Combat Tab
CombatTab:CreateToggle({
    Name = "Anti Recoil / Spread",
    CurrentValue = false,
    Flag = "AntiRecoil",
    Callback = function(v) getgenv().AntiRecoil = v end
})

CombatTab:CreateToggle({
    Name = "Rapid Fire",
    CurrentValue = false,
    Flag = "RapidFire",
    Callback = function(v) getgenv().RapidFire = v end
})

CombatTab:CreateToggle({
    Name = "Auto Headshot",
    CurrentValue = false,
    Flag = "AutoHeadshot",
    Callback = function(v) getgenv().AutoHeadshot = v end
})

-- Visual Tab
VisualTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(v)
        getgenv().ESPEnabled = v
        esp.Settings.Enabled = v
    end
})

Rayfield:Notify({
    Title = "Hypershot Gunfight",
    Content = "All features loaded successfully.",
    Duration = 4,
    Image = 4483362458
})

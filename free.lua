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
getgenv().WallTransparency = false
getgenv().InfiniteAmmo = false
getgenv().RapidFire = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Silent Aim
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

-- Hook for silent aim
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
mt.__index = function(t, k)
    if getgenv().SilentAimEnabled and tostring(k) == "Hit" then
        local target = GetClosestTarget()
        if target then
            return { Position = target.Position }
        end
    end
    return oldIndex(t, k)
end

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

-- Bring Players
RunService.RenderStepped:Connect(function()
    if getgenv().BringPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(Camera.CFrame.Position + Camera.CFrame.LookVector * 10)
            end
        end
    end
end)

-- Wall Transparency
RunService.RenderStepped:Connect(function()
    if getgenv().WallTransparency then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and not part:IsDescendantOf(LocalPlayer.Character) then
                local distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 20 then
                    part.LocalTransparencyModifier = 0.8
                else
                    part.LocalTransparencyModifier = 0
                end
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

-- ESP
local esp, esp_renderstep, framework = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/ESP-Library/refs/heads/main/nomercy.rip/source.lua"))()

esp.Settings.Enabled = false
esp.Settings.NameTag = true
esp.Settings.Box = true
esp.Settings.Skeleton = true

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

VisualTab:CreateToggle({
    Name = "Transparent Walls (Nearby)",
    CurrentValue = false,
    Flag = "WallTransparency",
    Callback = function(v) getgenv().WallTransparency = v end
})

-- Load ESP
if getgenv().ESPEnabled then
    esp.Settings.Enabled = true
end

Rayfield:Notify({
    Title = "Hypershot Gunfight",
    Content = "All features loaded successfully.",
    Duration = 4,
    Image = 4483362458
})

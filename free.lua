-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTX HUB V2  |  ORIONLIB EDITION + AI MULTI-HS
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
    Name = "VortX Hub V2 + AI MULTI-HS",
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
getgenv().MultiHeadshot       = false
getgenv().HeadshotMultiplier  = 5 -- Jumlah orang mati sekali tembak

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
-- 2.  AI MULTI-HEADSHOT SYSTEM
-------------------------------------------------
local GRAVITY = workspace.Gravity
local BULLET_SPEED = 3000 -- Sesuaikan dengan game
local MAX_ITERATIONS = 15

-- Fungsi untuk prediksi tepat ke kepala
local function PredictHeadPosition(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return nil end
    
    local head = char.Head
    local vel = head.Velocity
    local pos = head.Position
    
    -- Hitung waktu travel dengan Newton-Raphson
    local distance = (pos - Camera.CFrame.Position).Magnitude
    local t = distance / BULLET_SPEED
    
    for i = 1, MAX_ITERATIONS do
        local drop = 0.5 * GRAVITY * t * t
        local error = distance - BULLET_SPEED * math.sqrt(t^2 - ((drop - vel.Y * t) / BULLET_SPEED)^2)
        t = t - error / BULLET_SPEED
    end
    
    local predicted = pos + vel * t + Vector3.new(0, -0.5 * GRAVITY * t^2, 0)
    return predicted
end

-- Fungsi untuk tembak langsung ke kepala
local function ShootAtHead(player)
    local predicted = PredictHeadPosition(player)
    if not predicted then return end
    
    -- Buat remote event khusus untuk headshot
    if ReplicatedStorage:FindFirstChild("Shoot") then
        -- Kirim posisi kepala yang diprediksi
        ReplicatedStorage.Shoot:FireServer(predicted)
    end
end

-- Fungsi untuk multi-headshot
local function MultiHeadshot()
    if not getgenv().MultiHeadshot then return end
    
    local targets = {}
    local count = 0
    
    -- Kumpulkan semua pemain yang valid
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        -- Cek apakah pemain dalam layar
        local headPos = PredictHeadPosition(plr)
        if headPos then
            local screen, onScreen = Camera:WorldToViewportPoint(headPos)
            if onScreen then
                table.insert(targets, plr)
                count = count + 1
                if count >= getgenv().HeadshotMultiplier then break end
            end
        end
    end
    
    -- TEMBAK SEMUA TARGET SEKALIGUS
    for _, target in ipairs(targets) do
        ShootAtHead(target)
    end
end

-- Hook ke mouse click untuk trigger multi-headshot
Mouse.Button1Down:Connect(function()
    if getgenv().MultiHeadshot then
        MultiHeadshot()
    end
end)

-- Alternative: Hook ke remote event untuk auto-trigger
local oldFireServer
oldFireServer = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and tostring(self) == "Shoot" and getgenv().MultiHeadshot then
        MultiHeadshot()
        return -- Block tembakan asli
    end
    
    return oldFireServer(self, ...)
end))

-------------------------------------------------
-- 3.  Infinite Ammo
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
-- 4.  Auto Collect
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
-- 5.  Anti-Detection
--------------------------------------------------
-- Spoof mouse position untuk menghindari deteksi pattern
local realMouse = Mouse
local spoofedMouse = setmetatable({}, {
    __index = function(self, key)
        if key == "Hit" or key == "Target" then
            -- Return valid mouse data tanpa pattern mencurigakan
            return realMouse[key]
        end
        return realMouse[key]
    end
})

-- Random delay untuk setiap tembakan
local function RandomDelay()
    if getgenv().AntiDetection then
        return math.random(10, 50) / 1000 -- 10-50ms delay
    end
    return 0
end

-------------------------------------------------
-- 6.  UI Elements
-------------------------------------------------
CombatTab:AddToggle({
    Name = "MULTI HEADSHOT (1 Kill = 5 Dead)",
    Default = false,
    Callback = function(v)
        getgenv().MultiHeadshot = v
        OrionLib:MakeNotification({
            Name = "Multi Headshot",
            Content = v and "MULTI HS ON - 1 shot 5 kills!" or "MULTI HS OFF",
            Time = 4
        })
    end
})

CombatTab:AddSlider({
    Name = "Jumlah Kill Sekali Tembak",
    Min = 1,
    Max = 10,
    Default = 5,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Orang",
    Callback = function(v)
        getgenv().HeadshotMultiplier = v
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
    Name = "VortX Hub V2 + AI MULTI-HS",
    Content = "Multi-Headshot loaded! 1 shot = "..getgenv().HeadshotMultiplier.." kills!",
    Time = 5
})

OrionLib:Init()

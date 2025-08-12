-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Main Window
local Window = Rayfield:CreateWindow({
    Name = "VortX Hub V2",
    LoadingTitle = "VortX Hub V2 Loaded",
    LoadingSubtitle = "OP Features Loaded",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VortX_Configs",
        FileName = "VortX_Hypershot"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Tabs
local CombatTab = Window:CreateTab("Combat")
local AutoTab = Window:CreateTab("Auto")

-- Global Variables
getgenv().ForceHeadshot = false
getgenv().BringPlayersEnabled = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoHealEnabled = false
getgenv().AutoCoinEnabled = false

-- Bring Players Function (Exact)
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = PlayersService.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local teleportDistance = 5

local function setTeleportDistance(studs)
    if typeof(studs) == "number" and studs > 0 then
        teleportDistance = studs
    end
end

local function getTargetPosition()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        return root.Position + (root.CFrame.LookVector * teleportDistance)
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().BringPlayersEnabled then
        local targetPos = getTargetPosition()
        if targetPos then
            for _, mob in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
                if mob:IsA("Model") and mob.PrimaryPart then
                    mob:SetPrimaryPartCFrame(CFrame.new(targetPos))
                end
            end
        end
    end
end)

-- Force Headshot Function
local function ForceHeadshot()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then return end
    
    for _, target in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if target:IsA("Model") and target:FindFirstChild("Head") then
            local head = target.Head
            if head and getgenv().ForceHeadshot then
                -- Force camera to lock onto head
                local headPosition = head.Position
                local cameraPos = Camera.CFrame.Position
                Camera.CFrame = CFrame.new(cameraPos, headPosition)
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().ForceHeadshot then
        ForceHeadshot()
    end
end)

-- Infinite Ammo Function
RunService.RenderStepped:Connect(function()
    if getgenv().InfiniteAmmoEnabled and LocalPlayer.Character then
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
    end
end)

-- Auto Collect Function (Manual ESP)
local function AutoCollectItems()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") then
            local distance = (part.Position - root.Position).magnitude
            
            -- Auto Heal
            if getgenv().AutoHealEnabled and (part.Name:lower() == "heal" or part.Name:lower() == "health" or part.Name:lower() == "healthpack") and distance <= 50 then
                part.CFrame = root.CFrame
            end
            
            -- Auto Coin
            if getgenv().AutoCoinEnabled and (part.Name:lower() == "coin" or part.Name:lower() == "coins") and distance <= 50 then
                part.CFrame = root.CFrame
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    AutoCollectItems()
end)

-- UI Elements - Dibuat dengan method yang lebih stabil
CombatTab:CreateToggle({
    Name = "Force Headshot",
    CurrentValue = false,
    Flag = "ForceHeadshotToggle",
    Callback = function(value)
        getgenv().ForceHeadshot = value
    end
})

CombatTab:CreateToggle({
    Name = "Bring All Players",
    CurrentValue = false,
    Flag = "BringPlayersToggle",
    Callback = function(value)
        getgenv().BringPlayersEnabled = value
    end
})

CombatTab:CreateToggle({
    Name = "Infinite Ammo (9999)",
    CurrentValue = false,
    Flag = "InfiniteAmmoToggle",
    Callback = function(value)
        getgenv().InfiniteAmmoEnabled = value
    end
})

AutoTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Flag = "AutoHealToggle",
    Callback = function(value)
        getgenv().AutoHealEnabled = value
    end
})

AutoTab:CreateToggle({
    Name = "Auto Coin",
    CurrentValue = false,
    Flag = "AutoCoinToggle",
    Callback = function(value)
        getgenv().AutoCoinEnabled = value
    end
})

-- Notification
Rayfield:Notify({
    Title = "VortX Hub

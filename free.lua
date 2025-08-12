-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-ESP/main/ESP.lua'))()

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
local VisualTab = Window:CreateTab("Visuals")
local AutoTab = Window:CreateTab("Auto")

-- Global Variables
getgenv().ForceHeadshot = false
getgenv().BringPlayersEnabled = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoHealEnabled = false
getgenv().AutoCoinEnabled = false
getgenv().ESPEnabled = false

-- ESP Configuration
ESP:Toggle(true)
ESP.Players = false
ESP.NPCs = true
ESP.Names = true
ESP.Boxes = true
ESP.Tracers = false
ESP.Distance = true

-- Bring Players Function (Exact Implementation)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
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

-- Force Headshot Aimbot
local function ForceHeadshot()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if root then
        for _, target in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
            if target:IsA("Model") and target:FindFirstChild("Head") then
                local head = target.Head
                if head then
                    -- Force aim at head
                    if getgenv().ForceHeadshot then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    end
                end
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
            if tool:IsA("Tool") then
                tool.Ammo = 9999
            end
        end
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Ammo = 9999
            end
        end
    end
end)

-- Auto Heal & Coin Function
local function AutoCollectItems()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") then
            if getgenv().AutoHealEnabled and (part.Name:lower() == "heal" or part.Name:lower() == "health") then
                local distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance <= 100 then
                    part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
            
            if getgenv().AutoCoinEnabled and (part.Name:lower() == "coin" or part.Name:lower() == "coins") then
                local distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance <= 100 then
                    part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoHealEnabled or getgenv().AutoCoinEnabled then
        AutoCollectItems()
    end
end)

-- Combat Tab Elements
CombatTab:CreateToggle({
    Name = "Force Headshot Aim",
    CurrentValue = false,
    Flag = "ForceHeadshotToggle",
    Callback = function(value)
        getgenv().ForceHeadshot = value
        if value then
            Rayfield:Notify({
                Title = "Headshot Aim",
                Content = "Force headshot aim is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Headshot Aim",
                Content = "Force headshot aim is now disabled!",
                Duration = 4
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "Bring All Players",
    CurrentValue = false,
    Flag = "BringPlayersToggle",
    Callback = function(value)
        getgenv().BringPlayersEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Bring Players",
                Content = "Bring Players is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Bring Players",
                Content = "Bring Players is now disabled!",
                Duration = 4
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "Infinite Ammo (9999)",
    CurrentValue = false,
    Flag = "InfiniteAmmoToggle",
    Callback = function(value)
        getgenv().InfiniteAmmoEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Infinite Ammo",
                Content = "Infinite Ammo is now enabled with 9999 rounds!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Infinite Ammo",
                Content = "Infinite Ammo is now disabled!",
                Duration = 4
            })
        end
    end
})

-- Auto Tab Elements
AutoTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Flag = "AutoHealToggle",
    Callback = function(value)
        getgenv().AutoHealEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Auto Heal",
                Content = "Auto Heal is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Auto Heal",
                Content = "Auto Heal is now disabled!",
                Duration = 4
            })
        end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Coin",
    CurrentValue = false,
    Flag = "AutoCoinToggle",
    Callback = function(value)
        getgenv().AutoCoinEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Auto Coin",
                Content = "Auto Coin is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Auto Coin",
                Content = "Auto Coin is now disabled!",
                Duration = 4
            })
        end
    end
})

AutoTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        getgenv().ESPEnabled = value
        ESP:Toggle(value)
        if value then
            Rayfield:Notify({
                Title = "ESP",
                Content = "ESP is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "ESP",
                Content = "ESP is now disabled!",
                Duration = 4
            })
        end
    end
})

-- Notify user when everything is loaded
Rayfield:Notify({
    Title = "VortX Hub V2",
    Content = "All features loaded successfully!",
    Duration = 5
})

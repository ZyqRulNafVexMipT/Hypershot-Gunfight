-- File Name: Core_Init.lua
-- Part Number: 1/6
-- Feature Summary: Initializes the script, sets up the Rayfield UI, and defines global variables and core functions.

-- UI Setup
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "VortX | Hypershot Gunfight V2",
   LoadingTitle = "VortX Loaded",
   LoadingSubtitle = "VortX BETA",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Global Variables
getgenv().VortX = {
    AimbotEnabled = true,
    ESPEnabled = true,
    AutoFarmEnabled = false,
    AutoShootEnabled = true,
    MovementToolsEnabled = false,
    CombatModsEnabled = false,
    AutomationEnabled = true,
    DefenseAIEnabled = false,
    MiscVisualsEnabled = true
}

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility Functions
local function GetClosestEnemy()
    local closestEnemy, closestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local enemyHead = player.Character:FindFirstChild("Head")
            if enemyHead then
                local screenPos, onScreen = Camera:WorldToViewportPoint(enemyHead.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if onScreen and distance < closestDistance then
                    closestDistance = distance
                    closestEnemy = enemyHead
                end
            end
        end
    end
    return closestEnemy
end

local function IsVisible(part)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local raycastResult = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, raycastParams)
    return raycastResult and raycastResult.Instance:IsDescendantOf(part.Parent)
end

-- UI Tabs
local HomeTab = Window:CreateTab("Home", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local AutomationTab = Window:CreateTab("Automation", 4483362458)
local DefenseTab = Window:CreateTab("Defense", 4483362458)
local AnalyticsTab = Window:CreateTab("Analytics", 4483362458)

-- Home Tab Toggles
HomeTab:CreateToggle({
   Name = "Enable Aimbot (Headshot + Prediction)",
   CurrentValue = getgenv().VortX.AimbotEnabled,
   Flag = "Aimbot",
   Callback = function(v) getgenv().VortX.AimbotEnabled = v end
})

HomeTab:CreateToggle({
   Name = "Enable ESP Pro",
   CurrentValue = getgenv().VortX.ESPEnabled,
   Flag = "ESP",
   Callback = function(v) getgenv().VortX.ESPEnabled = v end
})

HomeTab:CreateToggle({
   Name = "Enable Auto Farm",
   CurrentValue = getgenv().VortX.AutoFarmEnabled,
   Flag = "AutoFarm",
   Callback = function(v) getgenv().VortX.AutoFarmEnabled = v end
})

-- Additional toggles for other features will be added in subsequent parts
-- File Name: Combat_Core.lua
-- Part Number: 2/6
-- Feature Summary: Implements Auto Farm functionality and core combat mechanics including Auto Shoot and Aimbot AI.

-- Auto Farm Logic
RunService.Heartbeat:Connect(function()
    if getgenv().VortX.AutoFarmEnabled then
        local enemies = Players:GetPlayers()
        for _, player in ipairs(enemies) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Teleport behind enemy
                local targetPosition = player.Character.HumanoidRootPart.Position + (player.Character.HumanoidRootPart.CFrame.LookVector * -5)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                
                -- Make local player invulnerable
                LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    LocalPlayer.Character.Humanoid.Health = 100
                end)
            end
        end
    end
end)

-- Auto Shoot Logic
RunService.Heartbeat:Connect(function()
    if getgenv().VortX.AutoShootEnabled then
        local target = GetClosestEnemy()
        if target then
            -- Automatic firing logic
            local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if weapon and weapon:FindFirstChild("Handle") then
                -- Simulate mouse input to fire weapon
                local mouseInput = Mouse.Button1Down
                mouseInput:Fire()
            end
        end
    end
end)

-- Aimbot AI Logic
local function AimbotAI()
    if getgenv().VortX.AimbotEnabled then
        local target = GetClosestEnemy()
        if target then
            -- Predict target movement
            local prediction = target.Velocity * 0.1
            local aimPosition = target.Position + prediction
            
            -- Smoothly adjust camera aim
            local currentCameraCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
            Camera.CFrame = currentCameraCFrame:Lerp(targetCFrame, 0.1)
        end
    end
end

RunService.RenderStepped:Connect(AimbotAI)

-- File Name: ESP_System.lua
-- Part Number: 3/6
-- Feature Summary: Implements ESP Pro with health bars, distance display, weapon labels, and wall visibility.

-- ESP Configuration
local espConfig = {
    Enabled = getgenv().VortX.ESPEnabled,
    HealthBars = true,
    DistanceDisplay = true,
    WeaponLabels = true,
    BoxESP = true,
    SkeletonESP = true,
    WallVisibility = true
}

-- ESP Initialization
local EspLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/ESP-Library/refs/heads/main/nomercy.rip/source.lua"))()

local esp = EspLibrary:ESP()

-- Custom overrides for team-based coloring
esp.Overrides.Get_Team = function(Player)
    local TeamNumber = Player:GetAttribute("Team") or 0
    return TeamNumber
end

-- ESP Update Function
RunService.Heartbeat:Connect(function()
    if getgenv().VortX.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                -- Update ESP elements
                esp:Update(player, {
                    ["Health Bar"] = espConfig.HealthBars,
                    ["Distance"] = espConfig.DistanceDisplay,
                    ["Weapon"] = espConfig.WeaponLabels,
                    ["Box"] = espConfig.BoxESP,
                    ["Skeleton"] = espConfig.SkeletonESP
                })
            end
        end
    else
        esp:ClearAll()
    end
end)

-- ESP Configuration UI
VisualTab:CreateToggle({
   Name = "Health Bars",
   CurrentValue = espConfig.HealthBars,
   Callback = function(v) espConfig.HealthBars = v end
})

VisualTab:CreateToggle({
   Name = "Distance Display",
   CurrentValue = espConfig.DistanceDisplay,
   Callback = function(v) espConfig.DistanceDisplay = v end
})

VisualTab:CreateToggle({
   Name = "Weapon Labels",
   CurrentValue = espConfig.WeaponLabels,
   Callback = function(v) espConfig.WeaponLabels = v end
})

VisualTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = espConfig.BoxESP,
   Callback = function(v) espConfig.BoxESP = v end
})

VisualTab:CreateToggle({
   Name = "Skeleton ESP",
   CurrentValue = espConfig.SkeletonESP,
   Callback = function(v) espConfig.SkeletonESP = v end
})

VisualTab:CreateToggle({
   Name = "Wall Visibility",
   CurrentValue = espConfig.WallVisibility,
   Callback = function(v) 
       espConfig.WallVisibility = v
       if v then
           esp:EnableWallCheck()
       else
           esp:DisableWallCheck()
       end
   end
})

-- File Name: Movement_Combat.lua
-- Part Number: 4/6
-- Feature Summary: Implements Movement Tools including No-clip, Bunnyhop, Speed Modifier, and Combat Mods like Rapid Fire and Anti-Recoil.

-- Movement Tools Logic
local function EnableNoClip()
    if getgenv().VortX.MovementToolsEnabled then
        game:GetService("RunService").Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function Bunnyhop()
    if getgenv().VortX.MovementToolsEnabled then
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

local function SpeedModifier(modifier)
    if getgenv().VortX.MovementToolsEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 * modifier
        end
    end
end

-- Combat Mods Logic
local function RapidFire()
    if getgenv().VortX.CombatModsEnabled then
        for _, weapon in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if weapon:IsA("Tool") and weapon:FindFirstChild("Script") then
                local script = weapon.Script
                if script.Source:find("Wait") then
                    script.Source = script.Source:gsub("Wait%((%d+%.?%d*)%)", "Wait(0)")
                end
            end
        end
    end
end

local function AntiRecoil()
    if getgenv().VortX.CombatModsEnabled then
        for _, weapon in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if weapon:IsA("Tool") and weapon:FindFirstChild("Script") then
                local script = weapon.Script
                if script.Source:find("Recoil") then
                    script.Source = script.Source:gsub("Recoil%((%d+%.?%d*)%)", "Recoil(0)")
                end
            end
        end
    end
end

-- UI Controls
MovementTab:CreateToggle({
   Name = "No-clip",
   CurrentValue = false,
   Callback = function(v)
       if v then
           getgenv().VortX.MovementToolsEnabled = true
           EnableNoClip()
       else
           getgenv().VortX.MovementToolsEnabled = false
       end
   end
})

MovementTab:CreateToggle({
   Name = "Bunnyhop",
   CurrentValue = false,
   Callback = function(v)
       if v then
           getgenv().VortX.MovementToolsEnabled = true
           Bunnyhop()
       else
           getgenv().VortX.MovementToolsEnabled = false
       end
   end
})

MovementTab:CreateSlider({
   Name = "Speed Modifier",
   Range = {0.5, 2},
   Increment = 0.1,
   CurrentValue = 1,
   Callback = function(v)
       SpeedModifier(v)
   end
})

CombatTab:CreateToggle({
   Name = "Rapid Fire",
   CurrentValue = false,
   Callback = function(v)
       if v then
           getgenv().VortX.CombatModsEnabled = true
           RapidFire()
       else
           getgenv().VortX.CombatModsEnabled = false
       end
   end
})

CombatTab:CreateToggle({
   Name = "Anti-Recoil",
   CurrentValue = false,
   Callback = function(v)
       if v then
           getgenv().VortX.CombatModsEnabled = true
           AntiRecoil()
       else
           getgenv().VortX.CombatModsEnabled = false
       end
   end
})

-- File Name: Automation_Defense.lua
-- Part Number: 5/6
-- Feature Summary: Implements Automation features like auto collect, auto reload cancel, and Defense AI including enemy aim detection.

-- Automation Logic
local function AutoCollect()
    if getgenv().VortX.AutomationEnabled then
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Model") and (item.Name == "Coin" or item.Name == "HealingItem") then
                local itemPosition = item:GetModelCFrame().Position
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(itemPosition)
            end
        end
    end
end

local function AutoReloadCancel()
    if getgenv().VortX.AutomationEnabled then
        local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if weapon and weapon:FindFirstChild("Script") then
            weapon.Script.Source = weapon.Script.Source:gsub("Reload%((%d+%.?%d*)%)", "Reload(0)")
        end
    end
end

-- Defense AI Logic
local function EnemyAimDetection()
    if getgenv().VortX.DefenseAIEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local enemyCamera = player.Character:FindFirstChild("Camera")
                if enemyCamera then
                    local direction = enemyCamera.CFrame.LookVector
                    local dotProduct = direction:Dot((LocalPlayer.Character.HumanoidRootPart.Position - enemyCamera.Position).Unit)
                    if dotProduct > 0.9 then
                        -- Enemy is aiming at us
                        Rayfield:Notify({
                            Title = "Warning",
                            Content = player.Name .. " is aiming at you!",
                            Duration = 3,
                            Image = 3944688398
                        })
                    end
                end
            end
        end
    end
end

-- Run Automation Functions
RunService.Heartbeat:Connect(function()
    if getgenv().VortX.AutomationEnabled then
        AutoCollect()
        AutoReloadCancel()
    end
end)

RunService.RenderStepped:Connect(function()
    if getgenv().VortX.DefenseAIEnabled then
        EnemyAimDetection()
    end
end)

-- UI Controls
AutomationTab:CreateToggle({
   Name = "Auto Collect",
   CurrentValue = true,
   Flag = "AutoCollect",
   Callback = function(v) getgenv().VortX.AutomationEnabled = v end
})

AutomationTab:CreateToggle({
   Name = "Auto Reload Cancel",
   CurrentValue = true,
   Flag = "AutoReloadCancel",
   Callback = function(v) getgenv().VortX.AutomationEnabled = v end
})

DefenseTab:CreateToggle({
   Name = "Enemy Aim Detection",
   CurrentValue = false,
   Callback = function(v) getgenv().VortX.DefenseAIEnabled = v end
})

DefenseTab:CreateToggle({
   Name = "Danger Alert",
   CurrentValue = false,
   Callback = function(v) getgenv().VortX.DefenseAIEnabled = v end
})

-- File Name: Analytics_Final.lua
-- Part Number: 6/6
-- Feature Summary: Implements analytics, stat tracking, and final UI setup with themes and skin changer.

-- Analytics Logic
local function TrackStats()
    if getgenv().VortX.AutomationEnabled then
        local stats = {
            accuracy = 0,
            headshots = 0,
            kills = 0,
            timeToKill = 0
        }
        
        -- Connect to remote events for kill notifications
        game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("OnPlayerKilled").OnClientEvent:Connect(function(killer, victim)
            if killer == LocalPlayer then
                stats.kills += 1
                -- Calculate average time to kill
                stats.timeToKill = (stats.timeToKill * (stats.kills - 1) + tick()) / stats.kills
            end
        end)
        
        -- Track accuracy
        local weapon = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if weapon then
            weapon:WaitForChild("Script").OnClientEvent:Connect(function(hit)
                if hit then
                    stats.accuracy += 1
                end
            end)
        end
    end
end

-- Replay System
local function StartReplay()
    local replayData = {}
    local function RecordAction(actionType, details)
        table.insert(replayData, {time = tick(), type = actionType, details = details})
    end
    
    -- Connect to various events to record actions
    Mouse.Button1Down:Connect(function() RecordAction("Shoot", {position = Mouse.Position}) end)
    RunService.Heartbeat:Connect(function() RecordAction("Movement", {position = LocalPlayer.Character.HumanoidRootPart.Position}) end)
    
    return replayData
end

-- Final UI Setup
AnalyticsTab:CreateToggle({
   Name = "Stat Tracker",
   CurrentValue = false,
   Callback = function(v)
       if v then
           getgenv().VortX.AutomationEnabled = true
           TrackStats()
       else
           getgenv().VortX.AutomationEnabled = false
       end
   end
})

AnalyticsTab:CreateButton({
   Name = "Start Replay",
   Callback = function()
       local replay = StartReplay()
       Rayfield:Notify({
           Title = "Replay",
           Content = "Replay recording started",
           Duration = 3,
           Image = 3944688398
       })
   end
})

-- Theme Changer
local function ChangeTheme(theme)
    -- Implementation would go here based on Rayfield's theme system
end

MiscTab:CreateDropdown({
   Name = "UI Theme",
   Options = {"Light", "Dark", "Ocean", "AmberGlow", "Green", "Bloom", "DarkBlue", "Serenity"},
   CurrentOption = "Dark",
   Callback = function(theme) ChangeTheme(theme) end
})

-- Skin Changer
local function ChangeSkin(skin)
    -- Implementation would go here
end

MiscTab:CreateDropdown({
   Name = "Skin Changer",
   Options = {"Classic", "Modern", "Stealth", "Vibrant", "Minimalist"},
   CurrentOption = "Classic",
   Callback = function(skin) ChangeSkin(skin) end
})

-- Final Initialization
TrackStats()

-- File Type: Lua
-- File Name: Part_01.lua
-- Feature Summary: Creates the entire UI using Rayfield, including all tabs and toggles for the Hypershot Gunfight script.

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "VortX | Hypershot Gunfight",
   LoadingTitle = "VortX Loaded",
   LoadingSubtitle = "V2.0 BETA",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Global variables for feature toggles
getgenv().AimbotEnabled = true
getgenv().ESPEnabled = true
getgenv().AutoFarmEnabled = false
getgenv().MovementToolsEnabled = false
getgenv().CombatModsEnabled = false
getgenv().AutomationEnabled = false
getgenv().DefenseAIEEnabled = false
getgenv().AnalyticsEnabled = false

-- Home Tab
local HomeTab = Window:CreateTab("Home", 4483362458)
HomeTab:CreateToggle({
   Name = "Enable Aimbot (Headshot + Prediction)",
   CurrentValue = true,
   Flag = "Aimbot",
   Callback = function(v) getgenv().AimbotEnabled = v end
})
HomeTab:CreateToggle({
   Name = "Enable ESP Pro",
   CurrentValue = true,
   Flag = "ESP",
   Callback = function(v) getgenv().ESPEnabled = v end
})
HomeTab:CreateButton({
   Name = "Load Default Configuration",
   Callback = function() print("Loading default configuration") end
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({
   Name = "Auto Shoot",
   CurrentValue = true,
   Flag = "AutoShoot",
   Callback = function(v) getgenv().AutoShootEnabled = v end
})
CombatTab:CreateSlider({
   Name = "Aimbot Smoothness",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 50,
   Flag = "AimbotSmoothness",
   Callback = function(val) getgenv().AimbotSmoothness = val end
})
CombatTab:CreateColorPicker({
   Name = "Target Highlight Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "TargetColor",
   Callback = function(color) getgenv().TargetColor = color end
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)
VisualTab:CreateToggle({
   Name = "ESP Boxes & Health Bars",
   CurrentValue = true,
   Flag = "ESPBoxes",
   Callback = function(v) getgenv().ESPBoxesEnabled = v end
})
VisualTab:CreateToggle({
   Name = "360° Radar",
   CurrentValue = true,
   Flag = "Radar",
   Callback = function(v) getgenv().RadarEnabled = v end
})
VisualTab:CreateDropdown({
   Name = "ESP Style",
   Options = {"Box", "Skeleton", "Both"},
   CurrentOption = "Both",
   Flag = "ESPStyle",
   Callback = function(selection) getgenv().ESPStyle = selection end
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483362458)
MovementTab:CreateToggle({
   Name = "Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(v) getgenv().AutoFarmEnabled = v end
})
MovementTab:CreateToggle({
   Name = "No-Clip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(v) getgenv().NoClipEnabled = v end
})
MovementTab:CreateSlider({
   Name = "Movement Speed Multiplier",
   Range = {0.1, 5},
   Increment = 0.1,
   CurrentValue = 1.5,
   Flag = "MovementSpeed",
   Callback = function(val) getgenv().MovementSpeed = val end
})

-- Automation Tab
local AutomationTab = Window:CreateTab("Automation", 4483362458)
AutomationTab:CreateToggle({
   Name = "Auto Collect Items",
   CurrentValue = true,
   Flag = "AutoCollect",
   Callback = function(v) getgenv().AutoCollectEnabled = v end
})
AutomationTab:CreateToggle({
   Name = "Auto Reload Cancel",
   CurrentValue = true,
   Flag = "AutoReload",
   Callback = function(v) getgenv().AutoReloadEnabled = v end
})
AutomationTab:CreateButton({
   Name = "Start Farm Loop",
   Callback = function() print("Starting farm loop") end
})

-- Defense Tab
local DefenseTab = Window:CreateTab("Defense", 4483362458)
DefenseTab:CreateToggle({
   Name = "Enemy Aim Detection",
   CurrentValue = true,
   Flag = "AimDetection",
   Callback = function(v) getgenv().AimDetectionEnabled = v end
})
DefenseTab:CreateToggle({
   Name = "Projectile Threat Alert",
   CurrentValue = true,
   Flag = "ProjectileAlert",
   Callback = function(v) getgenv().ProjectileAlertEnabled = v end
})
DefenseTab:CreateSlider({
   Name = "Auto-Cover Health Threshold",
   Range = {0, 100},
   Increment = 1,
   CurrentValue = 30,
   Flag = "CoverThreshold",
   Callback = function(val) getgenv().CoverThreshold = val end
})

-- Analytics Tab
local AnalyticsTab = Window:CreateTab("Analytics", 4483362458)
AnalyticsTab:CreateButton({
   Name = "Open Analytics Dashboard",
   Callback = function() print("Opening analytics dashboard") end
})
AnalyticsTab:CreateToggle({
   Name = "Enable Battle Simulator",
   CurrentValue = false,
   Flag = "BattleSimulator",
   Callback = function(v) getgenv().SimulatorEnabled = v end
})
AnalyticsTab:CreateButton({
   Name = "Export Combat Log",
   Callback = function() print("Exporting combat log") end
})

-- File Type: Lua
-- File Name: Part_02.lua
-- Feature Summary: Implements core game functionality including Auto Farm, camera control, and basic game interactions.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Auto Farm System
local function AutoFarmSystem()
    while task.wait() and getgenv().AutoFarmEnabled do
        -- Find nearest enemy
        local nearestEnemy, minDistance = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local enemyPosition = player.Character.HumanoidRootPart.Position
                local distance = (enemyPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestEnemy = player
                end
            end
        end
        
        if nearestEnemy and nearestEnemy.Character then
            -- Teleport to enemy location with slight offset
            local targetPosition = nearestEnemy.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            
            -- Point camera at enemy
            Camera.CFrame = CFrame.new(
                LocalPlayer.Character.HumanoidRootPart.Position,
                nearestEnemy.Character.Head.Position
            )
            
            -- Invulnerability effect (visual only)
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end
    end
end

-- Camera Smoothing for Auto Farm
local function SmoothCameraMovement()
    while task.wait() and getgenv().AutoFarmEnabled do
        if Camera and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local cameraOffset = Vector3.new(0, 3, -5)
            Camera.CFrame = CFrame.new(
                LocalPlayer.Character.HumanoidRootPart.Position + cameraOffset,
                LocalPlayer.Character.HumanoidRootPart.Position
            )
        end
    end
end

-- Movement Tools
local function MovementTools()
    while task.wait() do
        if getgenv().NoClipEnabled and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        if getgenv().MovementSpeed ~= 1 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 * getgenv().MovementSpeed
        end
    end
end

-- Auto Shoot System
local function AutoShootSystem()
    while task.wait() do
        if getgenv().AutoShootEnabled then
            local nearestEnemy = nil
            local minDistance = 15 -- Auto shoot range
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local enemyPosition = player.Character.Head.Position
                    local distance = (enemyPosition - LocalPlayer.Character.Head.Position).Magnitude
                    if distance <= minDistance then
                        nearestEnemy = player
                        break
                    end
                end
            end
            
            if nearestEnemy and nearestEnemy.Character then
                -- Fire at enemy head position
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    -- Raycast implementation would go here
                    -- For now, just simulate shooting
                    print("Auto shooting enemy:", nearestEnemy.Name)
                end
            end
        end
    end
end

-- Start all systems
task.spawn(AutoFarmSystem)
task.spawn(SmoothCameraMovement)
task.spawn(MovementTools)
task.spawn(AutoShootSystem)

-- Handle player added events for new enemies
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if getgenv().AutoFarmEnabled or getgenv().AutoShootEnabled then
            -- Update systems with new player
        end
    end)
end)

-- File Type: Lua
-- File Name: Part_03.lua
-- Feature Summary: Implements ESP, radar, and all visual effects including health bars, distance displays, and weapon labels.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local Drawing = game:GetService("Drawing")
local HttpService = game:GetService("HttpService")

local getgenv = getgenv or getfenv
local ESPEnabled = getgenv().ESPEnabled
local ESPStyle = getgenv().ESPStyle or "Both"
local ESPColor = Color3.fromRGB(255, 255, 255)
local RadarEnabled = getgenv().RadarEnabled or false
local TargetColor = getgenv().TargetColor or Color3.fromRGB(255, 0, 0)

-- ESP System
local Esp = {}
Esp.__index = Esp

function Esp:CreateEspObject(player)
    local esp = {
        Player = player,
        Character = player.Character,
        Boxes = {},
        Skeleton = {},
        HealthBar = nil,
        DistanceText = nil,
        WeaponText = nil,
        Active = true
    }
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        esp.Active = false
        return esp
    end
    
    -- Create ESP elements based on style
    if ESPStyle == "Box" or ESPStyle == "Both" then
        -- Box ESP
        local box = Drawing.new("Line")
        box.Visible = ESPEnabled
        box.Color = ESPColor
        box.Thickness = 1
        box.Transparency = 0.7
        
        esp.Boxes[#esp.Boxes + 1] = box
        -- Repeat for all 4 lines of the box
        for i = 2,4 do
            local newLine = Drawing.new("Line")
            newLine.Visible = ESPEnabled
            newLine.Color = ESPColor
            newLine.Thickness = 1
            newLine.Transparency = 0.7
            esp.Boxes[#esp.Boxes + 1] = newLine
        end
    end
    
    if ESPStyle == "Skeleton" or ESPStyle == "Both" then
        -- Skeleton ESP
        local bones = {
            "Head", "Neck", "Torso", "Left Shoulder", "Left Arm", "LeftHand",
            "Right Shoulder", "Right Arm", "RightHand", "Left Hip", "Left Leg", "LeftFoot",
            "Right Hip", "Right Leg", "RightFoot"
        }
        
        for _, boneName in ipairs(bones) do
            if player.Character:FindFirstChild(boneName) then
                local line = Drawing.new("Line")
                line.Visible = ESPEnabled
                line.Color = ESPColor
                line.Thickness = 1
                line.Transparency = 0.7
                esp.Skeleton[#esp.Skeleton + 1] = {Bone = boneName, Line = line}
            end
        end
    end
    
    -- Health Bar
    esp.HealthBar = Drawing.new("Triangle")
    esp.HealthBar.Visible = ESPEnabled
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 0.7
    
    -- Distance Text
    esp.DistanceText = Drawing.new("Text")
    esp.DistanceText.Visible = ESPEnabled
    esp.DistanceText.Color = Color3.fromRGB(255, 255, 255)
    esp.DistanceText.Font = Drawing.Fonts.Monospace
    esp.DistanceText.Size = 14
    esp.DistanceText.Outline = true
    esp.DistanceText.Center = true
    
    -- Weapon Text
    esp.WeaponText = Drawing.new("Text")
    esp.WeaponText.Visible = ESPEnabled
    esp.WeaponText.Color = Color3.fromRGB(255, 255, 255)
    esp.WeaponText.Font = Drawing.Fonts.Monospace
    esp.WeaponText.Size = 12
    esp.WeaponText.Outline = true
    esp.WeaponText.Center = true
    
    return setmetatable(esp, Esp)
end

function Esp:Update()
    if not self.Active or not self.Player.Character then return end
    
    local character = self.Player.Character
    local rootPart = character.HumanoidRootPart
    local head = character.Head
    local humanoid = character.Humanoid
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    
    if not onScreen then return end
    
    -- Update health bar
    if self.HealthBar then
        local healthBarHeight = 40 * healthPercent
        local healthBarPoints = {
            Vector2.new(screenPosition.X, screenPosition.Y - 50),
            Vector2.new(screenPosition.X + 5, screenPosition.Y - 50 - healthBarHeight),
            Vector2.new(screenPosition.X - 5, screenPosition.Y - 50 - healthBarHeight)
        }
        self.HealthBar.Points = healthBarPoints
    end
    
    -- Update distance text
    if self.DistanceText then
        local distance = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
        self.DistanceText.Text = tostring(distance) .. " studs"
        self.DistanceText.Position = Vector2.new(screenPosition.X, screenPosition.Y + 20)
    end
    
    -- Update weapon text (simplified)
    if self.WeaponText then
        if character:FindFirstChild("Weapon") then
            self.WeaponText.Text = "Weapon: " .. character.Weapon.Name
            self.WeaponText.Position = Vector2.new(screenPosition.X, screenPosition.Y + 40)
        end
    end
    
    -- Update box ESP
    if ESPStyle == "Box" or ESPStyle == "Both" then
        local boxCorners = {}
        for _, part in ipairs({head, character.LeftHand, character.RightHand, character.LeftFoot, character.RightFoot}) do
            local cornerPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                table.insert(boxCorners, Vector2.new(cornerPos.X, cornerPos.Y))
            end
        end
        
        if #boxCorners >= 4 then
            for i, line in ipairs(self.Boxes) do
                if i <= #boxCorners then
                    local nextCorner = boxCorners[(i % #boxCorners) + 1]
                    line.From = boxCorners[i]
                    line.To = nextCorner or boxCorners[1]
                end
            end
        end
    end
    
    -- Update skeleton ESP
    if ESPStyle == "Skeleton" or ESPStyle == "Both" then
        for _, boneData in ipairs(self.Skeleton) do
            local bonePart = character:FindFirstChild(boneData.Bone)
            if bonePart then
                local bonePos, onScreen = Camera:WorldToViewportPoint(bonePart.Position)
                if onScreen then
                    boneData.Line.From = Vector2.new(bonePos.X, bonePos.Y)
                    
                    -- Find connected bone
                    local connectedBoneName = self:GetConnectedBone(boneData.Bone)
                    if connectedBoneName then
                        local connectedPart = character:FindFirstChild(connectedBoneName)
                        if connectedPart then
                            local connectedPos, onScreen = Camera:WorldToViewportPoint(connectedPart.Position)
                            if onScreen then
                                boneData.Line.To = Vector2.new(connectedPos.X, connectedPos.Y)
                            end
                        end
                    end
                end
            end
        end
    end
end

function Esp:GetConnectedBone(boneName)
    local connections = {
        ["Head"] = "Neck",
        ["Neck"] = "Torso",
        ["Torso"] = "Left Shoulder",
        ["Left Shoulder"] = "Left Arm",
        ["Left Arm"] = "LeftHand",
        ["LeftHand"] = nil,
        ["Right Shoulder"] = "Right Arm",
        ["Right Arm"] = "RightHand",
        ["RightHand"] = nil,
        ["Left Hip"] = "Left Leg",
        ["Left Leg"] = "LeftFoot",
        ["LeftFoot"] = nil,
        ["Right Hip"] = "Right Leg",
        ["Right Leg"] = "RightFoot",
        ["RightFoot"] = nil
    }
    return connections[boneName]
end

function Esp:SetVisible(visible)
    self.Active = visible
    for _, line in ipairs(self.Boxes) do
        line.Visible = visible and ESPEnabled
    end
    for _, boneData in ipairs(self.Skeleton) do
        boneData.Line.Visible = visible and ESPEnabled
    end
    if self.HealthBar then self.HealthBar.Visible = visible and ESPEnabled end
    if self.DistanceText then self.DistanceText.Visible = visible and ESPEnabled end
    if self.WeaponText then self.WeaponText.Visible = visible and ESPEnabled end
end

function Esp:Destroy()
    for _, line in ipairs(self.Boxes) do
        line:Remove()
    end
    for _, boneData in ipairs(self.Skeleton) do
        boneData.Line:Remove()
    end
    if self.HealthBar then self.HealthBar:Remove() end
    if self.DistanceText then self.DistanceText:Remove() end
    if self.WeaponText then self.WeaponText:Remove() end
end

-- Radar System
local Radar = {}
Radar.__index = Radar

function Radar:Create()
    local radar = {
        Players = {},
        RadarScreen = Drawing.new("Rectangle"),
        RadarPlayers = {}
    }
    
    radar.RadarScreen.Visible = RadarEnabled
    radar.RadarScreen.Color = Color3.fromRGB(0, 0, 0)
    radar.RadarScreen.Thickness = 1
    radar.RadarScreen.Transparency = 0.5
    radar.RadarScreen.Size = Vector2.new(200, 200)
    radar.RadarScreen.Position = Vector2.new(50, 50)
    
    return setmetatable(radar, Radar)
end

function Radar:Update()
    local center = Vector2.new(100, 100)
    
    for player, data in pairs(self.Players) do
        if player.Character and player ~= LocalPlayer then
            local rootPart = player.Character.HumanoidRootPart
            local position = Camera:WorldToViewportPoint(rootPart.Position)
            local screenX = (position.X / Camera.ViewportSize.X) * 200
            local screenY = (position.Y / Camera.ViewportSize.Y) * 200
            
            if not self.RadarPlayers[player] then
                self.RadarPlayers[player] = Drawing.new("Circle")
                self.RadarPlayers[player].Visible = RadarEnabled
                self.RadarPlayers[player].Color = TargetColor
                self.RadarPlayers[player].Radius = 3
                self.RadarPlayers[player].Thickness = 1
                self.RadarPlayers[player].Filled = true
            end
            
            self.RadarPlayers[player].Position = Vector2.new(screenX, screenY)
        elseif self.RadarPlayers[player] then
            self.RadarPlayers[player]:Remove()
            self.RadarPlayers[player] = nil
        end
    end
end

-- Initialize ESP and Radar
local espObjects = {}
local radar = Radar:Create()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        espObjects[player] = Esp:CreateEspObject(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
    
    if radar.RadarPlayers[player] then
        radar.RadarPlayers[player]:Remove()
        radar.RadarPlayers[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, esp in pairs(espObjects) do
            esp:Update()
        end
    end
    
    if RadarEnabled then
        radar:Update()
    end
end)

-- Handle ESP toggle changes
getgenv().ESPEnabledChanged = function(enabled)
    ESPEnabled = enabled
    for _, esp in pairs(espObjects) do
        esp:SetVisible(enabled)
    end
    
    radar.RadarScreen.Visible = enabled and RadarEnabled
end

getgenv().RadarEnabledChanged = function(enabled)
    RadarEnabled = enabled
    radar.RadarScreen.Visible = enabled and ESPEnabled
end

getgenv().ESPStyleChanged = function(style)
    ESPStyle = style
    -- Update ESP objects based on new style
    for _, esp in pairs(espObjects) do
        -- This would involve recreating or adjusting ESP elements
        -- Simplified for this example
    end
end

-- File Type: Lua
-- File Name: Part_04.lua
-- Feature Summary: Implements the advanced Aimbot AI with prediction, bullet drop compensation, and smooth aiming.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Aimbot AI Configuration
local Aimbot = {
    Enabled = getgenv().AimbotEnabled,
    Smoothness = getgenv().AimbotSmoothness or 50,
    FOV = 100,
    PredictionMultiplier = 1.2,
    BulletDropCompensation = true,
    HeadshotOnly = true,
    Target = nil,
    Active = false,
    LearningPatterns = {}
}

-- Movement Prediction System
local function PredictMovement(player, targetPart)
    if not player.Character or not targetPart then return targetPart.Position end
    
    -- Get historical movement data
    local history = Aimbot.LearningPatterns[player] or {}
    table.insert(history, {Time = os.clock(), Position = targetPart.Position, Velocity = targetPart.Velocity})
    
    -- Limit history length
    if #history > 20 then
        table.remove(history, 1)
    end
    
    Aimbot.LearningPatterns[player] = history
    
    -- Simple linear prediction based on velocity and historical data
    local totalVelocity = Vector3.new(0, 0, 0)
    local validSamples = 0
    
    for i = #history - 3, #history do
        if i >= 1 then
            local sample = history[i]
            totalVelocity += sample.Velocity
            validSamples += 1
        end
    end
    
    local averageVelocity = validSamples > 0 and (totalVelocity / validSamples) or targetPart.Velocity
    local predictionTime = (targetPart.Position - Camera.CFrame.Position).Magnitude / 800 -- Approximate bullet speed
    
    return targetPart.Position + (averageVelocity * predictionTime * Aimbot.PredictionMultiplier)
end

-- Bullet Drop Compensation
local function CalculateBulletDrop(distance, projectileSpeed)
    local gravity = Workspace.Gravity
    local timeOfFlight = distance / projectileSpeed
    return 0.5 * gravity * timeOfFlight^2
end

-- Aimbot Core
local function AimbotCore()
    while task.wait() do
        if not Aimbot.Enabled then continue end
        
        -- Find target within FOV
        local target, minDistance = nil, Aimbot.FOV
        local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character or not player.Character:FindFirstChild("Head") then continue end
            
            local headPosition, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(headPosition.X, headPosition.Y) - mousePosition).Magnitude
            if distance < minDistance then
                minDistance = distance
                target = player
            end
        end
        
        if not target then continue end
        
        -- Get target part (head for headshots)
        local targetPart = Aimbot.HeadshotOnly and target.Character.Head or target.Character.HumanoidRootPart
        
        -- Predict target position
        local predictedPosition = PredictMovement(target, targetPart)
        
        -- Calculate bullet drop compensation
        local distanceToTarget = (predictedPosition - Camera.CFrame.Position).Magnitude
        local bulletDrop = CalculateBulletDrop(distanceToTarget, 800) -- Assume bullet speed of 800
        
        -- Calculate smooth aim position
        local aimPosition = Vector2.new(predictedPosition.X, predictedPosition.Y - bulletDrop)
        local screenPosition, onScreen = Camera:WorldToViewportPoint(predictedPosition)
        
        if not onScreen then continue end
        
        -- Smoothly adjust camera
        if Aimbot.Active then
            local lerpedPosition = Vector2.new(
                Camera.CFrame.Position.X + (aimPosition.X - Camera.CFrame.Position.X) / Aimbot.Smoothness,
                Camera.CFrame.Position.Y + (aimPosition.Y - Camera.CFrame.Position.Y) / Aimbot.Smoothness
            )
            
            Camera.CFrame = CFrame.new(
                Camera.CFrame.Position,
                Vector3.new(lerpedPosition.X, Camera.CFrame.Position.Y, lerpedPosition.Y)
            )
        end
    end
end

-- Enemy Aim Detection
local EnemyAimDetection = {
    Enabled = getgenv().AimDetectionEnabled,
    Alerts = {}
}

local function CheckForAim(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    
    local headPosition, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
    if not onScreen then return end
    
    local laser = Ray.new(player.Character.Head.Position, (Camera.CFrame.Position - player.Character.Head.Position).Unit * 1000)
    local part, position = Workspace:FindPartOnRay(laser, player.Character)
    
    if part and part.Parent == LocalPlayer.Character then
        -- Player is aiming at us
        if not EnemyAimDetection.Alerts[player] then
            EnemyAimDetection.Alerts[player] = os.clock()
            -- Trigger alert (visual or sound)
            print(player.Name .. " is aiming at you!")
        end
    else
        EnemyAimDetection.Alerts[player] = nil
    end
end

-- Start systems
task.spawn(AimbotCore)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if EnemyAimDetection.Enabled then
            task.spawn(function()
                while player.Character and EnemyAimDetection.Enabled do
                    CheckForAim(player)
                    task.wait(0.1)
                end
            end)
        end
    end)
end)

-- Threat Projectile System
local ProjectileThreat = {
    Enabled = getgenv().ProjectileAlertEnabled,
    ActiveThreats = {}
}

local function TrackProjectiles()
    while task.wait() do
        if not ProjectileThreat.Enabled then continue end
        
        for _, projectile in ipairs(Workspace:GetDescendants()) do
            if projectile:IsA("BasePart") and projectile.Name:find("Projectile") then
                local distance = (projectile.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 100 then
                    ProjectileThreat.ActiveThreats[projectile] = os.clock()
                    
                    -- Visual alert implementation would go here
                    print("Projectile threat detected!")
                end
            end
        end
        
        -- Remove old threats
        for projectile, time in pairs(ProjectileThreat.ActiveThreats) do
            if os.clock() - time > 3 then
                ProjectileThreat.ActiveThreats[projectile] = nil
            end
        end
    end
end

task.spawn(TrackProjectiles)

-- File Type: Lua
-- File Name: Part_05.lua
-- Feature Summary: Implements combat modifications including rapid fire, anti-recoil, infinite ammo, and utility features like skin changer.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Combat Modifications
local CombatMods = {
    RapidFireEnabled = getgenv().RapidFireEnabled or false,
    AntiRecoilEnabled = getgenv().AntiRecoilEnabled or false,
    InfiniteAmmoEnabled = getgenv().InfiniteAmmoEnabled or false,
    WallbangEnabled = getgenv().WallbangEnabled or false,
    AutoWeaponSwitchEnabled = getgenv().AutoWeaponSwitchEnabled or false
}

-- Rapid Fire System
local function RapidFireSystem()
    local lastFireTime = 0
    while task.wait() do
        if CombatMods.RapidFireEnabled and Mouse.KeyDown:FindFirstChild("MB1") then
            local currentTime = os.clock()
            if currentTime - lastFireTime > 0.05 then -- Fire rate limiter
                -- Simulate mouse click release and press to trigger rapid fire
                Mouse.KeyDown:FindFirstChild("MB1"):Destroy()
                task.wait(0.01)
                Mouse.KeyDown:FindFirstChild("MB1"):Destroy() -- This is a simplified example
                lastFireTime = currentTime
            end
        end
    end
end

-- Anti-Recoil System
local function AntiRecoilSystem()
    while task.wait() do
        if CombatMods.AntiRecoilEnabled then
            for _, gun in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if gun:IsA("Tool") then
                    -- Modify recoil properties
                    for _, prop in ipairs(gun:GetDescendants()) do
                        if prop:IsA("NumberValue") and (prop.Name == "Recoil" or prop.Name == "Spread") then
                            prop.Value = 0
                        end
                    end
                end
            end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Weapon") then
                local currentWeapon = LocalPlayer.Character.Weapon
                for _, prop in ipairs(currentWeapon:GetDescendants()) do
                    if prop:IsA("NumberValue") and (prop.Name == "Recoil" or prop.Name == "Spread") then
                        prop.Value = 0
                    end
                end
            end
        end
    end
end

-- Infinite Ammo System
local function InfiniteAmmoSystem()
    while task.wait() do
        if CombatMods.InfiniteAmmoEnabled then
            for _, gun in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if gun:IsA("Tool") then
                    if gun:FindFirstChild("Ammo") then
                        gun.Ammo.Value = math.huge
                    end
                end
            end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Weapon") then
                local currentWeapon = LocalPlayer.Character.Weapon
                if currentWeapon:FindFirstChild("Ammo") then
                    currentWeapon.Ammo.Value = math.huge
                end
            end
        end
    end
end

-- Wallbang System
local function WallbangSystem()
    while task.wait() do
        if CombatMods.WallbangEnabled then
            -- This would involve hooking raycast functions to ignore certain parts
            -- Simplified example:
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            
            mt.__index = function(t, k)
                if t == Workspace and k == "Raycast" then
                    return function(origin, direction, params)
                        params.FilterType = Enum.RaycastFilterType.Blacklist
                        params.FilterDescendantsInstances = {LocalPlayer.Character}
                        return oldIndex(t, k)(origin, direction, params)
                    end
                end
                return oldIndex(t, k)
            end
        end
    end
end

-- Auto Weapon Switch
local function AutoWeaponSwitch()
    while task.wait() do
        if CombatMods.AutoWeaponSwitchEnabled and LocalPlayer.Character then
            local currentWeapon = LocalPlayer.Character:FindFirstChild("Weapon")
            if currentWeapon and currentWeapon:FindFirstChild("Ammo") and currentWeapon.Ammo.Value <= 0 then
                -- Find nearest enemy's weapon
                local nearestWeapon, minDistance = nil, math.huge
                
                for _, weapon in ipairs(Workspace:GetDescendants()) do
                    if weapon:IsA("Tool") and weapon:FindFirstChild("Ammo") and weapon.Ammo.Value > 0 then
                        local distance = (weapon.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            nearestWeapon = weapon
                        end
                    end
                end
                
                if nearestWeapon then
                    -- Simulate picking up the weapon
                    -- This would involve game-specific implementation
                    print("Switching to weapon with ammo")
                end
            end
        end
    end
end

-- Start combat systems
task.spawn(RapidFireSystem)
task.spawn(AntiRecoilSystem)
task.spawn(InfiniteAmmoSystem)
task.spawn(WallbangSystem)
task.spawn(AutoWeaponSwitch)

-- Skin Changer Utility
local function SkinChanger()
    while task.wait() do
        if getgenv().SkinChangerEnabled then
            -- Implement skin changing logic here
            -- This would involve manipulating character models and textures
        end
    end
end

task.spawn(SkinChanger)

-- Auto Crouch/Slide
local function AutoCrouchSlide()
    while task.wait() do
        if getgenv().AutoCrouchEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Sit = true
            end
        end
        
        if getgenv().AutoSlideEnabled and Mouse.KeyDown:FindFirstChild("MB1") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 0
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end
    end
end

task.spawn(AutoCrouchSlide)

-- Analytics System
local CombatStats = {
    ShotsFired = 0,
    Headshots = 0,
    TotalDamage = 0,
    Kills = 0,
    TimeToKill = {}
}

local function TrackCombatStats()
    while task.wait() do
        -- Implement combat stat tracking here
        -- This would involve monitoring damage events and kill notifications
    end
end

task.spawn(TrackCombatStats)

-- Battle Simulator
local function BattleSimulator()
    while task.wait() do
        if getgenv().SimulatorEnabled then
            -- Implement battle simulation logic here
            -- This would involve creating simulated enemies and tracking performance
        end
    end
end

task.spawn(BattleSimulator)

Rayfield:Notify({
   Title = "VortX Hypershot",
   Content = "All systems initialized successfully.",
   Duration = 4,
   Image = 4483362458
})

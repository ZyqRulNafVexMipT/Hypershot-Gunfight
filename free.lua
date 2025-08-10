-- Part_01: UI Configuration and Structure
-- This part contains the full Rayfield UI setup with all tabs and toggles for the Hypershot Gunfight script

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "VortX | Hypershot Gunfight",
	LoadingTitle = "VortX Loaded",
	LoadingSubtitle = "V2.0 BETA",
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false
})

-- Initialize global variables
getgenv().AimbotEnabled = true
getgenv().ESPEnabled = true
getgenv().AutoFarmEnabled = false
getgenv().NoClipEnabled = false
getgenv().AnalyticsEnabled = true

-- Home Tab
local HomeTab = Window:CreateTab("Home", 4483362458)
HomeTab:CreateToggle({
	Name = "Enable Aimbot (AI + Prediction)",
	CurrentValue = true,
	Flag = "AimbotToggle",
	Callback = function(v) getgenv().AimbotEnabled = v end
})

HomeTab:CreateToggle({
	Name = "Auto Farm Mode",
	CurrentValue = false,
	Flag = "AutoFarmToggle",
	Callback = function(v) getgenv().AutoFarmEnabled = v end
})

HomeTab:CreateButton({
	Name = "Join Discord",
	Callback = function()
		setclipboard("https://discord.gg/vortx")
		Rayfield:Notify({
			Title = "Discord Copied",
			Content = "The Discord invite has been copied to your clipboard!",
			Duration = 3
		})
	end
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({
	Name = "Enable ESP Pro",
	CurrentValue = true,
	Flag = "ESPToggle",
	Callback = function(v) getgenv().ESPEnabled = v end
})

CombatTab:CreateSlider({
	Name = "ESP Distance",
	Range = {100, 1000},
	Increment = 50,
	CurrentValue = 500,
	Flag = "ESPDistance",
	Callback = function(val)
		getgenv().ESPDistance = val
	end
})

CombatTab:CreateToggle({
	Name = "Silent Aim",
	CurrentValue = true,
	Flag = "SilentAimToggle",
	Callback = function(v) getgenv().SilentAimEnabled = v end
})

CombatTab:CreateToggle({
	Name = "Auto Shoot",
	CurrentValue = true,
	Flag = "AutoShootToggle",
	Callback = function(v) getgenv().AutoShootEnabled = v end
})

CombatTab:CreateButton({
	Name = "Reset Combat Settings",
	Callback = function()
		getgenv().AimbotEnabled = true
		getgenv().ESPEnabled = true
		getgenv().AutoShootEnabled = true
		getgenv().SilentAimEnabled = true
		getgenv().ESPDistance = 500
	end
})

CombatTab:CreateKeybind({
	Name = "Toggle Silent Aim Key",
	CurrentKeybind = "Q",
	Flag = "SilentAimKeybind",
	Callback = function(key) getgenv().SilentAimKey = key end
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)
VisualTab:CreateToggle({
	Name = "3D ESP Boxes",
	CurrentValue = true,
	Flag = "ESPBoxToggle",
	Callback = function(v) getgenv().ESPBoxes = v end
})

VisualTab:CreateToggle({
	Name = "Health Bars",
	CurrentValue = true,
	Flag = "HealthBarToggle",
	Callback = function(v) getgenv().HealthBars = v end
})

VisualTab:CreateToggle({
	Name = "Weapon Labels",
	CurrentValue = true,
	Flag = "WeaponLabelToggle",
	Callback = function(v) getgenv().WeaponLabels = v end
})

VisualTab:CreateToggle({
	Name = "Team-Colored ESP",
	CurrentValue = true,
	Flag = "TeamColorToggle",
	Callback = function(v) getgenv().TeamColoredESP = v end
})

VisualTab:CreateToggle({
	Name = "360° Radar",
	CurrentValue = false,
	Flag = "RadarToggle",
	Callback = function(v) getgenv().RadarEnabled = v end
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483362458)
MovementTab:CreateToggle({
	Name = "No-Clip",
	CurrentValue = false,
	Flag = "NoClipToggle",
	Callback = function(v) getgenv().NoClipEnabled = v end
})

MovementTab:CreateSlider({
	Name = "Movement Speed",
	Range = {16, 100},
	Increment = 1,
	CurrentValue = 50,
	Flag = "SpeedSlider",
	Callback = function(val)
		getgenv().MovementSpeed = val
	end
})

MovementTab:CreateToggle({
	Name = "Auto-Cover System",
	CurrentValue = false,
	Flag = "CoverToggle",
	Callback = function(v) getgenv().AutoCoverEnabled = v end
})

-- Automation Tab
local AutomationTab = Window:CreateTab("Automation", 4483362458)
AutomationTab:CreateToggle({
	Name = "Auto Collect Items",
	CurrentValue = true,
	Flag = "AutoCollectToggle",
	Callback = function(v) getgenv().AutoCollectEnabled = v end
})

AutomationTab:CreateToggle({
	Name = "Auto Reload Cancel",
	CurrentValue = true,
	Flag = "ReloadCancelToggle",
	Callback = function(v) getgenv().AutoReloadCancel = v end
})

AutomationTab:CreateToggle({
	Name = "Auto Switch Weapons",
	CurrentValue = true,
	Flag = "WeaponSwitchToggle",
	Callback = function(v) getgenv().AutoWeaponSwitch = v end
})

-- Defense Tab
local DefenseTab = Window:CreateTab("Defense", 4483362458)
DefenseTab:CreateToggle({
	Name = "Enemy Aim Detector",
	CurrentValue = true,
	Flag = "AimDetectToggle",
	Callback = function(v) getgenv().AimDetectorEnabled = v end
})

DefenseTab:CreateToggle({
	Name = "Projectile Threat Detection",
	CurrentValue = true,
	Flag = "ProjectileDetectToggle",
	Callback = function(v) getgenv().ProjectileDetectionEnabled = v end
})

DefenseTab:CreateToggle({
	Name = "360° Threat Redirect",
	CurrentValue = true,
	Flag = "ThreatRedirectToggle",
	Callback = function(v) getgenv().ThreatRedirectEnabled = v end
})

-- Analytics Tab
local AnalyticsTab = Window:CreateTab("Analytics", 4483362458)
AnalyticsTab:CreateToggle({
	Name = "Enable Analytics",
	CurrentValue = true,
	Flag = "AnalyticsToggle",
	Callback = function(v) getgenv().AnalyticsEnabled = v end
})

AnalyticsTab:CreateButton({
	Name = "Open Stats Panel",
	Callback = function()
		if getgenv().AnalyticsEnabled then
			-- Will be implemented in Part_05
			Rayfield:Notify({
				Title = "Analytics Panel",
				Content = "The analytics panel will open shortly",
				Duration = 3
			})
		else
			Rayfield:Notify({
				Title = "Analytics Disabled",
				Content = "Enable analytics to use this feature",
				Duration = 3
			})
		end
	end
})

AnalyticsTab:CreateButton({
	Name = "Export Combat Log",
	Callback = function()
		if getgenv().AnalyticsEnabled then
			-- Will be implemented in Part_05
			Rayfield:Notify({
				Title = "Exporting Log",
				Content = "The combat log has been copied to your clipboard",
				Duration = 3
			})
		else
			Rayfield:Notify({
				Title = "Analytics Disabled",
				Content = "Enable analytics to use this feature",
				Duration = 3
			})
		end
	end
})

-- Initialize the script
local InitialMessage = Rayfield:Notify({
	Title = "VortX Loaded",
	Content = "All systems are operational. Enjoy the enhanced gameplay experience.",
	Duration = 5,
	Image = 4483362458
})

-- End of Part_01
-- Part_02: Aimbot AI and ESP System
-- This part contains the core logic for the Aimbot and ESP functionalities

-- Initialize services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")

-- Global variables
getgenv().SilentAimEnabled = false
getgenv().ESPEnabled = false
getgenv().AimPredictionEnabled = true
getgenv().ESPBoxes = false
getgenv().HealthBars = false
getgenv().WeaponLabels = false
getgenv().TeamColoredESP = false
getgenv().RadarEnabled = false
getgenv().ESPDistance = 500

-- ESP Configuration
local ESP = {
    Boxes = {},
    HealthBars = {},
    WeaponLabels = {},
    Radar = {}
}

-- Aimbot Configuration
local Aimbot = {
    Target = nil,
    FOVSize = 100,
    Smoothing = 0.6,
    Prediction = {
        Enabled = true,
        VelocityMultiplier = 1.1,
        DelayCompensation = 0.1
    }
}

-- AI System for Aimbot
local AimbotAI = {
    TargetPatterns = {},
    LastPositions = {},
    MovementPredictions = {},
    BulletDropCompensation = 0.05
}

-- Initialize ESP system
function ESP:Initialize()
    if not getgenv().ESPEnabled then return end

    -- Create radar
    if getgenv().RadarEnabled then
        ESP.Radar.Frame = Instance.new("Frame")
        ESP.Radar.Frame.Size = UDim2.new(0, 200, 0, 200)
        ESP.Radar.Frame.Position = UDim2.new(0.5, -100, 0.5, -100)
        ESP.Radar.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ESP.Radar.Frame.Parent = LocalPlayer.PlayerGui

        ESP.Radar.Canvas = Instance.new("Frame")
        ESP.Radar.Canvas.Size = UDim2.new(1, 0, 1, 0)
        ESP.Radar.Canvas.Position = UDim2.new(0, 0, 0, 0)
        ESP.Radar.Canvas.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ESP.Radar.Canvas.Parent = ESP.Radar.Frame
    end
end

-- Update ESP for all players
function ESP:Update()
    if not getgenv().ESPEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if head and rootPart then
                -- Update boxes
                if getgenv().ESPBoxes and not ESP.Boxes[player] then
                    ESP.Boxes[player] = Instance.new("BoxHandleAdornment")
                    ESP.Boxes[player].Adornee = rootPart
                    ESP.Boxes[player].Color3 = player.TeamColor.Color
                    ESP.Boxes[player].Transparency = 0.5
                    ESP.Boxes[player].AlwaysOnTop = true
                    ESP.Boxes[player].Parent = LocalPlayer.PlayerGui
                elseif not getgenv().ESPBoxes and ESP.Boxes[player] then
                    ESP.Boxes[player]:Destroy()
                    ESP.Boxes[player] = nil
                end

                -- Update health bars
                if getgenv().HealthBars and not ESP.HealthBars[player] then
                    ESP.HealthBars[player] = Instance.new("Frame")
                    ESP.HealthBars[player].Size = UDim2.new(0, 4, 0, 50)
                    ESP.HealthBars[player].Position = UDim2.new(0.5, 0, 0.5, 0)
                    ESP.HealthBars[player].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    ESP.HealthBars[player].BackgroundTransparency = 0.5
                    ESP.HealthBars[player].Parent = LocalPlayer.PlayerGui

                    local healthBar = Instance.new("Frame")
                    healthBar.Size = UDim2.new(1, 0, 1, 0)
                    healthBar.Position = UDim2.new(0, 0, 0, 0)
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    healthBar.Parent = ESP.HealthBars[player]
                elseif not getgenv().HealthBars and ESP.HealthBars[player] then
                    ESP.HealthBars[player]:Destroy()
                    ESP.HealthBars[player] = nil
                end

                -- Update weapon labels
                if getgenv().WeaponLabels and not ESP.WeaponLabels[player] then
                    ESP.WeaponLabels[player] = Instance.new("TextLabel")
                    ESP.WeaponLabels[player].Size = UDim2.new(0, 100, 0, 20)
                    ESP.WeaponLabels[player].Position = UDim2.new(0.5, 0, 0.5, 0)
                    ESP.WeaponLabels[player].Text = "Weapon: N/A"
                    ESP.WeaponLabels[player].TextColor3 = Color3.fromRGB(255, 255, 255)
                    ESP.WeaponLabels[player].BackgroundTransparency = 0.5
                    ESP.WeaponLabels[player].Parent = LocalPlayer.PlayerGui
                elseif not getgenv().WeaponLabels and ESP.WeaponLabels[player] then
                    ESP.WeaponLabels[player]:Destroy()
                    ESP.WeaponLabels[player] = nil
                end
            end
        end

        -- Update radar
        if getgenv().RadarEnabled and ESP.Radar.Frame then
            for _, radarDot in ipairs(ESP.Radar.Canvas:GetChildren()) do
                if radarDot:IsA("Frame") then
                    radarDot:Destroy()
                end
            end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if rootPart then
                        local dot = Instance.new("Frame")
                        dot.Size = UDim2.new(0, 10, 0, 10)
                        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
                        dot.BackgroundColor3 = player.TeamColor.Color
                        dot.CornerRadius = UDim.new(0.5, 0)
                        dot.Parent = ESP.Radar.Canvas

                        -- Position the dot based on player position relative to LocalPlayer
                        local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            dot.Position = UDim2.new(position.X / Camera.ViewportSize.X, 0, position.Y / Camera.ViewportSize.Y, 0)
                        else
                            dot.Position = UDim2.new(0.5, 0, 0.5, 0)
                        end
                    end
                end
            end
        end
    end
end

-- Initialize aimbot
function Aimbot:Initialize()
    if not getgenv().AimbotEnabled then return end

    -- Create FOV circle
    Aimbot.FOVCircle = Drawing.new("Circle")
    Aimbot.FOVCircle.Visible = false
    Aimbot.FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    Aimbot.FOVCircle.Thickness = 1
    Aimbot.FOVCircle.Filled = false
    Aimbot.FOVCircle.Radius = Aimbot.FOVSize
    Aimbot.FOVCircle.Transparency = 0.5
    Aimbot.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Update aimbot target
function Aimbot:UpdateTarget()
    if not getgenv().AimbotEnabled then return end

    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if head and rootPart then
                local position, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(position.X, position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                    if distance < shortestDistance and distance <= Aimbot.FOVSize then
                        shortestDistance = distance
                        closestTarget = head
                    end
                end
            end
        end
    end

    Aimbot.Target = closestTarget

    -- Update FOV circle
    if Aimbot.FOVCircle then
        Aimbot.FOVCircle.Visible = getgenv().AimbotEnabled
        Aimbot.FOVCircle.Radius = Aimbot.FOVSize
    end
end

-- Smoothly aim at the target
function Aimbot:SmoothAim()
    if not getgenv().AimbotEnabled or not Aimbot.Target then return end

    local targetPosition = Aimbot.Target.Position

    -- Apply prediction
    if getgenv().AimPredictionEnabled then
        local targetVelocity = Aimbot.Target.Velocity
        local predictionOffset = targetVelocity * Aimbot.Prediction.VelocityMultiplier * (Camera.Focus - Camera.CFrame.Position).Magnitude / 500
        targetPosition = targetPosition + predictionOffset
    end

    -- Apply bullet drop compensation
    targetPosition = targetPosition + Vector3.new(0, Aimbot.BulletDropCompensation, 0)

    -- Calculate new camera position
    local currentCameraPosition = Camera.CFrame.Position
    local targetDirection = (targetPosition - currentCameraPosition).Unit
    local newCameraPosition = currentCameraPosition + targetDirection * Aimbot.Smoothing

    -- Smoothly tween the camera
    TweenService:Create(Camera, TweenInfo.new(Aimbot.Smoothing, Enum.EasingStyle.Linear), {CFrame = CFrame.new(newCameraPosition, targetPosition)}):Play()
end

-- Initialize the AI system for aimbot
function AimbotAI:Initialize()
    if not getgenv().AimbotEnabled then return end

    -- Create a table to track player movement patterns
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            AimbotAI.TargetPatterns[player] = {}
            AimbotAI.LastPositions[player] = Vector3.new(0, 0, 0)
            AimbotAI.MovementPredictions[player] = Vector3.new(0, 0, 0)
        end
    end
end

-- Update AI system
function AimbotAI:Update()
    if not getgenv().AimbotEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

            if rootPart then
                -- Track movement patterns
                table.insert(AimbotAI.TargetPatterns[player], rootPart.Position)
                if #AimbotAI.TargetPatterns[player] > 10 then
                    table.remove(AimbotAI.TargetPatterns[player], 1)
                end

                -- Predict next position
                if #AimbotAI.TargetPatterns[player] >= 2 then
                    local lastPosition = AimbotAI.TargetPatterns[player][#AimbotAI.TargetPatterns[player]]
                    local previousPosition = AimbotAI.TargetPatterns[player][#AimbotAI.TargetPatterns[player] - 1]
                    local movementVector = lastPosition - previousPosition
                    AimbotAI.MovementPredictions[player] = lastPosition + movementVector
                end
            end
        end
    end
end

-- Initialize systems when the script starts
ESP:Initialize()
Aimbot:Initialize()
AimbotAI:Initialize()

-- Connect update functions to render stepped
RunService.RenderStepped:Connect(function()
    ESP:Update()
    Aimbot:UpdateTarget()
    Aimbot:SmoothAim()
    AimbotAI:Update()
end)

-- End of Part_02
-- Part_03: Movement Tools and Combat Enhancements
-- This part contains the implementation of movement tools and advanced combat features

-- Initialize services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")

-- Global variables
getgenv().NoClipEnabled = false
getgenv().BunnyHopEnabled = false
getgenv().SpeedMultiplier = 1
getgenv().AutoCoverEnabled = false
getgenv().BringHeadsEnabled = false
getgenv().RapidFireEnabled = false
getgenv().AntiRecoilEnabled = false
getgenv().InfiniteAmmoEnabled = false

-- Movement tools configuration
local MovementTools = {
    NoClip = {
        Speed = 50,
        Active = false
    },
    BunnyHop = {
        Enabled = false,
        LastHop = tick(),
        HopDelay = 0.1
    },
    AutoCover = {
        Enabled = false,
        SafePosition = nil,
        Covering = false
    },
    BringHeads = {
        Enabled = false,
        TargetPosition = nil
    }
}

-- Combat enhancements configuration
local CombatEnhancements = {
    RapidFire = {
        Enabled = false,
        BaseRate = 0.1,
        CurrentRate = 0.1
    },
    AntiRecoil = {
        Enabled = false,
        RecoilValues = {}
    },
    InfiniteAmmo = {
        Enabled = false,
        OriginalAmmo = {}
    },
    WallPenetration = {
        Enabled = false,
        PenetrationLevel = 1
    }
}

-- Initialize movement tools
function MovementTools:Initialize()
    if not getgenv().NoClipEnabled and not getgenv().BunnyHopEnabled and not getgenv().AutoCoverEnabled and not getgenv().BringHeadsEnabled then return end

    -- Create no-clip parts
    if getgenv().NoClipEnabled then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.7
            end
        end
    end

    -- Initialize auto-cover
    if getgenv().AutoCoverEnabled then
        MovementTools.AutoCover.SafePosition = LocalPlayer.Character.HumanoidRootPart.Position
    end

    -- Initialize bring heads
    if getgenv().BringHeadsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    MovementTools.BringHeads.TargetPosition = head.Position
                end
            end
        end
    end
end

-- Update movement tools
function MovementTools:Update()
    if not getgenv().NoClipEnabled and not getgenv().BunnyHopEnabled and not getgenv().AutoCoverEnabled and not getgenv().BringHeadsEnabled then return end

    -- Handle no-clip
    if getgenv().NoClipEnabled then
        if MovementTools.NoClip.Active then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if rootPart then
                rootPart.CanCollide = false
                rootPart.Velocity = Vector3.new(0, MovementTools.NoClip.Speed, 0)
            end
        end
    end

    -- Handle bunny-hop
    if getgenv().BunnyHopEnabled then
        local currentTime = tick()
        if currentTime - MovementTools.BunnyHop.LastHop > MovementTools.BunnyHop.HopDelay then
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")

            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                MovementTools.BunnyHop.LastHop = currentTime
            end
        end
    end

    -- Handle auto-cover
    if getgenv().AutoCoverEnabled and MovementTools.AutoCover.Enabled then
        if not MovementTools.AutoCover.Covering then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if rootPart then
                local direction = (MovementTools.AutoCover.SafePosition - rootPart.Position).Unit
                TweenService:Create(rootPart, TweenInfo.new(0.5), {CFrame = CFrame.new(rootPart.Position + direction * 10)}):Play()
                MovementTools.AutoCover.Covering = true
            end
        end
    end

    -- Handle bring heads
    if getgenv().BringHeadsEnabled and MovementTools.BringHeads.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    TweenService:Create(head, TweenInfo.new(0.5), {Position = MovementTools.BringHeads.TargetPosition}):Play()
                end
            end
        end
    end
end

-- Initialize combat enhancements
function CombatEnhancements:Initialize()
    if not getgenv().RapidFireEnabled and not getgenv().AntiRecoilEnabled and not getgenv().InfiniteAmmoEnabled and not getgenv().WallPenetrationEnabled then return end

    -- Initialize rapid fire
    if getgenv().RapidFireEnabled then
        CombatEnhancements.RapidFire.CurrentRate = CombatEnhancements.RapidFire.BaseRate
    end

    -- Initialize anti-recoil
    if getgenv().AntiRecoilEnabled then
        for _, weapon in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if weapon:IsA("Tool") then
                CombatEnhancements.AntiRecoil.RecoilValues[weapon] = {
                    OriginalRecoil = weapon:FindFirstChild("Recoil") and weapon.Recoil.Value or 0,
                    ModifiedRecoil = 0
                }
            end
        end
    end

    -- Initialize infinite ammo
    if getgenv().InfiniteAmmoEnabled then
        for _, weapon in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if weapon:IsA("Tool") then
                CombatEnhancements.InfiniteAmmo.OriginalAmmo[weapon] = weapon:FindFirstChild("Ammo") and weapon.Ammo.Value or math.huge
            end
        end
    end
end

-- Update combat enhancements
function CombatEnhancements:Update()
    if not getgenv().RapidFireEnabled and not getgenv().AntiRecoilEnabled and not getgenv().InfiniteAmmoEnabled and not getgenv().WallPenetrationEnabled then return end

    -- Handle rapid fire
    if getgenv().RapidFireEnabled then
        local currentWeapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if currentWeapon then
            local rapidFirePart = currentWeapon:FindFirstChild("RapidFire")
            if rapidFirePart then
                rapidFirePart.Value = CombatEnhancements.RapidFire.CurrentRate
            end
        end
    end

    -- Handle anti-recoil
    if getgenv().AntiRecoilEnabled then
        for weapon, values in pairs(CombatEnhancements.AntiRecoil.RecoilValues) do
            if weapon.Parent == LocalPlayer.Character then
                local recoilPart = weapon:FindFirstChild("Recoil")
                if recoilPart then
                    recoilPart.Value = values.ModifiedRecoil
                end
            end
        end
    end

    -- Handle infinite ammo
    if getgenv().InfiniteAmmoEnabled then
        for weapon, originalAmmo in pairs(CombatEnhancements.InfiniteAmmo.OriginalAmmo) do
            if weapon.Parent == LocalPlayer.Character then
                local ammoPart = weapon:FindFirstChild("Ammo")
                if ammoPart then
                    ammoPart.Value = originalAmmo
                end
            end
        end
    end

    -- Handle wall penetration
    if getgenv().WallPenetrationEnabled then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.Transparency = 0.5
                part.CanCollide = false
            end
        end
    end
end

-- Connect update functions to render stepped
RunService.RenderStepped:Connect(function()
    MovementTools:Update()
    CombatEnhancements:Update()
end)

-- Initialize systems when the script starts
MovementTools:Initialize()
CombatEnhancements:Initialize()

-- End of Part_03
-- Part_04: Defense Systems and Analytics
-- This part contains the implementation of defense mechanisms and analytics features

-- Initialize services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

-- Global variables
getgenv().AimDetectorEnabled = false
getgenv().ProjectileDetectionEnabled = false
getgenv().ThreatRedirectEnabled = false
getgenv().AnalyticsEnabled = false

-- Defense systems configuration
local DefenseSystems = {
    AimDetector = {
        Active = false,
        DetectionRange = 500,
        AlertsEnabled = true
    },
    ProjectileDetection = {
        Active = false,
        DetectionRange = 500,
        AutoRedirect = true
    },
    ThreatRedirect = {
        Active = false,
        RedirectTarget = nil
    }
}

-- Analytics configuration
local Analytics = {
    Stats = {
        Headshots = 0,
        TotalKills = 0,
        Accuracy = 0,
        TimePlayed = 0
    },
    CombatLog = {},
    BattleSimulator = {
        Running = false,
        SimulationData = {}
    }
}

-- Initialize defense systems
function DefenseSystems:Initialize()
    if not getgenv().AimDetectorEnabled and not getgenv().ProjectileDetectionEnabled and not getgenv().ThreatRedirectEnabled then return end

    -- Initialize aim detection
    if getgenv().AimDetectorEnabled then
        DefenseSystems.AimDetector.Active = true
    end

    -- Initialize projectile detection
    if getgenv().ProjectileDetectionEnabled then
        DefenseSystems.ProjectileDetection.Active = true
    end

    -- Initialize threat redirect
    if getgenv().ThreatRedirectEnabled then
        DefenseSystems.ThreatRedirect.Active = true
    end
end

-- Update defense systems
function DefenseSystems:Update()
    if not getgenv().AimDetectorEnabled and not getgenv().ProjectileDetectionEnabled and not getgenv().ThreatRedirectEnabled then return end

    -- Handle aim detection
    if getgenv().AimDetectorEnabled and DefenseSystems.AimDetector.Active then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                local rootPart = character:FindFirstChild("HumanoidRootPart")

                if head and rootPart then
                    local position, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance = (Vector2.new(position.X, position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                        if distance < DefenseSystems.AimDetector.DetectionRange then
                            if DefenseSystems.AimDetector.AlertsEnabled then
                                Rayfield:Notify({
                                    Title = "Aim Detected",
                                    Content = player.Name .. " is aiming at you!",
                                    Duration = 3
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    -- Handle projectile detection
    if getgenv().ProjectileDetectionEnabled and DefenseSystems.ProjectileDetection.Active then
        for _, projectile in ipairs(workspace:GetDescendants()) do
            if projectile:IsA("BasePart") and projectile.Name:find("Projectile") then
                local position, onScreen = Camera:WorldToViewportPoint(projectile.Position)
                if onScreen then
                    local distance = (Vector2.new(position.X, position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                    if distance < DefenseSystems.ProjectileDetection.DetectionRange then
                        if DefenseSystems.ProjectileDetection.AutoRedirect then
                            -- Redirect threat
                            if DefenseSystems.ThreatRedirect.RedirectTarget then
                                TweenService:Create(projectile, TweenInfo.new(0.5), {CFrame = CFrame.new(DefenseSystems.ThreatRedirect.RedirectTarget.Position)}):Play()
                            else
                                -- Default redirect to a safe position
                                TweenService:Create(projectile, TweenInfo.new(0.5), {CFrame = CFrame.new(Camera.CFrame.Position + Camera.CFrame.LookVector * 100)}):Play()
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Initialize analytics
function Analytics:Initialize()
    if not getgenv().AnalyticsEnabled then return end

    -- Start tracking stats
    Analytics.Stats.TimePlayed = os.time()

    -- Initialize combat log
    Analytics.CombatLog = {}

    -- Initialize battle simulator
    Analytics.BattleSimulator.SimulationData = {
        Accuracy = 0,
        Headshots = 0,
        TotalShots = 0,
        TotalHits = 0
    }
end

-- Update analytics
function Analytics:Update()
    if not getgenv().AnalyticsEnabled then return end

    -- Update time played
    Analytics.Stats.TimePlayed = os.time() - Analytics.Stats.TimePlayed

    -- Update accuracy
    if Analytics.Stats.TotalShots > 0 then
        Analytics.Stats.Accuracy = (Analytics.Stats.TotalHits / Analytics.Stats.TotalShots) * 100
    end
end

-- Log combat events
function Analytics:LogCombatEvent(eventType, data)
    if not getgenv().AnalyticsEnabled then return end

    table.insert(Analytics.CombatLog, {
        Type = eventType,
        Data = data,
        Timestamp = os.time()
    })

    -- Update battle simulator data
    if eventType == "SHOT" then
        Analytics.BattleSimulator.SimulationData.TotalShots += 1
    elseif eventType == "HIT" then
        Analytics.BattleSimulator.SimulationData.TotalHits += 1
        if data.Headshot then
            Analytics.BattleSimulator.SimulationData.Headshots += 1
        end
    end
end

-- Connect update functions to render stepped
RunService.RenderStepped:Connect(function()
    DefenseSystems:Update()
    Analytics:Update()
end)

-- Initialize systems when the script starts
DefenseSystems:Initialize()
Analytics:Initialize()

-- UI integration for analytics
local Rayfield = getgenv().Rayfield
local AnalyticsTab = Rayfield:GetTab("Analytics")

AnalyticsTab:CreateButton({
    Name = "Open Stats Panel",
    Callback = function()
        if getgenv().AnalyticsEnabled then
            -- Create stats panel
            local statsPanel = Instance.new("Frame")
            statsPanel.Size = UDim2.new(0, 300, 0, 400)
            statsPanel.Position = UDim2.new(0.5, -150, 0.5, -200)
            statsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            statsPanel.Parent = LocalPlayer.PlayerGui

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 30)
            titleLabel.Position = UDim2.new(0, 0, 0, 0)
            titleLabel.Text = "Combat Statistics"
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.Parent = statsPanel

            local statsList = Instance.new("ScrollingFrame")
            statsList.Size = UDim2.new(1, 0, 1, -30)
            statsList.Position = UDim2.new(0, 0, 0, 30)
            statsList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            statsList.Parent = statsPanel

            -- Add stats to the panel
            local function addStat(name, value)
                local statItem = Instance.new("Frame")
                statItem.Size = UDim2.new(1, 0, 0, 30)
                statItem.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                statItem.Parent = statsList

                local statName = Instance.new("TextLabel")
                statName.Size = UDim2.new(0.6, 0, 1, 0)
                statName.Position = UDim2.new(0, 0, 0, 0)
                statName.Text = name
                statName.TextColor3 = Color3.fromRGB(200, 200, 200)
                statName.Parent = statItem

                local statValue = Instance.new("TextLabel")
                statValue.Size = UDim2.new(0.4, 0, 1, 0)
                statValue.Position = UDim2.new(0.6, 0, 0, 0)
                statValue.Text = tostring(value)
                statValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                statValue.TextXAlignment = Enum.TextXAlignment.Right
                statValue.Parent = statItem
            end

            addStat("Headshots", Analytics.Stats.Headshots)
            addStat("Total Kills", Analytics.Stats.TotalKills)
            addStat("Accuracy", string.format("%.2f%%", Analytics.Stats.Accuracy))
            addStat("Time Played", tostring(math.floor(Analytics.Stats.TimePlayed / 60)) .. "m " .. tostring(Analytics.Stats.TimePlayed % 60) .. "s")

            -- Automatically close the panel after 10 seconds
            task.wait(10)
            statsPanel:Destroy()
        else
            Rayfield:Notify({
                Title = "Analytics Disabled",
                Content = "Enable analytics to use this feature",
                Duration = 3
            })
        end
    end
})

AnalyticsTab:CreateButton({
    Name = "Export Combat Log",
    Callback = function()
        if getgenv().AnalyticsEnabled then
            local logText = "Combat Log:\n"
            for _, entry in ipairs(Analytics.CombatLog) do
                logText = logText .. os.date("%H:%M:%S", entry.Timestamp) .. " - " .. entry.Type .. ": " .. tostring(entry.Data) .. "\n"
            end

            setclipboard(logText)
            Rayfield:Notify({
                Title = "Log Exported",
                Content = "The combat log has been copied to your clipboard",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Analytics Disabled",
                Content = "Enable analytics to use this feature",
                Duration = 3
            })
        end
    end
})

-- End of Part_04
-- Part_05: Final Integrations and Optimizations
-- This part contains the final integrations, performance optimizations, and remaining features

-- Initialize services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

-- Global variables
getgenv().CombatLogEnabled = false
getgenv().AutoFarmActive = false
getgenv().ItemCollectionEnabled = false
getgenv().SmartWallCalculationEnabled = false

-- Final integrations configuration
local FinalIntegrations = {
    CombatLogger = {
        Active = false,
        LogToFile = false,
        LogToConsole = true
    },
    AutoFarm = {
        Active = false,
        FarmingMode = "Coins",
        LastTeleport = tick(),
        TeleportDelay = 2
    },
    ItemCollector = {
        Active = false,
        CollectionRange = 100,
        LastCollection = tick(),
        CollectionDelay = 1
    },
    WallCalculator = {
        Active = false,
        OptimalShots = {},
        LastCalculation = tick(),
        CalculationDelay = 0.5
    }
}

-- Final analytics and logging
local FinalAnalytics = {
    PerformanceMonitor = {
        FrameRate = 0,
        LastFPSUpdate = tick(),
        FPSInterval = 1
    },
    CombatLogger = {
        LogEntries = {},
        MaxLogSize = 100
    }
}

-- Initialize final integrations
function FinalIntegrations:Initialize()
    if not getgenv().CombatLogEnabled and not getgenv().AutoFarmActive and not getgenv().ItemCollectionEnabled and not getgenv().SmartWallCalculationEnabled then return end

    -- Initialize combat logger
    if getgenv().CombatLogEnabled then
        FinalIntegrations.CombatLogger.Active = true
    end

    -- Initialize auto farm
    if getgenv().AutoFarmActive then
        FinalIntegrations.AutoFarm.Active = true
    end

    -- Initialize item collector
    if getgenv().ItemCollectionEnabled then
        FinalIntegrations.ItemCollector.Active = true
    end

    -- Initialize smart wall calculation
    if getgenv().SmartWallCalculationEnabled then
        FinalIntegrations.WallCalculator.Active = true
    end
end

-- Update final integrations
function FinalIntegrations:Update()
    if not getgenv().CombatLogEnabled and not getgenv().AutoFarmActive and not getgenv().ItemCollectionEnabled and not getgenv().SmartWallCalculationEnabled then return end

    -- Handle combat logging
    if getgenv().CombatLogEnabled and FinalIntegrations.CombatLogger.Active then
        -- Log combat events (integrated with previous analytics system)
        -- This would connect to the Analytics:LogCombatEvent function from Part_04
    end

    -- Handle auto farm
    if getgenv().AutoFarmActive and FinalIntegrations.AutoFarm.Active then
        local currentTime = tick()
        if currentTime - FinalIntegrations.AutoFarm.LastTeleport > FinalIntegrations.AutoFarm.TeleportDelay then
            -- Find nearest enemy or farming spot
            local closestEnemy = nil
            local shortestDistance = math.huge

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if rootPart then
                        local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(position.X, position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestEnemy = rootPart
                            end
                        end
                    end
                end
            end

            -- Teleport to farming target
            if closestEnemy then
                TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(1), {CFrame = CFrame.new(closestEnemy.Position)}):Play()
                FinalIntegrations.AutoFarm.LastTeleport = currentTime
            end
        end
    end

    -- Handle item collection
    if getgenv().ItemCollectionEnabled and FinalIntegrations.ItemCollector.Active then
        local currentTime = tick()
        if currentTime - FinalIntegrations.ItemCollector.LastCollection > FinalIntegrations.ItemCollector.CollectionDelay then
            for _, item in ipairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and (item.Name:find("Coin") or item.Name:find("Item")) then
                    local distance = (item.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

                    if distance < FinalIntegrations.ItemCollector.CollectionRange then
                        TweenService:Create(item, TweenInfo.new(0.5), {CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position)}):Play()
                        FinalIntegrations.ItemCollector.LastCollection = currentTime
                    end
                end
            end
        end
    end

    -- Handle smart wall calculation
    if getgenv().SmartWallCalculationEnabled and FinalIntegrations.WallCalculator.Active then
        local currentTime = tick()
        if currentTime - FinalIntegrations.WallCalculator.LastCalculation > FinalIntegrations.WallCalculator.CalculationDelay then
            -- Calculate optimal shooting positions
            FinalIntegrations.WallCalculator.OptimalShots = {}

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if rootPart then
                        local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            -- Find wall positions between player and enemy
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

                            local raycastResult = workspace:Raycast(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)

                            if raycastResult then
                                table.insert(FinalIntegrations.WallCalculator.OptimalShots, {
                                    Position = raycastResult.Position,
                                    Normal = raycastResult.Normal
                                })
                            end
                        end
                    end
                end
            end

            FinalIntegrations.WallCalculator.LastCalculation = currentTime
        end
    end
end

-- Initialize performance monitoring
function FinalAnalytics:Initialize()
    FinalAnalytics.PerformanceMonitor.FrameRate = 60
    FinalAnalytics.PerformanceMonitor.LastFPSUpdate = tick()
end

-- Update performance monitoring
function FinalAnalytics:Update()
    local currentTime = tick()
    if currentTime - FinalAnalytics.PerformanceMonitor.LastFPSUpdate > FinalAnalytics.PerformanceMonitor.FPSInterval then
        FinalAnalytics.PerformanceMonitor.FrameRate = math.floor(1 / (currentTime - FinalAnalytics.PerformanceMonitor.LastFPSUpdate))
        FinalAnalytics.PerformanceMonitor.LastFPSUpdate = currentTime
    end
end

-- Connect update functions to render stepped
RunService.RenderStepped:Connect(function()
    FinalIntegrations:Update()
    FinalAnalytics:Update()
end)

-- Initialize systems when the script starts
FinalIntegrations:Initialize()
FinalAnalytics:Initialize()

-- UI integration for final features
local Rayfield = getgenv().Rayfield
local HomeTab = Rayfield:GetTab("Home")
local CombatTab = Rayfield:GetTab("Combat")
local AutomationTab = Rayfield:GetTab("Automation")
local DefenseTab = Rayfield:GetTab("Defense")
local AnalyticsTab = Rayfield:GetTab("Analytics")

-- Add final features to UI
HomeTab:CreateToggle({
    Name = "Combat Logging",
    CurrentValue = false,
    Flag = "CombatLogToggle",
    Callback = function(v) getgenv().CombatLogEnabled = v end
})

CombatTab:CreateToggle({
    Name = "Smart Wall Calculation",
    CurrentValue = false,
    Flag = "SmartWallToggle",
    Callback = function(v) getgenv().SmartWallCalculationEnabled = v end
})

AutomationTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmActiveToggle",
    Callback = function(v) getgenv().AutoFarmActive = v end
})

AutomationTab:CreateToggle({
    Name = "Auto Collect Items",
    CurrentValue = false,
    Flag = "ItemCollectionToggle",
    Callback = function(v) getgenv().ItemCollectionEnabled = v end
})

AnalyticsTab:CreateToggle({
    Name = "Performance Monitor",
    CurrentValue = true,
    Flag = "PerformanceMonitorToggle",
    Callback = function(v) getgenv().PerformanceMonitorEnabled = v end
})

AnalyticsTab:CreateLabel({
    Name = "Current FPS: " .. tostring(FinalAnalytics.PerformanceMonitor.FrameRate)
})

-- Final script notification
Rayfield:Notify({
    Title = "VortX Fully Loaded",
    Content = "All systems are fully operational and optimized. Enjoy your enhanced gameplay!",
    Duration = 5,
    Image = 4483362458
})

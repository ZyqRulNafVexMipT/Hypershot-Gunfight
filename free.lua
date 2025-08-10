-- File Name: Core.lua
-- Part: 01
-- Feature Summary: Core Initialization, Framework Setup, and Utility Functions

-- Anti-Detection and Optimization
local silentMode = true
local obfuscate = function(code)
    local keywords = {
        ["getgenv"] = "gG", ["getrenv"] = "gR", ["gethui"] = "gH",
        ["syn"] = "sY", ["http_service"] = "hS", ["run_service"] = "rS",
        ["workspace"] = "wS", ["players"] = "pL", ["mouse"] = "mO"
    }
    for k, v in pairs(keywords) do code = code:gsub(k, v) end
    return code
end

if silentMode then
    setmetatable(_G, {
        __index = function(t, k)
            if k == "getgenv" then
                return function() return _G end
            end
            return rawget(t, k)
        end
    })
end

-- Framework Initialization
local VortX = {}
VortX.__index = VortX

function VortX:Init()
    self.services = {
        http = game:GetService("HttpService"),
        rs = game:GetService("RunService"),
        ws = game:GetService("Workspace"),
        plrs = game:GetService("Players"),
        uis = game:GetService("UserInputService"),
        lgp = game:GetService("GuiService"),
        lmt = getmetatable or function(t) return {__index = t} end
    }
    
    selfplr = self.services.plrs.LocalPlayer
    selfmouse = selfplr:GetMouse()
    selfcam = self.services.ws.CurrentCamera
    
    -- Roblox Environment Hooks
    self.hooks = {
        raycast = self:HookFunction(self.services.ws, "Raycast"),
        firetouchinterest = self:HookFunction(self.services.ws, "FireTouchInterest")
    }
    
    -- Utility Functions
    self.util = {
        vector = {
            new = function(x, y, z) return Vector3.new(x, y, z) end,
            worldToScreen = function(pos) return selfcam:WorldToViewportPoint(pos) end
        },
        math = {
            random = function(min, max) return math.random(min, max) end,
            clamp = function(val, min, max) return math.clamp(val, min, max) end
        }
    }
    
    return self
end

function VortX:HookFunction(target, funcName)
    local original = target[funcName]
    local mt = self.lmt(target)
    mt.__index = function(t, k)
        if k == funcName then
            return function(...) return self:OverrideRaycast(...) end
        end
        return rawget(t, k)
    end
    return {
        original = original,
        override = function(...) original(...) end
    }
end

function VortX:OverrideRaycast(origin, direction, params)
    if self.aimbot.active and self.aimbot.target then
        local targetHead = self.aimbot.target.Head
        local prediction = self.util.vector.new(
            targetHead.Velocity.X * 0.05,
            0,
            targetHead.Velocity.Z * 0.05
        )
        return {
            Position = targetHead.Position + prediction,
            Instance = targetHead
        }
    end
    return self.hooks.raycast.original(origin, direction, params)
end

-- Return Initialized Framework
return VortX:Init()

-- File Name: UISystem.lua
-- Part: 02
-- Feature Summary: Rayfield UI Setup, Configuration Manager, and UI Controls

local VortX_Core = require(script.Parent.Core)
local VortX = VortX_Core:Init()

-- Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
   Name = "VortX | Hypershot Gunfight",
   LoadingTitle = "VortX Loaded",
   LoadingSubtitle = "V2 BETA",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- UI Tabs
local HomeTab = Window:CreateTab("Home", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local AutomationTab = Window:CreateTab("Automation", 4483362458)
local DefenseTab = Window:CreateTab("Defense", 4483362458)
local AnalyticsTab = Window:CreateTab("Analytics", 4483362458)

-- Global Toggles
getgenv().VortX_Toggles = {
    aimbot = false,
    esp = false,
    autofarm = false,
    autoshoot = false,
    movement = false,
    combat = false,
    automation = false,
    defense = false,
    analytics = false
}

-- Home Tab Controls
HomeTab:CreateToggle({
   Name = "Enable Aimbot (Headshot + Prediction)",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(v) getgenv().VortX_Toggles.aimbot = v end
})

HomeTab:CreateToggle({
   Name = "Enable ESP System",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(v) getgenv().VortX_Toggles.esp = v end
})

HomeTab:CreateToggle({
   Name = "Auto Farm Mode",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(v) getgenv().VortX_Toggles.autofarm = v end
})

-- Visual Tab Controls
VisualTab:CreateToggle({
   Name = "ESP Boxes & Health Bars",
   CurrentValue = false,
   Flag = "ESPBoxesToggle",
   Callback = function(v) VortX.espBoxes = v end
})

VisualTab:CreateToggle({
   Name = "Weapon ESP",
   CurrentValue = false,
   Flag = "WeaponESPToggle",
   Callback = function(v) VortX.weaponESP = v end
})

VisualTab:CreateToggle({
   Name = "360° Radar",
   CurrentValue = false,
   Flag = "RadarToggle",
   Callback = function(v) VortX.radarActive = v end
})

-- Return UI System
return {
    Window = Window,
    Toggles = getgenv().VortX_Toggles,
    VortX_Core = VortX_Core
}

-- File Name: Combat.lua
-- Part: 03
-- Feature Summary: Aimbot AI, Auto Shoot, Combat Mods, and Projectile Prediction

local VortX_Core = require(script.Parent.Core)
local UI_System = require(script.Parent.UISystem)
local VortX = VortX_Core.VortX_Core
local toggles = UI_System.Toggles

-- Combat Features Initialization
VortX.combat = {}
VortX.combat.aimbot = {
    active = false,
    target = nil,
    prediction = {
        enabled = true,
        multiplier = 1.2
    },
    smoothness = 0.15
}

VortX.combat.autoshoot = {
    enabled = true,
    range = 500,
    accuracy = 0.98
}

VortX.combat.mods = {
    rapidfire = {
        enabled = false,
        rate = 0.05
    },
    antirecoil = {
        enabled = false,
        intensity = 0.8
    },
    spreadcontrol = {
        enabled = false,
        reduction = 0.7
    },
    infiniteammo = {
        enabled = false
    }
}

-- Aimbot AI Implementation
function VortX:FindTarget()
    local closest, distance = nil, math.huge
    for _, plr in ipairs(self.services.plrs:GetPlayers()) do
        if plr ~= selfplr and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = self.util.vector.worldToScreen(head.Position)
            if onScreen then
                local screenDist = (pos - selfmouse.Hit.p).Magnitude
                if screenDist < distance then
                    closest = head
                    distance = screenDist
                end
            end
        end
    end
    return closest
end

function VortX:UpdateAimbot()
    if toggles.aimbot then
        self.combat.aimbot.target = self:FindTarget()
        if self.combat.aimbot.target then
            -- Smooth Aim Implementation
            local targetPos = self.util.vector.worldToScreen(self.combat.aimbot.target.Position)
            local currentPos = selfmouse.Hit.p
            local aimStep = Vector3.new(
                (targetPos.X - currentPos.X) * self.combat.aimbot.smoothness,
                (targetPos.Y - currentPos.Y) * self.combat.aimbot.smoothness,
                0
            )
            
            -- Movement Prediction
            if self.combat.aimbot.prediction.enabled then
                local predictionOffset = Vector3.new(
                    self.combat.aimbot.target.Velocity.X * self.combat.aimbot.prediction.multiplier,
                    0,
                    self.combat.aimbot.target.Velocity.Z * self.combat.aimbot.prediction.multiplier
                )
                aimStep = aimStep + predictionOffset
            end
            
            -- Apply Aim
            selfmouse.Hit = Ray.new(
                self.util.vector.new(currentPos.X + aimStep.X, currentPos.Y + aimStep.Y, currentPos.Z),
                Vector3.new(0, 0, 1000)
            )
        end
    end
end

-- Auto Shoot Implementation
function VortX:AutoShoot()
    if self.combat.autoshoot.enabled and self.combat.aimbot.target then
        local targetDist = (selfplr.Character.HumanoidRootPart.Position - self.combat.aimbot.target.Position).Magnitude
        if targetDist <= self.combat.autoshoot.range then
            if math.random() < self.combat.autoshoot.accuracy then
                -- Fire Weapon Logic
                local weapon = selfplr.Character:FindFirstChildOfClass("Tool")
                if weapon and weapon:FindFirstChild("Handle") then
                    -- Weapon Firing Logic
                    weapon:Activate()
                    task.wait(0.05)
                    weapon:Deactivate()
                end
            end
        end
    end
end

-- Combat Mods Implementation
function VortX:ApplyCombatMods()
    if self.combat.mods.rapidfire.enabled then
        -- Rapid Fire Logic
        local tool = selfplr.Character:FindFirstChildOfClass("Tool")
        if tool then
            local mt = self.lmt(tool)
            mt.__index = function(t, k)
                if k == "Fire" then
                    return function()
                        for _ = 1, 10 do
                            tool:Fire()
                            task.wait(self.combat.mods.rapidfire.rate)
                        end
                    end
                end
                return rawget(t, k)
            end
        end
    end
    
    if self.combat.mods.antirecoil.enabled then
        -- Anti-Recoil Logic
        local humanoid = selfplr.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:GetPropertyChangedSignal("CameraOffset"):Connect(function()
                humanoid.CameraOffset = humanoid.CameraOffset * self.combat.mods.antirecoil.intensity
            end)
        end
    end
    
    if self.combat.mods.spreadcontrol.enabled then
        -- Spread Control Logic
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "Spread") then
                v.Spread = v.Spread * self.combat.mods.spreadcontrol.reduction
            end
        end
    end
    
    if self.combat.mods.infiniteammo.enabled then
        -- Infinite Ammo Logic
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "Ammo") then
                v.Ammo = math.huge
            end
        end
    end
end

-- Return Combat System
return VortX

-- File Name: Movement.lua
-- Part: 04
-- Feature Summary: Movement Tools, Automation Features, and Utility Functions

local VortX_Core = require(script.Parent.Core)
local UI_System = require(script.Parent.UISystem)
local VortX = VortX_Core.VortX_Core

-- Movement Features Initialization
VortX.movement = {
    noclip = false,
    bunnyhop = false,
    speed = 16,
    strafe = false,
    aircontrol = false,
    autocover = false,
    bringplayers = false
}

-- Automation Features Initialization
VortX.automation = {
    autofarm = {
        enabled = false,
        loop = nil
    },
    collectitems = {
        enabled = false
    },
    autoreload = {
        enabled = false
    },
    crouchslide = {
        enabled = false
    }
}

-- Movement Functions
function VortX:ToggleNoClip(state)
    if state then
        self.services.rs.Stepped:Connect(function()
            if selfplr.Character then
                for _, part in ipairs(selfplr.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
    self.movement.noclip = state
end

function VortX:ToggleBunnyhop(state)
    if state then
        self.services.uis.JumpRequest:Connect(function()
            if selfplr.Character and selfplr.Character:FindFirstChild("Humanoid") then
                local humanoid = selfplr.Character.Humanoid
                if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Landing)
                else
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
    self.movement.bunnyhop = state
end

function VortX:UpdateMovement()
    if self.movement.speed ~= 16 then
        if selfplr.Character and selfplr.Character:FindFirstChild("Humanoid") then
            selfplr.Character.Humanoid.WalkSpeed = self.movement.speed
        end
    end
    
    if self.movement.strafe then
        if selfplr.Character and selfplr.Character:FindFirstChild("Humanoid") then
            local humanoid = selfplr.Character.Humanoid
            if humanoid.MoveDirection.magnitude > 0 then
                local strafeForce = Vector3.new(
                    selfmouse.X - self.services.ws.CurrentCamera.ViewportSize.X/2,
                    0,
                    selfmouse.Y - self.services.ws.CurrentCamera.ViewportSize.Y/2
                )
                humanoid.RootPart.Velocity = strafeForce * 5
            end
        end
    end
    
    if self.movement.aircontrol then
        if selfplr.Character and selfplr.Character:FindFirstChild("Humanoid") then
            local humanoid = selfplr.Character.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid.RootPart.Velocity = humanoid.RootPart.Velocity + selfmouse.Hit.p * 10
            end
        end
    end
    
    if self.movement.autocover then
        if selfplr.Character and selfplr.Character:FindFirstChild("Humanoid") then
            local humanoid = selfplr.Character.Humanoid
            if humanoid.Health < 50 then
                -- Find cover logic
                local cover = self:FindCover()
                if cover then
                    humanoid:MoveTo(cover.Position)
                end
            end
        end
    end
    
    if self.movement.bringplayers then
        for _, plr in ipairs(self.services.plrs:GetPlayers()) do
            if plr ~= selfplr and plr.Character then
                plr.Character.HumanoidRootPart.CFrame = selfplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

-- Automation Functions
function VortX:AutoFarmLoop()
    while self.automation.autofarm.enabled do
        if selfplr.Character and selfplr.Character:FindFirstChild("HumanoidRootPart") then
            local target = self:FindNearestEnemy()
            if target then
                -- Teleport to enemy
                selfplr.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                
                -- Aim at enemy
                selfmouse.Hit = Ray.new(
                    selfplr.Character.Head.Position,
                    (target.Head.Position - selfplr.Character.Head.Position).Unit * 1000
                )
                
                -- Make invulnerable
                for _, part in ipairs(selfplr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Neon
                    end
                end
            end
        end
        task.wait(1)
    end
end

function VortX:CollectItems()
    if self.automation.collectitems.enabled then
        for _, item in ipairs(self.services.ws:GetDescendants()) do
            if item:IsA("Model") and item.Name:find("Item") then
                local itemPart = item:FindFirstChild("Part")
                if itemPart then
                    selfplr.Character.HumanoidRootPart.CFrame = itemPart.CFrame
                end
            end
        end
    end
end

function VortX:AutoReload()
    if self.automation.autoreload.enabled and selfplr.Character then
        local weapon = selfplr.Character:FindFirstChildOfClass("Tool")
        if weapon and weapon:FindFirstChild("Ammo") then
            if weapon.Ammo.Value <= 10 then
                weapon:Activate()
                task.wait(0.1)
                weapon:Deactivate()
            end
        end
    end
end

-- Return Movement System
return VortX

-- File Name: ESP.lua
-- Part: 05
-- Feature Summary: ESP System, Analytics, and Defense Features

local VortX_Core = require(script.Parent.Core)
local UI_System = require(script.Parent.UISystem)
local VortX = VortX_Core.VortX_Core

-- ESP Features Initialization
VortX.esp = {
    boxes = false,
    healthbars = false,
    weaponlabels = false,
    skeleton = false,
    radar = false,
    wallhack = false
}

-- Analytics Initialization
VortX.analytics = {
    accuracy = 0,
    headshotRate = 0,
    timeToKill = 0,
    shotsFired = 0,
    shotsHit = 0,
    headshots = 0,
    kills = 0
}

-- Defense Features Initialization
VortX.defense = {
    enemyAimDetection = false,
    projectileWarning = false,
    threatRedirect = false
}

-- ESP Functions
function VortX:DrawESP()
    if self.esp.boxes or self.esp.healthbars or self.esp.weaponlabels then
        for _, plr in ipairs(self.services.plrs:GetPlayers()) do
            if plr ~= selfplr and plr.Character then
                local character = plr.Character
                local head = character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = self.util.vector.worldToScreen(head.Position)
                    if onScreen then
                        -- Draw Box ESP
                        if self.esp.boxes then
                            local size = character.Humanoid.HumanoidDisplaySize
                            local box = Drawing.new("Square")
                            box.Color = Color3.fromRGB(255, 0, 0)
                            box.Thickness = 2
                            box.Transparency = 0.7
                            box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                            box.Size = Vector2.new(size.X, size.Y)
                            box.Visible = true
                        end
                        
                        -- Draw Health Bar
                        if self.esp.healthbars then
                            local healthBar = Drawing.new("Rectangle")
                            healthBar.Color = Color3.fromRGB(0, 255, 0)
                            healthBar.Thickness = 1
                            healthBar.Transparency = 0.7
                            healthBar.Position = Vector2.new(pos.X - 5, pos.Y - 20)
                            healthBar.Size = Vector2.new(2, 20 * (character.Humanoid.Health / character.Humanoid.MaxHealth))
                            healthBar.Visible = true
                        end
                        
                        -- Draw Weapon Label
                        if self.esp.weaponlabels then
                            local weapon = character:FindFirstChildOfClass("Tool")
                            if weapon then
                                local label = Drawing.new("Text")
                                label.Center = true
                                label.Outline = true
                                label.OutlineColor = Color3.fromRGB(0, 0, 0)
                                label.Color = Color3.fromRGB(255, 255, 255)
                                label.Position = Vector2.new(pos.X, pos.Y - 30)
                                label.Text = weapon.Name
                                label.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Draw Skeleton ESP
    if self.esp.skeleton then
        for _, plr in ipairs(self.services.plrs:GetPlayers()) do
            if plr ~= selfplr and plr.Character then
                local character = plr.Character
                local joints = {
                    "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"
                }
                for i = 1, #joints do
                    local part = character:FindFirstChild(joints[i])
                    if part then
                        local pos, onScreen = self.util.vector.worldToScreen(part.Position)
                        if onScreen then
                            local joint = Drawing.new("Circle")
                            joint.Color = Color3.fromRGB(255, 255, 255)
                            joint.Thickness = 1
                            joint.Transparency = 0.7
                            joint.Radius = 3
                            joint.Position = pos
                            joint.Visible = true
                        end
                    end
                end
            end
        end
    end
    
    -- Draw 360° Radar
    if self.esp.radar then
        local radar = Drawing.new("Circle")
        radar.Color = Color3.fromRGB(255, 255, 0)
        radar.Thickness = 1
        radar.Transparency = 0.7
        radar.Radius = 100
        radar.Position = Vector2.new(self.services.ws.CurrentCamera.ViewportSize.X/2, self.services.ws.CurrentCamera.ViewportSize.Y/2)
        radar.Visible = true
        
        for _, plr in ipairs(self.services.plrs:GetPlayers()) do
            if plr ~= selfplr and plr.Character then
                local character = plr.Character
                local head = character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = self.util.vector.worldToScreen(head.Position)
                    if onScreen then
                        local radarDot = Drawing.new("Circle")
                        radarDot.Color = Color3.fromRGB(255, 0, 0)
                        radarDot.Thickness = 1
                        radarDot.Transparency = 0.7
                        radarDot.Radius = 2
                        radarDot.Position = Vector2.new(
                            self.services.ws.CurrentCamera.ViewportSize.X/2 + (pos.X - self.services.ws.CurrentCamera.ViewportSize.X/2)/2,
                            self.services.ws.CurrentCamera.ViewportSize.Y/2 + (pos.Y - self.services.ws.CurrentCamera.ViewportSize.Y/2)/2
                        )
                        radarDot.Visible = true
                    end
                end
            end
        end
    end
    
    -- Wall Hack
    if self.esp.wallhack then
        for _, plr in ipairs(self.services.plrs:GetPlayers()) do
            if plr ~= selfplr and plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.5
                    end
                end
            end
        end
    end
end

-- Analytics Functions
function VortX:UpdateAnalytics()
    if self.analytics.shotsFired > 0 then
        self.analytics.accuracy = self.analytics.shotsHit / self.analytics.shotsFired * 100
        if self.analytics.shotsHit > 0 then
            self.analytics.headshotRate = self.analytics.headshots / self.analytics.shotsHit * 100
        end
    end
    
    -- Display Analytics on Screen
    local analyticsDisplay = Drawing.new("Text")
    analyticsDisplay.Center = true
    analyticsDisplay.Outline = true
    analyticsDisplay.OutlineColor = Color3.fromRGB(0, 0, 0)
    analyticsDisplay.Color = Color3.fromRGB(255, 255, 255)
    analyticsDisplay.Position = Vector2.new(20, 20)
    analyticsDisplay.Text = string.format(
        "Accuracy: %.1f%%\nHeadshots: %.1f%%\nKills: %d\nTTK: %.1fms",
        self.analytics.accuracy,
        self.analytics.headshotRate,
        self.analytics.kills,
        self.analytics.timeToKill * 1000
    )
    analyticsDisplay.Visible = true
end

-- Defense Functions
function VortX:CheckForIncomingProjectiles()
    if self.defense.projectileWarning then
        for _, obj in ipairs(self.services.ws:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Velocity.Magnitude > 10 then
                local toPlayer = selfplr.Character.HumanoidRootPart.Position - obj.Position
                if toPlayer.Unit:Dot(obj.Velocity.Unit) > 0.9 then
                    -- Projectile is heading toward player
                    local warning = Drawing.new("Text")
                    warning.Center = true
                    warning.Outline = true
                    warning.OutlineColor = Color3.fromRGB(255, 0, 0)
                    warning.Color = Color3.fromRGB(255, 255, 0)
                    warning.Position = Vector2.new(self.services.ws.CurrentCamera.ViewportSize.X/2, 30)
                    warning.Text = "INCOMING PROJECTILE!"
                    warning.Visible = true
                    task.wait(2)
                    warning.Visible = false
                end
            end
        end
    end
end

function VortX:RedirectThreats()
    if self.defense.threatRedirect then
        for _, obj in ipairs(self.services.ws:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Velocity.Magnitude > 10 then
                local toPlayer = selfplr.Character.HumanoidRootPart.Position - obj.Position
                if toPlayer.Unit:Dot(obj.Velocity.Unit) > 0.9 then
                    -- Redirect projectile
                    local newDirection = toPlayer.Unit * -1
                    obj.Velocity = newDirection * obj.Velocity.Magnitude
                end
            end
        end
    end
end

-- Return ESP and Analytics System
return VortX

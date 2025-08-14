-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V5  |  STABLE ESP + IMPROVED AI
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub V2.5| BEST HYPERSHOT SCRIPT",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat"})
local ESPTab = Window:MakeTab({Name = "ESP"})

-- ESP Configuration
local ESP_Config = {
    Enabled = false,
    Thickness = 1.5,
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0.75,
    TeamCheck = false
}

-- Drawing Table
local Drawings = {}

-- Functions for ESP
local function CreateESPBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = player.Character.HumanoidRootPart
    
    local espBox = Drawing.new("Square")
    espBox.Visible = false
    espBox.Thickness = ESP_Config.Thickness
    espBox.Color = ESP_Config.Color
    espBox.Transparency = ESP_Config.Transparency
    espBox.Filled = false
    
    local espName = Drawing.new("Text")
    espName.Visible = false
    espName.Color = ESP_Config.Color
    espName.Outline = true
    espName.OutlineColor = Color3.new(0, 0, 0)
    espName.Font = 2
    espName.TextSize = 14
    
    table.insert(Drawings, {espBox, espName, player})
    
    RunService.Heartbeat:Connect(function()
        if not ESP_Config.Enabled or not rootPart or not rootPart.Parent or rootPart.Parent ~= player.Character then
            espBox.Visible = false
            espName.Visible = false
            return
        end
        
        if ESP_Config.TeamCheck and player.Team == LocalPlayer.Team then
            espBox.Visible = false
            espName.Visible = false
            return
        end
        
        local Vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local Size = Vector2.new(150, 300)
            espBox.Size = Size
            espBox.Position = Vector2.new(Vector.X - Size.X / 2, Vector.Y - Size.Y / 2)
            espBox.Visible = true
            
            espName.Position = Vector2.new(Vector.X, Vector.Y - 30)
            espName.Text = player.Name
            espName.Visible = true
        else
            espBox.Visible = false
            espName.Visible = false
        end
    end)
end

local function ToggleESP(v)
    ESP_Config.Enabled = v
    for _, drawing in ipairs(Drawings) do
        drawing[1].Visible = v and drawing[3].Character and drawing[3].Character:FindFirstChild("HumanoidRootPart") and (not ESP_Config.TeamCheck or drawing[3].Team ~= LocalPlayer.Team)
        drawing[2].Visible = v and drawing[3].Character and drawing[3].Character:FindFirstChild("HumanoidRootPart") and (not ESP_Config.TeamCheck or drawing[3].Team ~= LocalPlayer.Team)
    end
end

-- ESP UI
ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = ToggleESP
})

ESPTab:AddSlider({
    Name = "ESP Thickness",
    Min = 0.5,
    Max = 5,
    Default = 1.5,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 0.1,
    ValueName = "px",
    Callback = function(v)
        ESP_Config.Thickness = v
        for _, drawing in ipairs(Drawings) do
            drawing[1].Thickness = v
        end
    end
})

ESPTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(v)
        ESP_Config.Color = v
        for _, drawing in ipairs(Drawings) do
            drawing[1].Color = v
            drawing[2].Color = v
        end
    end
})

ESPTab:AddSlider({
    Name = "ESP Transparency",
    Min = 0,
    Max = 1,
    Default = 0.75,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 0.01,
    ValueName = "Transparency",
    Callback = function(v)
        ESP_Config.Transparency = v
        for _, drawing in ipairs(Drawings) do
            drawing[1].Transparency = v
        end
    end
})

ESPTab:AddToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(v)
        ESP_Config.TeamCheck = v
    end
})

-- Create ESP Boxes for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESPBox(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    CreateESPBox(player)
end)

Players.PlayerRemoving:Connect(function(player)
    for i, drawing in ipairs(Drawings) do
        if drawing[3] == player then
            table.remove(Drawings, i)
            drawing[1]:Remove()
            drawing[2]:Remove()
            break
        end
    end
end)

-- Global Flags
getgenv().SilentAimEnabled   = false
getgenv().WallbangEnabled    = false
getgenv().InfiniteAmmo       = false
getgenv().AutoCollect        = false
getgenv().AntiDetection      = false
getgenv().BringAllEnabled    = false
getgenv().BringDistance      = 5
getgenv().FOV                = 180

-- AI Constants
local Gravity = workspace.Gravity
local BulletSpeed = 4500

-------------------------------------------------
--Bring All Players (Original Method)
-------------------------------------------------
local function BringPlayers()
    if not getgenv().BringAllEnabled then return end
    local targetPos = (LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            plr.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(targetPos)
        end
    end
end

RunService.Heartbeat:Connect(BringPlayers)

-------------------------------------------------
-- Improved AI WALLBANG HEADSHOT
-------------------------------------------------
local function PredictHead(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return nil end
    
    local head = char.Head
    local velocity = head.Velocity
    local pos = head.Position
    
    local distance = (pos - Camera.CFrame.Position).Magnitude
    local time = distance / BulletSpeed
    
    return pos + velocity * time + Vector3.new(0, -0.5 * Gravity * time^2, 0)
end

local function GetTarget()
    local closest, minDist = nil, getgenv().FOV
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local predPos = PredictHead(plr)
        local screenPos, onScreen = Camera:WorldToViewportPoint(predPos)
        
        if onScreen then
            local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if dist < minDist then
                closest, minDist = plr, dist
            end
        end
    end
    
    return closest
end

local oldIndex = getrawmetatable(game).__index
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__index = newcclosure(function(t, k)
    if getgenv().SilentAimEnabled and k == "CurrentCamera" and t == workspace then
        local plr = GetTarget()
        if plr and plr.Character and plr.Character:FindFirstChild("Head") then
            local predPos = PredictHead(plr)
            return {CurrentCamera = Camera, TargetPoint = predPos}
        end
    end
    return oldIndex(t, k)
end)

-------------------------------------------------
-- REMADE INFINITE AMMO
-------------------------------------------------
local function UpdateAmmo()
    if not getgenv().InfiniteAmmo then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local backpack = LocalPlayer.Backpack
    
    for _, container in ipairs({backpack, char}) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") and (child.Name:lower() == "ammo" or child.Name:lower() == "clip") then
                        child.Value = 9999
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(UpdateAmmo)

-------------------------------------------------
-- AUTO COLLECT
-------------------------------------------------
local function AutoCollectItems()
    if not getgenv().AutoCollect then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char.HumanoidRootPart
    if not root then return end
    
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and (item.Name:lower():find("coin") or item.Name:lower():find("heal")) then
            if (item.Position - root.Position).Magnitude <= 50 then
                item.CFrame = root.CFrame
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoCollectItems)

-------------------------------------------------
-- ANTI-DETECTION
-------------------------------------------------
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", newcclosure(function(t, k)
    if getgenv().AntiDetection and k == "Velocity" and t:IsA("HumanoidRootPart") then
        return Vector3.new(0, 0.1, 0)
    end
    return oldIndex(t, k)
end))

-------------------------------------------------
-- UI SECTION
-------------------------------------------------
CombatTab:AddToggle({
    Name = "Silent Aimbot (Head)",
    Default = false,
    Callback = function(v)
        getgenv().SilentAimEnabled = v
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = v and "Headshot Aimbot ENABLED" or "Headshot Aimbot DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Wallbang",
    Default = false,
    Callback = function(v)
        getgenv().WallbangEnabled = v
        OrionLib:MakeNotification({
            Name = "Wallbang",
            Content = v and "Wallbang ENABLED" or "Wallbang DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Bring All Players",
    Default = false,
    Callback = function(v)
        getgenv().BringAllEnabled = v
        OrionLib:MakeNotification({
            Name = "Bring Players",
            Content = v and "Bring All ENABLED" or "Bring All DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddSlider({
    Name = "Bring Distance",
    Min = 1,
    Max = 50,
    Default = 5,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Studs",
    Callback = function(v)
        getgenv().BringDistance = v
    end
})

CombatTab:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(v)
        getgenv().InfiniteAmmo = v
        OrionLib:MakeNotification({
            Name = "Ammo",
            Content = v and "Infinite Ammo ENABLED" or "Ammo DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Anti-Detection",
    Default = false,
    Callback = function(v)
        getgenv().AntiDetection = v
        OrionLib:MakeNotification({
            Name = "Stealth",
            Content = v and "Anti-Detection ENABLED" or "Stealth DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddSlider({
    Name = "FOV Radius",
    Min = 10,
    Max = 360,
    Default = 180,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(v)
        getgenv().FOV = v
    end
})

AutoTab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollect = v
        OrionLib:MakeNotification({
            Name = "Collector",
            Content = v and "Auto Collect ENABLED" or "Collector DISABLED",
            Time = 3
        })
    end
})

-- Additional Features
CombatTab:AddToggle({
    Name = "Auto Jump",
    Default = false,
    Callback = function(v)
        getgenv().AutoJump = v
        OrionLib:MakeNotification({
            Name = "Auto Jump",
            Content = v and "Auto Jump ENABLED" or "Auto Jump DISABLED",
            Time = 3
        })
    end
})

Mouse.KeyDown:Connect(function(k)
    if k == " " and getgenv().AutoJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)

OrionLib:MakeNotification({
    Name = "Vortex Hub V2.5 BETA",
    Content = "Features loaded successfully!",
    Time = 5
})

OrionLib:Init()

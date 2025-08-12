-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ESP Library
local esp = nil
local function LoadESP()
    esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/ESP-Library/main/nomercy.rip/source.lua"))()
end

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Lighting = game:GetService("Lighting")

-- Main Window
local Window = Rayfield:CreateWindow({
    Name = "VortX Hub | Hypershot V1.5",
    LoadingTitle = "VortX Hub Loaded",
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
local EspTab = Window:CreateTab("ESP")
local MiscTab = Window:CreateTab("Misc")
local AutoTab = Window:CreateTab("Auto")

-- Combat Variables
getgenv().AimbotEnabled = false
getgenv().Prediction = 0.15
getgenv().BringPlayersEnabled = false
getgenv().RapidFireEnabled = false
getgenv().InfiniteAmmoEnabled = false

-- Aimbot Functions
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
            local targetPosition = player.Character.Head.Position + (player.Character.Head.Velocity * getgenv().Prediction)
            local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPosition)
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude

            if distance < shortestDistance and distance < 500 and onScreen then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end

    return closestPlayer
end

-- Metatable Hijack for Aimbot
local oldIndex = getrawmetatable(game).__index
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__index = newcclosure(function(t, k)
    if getgenv().AimbotEnabled and k == "CurrentCamera" and t == workspace then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            local targetPosition = closestPlayer.Character.Head.Position + (closestPlayer.Character.Head.Velocity * getgenv().Prediction)
            return {CurrentCamera = Camera, TargetPoint = targetPosition}
        end
    end
    return oldIndex(t, k)
end)

-- Bring Players Function
RunService.RenderStepped:Connect(function()
    if getgenv().BringPlayersEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not string.find(player.Name, "BOT") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = Camera.CFrame * CFrame.new(0, 0, -3)
                end
            end
        end
    end
end)

-- Rapid Fire Function
RunService.RenderStepped:Connect(function()
    if getgenv().RapidFireEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Mouse:IsMouseButtonPressed(0) then
            for _, v in pairs(getconnections(LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"))) do
                if v.Function and getfenv(v.Function).script then
                    getfenv(v.Function).script.Disabled = true
                end
            end
        end
    end
end)

-- Infinite Ammo Function
RunService.RenderStepped:Connect(function()
    if getgenv().InfiniteAmmoEnabled and LocalPlayer.Character then
        for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Handle") then
                for _, prop in ipairs(child:GetProperties()) do
                    if prop == "Ammo" then
                        child.Ammo = math.huge
                    end
                end
            end
        end
    end
end)

-- ESP Configuration
LoadESP()

-- Combat Elements
CombatTab:CreateToggle({
    Name = "Aimbot (Headshot + Prediction)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        getgenv().AimbotEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot is now disabled!",
                Duration = 4
            })
        end
    end
})

CombatTab:CreateSlider({
    Name = "Prediction Value",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = 0.15,
    Flag = "PredictionSlider",
    Callback = function(value)
        getgenv().Prediction = value
    end
})

CombatTab:CreateToggle({
    Name = "Bring Players (Toggle)",
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
    Name = "Rapid Fire",
    CurrentValue = false,
    Flag = "RapidFireToggle",
    Callback = function(value)
        getgenv().RapidFireEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Rapid Fire",
                Content = "Rapid Fire is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Rapid Fire",
                Content = "Rapid Fire is now disabled!",
                Duration = 4
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "InfiniteAmmoToggle",
    Callback = function(value)
        getgenv().InfiniteAmmoEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Infinite Ammo",
                Content = "Infinite Ammo is now enabled!",
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

-- ESP Elements
EspTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        if esp then
            esp.Settings.Enabled = value
        end
    end
})

EspTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Flag = "BoxesToggle",
    Callback = function(value)
        if esp then
            esp.Settings.Box.Enabled = value
        end
    end
})

EspTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "NamesToggle",
    Callback = function(value)
        if esp then
            esp.Settings.Name.Enabled = value
        end
    end
})

EspTab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(0, 146, 214),
    Callback = function(color)
        if esp then
            esp.Settings.Box.Color = color
        end
    end
})

EspTab:CreateColorPicker({
    Name = "Outline Color",
    Color = Color3.fromRGB(0, 170, 255),
    Callback = function(color)
        if esp then
            esp.Settings.Box.OutlineColor = color
        end
    end
})

-- Wall Transparency
local WallSection = CombatTab:CreateSection("Wall Transparency")

CombatTab:CreateToggle({
    Name = "Transparent Walls",
    CurrentValue = false,
    Flag = "WallToggle",
    Callback = function(value)
        if value == true then
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                    part.LocalTransparencyModifier = 0.5
                end
            end
        else
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end
})

-- Misc Elements
local FullBrightEnabled = false
local FpsBoostEnabled = false

MiscTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBrightToggle",
    Callback = function(value)
        FullBrightEnabled = value
        if value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 5000
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        end
    end
})

MiscTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FpsBoostToggle",
    Callback = function(value)
        FpsBoostEnabled = value
        if value then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        else
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0.5
                end
            end
        end
    end
})

-- Auto Collect Features
local AutoCollectEnabled = false

function CollectCoins()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and part.Name == "Coin" and part:FindFirstChild("TouchInterest") then
            part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end

function CollectHeals()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and part.Name == "Heal" and part:FindFirstChild("TouchInterest") then
            part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end

RunService.RenderStepped:Connect(function()
    if AutoCollectEnabled then
        CollectCoins()
        CollectHeals()
    end
end)

AutoTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(value)
        AutoCollectEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Auto Collect",
                Content = "Auto Collect is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Auto Collect",
                Content = "Auto Collect is now disabled!",
                Duration = 4
            })
        end
    end
})

-- Load ESP after Rayfield is initialized
task.wait(1)
if esp then
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            esp:Player(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            esp:Player(player)
        end
    end)
end

Rayfield:Notify({
    Title = "VortX Hub",
    Content = "All features loaded successfully!",
    Duration = 5
})

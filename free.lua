-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Lighting = game:GetService("Lighting")

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
local MiscTab = Window:CreateTab("Misc")
local AutoTab = Window:CreateTab("Auto")

-- Combat Variables
getgenv().AimbotEnabled = false
getgenv().Prediction = 0.15
getgenv().BringPlayersEnabled = false
getgenv().RapidFireEnabled = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoFarmEnabled = false
getgenv().HitboxSize = 2

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

-- Hitbox Expander Function
RunService.RenderStepped:Connect(function()
    if getgenv().HitboxSize > 1 then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("Head")
                
                if rootPart then
                    rootPart.Size = rootPart.Size * getgenv().HitboxSize
                end
            end
        end
    end
end)

-- Auto Farm Function
RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled and getgenv().AimbotEnabled then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = closestPlayer.Character.Humanoid
            
            if humanoid.Health > 0 then
                -- Auto-shoot logic
                if Mouse:IsMouseButtonPressed(0) then
                    game:GetService("ReplicatedStorage").Shoot:FireServer()
                end
            else
                -- Auto-reload logic
                if Mouse:IsMouseButtonPressed(2) then
                    -- Add your reload implementation here
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

CombatTab:CreateToggle({
    Name = "Auto Farm Kill",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        getgenv().AutoFarmEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Auto Farm",
                Content = "Auto Farm is now enabled!",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Auto Farm",
                Content = "Auto Farm is now disabled!",
                Duration = 4
            })
        end
    end
})

CombatTab:CreateSlider({
    Name = "Hitbox Expander",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = 2,
    Flag = "HitboxSlider",
    Callback = function(value)
        getgenv().HitboxSize = value
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
        if part:IsA("Part") and (part.Name == "Coin" or part.Name == "coin") and part:FindFirstChild("TouchInterest") then
            part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end

function CollectHeals()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and (part.Name == "Heal" or part.Name == "heal" or part.Name == "HealthPack") and part:FindFirstChild("TouchInterest") then
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

Rayfield:Notify({
    Title = "VortX Hub V2",
    Content = "All features loaded successfully!",
    Duration = 5
})

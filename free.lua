-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
getgenv().Prediction = 0.2
getgenv().BringPlayersEnabled = false
getgenv().RapidFireEnabled = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoFarmEnabled = false
getgenv().HitboxSize = 2
getgenv().AutoCollectRange = 50

-- Aimbot with Advanced Prediction
local function PredictPlayerPosition(player, predictionTime)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return nil end
    
    local head = character.Head
    local velocity = head.Velocity
    local position = head.Position
    
    -- Calculate future position based on velocity
    local predictedPosition = position + velocity * predictionTime
    
    -- Also consider the player's movement direction
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.MoveDirection.magnitude > 0 then
        predictedPosition = predictedPosition + humanoid.MoveDirection * 10 * predictionTime
    end
    
    return predictedPosition
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            if head and character:FindFirstChild("Humanoid").Health > 0 then
                local predictionTime = 0.15 -- Adjust this value based on your needs
                local predictedPosition = PredictPlayerPosition(player, predictionTime)
                
                local screenPosition, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude

                if distance < shortestDistance and distance < 500 and onScreen then
                    closestPlayer = player
                    shortestDistance = distance
                end
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
            local predictionTime = 0.15
            local predictedPosition = PredictPlayerPosition(closestPlayer, predictionTime)
            return {CurrentCamera = Camera, TargetPoint = predictedPosition}
        end
    end
    return oldIndex(t, k)
end)

-- Bring Players Function (Improved)
RunService.RenderStepped:Connect(function()
    if getgenv().BringPlayersEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not string.find(player.Name, "BOT") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Smoothly bring players to the desired position
                    local targetPosition = Camera.CFrame * CFrame.new(0, 0, -3)
                    player.Character.HumanoidRootPart.CFrame = targetPosition
                end
            end
        end
    end
end)

-- Rapid Fire Function (Improved)
RunService.RenderStepped:Connect(function()
    if getgenv().RapidFireEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Mouse:IsMouseButtonPressed(0) then
            -- Directly fire the shoot remote
            if ReplicatedStorage:FindFirstChild("Shoot") then
                ReplicatedStorage.Shoot:FireServer()
            end
        end
    end
end)

-- Hitbox Expander Function
RunService.RenderStepped:Connect(function()
    if getgenv().HitboxSize > 1 then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                if head then
                    head.Size = head.Size * getgenv().HitboxSize
                end
            end
        end
    end
end)

-- Auto Farm Kill Function
RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer and closestPlayer.Character then
            -- Auto-shoot logic
            if Mouse:IsMouseButtonPressed(0) and ReplicatedStorage:FindFirstChild("Shoot") then
                ReplicatedStorage.Shoot:FireServer()
            end
        end
    end
end)

-- Infinite Ammo Function
RunService.RenderStepped:Connect(function()
    if getgenv().InfiniteAmmoEnabled and LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Ammo = math.huge
            end
        end
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Ammo = math.huge
            end
        end
    end
end)

-- Auto Collect Features (Optimized)
local function CollectItems(itemName)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and part.Name:lower() == itemName:lower() and part:FindFirstChild("TouchInterest") then
            local distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= getgenv().AutoCollectRange then
                part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoCollectEnabled then
        CollectItems("Coin")
        CollectItems("Heal")
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
    CurrentValue = 0.2,
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

-- Auto Collect Elements
AutoTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(value)
        getgenv().AutoCollectEnabled = value
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

AutoTab:CreateSlider({
    Name = "Collect Range",
    Range = {10, 1000},
    Increment = 10,
    CurrentValue = 50,
    Flag = "CollectRangeSlider",
    Callback = function(value)
        getgenv().AutoCollectRange = value
    end
})

-- Notify user when everything is loaded
Rayfield:Notify({
    Title = "VortX Hub V2",
    Content = "All features loaded successfully!",
    Duration = 5
})

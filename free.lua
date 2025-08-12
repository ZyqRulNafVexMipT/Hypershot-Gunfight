-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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
getgenv().AimbotEnabled = false
getgenv().Prediction = 0.15
getgenv().BringPlayersEnabled = false
getgenv().AutoFarmEnabled = false
getgenv().InfiniteAmmoEnabled = false

-- Bring Players Function
local function BringPlayers()
    local teleportDistance = 5
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")

    if root then
        local targetPosition = root.Position + (root.CFrame.LookVector * teleportDistance)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(targetPosition)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().BringPlayersEnabled then
        BringPlayers()
    end
end)

-- Auto Farm Function
local function AutoFarm()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")

    if root then
        local targetPosition = root.Position + (root.CFrame.LookVector * 5)
        for _, mob in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("Head") then
                local mobHead = mob.Head
                local screenPosition, onScreen = Camera:WorldToViewportPoint(mobHead.Position)
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude

                if distance < 500 and onScreen then
                    if ReplicatedStorage:FindFirstChild("Shoot") then
                        ReplicatedStorage.Shoot:FireServer()
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled then
        AutoFarm()
    end
end)

-- Aimbot Function with Prediction
local function PredictPlayerPosition(player, predictionTime)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return nil end
    
    local head = character.Head
    local velocity = head.Velocity
    local position = head.Position
    
    -- Calculate future position based on velocity and movement direction
    local predictedPosition = position + velocity * predictionTime
    
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
                local predictionTime = 0.15
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

-- Rapid Fire Function
RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled and Mouse:IsMouseButtonPressed(0) then
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer()
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

-- Combat Tab Elements
CombatTab:CreateToggle({
    Name = "100% Headshot Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        getgenv().AimbotEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Aimbot is now enabled with 100% headshot accuracy!",
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

-- Notify user when everything is loaded
Rayfield:Notify({
    Title = "VortX Hub V2",
    Content = "All features loaded successfully!",
    Duration = 5
})

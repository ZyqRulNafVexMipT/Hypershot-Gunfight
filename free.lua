-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V4  |  ESP + IMPROVED AI
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
    Name = "Vortex Hub V4 | ESP + Advanced AI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat"})
local ESP_Tab = Window:MakeTab({Name = "ESP"})

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
    local headPart = player.Character.Head
    
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
ESP_Tab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = ToggleESP
})

ESP_Tab:AddSlider({
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

ESP_Tab:AddColorpicker({
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

ESP_Tab:AddSlider({
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

ESP_Tab:AddToggle({
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

-- Add ESP Boxes for new players
Players.PlayerAdded:Connect(function(player)
    task.wait(1) -- Wait for character to load
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

-- This is part one of the script
-- Continue with part two for the remaining features
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V4  |  ESP + IMPROVED AI (PART 2)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- Global Flags
getgenv().SilentAimEnabled   = false
getgenv().WallbangEnabled    = false
getgenv().InfiniteAmmo       = false
getgenv().AutoCollect        = false
getgenv().AntiDetection      = false
getgenv().BringAllEnabled    = false
getgenv().BringDistance      = 5
getgenv().FOV                = 180
getgenv().HitChance          = 100
getgenv().DirectionalKill    = false
getgenv().RapidFire          = false

-- AI Constants
local Gravity = workspace.Gravity
local BulletSpeed = 4500
local PredictionTime = 0.1337

-------------------------------------------------
-- Bring All Players
-------------------------------------------------
local function GetMyPosition()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root then
        return Root.Position + (Root.CFrame.LookVector * getgenv().BringDistance)
    end
    return nil
end

local function BringPlayers()
    if not getgenv().BringAllEnabled then return end
    
    local MyPos = GetMyPosition()
    if not MyPos then return end
    
    -- Bring actual players
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                Root.CFrame = CFrame.new(MyPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
            end
        end
    end
    
    -- Bring mobs/NPCs if they exist
    local MobsFolder = Workspace:FindFirstChild("Mobs") or Workspace:FindFirstChild("NPCs")
    if MobsFolder then
        for _, Mob in ipairs(MobsFolder:GetChildren()) do
            if Mob:IsA("Model") and Mob.PrimaryPart then
                Mob:SetPrimaryPartCFrame(CFrame.new(MyPos))
            end
        end
    end
end

RunService.Heartbeat:Connect(BringPlayers)

-------------------------------------------------
-- AI WALLBANG HEADSHOT
-------------------------------------------------
local function PredictHead(Player)
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("Head") then return nil end
    
    local Head = Character.Head
    local Velocity = Head.Velocity
    local Position = Head.Position
    
    local Distance = (Position - Camera.CFrame.Position).Magnitude
    local Time = Distance / BulletSpeed
    
    -- Simple but effective prediction
    local Predicted = Position + Velocity * Time + Vector3.new(0, -0.5 * Gravity * Time * Time, 0)
    return Predicted
end

local function CheckWallbang(TargetPos)
    if getgenv().WallbangEnabled then return true end
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local Direction = (TargetPos - Camera.CFrame.Position).Unit
    local RaycastResult = Workspace:Raycast(Camera.CFrame.Position, Direction * 5000, RaycastParams)
    
    return not RaycastResult or RaycastResult.Instance:IsDescendantOf(TargetPos.Parent)
end

local function GetTarget()
    local Closest, Distance = nil, getgenv().FOV
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        
        local Character = Player.Character
        if not Character or not Character:FindFirstChild("Head") then continue end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        local HeadPos = PredictHead(Player)
        if not HeadPos then continue end
        
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HeadPos)
        if not OnScreen then continue end
        
        local MouseDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
        
        if MouseDistance <= Distance then
            if CheckWallbang(HeadPos) then
                Closest = {
                    Player = Player,
                    Position = HeadPos
                }
            end
        end
    end
    
    return Closest
end

-- Silent Aim Hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if getgenv().SilentAimEnabled and Method == "FireServer" and tostring(Self) == "Shoot" then
        local Target = GetTarget()
        if Target then
            -- Force headshot
            Args[1] = Target.Position
            Args[2] = Target.Player.Character.Head
            return OldNamecall(Self, unpack(Args))
        end
    end
    
    return OldNamecall(Self, ...)
end))

-------------------------------------------------
-- INFINITE AMMO (FORCE)
------------------------------------------------
local function ForceInfiniteAmmo()
    if not getgenv().InfiniteAmmo then return end
    
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Backpack = LocalPlayer.Backpack
    
    local function UpdateContainer(Container)
        for _, Tool in ipairs(Container:GetChildren()) do
            if Tool:IsA("Tool") then
                for _, Ammo in ipairs(Tool:GetDescendants()) do
                    if Ammo.Name:lower():find("ammo") or Ammo.Name:lower():find("clip") then
                        Ammo.Value = 9999
                    end
                end
            end
        end
    end
    
    UpdateContainer(Backpack)
    UpdateContainer(Character)
end

RunService.Heartbeat:Connect(ForceInfiniteAmmo)
LocalPlayer.CharacterAdded:Connect(ForceInfiniteAmmo)

-------------------------------------------------
-- AUTO COLLECT
-------------------------------------------------
local function AutoCollectItems()
    if not getgenv().AutoCollect then return end
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    
    for _, Item in ipairs(Workspace:GetDescendants()) do
        if Item:IsA("BasePart") and (Item.Name:lower():find("coin") or Item.Name:lower():find("money") or Item.Name:lower():find("heal")) then
            if (Item.Position - Root.Position).Magnitude <= 50 then
                Item.CFrame = Root.CFrame
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoCollectItems)

-------------------------------------------------
-- ANTI-DETECTION
------------------------------------------------
local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", newcclosure(function(Self, Key)
    if getgenv().AntiDetection and Key == "Velocity" and Self.Name == "HumanoidRootPart" then
        return Vector3.new(0, 0, 0)
    end
    return OldIndex(Self, Key)
end))

-------------------------------------------------
-- DIRECTIONAL KILL
-------------------------------------------------
local function autoDirectionalKill()
    if not getgenv().DirectionalKill then return end

    local camPos = Camera.CFrame.Position
    local lookDir = Camera.CFrame.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hd = char and char:FindFirstChild("Head")
        local h = char and char:FindFirstChildOfClass("Humanoid")
        if not hd or not h or h.Health <= 0 then continue end

        local vec = hd.Position - camPos
        local dist = vec.Magnitude
        if lookDir:Dot(vec.Unit) < 0.95 then continue end -- Wider cone for directional kill

        -- Universal remote
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer(hd.Position)
        elseif ReplicatedStorage:FindFirstChild("Damage") then
            ReplicatedStorage.Damage:FireServer(plr, 9e9)
        else
            local rem = ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
            if rem then rem:FireServer(plr, hd.Position) end
        end
    end
end

RunService.Heartbeat:Connect(autoDirectionalKill)

-------------------------------------------------
-- RAPID FIRE
-------------------------------------------------
Mouse.Button1Down:Connect(function()
    if not getgenv().RapidFire then return end
    while Mouse:IsMouseButtonPressed(0) and getgenv().RapidFire do
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer()
        end
        task.wait(0.1) -- Rapid fire rate
    end
end)

-------------------------------------------------
-- UI SECTION
------------------------------------------------
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
    Name = "Wallbang (Through Walls)",
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
    Default

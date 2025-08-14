-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V3  |  AI WALLBANG HEADSHOT + BRING ALL
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
    Name = "Vortex Hub V3 | Bring All + Headshot",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

-- Globals
getgenv().SilentAimEnabled   = false
getgenv().WallbangEnabled    = false
getgenv().InfiniteAmmo       = false
getgenv().AutoCollect        = false
getgenv().AntiDetection      = false
getgenv().BringAllEnabled    = false
getgenv().BringDistance      = 5
getgenv().FOV                = 180
getgenv().HitChance          = 100

-------------------------------------------------
-- 1.  BRING ALL PLAYERS
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
-- 2.  AI WALLBANG HEADSHOT
-------------------------------------------------
local Gravity = workspace.Gravity
local BulletSpeed = 4500

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
-- 3.  INFINITE AMMO (FORCE)
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
-- 4.  AUTO COLLECT
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
-- 5.  ANTI-DETECTION
------------------------------------------------
local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", newcclosure(function(Self, Key)
    if getgenv().AntiDetection and Key == "Velocity" and Self.Name == "HumanoidRootPart" then
        return Vector3.new(0, 0, 0)
    end
    return OldIndex(Self, Key)
end))

-------------------------------------------------
-- 6.  UI SECTION
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

-------------------------------------------------
-- INIT
-------------------------------------------------
OrionLib:MakeNotification({
    Name = "Vortex Hub V3",
    Content = "All features loaded successfully!",
    Time = 5
})

OrionLib:Init()

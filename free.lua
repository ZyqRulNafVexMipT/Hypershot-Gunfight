-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V10 | ULTIMATE EDITION
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- Orion Library Initialization
local OrionLib = nil
local function InitializeOrion()
    local Success, Result = pcall(function()
        -- Try multiple reliable sources for OrionLib
        local sources = {
            "https://raw.githubusercontent.com/shlexware/Orion/main/source", -- Official repository
            "https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua", -- Backup source
        }
        
        for _, source in ipairs(sources) do
            local content = game:HttpGet(source)
            local loaded = loadstring(content)
            if typeof(loaded) == "function" then
                return loaded()
            end
        end
        
        return nil
    end)
    
    if Success and Result then
        OrionLib = Result
    else
        warn("OrionLib failed to load. Please ensure your internet connection is working.")
    end
end

InitializeOrion()

-- If OrionLib failed to load, don't proceed
if not OrionLib then
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Main Window
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub V10 | Ultimate Edition",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat"})
local ESPTab = Window:MakeTab({Name = "ESP"})
local UtilityTab = Window:MakeTab({Name = "Utilities"})
local AutoFarmTab = Window:MakeTab({Name = "Auto Farm"})

-- ESP Configuration
local ESP_Config = {
    Enabled = false,
    Thickness = 1.5,
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0.75,
    TeamCheck = false
}

-- Drawing Management
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
getgenv().AutoCollectCoins   = false
getgenv().AutoCollectHeals   = false
getgenv().AutoCollectWeapons = false
getgenv().AntiDetection      = false
getgenv().BringAllEnabled    = false
getgenv().BringDistance      = 5
getgenv().FOV                = 180
getgenv().AutoJump           = false
getgenv().NoClip             = false
getgenv().AntiRecoil         = false
getgenv().AutoSpawn          = false
getgenv().AutoFarm           = false
getgenv().AutoOpenChest      = false
getgenv().AutoSpinWheel      = false
getgenv().AutoCollectAwards  = false
getgenv().RapidFire          = false
getgenv().HitboxExpander     = false
getgenv().KillAura           = false
getgenv().NoCooldown         = false

-- Constants
local Gravity = workspace.Gravity
local BulletSpeed = 4500

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
-- WALLBANG REMAKE
-------------------------------------------------
local function CheckWallbang(TargetPos)
    if getgenv().WallbangEnabled then return true end
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local Direction = (TargetPos - Camera.CFrame.Position).Unit
    local RaycastResult = Workspace:Raycast(Camera.CFrame.Position, Direction * 5000, RaycastParams)
    
    return not RaycastResult or RaycastResult.Instance:IsDescendantOf(TargetPos.Parent)
end

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
-- AUTO COLLECT ITEMS
-------------------------------------------------
local function AutoCollectCoins()
    if not getgenv().AutoCollectCoins then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char.HumanoidRootPart
    if not root then return end
    
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.Name:lower():find("coin") then
            if (item.Position - root.Position).Magnitude <= 50 then
                item.CFrame = root.CFrame
            end
        end
    end
end

local function AutoCollectHeals()
    if not getgenv().AutoCollectHeals then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char.HumanoidRootPart
    if not root then return end
    
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.Name:lower():find("heal") then
            if (item.Position - root.Position).Magnitude <= 50 then
                item.CFrame = root.CFrame
            end
        end
    end
end

local function AutoCollectWeapons()
    if not getgenv().AutoCollectWeapons then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char.HumanoidRootPart
    if not root then return end
    
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Tool") and item.Parent == Workspace then
            if (item.Handle.Position - root.Position).Magnitude <= 50 then
                item:Clone().Parent = LocalPlayer.Backpack
                item:Destroy()
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoCollectCoins)
RunService.Heartbeat:Connect(AutoCollectHeals)
RunService.Heartbeat:Connect(AutoCollectWeapons)

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
-- NO CLIP
-------------------------------------------------
local function NoClip()
    if not getgenv().NoClip then return end
    if not LocalPlayer.Character then return end
    
    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

RunService.Heartbeat:Connect(NoClip)

-------------------------------------------------
-- ANTI-RECOIL
-------------------------------------------------
local function AntiRecoil()
    if not getgenv().AntiRecoil then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    
    LocalPlayer.Character.Humanoid.PlatformStand = true
end

RunService.Heartbeat:Connect(AntiRecoil)

-------------------------------------------------
-- AUTO SPAWN
-------------------------------------------------
local function AutoSpawn()
    if not getgenv().AutoSpawn then return end
    if not LocalPlayer.Character then
        -- Find and use spawn point
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") or (obj:IsA("Part") and obj.Name:lower():find("spawn")) then
                task.wait(1) -- Wait for respawn
                if LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                end
                break
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoSpawn)

-------------------------------------------------
-- AUTO FARM
-------------------------------------------------
local function AutoFarm()
    if not getgenv().AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char.HumanoidRootPart
    if not root then return end
    
    -- Farm logic
    for _, mob in ipairs(Workspace:GetDescendants()) do
        if mob:IsA("Model") and (mob.Name:lower():find("mob") or mob.Name:lower():find("enemy")) then
            if mob:FindFirstChild("HumanoidRootPart") then
                root.CFrame = CFrame.new(mob.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
                task.wait(0.5)
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoFarm)

-------------------------------------------------
-- AUTO OPEN CHEST
-------------------------------------------------
local function AutoOpenChest()
    if not getgenv().AutoOpenChest then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) then
            if obj:FindFirstChild("UIButton") then
                obj:UIButton()
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoOpenChest)

-------------------------------------------------
-- AUTO SPIN WHEEL
-------------------------------------------------
local function AutoSpinWheel()
    if not getgenv().AutoSpinWheel then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("wheel") then
            if obj:FindFirstChild("SpinButton") then
                obj:SpinButton()
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoSpinWheel)

-------------------------------------------------
-- AUTO COLLECT AWARDS
-------------------------------------------------
local function AutoCollectAwards()
    if not getgenv().AutoCollectAwards then return end
    for _, obj in ipairs(game:GetService("GuiService"):GetAllGuiObjects()) do
        if obj:IsA("Frame") and obj.Name:lower():find("award") then
            for _, button in ipairs(obj:GetDescendants()) do
                if button:IsA("TextButton") and button.Text:lower():find("collect") then
                    button:Fire()
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(AutoCollectAwards)

-------------------------------------------------
-- RAPID FIRE
-------------------------------------------------
Mouse.Button1Down:Connect(function()
    if getgenv().RapidFire then
        while getgenv().RapidFire and Mouse:IsMouseButtonPressed(0) do
            if ReplicatedStorage:FindFirstChild("Shoot") then
                ReplicatedStorage.Shoot:FireServer()
                task.wait(0.1)
            end
        end
    end
end)

-------------------------------------------------
-- HITBOX EXPANDER
-------------------------------------------------
local function HitboxExpander()
    if not getgenv().HitboxExpander then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(8, 8, 8) -- Expand hitbox
            end
        end
    end
end

RunService.Heartbeat:Connect(HitboxExpander)

-------------------------------------------------
-- KILL AURA
-------------------------------------------------
local function KillAura()
    if not getgenv().KillAura then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPosition = player.Character.HumanoidRootPart.Position
            if (LocalPlayer.Character.HumanoidRootPart.Position - targetPosition).Magnitude < 20 then
                if ReplicatedStorage:FindFirstChild("Shoot") then
                    ReplicatedStorage.Shoot:FireServer()
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(KillAura)

-------------------------------------------------
-- NO COOLDOWN
-------------------------------------------------
local function NoCooldown()
    if not getgenv().NoCooldown then return end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Cooldown = 0
        end
    end
    for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Cooldown = 0
        end
    end
end

RunService.Heartbeat:Connect(NoCooldown)

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

CombatTab:AddToggle({
    Name = "Anti-Recoil",
    Default = false,
    Callback = function(v)
        getgenv().AntiRecoil = v
        OrionLib:MakeNotification({
            Name = "Anti-Recoil",
            Content = v and "Anti-Recoil ENABLED" or "Anti-Recoil DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Auto Spawn",
    Default = false,
    Callback = function(v)
        getgenv().AutoSpawn = v
        OrionLib:MakeNotification({
            Name = "Auto Spawn",
            Content = v and "Auto Spawn ENABLED" or "Auto Spawn DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Rapid Fire",
    Default = false,
    Callback = function(v)
        getgenv().RapidFire = v
        OrionLib:MakeNotification({
            Name = "Rapid Fire",
            Content = v and "Rapid Fire ENABLED" or "Rapid Fire DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Hitbox Expander",
    Default = false,
    Callback = function(v)
        getgenv().HitboxExpander = v
        OrionLib:MakeNotification({
            Name = "Hitbox Expander",
            Content = v and "Hitbox Expander ENABLED" or "Hitbox Expander DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(v)
        getgenv().KillAura = v
        OrionLib:MakeNotification({
            Name = "Kill Aura",
            Content = v and "Kill Aura ENABLED" or "Kill Aura DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "No Cooldown",
    Default = false,
    Callback = function(v)
        getgenv().NoCooldown = v
        OrionLib:MakeNotification({
            Name = "No Cooldown",
            Content = v and "No Cooldown ENABLED" or "No Cooldown DISABLED",
            Time = 3
        })
    end
})

UtilityTab:AddToggle({
    Name = "Auto Collect Coins",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollectCoins = v
        OrionLib:MakeNotification({
            Name = "Auto Collect Coins",
            Content = v and "Auto Collect Coins ENABLED" or "Auto Collect Coins DISABLED",
            Time = 3
        })
    end
})

UtilityTab:AddToggle({
    Name = "Auto Collect Heals",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollectHeals = v
        OrionLib:MakeNotification({
            Name = "Auto Collect Heals",
            Content = v and "Auto Collect Heals ENABLED" or "Auto Collect Heals DISABLED",
            Time = 3
        })
    end
})

UtilityTab:AddToggle({
    Name = "Auto Collect Weapons",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollectWeapons = v
        OrionLib:MakeNotification({
            Name = "Auto Collect Weapons",
            Content = v and "Auto Collect Weapons ENABLED" or "Auto Collect Weapons DISABLED",
            Time = 3
        })
    end
})

UtilityTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(v)
        getgenv().NoClip = v
        OrionLib:MakeNotification({
            Name = "No Clip",
            Content = v and "No Clip ENABLED" or "No Clip DISABLED",
            Time = 3
        })
    end
})

UtilityTab:AddToggle({
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

AutoFarmTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(v)
        getgenv().AutoFarm = v
        OrionLib:MakeNotification({
            Name = "Auto Farm",
            Content = v and "Auto Farm ENABLED" or "Auto Farm DISABLED",
            Time = 3
        })
    end
})

AutoFarmTab:AddToggle({
    Name = "Auto Open Chest",
    Default = false,
    Callback = function(v)
        getgenv().AutoOpenChest = v
        OrionLib:MakeNotification({
            Name = "Auto Open Chest",
            Content = v and "Auto Open Chest ENABLED" or "Auto Open Chest DISABLED",
            Time = 3
        })
    end
})

AutoFarmTab:AddToggle({
    Name = "Auto Spin Wheel",
    Default = false,
    Callback = function(v)
        getgenv().AutoSpinWheel = v
        OrionLib:MakeNotification({
            Name = "Auto Spin Wheel",
            Content = v and "Auto Spin Wheel ENABLED" or "Auto Spin Wheel DISABLED",
            Time = 3
        })
    end
})

AutoFarmTab:AddToggle({
    Name = "Auto Collect Awards",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollectAwards = v
        OrionLib:MakeNotification({
            Name = "Auto Collect Awards",
            Content = v and "Auto Collect Awards ENABLED" or "Auto Collect Awards DISABLED",
            Time = 3
        })
    end
})

OrionLib:MakeNotification({
    Name = "Vortex Hub V10",
    Content = "All features loaded successfully!",
    Time = 5
})

OrionLib:Init()

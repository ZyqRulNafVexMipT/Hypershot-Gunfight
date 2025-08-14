-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V2.8 | ULTIMATE EDITION
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
    Name = "Vortex Hub V2.8 | Ultimate Edition",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat"})
local ESPTab = Window:MakeTab({Name = "ESP"})
local UtilityTab = Window:MakeTab({Name = "Utilities"})
local OpenTab = Window:MakeTab({Name = "Open"})
local Gun ModsTab = Window:MakeTab({Name = "Gun Mods"})

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

-- Helpers
local function root(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function head(char) return char and char:FindFirstChild("Head") end

-- ESP Functions
local function CreateESPBox(player)
    if not player.Character or not root(player.Character) then return end
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
        if not ESP_Config.Enabled or not root(player.Character) then
            espBox.Visible = false
            espName.Visible = false
            return
        end
        
        if ESP_Config.TeamCheck and player.Team == LocalPlayer.Team then
            espBox.Visible = false
            espName.Visible = false
            return
        end
        
        local Vector, onScreen = Camera:WorldToViewportPoint(root(player.Character).Position)
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
        drawing[1].Visible = v and drawing[3].Character and root(drawing[3].Character) and (not ESP_Config.TeamCheck or drawing[3].Team ~= LocalPlayer.Team)
        drawing[2].Visible = v and drawing[3].Character and root(drawing[3].Character) and (not ESP_Config.TeamCheck or drawing[3].Team ~= LocalPlayer.Team)
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
getgenv().BringPlayersEnabled    = false
getgenv().teleportDistance      = 5
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
getgenv().BigHead           = false

-- Constants
local Gravity = workspace.Gravity
local BulletSpeed = 4500

-------------------------------------------------
-- Bring All Players
-------------------------------------------------
local teleportDistance = 5

local function setTeleportDistance(studs)
    teleportDistance = math.max(tonumber(studs) or 5, 1)
end

local function getTargetPosition()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position + (root.CFrame.LookVector * teleportDistance)
end

RunService.RenderStepped:Connect(function()
    if not getgenv().BringPlayersEnabled then return end
    local targetPos = getTargetPosition()
    if not targetPos then return end

    -- Bring actual players
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                Root.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
            end
        end
    end
    
    -- Bring mobs/NPCs if they exist
    local MobsFolder = Workspace:FindFirstChild("Mobs") or Workspace:FindFirstChild("NPCs")
    if MobsFolder then
        for _, Mob in ipairs(MobsFolder:GetChildren()) do
            if Mob:IsA("Model") and Mob.PrimaryPart then
                Mob:SetPrimaryPartCFrame(CFrame.new(targetPos))
            end
        end
    end
end)

-------------------------------------------------
-- Advanced AI Engine for Aimbot
-------------------------------------------------
local function AdvancedAimbot()
    if not getgenv().SilentAimEnabled then return end
    
    local closestPlayer = nil
    local closestDistance = getgenv().FOV
    
    -- Iterate through all players to find the closest one within FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character or not player.Character:FindFirstChild("Head") then continue end
        
        local targetHead = player.Character.Head
        local targetPosition = targetHead.Position
        local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPosition)
        
        -- Calculate distance from crosshair
        local distanceFromCrosshair = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
        
        -- Update closest player if within FOV and closer than current closest
        if onScreen and distanceFromCrosshair < closestDistance then
            closestPlayer = player
            closestDistance = distanceFromCrosshair
        end
    end
    
    -- If a valid target is found, predict head position
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local head = closestPlayer.Character.Head
        local velocity = head.Velocity
        local position = head.Position
        
        -- Calculate bullet travel time
        local distanceToTarget = (position - Camera.CFrame.Position).Magnitude
        local travelTime = distanceToTarget / BulletSpeed
        
        -- Predict future head position
        local predictedPosition = position + velocity * travelTime + Vector3.new(0, -0.5 * Gravity * travelTime^2, 0)
        
        -- Apply aimbot
        if getgenv().WallbangEnabled or CheckLineOfSight(predictedPosition) then
            -- Set camera target to predicted head position
            return {CurrentCamera = Camera, TargetPoint = predictedPosition}
        end
    end
    
    -- Function to check line of sight
    function CheckLineOfSight(targetPosition)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local direction = (targetPosition - Camera.CFrame.Position).Unit
        local raycastResult = Workspace:Raycast(Camera.CFrame.Position, direction * 5000, raycastParams)
        
        return not raycastResult or raycastResult.Instance:IsDescendantOf(targetPosition.Parent)
    end
end

-- Hook into the index metamethod to hijack camera targeting
local oldIndex = getrawmetatable(game).__index
setreadonly(getrawmetatable(game), false)
getrawmetatable(game).__index = newcclosure(function(t, k)
    if getgenv().SilentAimEnabled and k == "CurrentCamera" and t == workspace then
        local aimbotResult = AdvancedAimbot()
        if aimbotResult then
            return aimbotResult
        end
    end
    return oldIndex(t, k)
end)

-------------------------------------------------
-- BIG HEAD FEATURE
-------------------------------------------------
local function BigHead()
    if not getgenv().BigHead then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(4, 4, 4) -- Make head larger
                head.Transparency = 0.7 -- Make it slightly transparent for visibility
            end
        end
    end
end

RunService.Heartbeat:Connect(BigHead)

-------------------------------------------------
-- REMADE INFINITE AMMO
-------------------------------------------------
local function UpdateAmmo()
    if not getgenv().InfiniteAmmo then return end
    local function scan(container)
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
    scan(LocalPlayer.Backpack)
    scan(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
end

RunService.Heartbeat:Connect(UpdateAmmo)
LocalPlayer.CharacterAdded:Connect(UpdateAmmo)

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
local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", newcclosure(function(Self, Key)
    if getgenv().AntiDetection and Key == "Velocity" and Self.Name == "HumanoidRootPart" then
        return Vector3.new(0, 0.1, 0)
    end
    return OldIndex(Self, Key)
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
-- ANTI-RECOIL & GUN MODS
-------------------------------------------------
for _, v in next, getgc(true) do
    if typeof(v) == 'table' and rawget(v, 'Spread') then
        rawset(v, 'Spread', 0)
        rawset(v, 'BaseSpread', 0)
        rawset(v, 'MinCamRecoil', Vector3.new())
        rawset(v, 'MaxCamRecoil', Vector3.new())
        rawset(v, 'MinRotRecoil', Vector3.new())
        rawset(v, 'MaxRotRecoil', Vector3.new())
        rawset(v, 'MinTransRecoil', Vector3.new())
        rawset(v, 'MaxTransRecoil', Vector3.new())
        rawset(v, 'ScopeSpeed', 100)
    end
end

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
-- AUTO FARM (OPEN)
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
        getgenv().BringPlayersEnabled = v
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
        getgenv().teleportDistance = v
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

CombatTab:AddToggle({
    Name = "Big Head",
    Default = false,
    Callback = function(v)
        getgenv().BigHead = v
        OrionLib:MakeNotification({
            Name = "Big Head",
            Content = v and "Big Head ENABLED" or "Big Head DISABLED",
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

OpenTab:AddToggle({
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

OpenTab:AddToggle({
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

OpenTab:AddToggle({
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

OpenTab:AddToggle({
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

Gun ModsTab:AddLabel("Anti Recoil & Spread Settings")
Gun ModsTab:AddToggle({
    Name = "Enable Gun Mods",
    Default = false,
    Callback = function(v)
        getgenv().GunModsEnabled = v
        OrionLib:MakeNotification({
            Name = "Gun Mods",
            Content = v and "Gun Mods ENABLED" or "Gun Mods DISABLED",
            Time = 3
        })
    end
})

OrionLib:MakeNotification({
    Name = "Vortex Hub V2.8",
    Content = "All features loaded successfully!",
    Time = 5
})

OrionLib:Init()

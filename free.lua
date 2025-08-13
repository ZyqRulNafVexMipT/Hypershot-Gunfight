--  ██████  ██░ ██  ██░ ██  ▄▄▄█████▓ ▄▄▄       ██ ▄█▀
--▒██    ▒ ▓██░ ██▒▓██░ ██▒▓  ██▒ ▓▒▒████▄     ██▄█▒ 
--░ ▓██▄   ▒██▀▀██░▒██▀▀██░▒ ▓██░ ▒░▒██  ▀█▄  ▓███▄░ 
--  ▒   ██▒░▓█ ░██ ░▓█ ░██ ░ ▓██▓ ░ ░██▄▄▄▄██ ▓██ █▄ 
--▒██████▒▒░▓█▒░██▓░▓█▒░██▓  ▒██▒ ░  ▓█   ▓██▒▒██▒ █▄
--▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒ ▒ ░░▒░▒  ▒ ░░    ▒▒   ▓▒█░▒ ▒▒ ▓▒
--░ ░▒  ░ ░ ▒ ░▒░ ░ ▒ ░▒░ ░    ░      ▒   ▒▒ ░░ ░▒ ▒░
--░  ░  ░   ░  ░░ ░ ░  ░░ ░  ░        ░   ▒   ░ ░░ ░ 
--      ░   ░  ░  ░ ░  ░  ░                ░  ░░  ░   

--  Hypershot GunFight – Nebula-Starlight Edition
--  v2.1  |  14-Aug-2025
-----------------------------------------------------------------

local Starlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Starlight-Interface-Suite/master/Source.lua"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/Loader.lua"))()

-----------------------------------------------------------------
-- 0. Services & globals
-----------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Master switches
getgenv().AimbotEnabled       = false
getgenv().BringPlayersEnabled = false
getgenv().AutoFarmEnabled     = false
getgenv().InfiniteAmmoEnabled = false
getgenv().AutoCollectEnabled  = false
getgenv().TeamCheckEnabled    = true   -- new
getgenv().AntiCheatEnabled    = true   -- new

-----------------------------------------------------------------
-- 1. Nebula-Starlight UI (replaces Orion)
-----------------------------------------------------------------
local Window = Starlight:CreateWindow({
    Name = "Hypershot GunFight",
    Subtitle = "Nebula Edition v2.1",
    Icon = NebulaIcons:GetIcon("sports_esports", "Material"),
    LoadingSettings = {
        Title = "Hypershot GunFight",
        Subtitle = "by VortX",
    },
    ConfigurationSettings = { FolderName = "Hypershot_Nebula" }
})

local TabSection = Window:CreateTabSection("Main")
local CombatTab  = TabSection:CreateTab({ Name = "Combat", Icon = NebulaIcons:GetIcon("target", "Lucide"), Columns = 2 })
local AutoTab    = TabSection:CreateTab({ Name = "Auto",   Icon = NebulaIcons:GetIcon("autorenew", "Material"), Columns = 2 })

-----------------------------------------------------------------
-- 2. Anti-Cheat bypass layers
-----------------------------------------------------------------
local function cloakMetatable()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = newcclosure(function(self, key)
        if getgenv().AntiCheatEnabled and key == "CurrentCamera" and self == workspace then
            return Camera
        end
        return old(self, key)
    end)
end
cloakMetatable()

-- Randomised firerate jitter (simple)
local function randomDelay() return 0.03 + math.random() * 0.03 end

-----------------------------------------------------------------
-- 3. AI calibration & prediction
-----------------------------------------------------------------
local AI = {
    bulletSpeed = 2500,   -- adjust per weapon if needed
    gravity     = workspace.Gravity,
    lastTarget  = nil,
    missCount   = 0
}

function AI.predictHead(player, delta)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return nil end
    local head = char.Head
    local vel  = head.Velocity
    local pos  = head.Position
    local lead = vel * delta
    local drop = Vector3.new(0, -AI.gravity * 0.5 * delta^2, 0)
    return pos + lead + drop
end

function AI.getClosestPlayer()
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local human = char:FindFirstChildOfClass("Humanoid")
        if not human or human.Health <= 0 then continue end
        -- Team check
        if getgenv().TeamCheckEnabled and plr.Team and plr.Team == LocalPlayer.Team then continue end

        local pred = AI.predictHead(plr, 0.25)
        local screen, onScreen = Camera:WorldToViewportPoint(pred)
        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screen.X, screen.Y)).Magnitude
        if dist < minDist and dist < 500 and onScreen then
            closest, minDist = plr, dist
        end
    end
    -- re-lock if last target disappeared
    if AI.lastTarget and AI.lastTarget ~= closest then AI.missCount += 1 end
    AI.lastTarget = closest
    return closest
end

-----------------------------------------------------------------
-- 4. Silent-Aim hook (forces headshot)
-----------------------------------------------------------------
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if getgenv().AimbotEnabled and method == "FindPartOnRayWithIgnoreList" then
        local closest = AI.getClosestPlayer()
        if closest then
            local origin = Camera.CFrame.Position
            local target = AI.predictHead(closest, 0.25)
            local direction = (target - origin).Unit * 5000
            local newRay = Ray.new(origin, direction)
            return oldNamecall(self, newRay, ...)
        end
    end
    return oldNamecall(self, ...)
end)

-----------------------------------------------------------------
-- 5. Bring Mobs (unchanged, auto-reconnect on respawn)
-----------------------------------------------------------------
local teleportDistance = 5
RunService.RenderStepped:Connect(function()
    if not getgenv().BringPlayersEnabled then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetPos = root.Position + root.CFrame.LookVector * teleportDistance
    for _, mob in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if mob:IsA("Model") and mob.PrimaryPart then
            mob:SetPrimaryPartCFrame(CFrame.new(targetPos))
        end
    end
end)

-----------------------------------------------------------------
-- 6. Auto-Farm + Rapid-Fire
-----------------------------------------------------------------
local function autoFarm()
    if not getgenv().AutoFarmEnabled then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetPos = root.Position + root.CFrame.LookVector * 5
    for _, mob in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if mob:IsA("Model") and mob:FindFirstChild("Head") then
            local head = mob.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if distance < 500 and onScreen and ReplicatedStorage:FindFirstChild("Shoot") then
                ReplicatedStorage.Shoot:FireServer()
                task.wait(randomDelay()) -- anti-cheat jitter
            end
        end
    end
end
RunService.RenderStepped:Connect(autoFarm)

-- Rapid-Fire while holding LMB
RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarmEnabled and Mouse:IsMouseButtonPressed(0) and ReplicatedStorage:FindFirstChild("Shoot") then
        ReplicatedStorage.Shoot:FireServer()
        task.wait(randomDelay())
    end
end)

-----------------------------------------------------------------
-- 7. Infinite Ammo
-----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().InfiniteAmmoEnabled then return end
    local tools = LocalPlayer.Backpack:GetChildren()
    for _, t in ipairs(LocalPlayer.Character:GetChildren()) do table.insert(tools, t) end
    for _, tool in ipairs(tools) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
            tool.Ammo = 9999
        end
    end
end)

-----------------------------------------------------------------
-- 8. Auto Collect coins / heals
-----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not getgenv().AutoCollectEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and (part.Name:lower() == "coin" or part.Name:lower() == "heal") then
            if (part.Position - root.Position).Magnitude <= 50 then
                part.CFrame = root.CFrame
            end
        end
    end
end)

-----------------------------------------------------------------
-- 9. UI controls
-----------------------------------------------------------------
local function notify(title, msg)
    Window:Notify({ Title = title, Content = msg, Duration = 3 })
end

CombatTab:CreateToggle({
    Name = "100 % Headshot Aimbot",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AimbotEnabled = v
        notify("Aimbot", v and "ON – 100 % Headshot" or "OFF")
    end
})

CombatTab:CreateToggle({
    Name = "Team Check (ignore allies)",
    CurrentValue = true,
    Callback = function(v)
        getgenv().TeamCheckEnabled = v
        notify("Team Check", v and "ON" or "OFF")
    end
})

CombatTab:CreateToggle({
    Name = "Bring Mobs",
    CurrentValue = false,
    Callback = function(v)
        getgenv().BringPlayersEnabled = v
        notify("Bring Mobs", v and "ON" or "OFF")
    end
})

CombatTab:CreateToggle({
    Name = "Auto Farm Kill",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoFarmEnabled = v
        notify("Auto Farm", v and "ON" or "OFF")
    end
})

CombatTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Callback = function(v)
        getgenv().InfiniteAmmoEnabled = v
        notify("Infinite Ammo", v and "ON" or "OFF")
    end
})

AutoTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoCollectEnabled = v
        notify("Auto Collect", v and "ON" or "OFF")
    end
})

-----------------------------------------------------------------
-- 10. Final notification
-----------------------------------------------------------------
Window:Notify({ Title = "Hypershot GunFight", Content = "All features loaded & cloaked!", Duration = 5 })

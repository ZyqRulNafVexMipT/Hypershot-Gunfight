-----------------------------------------------------------------
--  Hypershot GunFight V3  |  Nebula-Starlight Edition
--  14-Aug-2025
-----------------------------------------------------------------

-- 1) Load UI Library & Icons
local Starlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Starlight-Interface-Suite/master/Source.lua"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/Loader.lua"))()

-- 2) Services
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local Camera  = workspace.CurrentCamera
local LP      = Players.LocalPlayer
local Mouse   = LP:GetMouse()

-- 3) Globals
local g = getgenv()
g.AimbotEnabled       = false
g.BringMobsEnabled    = false
g.AutoFarmEnabled     = false
g.InfAmmoEnabled      = false
g.AutoCollectEnabled  = false
g.TeamCheckEnabled    = true
g.AntiCheatEnabled    = true

-----------------------------------------------------------------
-- 4) Anti-Cheat layer
-----------------------------------------------------------------
do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = newcclosure(function(self, k)
        if g.AntiCheatEnabled and k == "CurrentCamera" and self == workspace then
            return Camera
        end
        return old(self, k)
    end)
end

-----------------------------------------------------------------
-- 5) AI engine
-----------------------------------------------------------------
local AI = {
    bulletSpeed = 2800,
    gravity     = workspace.Gravity,
    lastTarget  = nil
}

function AI.predictHead(plr, t)
    local c = plr.Character
    if not (c and c:FindFirstChild("Head")) then return nil end
    local h = c.Head
    local v = h.Velocity
    local p = h.Position
    local lead = v * t
    local drop = Vector3.new(0, -AI.gravity * 0.5 * t^2, 0)
    return p + lead + drop
end

function AI.getClosest()
    local closest, min = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local c = p.Character
        if not (c and c:FindFirstChild("Head") and c:FindFirstChildOfClass("Humanoid")) then continue end
        if c:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
        if g.TeamCheckEnabled and p.Team and p.Team == LP.Team then continue end

        local pos = AI.predictHead(p, 0.25)
        if not pos then continue end
        local screen, on = Camera:WorldToViewportPoint(pos)
        local d = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screen.X, screen.Y)).Magnitude
        if d < min and d < 500 and on then
            closest, min = p, d
        end
    end
    AI.lastTarget = closest
    return closest
end

-----------------------------------------------------------------
-- 6) Silent-Aim hook (forces head)
-----------------------------------------------------------------
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if g.AimbotEnabled and method == "FindPartOnRayWithIgnoreList" then
        local target = AI.getClosest()
        if target then
            local origin = Camera.CFrame.Position
            local dir = (AI.predictHead(target, 0.25) - origin).Unit * 5000
            return old(self, Ray.new(origin, dir), ...)
        end
    end
    return old(self, ...)
end)

-----------------------------------------------------------------
-- 7) Bring Mobs
-----------------------------------------------------------------
local tpDist = 5
RS.RenderStepped:Connect(function()
    if not g.BringMobsEnabled then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tgt = root.Position + root.CFrame.LookVector * tpDist
    for _, m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m.PrimaryPart then
            m:SetPrimaryPartCFrame(CFrame.new(tgt))
        end
    end
end)

-----------------------------------------------------------------
-- 8) Auto-Farm & Rapid-Fire
-----------------------------------------------------------------
local function autofarm()
    if not g.AutoFarmEnabled then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Head") then
            local head = m.Head
            local sp, on = Camera:WorldToViewportPoint(head.Position)
            local d = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(sp.X, sp.Y)).Magnitude
            if on and d < 500 and ReplicatedStorage:FindFirstChild("Shoot") then
                ReplicatedStorage.Shoot:FireServer()
                task.wait(0.03 + math.random()*0.03) -- jitter
            end
        end
    end
end
RS.RenderStepped:Connect(autofarm)

-----------------------------------------------------------------
-- 9) Inf Ammo
-----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not g.InfAmmoEnabled then return end
    local t = {}
    for _, v in ipairs(LP.Backpack:GetChildren()) do table.insert(t, v) end
    for _, v in ipairs(LP.Character:GetChildren()) do table.insert(t, v) end
    for _, tool in ipairs(t) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
            tool.Ammo = 9999
        end
    end
end)

-----------------------------------------------------------------
-- 10) Auto Collect
-----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not g.AutoCollectEnabled then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("Part") and (p.Name:lower() == "coin" or p.Name:lower() == "heal") and (p.Position - root.Position).Magnitude <= 50 then
            p.CFrame = root.CFrame
        end
    end
end)

-----------------------------------------------------------------
-- 11) UI – Starlight + NebulaIcons
-----------------------------------------------------------------
local W = Starlight:CreateWindow({
    Name = "Hypershot GunFight",
    Subtitle = "v3 – Nebula Edition",
    Icon = NebulaIcons:GetIcon("sports_esports", "Material"),
    LoadingSettings = { Title = "Loading Hypershot...", Subtitle = "by VortX" },
    ConfigurationSettings = { FolderName = "HypershotV3" }
})

local TS = W:CreateTabSection("Main")
local C  = TS:CreateTab({ Name = "Combat", Icon = NebulaIcons:GetIcon("target", "Lucide"), Columns = 2 })
local A  = TS:CreateTab({ Name = "Auto",   Icon = NebulaIcons:GetIcon("autorenew", "Material"), Columns = 2 })

local G1 = C:CreateGroupbox({ Name = "Combat", Column = 1 })
local G2 = A:CreateGroupbox({ Name = "Auto",   Column = 1 })

local function notify(t, m) W:Notify({ Title = t, Content = m, Duration = 3 }) end

G1:CreateToggle({ Name = "100% HS Aimbot", CurrentValue = false, Callback = function(v) g.AimbotEnabled = v; notify("Aimbot", v and "ON" or "OFF") end })
G1:CreateToggle({ Name = "Team Check",     CurrentValue = true,  Callback = function(v) g.TeamCheckEnabled = v; notify("Team", v and "ON" or "OFF") end })
G1:CreateToggle({ Name = "Bring Mobs",     CurrentValue = false, Callback = function(v) g.BringMobsEnabled = v; notify("Bring", v and "ON" or "OFF") end })
G1:CreateToggle({ Name = "Auto Farm",      CurrentValue = false, Callback = function(v) g.AutoFarmEnabled = v; notify("Farm", v and "ON" or "OFF") end })
G1:CreateToggle({ Name = "Inf Ammo",       CurrentValue = false, Callback = function(v

-- ============================================================
--  VortX Hub | Hypershot V2 BETA
--  Part 1/3 – UI + Variable Declarations
--  Powered by Luna Interface Suite
-- ============================================================

-- Fast require Luna
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- ------------------------------------------------------------------
-- 1.  Window & Branding
-- ------------------------------------------------------------------
local Window = Luna:CreateWindow({
    Name           = "VortX Hub",
    Subtitle       = "Hypershot V2 BETA",
    LogoID         = "117301323235823",          -- VortX logo (change if you have a custom one)
    LoadingEnabled = true,
    LoadingTitle   = "VortX Hub",
    LoadingSubtitle= "Injecting Hypershot V2 BETA...",

    ConfigSettings = {
        ConfigFolder = "VortX_Hypershot_V2"
    },

    KeySystem      = false   -- feel free to flip if you want a key later
})

-- ------------------------------------------------------------------
-- 2.  Tabs
-- ------------------------------------------------------------------
local MainTab   = Window:CreateTab({ Name = "Main",   Icon = "sports_esports", ImageSource = "Material", ShowTitle = true })
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "target",         ImageSource = "Material", ShowTitle = true })
local VisualTab = Window:CreateTab({ Name = "Visual", Icon = "visibility",     ImageSource = "Material", ShowTitle = true })
local FarmTab   = Window:CreateTab({ Name = "Farm",   Icon = "speed",          ImageSource = "Material", ShowTitle = true })
local MiscTab   = Window:CreateTab({ Name = "Misc",   Icon = "settings",       ImageSource = "Material", ShowTitle = true })

-- ------------------------------------------------------------------
-- 3.  Feature Flags & Global Vars
-- ------------------------------------------------------------------
getgenv().SilentAimEnabled   = true   -- 100 % headshot
getgenv().WallHackEnabled    = true   -- transparent walls
getgenv().HealthBarESP       = true
getgenv().NameESP            = true
getgenv().AutoFire           = false
getgenv().RapidFire          = false
getgenv().Prediction         = 0.12   -- bullet lead (sec)
getgenv().HitboxExpand       = 2.0
getgenv().AutoFarm           = false  -- teleport behind & insta-kill
getgenv().GodModeOnFarm      = true   -- invis + undamageable
getgenv().BringHeads         = false
getgenv().AimbotKey          = Enum.KeyCode.E
getgenv().FarmRange          = 200    -- studs
getgenv().ESPTextSize        = 14

-- ------------------------------------------------------------------
-- 4.  UI Elements
-- ------------------------------------------------------------------

-- 4.1 Main Tab
MainTab:CreateToggle({
    Name = "Silent Aim (100% Headshot)",
    CurrentValue = getgenv().SilentAimEnabled,
    Callback = function(v) getgenv().SilentAimEnabled = v end
}, "SilentAim")

MainTab:CreateToggle({
    Name = "Transparent Walls (Nearby)",
    CurrentValue = getgenv().WallHackEnabled,
    Callback = function(v) getgenv().WallHackEnabled = v end
}, "WallHack")

-- 4.2 Combat Tab
CombatTab:CreateToggle({
    Name = "Auto Fire",
    CurrentValue = getgenv().AutoFire,
    Callback = function(v) getgenv().AutoFire = v end
}, "AutoFire")

CombatTab:CreateToggle({
    Name = "Rapid Fire",
    CurrentValue = getgenv().RapidFire,
    Callback = function(v) getgenv().RapidFire = v end
}, "RapidFire")

CombatTab:CreateSlider({
    Name = "Prediction (sec)",
    Range = {0, 0.5},
    Increment = 0.01,
    CurrentValue = getgenv().Prediction,
    Callback = function(v) getgenv().Prediction = v end
}, "Prediction")

CombatTab:CreateSlider({
    Name = "Hitbox Expand (studs)",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = getgenv().HitboxExpand,
    Callback = function(v) getgenv().HitboxExpand = v end
}, "HitboxExpand")

CombatTab:CreateBind({
    Name = "Aimbot Key",
    CurrentBind = "E",
    HoldToInteract = false,
    Callback = function() end,
    OnChangedCallback = function(key) getgenv().AimbotKey = key end
}, "AimbotKey")

-- 4.3 Visual Tab
VisualTab:CreateToggle({
    Name = "Health Bar ESP",
    CurrentValue = getgenv().HealthBarESP,
    Callback = function(v) getgenv().HealthBarESP = v end
}, "HealthBarESP")

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = getgenv().NameESP,
    Callback = function(v) getgenv().NameESP = v end
}, "NameESP")

VisualTab:CreateSlider({
    Name = "ESP Text Size",
    Range = {10, 30},
    Increment = 1,
    CurrentValue = getgenv().ESPTextSize,
    Callback = function(v) getgenv().ESPTextSize = v end
}, "ESPTextSize")

-- 4.4 Farm Tab
FarmTab:CreateToggle({
    Name = "Auto Farm (Tele-Kill)",
    CurrentValue = getgenv().AutoFarm,
    Callback = function(v)
        getgenv().AutoFarm = v
        if v then
            Luna:Notification({
                Title = "Auto-Farm ON",
                Content = "You are now invisible & undamageable."
            })
        end
    end
}, "AutoFarm")

FarmTab:CreateToggle({
    Name = "God-Mode During Farm",
    CurrentValue = getgenv().GodModeOnFarm,
    Callback = function(v) getgenv().GodModeOnFarm = v end
}, "GodModeOnFarm")

FarmTab:CreateSlider({
    Name = "Farm Range (studs)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = getgenv().FarmRange,
    Callback = function(v) getgenv().FarmRange = v end
}, "FarmRange")

-- 4.5 Misc Tab
MiscTab:CreateToggle({
    Name = "Bring Heads",
    CurrentValue = getgenv().BringHeads,
    Callback = function(v) getgenv().BringHeads = v end
}, "BringHeads")

-- ------------------------------------------------------------------
-- 5.  Import next script chunk
-- ------------------------------------------------------------------
-- =====================================================================
--  VortX Hub | Hypershot V2 BETA
--  Part 2/3 – Core Combat & World Logic
-- =====================================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Workspace    = game:GetService("Workspace")
local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera
local Mouse        = LocalPlayer:GetMouse()

-- ------------------------------------------------------------------
-- Utility
-- ------------------------------------------------------------------
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if d < dist then
                    closest, dist = plr, d
                end
            end
        end
    end
    return closest
end

-- ------------------------------------------------------------------
-- 1. SILENT AIM 100 % HEADSHOT + PREDICTION
-- ------------------------------------------------------------------
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if getgenv().SilentAimEnabled and method == "FireServer" and tostring(self) == "RemoteEvent" then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local vel = head.Velocity
            local predicted = head.Position + vel * getgenv().Prediction
            -- Expand hitbox
            local offset = Vector3.new(
                math.random(-getgenv().HitboxExpand, getgenv().HitboxExpand),
                math.random(-getgenv().HitboxExpand, getgenv().HitboxExpand),
                math.random(-getgenv().HitboxExpand, getgenv().HitboxExpand)
            )
            local args = {...}
            if typeof(args[1]) == "CFrame" then
                args[1] = CFrame.new(predicted + offset)
            elseif typeof(args[1]) == "Vector3" then
                args[1] = predicted + offset
            end
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)

-- ------------------------------------------------------------------
-- 2. RAPID FIRE
-- ------------------------------------------------------------------
local function enableRapid()
    for _,v in next, getgc(true) do
        if typeof(v) == "table" and rawget(v, "FireRate") then
            v.FireRate = 0.02
        end
    end
end
RunService.RenderStepped:Connect(function()
    if getgenv().RapidFire then enableRapid() end
end)

-- ------------------------------------------------------------------
-- 3. AUTO FIRE (hold mouse when target visible)
-- ------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if getgenv().AutoFire then
        local t = getClosestPlayer()
        if t then
            mouse1press(); wait(); mouse1release()
        end
    end
end)

-- ------------------------------------------------------------------
-- 4. WALL TRANSPARENCY (nearby parts)
-- ------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if getgenv().WallHackEnabled and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and not part:IsDescendantOf(LocalPlayer.Character) then
                local d = (part.Position - root.Position).Magnitude
                part.LocalTransparencyModifier = d < 20 and 0.8 or 0
            end
        end
    end
end)

-- ------------------------------------------------------------------
-- 5. BRING HEADS
-- ------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if getgenv().BringHeads then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                plr.Character.Head.CFrame = CFrame.new(Camera.CFrame.Position + Camera.CFrame.LookVector * 10)
            end
        end
    end
end)

-- ------------------------------------------------------------------
-- Load final chunk (ESP + Auto-Farm)
-- ------------------------------------------------------------------
-- =====================================================================
--  VortX Hub | Hypershot V2 BETA
--  Part 3/3 – ESP + Auto-Farm + God-Mode
-- =====================================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Workspace    = game:GetService("Workspace")
local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera

-- ------------------------------------------------------------------
-- 1. ESP (Name + Health-Bar)
-- ------------------------------------------------------------------
local function createESP(player)
    local char = player.Character
    if not char or char:FindFirstChild("VortX_ESP") then return end

    -- Billboard
    local bb = Instance.new("BillboardGui")
    bb.Name = "VortX_ESP"
    bb.Adornee = char:WaitForChild("Head")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 120, 0, 45)
    bb.StudsOffset = Vector3.new(0, 3, 0)

    -- Name
    local name = Instance.new("TextLabel")
    name.Name = "NameLabel"
    name.Size = UDim2.new(1, 0, 0.5, 0)
    name.BackgroundTransparency = 1
    name.Text = player.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0
    name.Font = Enum.Font.GothamBold
    name.TextScaled = true
    name.Parent = bb

    -- Health-Bar frame
    local bar = Instance.new("Frame")
    bar.Name = "HealthBar"
    bar.Size = UDim2.new(1, 0, 0.15, 0)
    bar.Position = UDim2.new(0, 0, 0.6, 0)
    bar.BackgroundColor3 = Color3.new(0,0,0)
    bar.BorderSizePixel = 0
    bar.Parent = bb

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0,1,0)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    bb.Parent = char:WaitForChild("Head")
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if not head then continue end

            local bb = head:FindFirstChild("VortX_ESP")
            if getgenv().NameESP or getgenv().HealthBarESP then
                if not bb then createESP(plr) end
                if bb then
                    bb.Enabled = true
                    local nameLbl = bb:FindFirstChild("NameLabel")
                    local fill = bb:FindFirstChild("HealthBar") and bb.HealthBar:FindFirstChild("Fill")
                    if nameLbl then
                        nameLbl.Text = plr.Name
                        nameLbl.TextSize = getgenv().ESPTextSize
                    end
                    if fill then
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local pct = hum.Health / hum.MaxHealth
                            fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
                            fill.BackgroundColor3 = Color3.fromHSV(pct * 0.3, 1, 1) -- red→green
                        end
                    end
                end
            else
                if bb then bb.Enabled = false end
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- ------------------------------------------------------------------
-- 2. AUTO-FARM (Teleport behind + Invisible + Undamageable)
-- ------------------------------------------------------------------
local lastTarget
local function getFarmTarget()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local closest, dist = nil, getgenv().FarmRange
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if d < dist then
                closest, dist = plr, d
            end
        end
    end
    return closest
end

-- God-Mode (invisible + undamageable)
local function setGod(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
            v.LocalTransparencyModifier = state and 1 or 0
            if state then v.Transparency = 1 end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not state)
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().AutoFarm then
        local target = getFarmTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            lastTarget = target
            local tRoot = target.Character.HumanoidRootPart
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if getgenv().GodModeOnFarm then setGod(true) end
                -- Teleport behind
                local behind = tRoot.CFrame * CFrame.new(0, 0, 4)
                root.CFrame = behind
                -- Auto-shoot
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("RemoteEvent") then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        local vel = head.Velocity
                        local predicted = head.Position + vel * getgenv().Prediction
                        tool.RemoteEvent:FireServer(predicted)
                    end
                end
            end
        end
    else
        if lastTarget then
            setGod(false)
            lastTarget = nil
        end
    end
end)

-- ------------------------------------------------------------------
-- Ready notification
-- ------------------------------------------------------------------
Luna:Notification({
    Title   = "VortX Hub V2 BETA",
    Content = "All systems loaded. 100 % head-shot & auto-farm ready.",
    Icon    = "check_circle"
})


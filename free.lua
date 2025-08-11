local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Win = OrionLib:MakeWindow({
    Name = "VortX Hub •  Gunfight",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HypershotV2"
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Services
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local UIS         = game:GetService("UserInputService")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Core features toggles
local Config = {
    SilentAim   = true,
    FOV         = 120,
    AimBone     = "Head",
    ShowFOV     = true,
    ShowESP     = true,
    ShowSkel    = true,
    ShowNames   = true,
    Wallhack    = true,
    BringAll    = false,
    NoRecoil    = true,
    InfAmmo     = true
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Silent-Aim
local FOVCirc = Drawing.new("Circle")
FOVCirc.Visible = Config.ShowFOV
FOVCirc.Color   = Color3.fromRGB(255, 0, 0)
FOVCirc.Thickness = 2
FOVCirc.Radius    = Config.FOV
FOVCirc.Position  = Camera.ViewportSize / 2

local function closestPlayer()
    local near, dist = nil, math.huge
    local mouse = UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(Config.AimBone) then
            local head = p.Character[Config.AimBone]
            local pos, on = Camera:WorldToViewportPoint(head.Position)
            if on then
                local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if d < dist and d < Config.FOV then
                    near, dist = head, d
                end
            end
        end
    end
    return near
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Gun-Mods (spread / recoil / ammo)
local function applyGunMods()
    for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Spread") then
            v.Spread        = 0
            v.BaseSpread    = 0
            v.MinCamRecoil  = Vector3.new()
            v.MaxCamRecoil  = Vector3.new()
            v.MinRotRecoil  = Vector3.new()
            v.MaxRotRecoil  = Vector3.new()
            v.MinTransRecoil = Vector3.new()
            v.MaxTransRecoil = Vector3.new()
            v.Ammo          = math.huge
            v.MaxAmmo       = math.huge
            v.ScopeSpeed    = 100
        end
    end
end
if Config.NoRecoil or Config.InfAmmo then applyGunMods() end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ESP – Skeleton + Name
local espObjects = {}
local function createESP(p)
    local char = p.Character or p.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local head = char:WaitForChild("Head")

    local function build()
        local bones = {
            ["Head"]  = head,
            ["Torso"] = hrp,
            ["LeftArm"] = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
            ["RightArm"] = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
            ["LeftLeg"] = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
            ["RightLeg"] = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
        }

        -- Skeleton
        local skel = {}
        for _,part in pairs(bones) do
            if part then
                local d = Drawing.new("Circle")
                d.Visible = Config.ShowSkel
                d.Color   = Color3.new(1,1,1)
                d.Radius  = 4
                d.Filled  = true
                table.insert(skel, {d, part})
            end
        end

        -- Name
        local nam = Drawing.new("Text")
        nam.Visible = Config.ShowNames
        nam.Color   = Color3.new(1,1,1)
        nam.Center  = true
        nam.Outline = true
        nam.Text    = p.Name
        nam.Size    = 18

        espObjects[p] = {nam = nam, skel = skel}
    end
    build()
    p.CharacterAdded:Connect(build)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Wallhack – nearby walls transparent
local function wallhack()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 and (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 30 then
            v.LocalTransparencyModifier = 0.8
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Bring All – teleport everyone in front
local function bringAll()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = root.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ESP loop
RunService.RenderStepped:Connect(function()
    FOVCirc.Radius = Config.FOV
    FOVCirc.Visible = Config.ShowFOV
    FOVCirc.Position = Camera.ViewportSize / 2

    -- Update ESP
    for p, obj in pairs(espObjects) do
        local char = p.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
                obj.nam.Visible = vis and Config.ShowNames
                obj.nam.Position = Vector2.new(pos.X, pos.Y)

                for _,d in ipairs(obj.skel) do
                    local partPos, v2 = Camera:WorldToViewportPoint(d[2].Position)
                    d[1].Visible = v2 and Config.ShowSkel
                    d[1].Position = Vector2.new(partPos.X, partPos.Y)
                end
            end
        end
    end

    -- Wallhack
    if Config.Wallhack then wallhack() end
    -- Bring All
    if Config.BringAll then bringAll() Config.BringAll = false end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  UI Tabs
local MainTab = Win:MakeTab({Name = "Main"})
MainTab:AddToggle({
    Name = "Silent-Aim",
    Default = Config.SilentAim,
    Callback = function(v) Config.SilentAim = v end
})

MainTab:AddSlider({
    Name = "FOV",
    Min = 30,
    Max = 300,
    Default = Config.FOV,
    Callback = function(v) Config.FOV = v end
})

MainTab:AddDropdown({
    Name = "Aim-Bone",
    Default = Config.AimBone,
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    Callback = function(v) Config.AimBone = v end
})

local VisualsTab = Win:MakeTab({Name = "Visuals"})
VisualsTab:AddToggle({
    Name = "Show ESP",
    Default = Config.ShowESP,
    Callback = function(v) Config.ShowESP = v end
})
VisualsTab:AddToggle({
    Name = "Skeleton",
    Default = Config.ShowSkel,
    Callback = function(v) Config.ShowSkel = v end
})
VisualsTab:AddToggle({
    Name = "Names",
    Default = Config.ShowNames,
    Callback = function(v) Config.ShowNames = v end
})
VisualsTab:AddToggle({
    Name = "Wallhack (nearby)",
    Default = Config.Wallhack,
    Callback = function(v) Config.Wallhack = v end
})

local MiscTab = Win:MakeTab({Name = "Misc"})
MiscTab:AddToggle({
    Name = "No-Recoil / Spread",
    Default = Config.NoRecoil,
    Callback = function(v) Config.NoRecoil = v; applyGunMods() end
})
MiscTab:AddToggle({
    Name = "Infinite Ammo",
    Default = Config.InfAmmo,
    Callback = function(v) Config.InfAmmo = v; applyGunMods() end
})
MiscTab:AddButton({
    Name = "Bring All Players",
    Callback = bringAll
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Hypershot V2 – Bagian 2/3
--  AI Prediction + 100 % Headshot Redirect
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players     = game:GetService("Players")
local Workspace   = game:GetService("Workspace")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Settings (auto-sync dari Bagian 1)
local Config = {
    SilentAim   = true,   -- toggle dari UI tab 1
    AimBone     = "Head", -- dropdown dari UI tab 1
    FOV         = 120
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  AI Prediction Engine
local function predictTargetPosition(targetPart)
    -- Hitung waktu peluru ke target
    local dist   = (targetPart.Position - Camera.CFrame.Position).Magnitude
    local bulletTime = dist / 1500 -- 1500 stud/s (adjust sesuai senjata)

    -- Prediksi posisi target berdasarkan velocity
    local vel    = targetPart.Velocity
    local drop   = 0.5 * workspace.Gravity * bulletTime^2
    local future = targetPart.Position +
                   vel * bulletTime +
                   Vector3.new(0, -drop, 0)

    return future
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Target finder
local function getBestTarget()
    local mousePos = UIS:GetMouseLocation()
    local closest, minDist = nil, Config.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bone = p.Character:FindFirstChild(Config.AimBone)
            if bone then
                local screen, on = Camera:WorldToViewportPoint(bone.Position)
                if on then
                    local dist = (mousePos - Vector2.new(screen.X, screen.Y)).Magnitude
                    if dist < minDist then
                        closest, minDist = bone, dist
                    end
                end
            end
        end
    end
    return closest
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Hook Raycast → redirect ke head prediksi
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}

    if not checkcaller() and method == "Raycast" and Config.SilentAim then
        local target = getBestTarget()
        if target then
            local aimPos = predictTargetPosition(target)
            local origin = args[1]
            local dir    = (aimPos - origin).Unit * 5000
            args[2] = dir
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Auto-fire helper (opsional)
local autoFire = false
local function autoShoot()
    if autoFire and Config.SilentAim and getBestTarget() then
        mouse1click()
    end
end
RunService.RenderStepped:Connect(autoShoot)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Tambah tab khusus AI (bisa di-merge ke tab 1)
local OrionLib = getgenv().OrionLib -- asumsi sudah ada di global
local AITab = OrionLib:MakeTab({Name = "AI"})
AITab:AddToggle({
    Name = "Auto-Fire",
    Default = autoFire,
    Callback = function(v) autoFire = v end
})
AITab:AddLabel("AI 100 % headshot active")

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Hypershot V2 – Bagian 3/3
--  Advanced Extras + Keybinds + Config
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Tween       = game:GetService("TweenService")

local LP          = Players.LocalPlayer
local OrionLib    = getgenv().OrionLib   -- sudah load di bagian 1

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Config tambahan (auto-save)
local Advanced = {
    DropComp      = true,   -- kompensasi bullet drop
    TriggerBot    = false,  -- auto-fire saat kursor di atas target
    FOVChanger    = 120,    -- override FOV
    Keybinds      = {
        ToggleSilent = Enum.KeyCode.LeftAlt,
        ToggleESP    = Enum.KeyCode.RightAlt,
        BringAll     = Enum.KeyCode.B,
        TriggerBot   = Enum.KeyCode.T
    },
    SaveCfg       = true
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Drop compensation (untuk long-range)
local function dropComp(origin, targetPos)
    if not Advanced.DropComp then return targetPos end
    local dist   = (targetPos - origin).Magnitude
    local bulletTime = dist / 1500
    local drop   = 0.5 * workspace.Gravity * bulletTime^2
    return targetPos - Vector3.new(0, drop, 0)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Trigger-Bot
local triggerBotActive = Advanced.TriggerBot
RunService.RenderStepped:Connect(function()
    if not triggerBotActive then return end
    local target = getgenv().getBestTarget and getgenv().getBestTarget() or nil
    if target then
        mouse1click()
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FOV slider override
local function setFOV(fov)
    workspace.CurrentCamera.FieldOfView = fov
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Keybind handler
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode

    if k == Advanced.Keybinds.ToggleSilent then
        Config.SilentAim = not Config.SilentAim
        OrionLib:MakeNotification({Name = "Silent-Aim", Content = Config.SilentAim and "ON" or "OFF", Time = 2})
    elseif k == Advanced.Keybinds.ToggleESP then
        Config.ShowESP = not Config.ShowESP
        OrionLib:MakeNotification({Name = "ESP", Content = Config.ShowESP and "ON" or "OFF", Time = 2})
    elseif k == Advanced.Keybinds.BringAll then
        getgenv().bringAll()
    elseif k == Advanced.Keybinds.TriggerBot then
        triggerBotActive = not triggerBotActive
        OrionLib:MakeNotification({Name = "Trigger-Bot", Content = triggerBotActive and "ON" or "OFF", Time = 2})
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Tab Advanced
local AdvTab = OrionLib:MakeTab({Name = "Advanced"})
AdvTab:AddToggle({
    Name = "Drop Compensation",
    Default = Advanced.DropComp,
    Callback = function(v) Advanced.DropComp = v end
})
AdvTab:AddToggle({
    Name = "Trigger-Bot",
    Default = triggerBotActive,
    Callback = function(v) triggerBotActive = v end
})
AdvTab:AddSlider({
    Name = "FOV Override",
    Min = 30,
    Max = 120,
    Default = Advanced.FOVChanger,
    Callback = function(v)
        Advanced.FOVChanger = v
        setFOV(v)
    end
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Config saver
local Http = game:GetService("HttpService")
local Folder = "HypershotV2"

local function save()
    if not isfolder(Folder) then makefolder(Folder) end
    writefile(Folder .. "/advanced.txt", Http:JSONEncode(Advanced))
end

local function load()
    local path = Folder .. "/advanced.txt"
    if isfile(path) then
        local data = Http:JSONDecode(readfile(path))
        for k,v in pairs(data) do Advanced[k] = v end
    end
end

AdvTab:AddButton({Name = "Save Config", Callback = save})
AdvTab:AddButton({Name = "Load Config", Callback = load})

-- load on start
load()

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Tampilkan info
OrionLib:MakeNotification({
    Name = "Hypershot V2 Loaded",
    Content = "LOADED.",
    Time = 4
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Init
OrionLib:Init()

-- Auto-ESP new players
Players.PlayerAdded:Connect(createESP)
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end

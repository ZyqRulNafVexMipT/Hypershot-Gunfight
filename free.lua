-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Hypershot V2 – FINAL SINGLE FILE
--  (UI lengkap + toggle on/off + FOV transparan)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FEATURE CONFIG
local Config = {
    SilentAim   = false,
    FOV         = 120,
    FOVColor    = Color3.fromRGB(255,0,0),
    FOVTrans    = 0.7,
    AimBone     = "Head",
    ShowFOV     = false,
    ShowESP     = false,
    ShowSkel    = false,
    ShowNames   = false,
    Wallhack    = false,
    BringAll    = false,
    NoRecoil    = false,
    InfAmmo     = false,
    DropComp    = false,
    TriggerBot  = false
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  DRAWING OBJECTS
local FOVCirc = Drawing.new("Circle")
FOVCirc.Visible = false
FOVCirc.Color   = Config.FOVColor
FOVCirc.Thickness = 2
FOVCirc.Filled = false
FOVCirc.Transparency = Config.FOVTrans

local espObjects = {}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SILENT-AIM + AI PREDICTION
local function predict(pos, vel)
    local dist = (pos - Camera.CFrame.Position).Magnitude
    local t = dist / 1500
    local drop = 0.5 * workspace.Gravity * t^2
    return pos + vel * t + Vector3.new(0, -drop, 0)
end

local function getBestTarget()
    local mouse = UIS:GetMouseLocation()
    local near, dist = nil, Config.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bone = p.Character:FindFirstChild(Config.AimBone)
            if bone then
                local screen, on = Camera:WorldToViewportPoint(bone.Position)
                if on then
                    local d = (Vector2.new(screen.X, screen.Y) - mouse).Magnitude
                    if d < dist then near, dist = bone, d end
                end
            end
        end
    end
    return near
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast" and Config.SilentAim then
        local target = getBestTarget()
        if target then
            local aim = Config.DropComp and predict(target.Position, target.Velocity) or target.Position
            args[2] = (aim - args[1]).Unit * 5000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  GUN-MODS
local function applyGunMods()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Spread") then
            v.Spread        = Config.NoRecoil and 0 or v.Spread
            v.BaseSpread    = Config.NoRecoil and 0 or v.BaseSpread
            v.MinCamRecoil  = Config.NoRecoil and Vector3.new() or v.MinCamRecoil
            v.MaxCamRecoil  = Config.NoRecoil and Vector3.new() or v.MaxCamRecoil
            v.Ammo          = Config.InfAmmo and math.huge or v.Ammo
            v.MaxAmmo       = Config.InfAmmo and math.huge or v.MaxAmmo
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ESP
local function createESP(p)
    local char = p.Character or p.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local hrp  = char:WaitForChild("HumanoidRootPart")

    -- Skeleton
    local skel = {}
    local function addSkel(part)
        if not part then return end
        local d = Drawing.new("Circle")
        d.Visible = false
        d.Color   = Color3.new(1,1,1)
        d.Radius  = 4
        d.Filled  = true
        table.insert(skel, {d, part})
    end
    addSkel(head)
    addSkel(hrp)
    addSkel(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
    addSkel(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
    addSkel(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
    addSkel(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

    -- Name
    local nam = Drawing.new("Text")
    nam.Visible = false
    nam.Color   = Color3.new(1,1,1)
    nam.Center  = true
    nam.Outline = true
    nam.Text    = p.Name
    nam.Size    = 18

    espObjects[p] = {nam = nam, skel = skel}

    p.CharacterAdded:Connect(function() createESP(p) end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  WALLHACK
local function wallhack()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            local dist = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if dist < 30 then
                v.LocalTransparencyModifier = Config.Wallhack and 0.8 or 0
            end
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  BRING ALL
local function bringAll()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = root.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  TRIGGER-BOT
local triggerActive = false
RunService.RenderStepped:Connect(function()
    triggerActive = Config.TriggerBot and getBestTarget()
    if triggerActive then mouse1click() end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVCirc.Visible = Config.ShowFOV
    FOVCirc.Radius   = Config.FOV
    FOVCirc.Color    = Config.FOVColor
    FOVCirc.Transparency = Config.FOVTrans
    FOVCirc.Position = Camera.ViewportSize / 2

    -- ESP update
    for p, obj in pairs(espObjects) do
        local char = p.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2,0))
                obj.nam.Visible = vis and Config.ShowNames
                obj.nam.Position = Vector2.new(pos.X, pos.Y)

                for _, s in ipairs(obj.skel) do
                    local p2, v2 = Camera:WorldToViewportPoint(s[2].Position)
                    s[1].Visible = v2 and Config.ShowSkel
                    s[1].Position = Vector2.new(p2.X, p2.Y)
                end
            end
        end
    end

    -- Wallhack
    wallhack()
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  UI
local Win = OrionLib:MakeWindow({
    Name = "Hypershot V2  •  FINAL",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HypershotV2"
})

local MainTab = Win:MakeTab({Name = "Main"})
MainTab:AddToggle({Name = "Silent-Aim", Default = Config.SilentAim, Callback = function(v) Config.SilentAim = v end})
MainTab:AddToggle({Name = "Show FOV", Default = Config.ShowFOV, Callback = function(v) Config.ShowFOV = v end})
MainTab:AddSlider({Name = "FOV Size", Min = 30, Max = 300, Default = Config.FOV, Callback = function(v) Config.FOV = v end})
MainTab:AddColorPicker({Name = "FOV Color", Default = Config.FOVColor, Callback = function(v) Config.FOVColor = v end})
MainTab:AddSlider({Name = "FOV Transparency", Min = 0, Max = 1, Default = Config.FOVTrans, Callback = function(v) Config.FOVTrans = v end})
MainTab:AddDropdown({Name = "Aim-Bone", Options = {"Head","HumanoidRootPart","UpperTorso"}, Default = Config.AimBone, Callback = function(v) Config.AimBone = v end})

local VisTab = Win:MakeTab({Name = "Visuals"})
VisTab:AddToggle({Name = "ESP", Default = Config.ShowESP, Callback = function(v) Config.ShowESP = v end})
VisTab:AddToggle({Name = "Skeleton", Default = Config.ShowSkel, Callback = function(v) Config.ShowSkel = v end})
VisTab:AddToggle({Name = "Names", Default = Config.ShowNames, Callback = function(v) Config.ShowNames = v end})
VisTab:AddToggle({Name = "Wallhack (nearby)", Default = Config.Wallhack, Callback = function(v) Config.Wallhack = v end})

local MiscTab = Win:MakeTab({Name = "Misc"})
MiscTab:AddToggle({Name = "No-Recoil / Spread", Default = Config.NoRecoil, Callback = function(v) Config.NoRecoil = v; applyGunMods() end})
MiscTab:AddToggle({Name = "Infinite Ammo", Default = Config.InfAmmo, Callback = function(v) Config.InfAmmo = v; applyGunMods() end})
MiscTab:AddToggle({Name = "Drop Compensation", Default = Config.DropComp, Callback = function(v) Config.DropComp = v end})
MiscTab:AddToggle({Name = "Trigger-Bot", Default = Config.TriggerBot, Callback = function(v) Config.TriggerBot = v end})
MiscTab:AddButton({Name = "Bring All Players", Callback = bringAll})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Auto-ESP & mods
applyGunMods()
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

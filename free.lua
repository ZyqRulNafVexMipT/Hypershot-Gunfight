-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – 1 FILE WORKING
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  KONFIG
local Config = {
    SilentAim   = false,
    FOV         = 120,
    FOVColor    = Color3.new(1,0,0),
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
    AutoHeal    = false
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  DRAWING
local FOVCirc = Drawing.new("Circle")
FOVCirc.Visible = false
FOVCirc.Color   = Config.FOVColor
FOVCirc.Thickness = 2
FOVCirc.Filled = false
FOVCirc.Transparency = Config.FOVTrans
FOVCirc.Position = Camera.ViewportSize / 2

local espObjects = {}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  GUN-MODS
local function applyGunMods()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Spread") then
            if Config.NoRecoil then
                v.Spread = 0; v.BaseSpread = 0
                v.MinCamRecoil = Vector3.new(); v.MaxCamRecoil = Vector3.new()
                v.MinRotRecoil = Vector3.new(); v.MaxRotRecoil = Vector3.new()
            end
            if Config.InfAmmo then
                v.Ammo = math.huge; v.MaxAmmo = math.huge
            end
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  AI PREDIKSI PRESISI
local function predictUltra(pos, vel)
    local dist   = (pos - Camera.CFrame.Position).Magnitude
    local travel = dist / 1500
    local drop   = 0.5 * workspace.Gravity * travel^2
    return pos + vel * travel + Vector3.new(0, -drop, 0)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  GET TARGET
local function getTarget()
    local mouse = UIS:GetMouseLocation()
    local near, min = nil, Config.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bone = p.Character:FindFirstChild(Config.AimBone)
            if bone then
                local screen, on = Camera:WorldToViewportPoint(bone.Position)
                if on then
                    local d = (Vector2.new(screen.X, screen.Y) - mouse).Magnitude
                    if d < min then near, min = bone, d end
                end
            end
        end
    end
    return near
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SILENT-AIM HOOK (SAFE, tidak hancur sistem)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast" and Config.SilentAim then
        local target = getTarget()
        if target then
            local aim = predictUltra(target.Position, target.Velocity)
            args[2] = (aim - args[1]).Unit * 5000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ESP
local function createESP(p)
    local char = p.Character or p.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local hrp  = char:WaitForChild("HumanoidRootPart")

    local skel = {}
    local function add(part)
        if not part then return end
        local d = Drawing.new("Circle")
        d.Visible = false; d.Color = Color3.new(1,1,1)
        d.Radius = 4; d.Filled = true
        table.insert(skel, {d, part})
    end
    add(head); add(hrp)
    add(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
    add(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
    add(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
    add(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

    local nam = Drawing.new("Text")
    nam.Visible = false; nam.Color = Color3.new(1,1,1); nam.Center = true
    nam.Outline = true; nam.Text = p.Name; nam.Size = 18

    espObjects[p] = {nam = nam, skel = skel}
    p.CharacterAdded:Connect(function() createESP(p) end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  WALLHACK
local function wallhack()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            local dist = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            v.LocalTransparencyModifier = (Config.Wallhack and dist < 30) and 0.8 or 0
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  BRING ALL (human only)
local function bringAll()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  AUTO-HEAL
local function autoHeal()
    if Config.AutoHeal and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if hum.Health < hum.MaxHealth then
            hum.Health = math.min(hum.Health + 5, hum.MaxHealth)
        end
    end
end
RunService.Heartbeat:Connect(autoHeal)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVCirc.Visible   = Config.ShowFOV
    FOVCirc.Radius    = Config.FOV
    FOVCirc.Color     = Config.FOVColor
    FOVCirc.Transparency = Config.FOVTrans
    FOVCirc.Position  = Camera.ViewportSize / 2

    -- ESP
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

    wallhack()
    applyGunMods()
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  UI
local Win = OrionLib:MakeWindow({Name="VortX Hub V2", SaveConfig=true, ConfigFolder="VortXHub2"})

local Main  = Win:MakeTab({Name="Aim"})
Main:AddToggle({Name="Silent-Aim", Default=Config.SilentAim, Callback=function(v) Config.SilentAim=v end})
Main:AddToggle({Name="Show FOV", Default=Config.ShowFOV, Callback=function(v) Config.ShowFOV=v end})
Main:AddSlider({Name="FOV Size", Min=30, Max=300, Default=Config.FOV, Callback=function(v) Config.FOV=v end})
Main:AddColorPicker({Name="FOV Color", Default=Config.FOVColor, Callback=function(v) Config.FOVColor=v end})
Main:AddDropdown({Name="Aim-Bone", Options={"Head","UpperTorso","HumanoidRootPart"}, Default=Config.AimBone, Callback=function(v) Config.AimBone=v end})

local Vis = Win:MakeTab({Name="Visuals"})
Vis:AddToggle({Name="ESP", Default=Config.ShowESP, Callback=function(v) Config.ShowESP=v end})
Vis:AddToggle({Name="Skeleton", Default=Config.ShowSkel, Callback=function(v) Config.ShowSkel=v end})
Vis:AddToggle({Name="Names", Default=Config.ShowNames, Callback=function(v) Config.ShowNames=v end})
Vis:AddToggle({Name="Wallhack (nearby)", Default=Config.Wallhack, Callback=function(v) Config.Wallhack=v end})

local Misc = Win:MakeTab({Name="Misc"})
Misc:AddToggle({Name="No-Recoil / Spread", Default=Config.NoRecoil, Callback=function(v) Config.NoRecoil=v end})
Misc:AddToggle({Name="Infinite Ammo", Default=Config.InfAmmo, Callback=function(v) Config.InfAmmo=v end})
Misc:AddToggle({Name="Auto-Heal", Default=Config.AutoHeal, Callback=function(v) Config.AutoHeal=v end})
Misc:AddButton({Name="Bring All Players", Callback=bringAll})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  INIT
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
OrionLib:Init()

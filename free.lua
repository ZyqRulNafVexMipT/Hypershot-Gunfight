-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Bagian 1: UI + Toggle
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Win = OrionLib:MakeWindow({Name="VortX Hub V2", SaveConfig=true, ConfigFolder="VortXHub2"})

local Main  = Win:MakeTab({Name="Aim"})
local Vis   = Win:MakeTab({Name="Visuals"})
local Misc  = Win:MakeTab({Name="Misc"})

-- Aim
Main:AddToggle({Name="Silent-Aim", Default=false, Flag="SilentAim"})
Main:AddToggle({Name="Show FOV", Default=false, Flag="ShowFOV"})
Main:AddSlider({Name="FOV Size", Min=30, Max=300, Default=120, Flag="FOVSize"})
Main:AddColorPicker({Name="FOV Color", Default=Color3.new(1,0,0), Flag="FOVColor"})
Main:AddDropdown({Name="Aim-Bone", Options={"Head","UpperTorso","HumanoidRootPart"}, Default="Head", Flag="AimBone"})

-- Visuals
Vis:AddToggle({Name="ESP", Default=false, Flag="ShowESP"})
Vis:AddToggle({Name="Skeleton", Default=false, Flag="ShowSkel"})
Vis:AddToggle({Name="Names", Default=false, Flag="ShowNames"})
Vis:AddToggle({Name="Wallhack (nearby)", Default=false, Flag="Wallhack"})

-- Misc
Misc:AddToggle({Name="No-Recoil / Spread", Default=false, Flag="NoRecoil"})
Misc:AddToggle({Name="Infinite Ammo", Default=false, Flag="InfAmmo"})
Misc:AddToggle({Name="Auto-Heal", Default=false, Flag="AutoHeal"})
Misc:AddButton({Name="Bring All Players", Flag="BringAll"})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Bagian 2: Core Functions
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local Config = getgenv().VortX_Config or {}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  AI Prediksi Ultra-Presisi
local function predictUltra(targetPart)
    local dist   = (targetPart.Position - Camera.CFrame.Position).Magnitude
    local travel = dist / 1500 -- velocity senjata
    local vel    = targetPart.Velocity
    local drop   = 0.5 * workspace.Gravity * travel^2
    return targetPart.Position + vel * travel + Vector3.new(0, -drop, 0)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Gun-Mods
local function applyGunMods()
    for _,v in pairs(getgc(true)) do
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
--  Auto-Heal
local function autoHeal()
    if Config.AutoHeal and LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health < LP.Character.Humanoid.MaxHealth then
        -- heal via remote / attribute (adjust sesuai game)
        -- contoh basic: LP.Character.Humanoid.Health = math.min(LP.Character.Humanoid.Health + 5, LP.Character.Humanoid.MaxHealth)
    end
end
RunService.Heartbeat:Connect(autoHeal)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Bring All Players (Human Only)
local function bringAll()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Silent-Aim + AI Redirect
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast" and Config.SilentAim then
        -- cari target via config
        local mouse = UIS:GetMouseLocation()
        local near, min = nil, Config.FOVSize or 120
        for _,p in ipairs(Players:GetPlayers()) do
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
        if near then
            local aim = predictUltra(near)
            args[2] = (aim - args[1]).Unit * 5000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- export
getgenv().VortX_Funcs = {
    applyGunMods = applyGunMods,
    bringAll     = bringAll
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Bagian 3: Loader
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")

local OrionLib    = getgenv().OrionLib
local Config      = getgenv().VortX_Config or {}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Sync UI ↔ Config
local function sync()
    -- Aim
    Config.SilentAim = OrionLib.Flags.SilentAim.Value
    Config.ShowFOV   = OrionLib.Flags.ShowFOV.Value
    Config.FOVSize   = OrionLib.Flags.FOVSize.Value
    Config.FOVColor  = OrionLib.Flags.FOVColor.Value
    Config.AimBone   = OrionLib.Flags.AimBone.Value

    -- Visuals
    Config.ShowESP   = OrionLib.Flags.ShowESP.Value
    Config.ShowSkel  = OrionLib.Flags.ShowSkel.Value
    Config.ShowNames = OrionLib.Flags.ShowNames.Value
    Config.Wallhack  = OrionLib.Flags.Wallhack.Value

    -- Misc
    Config.NoRecoil  = OrionLib.Flags.NoRecoil.Value
    Config.InfAmmo   = OrionLib.Flags.InfAmmo.Value
    Config.AutoHeal  = OrionLib.Flags.AutoHeal.Value
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Loop sync + apply
RunService.Heartbeat:Connect(function()
    sync()
    if Config.NoRecoil or Config.InfAmmo then
        getgenv().VortX_Funcs.applyGunMods()
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Button action
if OrionLib.Flags.BringAll then
    OrionLib.Flags.BringAll.Callback = function()
        getgenv().VortX_Funcs.bringAll()
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Init
OrionLib:Init()
OrionLib:MakeNotification({Name="VortX Hub V2", Content="All modules loaded. Use tabs to toggle features.", Time=4})

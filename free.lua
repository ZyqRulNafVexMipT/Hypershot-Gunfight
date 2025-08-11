-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Bagian 1: UI ONLY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "VortX Hub V2 – Hypershot Gunfight",
    LoadingTitle = "VortX Hub Loaded",
    LoadingSubtitle = "Hypershot Gunfight",
    ConfigurationSaving = {Enabled = true, FolderName = "VortXHub2"},
    KeySystem = false
})

local Main  = Window:CreateTab("Aim", 4483362458)
local Vis   = Window:CreateTab("Visuals", 4483362458)
local Misc  = Window:CreateTab("Misc", 4483362458)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Aim Tab
Main:AddToggle({Title="Silent-Aim",        Default=false})
Main:AddToggle({Title="Show FOV",          Default=false})
Main:AddSlider({Title="FOV Size",          Min=30, Max=300, Default=120})
Main:AddColorPicker({Title="FOV Color",    Default=Color3.new(1,0,0)})
Main:AddDropdown({Title="Aim-Bone",        Options={"Head","UpperTorso","HumanoidRootPart"}, Default="Head"})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Visuals Tab
Vis:AddToggle({Title="ESP",               Default=false})
Vis:AddToggle({Title="Skeleton",          Default=false})
Vis:AddToggle({Title="Names",             Default=false})
Vis:AddToggle({Title="Wallhack (nearby)", Default=false})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Misc Tab
Misc:AddToggle({Title="No-Recoil/Spread",  Default=false})
Misc:AddToggle({Title="Infinite Ammo",     Default=false})
Misc:AddToggle({Title="Auto-Heal",         Default=false})
Misc:AddButton({Title="Bring All Players", Callback=function() end})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Flag system (penghubung dengan bagian 2)
getgenv().VortX_Flags = {
    SilentAim  = false,
    ShowFOV    = false,
    FOVSize    = 120,
    FOVColor   = Color3.new(1,0,0),
    AimBone    = "Head",
    ShowESP    = false,
    ShowSkel   = false,
    ShowNames  = false,
    Wallhack   = false,
    NoRecoil   = false,
    InfAmmo    = false,
    AutoHeal   = false
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Bagian 2: Core Functions
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Flags       = getgenv().VortX_Flags or {}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  AI Prediksi Ultra Presisi
local function predictUltra(pos, vel)
    local dist   = (pos - Camera.CFrame.Position).Magnitude
    local travel = dist / 1500 -- velocity senjata
    local drop   = 0.5 * workspace.Gravity * travel^2
    return pos + vel * travel + Vector3.new(0, -drop, 0)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Get Closest Target
local function getClosest()
    local mouse = UIS:GetMouseLocation()
    local near, min = nil, Flags.FOVSize
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bone = p.Character:FindFirstChild(Flags.AimBone)
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
--  Silent-Aim Hook (non-destructive)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast" and Flags.SilentAim then
        local target = getClosest()
        if target then
            local aim = predictUltra(target.Position, target.Velocity)
            args[2] = (aim - args[1]).Unit * 5000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Gun Mods
local function applyGunMods()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Spread") then
            if Flags.NoRecoil then
                v.Spread = 0; v.BaseSpread = 0
                v.MinCamRecoil = Vector3.new(); v.MaxCamRecoil = Vector3.new()
            end
            if Flags.InfAmmo then
                v.Ammo = math.huge; v.MaxAmmo = math.huge
            end
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ESP
local espObjects = {}
local function createESP(p)
    local char = p.Character or p.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local hrp  = char:WaitForChild("HumanoidRootPart")

    local skel = {}
    local function add(part)
        if part then
            local d = Drawing.new("Circle")
            d.Visible = false; d.Color = Color3.new(1,1,1)
            d.Radius = 4; d.Filled = true
            table.insert(skel, {d, part})
        end
    end
    add(head); add(hrp)
    add(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
    add(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
    add(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
    add(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

    local nam = Drawing.new("Text")
    nam.Visible = false; nam.Color = Color3.new(1,1,1)
    nam.Center = true; nam.Outline = true
    nam.Text = p.Name; nam.Size = 18

    espObjects[p] = {nam = nam, skel = skel}
    p.CharacterAdded:Connect(function() createESP(p) end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Wallhack
local function wallhack()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            local dist = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            v.LocalTransparencyModifier = (Flags.Wallhack and dist < 30) and 0.8 or 0
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Bring All + Auto-Heal
local function bringAll()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

local function autoHeal()
    if Flags.AutoHeal and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if hum.Health < hum.MaxHealth then
            hum.Health = math.min(hum.Health + 5, hum.MaxHealth)
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SYNC UI ↔ FLAGS
local function sync()
    Flags.SilentAim = Rayfield.Flags.SilentAim or false
    Flags.ShowFOV   = Rayfield.Flags.ShowFOV or false
    Flags.FOVSize   = Rayfield.Flags.FOVSize or 120
    Flags.FOVColor  = Rayfield.Flags.FOVColor or Color3.new(1,0,0)
    Flags.AimBone   = Rayfield.Flags.AimBone or "Head"
    Flags.ShowESP   = Rayfield.Flags.ShowESP or false
    Flags.ShowSkel  = Rayfield.Flags.ShowSkel or false
    Flags.ShowNames = Rayfield.Flags.ShowNames or false
    Flags.Wallhack  = Rayfield.Flags.Wallhack or false
    Flags.NoRecoil  = Rayfield.Flags.NoRecoil or false
    Flags.InfAmmo   = Rayfield.Flags.InfAmmo or false
    Flags.AutoHeal  = Rayfield.Flags.AutoHeal or false
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  MAIN LOOP
local DrawingObjects = {}

RunService.RenderStepped:Connect(function()
    sync()
    applyGunMods()
    autoHeal()

    -- FOV
    FOVCirc.Visible = Flags.ShowFOV
    FOVCirc.Radius = Flags.FOVSize
    FOVCirc.Color = Flags.FOVColor
    FOVCirc.Position = Camera.ViewportSize / 2

    -- ESP
    for p, obj in pairs(espObjects) do
        local char = p.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2,0))
                obj.nam.Visible = vis and Flags.ShowNames
                obj.nam.Position = Vector2.new(pos.X, pos.Y)

                for _, s in ipairs(obj.skel) do
                    local p2, v2 = Camera:WorldToViewportPoint(s[2].Position)
                    s[1].Visible = v2 and Flags.ShowSkel
                    s[1].Position = Vector2.new(p2.X, p2.Y)
                end
            end
        end
    end
    wallhack()
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  BRIDGE UI
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FINAL INIT
Rayfield:Notify({Title="VortX Hub V2", Content="All modules active.", Duration=4})

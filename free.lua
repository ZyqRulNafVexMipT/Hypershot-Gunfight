-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Hypershot Gunfight
--  Rayfield Edition | 1-File
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  Window
local Window = Rayfield:CreateWindow({
   Name = "VortX Hub V2 – Hypershot Gunfight",
   LoadingTitle = "VortX Hub Loaded",
   LoadingSubtitle = "Hypershot Gunfight",
   ConfigurationSaving = {Enabled = true, FolderName = "VortXHub2"},
   KeySystem = false
})

local MainTab   = Window:CreateTab("Aim", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MiscTab   = Window:CreateTab("Misc", 4483362458)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VARIABLES
local SilentAim      = false
local FOVSize        = 120
local FOVColor       = Color3.fromRGB(255, 0, 0)
local AimBone        = "Head"
local ShowFOV        = false
local ShowESP        = false
local ShowSkel       = false
local ShowNames      = false
local Wallhack       = false
local NoRecoil       = false
local InfAmmo        = false
local AutoHeal       = false

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  DRAWING
local FOVCirc = Drawing.new("Circle")
FOVCirc.Visible = false
FOVCirc.Color = FOVColor
FOVCirc.Thickness = 2
FOVCirc.Filled = false
FOVCirc.Transparency = 0.7
FOVCirc.Position = Camera.ViewportSize / 2

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FUNCTIONS
local function getClosest()
    local mouse = UIS:GetMouseLocation()
    local nearest, dist = nil, FOVSize
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bone = p.Character:FindFirstChild(AimBone)
            if bone then
                local screen, on = Camera:WorldToViewportPoint(bone.Position)
                if on then
                    local d = (Vector2.new(screen.X, screen.Y) - mouse).Magnitude
                    if d < dist then nearest, dist = bone, d end
                end
            end
        end
    end
    return nearest
end

local function predict(pos, vel)
    local dist   = (pos - Camera.CFrame.Position).Magnitude
    local travel = dist / 1500
    local drop   = 0.5 * workspace.Gravity * travel^2
    return pos + vel * travel + Vector3.new(0, -drop, 0)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast" and SilentAim then
        local target = getClosest()
        if target then
            local aim = predict(target.Position, target.Velocity)
            args[2] = (aim - args[1]).Unit * 5000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  GUN MODS
local function applyGunMods()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Spread") then
            if NoRecoil then
                v.Spread = 0; v.BaseSpread = 0
                v.MinCamRecoil = Vector3.new(); v.MaxCamRecoil = Vector3.new()
                v.MinRotRecoil = Vector3.new(); v.MaxRotRecoil = Vector3.new()
            end
            if InfAmmo then
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

    -- Skeleton
    local skel = {}
    local function add(part)
        if not part then return end
        local d = Drawing.new("Circle")
        d.Visible = false; d.Color = Color3.new(1,1,1)
        d.Radius = 4; d.Filled = true
        table.insert(skel, {d, part})
    end
    add(head)
    add(char:FindFirstChild("HumanoidRootPart"))
    add(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
    add(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
    add(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
    add(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

    -- Name
    local nam = Drawing.new("Text")
    nam.Visible = false; nam.Color = Color3.new(1,1,1)
    nam.Center = true; nam.Outline = true
    nam.Text = p.Name; nam.Size = 18

    espObjects[p] = {nam = nam, skel = skel}
    p.CharacterAdded:Connect(function() createESP(p) end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  WALLHACK
local function wallhack()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            local dist = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            v.LocalTransparencyModifier = (Wallhack and dist < 30) and 0.8 or 0
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  BRING ALL + AUTO-HEAL
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
    if AutoHeal and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if hum.Health < hum.MaxHealth then
            hum.Health = math.min(hum.Health + 5, hum.MaxHealth)
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  MAIN LOOP
RunService.RenderStepped:Connect(function()
    FOVCirc.Visible = ShowFOV
    FOVCirc.Radius = FOVSize
    FOVCirc.Color = FOVColor
    FOVCirc.Transparency = FOVTrans
    FOVCirc.Position = Camera.ViewportSize / 2

    -- ESP & Wallhack
    for p, obj in pairs(espObjects) do
        local char = p.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2,0))
                obj.nam.Visible = vis and ShowNames
                obj.nam.Position = Vector2.new(pos.X, pos.Y)

                for _, s in ipairs(obj.skel) do
                    local p2, v2 = Camera:WorldToViewportPoint(s[2].Position)
                    s[1].Visible = v2 and ShowSkel
                    s[1].Position = Vector2.new(p2.X, p2.Y)
                end
            end
        end
    end
    wallhack()
    applyGunMods()
    autoHeal()
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  UI – Toggles langsung di tab
MainTab:AddToggle({Title="Silent-Aim",      Default=SilentAim, Callback=function(v) SilentAim=v end})
MainTab:AddToggle({Title="Show FOV",        Default=ShowFOV,   Callback=function(v) ShowFOV=v end})
MainTab:AddSlider({Title="FOV Size",        Min=30, Max=300, Default=FOVSize, Callback=function(v) FOVSize=v end})
MainTab:AddColorPicker({Title="FOV Color",  Default=FOVColor, Callback=function(v) FOVColor=v; FOVCirc.Color=v end})
MainTab:AddDropdown({Title="Aim-Bone",      Options={"Head","UpperTorso","HumanoidRootPart"}, Default=AimBone, Callback=function(v) AimBone=v end})

VisualTab:AddToggle({Title="ESP",           Default=ShowESP,   Callback=function(v) ShowESP=v end})
VisualTab:AddToggle({Title="Skeleton",      Default=ShowSkel,  Callback=function(v) ShowSkel=v end})
VisualTab:AddToggle({Title="Names",         Default=ShowNames, Callback=function(v) ShowNames=v end})
VisualTab:AddToggle({Title="Wallhack",      Default=Wallhack,  Callback=function(v) Wallhack=v end})

MiscTab:AddToggle({Title="No-Recoil",       Default=NoRecoil,  Callback=function(v) NoRecoil=v end})
MiscTab:AddToggle({Title="Infinite Ammo",   Default=InfAmmo,   Callback=function(v) InfAmmo=v end})
MiscTab:AddToggle({Title="Auto-Heal",       Default=AutoHeal,  Callback=function(v) AutoHeal=v end})
MiscTab:AddButton({Title="Bring All Players", Callback=bringAll})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  AUTO-ESP
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

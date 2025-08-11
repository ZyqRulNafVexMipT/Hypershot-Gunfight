-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  VortX Hub V2 – Hypershot Gunfight
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local UIS         = game:GetService("UserInputService")

local LP   = Players.LocalPlayer
local Cam  = Workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  CONFIG (live toggles)
local Config = {
    SilentAim = false,
    FOVSize   = 120,
    FOVColor  = Color3.fromRGB(255,0,0),
    AimBone   = "Head",
    ShowFOV   = false,

    ShowESP   = false,
    ShowSkel  = false,
    ShowNames = false,
    Wallhack  = false,

    NoRecoil  = false,
    InfAmmo   = false,
    AutoHeal  = false,
    BringAll  = false
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  DRAWING
local FOVCirc = Drawing.new("Circle")
FOVCirc.Visible = false
FOVCirc.Color   = Config.FOVColor
FOVCirc.Thickness = 2
FOVCirc.Filled = false
FOVCirc.Transparency = 0.7

local espObjects = {}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FUNCTIONS
local function getClosest()
    local mouse = UIS:GetMouseLocation()
    local near, min = nil, Config.FOVSize
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local bone = p.Character:FindFirstChild(Config.AimBone)
            if bone then
                local screen, on = Cam:WorldToViewportPoint(bone.Position)
                if on then
                    local d = (Vector2.new(screen.X, screen.Y) - mouse).Magnitude
                    if d < min then near, min = bone, d end
                end
            end
        end
    end
    return near
end

local function predict(pos, vel)
    local dist   = (pos - Cam.CFrame.Position).Magnitude
    local travel = dist / 1500
    local drop   = 0.5 * workspace.Gravity * travel^2
    return pos + vel * travel + Vector3.new(0, -drop, 0)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast" and Config.SilentAim then
        local t = getClosest()
        if t then
            local aim = predict(t.Position, t.Velocity)
            args[2] = (aim - args[1]).Unit * 5000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

local function applyGunMods()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Spread") then
            if Config.NoRecoil then
                v.Spread = 0
                v.BaseSpread = 0
                v.MinCamRecoil = Vector3.new()
                v.MaxCamRecoil = Vector3.new()
            end
            if Config.InfAmmo then
                v.Ammo = math.huge
                v.MaxAmmo = math.huge
            end
        end
    end
end

local function createESP(p)
    local char = p.Character or p.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    local hrp  = char:WaitForChild("HumanoidRootPart")

    local skel = {}
    local function add(part)
        if not part then return end
        local d = Drawing.new("Circle")
        d.Visible = false
        d.Color = Color3.new(1,1,1)
        d.Radius = 4
        d.Filled = true
        table.insert(skel, {d, part})
    end
    add(head); add(hrp)
    add(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
    add(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
    add(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
    add(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

    local nam = Drawing.new("Text")
    nam.Visible = false
    nam.Color = Color3.new(1,1,1)
    nam.Center = true
    nam.Outline = true
    nam.Text = p.Name
    nam.Size = 18

    espObjects[p] = {nam = nam, skel = skel}
    p.CharacterAdded:Connect(function() createESP(p) end)
end

local function wallhack()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            local dist = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            v.LocalTransparencyModifier = (Config.Wallhack and dist < 30) and 0.8 or 0
        end
    end
end

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
    if Config.AutoHeal and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if hum.Health < hum.MaxHealth then
            hum.Health = math.min(hum.Health + 5, hum.MaxHealth)
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVCirc.Visible = Config.ShowFOV
    FOVCirc.Radius = Config.FOVSize
    FOVCirc.Color = Config.FOVColor
    FOVCirc.Position = Cam.ViewportSize / 2

    -- ESP
    for p, obj in pairs(espObjects) do
        local char = p.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, vis = Cam:WorldToViewportPoint(head.Position + Vector3.new(0,2,0))
                obj.nam.Visible = vis and Config.ShowNames
                obj.nam.Position = Vector2.new(pos.X, pos.Y)

                for _, s in ipairs(obj.skel) do
                    local p2, v2 = Cam:WorldToViewportPoint(s[2].Position)
                    s[1].Visible = v2 and Config.ShowSkel
                    s[1].Position = Vector2.new(p2.X, p2.Y)
                end
            end
        end
    end

    applyGunMods()
    wallhack()
    autoHeal()
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  UI
local Window = Rayfield:CreateWindow({
    Name = "VortX Hub | Hypershot Gunfight",
    LoadingTitle = "VortX Hub Loading...",
    LoadingSubtitle = "Powered by Rayfield",
    ConfigurationSaving = {Enabled = true, FolderName = "VortXHub2", FileName = "HypershotGunfight"},
    Discord = {Enabled = false},
    KeySystem = false
})

local AimTab   = Window:CreateTab("Aim",     4483362458)
local VisTab   = Window:CreateTab("Visual",  4483362458)
local MiscTab  = Window:CreateTab("Misc",    4483362458)

-- Aim
AimTab:CreateToggle({Name = "Silent-Aim", CurrentValue = false, Callback = function(v) Config.SilentAim = v end})
AimTab:CreateToggle({Name = "Show FOV",   CurrentValue = false, Callback = function(v) Config.ShowFOV = v end})
AimTab:CreateSlider({Name = "FOV Size",   Range = {30, 300}, Increment = 5, CurrentValue = 120, Callback = function(v) Config.FOVSize = v end})
AimTab:CreateColorPicker({Name = "FOV Color", Color = Config.FOVColor, Callback = function(c) Config.FOVColor = c; FOVCirc.Color = c end})
AimTab:CreateDropdown({Name = "Aim-Bone", Options = {"Head","UpperTorso","HumanoidRootPart"}, CurrentOption = {Config.AimBone}, MultipleOptions = false, Callback = function(o) Config.AimBone = o[1] end})

-- Visual
VisTab:CreateToggle({Name = "ESP",        CurrentValue = false, Callback = function(v) Config.ShowESP = v end})
VisTab:CreateToggle({Name = "Skeleton",   CurrentValue = false, Callback = function(v) Config.ShowSkel = v end})
VisTab:CreateToggle({Name = "Names",      CurrentValue = false, Callback = function(v) Config.ShowNames = v end})
VisTab:CreateToggle({Name = "Wallhack",   CurrentValue = false, Callback = function(v) Config.Wallhack = v end})

-- Misc
MiscTab:CreateToggle({Name = "No-Recoil",  CurrentValue = false, Callback = function(v) Config.NoRecoil = v end})
MiscTab:CreateToggle({Name = "Inf-Ammo",   CurrentValue = false, Callback = function(v) Config.InfAmmo = v end})
MiscTab:CreateToggle({Name = "Auto-Heal",  CurrentValue = false, Callback = function(v) Config.AutoHeal = v end})
MiscTab:CreateButton({Name = "Bring All Players", Callback = bringAll})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  INIT
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

Rayfield:Notify({Title = "VortX Hub V2", Content = "Loaded! Use tabs to toggle features.", Duration = 4})

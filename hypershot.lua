--[[
    VortX Hub – Part 1/2
    Re-branded & upgraded Hyper-Shot using Luna Interface Suite.
    Features retained:
        • Walls, Big Heads, Bring Heads, No Recoil, No Cool-down
    New additions:
        • Silent Aim (from message 15)
        • ESP (from message 15)
        • Full Luna UI with Home-Tab & executor list
]]

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 1) Load Luna Library
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 2) Create Main Window
local Window = Luna:CreateWindow({
    Name = "VortX Hub",
    Subtitle = "HyperShot Gunfight V2",
    LogoID = "82795327169782",
    LoadingEnabled = true,
    LoadingTitle = "VortX Hub",
    LoadingSubtitle = "V2",
    ConfigSettings = {
        ConfigFolder = "VortX"
    },
    KeySystem = false
})

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 3) Home Tab (Executor list)
Window:CreateHomeTab({
    SupportedExecutors = {
        "Synapse X","Krnl","ProtoSmasher","Fluxus","Script-Ware",
        "EasyExploits","Electron","JJSploit","Calamari","SirHurt",
        "Sentinel","WEAREDEVS","Comet","Cellery","Wave","CODex","Delta"
    },
    DiscordInvite = "https://discord.gg/YqacuSRb",
    Icon = 1
})

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 4) Load ESP + Silent-Aim engine (from message 15)
local esp, esp_renderstep, framework = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/ESP-Library/refs/heads/main/nomercy.rip/source.lua"))()

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 5) Global Variables (Hyper-Shot core)
local Players        = game:GetService("Players")
local UIS            = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local Workspace      = game:GetService("Workspace")
local LocalPlayer    = Players.LocalPlayer

-- Original Hyper-Shot toggles
local wallsEnabled      = false
local bigHeadEnabled    = false
local bringHeadEnabled  = false
local noRecoilEnabled   = false
local noCooldownEnabled = false

-- Head-size slider
local HeadSize = 6

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 6) Tabs
local combatTab   = Window:CreateTab({ Name = "Combat",   Icon = "target" })
local visualsTab  = Window:CreateTab({ Name = "Visuals",  Icon = "visibility" })
local miscTab     = Window:CreateTab({ Name = "Misc",     Icon = "settings" })

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 7) Combat Section (Silent-Aim)
local combatCol  = combatTab:CreateColumn()
local combatSec  = combatCol:CreateSection({ Name = "Silent-Aim" })

combatSec:CreateToggle({
    Name = "Silent-Aim Enabled",
    Callback = function(v)
        -- Hook is handled in Part 2
        getgenv().SilentAim.Enabled = v
    end
})

combatSec:CreateSlider({
    Name = "FOV Size",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = 200,
    Callback = function(v)
        getgenv().Config.FOVSize = v
    end
})

combatSec:CreateDropdown({
    Name = "Aim Bone",
    Options = {"Head","LowerTorso","RightFoot"},
    CurrentOption = {"Head"},
    Callback = function(v)
        getgenv().Config.AimBone = v[1]
    end
})

combatSec:CreateToggle({
    Name = "Show FOV",
    Callback = function(v)
        getgenv().Config.ShowFOV = v
    end
})

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 8) Visuals Section (ESP)
local visCol1 = visualsTab:CreateColumn()
local visCol2 = visualsTab:CreateColumn()

local espGlobalSec = visCol1:CreateSection({ Name = "ESP Global" })
local espColorSec  = visCol2:CreateSection({ Name = "ESP Colors" })

espGlobalSec:CreateToggle({
    Name = "ESP Enabled",
    Callback = function(v)
        esp.Settings.Enabled = v
    end
})

espGlobalSec:CreateToggle({
    Name = "Show Box",
    Callback = function(v)
        esp.Settings.Box.Enabled = v
    end
})

espGlobalSec:CreateToggle({
    Name = "Show Name",
    Callback = function(v)
        esp.Settings.Name.Enabled = v
    end
})

espGlobalSec:CreateToggle({
    Name = "Show Distance",
    Callback = function(v)
        esp.Settings.Distance.Enabled = v
    end
})

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 9) Misc Section (Hyper-Shot features)
local miscCol  = miscTab:CreateColumn()
local miscSec  = miscCol:CreateSection({ Name = "Hyper-Shot" })

miscSec:CreateToggle({
    Name = "Walls (see enemies)",
    Callback = function(v)
        wallsEnabled = v
        -- logic in Part 2
    end
})

miscSec:CreateToggle({
    Name = "Big Head",
    Callback = function(v)
        bigHeadEnabled = v
    end
})

miscSec:CreateSlider({
    Name = "Head Size",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = HeadSize,
    Callback = function(v)
        HeadSize = v
    end
})

miscSec:CreateToggle({
    Name = "Bring Heads",
    Callback = function(v)
        bringHeadEnabled = v
    end
})

miscSec:CreateToggle({
    Name = "No Recoil",
    Callback = function(v)
        noRecoilEnabled = v
    end
})

miscSec:CreateToggle({
    Name = "No Cool-down",
    Callback = function(v)
        noCooldownEnabled = v
    end
})

--[[
    VortX Hub – Part 2/2
    Contains:
        • Silent-Aim hooks
        • ESP player / mob handling
        • Hyper-Shot logic (walls, big-head, etc.)
]]

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- Shared variables (must match Part 1)
local Players        = game:GetService("Players")
local Workspace      = game:GetService("Workspace")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local LocalPlayer    = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- Silent-Aim Config (used by UI)
getgenv().Config = {
    AimBone            = "Head",
    FOVSize            = 200,
    ShowFOV            = true,
    ShowTargetLine     = true,
    fovcolor           = Color3.new(1,0,0),
    linecolor          = Color3.new(0,1,0),
    TeamCheck          = true,
    VisibilityCheck    = true
}

getgenv().SilentAim = {
    Enabled = false,
    Target  = nil
}

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 1) Load ESP engine again (ensure tables exist)
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/ESP-Library/refs/heads/main/nomercy.rip/source.lua"))()

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 2) Silent-Aim hooks (from message 15)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Config.fovcolor
FOVCircle.Thickness = 2
FOVCircle.Radius = Config.FOVSize
FOVCircle.Transparency = 0.5
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local TargetLine = Drawing.new("Line")
TargetLine.Visible = false
TargetLine.Color = Config.linecolor
TargetLine.Thickness = 2

local function IsVisible(part)
    if not Config.VisibilityCheck then return true end
    local origin, dir = Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000
    local ray = Workspace:Raycast(origin, dir, RaycastParams.new({
        FilterDescendantsInstances = {LocalPlayer.Character},
        FilterType = Enum.RaycastFilterType.Blacklist
    }))
    return not ray or ray.Instance:IsDescendantOf(part.Parent)
end

local function IsEnemy(player)
    if not Config.TeamCheck then return true end
    return (player:GetAttribute("Team") or 0) ~= (LocalPlayer:GetAttribute("Team") or 0)
end

local function WorldToScreen(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), onScreen
end

local function GetClosest()
    if not getgenv().SilentAim.Enabled then return end
    local mousePos = UIS:GetMouseLocation()
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local bone = plr.Character:FindFirstChild(Config.AimBone)
        if bone and IsEnemy(plr) then
            local screen, onScreen = WorldToScreen(bone.Position)
            if onScreen and IsVisible(bone) then
                local d = (mousePos - screen).Magnitude
                if d < dist and d <= Config.FOVSize then
                    closest, dist = bone, d
                end
            end
        end
    end
    -- Mobs
    for _, mob in ipairs(Workspace:GetChildren()) do
        if mob.Name == "Mobs" then
            for _, bot in ipairs(mob:GetChildren()) do
                local bone = bot:FindFirstChild(Config.AimBone)
                if bone then
                    local screen, onScreen = WorldToScreen(bone.Position)
                    if onScreen and IsVisible(bone) then
                        local d = (mousePos - screen).Magnitude
                        if d < dist and d <= Config.FOVSize then
                            closest, dist = bone, d
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Hook Raycast
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and self == Workspace and method == "Raycast" and getgenv().SilentAim.Enabled then
        local target = GetClosest()
        if target then
            args[2] = (target.Position - args[1]).Unit * 1000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 3) ESP Player / Mob handling (from message 15)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then esp:Player(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then esp:Player(p) end
end)

-- Mobs (NPC)
local added = {}
RunService.Heartbeat:Connect(function()
    local mobs = Workspace:FindFirstChild("Mobs")
    if mobs then
        for _, mob in ipairs(mobs:GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and not added[mob] then
                added[mob] = true
                local fake = {
                    Name = mob.Name,
                    Character = mob,
                    GetAttribute = function() return nil end,
                    IsA = function(_,c) return c=="Player" end
                }
                esp:Player(fake, {Color = Color3.fromRGB(255,50,50)})
                mob.AncestryChanged:Connect(function()
                    if not mob:IsDescendantOf(game) then
                        local o = esp:GetObject(fake)
                        if o then o:Destroy() end
                        added[mob] = nil
                    end
                end)
            end
        end
    end
end)

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 4) Hyper-Shot logic (walls, big-head, etc.)
local function BigHead(char, size)
    if char and char:FindFirstChild("Head") then
        char.Head.Size = Vector3.new(size, size, size)
    end
end

local function Walls(char)
    -- simple wall-hack billboard
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.new(0,30,0,30)
    gui.AlwaysOnTop = true
    gui.MaxDistance = math.huge
    gui.Parent = char
    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.new(1,0,1,0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://7142136429"
end

-- Toggle listeners (connect to UI toggles)
RunService.RenderStepped:Connect(function()
    -- Big Head
    if getgenv().bigHeadEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                BigHead(p.Character, getgenv().HeadSize or 6)
            end
        end
    end

    -- Walls
    if getgenv().wallsEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("BBGui") then
                Walls(p.Character)
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("BBGui") then
                p.Character.BBGui:Destroy()
            end
        end
    end

    -- Bring heads (simple CFrame move)
    if getgenv().bringHeadEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.CFrame = LocalPlayer.Character.Head.CFrame * CFrame.new(0,3,0)
            end
        end
    end

    -- Update FOV visuals
    FOVCircle.Visible = getgenv().SilentAim.Enabled and Config.ShowFOV
    FOVCircle.Radius  = Config.FOVSize
    local target = GetClosest()
    TargetLine.Visible = target and Config.ShowTargetLine or false
    if target then
        local screen = WorldToScreen(target.Position)
        TargetLine.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        TargetLine.To   = screen
    end
end)

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 5) Finish notification
Luna:Notification({
    Title = "VortX Hub",
    Content = "loaded – enjoy!",
    Icon = "notifications_active"
})

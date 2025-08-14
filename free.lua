-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V4  |  AUTO-KILL ON CAMERA
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1ghtmare1234/SCRIPTS/main/Orion.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub V4 | Auto-Kill on Camera",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

getgenv().AutoKillCam = false
getgenv().Wallbang    = true
getgenv().InfiniteAmmo = false
getgenv().BringAll     = false
getgenv().Collect      = false
getgenv().AntiDetect   = false
getgenv().KillDistance = 1000
getgenv().KillDelay    = 0

-------------------------------------------------
-- UTILITY
-------------------------------------------------
local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHead(char)
    return char and char:FindFirstChild("Head")
end

-------------------------------------------------
-- AUTO-KILL ENGINE
-------------------------------------------------
local function autoKill()
    if not getgenv().AutoKillCam then return end

    local camCF = Camera.CFrame
    local camPos = camCF.Position
    local look = camCF.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end

        local head = getHead(char)
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end

        -- Vector from camera to head
        local toHead = head.Position - camPos
        local dist = toHead.Magnitude
        if dist > getgenv().KillDistance then continue end

        -- Check if head is in camera direction
        local dot = look:Dot(toHead.Unit)
        if dot < 0.98 then continue end  -- ~11° cone; tighten/loosen here

        -- Optional wallbang
        if not getgenv().Wallbang then
            local ray = Ray.new(camPos, toHead.Unit * dist)
            local hit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit and not hit:IsDescendantOf(char) then continue end
        end

        -- INSTANT KILL
        task.wait(getgenv().KillDelay)
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer(head.Position)
        elseif ReplicatedStorage:FindFirstChild("Damage") then
            ReplicatedStorage.Damage:FireServer(plr, 9e9)
        else
            -- Fallback: teleport bullet to head
            if ReplicatedStorage:FindFirstChild("Bullet") then
                ReplicatedStorage.Bullet:FireServer(head.CFrame)
            end
        end
    end
end

RunService.Heartbeat:Connect(autoKill)

-------------------------------------------------
-- BRING ALL PLAYERS
-------------------------------------------------
local function bringLoop()
    if not getgenv().BringAll then return end
    local me = LocalPlayer.Character
    if not me then return end
    local root = getRoot(me)
    if not root then return end

    local target = root.Position + root.CFrame.LookVector * 5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local r = getRoot(char)
        if r then
            r.CFrame = CFrame.new(target + Vector3.new(math.random(-2,2),0,math.random(-2,2)))
        end
    end
end

RunService.Heartbeat:Connect(bringLoop)

-------------------------------------------------
-- INFINITE AMMO
-------------------------------------------------
local function infAmmo()
    if not getgenv().InfiniteAmmo then return end
    local char = LocalPlayer.Character
    if not char then return end
    local backpack = LocalPlayer.Backpack

    local function scan(container)
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                for _, child in ipairs(tool:GetDescendants()) do
                    if child.Name:lower():find("ammo") or child.Name:lower():find("clip") then
                        child.Value = 9999
                    end
                end
            end
        end
    end
    scan(backpack)
    scan(char)
end
RunService.Heartbeat:Connect(infAmmo)

-------------------------------------------------
-- AUTO COLLECT
-------------------------------------------------
local function collectLoop()
    if not getgenv().Collect then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = getRoot(char)
    if not root then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("heal")) then
            if (obj.Position - root.Position).Magnitude <= 50 then
                obj.CFrame = root.CFrame
            end
        end
    end
end
RunService.Heartbeat:Connect(collectLoop)

-------------------------------------------------
-- UI
-------------------------------------------------
CombatTab:AddToggle({
    Name = "Auto-Kill on Camera",
    Default = false,
    Callback = function(v)
        getgenv().AutoKillCam = v
        OrionLib:MakeNotification({
            Name = "Auto-Kill",
            Content = v and "Auto-Kill ENABLED" or "Auto-Kill DISABLED",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Wallbang",
    Default = true,
    Callback = function(v)
        getgenv().Wallbang = v
        OrionLib:MakeNotification({
            Name = "Wallbang",
            Content = v and "Wallbang ON" or "Wallbang OFF",
            Time = 3
        })
    end
})

CombatTab:AddSlider({
    Name = "Kill Distance",
    Min = 50,
    Max = 5000,
    Default = 1000,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 50,
    ValueName = "studs",
    Callback = function(v)
        getgenv().KillDistance = v
    end
})

CombatTab:AddSlider({
    Name = "Kill Delay (ms)",
    Min = 0,
    Max = 100,
    Default = 0,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 5,
    ValueName = "ms",
    Callback = function(v)
        getgenv().KillDelay = v / 1000
    end
})

CombatTab:AddToggle({
    Name = "Bring All Players",
    Default = false,
    Callback = function(v)
        getgenv().BringAll = v
        OrionLib:MakeNotification({
            Name = "Bring",
            Content = v and "Bring All ON" or "Bring All OFF",
            Time = 3
        })
    end
})

CombatTab:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(v)
        getgenv().InfiniteAmmo = v
        OrionLib:MakeNotification({
            Name = "Ammo",
            Content = v and "Infinite Ammo ON" or "Infinite Ammo OFF",
            Time = 3
        })
    end
})

AutoTab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(v)
        getgenv().Collect = v
        OrionLib:MakeNotification({
            Name = "Collect",
            Content = v and "Auto Collect ON" or "Auto Collect OFF",
            Time = 3
        })
    end
})

-------------------------------------------------
-- INIT
-------------------------------------------------
OrionLib:MakeNotification({
    Name = "Vortex Hub V4",
    Content = "Auto-Kill on Camera loaded!",
    Time = 5
})

OrionLib:Init()

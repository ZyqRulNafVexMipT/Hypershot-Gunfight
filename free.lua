-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB  |  WORKING VERSION
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1ghtmare1234/SCRIPTS/main/Orion.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------
-- WINDOW
-------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub | Auto-Kill + Bring",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VortexCfg"
})

local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

-------------------------------------------------
-- CONFIG
-------------------------------------------------
local cfg = {
    autoKill = false,
    wallbang = true,
    bringAll = false,
    infAmmo  = false,
    collect  = false,
    killDist = 1000,
    bringDist = 5
}

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function root(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function head(char) return char and char:FindFirstChild("Head") end
local function hum(char) return char and char:FindFirstChildOfClass("Humanoid") end

-------------------------------------------------
-- AUTO-KILL (Camera Direction)
-------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not cfg.autoKill then return end

    local camPos = Camera.CFrame.Position
    local lookDir = Camera.CFrame.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hd = head(char)
        local h = hum(char)
        if not hd or not h or h.Health <= 0 then continue end

        local vec = hd.Position - camPos
        local dist = vec.Magnitude
        if dist > cfg.killDist then continue end
        if lookDir:Dot(vec.Unit) < 0.98 then continue end -- 11° cone

        -- Wallbang check
        if not cfg.wallbang then
            local ray = Ray.new(camPos, vec.Unit * dist)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit and not hit:IsDescendantOf(char) then continue end
        end

        -- Universal remote
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer(hd.Position)
        elseif ReplicatedStorage:FindFirstChild("Damage") then
            ReplicatedStorage.Damage:FireServer(plr, 9e9)
        else
            local rem = ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
            if rem then rem:FireServer(plr, hd.Position) end
        end
    end
end)

-------------------------------------------------
-- BRING ALL
-------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not cfg.bringAll then return end
    local myRoot = root(LocalPlayer.Character)
    if not myRoot then return end

    local targetPos = myRoot.Position + myRoot.CFrame.LookVector * cfg.bringDist
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local r = root(plr.Character)
        if r then
            r.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-2,2),0,math.random(-2,2)))
        end
    end
end)

-------------------------------------------------
-- INFINITE AMMO
-------------------------------------------------
local function ammoLoop()
    if not cfg.infAmmo then return end
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
    scan(LocalPlayer.Backpack)
    scan(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
end
RunService.Heartbeat:Connect(ammoLoop)
LocalPlayer.CharacterAdded:Connect(function(char) ammoLoop() end)

-------------------------------------------------
-- AUTO COLLECT
-------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not cfg.collect then return end
    local myRoot = root(LocalPlayer.Character)
    if not myRoot then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money") or obj.Name:lower():find("heal")) then
            if (obj.Position - myRoot.Position).Magnitude <= 50 then
                obj.CFrame = myRoot.CFrame
            end
        end
    end
end)

-------------------------------------------------
-- UI CONTROLS
-------------------------------------------------
CombatTab:AddToggle({Name = "Auto-Kill on Camera", Default = false,
    Callback = function(v)
        cfg.autoKill = v
        OrionLib:MakeNotification({Name = "Auto-Kill", Content = v and "ON" or "OFF", Time = 3})
    end})

CombatTab:AddToggle({Name = "Wallbang", Default = true,
    Callback = function(v) cfg.wallbang = v end})

CombatTab:AddSlider({Name = "Kill Distance", Min = 50, Max = 5000, Default = 1000,
    Color = Color3.new(1,0,0), Increment = 50, ValueName = "studs",
    Callback = function(v) cfg.killDist = v end})

CombatTab:AddToggle({Name = "Bring All Players", Default = false,
    Callback = function(v)
        cfg.bringAll = v
        OrionLib:MakeNotification({Name = "Bring", Content = v and "ON" or "OFF", Time = 3})
    end})

CombatTab:AddSlider({Name = "Bring Distance", Min = 1, Max = 50, Default = 5,
    Color = Color3.new(1,1,0), Increment = 1, ValueName = "studs",
    Callback = function(v) cfg.bringDist = v end})

CombatTab:AddToggle({Name = "Infinite Ammo", Default = false,
    Callback = function(v)
        cfg.infAmmo = v
        OrionLib:MakeNotification({Name = "Ammo", Content = v and "ON" or "OFF", Time = 3})
    end})

AutoTab:AddToggle({Name = "Auto Collect Items", Default = false,
    Callback = function(v)
        cfg.collect = v
        OrionLib:MakeNotification({Name = "Collector", Content = v and "ON" or "OFF", Time = 3})
    end})

-------------------------------------------------
-- LOADED
-------------------------------------------------
OrionLib:MakeNotification({Name = "Vortex Hub", Content = "Ready – point camera to kill!", Time = 5})
OrionLib:Init()

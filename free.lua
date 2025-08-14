-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB  |  FINAL BUILD (Single File)
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Camera     = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------
-- 1. WINDOW
-------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub | Auto-Kill Camera",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VortexCfg"
})

local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

-------------------------------------------------
-- 2. FLAGS
-------------------------------------------------
local cfg = {
    autoKill = false,
    wallbang = true,
    bringAll = false,
    infAmmo  = false,
    autoCollect = false,
    killDist = 1000,
    bringDist = 5
}

-------------------------------------------------
-- 3. HELPERS
-------------------------------------------------
local function root(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function head(c) return c and c:FindFirstChild("Head") end
local function hum(c)  return c and c:FindFirstChildOfClass("Humanoid") end

-------------------------------------------------
-- 4. MAIN LOOPS
-------------------------------------------------
-- 4-A  Auto-Kill on Camera
RunService.Heartbeat:Connect(function()
    if not cfg.autoKill then return end
    local camPos = Camera.CFrame.Position
    local look   = Camera.CFrame.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hd   = head(char)
        local h    = hum(char)
        if not hd or not h or h.Health <= 0 then continue end

        local vec   = hd.Position - camPos
        local dist  = vec.Magnitude
        if dist > cfg.killDist then continue end
        if look:Dot(vec.Unit) < 0.98 then continue end   -- 11° cone

        -- wall check
        if not cfg.wallbang then
            local ray = Ray.new(camPos, vec.Unit * dist)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit and not hit:IsDescendantOf(char) then continue end
        end

        -- universal remotes
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

-- 4-B  Bring All
RunService.Heartbeat:Connect(function()
    if not cfg.bringAll then return end
    local myRoot = root(LocalPlayer.Character)
    if not myRoot then return end
    local pos = myRoot.Position + myRoot.CFrame.LookVector * cfg.bringDist

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local r = root(plr.Character)
        if r then r.CFrame = CFrame.new(pos + Vector3.new(math.random(-2,2),0,math.random(-2,2))) end
    end
end)

-- 4-C  Infinite Ammo
RunService.Heartbeat:Connect(function()
    if not cfg.infAmmo then return end
    local function scan(con)
        for _, t in ipairs(con:GetChildren()) do
            if t:IsA("Tool") then
                for _, v in ipairs(t:GetDescendants()) do
                    if v.Name:lower():find("ammo") or v.Name:lower():find("clip") then
                        v.Value = 9999
                    end
                end
            end
        end
    end
    scan(LocalPlayer.Backpack)
    scan(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
end)
LocalPlayer.CharacterAdded:Connect(function() scan(LocalPlayer.Character) end)

-- 4-D  Auto Collect
RunService.Heartbeat:Connect(function()
    if not cfg.autoCollect then return end
    local r = root(LocalPlayer.Character)
    if not r then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money") or obj.Name:lower():find("heal")) then
            if (obj.Position - r.Position).Magnitude <= 50 then
                obj.CFrame = r.CFrame
            end
        end
    end
end)

-------------------------------------------------
-- 5. UI CONTROLS
-------------------------------------------------
CombatTab:AddToggle({Name = "Auto-Kill on Camera", Default = false,
    Callback = function(v)
        cfg.autoKill = v
        OrionLib:MakeNotification({Name = "Auto-Kill", Content = v and "ENABLED" or "DISABLED", Time = 3})
    end})

CombatTab:AddToggle({Name = "Wallbang (Through Walls)", Default = true,
    Callback = function(v) cfg.wallbang = v end})

CombatTab:AddSlider({Name = "Kill Distance", Min = 50, Max = 5000, Default = 1000,
    Color = Color3.new(1,0,0), Increment = 50, ValueName = "studs",
    Callback = function(v) cfg.killDist = v end})

CombatTab:AddToggle({Name = "Bring All Players", Default = false,
    Callback = function(v)
        cfg.bringAll = v
        OrionLib:MakeNotification({Name = "Bring", Content = v and "ENABLED" or "DISABLED", Time = 3})
    end})

CombatTab:AddSlider({Name = "Bring Distance", Min = 1, Max = 50, Default = 5,
    Color = Color3.new(1,1,0), Increment = 1, ValueName = "studs",
    Callback = function(v) cfg.bringDist = v end})

CombatTab:AddToggle({Name = "Infinite Ammo", Default = false,
    Callback = function(v)
        cfg.infAmmo = v
        OrionLib:MakeNotification({Name = "Ammo", Content = v and "ENABLED" or "DISABLED", Time = 3})
    end})

AutoTab:AddToggle({Name = "Auto Collect Items", Default = false,
    Callback = function(v)
        cfg.autoCollect = v
        OrionLib:MakeNotification({Name = "Collector", Content = v and "ENABLED" or "DISABLED", Time = 3})
    end})

-------------------------------------------------
-- 6. LOAD POPUP
-------------------------------------------------
OrionLib:MakeNotification({Name = "Vortex Hub", Content = "Fully loaded – point camera to kill!", Time = 5})
OrionLib:Init()

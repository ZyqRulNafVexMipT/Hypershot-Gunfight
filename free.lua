-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB  |  SINGLE-FILE WORKING
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1ghtmare1234/SCRIPTS/main/Orion.lua"))()

local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera    = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-------------------------------------------------
-- WINDOW
-------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Vortex Hub  |  Auto-Kill + Bring All",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Vortex_Configs"
})

local CombatTab = Window:MakeTab({Name = "Combat"})
local AutoTab   = Window:MakeTab({Name = "Auto"})

-------------------------------------------------
-- FLAGS
-------------------------------------------------
local flags = {
    AutoKillCam   = false,
    Wallbang      = true,
    InfiniteAmmo  = false,
    BringAll      = false,
    AutoCollect   = false,
    KillDist      = 1000,
    KillDelay     = 0,
    BringDist     = 5
}

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function root(char)  return char and char:FindFirstChild("HumanoidRootPart") end
local function head(char)  return char and char:FindFirstChild("Head") end
local function hum(char)   return char and char:FindFirstChildOfClass("Humanoid") end

-------------------------------------------------
-- AUTO-KILL ON CAMERA
-------------------------------------------------
local function autoKillLoop()
    if not flags.AutoKillCam then return end

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
        if dist > flags.KillDist then continue end

        -- cone check  (≈ 11°)
        if look:Dot(vec.Unit) < 0.98 then continue end

        -- wallbang toggle
        if not flags.Wallbang then
            local ray = Ray.new(camPos, vec.Unit * dist)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit and not hit:IsDescendantOf(char) then continue end
        end

        task.wait(flags.KillDelay)

        -- universal remotes
        if ReplicatedStorage:FindFirstChild("Shoot") then
            ReplicatedStorage.Shoot:FireServer(hd.Position)
        elseif ReplicatedStorage:FindFirstChild("Damage") then
            ReplicatedStorage.Damage:FireServer(plr, 9e9)
        elseif ReplicatedStorage:FindFirstChild("RemoteDamage") then
            ReplicatedStorage.RemoteDamage:FireServer(plr, hd.Position)
        else
            -- fallback – try any remote with 2 args
            local rem = ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
            if rem then rem:FireServer(plr, hd.Position) end
        end
    end
end
RunService.Heartbeat:Connect(autoKillLoop)

-------------------------------------------------
-- BRING ALL PLAYERS
-------------------------------------------------
local function bringLoop()
    if not flags.BringAll then return end
    local myChar = LocalPlayer.Character
    local myRoot = root(myChar)
    if not myRoot then return end

    local targetPos = myRoot.Position + myRoot.CFrame.LookVector * flags.BringDist
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local r    = root(char)
        if r then
            r.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-2,2),0,math.random(-2,2)))
        end
    end
end
RunService.Heartbeat:Connect(bringLoop)

-------------------------------------------------
-- INFINITE AMMO
-------------------------------------------------
local function ammoLoop()
    if not flags.InfiniteAmmo then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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
RunService.Heartbeat:Connect(ammoLoop)
LocalPlayer.CharacterAdded:Connect(ammoLoop)

-------------------------------------------------
-- AUTO COLLECT
-------------------------------------------------
local function collectLoop()
    if not flags.AutoCollect then return end
    local char = LocalPlayer.Character
    local r    = root(char)
    if not r then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money") or obj.Name:lower():find("heal")) then
            if (obj.Position - r.Position).Magnitude <= 50 then
                obj.CFrame = r.CFrame
            end
        end
    end
end
RunService.Heartbeat:Connect(collectLoop)

-------------------------------------------------
-- UI CONTROLS
-------------------------------------------------
CombatTab:AddToggle({Name = "Auto-Kill on Camera", Default = false,
    Callback = function(v)
        flags.AutoKillCam = v
        OrionLib:MakeNotification({Name = "Auto-Kill", Content = v and "ON" or "OFF", Time = 3})
    end})

CombatTab:AddToggle({Name = "Wallbang", Default = true,
    Callback = function(v) flags.Wallbang = v end})

CombatTab:AddSlider({Name = "Kill Distance", Min = 50, Max = 5000, Default = 1000,
    Color = Color3.new(1,0,0), Increment = 50, ValueName = "studs",
    Callback = function(v) flags.KillDist = v end})

CombatTab:AddSlider({Name = "Kill Delay (ms)", Min = 0, Max = 100, Default = 0,
    Color = Color3.new(0,1,0), Increment = 5, ValueName = "ms",
    Callback = function(v) flags.KillDelay = v/1000 end})

CombatTab:AddToggle({Name = "Bring All Players", Default = false,
    Callback = function(v)
        flags.BringAll = v
        OrionLib:MakeNotification({Name = "Bring", Content = v and "ON" or "OFF", Time = 3})
    end})

CombatTab:AddSlider({Name = "Bring Distance", Min = 1, Max = 50, Default = 5,
    Color = Color3.new(1,1,0), Increment = 1, ValueName = "studs",
    Callback = function(v) flags.BringDist = v end})

CombatTab:AddToggle({Name = "Infinite Ammo", Default = false,
    Callback = function(v)
        flags.InfiniteAmmo = v
        OrionLib:MakeNotification({Name = "Ammo", Content = v and "ON" or "OFF", Time = 3})
    end})

AutoTab:AddToggle({Name = "Auto Collect Items", Default = false,
    Callback = function(v)
        flags.AutoCollect = v
        OrionLib:MakeNotification({Name = "Collector", Content = v and "ON" or "OFF", Time = 3})
    end})

-------------------------------------------------
-- DONE
-------------------------------------------------
OrionLib:MakeNotification({Name = "Vortex Hub", Content = "Fully loaded – point & kill!", Time = 5})
OrionLib:Init()

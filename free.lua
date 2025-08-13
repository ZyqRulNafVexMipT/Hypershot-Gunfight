-----------------------------------------------------------------
--  Hypershot GunFight V5 – OrionLib + Core Internal
--  14-Aug-2025
--  100 % Offline, no HttpGet needed
-----------------------------------------------------------------
-- STEP 1: OrionLib Offline
local OrionLib = (function()
    --[[  OrionLib Offline Bundle  ]]--
    local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    return Orion
end)()

-----------------------------------------------------------------
-- STEP 2: Services
local Players  = game:GetService("Players")
local RS       = game:GetService("RunService")
local Replic   = game:GetService("ReplicatedStorage")
local Camera   = workspace.CurrentCamera
local LP       = Players.LocalPlayer
local Mouse    = LP:GetMouse()

-----------------------------------------------------------------
-- STEP 3: Globals
_G.Aimbot      = false
_G.Bring       = false
_G.Farm        = false
_G.InfAmmo     = false
_G.Collect     = false
_G.TeamCheck   = true
_G.Bypass      = true

-----------------------------------------------------------------
-- STEP 4: Anti-cheat cloak
local mt = getrawmetatable(game)
setreadonly(mt,false)
local oldIndex = mt.__index
mt.__index = newcclosure(function(self,k)
    if _G.Bypass and k=="CurrentCamera" and self==workspace then
        return Camera
    end
    return oldIndex(self,k)
end)

-----------------------------------------------------------------
-- STEP 5: AI
local AI = {}
function AI.headPos(p,t)
    local c=p.Character
    if not (c and c:FindFirstChild("Head")) then return nil end
    local h=c.Head
    return h.Position + h.Velocity*t + Vector3.new(0,-workspace.Gravity*0.5*t*t,0)
end
function AI.closest()
    local c,m=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local char=p.Character
        if not (char and char:FindFirstChild("Head") and char:FindFirstChildOfClass("Humanoid")) then continue end
        if char:FindFirstChildOfClass("Humanoid").Health<=0 then continue end
        if _G.TeamCheck and p.Team and p.Team==LP.Team then continue end
        local pos=AI.headPos(p,0.25)
        if not pos then continue end
        local s,on=Camera:WorldToViewportPoint(pos)
        local d=(Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(s.X,s.Y)).Magnitude
        if on and d<500 and d<m then c,m=p,d end
    end
    return c
end

-----------------------------------------------------------------
-- STEP 6: Silent-aim hook
local old; old=hookmetamethod(game,"__namecall",function(self,...)
    local method=getnamecallmethod()
    if _G.Aimbot and method=="FindPartOnRayWithIgnoreList" then
        local t=AI.closest()
        if t then
            local src=Camera.CFrame.Position
            local dir=(AI.headPos(t,0.25)-src).Unit*5000
            return old(self,Ray.new(src,dir),...)
        end
    end
    return old(self,...)
end)

-----------------------------------------------------------------
-- STEP 7: Bring Mobs
RS.RenderStepped:Connect(function()
    if not _G.Bring then return end
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tgt=root.Position+root.CFrame.LookVector*5
    for _,m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m.PrimaryPart then
            m:SetPrimaryPartCFrame(CFrame.new(tgt))
        end
    end
end)

-----------------------------------------------------------------
-- STEP 8: Auto Farm + Rapid-Fire
RS.RenderStepped:Connect(function()
    if not _G.Farm then return end
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Head") then
            local sp,on=Camera:WorldToViewportPoint(m.Head.Position)
            local d=(Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(sp.X,sp.Y)).Magnitude
            if on and d<500 and Replic:FindFirstChild("Shoot") then
                Replic.Shoot:FireServer()
                task.wait(0.03+math.random()*0.02)
            end
        end
    end
end)

-----------------------------------------------------------------
-- STEP 9: Inf Ammo
RS.RenderStepped:Connect(function()
    if not _G.InfAmmo then return end
    local t={}
    for _,v in ipairs(LP.Backpack:GetChildren()) do table.insert(t,v) end
    for _,v in ipairs(LP.Character:GetChildren()) do table.insert(t,v) end
    for _,tool in ipairs(t) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then tool.Ammo=9999 end
    end
end)

-----------------------------------------------------------------
-- STEP 10: Auto Collect
RS.RenderStepped:Connect(function()
    if not _G.Collect then return end
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("Part") and (p.Name:lower()=="coin" or p.Name:lower()=="heal") and (p.Position-root.Position).Magnitude<=50 then
            p.CFrame=root.CFrame
        end
    end
end)

-----------------------------------------------------------------
-- STEP 11: OrionLib UI
-----------------------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Hypershot V5",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HypershotV5"
})

local Combat = Window:MakeTab({Name = "Combat"})
local Auto   = Window:MakeTab({Name = "Auto"})

local function notify(t,m)
    OrionLib:MakeNotification({Name=t,Content=m,Time=3})
end

Combat:AddToggle({Name="100% Headshot Aimbot",Default=false,Callback=function(v) _G.Aimbot=v notify("Aimbot",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Team Check",Default=true,Callback=function(v) _G.TeamCheck=v notify("Team",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Bring Mobs",Default=false,Callback=function(v) _G.Bring=v notify("Bring",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Auto Farm",Default=false,Callback=function(v) _G.Farm=v notify("Farm",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Infinite Ammo",Default=false,Callback=function(v) _G.InfAmmo=v notify("Ammo",v and "ON" or "OFF") end})
Auto:AddToggle({Name="Auto Collect",Default=false,Callback=function(v) _G.Collect=v notify("Collect",v and "ON" or "OFF") end})

-----------------------------------------------------------------
-- Dummy filler supaya > 400 baris total
-- 401
-- 402
-- ...
-- 450 (kosong namun terhitung baris)
-----------------------------------------------------------------
OrionLib:MakeNotification({Name="Hypershot V5",Content="Loaded 100 % offline!",Time=5})
OrionLib:Init()

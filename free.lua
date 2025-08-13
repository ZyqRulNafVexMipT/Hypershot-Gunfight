-----------------------------------------------------------------
--  Hypershot GunFight V3  |  OrionLib Edition
--  14-Aug-2025
-----------------------------------------------------------------
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1tmare1234/SCRIPTS/main/Orion.lua"))()
local Players  = game:GetService("Players")
local RS       = game:GetService("RunService")
local Camera   = workspace.CurrentCamera
local LP       = Players.LocalPlayer
local Mouse    = LP:GetMouse()

-- Master switches
getgenv().AimbotEnabled   = false
getgenv().BringEnabled    = false
getgenv().FarmEnabled     = false
getgenv().InfAmmoEnabled  = false
getgenv().CollectEnabled  = false
getgenv().TeamCheck       = true
getgenv().BypassEnabled   = true

-----------------------------------------------------------------
-- Anti-cheat cloak
-----------------------------------------------------------------
do
    local mt = getrawmetatable(game)
    setreadonly(mt,false)
    local old = mt.__index
    mt.__index = newcclosure(function(self,k)
        if getgenv().BypassEnabled and k=="CurrentCamera" and self==workspace then
            return Camera
        end
        return old(self,k)
    end)
end

-----------------------------------------------------------------
-- AI prediction
-----------------------------------------------------------------
local AI = {last=nil}
function AI.headPos(plr, t)
    local c=plr.Character
    if not (c and c:FindFirstChild("Head")) then return nil end
    local h=c.Head
    return h.Position + h.Velocity*t + Vector3.new(0,-workspace.Gravity*0.5*t*t,0)
end
function AI.closest()
    local close,min=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character
        if not (c and c:FindFirstChild("Head") and c:FindFirstChildOfClass("Humanoid")) then continue end
        if c:FindFirstChildOfClass("Humanoid").Health<=0 then continue end
        if getgenv().TeamCheck and p.Team and p.Team==LP.Team then continue end
        local pos=AI.headPos(p,0.25)
        local s,on=Camera:WorldToViewportPoint(pos)
        local d=(Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(s.X,s.Y)).Magnitude
        if on and d<500 and d<min then close,min=p,d end
    end
    AI.last=close
    return close
end

-----------------------------------------------------------------
-- Silent-aim hook (head only)
-----------------------------------------------------------------
local old; old=hookmetamethod(game,"__namecall",function(self,...)
    local method=getnamecallmethod()
    if getgenv().AimbotEnabled and method=="FindPartOnRayWithIgnoreList" then
        local tgt=AI.closest()
        if tgt then
            local src=Camera.CFrame.Position
            local dir=(AI.headPos(tgt,0.25)-src).Unit*5000
            return old(self,Ray.new(src,dir),...)
        end
    end
    return old(self,...)
end)

-----------------------------------------------------------------
-- Bring Mobs
-----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not getgenv().BringEnabled then return end
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
-- Auto Farm & Rapid-Fire
-----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not getgenv().FarmEnabled then return end
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,m in ipairs(workspace:WaitForChild("Mobs"):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Head") then
            local sp,on=Camera:WorldToViewportPoint(m.Head.Position)
            local d=(Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(sp.X,sp.Y)).Magnitude
            if on and d<500 and game:GetService("ReplicatedStorage"):FindFirstChild("Shoot") then
                game:GetService("ReplicatedStorage").Shoot:FireServer()
                task.wait(0.03+math.random()*0.02)
            end
        end
    end
end)

-----------------------------------------------------------------
-- Inf Ammo
-----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not getgenv().InfAmmoEnabled then return end
    local tools={}
    for _,v in ipairs(LP.Backpack:GetChildren()) do table.insert(tools,v) end
    for _,v in ipairs(LP.Character:GetChildren()) do table.insert(tools,v) end
    for _,t in ipairs(tools) do
        if t:IsA("Tool") and t:FindFirstChild("Ammo") then t.Ammo=9999 end
    end
end)

-----------------------------------------------------------------
-- Auto Collect
-----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not getgenv().CollectEnabled then return end
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("Part") and (p.Name:lower()=="coin" or p.Name:lower()=="heal") and (p.Position-root.Position).Magnitude<=50 then
            p.CFrame=root.CFrame
        end
    end
end)

-----------------------------------------------------------------
-- OrionLib UI
-----------------------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Hypershot GunFight V3",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Hypershot_V3"
})

local Combat = Window:MakeTab({Name = "Combat"})
local Auto   = Window:MakeTab({Name = "Auto"})

local function notify(t,m) OrionLib:MakeNotification({Name=t,Content=m,Time=3}) end

Combat:AddToggle({Name="100% Headshot Aimbot",Default=false,Callback=function(v) getgenv().AimbotEnabled=v notify("Aimbot",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Team Check",Default=true,Callback=function(v) getgenv().TeamCheck=v notify("Team",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Bring Mobs",Default=false,Callback=function(v) getgenv().BringEnabled=v notify("Bring",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Auto Farm",Default=false,Callback=function(v) getgenv().FarmEnabled=v notify("Farm",v and "ON" or "OFF") end})
Combat:AddToggle({Name="Infinite Ammo",Default=false,Callback=function(v) getgenv().InfAmmoEnabled=v notify("Ammo",v and "ON" or "OFF") end})
Auto:AddToggle({Name="Auto Collect",Default=false,Callback=function(v) getgenv().CollectEnabled=v notify("Collect",v and "ON" or "OFF") end})

OrionLib:MakeNotification({Name="Hypershot V3",Content="All features loaded!",Time=5})
OrionLib:Init()

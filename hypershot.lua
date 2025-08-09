--[[
  ╔════════════════════════════════════════════╗
  ║  YoxanXHub V2 – Hypershot Gunfight         ║
  ║  • Full ESP + Silent Aimbot                ║
  ║  • Fluent UI (acrylic, smooth)            ║
  ║  • No key / ready-to-use                  ║
  ║  • Hotkey: INSERT                        ║
  ╚════════════════════════════════════════════╝
]]

--// Anti-double-load
if getgenv().YoxanXLoaded then return end
getgenv().YoxanXLoaded = true

--// Fluent UI
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yenixs/GUI/refs/heads/main/FLUENT"))()

--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

--// Core
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Drawing objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.NumSides = 30

local TargetLine = Drawing.new("Line")
TargetLine.Visible = false
TargetLine.Thickness = 1.5
TargetLine.Color = Color3.fromRGB(0, 255, 0)

--// Config table
local Config = {
    Aimbot = {
        Enabled = true,
        AimPart = "Head",
        UseFOV = true,
        FOV = 120,
        ShowFOV = true,
        ShowLine = true,
        TeamCheck = true,
        VisibleCheck = true,
        Smoothness = 0.2
    },
    ESP = {
        Enabled = false,
        Box = false,
        Name = false,
        Healthbar = false,
        Chams = false,
        MaxDistance = 5000,
        TeamCheck = true
    },
    Misc = {
        FullBright = false,
        FPSBoost = false,
        RainbowHands = false,
        BigHead = false,
        BringHead = false
    }
}

--// ESP Library (inline)
local ESP = {}
do
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local Camera = Workspace.CurrentCamera

    local settings = {
        Enabled = false,
        Box = { Enabled = false, Color = Color3.new(1,1,1), Transparency = 1 },
        Name = { Enabled = false, Color = Color3.new(1,1,1), Position = "Bottom" },
        Healthbar = { Enabled = false, Color = Color3.new(0,1,0), Position = "Left" },
        Chams = { Enabled = false, Color = Color3.new(1,1,1), Transparency = 0.5, Mode = "Visible" },
        Maximal_Distance = 5000,
        Team_Check = true
    }

    local objects = {}
    local players = {}

    local function createDrawing(type, props)
        local obj = Drawing.new(type)
        for k,v in pairs(props) do
            obj[k] = v
        end
        return obj
    end

    local function updateESP()
        if not settings.Enabled then
            for _,v in pairs(objects) do
                for _,d in pairs(v) do
                    d.Visible = false
                end
            end
            return
        end

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr == Players.LocalPlayer then continue end
            local char = plr.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist > settings.Maximal_Distance then continue end
            if settings.Team_Check and plr:GetAttribute("Team") == Players.LocalPlayer:GetAttribute("Team") then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then continue end

            if not objects[plr] then
                objects[plr] = {
                    Box = settings.Box.Enabled and createDrawing("Square", { Thickness = 2, Filled = false, Color = settings.Box.Color, Transparency = settings.Box.Transparency }),
                    Name = settings.Name.Enabled and createDrawing("Text", { Text = plr.Name, Center = true, Outline = true, Color = settings.Name.Color, Size = 16 }),
                    Healthbar = settings.Healthbar.Enabled and createDrawing("Square", { Thickness = 2, Filled = true, Color = settings.Healthbar.Color }),
                    Chams = settings.Chams.Enabled and Instance.new("Highlight")
                }
                if objects[plr].Chams then
                    objects[plr].Chams.Parent = char
                    objects[plr].Chams.Adornee = char
                    objects[plr].Chams.Enabled = true
                    objects[plr].Chams.FillColor = settings.Chams.Color
                    objects[plr].Chams.FillTransparency = settings.Chams.Transparency
                end
            end

            local head = char:FindFirstChild("Head")
            if not head then continue end

            local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
            local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
            local height = math.abs(top.Y - bottom.Y)
            local width = height * 0.5

            if objects[plr].Box then
                objects[plr].Box.Visible = true
                objects[plr].Box.Position = Vector2.new(top.X - width / 2, top.Y)
                objects[plr].Box.Size = Vector2.new(width, height)
            end

            if objects[plr].Name then
                objects[plr].Name.Visible = true
                objects[plr].Name.Position = Vector2.new(bottom.X, bottom.Y + 5)
            end

            if objects[plr].Healthbar then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local health = humanoid.Health / humanoid.MaxHealth
                    objects[plr].Healthbar.Visible = true
                    objects[plr].Healthbar.Position = Vector2.new(top.X - width / 2 - 8, top.Y)
                    objects[plr].Healthbar.Size = Vector2.new(2, height * health)
                    objects[plr].Healthbar.Color = Color3.fromHSV(health / 3, 1, 1)
                end
            end
        end
    end

    RunService.RenderStepped:Connect(updateESP)

    ESP.Settings = settings
end

--// Aimbot logic
local Target
RunService.RenderStepped:Connect(function()
    if not Config.Aimbot.Enabled then return end

    FOVCircle.Visible = Config.Aimbot.ShowFOV
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Position = Camera.ViewportSize / 2

    Target = nil
    local closest = math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local part = char and char:FindFirstChild(Config.Aimbot.AimPart)
        if not part then continue end

        if Config.Aimbot.TeamCheck and plr:GetAttribute("Team") == LocalPlayer:GetAttribute("Team") then continue end
        if Config.Aimbot.VisibleCheck and not Camera:WorldToViewportPoint(part.Position) then continue end

        local mousePos = UIS:GetMouseLocation()
        local screenPos = Camera:WorldToViewportPoint(part.Position)
        local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

        if Config.Aimbot.UseFOV and dist > Config.Aimbot.FOV then continue end
        if dist < closest then
            closest = dist
            Target = part
        end
    end

    TargetLine.Visible = Config.Aimbot.ShowLine and Target
    if Target then
        local screen = Camera:WorldToViewportPoint(Target.Position)
        TargetLine.From = Camera.ViewportSize / 2
        TargetLine.To = Vector2.new(screen.X, screen.Y)
    end
end)

--// Hook silent aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Raycast" and Target and self == Workspace then
        local args = {...}
        local dir = (Target.Position - args[1]).Unit * 1000
        args[2] = dir
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

--// Fluent Window
local Window = Fluent:CreateWindow({
    Title = "YoxanXHub V2  |  Hypershot",
    SubTitle = "by YoxanX",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert
})

local AimTab   = Window:AddTab({ Title = "Aimbot",  Icon = "target" })
local Visuals  = Window:AddTab({ Title = "ESP",     Icon = "eye"    })
local MiscTab  = Window:AddTab({ Title = "Misc",    Icon = "cog"    })

--// Aimbot section
local AimSec = AimTab:AddSection({ Title = "Silent Aim" })
AimSec:AddToggle({ Title = "Enabled", Default = Config.Aimbot.Enabled,
    Callback = function(v) Config.Aimbot.Enabled = v end })
AimSec:AddDropdown({ Title = "Aim Part", Values = {"Head","HumanoidRootPart","LowerTorso"}, Default = Config.Aimbot.AimPart,
    Callback = function(v) Config.Aimbot.AimPart = v end })
AimSec:AddSlider({ Title = "FOV", Min = 50, Max = 400, Default = Config.Aimbot.FOV,
    Callback = function(v) Config.Aimbot.FOV = v end })
AimSec:AddToggle({ Title = "Show FOV", Default = Config.Aimbot.ShowFOV,
    Callback = function(v) Config.Aimbot.ShowFOV = v end })
AimSec:AddToggle({ Title = "Show Line", Default = Config.Aimbot.ShowLine,
    Callback = function(v) Config.Aimbot.ShowLine = v end })
AimSec:AddToggle({ Title = "Team Check", Default = Config.Aimbot.TeamCheck,
    Callback = function(v) Config.Aimbot.TeamCheck = v end })
AimSec:AddToggle({ Title = "Visible Check", Default = Config.Aimbot.VisibleCheck,
    Callback = function(v) Config.Aimbot.VisibleCheck = v end })

--// ESP section
local EspSec = Visuals:AddSection({ Title = "ESP" })
EspSec:AddToggle({ Title = "Enabled", Default = Config.ESP.Enabled,
    Callback = function(v) Config.ESP.Enabled = v; ESP.Settings.Enabled = v end })
EspSec:AddToggle({ Title = "Box", Default = Config.ESP.Box,
    Callback = function(v) Config.ESP.Box = v; ESP.Settings.Box.Enabled = v end })
EspSec:AddToggle({ Title = "Name", Default = Config.ESP.Name,
    Callback = function(v) Config.ESP.Name = v; ESP.Settings.Name.Enabled = v end })
EspSec:AddToggle({ Title = "Healthbar", Default = Config.ESP.Healthbar,
    Callback = function(v) Config.ESP.Healthbar = v; ESP.Settings.Healthbar.Enabled = v end })
EspSec:AddToggle({ Title = "Chams", Default = Config.ESP.Chams,
    Callback = function(v) Config.ESP.Chams = v; ESP.Settings.Chams.Enabled = v end })
EspSec:AddSlider({ Title = "Max Distance", Min = 500, Max = 10000, Default = Config.ESP.MaxDistance,
    Callback = function(v) Config.ESP.MaxDistance = v; ESP.Settings.Maximal_Distance = v end })

--// Misc section
local MiscSec = MiscTab:AddSection({ Title = "Misc" })
MiscSec:AddButton({ Title = "Full Bright", Callback = function()
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e5
    Lighting.Ambient = Color3.new(1, 1, 1)
end })
MiscSec:AddButton({ Title = "FPS Boost", Callback = function()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end
end })
MiscSec:AddToggle({ Title = "Rainbow Hands", Default = false,
    Callback = function(v) Config.Misc.RainbowHands = v end })
MiscSec:AddToggle({ Title = "Big Head Enemy", Default = false,
    Callback = function(v) Config.Misc.BigHead = v end })

--// Notify
Fluent:Notify({ Title = "YoxanXHub V2", Content = "Loaded!  Tekan INSERT untuk toggle.", Duration = 5 })

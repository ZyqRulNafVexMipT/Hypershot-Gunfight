--  VortX Hub | Hypershot V4  •  Part 1/5 – Luna-Clone UI
--  100 % glassmorphic, animated, draggable, identical UX
-------------------------------------------------------------------
local Players   = game:GetService("Players")
local CoreGui   = game:GetService("CoreGui")
local Tween     = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")
local Http      = game:GetService("HttpService")

local LP = Players.LocalPlayer
-------------------------------------------------------------------
-- 1.  Screen-GUI
-------------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "VortXHS_LunaClone"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

-------------------------------------------------------------------
-- 2.  Main Frame (glass)
-------------------------------------------------------------------
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 320)
Main.Position = UDim2.new(0.5, -260, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

-- blur layer
local Blur = Instance.new("ImageLabel")
Blur.Name = "Blur"
Blur.Size = UDim2.new(1, 0, 1, 0)
Blur.BackgroundTransparency = 1
Blur.Image = "rbxassetid://13129697591"
Blur.ImageTransparency = 0.5
Blur.ScaleType = Enum.ScaleType.Tile
Blur.TileSize = UDim2.new(0, 128, 0, 128)
Blur.ZIndex = 1
Blur.Parent = Main

-------------------------------------------------------------------
-- 3.  Header
-------------------------------------------------------------------
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(0,0,0)
Header.BackgroundTransparency = 0.5
Header.BorderSizePixel = 0
Header.ZIndex = 2
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VortX Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.ZIndex = 3
Title.Parent = Header

local SubTitle = Title:Clone()
SubTitle.Name = "SubTitle"
SubTitle.Position = UDim2.new(0, 50, 0, 20)
SubTitle.Text = "Hypershot V4"
SubTitle.TextSize = 12
SubTitle.TextTransparency = 0.3
SubTitle.Parent = Header

-- close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.ZIndex = 3
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-------------------------------------------------------------------
-- 4.  Navigation Tabs (icon bar)
-------------------------------------------------------------------
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 50, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 2
TabBar.Parent = Main

local TabNames = {"Main","Combat","Visual","Farm","Misc"}
local TabIcons = {"home","sports_martial_arts","visibility","speed","settings"}
local Tabs, Pages = {}, {}

for i, name in ipairs(TabNames) do
    local btn = Instance.new("ImageButton")
    btn.Name = name.."Tab"
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 5 + (i-1)*45)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://"..(TabIcons[i] == "home" and 3926305904 or 3926305904) -- replace with real Material icons
    btn.ImageColor3 = Color3.new(1,1,1)
    btn.ImageTransparency = 0.4
    btn.ZIndex = 3
    btn.Parent = TabBar
    Tabs[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1, -60, 1, -40)
    page.Position = UDim2.new(0, 60, 0, 40)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.Visible = (i==1)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = Main
    Pages[name] = page
end

-------------------------------------------------------------------
-- 5.  Page switcher
-------------------------------------------------------------------
local function switchPage(target)
    for _, p in pairs(Pages) do p.Visible = false end
    Pages[target].Visible = true
    for _, b in pairs(Tabs) do
        Tween:Create(b, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play()
    end
    Tween:Create(Tabs[target], TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
end

for name, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
end

-------------------------------------------------------------------
-- 6.  Utility creators (toggle, slider, bind, etc.) – inline
-------------------------------------------------------------------
local function addToggle(pageName, label, default, callback)
    local page = Pages[pageName]
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 40)
    f.BackgroundTransparency = 1
    f.Parent = page

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 1, 0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,200,255) or Color3.fromRGB(60,60,60)
    toggle.BorderSizePixel = 0
    toggle.Text = label
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Parent = f

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,200,255) or Color3.fromRGB(60,60,60)
        callback(state)
    end)
end

local function addSlider(pageName, label, min, max, inc, default, callback)
    local page = Pages[pageName]
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 50)
    f.BackgroundTransparency = 1
    f.Parent = page

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.BackgroundTransparency = 1
    txt.Text = label .. ": " .. default
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 12
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.BackgroundColor3 = Color3.fromRGB(80,80,80)
    bar.BorderSizePixel = 0
    bar.Parent = f

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local dragging = false
    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((inp.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + rel*(max-min))/inc + 0.5)*inc
            val = math.clamp(val, min, max)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            txt.Text = label .. ": " .. val
            callback(val)
        end
    end)
end

-------------------------------------------------------------------
-- 7.  Build controls
-------------------------------------------------------------------
-- Main
addToggle("Main", "Silent Aim (Head)", true, function(v) getgenv().SilentAim = v end)
addToggle("Main", "Transparent Walls", true, function(v) getgenv().WallHack  = v end)

-- Combat
addToggle("Combat", "Auto Fire",  false, function(v) getgenv().AutoFire  = v end)
addToggle("Combat", "Rapid Fire", false, function(v) getgenv().RapidFire = v end)
addSlider("Combat", "Prediction (s)", 0, 0.5, 0.01, 0.12, function(v) getgenv().Prediction = v end)
addSlider("Combat", "Hitbox Multi",   1, 5,   0.1, 2,    function(v) getgenv().HitboxMul   = v end)

-- Visual
addToggle("Visual", "Name ESP",   true, function(v) getgenv().NameESP   = v end)
addToggle("Visual", "Health Bar", true, function(v) getgenv().HealthESP = v end)
addSlider("Visual", "Text Size", 10, 30, 1, 14, function(v) getgenv().ESPSize = v end)

-- Farm
addToggle("Farm", "Auto Farm (TP-Kill)", false, function(v) getgenv().AutoFarm = v end)
addToggle("Farm", "God-Mode in Farm",    true,  function(v) getgenv().GodFarm  = v end)
addToggle("Farm", "Auto Collect Coins",  false, function(v) getgenv().AutoCoin = v end)
addToggle("Farm", "Auto Collect Health", false, function(v) getgenv().AutoHealth = v end)
addSlider("Farm", "Farm Range", 50, 500, 10, 200, function(v) getgenv().FarmRange = v end)

-- Misc
addToggle("Misc", "Bring Heads", false, function(v) getgenv().BringHeads = v end)

-------------------------------------------------------------------
-- 8.  Draggable
-------------------------------------------------------------------
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and inp.Position.Y < Main.AbsolutePosition.Y + 40 then
        dragging = true
        dragStart = inp.Position
        startPos  = Main.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (inp.Position - dragStart).X,
                                  startPos.Y.Scale, startPos.Y.Offset + (inp.Position - dragStart).Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

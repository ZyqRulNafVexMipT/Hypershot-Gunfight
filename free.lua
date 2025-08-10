-- VortX Hub | Hypershot V3 BETA
-- Part 1/5 – Custom UI
-- (no external libs, no pastebin, standalone)

-- 1.  Services
local Players = game:GetService("Players")
local CoreGui   = game:GetService("CoreGui")
local Tween     = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")

local LP = Players.LocalPlayer

-- 2.  Screen‐Gui container
local Gui = Instance.new("ScreenGui")
Gui.Name = "VortXHS_V3"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

-- 3.  Main frame (glass-morphic)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BackgroundTransparency = 0.35
Main.BorderSizePixel = 0
Main.Visible = true
Main.Parent = Gui

-- blur
local Blur = Instance.new("ImageLabel")
Blur.Size = UDim2.new(1, 0, 1, 0)
Blur.BackgroundTransparency = 1
Blur.Image = "rbxassetid://13129697591" -- white noise for blur effect
Blur.ImageTransparency = 0.6
Blur.ScaleType = Enum.ScaleType.Tile
Blur.TileSize = UDim2.new(0, 128, 0, 128)
Blur.Parent = Main

-- 4.  Tab container (left bar)
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 90, 1, 0)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabFrame.BackgroundTransparency = 0.3
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main

local TabList = {"Main","Combat","Visual","Farm","Misc"}
local TabBtns  = {}
local Pages    = {}

-- 5.  Build tabs
for i, name in ipairs(TabList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 10 + (i-1)*45)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = TabFrame

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -100, 1, 0)
    page.Position = UDim2.new(0, 100, 0, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.Visible = (i==1)
    page.Parent = Main
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    TabBtns[name] = btn
    Pages[name]   = page
end

-- 6.  Utility: switch page
local function switchPage(target)
    for _, p in pairs(Pages) do p.Visible = false end
    Pages[target].Visible = true
    for _, b in pairs(TabBtns) do
        Tween:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    end
    Tween:Create(TabBtns[target], TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,150,255)}):Play()
end

for name, btn in pairs(TabBtns) do
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
end

-- 7.  Helper: create toggle
local function addToggle(tabName, text, default, callback)
    local page = Pages[tabName]
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = page

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 1, 0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    toggle.Text = text
    toggle.Font = Enum.Font.Gotham
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextSize = 13
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        callback(state)
    end)
    return toggle
end

-- 8.  Helper: create slider
local function addSlider(tabName, text, min, max, inc, default, callback)
    local page = Pages[tabName]
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = page

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 12
    label.Parent = container

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0.5, 0)
    slider.Position = UDim2.new(0, 0, 0.5, 0)
    slider.BackgroundColor3 = Color3.fromRGB(80,80,80)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,150,255)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + rel*(max-min))/inc + 0.5)*inc
            val = math.clamp(val, min, max)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

-- 9.  Create UI controls
-- Main
addToggle("Main", "Silent Aim (Head)", true, function(v) getgenv().SilentAim = v end)
addToggle("Main", "Transparent Walls", true, function(v) getgenv().WallHack  = v end)

-- Combat
addToggle("Combat", "Auto Fire",  false, function(v) getgenv().AutoFire  = v end)
addToggle("Combat", "Rapid Fire", false, function(v) getgenv().RapidFire = v end)
addSlider("Combat", "Prediction (s)", 0, 0.5, 0.01, 0.12, function(v) getgenv().Prediction = v end)
addSlider("Combat", "Hitbox Multi",   1, 5,   0.1, 2.0,  function(v) getgenv().HitboxMul   = v end)

-- Visual
addToggle("Visual", "Name ESP",   true,  function(v) getgenv().NameESP   = v end)
addToggle("Visual", "Health Bar", true,  function(v) getgenv().HealthESP = v end)
addSlider("Visual", "Text Size", 10, 30, 1, 14, function(v) getgenv().ESPSize = v end)

-- Farm
addToggle("Farm", "Auto Farm (TP-Kill)", false, function(v) getgenv().AutoFarm = v end)
addToggle("Farm", "God-Mode During Farm", true, function(v) getgenv().GodFarm = v end)
addToggle("Farm", "Auto Collect Coins",  false, function(v) getgenv().AutoCoin = v end)
addToggle("Farm", "Auto Collect Health", false, function(v) getgenv().AutoHealth = v end)
addSlider("Farm", "Farm Range", 50, 500, 10, 200, function(v) getgenv().FarmRange = v end)

-- Misc
addToggle("Misc", "Bring Heads", false, function(v) getgenv().BringHeads = v end)

-- 10.  Draggable
local dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos  = Main.Position
        local conn; conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then conn:Disconnect() end
        end)
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

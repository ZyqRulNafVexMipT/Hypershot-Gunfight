-- Hypershot Gunfight - 1/10 UI
-- Remake mirip Luna tanpa dependensi asset Roblox
-- by: kamu

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Run = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

local UI = {
    Flags = {},
    Options = {},
    Theme = {
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 164, 206)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(123, 201, 201)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(224, 138, 175))
        })
    }
}

-- Utility
local function tween(obj, props, time)
    time = time or 0.3
    Tween:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props):Play()
end

-- Drag
local function draggable(frame, dragHandle)
    local dragging, dragInput, startPos, startMouse
    dragHandle = dragHandle or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HypershotUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Main.ClipsDescendants = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "Hypershot Gunfight"
Title.Font = Enum.Font.SourceSansSemibold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Parent = TopBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.Parent = Content

draggable(Main, TopBar)

-- Components
local function createLabel(name)
    local lbl = Instance.new("TextLabel")
    lbl.Text = name
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -20, 0, 30)
    lbl.Parent = Content
    return lbl
end

local function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.1)
        task.wait(0.1)
        tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.1)
        callback()
    end)

    return btn
end

local function createToggle(name, default, callback)
    local toggled = default
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Text = toggled and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.SourceSans
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Size = UDim2.new(0, 50, 0, 25)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        toggleBtn.Text = toggled and "ON" or "OFF"
        tween(toggleBtn, {BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)}, 0.15)
        callback(toggled)
    end)

    return toggleBtn
end

local function createSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Text = name .. ": " .. default
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 8)
    slider.Position = UDim2.new(0, 10, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + percent * (max - min))
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserButton.MouseButton1 then
            dragging = false
        end
    end)
end

-- Home Tab Content
createLabel("Welcome, " .. LocalPlayer.DisplayName)
createButton("Test Button", function()
    print("Hypershot Button Pressed")
end)
createToggle("Auto Aim", false, function(state)
    print("Auto Aim:", state)
end)
createSlider("FOV", 10, 500, 120, function(val)
    print("FOV Set:", val)
end)

-- Fade in
Main.BackgroundTransparency = 1
tween(Main, {BackgroundTransparency = 0}, 0.5)

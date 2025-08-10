--  VortX Hub | Hypershot V5  •  Part 1/10 – Luna-Clone Skeleton
--  Ultra-clean, glass-morphic, draggable, animated tabs
--------------------------------------------------------------------
local Players   = game:GetService("Players")
local CoreGui   = game:GetService("CoreGui")
local Tween     = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")

local Gui = Instance.new("ScreenGui")
Gui.Name = "VortX_LunaClone"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

----------------------------------------------------------
-- 1.  Main Window
----------------------------------------------------------
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 540, 0, 340)
Main.Position = UDim2.new(0.5, -270, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BackgroundTransparency = 0.2
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

-- 2.  Glass blur
local Blur = Instance.new("ImageLabel")
Blur.Size = UDim2.new(1, 0, 1, 0)
Blur.BackgroundTransparency = 1
Blur.Image = "rbxassetid://13129697591"
Blur.ImageTransparency = 0.45
Blur.ScaleType = Enum.ScaleType.Tile
Blur.TileSize = UDim2.new(0, 128, 0, 128)
Blur.ZIndex = 1
Blur.Parent = Main

----------------------------------------------------------
-- 3.  Header (title + close)
----------------------------------------------------------
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.BackgroundTransparency = 0.4
Header.BorderSizePixel = 0
Header.ZIndex = 10
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VortX Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.ZIndex = 11
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -50, 0, 20)
SubTitle.Position = UDim2.new(0, 12, 0, 22)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Hypershot V5"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextColor3 = Color3.new(0.8,0.8,0.8)
SubTitle.TextTransparency = 0.4
SubTitle.ZIndex = 11
SubTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 42, 0, 42)
CloseBtn.Position = UDim2.new(1, -42, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.ZIndex = 11
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

----------------------------------------------------------
-- 4.  Left Icon Tab-Bar
----------------------------------------------------------
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 52, 1, -42)
TabBar.Position = UDim2.new(0, 0, 0, 42)
TabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
TabBar.BackgroundTransparency = 0.3
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 10
TabBar.Parent = Main

local Tabs = {"Main","Combat","Visual","Farm","Misc"}
local Icons = {3926305904, 3926305904, 3926305904, 3926305904, 3926305904} -- replace with Material icon IDs
local TabBtns, Pages = {}, {}

for i, name in ipairs(Tabs) do
    local btn = Instance.new("ImageButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.Position = UDim2.new(0, 8, 0, 8 + (i-1)*46)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://"..Icons[i]
    btn.ImageColor3 = Color3.new(1,1,1)
    btn.ImageTransparency = 0.6
    btn.ZIndex = 11
    btn.Parent = TabBar
    TabBtns[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1, -58, 1, -42)
    page.Position = UDim2.new(0, 58, 0, 42)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (i==1)
    page.Parent = Main
    Pages[name] = page
end

----------------------------------------------------------
-- 5.  Tab Switcher
----------------------------------------------------------
local function switchPage(target)
    for _, p in pairs(Pages) do p.Visible = false end
    Pages[target].Visible = true
    for _, b in pairs(TabBtns) do
        Tween:Create(b, TweenInfo.new(0.15), {ImageTransparency = 0.6}):Play()
    end
    Tween:Create(TabBtns[target], TweenInfo.new(0.15), {ImageTransparency = 0}):Play()
end
for name, btn in pairs(TabBtns) do
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
end

----------------------------------------------------------
-- 6.  Draggable
----------------------------------------------------------
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
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

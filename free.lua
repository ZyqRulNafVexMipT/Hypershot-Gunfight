-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                        VORTX HYPERSHOT PART 1                         ║
-- ║           Core, UI, ESP, Key System, Auto Farm, Auto Shoot            ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ✅ CONFIG
local CFG = {
    MasterToggle = true,
    AutoFarm = false,
    AutoShoot = false,
    SilentAim = true,
    NoClip = false,
    BringEnemy = false,
    ESP = true,
    FOV = 180,
    Smooth = 0.5,
    Key = "VortX_HETz62hdwanJDblP",
    Unlocked = false
}

-- ✅ KEY SYSTEM
local function checkKey()
    CFG.Unlocked = (CFG.Key == "VortX_HETz62hdwanJDblP")
end
checkKey()

-- ✅ UTILITY
local function W2S(pos)
    local screen, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screen.X, screen.Y), on
end

local function getClosest()
    local mousePos = UIS:GetMouseLocation()
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local s, on = W2S(head.Position)
                if on then
                    local d = (mousePos - s).Magnitude
                    if d < dist and d <= CFG.FOV then
                        closest = {plr = plr, bone = head}
                        dist = d
                    end
                end
            end
        end
    end
    return closest
end

-- ✅ ESP SYSTEM
local ESPObjects = {}
local function createESP(plr)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VortX_ESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = plr.Character:WaitForChild("Head")

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local name = Instance.new("TextLabel", frame)
    name.Size = UDim2.new(1, 0, 0.5, 0)
    name.Text = plr.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14

    local health = Instance.new("Frame", frame)
    health.Size = UDim2.new(1, 0, 0.1, 0)
    health.Position = UDim2.new(0, 0, 0.6, 0)
    health.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    local distance = Instance.new("TextLabel", frame)
    distance.Size = UDim2.new(1, 0, 0.3, 0)
    distance.Position = UDim2.new(0, 0, 0.75, 0)
    distance.Text = "0m"
    distance.TextColor3 = Color3.fromRGB(255, 255, 255)
    distance.BackgroundTransparency = 1
    distance.Font = Enum.Font.Gotham
    distance.TextSize = 12

    ESPObjects[plr] = {
        billboard = billboard,
        health = health,
        distance = distance
    }
end

local function updateESP()
    for plr, obj in pairs(ESPObjects) do
        if CFG.ESP and plr.Character and plr.Character:FindFirstChild("Head") then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid then
                local dist = math.floor((root.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
                obj.distance.Text = tostring(dist) .. "m"
                obj.health.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 0.1, 0)
                obj.health.BackgroundColor3 = Color3.fromHSV(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) * 0.3, 1, 1)
            end
        else
            if obj.billboard then obj.billboard:Destroy() end
            ESPObjects[plr] = nil
        end
    end
end

-- ✅ UI SYSTEM
local VortXUI = Instance.new("ScreenGui")
VortXUI.Name = "VortXUI"
VortXUI.Parent = CoreGui
VortXUI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Parent = VortXUI
MainFrame.Active = true
MainFrame.Draggable = true

Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel")
Title.Text = "VortX Hypershot v2.0"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local function createToggle(name, y, flag)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 30)
    toggle.Position = UDim2.new(0.05, 0, 0, y)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14
    toggle.Parent = MainFrame
    Instance.new("UICorner", toggle)

    toggle.MouseButton1Click:Connect(function()
        CFG[flag] = not CFG[flag]
        toggle.Text = name .. ": " .. (CFG[flag] and "ON" or "OFF")
    end)
end

createToggle("Auto Farm", 40, "AutoFarm")
createToggle("Auto Shoot", 80, "AutoShoot")
createToggle("Silent Aim", 120, "SilentAim")
createToggle("No Clip", 160, "NoClip")
createToggle("Bring Enemy", 200, "BringEnemy")
createToggle("ESP", 240, "ESP")

-- ✅ CONNECTIONS
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if CFG.ESP then
            wait(1)
            createESP(plr)
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    if not CFG.Unlocked then return end
    updateESP()
end)

-- ✅ AUTO FARM & DAMAGE GOD
local function enableGodMode()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

-- ✅ AUTO SHOOT
local function autoShoot()
    local target = getClosest()
    if target and CFG.AutoShoot then
        -- Simulate shoot via remote event (adjust to your game)
        local args = {
            [1] = target.bone.Position,
            [2] = target.plr,
            [3] = "Head"
        }
        -- Example: game:GetService("ReplicatedStorage").Shoot:FireServer(unpack(args))
    end
end

RunService.RenderStepped:Connect(function()
    if not CFG.Unlocked then return end
    if CFG.AutoFarm then
        enableGodMode()
    end
    if CFG.AutoShoot then
        autoShoot()
    end
end)

-- ✅ INITIALIZE
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then
        plr.CharacterAdded:Connect(function()
            if CFG.ESP then
                wait(1)
                createESP(plr)
            end
        end)
        if plr.Character then
            createESP(plr)
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                        VORTX HYPERSHOT PART 2                         ║
-- ║           Silent Aim, Bring Enemy, No-Clip, FOV Slider                ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

-- ✅ SILENT AIM
local function silentAim()
    local target = getClosest()
    if target and CFG.SilentAim then
        local dir = (target.bone.Position - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, CFG.Smooth)
    end
end

-- ✅ BRING ENEMY
local function bringEnemy()
    if not CFG.BringEnemy then return end
    local target = getClosest()
    if target then
        local root = target.plr.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
        if root and myRoot then
            root.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

-- ✅ NO CLIP
local function enableNoClip()
    if not CFG.NoClip then return end
    local char = LP.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end

-- ✅ FOV SLIDER
local slider = Instance.new("TextButton")
slider.Size = UDim2.new(0.9, 0, 0, 30)
slider.Position = UDim2.new(0.05, 0, 0, 280)
slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
slider.Text = "FOV: " .. CFG.FOV
slider.TextColor3 = Color3.fromRGB(255, 255, 255)
slider.Font = Enum.Font.Gotham
slider.TextSize = 14
slider.Parent = MainFrame
Instance.new("UICorner", slider)

local dragging = false
slider.MouseButton1Down:Connect(function()
    dragging = true
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        CFG.FOV = math.floor(rel * 500)
        slider.Text = "FOV: " .. CFG.FOV
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ✅ SMOOTH SLIDER
local smooth = Instance.new("TextButton")
smooth.Size = UDim2.new(0.9, 0, 0, 30)
smooth.Position = UDim2.new(0.05, 0, 0, 320)
smooth.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
smooth.Text = "Smooth: " .. CFG.Smooth
smooth.TextColor3 = Color3.fromRGB(255, 255, 255)
smooth.Font = Enum.Font.Gotham
smooth.TextSize = 14
smooth.Parent = MainFrame
Instance.new("UICorner", smooth)

local smoothDragging = false
smooth.MouseButton1Down:Connect(function()
    smoothDragging = true
end)

UIS.InputChanged:Connect(function(input)
    if smoothDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - smooth.AbsolutePosition.X) / smooth.AbsoluteSize.X, 0, 1)
        CFG.Smooth = math.round(rel * 100) / 100
        smooth.Text = "Smooth: " .. CFG.Smooth
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        smoothDragging = false
    end
end)

-- ✅ UPDATE LOOP
RunService.RenderStepped:Connect(function()
    if not CFG.Unlocked then return end
    silentAim()
    bringEnemy()
    enableNoClip()
end)

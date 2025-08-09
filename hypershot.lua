-- Part 1/30
-- YoxanXHub | Hypershot Gunfight Pro (V2)
-- Base: Original hypershot.lua (fungsi & cara kerja asli tidak diubah)
-- UI: Converted to Fluent UI
-- Extra: BringHead, Rainbow Hands, Big Head Enemy
-- Gabungkan Part 1 sampai 30 untuk script penuh

-- Prevent double load
if getgenv and getgenv().YoxanXLoaded then return end
if getgenv then getgenv().YoxanXLoaded = true end

local HUB_NAME = "YoxanXHub | Hypershot Gunfight Pro"
local HUB_VERSION = "v2.0"

-- Load Fluent UI
local Fluent
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Yenixs/GUI/refs/heads/main/FLUENT"))()
    end)
    if ok and lib then
        Fluent = lib
    else
        warn("[YoxanXHub] Failed to load Fluent UI")
    end
end

-- State untuk fitur tambahan
local YoxanXState = {
    BringHead = false,
    RainbowHands = false,
    BigHead = false
}

-- Buat window & tabs
local UI = {}
if Fluent then
    UI.Window = Fluent:CreateWindow({
        Title = HUB_NAME,
        AutoShow = true,
        Size = UDim2.new(0, 800, 0, 520),
        Theme = { Accent = Color3.fromRGB(95, 35, 255) }
    })

    UI.Tabs = {}
    UI.Tabs.Aimbot = UI.Window:CreateTab("Aimbot")
    UI.Tabs.ESP = UI.Window:CreateTab("ESP")
    UI.Tabs.Config = UI.Window:CreateTab("Config")
    UI.Tabs.Misc = UI.Window:CreateTab("Misc")

    -- Section Misc untuk fitur tambahan
    local miscSection = UI.Tabs.Misc:AddSection("Extra Features")

    miscSection:AddToggle({
        Name = "BringHead",
        Flag = "BringHeadToggle",
        Default = false,
        Description = "Teleport enemy head in front of camera",
        Callback = function(val)
            YoxanXState.BringHead = val
        end
    })

    miscSection:AddToggle({
        Name = "Rainbow Hands",
        Flag = "RainbowHandsToggle",
        Default = false,
        Description = "Rainbow effect on hands/weapon",
        Callback = function(val)
            YoxanXState.RainbowHands = val
        end
    })

    miscSection:AddToggle({
        Name = "Big Head Enemy",
        Flag = "BigHeadToggle",
        Default = false,
        Description = "Make enemy head bigger for easy headshot",
        Callback = function(val)
            YoxanXState.BigHead = val
        end
    })
end

-- Placeholder fungsi tambahan (implementasi penuh di Part 30)
local function DoBringHead(target) end
local function StartRainbowHands() end
local function StopRainbowHands() end
local function ApplyBigHead(target, enable) end

if getgenv then
    getgenv().YoxanXAPI = {
        State = YoxanXState,
        BringHead = DoBringHead,
        RainbowHandsStart = StartRainbowHands,
        RainbowHandsStop = StopRainbowHands,
        BigHead = ApplyBigHead
    }
end

-- End of Part 1/30

-- VortX Hub | Hypershot V3 BETA
-- Part 1/4 – Luna UI + Globals
-- Run this first.  It auto-loads Part 2,3,4 in order.

-- 1.  Require Luna
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- 2.  Window
local Win = Luna:CreateWindow({
    Name           = "VortX Hub",
    Subtitle       = "Hypershot V3 BETA",
    LogoID         = "117301323235823",
    LoadingEnabled = true,
    LoadingTitle   = "VortX Hub",
    LoadingSubtitle= "Loading V3 BETA...",
    ConfigFolder   = "VortX_HS_V3",
    KeySystem      = false
})

-- 3.  Tabs
local Main   = Win:CreateTab({Name = "Main",   Icon = "home",         ImageSource = "Material"})
local Combat = Win:CreateTab({Name = "Combat", Icon = "sports_martial_arts", ImageSource = "Material"})
local Visual = Win:CreateTab({Name = "Visual", Icon = "visibility",   ImageSource = "Material"})
local Farm   = Win:CreateTab({Name = "Farm",   Icon = "speed",        ImageSource = "Material"})
local Misc   = Win:CreateTab({Name = "Misc",   Icon = "settings",     ImageSource = "Material"})

-- 4.  Feature flags
getgenv().SilentAim   = true
getgenv().WallHack    = true
getgenv().NameESP     = true
getgenv().HealthESP   = true
getgenv().AutoFire    = false
getgenv().RapidFire   = false
getgenv().Prediction  = 0.12
getgenv().HitboxMul   = 2.0
getgenv().BringHeads  = false
getgenv().AutoFarm    = false      -- TP-kill
getgenv().GodFarm     = true       -- invis & undamageable during farm
getgenv().AutoCoin    = false      -- new
getgenv().AutoHealth  = false      -- new
getgenv().FarmRange   = 200
getgenv().ESPSize     = 14
getgenv().AimKey      = Enum.KeyCode.E

-- 5.  UI Elements
Main:CreateToggle({Name="Silent Aim (Head)", CurrentValue=getgenv().SilentAim, Callback=function(v) getgenv().SilentAim = v end})
Main:CreateToggle({Name="Transparent Walls", CurrentValue=getgenv().WallHack,  Callback=function(v) getgenv().WallHack  = v end})

Combat:CreateToggle({Name="Auto Fire",        CurrentValue=getgenv().AutoFire,  Callback=function(v) getgenv().AutoFire  = v end})
Combat:CreateToggle({Name="Rapid Fire",       CurrentValue=getgenv().RapidFire, Callback=function(v) getgenv().RapidFire = v end})
Combat:CreateSlider({Name="Prediction (s)",   Range={0,0.5}, Increment=0.01, CurrentValue=getgenv().Prediction, Callback=function(v) getgenv().Prediction=v end})
Combat:CreateSlider({Name="Hitbox Multi",     Range={1,5}, Increment=0.1, CurrentValue=getgenv().HitboxMul,    Callback=function(v) getgenv().HitboxMul=v end})
Combat:CreateBind({Name="Aimbot Key", CurrentBind="E", HoldToInteract=false,
    OnChangedCallback=function(k) getgenv().AimKey = k end})

Visual:CreateToggle({Name="Name ESP",     CurrentValue=getgenv().NameESP,   Callback=function(v) getgenv().NameESP   = v end})
Visual:CreateToggle({Name="Health Bar",   CurrentValue=getgenv().HealthESP, Callback=function(v) getgenv().HealthESP = v end})
Visual:CreateSlider({Name="Text Size",    Range={10,30}, Increment=1, CurrentValue=getgenv().ESPSize, Callback=function(v) getgenv().ESPSize=v end})

Farm:CreateToggle({Name="Auto Farm (TP-Kill)", CurrentValue=getgenv().AutoFarm, Callback=function(v) getgenv().AutoFarm = v end})
Farm:CreateToggle({Name="God-Mode in Farm",    CurrentValue=getgenv().GodFarm,  Callback=function(v) getgenv().GodFarm  = v end})
Farm:CreateToggle({Name="Auto Collect Coins",  CurrentValue=getgenv().AutoCoin, Callback=function(v) getgenv().AutoCoin = v end})
Farm:CreateToggle({Name="Auto Collect Health", CurrentValue=getgenv().AutoHealth,Callback=function(v) getgenv().AutoHealth = v end})
Farm:CreateSlider({Name="Farm Range", Range={50,500}, Increment=10, CurrentValue=getgenv().FarmRange, Callback=function(v) getgenv().FarmRange=v end})

Misc:CreateToggle({Name="Bring Heads", CurrentValue=getgenv().BringHeads, Callback=function(v) getgenv().BringHeads = v end})


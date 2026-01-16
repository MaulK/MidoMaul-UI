# MidoMaul

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-cyan)
![Lua](https://img.shields.io/badge/language-Luau-blue)
![Platform](https://img.shields.io/badge/platform-Roblox-red)
![License](https://img.shields.io/badge/license-MIT-green)

**Futuristic. Fluid. Mobile-First.**
<br/>
A next-generation material control surface.

</div>

## 🌌 Philosophy
MidoMaul is built on the idea that power should feel effortless. It abandons rigid borders for "glass-morphic" surfaces, magnetic haptics, and intelligent scaling. It is designed to feel less like a GUI and more like a physical interface.

## ✨ Features
- **Mobile-First Architecture:** Auto-detects device type and scales UI (1.1x on mobile) for perfect touch targets.
- **Magnetic Haptics:** Buttons pulse and ripple; sliders glow with intensity.
- **Holo-Glow Depth:** Uses layered transparency and shadow sprites instead of borders.
- **TweenService Integration:** Deeply integrated smooth motion for every interaction.
- **Cloud Loading:** Always load the latest version directly from source.

## 🚀 Usage (Loadstring)

You can load MidoMaul directly into your script using `game:HttpGet`.

```lua
--[[
    MIDOMAUL v5.2 // ULTIMATE SHOWCASE
    ----------------------------------
    > Draggable "M" Toggle Button
    > Save/Load Config System
    > Multi-Select Dropdowns
    > Color Pickers & Progress Bars
]]

--// 1. LOAD THE LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaulK/MidoMaul-UI/refs/heads/main/src/MidoMaul.lua"))()

--// 2. CREATE WINDOW
local Window = Library:Window({
    Title = "MidoMaul v5.2 Hub",
    ToggleKey = Enum.KeyCode.RightControl
})

--// 3. CREATE TABS
local CombatTab = Window:Tab("Combat")
local VisualsTab = Window:Tab("Visuals")
local PlayerTab = Window:Tab("Player")
local SettingsTab = Window:Tab("Configs")

--// 4. LOGIC VARIABLES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local State = {
    Aimbot = false,
    AimPart = "Head",
    ESP = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50
}

--// ==============================
--// TAB: COMBAT
--// ==============================

CombatTab:Section("Aimbot Settings")

CombatTab:Toggle({
    Name = "Enable Aimbot",
    Flag = "Aim_Enabled",
    Default = false
}, function(val)
    State.Aimbot = val
    if val then Library:Notify("Combat", "Aimbot Active", 2) end
end)

CombatTab:Dropdown({
    Name = "Target Part",
    Flag = "Aim_Part",
    List = {"Head", "Torso", "HumanoidRootPart"},
    Multi = false, -- Single Select
    Default = "Head"
}, function(val)
    State.AimPart = val
end)

CombatTab:Keybind({
    Name = "Aim Lock Key",
    Flag = "Aim_Bind",
    Default = "Q"
}, function()
    if State.Aimbot then
        print("[Simulated] Locked on: " .. State.AimPart)
    end
end)

CombatTab:Section("Auto Farm")

CombatTab:ButtonGroup({
    Names = {"Start Farm", "Stop Farm", "Collect"},
    Callback = function(action)
        print("AutoFarm Action: " .. action)
    end
})

--// ==============================
--// TAB: VISUALS
--// ==============================

VisualsTab:Section("ESP Configuration")

VisualsTab:Toggle({
    Name = "Master Switch",
    Flag = "ESP_Master",
    Default = false
}, function(val)
    State.ESP = val
end)

VisualsTab:ColorPicker({
    Name = "ESP Color",
    Flag = "ESP_Col",
    Default = Color3.fromRGB(0, 255, 150)
}, function(col)
    State.ESPColor = col
end)

-- [MULTI-SELECT DROPDOWN]
VisualsTab:Dropdown({
    Name = "Show Elements",
    Flag = "ESP_Elements",
    List = {"Tracers", "Boxes", "Names", "Health", "Distance"},
    Multi = true, -- Select multiple options
    Default = {"Boxes", "Names"}
}, function(selected)
    -- 'selected' is a table: { ["Boxes"] = true, ["Tracers"] = false }
    for item, enabled in pairs(selected) do
        if enabled then print("ESP Showing: " .. item) end
    end
end)

VisualsTab:TextField({
    Name = "Custom Watermark",
    Flag = "ESP_Text",
    Placeholder = "maul.cc"
}, function(txt)
    print("Watermark set to: " .. txt)
end)

--// ==============================
--// TAB: PLAYER
--// ==============================

PlayerTab:Section("Character Mods")

PlayerTab:Slider({
    Name = "WalkSpeed",
    Flag = "Plr_Speed",
    Min = 16, Max = 500, Default = 16
}, function(val)
    State.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

PlayerTab:Slider({
    Name = "JumpPower",
    Flag = "Plr_Jump",
    Min = 50, Max = 500, Default = 50
}, function(val)
    State.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

PlayerTab:Section("Status")

local HP_Bar = PlayerTab:ProgressBar({
    Name = "Health",
    Min = 0, Max = 100, Default = 100
})

-- Update Health Bar Logic
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        HP_Bar:Set(LocalPlayer.Character.Humanoid.Health)
    end
end)

--// ==============================
--// TAB: SETTINGS (Config System)
--// ==============================

SettingsTab:Label("Save your settings to load them later.")

-- This ONE line adds the entire Save/Load/List UI
SettingsTab:ConfigSystem()

SettingsTab:Button("Unload Script", function()
    game.CoreGui:FindFirstChild("MidoMaul_Ultimate"):Destroy()
    game.CoreGui:FindFirstChild("MidoMaul_Ultimate"):Destroy() -- Cleanup Open Button
end)

Library:Notify("Success", "MidoMaul Loaded! Press RightCtrl to toggle.", 5)t(value)
end)

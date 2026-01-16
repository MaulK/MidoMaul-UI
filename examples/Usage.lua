--// Load Library via Web Import
local MidoMaul = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaulK/MidoMaul-UI/refs/heads/main/src/MidoMaul.lua"))()

local Window = MidoMaul:Window({
    Title = "MidoMaul v4"
})

local MainTab = Window:Tab("Combat")
local SettingTab = Window:Tab("Settings")

--// TOGGLES with FLAGS (Important for saving)
MainTab:Section("Aimbot")

MainTab:Toggle({
    Name = "Enabled",
    Flag = "AimEnabled", -- This ID is used for the config file
    Default = false
}, function(state)
    print("Aimbot:", state)
end)

--// MULTI-SELECT DROPDOWN
MainTab:Dropdown({
    Name = "Target Parts",
    Flag = "AimParts",
    List = {"Head", "Torso", "Left Arm", "Right Arm", "Legs"},
    Multi = true, -- <--- ENABLE MULTI SELECT
    Default = {"Head"}
}, function(selectedTable)
    -- Multi returns a table: { ["Head"] = true, ["Torso"] = false }
    for part, enabled in pairs(selectedTable) do
        if enabled then print("Targeting:", part) end
    end
end)

--// SINGLE-SELECT DROPDOWN
MainTab:Dropdown({
    Name = "Aim Mode",
    Flag = "AimMode",
    List = {"Mouse", "Camera", "Closest"},
    Multi = false,
    Default = "Mouse"
}, function(val)
    print("Mode:", val)
end)

--// CONFIG SYSTEM GENERATOR
-- This automatically creates the Save/Load/List UI for you
SettingTab:ConfigSystem()

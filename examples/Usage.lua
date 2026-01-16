local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MidoMaul = require(ReplicatedStorage:WaitForChild("MidoMaul"))

--// Window Creation
local Window = MidoMaul:Window({
    Title = "MidoMaul Demo"
})

--// Tabs
local CombatTab = Window:Tab("Combat")
local VisualsTab = Window:Tab("Visuals")
local SettingsTab = Window:Tab("Settings")

--// Combat Section
CombatTab:Section("Aimbot")

CombatTab:Toggle("Enabled", false, function(state)
    print("Aimbot is now:", state)
end)

CombatTab:Slider("FOV Radius", 0, 360, 90, function(value)
    -- Real-time update logic here
end)

CombatTab:Button("Silent Aim (Beta)", function()
    print("Silent Aim Triggered")
end)

--// Visuals Section
VisualsTab:Section("ESP")

VisualsTab:Toggle("Box ESP", true, function(s) end)
VisualsTab:Toggle("Tracers", false, function(s) end)
VisualsTab:Slider("Render Distance", 100, 5000, 1500, function(v) end)

print("MidoMaul Loaded Successfully")
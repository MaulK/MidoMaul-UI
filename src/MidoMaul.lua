--[[
    MIDOMAUL // v8.6 APEX EDITION
    - CRITICAL FIX: Resolved 'attempt to call missing method InitAntiAFK' crash.
    - VISUAL FIX: Keybinds now perfectly align with Toggles on the right edge.
    - LAYOUT FIX: Dual columns now render reliably without gaps.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// 🎨 THEME ENGINE
local Theme = {
    Main        = Color3.fromRGB(18, 18, 22),
    Sidebar     = Color3.fromRGB(23, 23, 28),
    Element     = Color3.fromRGB(30, 30, 36),
    Interact    = Color3.fromRGB(45, 45, 52),
    Accent      = Color3.fromRGB(0, 200, 255),
    Accent2     = Color3.fromRGB(0, 150, 255),
    Text        = Color3.fromRGB(240, 240, 240),
    SubText     = Color3.fromRGB(140, 140, 150),
    Stroke      = Color3.fromRGB(60, 60, 70),
    
    Font        = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    Corner      = UDim.new(0, 6)
}

--// 🛠️ UTILITY
local Library = { 
    Flags = {}, Items = {}, Accents = {}, Connections = {}, 
    ToggleKey = Enum.KeyCode.RightControl, ConfigFolder = "MidoMaulConfigs", 
    Keys = {}, IsOpen = true, Searchable = {}, AntiAFK = false 
}
local Utility = {}

local function SafeWrite(file, data) if writefile then writefile(file, data) end end
local function SafeRead(file) if readfile and isfile and isfile(file) then return readfile(file) end return nil end
local function SafeMakeFolder(folder) if makefolder and not isfolder(folder) then makefolder(folder) end end
local function SafeList(folder) if listfiles and isfolder and isfolder(folder) then return listfiles(folder) end return {} end

function Utility:Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

function Utility:Stroke(parent, color)
    local s = Instance.new("UIStroke")
    s.Parent = parent; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or Theme.Stroke; s.Transparency = 0
    return s
end

function Utility:Corner(parent, radius)
    local c = Instance.new("UICorner"); c.Parent = parent
    c.CornerRadius = radius or Theme.Corner
    return c
end

function Utility:Padding(parent, px, py)
    local p = Instance.new("UIPadding")
    p.Parent = parent
    p.PaddingLeft = UDim.new(0, px or 10); p.PaddingRight = UDim.new(0, px or 10)
    p.PaddingTop = UDim.new(0, py or 0); p.PaddingBottom = UDim.new(0, py or 0)
    return p
end

function Utility:Gradient(parent)
    local g = Instance.new("UIGradient")
    g.Parent = parent
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent2)
    }
    g.Rotation = 45
    table.insert(Library.Accents, {Object = g, Type = "Gradient"})
    return g
end

function Utility:Tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

function Utility:MakeDrag(frame)
    local Dragging, DragInput, DragStart, StartPos
    table.insert(Library.Connections, frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = frame.Position
        end
    end))
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            Utility:Tween(frame, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
        end
    end))
    table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end))
end

--// 🛡️ ANTI-AFK (Fixed Method Location)
function Library:InitAntiAFK()
    table.insert(Library.Connections, LocalPlayer.Idled:Connect(function()
        if Library.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end))
end

function Library:SetWatermark(text)
    local UI = CoreGui:FindFirstChild("MidoMaul_HUD")
    if not UI then
        UI = Utility:Create("ScreenGui", {Name = "MidoMaul_HUD", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
        local Frame = Utility:Create("Frame", {Parent=UI, BackgroundColor3=Theme.Main, Size=UDim2.new(0,0,0,26), Position=UDim2.new(0,20,0,20), AutomaticSize=Enum.AutomaticSize.X})
        Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke); Utility:Padding(Frame, 10)
        local Label = Utility:Create("TextLabel", {Name="Val", Parent=Frame, Text=text, TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X})
        local Line = Utility:Create("Frame", {Parent=Frame, BackgroundColor3=Theme.Accent, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,0), BorderSizePixel=0}); Utility:Gradient(Line)
        table.insert(Library.Connections, RunService.RenderStepped:Connect(function(dt)
            local fps = math.floor(1/dt)
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local time = os.date("%H:%M:%S")
            Label.Text = string.format("%s | FPS: %d | Ping: %dms | %s", text, fps, ping, time)
        end))
    end
end

function Utility:RegisterAccent(obj, prop)
    table.insert(Library.Accents, {Object = obj, Property = prop, Type = "Color"})
    obj[prop] = Theme.Accent
end

function Library:SetAccent(color)
    Theme.Accent = color
    Theme.Accent2 = Color3.fromHSV(Color3.toHSV(color), 0.8, 1)
    for _, item in pairs(Library.Accents) do
        if item.Object then
            if item.Type == "Gradient" then
                item.Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Accent2)}
            else
                Utility:Tween(item.Object, {[item.Property] = color}, 0.3)
            end
        end
    end
end

function Library:SaveConfig(name)
    local json = HttpService:JSONEncode(Library.Flags)
    SafeMakeFolder(Library.ConfigFolder)
    SafeWrite(Library.ConfigFolder .. "/" .. name .. ".json", json)
    Library:Notify("Config", "Saved: " .. name)
end

function Library:LoadConfig(name)
    local data = SafeRead(Library.ConfigFolder .. "/" .. name .. ".json")
    if data then
        local decoded = HttpService:JSONDecode(data)
        for flag, value in pairs(decoded) do
            if Library.Items[flag] then Library.Items[flag]:Set(value) end
        end
        Library:Notify("Config", "Loaded: " .. name)
    end
end

function Library:Notify(title, text, duration)
    local UI = CoreGui:FindFirstChild("MidoMaul_HUD")
    if not UI then return end
    local Holder = UI:FindFirstChild("Notifs") or Utility:Create("Frame", { Name = "Notifs", Parent = UI, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(1, 1) })
    if not Holder:FindFirstChild("Layout") then Utility:Create("UIListLayout", {Name="Layout", Parent=Holder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Right}) end
    local Toast = Utility:Create("Frame", {Parent=Holder, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}); Utility:Corner(Toast); Utility:Stroke(Toast, Theme.Stroke); Utility:Padding(Toast, 12, 10)
    local Bar = Utility:Create("Frame", {Parent=Toast, Size=UDim2.new(0,3,1,0), Position=UDim2.new(0,-12,0,0), BorderSizePixel=0}); Utility:Gradient(Bar)
    Utility:Create("TextLabel", {Parent=Toast, Text=title, TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=14, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    Utility:Create("TextLabel", {Parent=Toast, Text=text, TextColor3=Theme.SubText, Font=Theme.Font, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    local Scale = Utility:Create("UIScale", {Parent=Toast, Scale=0})
    Utility:Tween(Scale, {Scale=1}, 0.3, Enum.EasingStyle.Back)
    task.delay(duration or 3, function() Utility:Tween(Scale, {Scale=0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In); task.wait(0.3); Toast:Destroy() end)
end

function Library:Unload()
    for _, conn in pairs(Library.Connections) do conn:Disconnect() end
    if CoreGui:FindFirstChild("MidoMaul_HUD") then CoreGui.MidoMaul_HUD:Destroy() end
    Library.Flags = {}; Library.Items = {}; Library.Accents = {}
end

table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Library.ToggleKey then Library:Toggle() end
        for _, bind in pairs(Library.Keys) do if input.KeyCode.Name == bind.Key then bind.Callback() end end
    end
end))

--// 🖥️ MAIN WINDOW
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    Library.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    Library:InitAntiAFK() -- This call is now safe
    Library:SetWatermark(Title)
    
    local ScreenGui = CoreGui:FindFirstChild("MidoMaul_HUD")
    
    local OpenBtn = Utility:Create("TextButton", { Name = "OpenBtn", Parent = ScreenGui, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), Visible = false, Text = "M", TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 24, AutoButtonColor = false }); Utility:Corner(OpenBtn, UDim.new(1,0)); Utility:Stroke(OpenBtn, Theme.Stroke); Utility:MakeDrag(OpenBtn)
    Utility:RegisterAccent(OpenBtn, "TextColor3")

    local Main = Utility:Create("Frame", { Name = "Main", Parent = ScreenGui, BackgroundColor3 = Theme.Main, Position = UDim2.new(0.5, -350, 0.5, -225), Size = UDim2.new(0, 700, 0, 450) }); Utility:Corner(Main); Utility:Stroke(Main, Theme.Stroke); Utility:MakeDrag(Main)
    local MainScale = Utility:Create("UIScale", {Parent=Main, Scale=1})
    
    function Library:Toggle()
        Library.IsOpen = not Library.IsOpen
        if Library.IsOpen then Main.Visible = true; OpenBtn.Visible = false; Utility:Tween(MainScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else Utility:Tween(MainScale, {Scale = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In); task.wait(0.3); Main.Visible = false; OpenBtn.Visible = true end
    end
    OpenBtn.MouseButton1Click:Connect(Library.Toggle)
    local CloseBtn = Utility:Create("TextButton", { Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 10), Text = "×", TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 24 }); CloseBtn.MouseButton1Click:Connect(Library.Toggle)

    local Sidebar = Utility:Create("Frame", { Parent = Main, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 170, 1, 0) }); Utility:Corner(Sidebar)
    Utility:Create("Frame", {Parent=Sidebar, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(0,10,1,0), Position=UDim2.new(1,-10,0,0), BorderSizePixel=0})
    local TitleLabel = Utility:Create("TextLabel", { Parent = Sidebar, Text = Title, TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 18, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TitleLabel, 15); Utility:RegisterAccent(TitleLabel, "TextColor3")
    
    local SearchBox = Utility:Create("TextBox", { Parent = Sidebar, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 55), Text = "", PlaceholderText = "Search...", TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13 }); Utility:Corner(SearchBox); Utility:Stroke(SearchBox, Theme.Stroke)
    
    local TabHolder = Utility:Create("ScrollingFrame", { Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -95), Position = UDim2.new(0,0,0,95), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0 }); Utility:Create("UIListLayout", {Parent=TabHolder, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)})
    local PageHolder = Utility:Create("Frame", { Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), ClipsDescendants = true })

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, item in pairs(Library.Searchable) do
            if item.Text:lower():find(query) then item.Object.Visible = true else item.Object.Visible = false end
        end
    end)

    local WindowAPI = {}
    local FirstTab = true

    function WindowAPI:Tab(name)
        local TabBtn = Utility:Create("TextButton", { Parent = TabHolder, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false }); Utility:Corner(TabBtn)
        local TabTxt = Utility:Create("TextLabel", { Parent = TabBtn, Text = name, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TabTxt, 10)
        
        -- AutomaticCanvasSize Logic
        local Page = Utility:Create("Frame", { Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false })
        local Container = Utility:Create("ScrollingFrame", { Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Position=UDim2.new(0,0,0,0), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel=0 }); Utility:Create("UIPadding", {Parent=Container, PaddingRight=UDim.new(0,10), PaddingBottom=UDim.new(0,20)})
        
        -- Explicit Column Widths
        local LeftCol = Utility:Create("Frame", {Parent=Container, BackgroundTransparency=1, Size=UDim2.new(0.48,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}); Utility:Create("UIListLayout", {Parent=LeftCol, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)})
        local RightCol = Utility:Create("Frame", {Parent=Container, BackgroundTransparency=1, Size=UDim2.new(0.48,0,0,0), Position=UDim2.new(0.52,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}); Utility:Create("UIListLayout", {Parent=RightCol, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)})
        
        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then Utility:Tween(v, {BackgroundColor3 = Theme.Sidebar}); Utility:Tween(v.TextLabel, {TextColor3 = Theme.SubText}) end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            Utility:Tween(TabBtn, {BackgroundColor3 = Theme.Element}); Utility:Tween(TabTxt, {TextColor3 = Theme.Text}); Page.Visible = true
        end
        TabBtn.MouseButton1Click:Connect(Activate); if FirstTab then FirstTab = false; Activate() end

        local Elements = {}
        
        function Elements:Section(text, side) 
            local p = (side == "Right") and RightCol or LeftCol
            local Sec = Utility:Create("TextLabel", { Parent = p, Text = string.upper(text), TextColor3 = Theme.SubText, Font = Theme.FontBold, TextSize = 11, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Sec, 2) 
        end
        function Elements:Label(text, side) 
            local p = (side == "Right") and RightCol or LeftCol
            local Lab = Utility:Create("TextLabel", { Parent = p, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped=true }); Utility:Padding(Lab, 2) 
        end
        
        function Elements:Button(text, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Btn = Utility:Create("TextButton", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false }); Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke); Utility:AnimateHover(Btn)
            local BtnTxt = Utility:Create("TextLabel", { Parent = Btn, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(BtnTxt, 12)
            table.insert(Library.Searchable, {Object = Btn, Text = text})
            Btn.MouseButton1Click:Connect(function() Utility:Tween(Btn, {BackgroundColor3 = Theme.Interact}, 0.1); task.wait(0.1); Utility:Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.2); pcall(callback) end)
        end
        
        function Elements:Toggle(options, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or false; Library.Flags[Flag] = Default
            local Tgl = Utility:Create("TextButton", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false }); Utility:Corner(Tgl); Utility:Stroke(Tgl, Theme.Stroke); Utility:AnimateHover(Tgl)
            local TglTxt = Utility:Create("TextLabel", { Parent = Tgl, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TglTxt, 12)
            
            -- Box Aligned to Right (-12px padding)
            local Box = Utility:Create("Frame", { Parent = Tgl, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 36, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0) }); Utility:Corner(Box, UDim.new(1,0)); local Stroke = Utility:Stroke(Box, Theme.Stroke)
            local Knob = Utility:Create("Frame", { Parent = Box, BackgroundColor3 = Theme.SubText, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8) }); Utility:Corner(Knob, UDim.new(1,0))
            
            table.insert(Library.Searchable, {Object = Tgl, Text = Text})
            local function Update(val) Library.Flags[Flag] = val; Utility:Tween(Box, {BackgroundColor3 = val and Theme.Accent or Theme.Main}); Utility:Tween(Knob, {Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = val and Theme.Text or Theme.SubText}, 0.2, Enum.EasingStyle.Back); pcall(callback, val) end
            Tgl.MouseButton1Click:Connect(function() Update(not Library.Flags[Flag]) end); Library.Items[Flag] = { Set = function(self, v) Update(v) end }; if Default then Update(true) end
        end
        
        function Elements:Slider(options, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Text, Flag, Min, Max, Default = options.Name, options.Flag or options.Name, options.Min or 0, options.Max or 100, options.Default or 0; Library.Flags[Flag] = Default
            local Sld = Utility:Create("Frame", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 55) }); Utility:Corner(Sld); Utility:Stroke(Sld, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = Sld, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local ValTxt = Utility:Create("TextLabel", { Parent = Sld, Text = tostring(Default), TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 13, Size = UDim2.new(0, 40, 0, 30), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right }); Utility:RegisterAccent(ValTxt, "TextColor3")
            local Bar = Utility:Create("TextButton", { Parent = Sld, BackgroundColor3 = Theme.Main, Text = "", AutoButtonColor = false, Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 36) }); Utility:Corner(Bar, UDim.new(1, 0))
            local Fill = Utility:Create("Frame", { Parent = Bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0) }); Utility:Corner(Fill, UDim.new(1, 0)); Utility:Gradient(Fill)
            table.insert(Library.Searchable, {Object = Sld, Text = Text})
            local function Update(val) val = math.clamp(val, Min, Max); Library.Flags[Flag] = val; ValTxt.Text = tostring(val); Utility:Tween(Fill, {Size = UDim2.new((val - Min) / (Max - Min), 0, 1, 0)}, 0.1); pcall(callback, val) end
            local Dragging = false
            local function Move(input) local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); Update(math.floor(Min + (Max - Min) * p)) end
            table.insert(Library.Connections, Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Move(i) end end))
            table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Move(i) end end))
            table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end))
            Library.Items[Flag] = { Set = function(self, v) Update(v) end }; Update(Default)
        end

        function Elements:TextField(options, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Text, Flag, Placeholder = options.Name, options.Flag or options.Name, options.Placeholder or "..."
            local Frame = Utility:Create("Frame", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 50) }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12)
            local BoxHolder = Utility:Create("Frame", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 24) }); Utility:Corner(BoxHolder, UDim.new(0, 4)); local Stroke = Utility:Stroke(BoxHolder, Theme.Stroke)
            local Box = Utility:Create("TextBox", { Parent = BoxHolder, BackgroundTransparency = 1, Text = "", PlaceholderText = Placeholder, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false }); Utility:Padding(Box, 6)
            table.insert(Library.Searchable, {Object = Frame, Text = Text})
            table.insert(Library.Connections, Box.FocusLost:Connect(function() Library.Flags[Flag] = Box.Text; Utility:Tween(Stroke, {Color = Theme.Stroke}); pcall(callback, Box.Text) end))
            table.insert(Library.Connections, Box.Focused:Connect(function() Utility:Tween(Stroke, {Color = Theme.Accent}) end))
            Library.Items[Flag] = { Set = function(self, v) Box.Text = v; Library.Flags[Flag] = v; pcall(callback, v) end }
        end
        
        function Elements:Keybind(options, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or "None"; Library.Keys[Flag] = { Key = Default, Callback = function() pcall(callback) end }
            local Frame = Utility:Create("Frame", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40) }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12)
            
            -- FIX: Button uses same right-alignment margin as Toggles (12px)
            local Btn = Utility:Create("TextButton", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 80, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Text = Default, TextColor3 = Theme.SubText, Font = Theme.FontBold, TextSize = 12 }); Utility:Corner(Btn, UDim.new(0,4)); local Stroke = Utility:Stroke(Btn, Theme.Stroke)
            
            local Binding = false
            Btn.MouseButton1Click:Connect(function() Binding = true; Btn.Text = "..."; Utility:Tween(Stroke, {Color = Theme.Accent}) end)
            table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(i) if Binding and i.UserInputType == Enum.UserInputType.Keyboard then Binding = false; if options.IsToggleKey then Library.ToggleKey = i.KeyCode end; Library.Keys[Flag].Key = i.KeyCode.Name; Btn.Text = i.KeyCode.Name; Utility:Tween(Stroke, {Color = Theme.Stroke}) end end))
        end

        function Elements:ColorPicker(options, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or Color3.new(1,1,1); Library.Flags[Flag] = Default
            local Frame = Utility:Create("Frame", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants=true, ZIndex=5 }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12)
            
            -- FIX: Preview box alignment matching Toggles (12px margin)
            local Preview = Utility:Create("TextButton", { Parent = Frame, BackgroundColor3 = Default, Size = UDim2.new(0, 36, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Text = "" }); Utility:Corner(Preview, UDim.new(0,4)); Utility:Stroke(Preview, Theme.Stroke)
            
            table.insert(Library.Searchable, {Object = Frame, Text = Text})
            local Picker = Utility:Create("Frame", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 110), Position = UDim2.new(0, 12, 0, 40), Visible = false }); Utility:Corner(Picker, UDim.new(0,4))
            local function CreateBox(pos, col, t) local b = Utility:Create("TextBox", { Parent = Picker, BackgroundColor3 = Theme.Element, Size = UDim2.new(0.3, 0, 0, 25), Position = pos, Text = t, TextColor3 = col, Font = Theme.FontBold, TextSize = 12 }); Utility:Corner(b, UDim.new(0,4)); return b end
            local R = CreateBox(UDim2.new(0,0,0.25,0), Color3.fromRGB(255,100,100), "255"); local G = CreateBox(UDim2.new(0.35,0,0.25,0), Color3.fromRGB(100,255,100), "255"); local B = CreateBox(UDim2.new(0.7,0,0.25,0), Color3.fromRGB(100,100,255), "255")
            local Apply = Utility:Create("TextButton", {Parent = Picker, BackgroundColor3 = Theme.Interact, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0,0,0.65,0), Text = "Apply Color", TextColor3 = Theme.Text, Font = Theme.FontBold}); Utility:Corner(Apply, UDim.new(0,4))
            local Open = false
            Apply.MouseButton1Click:Connect(function() local c = Color3.fromRGB(tonumber(R.Text) or 0, tonumber(G.Text) or 0, tonumber(B.Text) or 0); Preview.BackgroundColor3 = c; Library.Flags[Flag] = c; pcall(callback, c); Library:Notify("Color", "Updated", 1); Open=false; Picker.Visible=false; Frame:TweenSize(UDim2.new(1,0,0,40),"Out","Quart",0.3,true) end)
            Preview.MouseButton1Click:Connect(function() Open = not Open; Picker.Visible = Open; Frame:TweenSize(Open and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 40), "Out", "Quart", 0.3, true) end)
        end
        function Elements:ProgressBar(options, side)
             local p = (side == "Right") and RightCol or LeftCol
             local Text, Min, Max, Current = options.Name, options.Min or 0, options.Max or 100, options.Default or 0
             local PFrame = Utility:Create("Frame", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40) }); Utility:Corner(PFrame); Utility:Stroke(PFrame, Theme.Stroke)
             local PLabel = Utility:Create("TextLabel", { Parent = PFrame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(PLabel, 12)
             local PBarBack = Utility:Create("Frame", { Parent = PFrame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 10), Position = UDim2.new(0, 12, 0, 22) }); Utility:Corner(PBarBack, UDim.new(1,0))
             local PFill = Utility:Create("Frame", { Parent = PBarBack, BackgroundColor3 = Theme.Success, Size = UDim2.new(0,0,1,0) }); Utility:Corner(PFill, UDim.new(1,0))
             local Obj = {}; function Obj:Set(val) val = math.clamp(val, Min, Max); local percent = (val - Min) / (Max - Min); Utility:Tween(PFill, {Size = UDim2.new(percent, 0, 1, 0)}); PLabel.Text = Text .. " [" .. math.floor(val) .. "/" .. Max .. "]" end
             Obj:Set(Current); return Obj
        end
        function Elements:Dropdown(options, callback, side)
            local p = (side == "Right") and RightCol or LeftCol
            local Text, Flag, List, Default, Multi = options.Name, options.Flag or options.Name, options.List or {}, options.Default, options.Multi; local State = Multi and {} or Default or List[1]
            if Multi then for _, v in pairs(List) do State[v] = false end if type(Default)=="table" then for _,v in pairs(Default) do State[v]=true end end end; Library.Flags[Flag] = State
            local DropFrame = Utility:Create("Frame", { Parent = p, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true, ZIndex = 3 }); Utility:Corner(DropFrame); Utility:Stroke(DropFrame, Theme.Stroke)
            local Button = Utility:Create("TextButton", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false, ZIndex = 3 })
            local Label = Utility:Create("TextLabel", { Parent = Button, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -40, 0, 40), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3 }); Utility:Padding(Label, 12)
            local Arrow = Utility:Create("ImageLabel", { Parent = Button, BackgroundTransparency = 1, Image = "rbxassetid://6031090990", Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9), ZIndex = 3 })
            table.insert(Library.Searchable, {Object = DropFrame, Text = Text})
            local Container = Utility:Create("Frame", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0,0,0,40), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 3 }); Utility:Create("UIListLayout", {Parent=Container, SortOrder=Enum.SortOrder.LayoutOrder})
            local function Refresh() Label.Text = Text .. (Multi and " [...]" or ": "..tostring(State)) end; Refresh()
            local IsOpen = false; Button.MouseButton1Click:Connect(function() IsOpen = not IsOpen; Container.Visible = IsOpen; Utility:Tween(Arrow, {Rotation = IsOpen and 180 or 0})
                if IsOpen then for _, child in pairs(Container:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    for _, item in pairs(List) do local ItemBtn = Utility:Create("TextButton", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false, ZIndex = 4 })
                        local ItemTxt = Utility:Create("TextLabel", { Parent = ItemBtn, Text = item, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }); Utility:Padding(ItemTxt, 30)
                        local Sel = Multi and State[item] or (State == item); if Sel then ItemTxt.TextColor3 = Theme.Accent end
                        ItemBtn.MouseButton1Click:Connect(function() if Multi then State[item] = not State[item]; Sel = State[item]; ItemTxt.TextColor3 = Sel and Theme.Accent or Theme.SubText else State = item; IsOpen = false; Container.Visible = false; DropFrame:TweenSize(UDim2.new(1, 0, 0, 40), "Out", "Quart", 0.3, true) end; Library.Flags[Flag] = State; Refresh(); pcall(callback, State) end)
                    end; DropFrame:TweenSize(UDim2.new(1, 0, 0, 40 + (#List * 30)), "Out", "Quart", 0.3, true)
                else DropFrame:TweenSize(UDim2.new(1, 0, 0, 40), "Out", "Quart", 0.3, true) end
            end)
            Library.Items[Flag] = { Set = function(self, val) State = val; Library.Flags[Flag] = State; Refresh(); pcall(callback, State) end }
        end
        function Elements:ConfigSystem()
            Elements:Section("Configuration", "Left")
            local Name = ""
            Elements:TextField({Name="Config Name", Flag="ConfigName", Placeholder="Config Name..."}, function(v) Name = v end, "Left")
            local Grp = Utility:Create("Frame", {Parent=LeftCol, BackgroundTransparency=1, Size=UDim2.new(1,0,0,36)}); local Layout = Utility:Create("UIListLayout", {Parent=Grp, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)})
            local function Btn(t, f) local b = Utility:Create("TextButton", {Parent=Grp, BackgroundColor3=Theme.Element, Size=UDim2.new(0.32,0,1,0), Text=t, TextColor3=Theme.Text, Font=Theme.Font}); Utility:Corner(b); Utility:Stroke(b, Theme.Stroke); b.MouseButton1Click:Connect(f) end
            Btn("Save", function() Library:SaveConfig(Name) end); Btn("Load", function() Library:LoadConfig(Name) end); Btn("List", function() Library:Notify("Configs", table.concat(Library:GetConfigs(), ", ")) end)
        end
        function Elements:ButtonGroup(options, side)
             local List, Call = options.Names or {}, options.Callback or function() end
             local p = (side == "Right") and RightCol or LeftCol
             local Grp = Utility:Create("Frame", {Parent=p, BackgroundTransparency=1, Size=UDim2.new(1,0,0,36)}); local Layout = Utility:Create("UIListLayout", {Parent=Grp, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)})
             local SizePercent = 1 / #List
             for _, name in pairs(List) do
                 local Btn = Utility:Create("TextButton", { Parent = Grp, BackgroundColor3 = Theme.Element, Size = UDim2.new(SizePercent, -5, 1, 0), Text = name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, AutoButtonColor = false }); Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke); Btn.MouseButton1Click:Connect(function() pcall(Call, name) end)
             end
        end
        
        return Elements
    end
    
    local SetTab = WindowAPI:Tab("Settings")
    SetTab:Section("Theme", "Left")
    SetTab:ColorPicker({Name = "UI Accent Color", Flag = "UI_Color", Default = Theme.Accent}, function(c) Library:SetAccent(c) end, "Left")
    SetTab:Section("Security", "Right")
    SetTab:Toggle({Name = "Anti-AFK", Flag = "AntiAFK", Default = false}, function(v) Library.AntiAFK = v end, "Right")
    SetTab:Section("Keybinds", "Right")
    SetTab:Keybind({Name = "Menu Toggle", Flag = "MenuBind", Default = "RightControl", IsToggleKey = true}, function() end, "Right")
    SetTab:ConfigSystem()
    SetTab:Section("Exit", "Right")
    SetTab:Button("Unload UI", function() Library:Unload() end, "Right")
    
    return WindowAPI
end
return Library

--[[
    MIDOMAUL // v9.0 INNOVATION UPDATE
    - Added: Spotlight Command Palette (Ctrl+P)
    - Added: Pin-to-HUD (Right-Click Toggles/Sliders)
    - Added: Smart Harmonizer (Auto-Theme Engine)
    - Architecture: Stable Single-Column
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

--// 🎨 SMART THEME ENGINE
local Theme = {
    Main        = Color3.fromRGB(18, 18, 22),
    Sidebar     = Color3.fromRGB(23, 23, 28),
    Element     = Color3.fromRGB(30, 30, 36),
    Interact    = Color3.fromRGB(45, 45, 52),
    Accent      = Color3.fromRGB(0, 200, 255),
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
    Keys = {}, IsOpen = true, Searchable = {}, AntiAFK = false,
    SpotlightOpen = false, PinnedElements = {}
}
local Utility = {}

-- Safe Functions
local function SafeWrite(file, data) if writefile then writefile(file, data) end end
local function SafeRead(file) if readfile and isfile and isfile(file) then return readfile(file) end return nil end
local function SafeMakeFolder(folder) if makefolder and not isfolder(folder) then makefolder(folder) end end

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
    p.PaddingLeft = UDim.new(0, px or 12); p.PaddingRight = UDim.new(0, px or 12)
    p.PaddingTop = UDim.new(0, py or 0); p.PaddingBottom = UDim.new(0, py or 0)
    return p
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

--// 🎨 HARMONIZER (SMART THEME)
function Library:Harmonize(accent)
    local h, s, v = Color3.toHSV(accent)
    
    -- Smart Colors
    Theme.Accent = accent
    Theme.Main = Color3.fromHSV(h, s * 0.15, 0.1) -- Very dark tint of accent
    Theme.Sidebar = Color3.fromHSV(h, s * 0.1, 0.15) -- Slightly lighter
    Theme.Element = Color3.fromHSV(h, s * 0.05, 0.2) -- Interactive background
    Theme.Interact = Color3.fromHSV(h, s * 0.3, 0.3) -- Hover state
    Theme.Stroke = Color3.fromHSV(h, s * 0.2, 0.3)
    
    -- Apply to all registered objects
    for _, item in pairs(Library.Accents) do
        if item.Object then
            if item.Prop == "BackgroundColor3" then
                if item.Type == "Main" then Utility:Tween(item.Object, {BackgroundColor3 = Theme.Main}, 0.5)
                elseif item.Type == "Sidebar" then Utility:Tween(item.Object, {BackgroundColor3 = Theme.Sidebar}, 0.5)
                elseif item.Type == "Element" then Utility:Tween(item.Object, {BackgroundColor3 = Theme.Element}, 0.5)
                else Utility:Tween(item.Object, {BackgroundColor3 = Theme.Accent}, 0.5) end
            elseif item.Prop == "TextColor3" then
                Utility:Tween(item.Object, {TextColor3 = Theme.Accent}, 0.5)
            elseif item.Prop == "Color" then -- UIStroke
                Utility:Tween(item.Object, {Color = Theme.Stroke}, 0.5)
            end
        end
    end
end

--// 📌 PIN TO HUD LOGIC
function Library:PinElement(type, options, callback)
    local HUD = CoreGui:FindFirstChild("MidoMaul_HUD")
    if not HUD then return end
    
    local PinFrame = Utility:Create("Frame", {
        Parent = HUD, 
        BackgroundColor3 = Theme.Main, 
        Size = UDim2.new(0, 200, 0, 40), 
        Position = UDim2.new(0.8, 0, 0.8, #Library.PinnedElements * 45) -- Stack logic
    })
    Utility:Corner(PinFrame); Utility:Stroke(PinFrame, Theme.Stroke)
    Utility:MakeDrag(PinFrame)
    table.insert(Library.PinnedElements, PinFrame)
    
    local Label = Utility:Create("TextLabel", {Parent=PinFrame, Text=options.Name, TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=12, Size=UDim2.new(1,-40,1,0), BackgroundTransparency=1})
    Utility:Padding(Label, 10, 0)
    
    if type == "Toggle" then
        local Indicator = Utility:Create("Frame", {Parent=PinFrame, Size=UDim2.new(0,10,0,10), Position=UDim2.new(1,-20,0.5,-5), BackgroundColor3=options.State and Theme.Accent or Theme.SubText}); Utility:Corner(Indicator, UDim.new(1,0))
        local Btn = Utility:Create("TextButton", {Parent=PinFrame, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""})
        Btn.MouseButton1Click:Connect(function()
            local newState = not Library.Flags[options.Flag]
            Library.Items[options.Flag]:Set(newState) -- Sync with main UI
            Indicator.BackgroundColor3 = newState and Theme.Accent or Theme.SubText
        end)
    elseif type == "Slider" then
        -- Simplified slider for HUD
        local Val = Utility:Create("TextLabel", {Parent=PinFrame, Text=tostring(options.Default), TextColor3=Theme.Accent, Position=UDim2.new(1,-40,0,0), Size=UDim2.new(0,30,1,0), BackgroundTransparency=1})
    end
    
    -- Right click to unpin
    local UnpinBtn = Utility:Create("TextButton", {Parent=PinFrame, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10})
    UnpinBtn.MouseButton2Click:Connect(function() PinFrame:Destroy() end)
end

--// REGISTRATION HELPER
function Utility:RegisterTheme(obj, prop, type)
    table.insert(Library.Accents, {Object = obj, Prop = prop, Type = type})
end

--// INTERNAL SYSTEMS
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
        Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke); Utility:Padding(Frame, 10, 6)
        local Label = Utility:Create("TextLabel", {Name="Val", Parent=Frame, Text=text, TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X})
        
        table.insert(Library.Connections, RunService.RenderStepped:Connect(function(dt)
            local fps = math.floor(1/dt)
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local time = os.date("%H:%M:%S")
            Label.Text = string.format("%s | FPS: %d | Ping: %dms | %s", text, fps, ping, time)
        end))
    end
end

--// 🔔 NOTIFICATION
function Library:Notify(title, text, duration)
    local UI = CoreGui:FindFirstChild("MidoMaul_HUD")
    if not UI then return end
    local Holder = UI:FindFirstChild("Notifs") or Utility:Create("Frame", { Name = "Notifs", Parent = UI, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(1, 1) })
    if not Holder:FindFirstChild("Layout") then Utility:Create("UIListLayout", {Name="Layout", Parent=Holder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Right}) end
    local Toast = Utility:Create("Frame", {Parent=Holder, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}); Utility:Corner(Toast); Utility:Stroke(Toast, Theme.Stroke); Utility:Padding(Toast, 12, 10)
    local Bar = Utility:Create("Frame", {Parent=Toast, Size=UDim2.new(0,3,1,0), Position=UDim2.new(0,-12,0,0), BorderSizePixel=0, BackgroundColor3=Theme.Accent}); 
    Utility:Create("TextLabel", {Parent=Toast, Text=title, TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=14, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    Utility:Create("TextLabel", {Parent=Toast, Text=text, TextColor3=Theme.SubText, Font=Theme.Font, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    local Scale = Utility:Create("UIScale", {Parent=Toast, Scale=0}); Utility:Tween(Scale, {Scale=1}, 0.3, Enum.EasingStyle.Back)
    task.delay(duration or 3, function() Utility:Tween(Scale, {Scale=0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In); task.wait(0.3); Toast:Destroy() end)
end

function Library:Unload()
    for _, conn in pairs(Library.Connections) do conn:Disconnect() end
    if CoreGui:FindFirstChild("MidoMaul_HUD") then CoreGui.MidoMaul_HUD:Destroy() end
end

--// ⌨️ GLOBAL INPUTS (SPOTLIGHT)
table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Library.ToggleKey then Library:Toggle() end
    
    -- SPOTLIGHT TOGGLE
    if input.KeyCode == Enum.KeyCode.P and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        local HUD = CoreGui:FindFirstChild("MidoMaul_HUD")
        local Spot = HUD:FindFirstChild("Spotlight")
        if Spot then 
            Spot.Visible = not Spot.Visible 
            if Spot.Visible then Spot.Container.SearchBox:CaptureFocus() end
        end
    end
end))

--// 🖥️ MAIN WINDOW
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    Library.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    Library:InitAntiAFK()
    Library:SetWatermark(Title)
    
    local ScreenGui = CoreGui:FindFirstChild("MidoMaul_HUD")
    
    -- 🔦 SPOTLIGHT UI CREATION
    local Spotlight = Utility:Create("Frame", {Name="Spotlight", Parent=ScreenGui, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Visible=false, ZIndex=100})
    local SpotBlur = Utility:Create("Frame", {Parent=Spotlight, BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.6, Size=UDim2.new(1,0,1,0)}); 
    local SpotMain = Utility:Create("Frame", {Name="Container", Parent=Spotlight, BackgroundColor3=Theme.Main, Size=UDim2.new(0, 500, 0, 300), Position=UDim2.new(0.5,-250,0.2,0)}); Utility:Corner(SpotMain); Utility:Stroke(SpotMain, Theme.Accent)
    local SpotBox = Utility:Create("TextBox", {Name="SearchBox", Parent=SpotMain, BackgroundTransparency=1, Size=UDim2.new(1,-30,0,40), Position=UDim2.new(0,15,0,0), Text="", PlaceholderText="Type to search command...", TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left})
    local SpotScroll = Utility:Create("ScrollingFrame", {Parent=SpotMain, BackgroundTransparency=1, Size=UDim2.new(1,0,1,-50), Position=UDim2.new(0,0,0,50), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2}); Utility:Create("UIListLayout", {Parent=SpotScroll, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)}); Utility:Padding(SpotScroll, 10, 0)
    Utility:Create("Frame", {Parent=SpotMain, BackgroundColor3=Theme.Stroke, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,45), BorderSizePixel=0})

    SpotBox:GetPropertyChangedSignal("Text"):Connect(function()
        for _, c in pairs(SpotScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local query = SpotBox.Text:lower()
        if query == "" then return end
        for _, item in pairs(Library.Searchable) do
            if item.Text:lower():find(query) then
                local Res = Utility:Create("TextButton", {Parent=SpotScroll, BackgroundColor3=Theme.Element, Size=UDim2.new(1,0,0,30), Text=item.Text, TextColor3=Theme.SubText, Font=Theme.Font, AutoButtonColor=false}); Utility:Corner(Res)
                Res.MouseButton1Click:Connect(function()
                    if item.Type == "Button" then item.Callback() end
                    if item.Type == "Toggle" then local new = not Library.Flags[item.Flag]; Library.Items[item.Flag]:Set(new) end
                    Library:Notify("Spotlight", "Executed: " .. item.Text, 2)
                    Spotlight.Visible = false
                end)
            end
        end
    end)

    -- STANDARD UI
    local OpenBtn = Utility:Create("TextButton", { Name = "OpenBtn", Parent = ScreenGui, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), Visible = false, Text = "M", TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 24, AutoButtonColor = false }); Utility:Corner(OpenBtn, UDim.new(1,0)); Utility:Stroke(OpenBtn, Theme.Stroke); Utility:MakeDrag(OpenBtn); Utility:RegisterTheme(OpenBtn, "TextColor3", "Accent")
    
    local Main = Utility:Create("Frame", { Name = "Main", Parent = ScreenGui, BackgroundColor3 = Theme.Main, Position = UDim2.new(0.5, -350, 0.5, -225), Size = UDim2.new(0, 700, 0, 450) }); Utility:Corner(Main); Utility:Stroke(Main, Theme.Stroke); Utility:MakeDrag(Main); Utility:RegisterTheme(Main, "BackgroundColor3", "Main")
    local MainScale = Utility:Create("UIScale", {Parent=Main, Scale=1})
    
    function Library:Toggle()
        Library.IsOpen = not Library.IsOpen
        if Library.IsOpen then Main.Visible = true; OpenBtn.Visible = false; Utility:Tween(MainScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else Utility:Tween(MainScale, {Scale = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In); task.wait(0.3); Main.Visible = false; OpenBtn.Visible = true end
    end
    OpenBtn.MouseButton1Click:Connect(Library.Toggle)
    local CloseBtn = Utility:Create("TextButton", { Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 10), Text = "×", TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 24 }); CloseBtn.MouseButton1Click:Connect(Library.Toggle)

    local Sidebar = Utility:Create("Frame", { Parent = Main, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 170, 1, 0) }); Utility:Corner(Sidebar); Utility:RegisterTheme(Sidebar, "BackgroundColor3", "Sidebar")
    Utility:Create("Frame", {Parent=Sidebar, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(0,10,1,0), Position=UDim2.new(1,-10,0,0), BorderSizePixel=0})
    local TitleLabel = Utility:Create("TextLabel", { Parent = Sidebar, Text = Title, TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 18, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TitleLabel, 15, 0); Utility:RegisterTheme(TitleLabel, "TextColor3", "Accent")
    
    local TabHolder = Utility:Create("ScrollingFrame", { Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0,0,0,60), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0 }); Utility:Create("UIListLayout", {Parent=TabHolder, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)})
    local PageHolder = Utility:Create("Frame", { Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), ClipsDescendants = true })

    local WindowAPI = {}
    local FirstTab = true

    function WindowAPI:Tab(name)
        local TabBtn = Utility:Create("TextButton", { Parent = TabHolder, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false }); Utility:Corner(TabBtn)
        local TabTxt = Utility:Create("TextLabel", { Parent = TabBtn, Text = name, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TabTxt, 10, 0)
        
        local Page = Utility:Create("Frame", { Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false })
        local Container = Utility:Create("ScrollingFrame", { Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Position=UDim2.new(0,0,0,0), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel=0 }); 
        Utility:Create("UIPadding", {Parent=Container, PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,10), PaddingBottom=UDim.new(0,20)})
        local MainLayout = Utility:Create("UIListLayout", {Parent=Container, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)})
        
        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then Utility:Tween(v, {BackgroundColor3 = Theme.Sidebar}); Utility:Tween(v.TextLabel, {TextColor3 = Theme.SubText}) end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            Utility:Tween(TabBtn, {BackgroundColor3 = Theme.Element}); Utility:Tween(TabTxt, {TextColor3 = Theme.Text}); Page.Visible = true
        end
        TabBtn.MouseButton1Click:Connect(Activate); if FirstTab then FirstTab = false; Activate() end

        local Elements = {}
        
        function Elements:Section(text) 
            local Sec = Utility:Create("TextLabel", { Parent = Container, Text = string.upper(text), TextColor3 = Theme.SubText, Font = Theme.FontBold, TextSize = 11, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Sec, 2, 0) 
        end
        
        function Elements:Button(text, callback)
            local Btn = Utility:Create("TextButton", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false }); Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke); Utility:AnimateHover(Btn)
            local BtnTxt = Utility:Create("TextLabel", { Parent = Btn, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(BtnTxt, 12, 0)
            table.insert(Library.Searchable, {Text = text, Type = "Button", Callback = callback})
            Utility:RegisterTheme(Btn, "BackgroundColor3", "Element")
            Btn.MouseButton1Click:Connect(function() Utility:Tween(Btn, {BackgroundColor3 = Theme.Interact}, 0.1); task.wait(0.1); Utility:Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.2); pcall(callback) end)
        end
        
        function Elements:Toggle(options, callback)
            local Text, Flag = options.Name, options.Flag or options.Name
            local Tgl = Utility:Create("TextButton", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false }); Utility:Corner(Tgl); Utility:Stroke(Tgl, Theme.Stroke); Utility:AnimateHover(Tgl)
            local TglTxt = Utility:Create("TextLabel", { Parent = Tgl, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TglTxt, 12, 0)
            local Box = Utility:Create("Frame", { Parent = Tgl, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 36, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0) }); Utility:Corner(Box, UDim.new(1,0)); local Stroke = Utility:Stroke(Box, Theme.Stroke)
            local Knob = Utility:Create("Frame", { Parent = Box, BackgroundColor3 = Theme.SubText, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8) }); Utility:Corner(Knob, UDim.new(1,0))
            Utility:RegisterTheme(Tgl, "BackgroundColor3", "Element")
            table.insert(Library.Searchable, {Text = Text, Type = "Toggle", Flag = Flag})
            
            -- PIN LOGIC
            Tgl.MouseButton2Click:Connect(function() Library:PinElement("Toggle", {Name=Text, Flag=Flag, State=Library.Flags[Flag]}, callback) end)

            local function Update(val) Library.Flags[Flag] = val; Utility:Tween(Box, {BackgroundColor3 = val and Theme.Accent or Theme.Main}); Utility:Tween(Knob, {Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = val and Theme.Text or Theme.SubText}, 0.2, Enum.EasingStyle.Back); pcall(callback, val) end
            Tgl.MouseButton1Click:Connect(function() Update(not Library.Flags[Flag]) end); Library.Items[Flag] = { Set = function(self, v) Update(v) end }; if options.Default then Update(true) end
        end
        
        function Elements:Slider(options, callback)
            local Text, Flag, Min, Max, Default = options.Name, options.Flag or options.Name, options.Min or 0, options.Max or 100, options.Default or 0; Library.Flags[Flag] = Default
            local Sld = Utility:Create("Frame", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 55) }); Utility:Corner(Sld); Utility:Stroke(Sld, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = Sld, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local ValTxt = Utility:Create("TextLabel", { Parent = Sld, Text = tostring(Default), TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 13, Size = UDim2.new(0, 40, 0, 30), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right }); Utility:RegisterTheme(ValTxt, "TextColor3", "Accent")
            local Bar = Utility:Create("TextButton", { Parent = Sld, BackgroundColor3 = Theme.Main, Text = "", AutoButtonColor = false, Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 36) }); Utility:Corner(Bar, UDim.new(1, 0))
            local Fill = Utility:Create("Frame", { Parent = Bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0) }); Utility:Corner(Fill, UDim.new(1, 0)); Utility:RegisterTheme(Fill, "BackgroundColor3", "Accent")
            Utility:RegisterTheme(Sld, "BackgroundColor3", "Element")
            
            Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then Library:PinElement("Slider", {Name=Text, Flag=Flag, Default=Default}, callback) end end)

            local function Update(val) val = math.clamp(val, Min, Max); Library.Flags[Flag] = val; ValTxt.Text = tostring(val); Utility:Tween(Fill, {Size = UDim2.new((val - Min) / (Max - Min), 0, 1, 0)}, 0.1); pcall(callback, val) end
            local Dragging = false
            local function Move(input) local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); Update(math.floor(Min + (Max - Min) * p)) end
            table.insert(Library.Connections, Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Move(i) end end))
            table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Move(i) end end))
            table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end))
            Library.Items[Flag] = { Set = function(self, v) Update(v) end }; Update(Default)
        end

        function Elements:ColorPicker(options, callback)
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or Color3.new(1,1,1); Library.Flags[Flag] = Default
            local Frame = Utility:Create("Frame", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants=true, ZIndex=5 }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12, 0)
            local Preview = Utility:Create("TextButton", { Parent = Frame, BackgroundColor3 = Default, Size = UDim2.new(0, 36, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Text = "" }); Utility:Corner(Preview, UDim.new(0,4)); Utility:Stroke(Preview, Theme.Stroke)
            
            local Picker = Utility:Create("Frame", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 110), Position = UDim2.new(0, 12, 0, 40), Visible = false }); Utility:Corner(Picker, UDim.new(0,4))
            local function CreateBox(pos, col, t) local b = Utility:Create("TextBox", { Parent = Picker, BackgroundColor3 = Theme.Element, Size = UDim2.new(0.3, 0, 0, 25), Position = pos, Text = t, TextColor3 = col, Font = Theme.FontBold, TextSize = 12 }); Utility:Corner(b, UDim.new(0,4)); return b end
            local R = CreateBox(UDim2.new(0,0,0.25,0), Color3.fromRGB(255,100,100), "255"); local G = CreateBox(UDim2.new(0.35,0,0.25,0), Color3.fromRGB(100,255,100), "255"); local B = CreateBox(UDim2.new(0.7,0,0.25,0), Color3.fromRGB(100,100,255), "255")
            local Apply = Utility:Create("TextButton", {Parent = Picker, BackgroundColor3 = Theme.Interact, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0,0,0.65,0), Text = "Apply Color", TextColor3 = Theme.Text, Font = Theme.FontBold}); Utility:Corner(Apply, UDim.new(0,4))
            
            Apply.MouseButton1Click:Connect(function() 
                local c = Color3.fromRGB(tonumber(R.Text) or 0, tonumber(G.Text) or 0, tonumber(B.Text) or 0); Preview.BackgroundColor3 = c; Library.Flags[Flag] = c; pcall(callback, c); 
                Picker.Visible=false; Frame:TweenSize(UDim2.new(1,0,0,40),"Out","Quart",0.3,true)
            end)
            Preview.MouseButton1Click:Connect(function() Picker.Visible = not Picker.Visible; Frame:TweenSize(Picker.Visible and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 40), "Out", "Quart", 0.3, true) end)
        end
        
        return Elements
    end
    
    local SetTab = WindowAPI:Tab("Settings")
    SetTab:Section("Theme")
    SetTab:ColorPicker({Name = "UI Accent Color", Flag = "UI_Color", Default = Theme.Accent}, function(c) Library:Harmonize(c) end) -- HARMONIZER LINKED
    SetTab:Section("Security")
    SetTab:Toggle({Name = "Anti-AFK", Flag = "AntiAFK", Default = false}, function(v) Library.AntiAFK = v end)
    SetTab:Section("Exit")
    SetTab:Button("Unload UI", function() Library:Unload() end)
    
    return WindowAPI
end
return Library

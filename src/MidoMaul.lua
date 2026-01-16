--[[
    MIDOMAUL // v7.0 HYPER-ANIMATED
    - Added: UIScale Pop-up Animations
    - Added: Hover/Click Motion Effects
    - Added: Modern Color Picker with Submit Button
    - Added: Dynamic UI Toggle Keybind
    - Added: Anti-AFK System
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// 🎨 THEME ENGINE
local Theme = {
    Main        = Color3.fromRGB(18, 18, 22),
    Sidebar     = Color3.fromRGB(23, 23, 28),
    Element     = Color3.fromRGB(30, 30, 36),
    Interact    = Color3.fromRGB(45, 45, 52), -- Lighter for hover
    Accent      = Color3.fromRGB(0, 200, 255),
    Text        = Color3.fromRGB(240, 240, 240),
    SubText     = Color3.fromRGB(140, 140, 150),
    Stroke      = Color3.fromRGB(60, 60, 70),
    
    Font        = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    Corner      = UDim.new(0, 6)
}

--// 🛠️ UTILITY & INTERNALS
local Library = { 
    Flags = {}, 
    Items = {}, 
    Accents = {}, 
    Connections = {},
    ToggleKey = Enum.KeyCode.RightControl, -- Default Key
    ConfigFolder = "MidoMaulConfigs", 
    Keys = {},
    IsOpen = true
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

function Utility:Padding(parent, px)
    local p = Instance.new("UIPadding")
    p.Parent = parent
    p.PaddingLeft = UDim.new(0, px or 10); p.PaddingRight = UDim.new(0, px or 10)
    return p
end

--// 🎬 ANIMATION ENGINE
function Utility:Tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

function Utility:AnimateHover(btn, originalColor)
    btn.MouseEnter:Connect(function()
        Utility:Tween(btn, {BackgroundColor3 = Theme.Interact}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        Utility:Tween(btn, {BackgroundColor3 = originalColor or Theme.Element}, 0.2)
    end)
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

--// 🛡️ ANTI-AFK
function Library:InitAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

--// 🎨 THEME MANAGER
function Utility:RegisterAccent(obj, prop)
    table.insert(Library.Accents, {Object = obj, Property = prop})
    obj[prop] = Theme.Accent
end

function Library:SetAccent(color)
    Theme.Accent = color
    for _, item in pairs(Library.Accents) do
        if item.Object then Utility:Tween(item.Object, {[item.Property] = color}, 0.3) end
    end
end

--// ⚙️ SYSTEM
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
    local UI = CoreGui:FindFirstChild("MidoMaul_Hyper")
    if not UI then return end
    local Holder = UI:FindFirstChild("Notifs") or Utility:Create("Frame", { Name = "Notifs", Parent = UI, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(1, 1) })
    if not Holder:FindFirstChild("Layout") then Utility:Create("UIListLayout", {Name="Layout", Parent=Holder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Right}) end
    
    local Toast = Utility:Create("Frame", {Parent=Holder, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}); Utility:Corner(Toast); Utility:Stroke(Toast, Theme.Stroke); Utility:Padding(Toast, 12)
    local Bar = Utility:Create("Frame", {Parent=Toast, Size=UDim2.new(0,3,1,0), Position=UDim2.new(0,-12,0,0), BorderSizePixel=0}); Utility:RegisterAccent(Bar, "BackgroundColor3")
    
    Utility:Create("TextLabel", {Parent=Toast, Text=title, TextColor3=Theme.Text, Font=Theme.FontBold, TextSize=14, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    Utility:Create("TextLabel", {Parent=Toast, Text=text, TextColor3=Theme.SubText, Font=Theme.Font, TextSize=12, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    
    -- Pop In Animation
    local Scale = Utility:Create("UIScale", {Parent=Toast, Scale=0})
    Utility:Tween(Scale, {Scale=1}, 0.3, Enum.EasingStyle.Back)
    
    task.delay(duration or 3, function() 
        Utility:Tween(Scale, {Scale=0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        Toast:Destroy() 
    end)
end

function Library:Unload()
    for _, conn in pairs(Library.Connections) do conn:Disconnect() end
    if CoreGui:FindFirstChild("MidoMaul_Hyper") then CoreGui.MidoMaul_Hyper:Destroy() end
end

--// ⌨️ KEYBIND HANDLER
table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
        -- Custom UI Toggle
        if input.KeyCode == Library.ToggleKey then
            Library:Toggle()
        end
        -- Feature Keybinds
        for _, bind in pairs(Library.Keys) do 
            if input.KeyCode.Name == bind.Key then bind.Callback() end 
        end
    end
end))

--// 🖥️ MAIN WINDOW
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    Library.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    Library:InitAntiAFK()
    
    local ScreenGui = Utility:Create("ScreenGui", { Name = "MidoMaul_Hyper", Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    
    --// OPEN BUTTON
    local OpenBtn = Utility:Create("TextButton", { Name = "OpenBtn", Parent = ScreenGui, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), Visible = false, Text = "M", TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 24, AutoButtonColor = false }); Utility:Corner(OpenBtn, UDim.new(1,0)); Utility:Stroke(OpenBtn, Theme.Stroke); Utility:MakeDrag(OpenBtn)
    Utility:RegisterAccent(OpenBtn, "TextColor3")

    --// MAIN FRAME
    local Main = Utility:Create("Frame", { Name = "Main", Parent = ScreenGui, BackgroundColor3 = Theme.Main, Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0, 600, 0, 450) }); Utility:Corner(Main); Utility:Stroke(Main, Theme.Stroke); Utility:MakeDrag(Main)
    local MainScale = Utility:Create("UIScale", {Parent=Main, Scale=1}) -- For Open/Close Anim
    
    -- Close/Open Logic
    function Library:Toggle()
        Library.IsOpen = not Library.IsOpen
        if Library.IsOpen then
            Main.Visible = true
            OpenBtn.Visible = false
            Utility:Tween(MainScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Utility:Tween(MainScale, {Scale = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.3)
            Main.Visible = false
            OpenBtn.Visible = true
        end
    end
    OpenBtn.MouseButton1Click:Connect(Library.Toggle)
    
    local CloseBtn = Utility:Create("TextButton", { Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 10), Text = "×", TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 24 }); CloseBtn.MouseButton1Click:Connect(Library.Toggle)

    -- Sidebar
    local Sidebar = Utility:Create("Frame", { Parent = Main, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 170, 1, 0) }); Utility:Corner(Sidebar)
    Utility:Create("Frame", {Parent=Sidebar, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(0,10,1,0), Position=UDim2.new(1,-10,0,0), BorderSizePixel=0})
    
    local TitleLabel = Utility:Create("TextLabel", { Parent = Sidebar, Text = Title, TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 18, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TitleLabel, 15); Utility:RegisterAccent(TitleLabel, "TextColor3")
    
    local TabHolder = Utility:Create("ScrollingFrame", { Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0,0,0,60), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0 })
    Utility:Create("UIListLayout", {Parent=TabHolder, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)})
    local PageHolder = Utility:Create("Frame", { Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), ClipsDescendants = true })

    local WindowAPI = {}
    local FirstTab = true

    function WindowAPI:Tab(name)
        local TabBtn = Utility:Create("TextButton", { Parent = TabHolder, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false }); Utility:Corner(TabBtn)
        local TabTxt = Utility:Create("TextLabel", { Parent = TabBtn, Text = name, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TabTxt, 10)
        
        local Page = Utility:Create("ScrollingFrame", { Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel=0 }); Utility:Padding(Page, 0); Utility:Create("UIPadding", {Parent=Page, PaddingRight=UDim.new(0,10)})
        local PageList = Utility:Create("UIListLayout", {Parent=Page, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)})
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 20) end)
        
        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then Utility:Tween(v, {BackgroundColor3 = Theme.Sidebar}); Utility:Tween(v.TextLabel, {TextColor3 = Theme.SubText}) end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            Utility:Tween(TabBtn, {BackgroundColor3 = Theme.Element}); Utility:Tween(TabTxt, {TextColor3 = Theme.Text}); Page.Visible = true
        end
        TabBtn.MouseButton1Click:Connect(Activate); if FirstTab then FirstTab = false; Activate() end

        local Elements = {}
        
        function Elements:Section(text) local Sec = Utility:Create("TextLabel", { Parent = Page, Text = string.upper(text), TextColor3 = Theme.SubText, Font = Theme.FontBold, TextSize = 11, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Sec, 2) end
        function Elements:Label(text) local Lab = Utility:Create("TextLabel", { Parent = Page, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped=true }); Utility:Padding(Lab, 2) end
        
        function Elements:Button(text, callback)
            local Btn = Utility:Create("TextButton", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false }); Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke); Utility:AnimateHover(Btn)
            local BtnTxt = Utility:Create("TextLabel", { Parent = Btn, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(BtnTxt, 12)
            Btn.MouseButton1Click:Connect(function() 
                local Ripple = Utility:Create("Frame", {Parent=Btn, BackgroundColor3=Theme.Text, BackgroundTransparency=0.8, Position=UDim2.new(0,Mouse.X-Btn.AbsolutePosition.X,0,Mouse.Y-Btn.AbsolutePosition.Y), Size=UDim2.new(0,0,0,0)}); Utility:Corner(Ripple, UDim.new(1,0))
                Utility:Tween(Ripple, {Size=UDim2.new(0,400,0,400), Position=UDim2.new(0,Ripple.Position.X.Offset-200,0,Ripple.Position.Y.Offset-200), BackgroundTransparency=1}, 0.5)
                task.wait(0.5); Ripple:Destroy(); pcall(callback) 
            end)
        end
        
        function Elements:Toggle(options, callback)
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or false; Library.Flags[Flag] = Default
            local Tgl = Utility:Create("TextButton", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false }); Utility:Corner(Tgl); Utility:Stroke(Tgl, Theme.Stroke); Utility:AnimateHover(Tgl)
            local TglTxt = Utility:Create("TextLabel", { Parent = Tgl, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(TglTxt, 12)
            local Box = Utility:Create("Frame", { Parent = Tgl, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -46, 0.5, -10) }); Utility:Corner(Box, UDim.new(1,0)); local Stroke = Utility:Stroke(Box, Theme.Stroke)
            local Knob = Utility:Create("Frame", { Parent = Box, BackgroundColor3 = Theme.SubText, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8) }); Utility:Corner(Knob, UDim.new(1,0))
            local function Update(val) Library.Flags[Flag] = val; 
                Utility:Tween(Box, {BackgroundColor3 = val and Theme.Accent or Theme.Main}); 
                Utility:Tween(Knob, {Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = val and Theme.Text or Theme.SubText}, 0.2, Enum.EasingStyle.Back)
                pcall(callback, val) 
            end
            Tgl.MouseButton1Click:Connect(function() Update(not Library.Flags[Flag]) end); Library.Items[Flag] = { Set = function(self, v) Update(v) end }; if Default then Update(true) end
        end
        
        function Elements:Slider(options, callback)
            local Text, Flag, Min, Max, Default = options.Name, options.Flag or options.Name, options.Min or 0, options.Max or 100, options.Default or 0; Library.Flags[Flag] = Default
            local Sld = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 50) }); Utility:Corner(Sld); Utility:Stroke(Sld, Theme.Stroke)
            local SldTxt = Utility:Create("TextLabel", { Parent = Sld, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -60, 0, 30), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(SldTxt, 12)
            local ValTxt = Utility:Create("TextLabel", { Parent = Sld, Text = tostring(Default), TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 13, Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right }); Utility:RegisterAccent(ValTxt, "TextColor3")
            local Bar = Utility:Create("TextButton", { Parent = Sld, BackgroundColor3 = Theme.Main, Text = "", AutoButtonColor = false, Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 32) }); Utility:Corner(Bar, UDim.new(1, 0))
            local Fill = Utility:Create("Frame", { Parent = Bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0) }); Utility:Corner(Fill, UDim.new(1, 0)); Utility:RegisterAccent(Fill, "BackgroundColor3")
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
            local Frame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 36) }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12)
            local Preview = Utility:Create("TextButton", { Parent = Frame, BackgroundColor3 = Default, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -42, 0.5, -10), Text = "" }); Utility:Corner(Preview, UDim.new(0,4)); Utility:Stroke(Preview, Theme.Stroke)
            
            local Picker = Utility:Create("Frame", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 110), Position = UDim2.new(0, 12, 0, 36), Visible = false }); Utility:Corner(Picker, UDim.new(0,4))
            local function CreateBox(pos, col, t) local b = Utility:Create("TextBox", { Parent = Picker, BackgroundColor3 = Theme.Element, Size = UDim2.new(0.3, 0, 0, 25), Position = pos, Text = t, TextColor3 = col, Font = Theme.FontBold, TextSize = 12 }); Utility:Corner(b, UDim.new(0,4)); return b end
            local R = CreateBox(UDim2.new(0,0,0.25,0), Color3.fromRGB(255,100,100), "255"); local G = CreateBox(UDim2.new(0.35,0,0.25,0), Color3.fromRGB(100,255,100), "255"); local B = CreateBox(UDim2.new(0.7,0,0.25,0), Color3.fromRGB(100,100,255), "255")
            local Apply = Utility:Create("TextButton", {Parent = Picker, BackgroundColor3 = Theme.Interact, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0,0,0.65,0), Text = "Apply Color", TextColor3 = Theme.Text, Font = Theme.FontBold}); Utility:Corner(Apply, UDim.new(0,4))
            
            Apply.MouseButton1Click:Connect(function()
                local c = Color3.fromRGB(tonumber(R.Text) or 0, tonumber(G.Text) or 0, tonumber(B.Text) or 0)
                Preview.BackgroundColor3 = c; Library.Flags[Flag] = c; pcall(callback, c)
                Library:Notify("Color", "Updated", 1)
            end)
            local Open = false; Preview.MouseButton1Click:Connect(function() Open = not Open; Picker.Visible = Open; Frame:TweenSize(Open and UDim2.new(1, 0, 0, 150) or UDim2.new(1, 0, 0, 36), "Out", "Quart", 0.3, true) end)
        end
        
        function Elements:Keybind(options, callback) -- Works for both feature binds AND changing ToggleKey
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or "None"; Library.Keys[Flag] = { Key = Default, Callback = function() pcall(callback) end }
            local Frame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 36) }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12)
            local Btn = Utility:Create("TextButton", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -92, 0.5, -10), Text = Default, TextColor3 = Theme.SubText, Font = Theme.FontBold, TextSize = 12 }); Utility:Corner(Btn, UDim.new(0,4)); local Stroke = Utility:Stroke(Btn, Theme.Stroke)
            local Binding = false
            Btn.MouseButton1Click:Connect(function() Binding = true; Btn.Text = "..."; Utility:Tween(Stroke, {Color = Theme.Accent}) end)
            table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(i) 
                if Binding and i.UserInputType == Enum.UserInputType.Keyboard then 
                    Binding = false; 
                    -- Special Case: If this keybind is meant to change the Menu Toggle
                    if options.IsToggleKey then Library.ToggleKey = i.KeyCode end
                    
                    Library.Keys[Flag].Key = i.KeyCode.Name; Btn.Text = i.KeyCode.Name; Utility:Tween(Stroke, {Color = Theme.Stroke}) 
                end 
            end))
        end

        function Elements:Dropdown(options, callback)
            local Text, Flag, List, Default, Multi = options.Name, options.Flag or options.Name, options.List or {}, options.Default, options.Multi; local State = Multi and {} or Default or List[1]
            if Multi then for _, v in pairs(List) do State[v] = false end if type(Default)=="table" then for _,v in pairs(Default) do State[v]=true end end end; Library.Flags[Flag] = State
            local DropFrame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true }); Utility:Corner(DropFrame); Utility:Stroke(DropFrame, Theme.Stroke)
            local Button = Utility:Create("TextButton", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false })
            local Label = Utility:Create("TextLabel", { Parent = Button, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -40, 0, 36), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Label, 12)
            local Arrow = Utility:Create("ImageLabel", { Parent = Button, BackgroundTransparency = 1, Image = "rbxassetid://6031090990", Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9) })
            local Container = Utility:Create("Frame", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0,0,0,36), AutomaticSize = Enum.AutomaticSize.Y, Visible = false }); Utility:Create("UIListLayout", {Parent=Container, SortOrder=Enum.SortOrder.LayoutOrder})
            local function Refresh() Label.Text = Text .. (Multi and " [...]" or ": "..tostring(State)) end; Refresh()
            local IsOpen = false; Button.MouseButton1Click:Connect(function() IsOpen = not IsOpen; Container.Visible = IsOpen; Utility:Tween(Arrow, {Rotation = IsOpen and 180 or 0})
                if IsOpen then for _, child in pairs(Container:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    for _, item in pairs(List) do local ItemBtn = Utility:Create("TextButton", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false })
                        local ItemTxt = Utility:Create("TextLabel", { Parent = ItemBtn, Text = item, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(ItemTxt, 30)
                        local Sel = Multi and State[item] or (State == item); if Sel then ItemTxt.TextColor3 = Theme.Accent end
                        ItemBtn.MouseButton1Click:Connect(function() if Multi then State[item] = not State[item]; Sel = State[item]; ItemTxt.TextColor3 = Sel and Theme.Accent or Theme.SubText else State = item; IsOpen = false; Container.Visible = false; DropFrame:TweenSize(UDim2.new(1, 0, 0, 36), "Out", "Quart", 0.3, true) end; Library.Flags[Flag] = State; Refresh(); pcall(callback, State) end)
                    end; DropFrame:TweenSize(UDim2.new(1, 0, 0, 36 + (#List * 30)), "Out", "Quart", 0.3, true)
                else DropFrame:TweenSize(UDim2.new(1, 0, 0, 36), "Out", "Quart", 0.3, true) end
            end)
            Library.Items[Flag] = { Set = function(self, val) State = val; Library.Flags[Flag] = State; Refresh(); pcall(callback, State) end }
        end
        
        function Elements:ConfigSystem()
            Elements:Section("Configuration")
            local Name = ""
            local Field = Elements:TextField({Name="Config Name", Flag="ConfigName", Placeholder="Config Name..."}, function(v) Name = v end)
            local Grp = Utility:Create("Frame", {Parent=Page, BackgroundTransparency=1, Size=UDim2.new(1,0,0,36)}); local Layout = Utility:Create("UIListLayout", {Parent=Grp, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)})
            local function Btn(t, f) local b = Utility:Create("TextButton", {Parent=Grp, BackgroundColor3=Theme.Element, Size=UDim2.new(0.32,0,1,0), Text=t, TextColor3=Theme.Text, Font=Theme.Font}); Utility:Corner(b); Utility:Stroke(b, Theme.Stroke); b.MouseButton1Click:Connect(f) end
            Btn("Save", function() Library:SaveConfig(Name) end); Btn("Load", function() Library:LoadConfig(Name) end); Btn("List", function() Library:Notify("Configs", table.concat(Library:GetConfigs(), ", ")) end)
        end
        -- ADD MISSING ELEMENTS TO RETURN
        function Elements:TextField(options, callback) -- Added back to return
            local Text, Flag, Placeholder = options.Name, options.Flag or options.Name, options.Placeholder or "..."
            local Frame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 50) }); Utility:Corner(Frame); Utility:Stroke(Frame, Theme.Stroke)
            local Lab = Utility:Create("TextLabel", { Parent = Frame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left }); Utility:Padding(Lab, 12)
            local BoxHolder = Utility:Create("Frame", { Parent = Frame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 24) }); Utility:Corner(BoxHolder, UDim.new(0, 4)); local Stroke = Utility:Stroke(BoxHolder, Theme.Stroke)
            local Box = Utility:Create("TextBox", { Parent = BoxHolder, BackgroundTransparency = 1, Text = "", PlaceholderText = Placeholder, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false }); Utility:Padding(Box, 6)
            table.insert(Library.Connections, Box.FocusLost:Connect(function() Library.Flags[Flag] = Box.Text; Utility:Tween(Stroke, {Color = Theme.Stroke}); pcall(callback, Box.Text) end))
            table.insert(Library.Connections, Box.Focused:Connect(function() Utility:Tween(Stroke, {Color = Theme.Accent}) end))
            Library.Items[Flag] = { Set = function(self, v) Box.Text = v; Library.Flags[Flag] = v; pcall(callback, v) end }
        end
        function Elements:ButtonGroup(options) -- Added back
             local List, Call = options.Names or {}, options.Callback or function() end
             local Grp = Utility:Create("Frame", {Parent=Page, BackgroundTransparency=1, Size=UDim2.new(1,0,0,36)}); local Layout = Utility:Create("UIListLayout", {Parent=Grp, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)})
             local SizePercent = 1 / #List
             for _, name in pairs(List) do
                 local Btn = Utility:Create("TextButton", { Parent = Grp, BackgroundColor3 = Theme.Element, Size = UDim2.new(SizePercent, -5, 1, 0), Text = name, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, AutoButtonColor = false }); Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke)
                 Btn.MouseButton1Click:Connect(function() pcall(Call, name) end)
             end
        end
        return Elements
    end
    return WindowAPI
end
return Library

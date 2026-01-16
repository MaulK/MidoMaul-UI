--[[
    MIDOMAUL // v5.2 PC/MOBILE TOGGLE UPDATE
    - Added: Draggable "M" Button for PC & Mobile
    - Updated: Dragging logic is now a reusable utility
    - Fixed: Button visibility sync with Keybinds
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// 🎨 THEME
local Theme = {
    Main        = Color3.fromRGB(18, 18, 22),
    Sidebar     = Color3.fromRGB(23, 23, 28),
    Element     = Color3.fromRGB(30, 30, 36),
    Interact    = Color3.fromRGB(40, 40, 48),
    Accent      = Color3.fromRGB(0, 200, 255),
    Text        = Color3.fromRGB(240, 240, 240),
    SubText     = Color3.fromRGB(140, 140, 150),
    Stroke      = Color3.fromRGB(50, 50, 60),
    Success     = Color3.fromRGB(100, 255, 120),
    Warning     = Color3.fromRGB(255, 200, 100),
    
    Font        = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    Corner      = UDim.new(0, 6)
}

--// 💾 FILESYSTEM
local function SafeWrite(file, data) if writefile then writefile(file, data) end end
local function SafeRead(file) if readfile and isfile and isfile(file) then return readfile(file) end return nil end
local function SafeList(folder) if listfiles and isfolder and isfolder(folder) then return listfiles(folder) end return {} end
local function SafeMakeFolder(folder) if makefolder and not isfolder(folder) then makefolder(folder) end end

--// 🛠️ UTILITY
local Library = { Flags = {}, Items = {}, ConfigFolder = "MidoMaulConfigs", Keys = {} }
local Utility = {}

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

function Utility:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

-- New Reusable Drag Function
function Utility:MakeDrag(frame)
    local Dragging, DragInput, DragStart, StartPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

--// ⚙️ CONFIG ENGINE
function Library:SaveConfig(name)
    local json = HttpService:JSONEncode(Library.Flags)
    SafeMakeFolder(Library.ConfigFolder)
    SafeWrite(Library.ConfigFolder .. "/" .. name .. ".json", json)
    Library:Notify("System", "Config '"..name.."' saved.")
end

function Library:LoadConfig(name)
    local data = SafeRead(Library.ConfigFolder .. "/" .. name .. ".json")
    if data then
        local decoded = HttpService:JSONDecode(data)
        for flag, value in pairs(decoded) do
            if Library.Items[flag] then Library.Items[flag]:Set(value) end
        end
        Library:Notify("System", "Config loaded.")
    else
        Library:Notify("Error", "Config not found.")
    end
end

function Library:GetConfigs()
    local raw = SafeList(Library.ConfigFolder)
    local clean = {}
    for _, file in pairs(raw) do
        local filename = file:match("([^/]+)%.json$")
        if filename then table.insert(clean, filename) end
    end
    return clean
end

function Library:Notify(title, text, duration)
    local UI = CoreGui:FindFirstChild("MidoMaul_Ultimate")
    if not UI then return end
    local Holder = UI:FindFirstChild("Notifs") or Utility:Create("Frame", {
        Name = "Notifs", Parent = UI, BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(1, 1)
    })
    if not Holder:FindFirstChild("Layout") then
        Utility:Create("UIListLayout", {Name="Layout", Parent=Holder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,5), HorizontalAlignment=Enum.HorizontalAlignment.Right})
    end
    local Toast = Utility:Create("Frame", {Parent=Holder, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y})
    Utility:Corner(Toast); Utility:Stroke(Toast, Theme.Stroke)
    Utility:Create("UIPadding", {Parent=Toast, PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)})
    Utility:Create("TextLabel", {
        Parent=Toast, Text=title, TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=14,
        BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, TextXAlignment=Enum.TextXAlignment.Left
    })
    Utility:Create("TextLabel", {
        Parent=Toast, Text=text, TextColor3=Theme.Text, Font=Theme.Font, TextSize=12,
        BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, TextXAlignment=Enum.TextXAlignment.Left
    })
    task.delay(duration or 3, function() Toast:Destroy() end)
end

--// ⌨️ KEYBIND SYSTEM
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
        for _, bind in pairs(Library.Keys) do
            if input.KeyCode.Name == bind.Key then bind.Callback() end
        end
    end
end)

--// 🖥️ WINDOW
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    local ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    SafeMakeFolder(Library.ConfigFolder)
    
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "MidoMaul_Ultimate", Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    --// TOGGLE BUTTON (Draggable for PC/Mobile)
    local OpenBtn = Utility:Create("TextButton", {
        Name = "OpenButton", Parent = ScreenGui, BackgroundColor3 = Theme.Main,
        Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), Visible = false,
        Text = "M", TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 24,
        AutoButtonColor = false
    })
    Utility:Corner(OpenBtn, UDim.new(1,0)); Utility:Stroke(OpenBtn, Theme.Stroke)
    
    -- Make the button draggable
    Utility:MakeDrag(OpenBtn)
    
    --// MAIN FRAME
    local Main = Utility:Create("Frame", {
        Name = "Main", Parent = ScreenGui, BackgroundColor3 = Theme.Main,
        Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0, 600, 0, 450)
    })
    Utility:Corner(Main, UDim.new(0, 8)); Utility:Stroke(Main, Theme.Stroke)
    
    -- Make Main draggable
    Utility:MakeDrag(Main)
    
    -- Toggle Logic
    local function ToggleUI()
        Main.Visible = not Main.Visible
        OpenBtn.Visible = not Main.Visible
    end
    
    Library.Toggle = ToggleUI
    OpenBtn.MouseButton1Click:Connect(ToggleUI)
    
    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == ToggleKey then ToggleUI() end end)

    --// CLOSE BUTTON (X)
    local CloseBtn = Utility:Create("TextButton", {
        Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 10), Text = "×", TextColor3 = Theme.SubText,
        Font = Theme.Font, TextSize = 24, ZIndex = 5
    })
    CloseBtn.MouseButton1Click:Connect(ToggleUI)

    -- Sidebar
    local Sidebar = Utility:Create("Frame", { Parent = Main, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 160, 1, 0) })
    Utility:Corner(Sidebar, UDim.new(0, 8))
    Utility:Create("Frame", {Parent=Sidebar, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(0,10,1,0), Position=UDim2.new(1,-10,0,0), BorderSizePixel=0})
    Utility:Create("TextLabel", {
        Parent = Sidebar, Text = Title, TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 18,
        Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
    })
    local TabHolder = Utility:Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0,0,0,60),
        CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0
    })
    Utility:Create("UIListLayout", {Parent=TabHolder, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)})
    local PageHolder = Utility:Create("Frame", {
        Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, -170, 1, -20), Position = UDim2.new(0, 170, 0, 10), ClipsDescendants = true
    })

    local WindowAPI = {}
    local FirstTab = true

    function WindowAPI:Tab(name)
        local TabBtn = Utility:Create("TextButton", {
            Parent = TabHolder, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, -20, 0, 32),
            Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false
        })
        Utility:Corner(TabBtn)
        local TabTxt = Utility:Create("TextLabel", {
            Parent = TabBtn, Text = name, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 14,
            BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Page = Utility:Create("ScrollingFrame", {
            Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel=0
        })
        local PageList = Utility:Create("UIListLayout", {Parent=Page, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)})
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 20) end)
        
        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then
                Utility:Tween(v, {BackgroundColor3 = Theme.Sidebar}); Utility:Tween(v.TextLabel, {TextColor3 = Theme.SubText})
            end end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            Utility:Tween(TabBtn, {BackgroundColor3 = Theme.Element}); Utility:Tween(TabTxt, {TextColor3 = Theme.Text})
            Page.Visible = true
        end
        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false; Activate() end

        local Elements = {}

        function Elements:Section(text)
            local Sec = Utility:Create("TextLabel", {
                Parent = Page, Text = string.upper(text), TextColor3 = Theme.SubText, Font = Theme.FontBold,
                TextSize = 11, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })
            Utility:Create("UIPadding", {Parent=Sec, PaddingLeft=UDim.new(0,2), PaddingTop=UDim.new(0,10)})
        end

        function Elements:Label(text)
            local Lab = Utility:Create("TextLabel", {
                Parent = Page, Text = text, TextColor3 = Theme.Text, Font = Theme.Font,
                TextSize = 13, Size = UDim2.new(1, -6, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped=true
            })
            Utility:Create("UIPadding", {Parent=Lab, PaddingLeft=UDim.new(0,12)})
        end

        function Elements:Button(text, callback)
            local Btn = Utility:Create("TextButton", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36), Text = "", AutoButtonColor = false
            })
            Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke)
            Utility:Create("TextLabel", {
                Parent = Btn, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })
            Btn.MouseButton1Click:Connect(function() 
                Utility:Tween(Btn, {BackgroundColor3 = Theme.Interact}, 0.1); task.wait(0.1); Utility:Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.2); pcall(callback) 
            end)
        end
        
        function Elements:ButtonGroup(options) 
             local List, Call = options.Names or {}, options.Callback or function() end
             local Grp = Utility:Create("Frame", {Parent=Page, BackgroundTransparency=1, Size=UDim2.new(1,-6,0,36)})
             local Layout = Utility:Create("UIListLayout", {Parent=Grp, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5)})
             local SizePercent = 1 / #List
             for _, name in pairs(List) do
                 local Btn = Utility:Create("TextButton", {
                     Parent = Grp, BackgroundColor3 = Theme.Element, Size = UDim2.new(SizePercent, -5, 1, 0), Text = name,
                     TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, AutoButtonColor = false
                 })
                 Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke)
                 Btn.MouseButton1Click:Connect(function() pcall(Call, name) end)
             end
        end

        function Elements:Toggle(options, callback)
            local Text, Flag, Default = options.Name or "Toggle", options.Flag or options.Name, options.Default or false
            Library.Flags[Flag] = Default
            local Tgl = Utility:Create("TextButton", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36), Text = "", AutoButtonColor = false })
            Utility:Corner(Tgl); Utility:Stroke(Tgl, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = Tgl, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local Box = Utility:Create("Frame", { Parent = Tgl, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10) }); Utility:Corner(Box, UDim.new(0,4)); local Stroke = Utility:Stroke(Box, Theme.Stroke)
            local Check = Utility:Create("Frame", { Parent = Box, BackgroundColor3 = Theme.Accent, Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2), Transparency = 1 }); Utility:Corner(Check, UDim.new(0,3))
            local function Update(val) Library.Flags[Flag] = val; Utility:Tween(Check, {Transparency = val and 0 or 1}); Utility:Tween(Stroke, {Color = val and Theme.Accent or Theme.Stroke}); pcall(callback, val) end
            Tgl.MouseButton1Click:Connect(function() Update(not Library.Flags[Flag]) end)
            Library.Items[Flag] = { Set = function(self, v) Update(v) end }
            if Default then Update(true) end
        end

        function Elements:Slider(options, callback)
            local Text, Flag, Min, Max, Default = options.Name, options.Flag or options.Name, options.Min or 0, options.Max or 100, options.Default or 0
            Library.Flags[Flag] = Default
            local Sld = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 50) }); Utility:Corner(Sld); Utility:Stroke(Sld, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = Sld, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local ValTxt = Utility:Create("TextLabel", { Parent = Sld, Text = tostring(Default), TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 13, Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right })
            local Bar = Utility:Create("TextButton", { Parent = Sld, BackgroundColor3 = Theme.Main, Text = "", AutoButtonColor = false, Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 32) }); Utility:Corner(Bar, UDim.new(1, 0))
            local Fill = Utility:Create("Frame", { Parent = Bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0) }); Utility:Corner(Fill, UDim.new(1, 0))
            local function Update(val) val = math.clamp(val, Min, Max); Library.Flags[Flag] = val; ValTxt.Text = tostring(val); Fill.Size = UDim2.new((val - Min) / (Max - Min), 0, 1, 0); pcall(callback, val) end
            local Dragging = false
            local function Move(input) local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); Update(math.floor(Min + (Max - Min) * p)) end
            Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Move(i) end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Move(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            Library.Items[Flag] = { Set = function(self, v) Update(v) end }
            Update(Default)
        end
        
        function Elements:TextField(options, callback)
            local Text, Flag, Placeholder = options.Name, options.Flag or options.Name, options.Placeholder or "..."
            local TxtFrame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 50) }); Utility:Corner(TxtFrame); Utility:Stroke(TxtFrame, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = TxtFrame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 12, 0, 2), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local BoxHolder = Utility:Create("Frame", { Parent = TxtFrame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 24) }); Utility:Corner(BoxHolder, UDim.new(0, 4)); local Stroke = Utility:Stroke(BoxHolder, Theme.Stroke)
            local Box = Utility:Create("TextBox", { Parent = BoxHolder, BackgroundTransparency = 1, Text = "", PlaceholderText = Placeholder, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false })
            Box.FocusLost:Connect(function() Library.Flags[Flag] = Box.Text; Utility:Tween(Stroke, {Color = Theme.Stroke}); pcall(callback, Box.Text) end)
            Box.Focused:Connect(function() Utility:Tween(Stroke, {Color = Theme.Accent}) end)
            Library.Items[Flag] = { Set = function(self, v) Box.Text = v; Library.Flags[Flag] = v; pcall(callback, v) end }
        end
        
        function Elements:Keybind(options, callback)
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or "None"
            Library.Keys[Flag] = { Key = Default, Callback = function() pcall(callback) end }
            local KeyFrame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36) }); Utility:Corner(KeyFrame); Utility:Stroke(KeyFrame, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = KeyFrame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local BindBtn = Utility:Create("TextButton", { Parent = KeyFrame, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -92, 0.5, -10), Text = Default, TextColor3 = Theme.SubText, Font = Theme.FontBold, TextSize = 12 }); Utility:Corner(BindBtn, UDim.new(0,4)); local Stroke = Utility:Stroke(BindBtn, Theme.Stroke)
            local Binding = false
            BindBtn.MouseButton1Click:Connect(function() Binding = true; BindBtn.Text = "..."; Utility:Tween(Stroke, {Color = Theme.Accent}) end)
            UserInputService.InputBegan:Connect(function(i) if Binding and i.UserInputType == Enum.UserInputType.Keyboard then Binding = false; Library.Keys[Flag].Key = i.KeyCode.Name; BindBtn.Text = i.KeyCode.Name; Utility:Tween(Stroke, {Color = Theme.Stroke}) end end)
        end
        
        function Elements:ColorPicker(options, callback)
            local Text, Flag, Default = options.Name, options.Flag or options.Name, options.Default or Color3.new(1,1,1)
            Library.Flags[Flag] = Default
            local CPFrame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36) }); Utility:Corner(CPFrame); Utility:Stroke(CPFrame, Theme.Stroke)
            Utility:Create("TextLabel", { Parent = CPFrame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local Preview = Utility:Create("TextButton", { Parent = CPFrame, BackgroundColor3 = Default, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -42, 0.5, -10), Text = "" }); Utility:Corner(Preview, UDim.new(0,4)); Utility:Stroke(Preview, Theme.Stroke)
            local Open = false
            local Picker = Utility:Create("Frame", { Parent = CPFrame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 100), Position = UDim2.new(0, 12, 0, 36), Visible = false }); Utility:Corner(Picker, UDim.new(0,4))
            local R_Box = Utility:Create("TextBox", { Parent = Picker, BackgroundColor3 = Theme.Element, Size = UDim2.new(0.3, 0, 0, 25), Position = UDim2.new(0,0,0.4,0), Text = "255", TextColor3 = Color3.fromRGB(255,100,100) })
            local G_Box = Utility:Create("TextBox", { Parent = Picker, BackgroundColor3 = Theme.Element, Size = UDim2.new(0.3, 0, 0, 25), Position = UDim2.new(0.35,0,0.4,0), Text = "255", TextColor3 = Color3.fromRGB(100,255,100) })
            local B_Box = Utility:Create("TextBox", { Parent = Picker, BackgroundColor3 = Theme.Element, Size = UDim2.new(0.3, 0, 0, 25), Position = UDim2.new(0.7,0,0.4,0), Text = "255", TextColor3 = Color3.fromRGB(100,100,255) })
            local function UpdateColor() local r, g, b = tonumber(R_Box.Text) or 0, tonumber(G_Box.Text) or 0, tonumber(B_Box.Text) or 0; local newCol = Color3.fromRGB(r, g, b); Preview.BackgroundColor3 = newCol; Library.Flags[Flag] = newCol; pcall(callback, newCol) end
            R_Box.FocusLost:Connect(UpdateColor); G_Box.FocusLost:Connect(UpdateColor); B_Box.FocusLost:Connect(UpdateColor)
            Preview.MouseButton1Click:Connect(function() Open = not Open; Picker.Visible = Open; CPFrame:TweenSize(Open and UDim2.new(1, -6, 0, 140) or UDim2.new(1, -6, 0, 36), "Out", "Quart", 0.3, true) end)
        end
        
        function Elements:ProgressBar(options)
             local Text, Min, Max, Current = options.Name, options.Min or 0, options.Max or 100, options.Default or 0
             local PFrame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 40) }); Utility:Corner(PFrame); Utility:Stroke(PFrame, Theme.Stroke)
             local PLabel = Utility:Create("TextLabel", { Parent = PFrame, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 12, 0, 2), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
             local PBarBack = Utility:Create("Frame", { Parent = PFrame, BackgroundColor3 = Theme.Main, Size = UDim2.new(1, -24, 0, 10), Position = UDim2.new(0, 12, 0, 22) }); Utility:Corner(PBarBack, UDim.new(1,0))
             local PFill = Utility:Create("Frame", { Parent = PBarBack, BackgroundColor3 = Theme.Success, Size = UDim2.new(0,0,1,0) }); Utility:Corner(PFill, UDim.new(1,0))
             local Obj = {}; function Obj:Set(val) val = math.clamp(val, Min, Max); local percent = (val - Min) / (Max - Min); Utility:Tween(PFill, {Size = UDim2.new(percent, 0, 1, 0)}); PLabel.Text = Text .. " [" .. math.floor(val) .. "/" .. Max .. "]" end
             Obj:Set(Current); return Obj
        end

        function Elements:Dropdown(options, callback)
            local Text, Flag, List, Default, Multi = options.Name, options.Flag or options.Name, options.List or {}, options.Default, options.Multi
            local State = Multi and {} or Default or List[1]
            if Multi then for _, v in pairs(List) do State[v] = false end if type(Default)=="table" then for _,v in pairs(Default) do State[v]=true end end end
            Library.Flags[Flag] = State
            local DropFrame = Utility:Create("Frame", { Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36), ClipsDescendants = true }); Utility:Corner(DropFrame); Utility:Stroke(DropFrame, Theme.Stroke)
            local Button = Utility:Create("TextButton", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false })
            local Label = Utility:Create("TextLabel", { Parent = Button, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            local Arrow = Utility:Create("ImageLabel", { Parent = Button, BackgroundTransparency = 1, Image = "rbxassetid://6031090990", Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9) })
            local Container = Utility:Create("Frame", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0,0,0,36), AutomaticSize = Enum.AutomaticSize.Y, Visible = false }); Utility:Create("UIListLayout", {Parent=Container, SortOrder=Enum.SortOrder.LayoutOrder})
            local function Refresh() Label.Text = Text .. (Multi and " [...]" or ": "..tostring(State)) end; Refresh()
            local IsOpen = false
            Button.MouseButton1Click:Connect(function() IsOpen = not IsOpen; Container.Visible = IsOpen; Utility:Tween(Arrow, {Rotation = IsOpen and 180 or 0})
                if IsOpen then for _, child in pairs(Container:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    for _, item in pairs(List) do local ItemBtn = Utility:Create("TextButton", { Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false })
                        local ItemTxt = Utility:Create("TextLabel", { Parent = ItemBtn, Text = item, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
                        local Sel = Multi and State[item] or (State == item); if Sel then ItemTxt.TextColor3 = Theme.Accent end
                        ItemBtn.MouseButton1Click:Connect(function() if Multi then State[item] = not State[item]; Sel = State[item]; ItemTxt.TextColor3 = Sel and Theme.Accent or Theme.SubText else State = item; IsOpen = false; Container.Visible = false; DropFrame:TweenSize(UDim2.new(1, -6, 0, 36), "Out", "Quart", 0.3, true) end; Library.Flags[Flag] = State; Refresh(); pcall(callback, State) end)
                    end; DropFrame:TweenSize(UDim2.new(1, -6, 0, 36 + (#List * 30)), "Out", "Quart", 0.3, true)
                else DropFrame:TweenSize(UDim2.new(1, -6, 0, 36), "Out", "Quart", 0.3, true) end
            end)
            Library.Items[Flag] = { Set = function(self, val) State = val; Library.Flags[Flag] = State; Refresh(); pcall(callback, State) end }
        end
        
        function Elements:ConfigSystem()
            Elements:Section("Configuration")
            local ConfigName = ""
            Elements:TextField({Name = "Config Name", Flag = "CfgName", Placeholder = "Type name..."}, function(v) ConfigName = v end)
            Elements:ButtonGroup({Names = {"Save", "Load", "Refresh"}, Callback = function(x) 
                if x == "Save" then Library:SaveConfig(ConfigName) end
                if x == "Load" then Library:LoadConfig(ConfigName) end
                if x == "Refresh" then Library:Notify("System", "Refreshed list (Check console/logs)") end
            end})
        end
        
        return Elements
    end
    return WindowAPI
end
return Library

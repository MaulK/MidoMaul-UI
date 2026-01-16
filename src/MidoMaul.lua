--[[
    MIDOMAUL // v4.0 SYSTEM EDITION
    - Added: Config System (Save/Load/Delete)
    - Added: Multi-Select & Single-Select Dropdowns
    - Added: Flag System for state tracking
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

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
    
    Font        = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    Corner      = UDim.new(0, 6)
}

--// 💾 FILESYSTEM
local function SafeWrite(file, data)
    if writefile then writefile(file, data) end
end
local function SafeRead(file)
    if readfile and isfile and isfile(file) then return readfile(file) end
    return nil
end
local function SafeList(folder)
    if listfiles and isfolder and isfolder(folder) then return listfiles(folder) end
    return {}
end
local function SafeMakeFolder(folder)
    if makefolder and not isfolder(folder) then makefolder(folder) end
end

--// 🛠️ UTILITY
local Library = {
    Flags = {},
    Items = {}, -- Stores Component Objects for updating
    ConfigFolder = "MidoMaulConfigs"
}
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

--// ⚙️ CONFIG ENGINE
function Library:SaveConfig(name)
    local json = HttpService:JSONEncode(Library.Flags)
    SafeMakeFolder(Library.ConfigFolder)
    SafeWrite(Library.ConfigFolder .. "/" .. name .. ".json", json)
    Library:Notify("System", "Config '"..name.."' saved successfully.")
end

function Library:LoadConfig(name)
    local data = SafeRead(Library.ConfigFolder .. "/" .. name .. ".json")
    if data then
        local decoded = HttpService:JSONDecode(data)
        for flag, value in pairs(decoded) do
            if Library.Items[flag] then
                Library.Items[flag]:Set(value)
            end
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
    -- Simplified Notification
    local UI = CoreGui:FindFirstChild("MidoMaul_Obsidian")
    if not UI then return end
    
    local Holder = UI:FindFirstChild("Notifs") or Utility:Create("Frame", {
        Name = "Notifs", Parent = UI, BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(0, 1)
    })
    if not Holder:FindFirstChild("Layout") then
        Utility:Create("UIListLayout", {Name="Layout", Parent=Holder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,5)})
    end
    
    local Toast = Utility:Create("Frame", {
        Parent=Holder, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y
    })
    Utility:Corner(Toast); Utility:Stroke(Toast, Theme.Stroke)
    Utility:Create("UIPadding", {Parent=Toast, PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,12)})
    
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

--// 🖥️ WINDOW
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    SafeMakeFolder(Library.ConfigFolder)
    
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "MidoMaul_Obsidian", Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local Main = Utility:Create("Frame", {
        Name = "Main", Parent = ScreenGui, BackgroundColor3 = Theme.Main,
        Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0, 600, 0, 420)
    })
    Utility:Corner(Main, UDim.new(0, 8)); Utility:Stroke(Main, Theme.Stroke)
    
    -- Drag Logic
    local Dragging, DragInput, StartPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; StartPos = input.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - StartPos
            Main.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + delta.X, Main.Position.Y.Scale, Main.Position.Y.Offset + delta.Y)
            StartPos = input.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)

    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Parent = Main, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 160, 1, 0)
    })
    Utility:Corner(Sidebar, UDim.new(0, 8))
    Utility:Create("Frame", {Parent=Sidebar, BackgroundColor3=Theme.Sidebar, Size=UDim2.new(0,10,1,0), Position=UDim2.new(1,-10,0,0), BorderSizePixel=0}) -- Patch
    
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
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v, {BackgroundColor3 = Theme.Sidebar})
                    Utility:Tween(v.TextLabel, {TextColor3 = Theme.SubText})
                end
            end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            
            Utility:Tween(TabBtn, {BackgroundColor3 = Theme.Element})
            Utility:Tween(TabTxt, {TextColor3 = Theme.Text})
            Page.Visible = true
        end
        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false; Activate() end

        local Elements = {}

        --// ELEMENT: BUTTON
        function Elements:Button(text, callback)
            local Btn = Utility:Create("TextButton", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36),
                Text = "", AutoButtonColor = false
            })
            Utility:Corner(Btn); Utility:Stroke(Btn, Theme.Stroke)
            Utility:Create("TextLabel", {
                Parent = Btn, Text = text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })
            Btn.MouseButton1Click:Connect(function() 
                Utility:Tween(Btn, {BackgroundColor3 = Theme.Interact}, 0.1)
                task.wait(0.1)
                Utility:Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.2)
                pcall(callback) 
            end)
        end

        --// ELEMENT: TOGGLE
        function Elements:Toggle(options, callback)
            local Text = options.Name or "Toggle"
            local Flag = options.Flag or Text
            local Default = options.Default or false
            
            Library.Flags[Flag] = Default
            
            local Tgl = Utility:Create("TextButton", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36),
                Text = "", AutoButtonColor = false
            })
            Utility:Corner(Tgl); Utility:Stroke(Tgl, Theme.Stroke)
            
            Utility:Create("TextLabel", {
                Parent = Tgl, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Box = Utility:Create("Frame", {
                Parent = Tgl, BackgroundColor3 = Theme.Main, Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10)
            })
            Utility:Corner(Box, UDim.new(0,4)); local Stroke = Utility:Stroke(Box, Theme.Stroke)
            local Check = Utility:Create("Frame", {
                Parent = Box, BackgroundColor3 = Theme.Accent, Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2), Transparency = 1
            })
            Utility:Corner(Check, UDim.new(0,3))
            
            local function Update(val)
                Library.Flags[Flag] = val
                Utility:Tween(Check, {Transparency = val and 0 or 1})
                Utility:Tween(Stroke, {Color = val and Theme.Accent or Theme.Stroke})
                pcall(callback, val)
            end
            
            Tgl.MouseButton1Click:Connect(function() Update(not Library.Flags[Flag]) end)
            
            -- API
            Library.Items[Flag] = { Set = function(self, v) Update(v) end }
            if Default then Update(true) end
        end

        --// ELEMENT: DROPDOWN (MULTI & SINGLE)
        function Elements:Dropdown(options, callback)
            local Text = options.Name or "Dropdown"
            local Flag = options.Flag or Text
            local List = options.List or {}
            local Default = options.Default
            local Multi = options.Multi or false
            
            -- State Initialization
            local State
            if Multi then
                State = {}
                for _, v in pairs(List) do State[v] = false end
                -- Handle default table if provided
                if type(Default) == "table" then
                   for _, v in pairs(Default) do State[v] = true end
                end
            else
                State = Default or List[1]
            end
            
            Library.Flags[Flag] = State
            
            local DropFrame = Utility:Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36),
                ClipsDescendants = true
            })
            Utility:Corner(DropFrame); Utility:Stroke(DropFrame, Theme.Stroke)
            
            local Button = Utility:Create("TextButton", {
                Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36),
                Text = "", AutoButtonColor = false
            })
            
            local Label = Utility:Create("TextLabel", {
                Parent = Button, Text = Text, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Arrow = Utility:Create("ImageLabel", {
                Parent = Button, BackgroundTransparency = 1, Image = "rbxassetid://6031090990",
                Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9)
            })
            
            local ListLayout = Utility:Create("UIListLayout", {Parent = DropFrame, SortOrder = Enum.SortOrder.LayoutOrder})
            
            -- Container for items
            local Container = Utility:Create("Frame", {
                Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Visible = false
            })
            Utility:Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder})
            
            local IsOpen = false
            
            local function RefreshText()
                if Multi then
                    local count = 0
                    for k, v in pairs(State) do if v then count = count + 1 end end
                    Label.Text = Text .. " [" .. count .. "]"
                else
                    Label.Text = Text .. ": " .. tostring(State)
                end
            end
            RefreshText()

            local function Toggle()
                IsOpen = not IsOpen
                Container.Visible = IsOpen
                Utility:Tween(Arrow, {Rotation = IsOpen and 180 or 0})
                
                if IsOpen then
                    -- Rebuild List
                    for _, child in pairs(Container:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    
                    for _, item in pairs(List) do
                        local ItemBtn = Utility:Create("TextButton", {
                            Parent = Container, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 30),
                            Text = "", AutoButtonColor = false
                        })
                        local ItemTxt = Utility:Create("TextLabel", {
                            Parent = ItemBtn, Text = item, TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12,
                            Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                        })
                        
                        -- Selection Indicator
                        local IsSelected
                        if Multi then IsSelected = State[item] else IsSelected = (State == item) end
                        
                        if IsSelected then ItemTxt.TextColor3 = Theme.Accent end
                        
                        ItemBtn.MouseButton1Click:Connect(function()
                            if Multi then
                                State[item] = not State[item]
                                IsSelected = State[item]
                                ItemTxt.TextColor3 = IsSelected and Theme.Accent or Theme.SubText
                            else
                                State = item
                                Toggle() -- Close on single select
                            end
                            Library.Flags[Flag] = State
                            RefreshText()
                            pcall(callback, State)
                        end)
                    end
                    DropFrame:TweenSize(UDim2.new(1, -6, 0, 36 + Container.AbsoluteSize.Y + 5), "Out", "Quart", 0.3, true)
                else
                    DropFrame:TweenSize(UDim2.new(1, -6, 0, 36), "Out", "Quart", 0.3, true)
                end
            end
            
            Container.ChildAdded:Connect(function() 
                if IsOpen then 
                    DropFrame:TweenSize(UDim2.new(1, -6, 0, 36 + Container.AbsoluteSize.Y + 5), "Out", "Quart", 0.3, true) 
                end 
            end)

            Button.MouseButton1Click:Connect(Toggle)
            
            -- API
            Library.Items[Flag] = { 
                Set = function(self, val) 
                    State = val
                    Library.Flags[Flag] = State
                    RefreshText()
                    pcall(callback, State)
                end 
            }
        end
        
        --// ELEMENT: CONFIG MANAGER
        function Elements:ConfigSystem()
            Elements:Section("Configuration")
            
            local ConfigName = ""
            
            local Box = Utility:Create("TextBox", {
                Parent = Page, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -6, 0, 36),
                Text = "", PlaceholderText = "Config Name...", TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13
            })
            Utility:Corner(Box); Utility:Stroke(Box, Theme.Stroke)
            Box.FocusLost:Connect(function() ConfigName = Box.Text end)
            
            Elements:Button("Save Config", function()
                if ConfigName ~= "" then Library:SaveConfig(ConfigName) end
            end)
            
            local Drop = Elements:Dropdown({
                Name = "Load Config",
                List = Library:GetConfigs(),
                Multi = false
            }, function(val)
                ConfigName = val
            end)
            
            Elements:Button("Load Selected", function()
                if ConfigName ~= "" then Library:LoadConfig(ConfigName) end
            end)
            
            Elements:Button("Refresh List", function()
                Drop:Set(Library:GetConfigs()) -- Not implemented in this snippet but easy to add.
                -- Basic Refresh hack:
                Library:Notify("System", "Please restart UI to refresh list (Implementation restriction)")
            end)
        end
        
        --// ELEMENT: SECTION
        function Elements:Section(text)
            local Sec = Utility:Create("TextLabel", {
                Parent = Page, Text = string.upper(text), TextColor3 = Theme.SubText, Font = Theme.FontBold,
                TextSize = 11, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
            })
            Utility:Create("UIPadding", {Parent=Sec, PaddingLeft=UDim.new(0,2), PaddingTop=UDim.new(0,10)})
        end

        return Elements
    end
    return WindowAPI
end
return Library

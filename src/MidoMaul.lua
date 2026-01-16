--[[
    MIDOMAUL // v2.1 AUTO-FIT EDITION
    Futuristic Material GUI Library
    Author: [MaulK / AI Architect]
    License: MIT
    
    Update Log:
    - Added AutomaticSize to all components (UI grows with text)
    - Enabled TextWrapped globally
    - Added UIPadding to prevent text hitting edges
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// 🎨 THEME CONFIGURATION
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Surface = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 255, 170), -- "Bio-Digital Cyan"
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    Outline = Color3.fromRGB(40, 40, 55),
    
    FontMain = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    
    CornerRadius = UDim.new(0, 8),
    AnimationSpeed = 0.35, 
}

--// 🛠️ UTILITY ENGINE
local Library = {}
local Utility = {}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function Utility:Tween(instance, properties, duration)
    local info = TweenInfo.new(duration or Theme.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(instance, info, properties):Play()
end

function Utility:AddRipple(button, color)
    task.spawn(function()
        local ripple = Utility:Create("Frame", {
            Name = "Ripple",
            Parent = button,
            BackgroundColor3 = color or Theme.TextPrimary,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 10,
        })
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        Utility:Tween(ripple, {Size = UDim2.new(2.5, 0, 2.5, 0), BackgroundTransparency = 1}, 0.6)
        task.wait(0.6)
        ripple:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, main)
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

--// 🔔 NOTIFICATION SYSTEM
function Library:Notify(title, text, duration)
    local ScreenGui = CoreGui:FindFirstChild("MidoMaulUI") or LocalPlayer.PlayerGui:FindFirstChild("MidoMaulUI")
    if not ScreenGui then return end
    
    local NotifyContainer = ScreenGui:FindFirstChild("NotifyContainer") or Utility:Create("Frame", {
        Name = "NotifyContainer", Parent = ScreenGui, BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(0, 1)
    })
    if not NotifyContainer:FindFirstChild("Layout") then
        Utility:Create("UIListLayout", {Name="Layout", Parent = NotifyContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})
    end
    
    local Toast = Utility:Create("Frame", {
        Parent = NotifyContainer, BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, -- Auto Height
        BorderSizePixel = 0, ClipsDescendants = true,
    })
    Instance.new("UICorner", Toast).CornerRadius = Theme.CornerRadius
    
    local Content = Utility:Create("Frame", {
        Parent = Toast, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.Y 
    })
    Utility:Create("UIPadding", {Parent = Content, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
    Utility:Create("UIListLayout", {Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})

    Utility:Create("Frame", {Parent = Toast, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 3, 1, 0)}) -- Bar

    Utility:Create("TextLabel", {
        Parent = Content, Text = title, TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 14,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
    })
    
    Utility:Create("TextLabel", {
        Parent = Content, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain, TextSize = 12,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
    })
    
    -- Animate (Note: Tweening Size with AutomaticSize can be tricky, so we tween transparency/visible mostly)
    Toast.BackgroundTransparency = 1
    Utility:Tween(Toast, {BackgroundTransparency = 0}, 0.3)
    
    task.delay(duration or 3, function()
        Utility:Tween(Toast, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        Toast:Destroy()
    end)
end

--// 🚀 MAIN WINDOW
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    local ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "MidoMaulUI", Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local UIScale = Utility:Create("UIScale", {Parent = ScreenGui})
    task.spawn(function()
        while true do
            UIScale.Scale = (workspace.CurrentCamera.ViewportSize.Y < 600) and 1.15 or 1.0
            task.wait(1)
        end
    end)

    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -275, 0.5, -200), Size = UDim2.new(0, 550, 0, 400), BorderSizePixel = 0
    })
    Instance.new("UICorner", MainFrame).CornerRadius = Theme.CornerRadius

    -- Glow
    Utility:Create("ImageLabel", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, -30, 0, -30),
        Size = UDim2.new(1, 60, 1, 60), ZIndex = -1, Image = "rbxassetid://5028857472",
        ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.4, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276)
    })
    
    local Sidebar = Utility:Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Theme.Surface, Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0), BorderSizePixel = 0, ZIndex = 2
    })
    Instance.new("UICorner", Sidebar).CornerRadius = Theme.CornerRadius
    
    Utility:Create("TextLabel", {
        Parent = Sidebar, Text = Title, TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 18,
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 15, 0, 5),
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true -- Wrapped Title
    })

    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -70), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0
    })
    Utility:Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})

    local Pages = Utility:Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 160, 0, 10),
        Size = UDim2.new(1, -170, 1, -20), ClipsDescendants = true
    })

    Utility:MakeDraggable(Sidebar, MainFrame)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then MainFrame.Visible = not MainFrame.Visible end
    end)

    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:Tab(name)
        local TabBtn = Utility:Create("TextButton", {
            Parent = TabContainer, BackgroundColor3 = Theme.Background, BackgroundTransparency = 1,
            Text = "", Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, -- Auto Height Tab
            Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false
        })
        -- Min Height enforcement via padding
        Utility:Create("UIPadding", {Parent = TabBtn, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local TabLabel = Utility:Create("TextLabel", {
            Parent = TabBtn, Text = name, TextColor3 = Theme.TextSecondary, Font = Theme.FontMain, TextSize = 14,
            BackgroundTransparency = 1, Size = UDim2.new(1, -15, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
        })
        
        local Indicator = Utility:Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 2, 1, -10),
            Position = UDim2.new(0, 0, 0, 5), BackgroundTransparency = 1
        })

        local Page = Utility:Create("ScrollingFrame", {
            Parent = Pages, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false
        })
        local PageLayout = Utility:Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v.TextLabel, {TextColor3 = Theme.TextSecondary}, 0.2)
                    Utility:Tween(v.Frame, {BackgroundTransparency = 1}, 0.2)
                end
            end
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            Utility:Tween(TabLabel, {TextColor3 = Theme.TextPrimary}, 0.2)
            Utility:Tween(Indicator, {BackgroundTransparency = 0}, 0.2)
            Page.Visible = true
        end)
        
        if FirstTab then FirstTab = false; TabBtn.MouseButton1Click:Fire() end

        local Elements = {}

        --// ELEMENT: BUTTON
        function Elements:Button(text, callback)
            local Btn = Utility:Create("TextButton", {
                Parent = Page, BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, -- Auto Height
                AutoButtonColor = false, Text = ""
            })
            Utility:Create("UIPadding", {Parent = Btn, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            Instance.new("UICorner", Btn).CornerRadius = Theme.CornerRadius
            
            Utility:Create("TextLabel", {
                Parent = Btn, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain, TextSize = 14,
                BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            Btn.MouseButton1Click:Connect(function() Utility:AddRipple(Btn, Theme.Accent); pcall(callback) end)
        end

        --// ELEMENT: SECTION
        function Elements:Section(text)
            local Sec = Utility:Create("TextLabel", {
                Parent = Page, Text = string.upper(text), TextColor3 = Theme.TextSecondary, TextTransparency = 0.5,
                Font = Theme.FontBold, TextSize = 11, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            Utility:Create("UIPadding", {Parent=Sec, PaddingLeft=UDim.new(0,2), PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5)})
        end

        --// ELEMENT: TOGGLE
        function Elements:Toggle(text, default, callback)
            local State = default or false
            local Tgl = Utility:Create("TextButton", {
                Parent = Page, BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                AutoButtonColor = false, Text = ""
            })
            Utility:Create("UIPadding", {Parent = Tgl, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            Instance.new("UICorner", Tgl).CornerRadius = Theme.CornerRadius
            
            Utility:Create("TextLabel", {
                Parent = Tgl, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain, TextSize = 14,
                BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            local Switch = Utility:Create("Frame", {
                Parent = Tgl, BackgroundColor3 = State and Theme.Accent or Theme.Background,
                Size = UDim2.new(0, 40, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0.5, 0)
            })
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
            local Knob = Utility:Create("Frame", {
                Parent = Switch, BackgroundColor3 = State and Theme.TextPrimary or Theme.TextSecondary,
                Size = UDim2.new(0, 16, 0, 16), Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            })
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            
            Tgl.MouseButton1Click:Connect(function()
                State = not State
                Utility:AddRipple(Tgl, Theme.TextSecondary)
                Utility:Tween(Switch, {BackgroundColor3 = State and Theme.Accent or Theme.Background}, 0.3)
                Utility:Tween(Knob, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = State and Theme.TextPrimary or Theme.TextSecondary}, 0.3)
                pcall(callback, State)
            end)
        end

        --// ELEMENT: SLIDER
        function Elements:Slider(text, min, max, default, callback)
            local Value = default or min
            local Dragging = false
            
            local SliderFrame = Utility:Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            Utility:Create("UIPadding", {Parent = SliderFrame, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            Instance.new("UICorner", SliderFrame).CornerRadius = Theme.CornerRadius
            
            -- Header Container
            local Header = Utility:Create("Frame", {
                Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Utility:Create("TextLabel", {
                Parent = Header, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain, TextSize = 14,
                BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            local ValLabel = Utility:Create("TextLabel", {
                Parent = Header, Text = tostring(Value), TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 14,
                BackgroundTransparency = 1, Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -65, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right
            })

            -- Slider Track container (Separate from header to avoid overlap with wrapped text)
            local TrackContainer = Utility:Create("Frame", {
                Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), 
                Position = UDim2.new(0, 0, 0, 0), LayoutOrder = 2
            })
            -- Use UIListLayout to stack Header then Track
            Utility:Create("UIListLayout", {Parent = SliderFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            
            local Track = Utility:Create("TextButton", {
                Parent = TrackContainer, BackgroundColor3 = Theme.Background, Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0.5, -3), AutoButtonColor = false, Text = ""
            })
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            
            local Fill = Utility:Create("Frame", {Parent = Track, BackgroundColor3 = Theme.Accent, Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)})
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local function Update(input)
                local p = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                Value = math.floor(min + (max - min) * p)
                ValLabel.Text = tostring(Value)
                Utility:Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.05)
                pcall(callback, Value)
            end
            Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; Update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
        end
        
        --// ELEMENT: DROPDOWN
        function Elements:Dropdown(text, list, callback)
            local IsOpen = false
            local Selected = "None"
            
            local DropFrame = Utility:Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true
            })
            Instance.new("UICorner", DropFrame).CornerRadius = Theme.CornerRadius
            
            local Header = Utility:Create("TextButton", {
                Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Text = "", AutoButtonColor = false
            })
            Utility:Create("UIPadding", {Parent = Header, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            
            local Title = Utility:Create("TextLabel", {
                Parent = Header, Text = text .. ": " .. Selected, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain,
                TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            local Icon = Utility:Create("ImageLabel", {
                Parent = Header, BackgroundTransparency = 1, Image = "rbxassetid://6031090990",
                Size = UDim2.new(0, 20, 0, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0.5, 0)
            })
            
            local ItemContainer = Utility:Create("Frame", {
                Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Visible = false,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Utility:Create("UIPadding", {Parent = ItemContainer, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10)})
            Utility:Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            
            -- Layout to stack Header and Items
            Utility:Create("UIListLayout", {Parent = DropFrame, SortOrder = Enum.SortOrder.LayoutOrder})

            Header.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                ItemContainer.Visible = IsOpen
                Utility:Tween(Icon, {Rotation = IsOpen and 180 or 0}, 0.3)
                
                -- Refresh items if opening
                if IsOpen then
                    for _, v in pairs(ItemContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, item in pairs(list) do
                        local ItemBtn = Utility:Create("TextButton", {
                            Parent = ItemContainer, BackgroundColor3 = Theme.Background, Size = UDim2.new(1, -20, 0, 35),
                            Position = UDim2.new(0, 10, 0, 0), Text = item, TextColor3 = Theme.TextSecondary,
                            Font = Theme.FontMain, TextSize = 13
                        })
                        Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 6)
                        ItemBtn.MouseButton1Click:Connect(function()
                            Selected = item
                            Title.Text = text .. ": " .. Selected
                            Utility:AddRipple(ItemBtn, Theme.Accent)
                            pcall(callback, item)
                            IsOpen = false
                            ItemContainer.Visible = false
                            Utility:Tween(Icon, {Rotation = 0}, 0.3)
                        end)
                    end
                end
            end)
        end
        
        --// ELEMENT: INPUT
        function Elements:Input(text, placeholder, callback)
            local InputFrame = Utility:Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            Utility:Create("UIPadding", {Parent = InputFrame, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            Instance.new("UICorner", InputFrame).CornerRadius = Theme.CornerRadius
            
            Utility:Create("UIListLayout", {Parent = InputFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            
            Utility:Create("TextLabel", {
                Parent = InputFrame, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain,
                TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            local BoxContainer = Utility:Create("Frame", {
                Parent = InputFrame, BackgroundColor3 = Theme.Background, Size = UDim2.new(1, -30, 0, 30),
                Position = UDim2.new(0, 15, 0, 0)
            })
            Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 4)
            
            local Box = Utility:Create("TextBox", {
                Parent = BoxContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0), Text = "", PlaceholderText = placeholder or "...",
                TextColor3 = Theme.TextSecondary, Font = Theme.FontMain, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            Box.FocusLost:Connect(function() pcall(callback, Box.Text); Utility:Tween(BoxContainer, {BackgroundColor3 = Theme.Background}, 0.2) end)
            Box.Focused:Connect(function() Utility:Tween(BoxContainer, {BackgroundColor3 = Color3.fromRGB(40,40,55)}, 0.2) end)
        end
        
        --// ELEMENT: KEYBIND
        function Elements:Keybind(text, defaultKey, callback)
            local Key = defaultKey or Enum.KeyCode.RightControl
            local Binding = false
            
            local BindFrame = Utility:Create("Frame", {
                Parent = Page, BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            Utility:Create("UIPadding", {Parent = BindFrame, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            Instance.new("UICorner", BindFrame).CornerRadius = Theme.CornerRadius
            
            local Label = Utility:Create("TextLabel", {
                Parent = BindFrame, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain,
                TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -100, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
            })
            
            local BindBtn = Utility:Create("TextButton", {
                Parent = BindFrame, BackgroundColor3 = Theme.Background, Size = UDim2.new(0, 80, 0, 24),
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0.5, 0),
                Text = Key.Name, TextColor3 = Theme.TextSecondary, Font = Theme.FontBold, TextSize = 12
            })
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
            
            BindBtn.MouseButton1Click:Connect(function() Binding = true; BindBtn.Text = "..."; BindBtn.TextColor3 = Theme.Accent end)
            UserInputService.InputBegan:Connect(function(input)
                if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    Binding = false; Key = input.KeyCode; BindBtn.Text = Key.Name; BindBtn.TextColor3 = Theme.TextSecondary; pcall(callback, Key)
                end
            end)
        end

        return Elements
    end
    return WindowFuncs
end
return Library

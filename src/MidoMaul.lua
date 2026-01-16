--[[
    MIDOMAUL // FUTURISTIC CONTROL SURFACE
    Version: 1.0.0 (Flagship)
    Author: [AI Architect]
    License: MIT

    "Power should feel effortless."
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
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 80, 80),
    
    FontMain = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    
    CornerRadius = UDim.new(0, 12), -- Soft, modern corners
    AnimationSpeed = 0.4, -- Fluid, not instant
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

function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or Theme.AnimationSpeed, 
        style or Enum.EasingStyle.Quart, 
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:AddRipple(button, color)
    task.spawn(function()
        local ripple = Utility:Create("Frame", {
            Name = "Ripple",
            Parent = button,
            BackgroundColor3 = color or Theme.TextPrimary,
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), -- Simplified for mobile performance
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 10,
        })
        
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1, 0)
        
        -- Expand logic
        local targetSize = UDim2.new(2, 0, 2, 0) -- Overshoot to cover
        Utility:Tween(ripple, {Size = targetSize, BackgroundTransparency = 1}, 0.6)
        
        task.wait(0.6)
        ripple:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Utility:Tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1) -- Smooth drag
        end
    end)
end

--// 🚀 CORE LIBRARY
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    
    -- Main GUI
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "MidoMaulUI",
        Parent = CoreGui, -- Change to LocalPlayer.PlayerGui for regular games
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Dynamic Scaling (Mobile First Logic)
    local ScaleObj = Utility:Create("UIScale", {Parent = ScreenGui})
    
    -- Listener for screen size to adjust scale
    local function UpdateScale()
        local viewport = workspace.CurrentCamera.ViewportSize
        if viewport.Y < 600 then -- Mobile
            ScaleObj.Scale = 1.1 -- Slightly larger for fingers
        else
            ScaleObj.Scale = 1.0 -- Standard PC
        end
    end
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
    UpdateScale()

    -- Main Container (The Surface)
    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -250, 0.5, -175),
        Size = UDim2.new(0, 500, 0, 380),
        BorderSizePixel = 0,
        ClipsDescendants = false, -- Allow shadows/glows to escape
    })
    
    Instance.new("UICorner", MainFrame).CornerRadius = Theme.CornerRadius

    -- Soft Glow (Futuristic Touch)
    local Glow = Utility:Create("ImageLabel", {
        Name = "GlowShadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -30, 0, -30),
        Size = UDim2.new(1, 60, 1, 60),
        ZIndex = -1,
        Image = "rbxassetid://5028857472", -- Soft gradient blob
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276)
    })
    
    -- Accent Line (Top)
    local TopAccent = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
    })
    Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0, 2)

    -- Sidebar (Navigation)
    local Sidebar = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 140, 1, -2),
        BorderSizePixel = 0,
    })
    local SideCorner = Instance.new("UICorner", Sidebar)
    SideCorner.CornerRadius = Theme.CornerRadius
    
    -- Fix corner overlap
    local HideCorner = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 1
    })

    -- Title
    local TitleLabel = Utility:Create("TextLabel", {
        Parent = Sidebar,
        Text = string.upper(Title),
        TextColor3 = Theme.Accent,
        Font = Theme.FontBold,
        TextSize = 16,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Tab Container
    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -70),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 0,
    })
    
    local TabListLayout = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    -- Pages Container
    local Pages = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 10),
        Size = UDim2.new(1, -160, 1, -20),
        ClipsDescendants = true,
    })

    Utility:MakeDraggable(Sidebar, MainFrame)

    local WindowFunctions = {}
    local FirstTab = true

    function WindowFunctions:Tab(name, iconId)
        -- Tab Button
        local TabBtn = Utility:Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, -20, 0, 36), -- Big touch target
            Position = UDim2.new(0, 10, 0, 0),
            AutoButtonColor = false,
        })
        
        local TabCorner = Instance.new("UICorner", TabBtn)
        TabCorner.CornerRadius = UDim.new(0, 8)
        
        local TabLabel = Utility:Create("TextLabel", {
            Parent = TabBtn,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            Font = Theme.FontMain,
            TextSize = 14,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        -- Active Indicator (Futuristic vertical bar)
        local Indicator = Utility:Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundTransparency = 1, -- Hidden by default
            BorderSizePixel = 0,
        })
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1,0)

        -- Page Frame
        local Page = Utility:Create("ScrollingFrame", {
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
        })
        
        local PageLayout = Utility:Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
        })
        
        -- Adjust Canvas Size automatically
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Logic
        local function Activate()
            -- Deactivate others
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    Utility:Tween(child.TextLabel, {TextColor3 = Theme.TextSecondary}, 0.3)
                    Utility:Tween(child, {BackgroundTransparency = 1}, 0.3)
                    Utility:Tween(child.Frame, {BackgroundTransparency = 1}, 0.3) -- Hide indicator
                end
            end
            for _, child in pairs(Pages:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            
            -- Activate Self
            Utility:Tween(TabLabel, {TextColor3 = Theme.TextPrimary}, 0.3)
            Utility:Tween(TabBtn, {BackgroundTransparency = 0.9}, 0.3)
            Utility:Tween(Indicator, {BackgroundTransparency = 0}, 0.3)
            
            Page.Visible = true
            -- Subtle entry animation
            Page.CanvasPosition = Vector2.new(0,0)
            Page.Position = UDim2.new(0, 10, 0, 0)
            Utility:Tween(Page, {Position = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back)
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            FirstTab = false
            Activate()
        end
        
        local TabFunctions = {}
        
        --// COMPONENT: Section
        function TabFunctions:Section(text)
            local SectionLabel = Utility:Create("TextLabel", {
                Parent = Page,
                Text = string.upper(text),
                TextColor3 = Theme.TextSecondary,
                TextTransparency = 0.5,
                Font = Theme.FontBold,
                TextSize = 11,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Utility:Create("UIPadding", {Parent = SectionLabel, PaddingLeft = UDim.new(0, 5)})
        end

        --// COMPONENT: Button
        function TabFunctions:Button(text, callback)
            callback = callback or function() end
            
            local BtnFrame = Utility:Create("TextButton", {
                Parent = Page,
                BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 42),
                AutoButtonColor = false,
                Text = "",
            })
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 8)
            
            local BtnTitle = Utility:Create("TextLabel", {
                Parent = BtnFrame,
                Text = text,
                TextColor3 = Theme.TextPrimary,
                Font = Theme.FontMain,
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            -- Button Events
            BtnFrame.MouseButton1Click:Connect(function()
                Utility:AddRipple(BtnFrame, Theme.Accent)
                callback()
            end)
            
            BtnFrame.MouseEnter:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.2)
            end)
            
            BtnFrame.MouseLeave:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = Theme.Surface}, 0.2)
            end)
        end

        --// COMPONENT: Toggle
        function TabFunctions:Toggle(text, default, callback)
            callback = callback or function() end
            local State = default or false
            
            local ToggleFrame = Utility:Create("TextButton", {
                Parent = Page,
                BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 42),
                AutoButtonColor = false,
                Text = "",
            })
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
            
            local Title = Utility:Create("TextLabel", {
                Parent = ToggleFrame,
                Text = text,
                TextColor3 = Theme.TextPrimary,
                Font = Theme.FontMain,
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            -- The Switch (Track)
            local SwitchBg = Utility:Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -55, 0.5, -10),
            })
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
            
            -- The Knob
            local Knob = Utility:Create("Frame", {
                Parent = SwitchBg,
                BackgroundColor3 = Theme.TextSecondary,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0.5, -8),
            })
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            
            local function Update()
                if State then
                    Utility:Tween(SwitchBg, {BackgroundColor3 = Theme.Accent}, 0.3)
                    Utility:Tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.TextPrimary}, 0.3)
                else
                    Utility:Tween(SwitchBg, {BackgroundColor3 = Theme.Background}, 0.3)
                    Utility:Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextSecondary}, 0.3)
                end
                callback(State)
            end
            
            ToggleFrame.MouseButton1Click:Connect(function()
                State = not State
                Utility:AddRipple(ToggleFrame, Theme.TextSecondary)
                Update()
            end)
            
            Update()
        end

        --// COMPONENT: Slider
        function TabFunctions:Slider(text, min, max, default, callback)
            callback = callback or function() end
            local Value = default or min
            local Dragging = false
            
            local SliderFrame = Utility:Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(1, -4, 0, 60), -- Taller for easier touch
            })
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
            
            local Title = Utility:Create("TextLabel", {
                Parent = SliderFrame,
                Text = text,
                TextColor3 = Theme.TextPrimary,
                Font = Theme.FontMain,
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 15, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ValueLabel = Utility:Create("TextLabel", {
                Parent = SliderFrame,
                Text = tostring(Value),
                TextColor3 = Theme.Accent,
                Font = Theme.FontBold,
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 50, 0, 30),
                Position = UDim2.new(1, -65, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
            })
            
            local Track = Utility:Create("TextButton", { -- Button for hit detection
                Parent = SliderFrame,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 40),
                AutoButtonColor = false,
                Text = ""
            })
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            
            local Fill = Utility:Create("Frame", {
                Parent = Track,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new(0, 0, 1, 0),
            })
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            -- Glow Effect on Fill
            local Glow = Utility:Create("ImageLabel", {
                Parent = Fill,
                BackgroundTransparency = 1,
                Image = "rbxassetid://5028857472",
                ImageColor3 = Theme.Accent,
                Size = UDim2.new(1, 20, 1, 20),
                Position = UDim2.new(0, -10, 0, -10),
                ImageTransparency = 0.5,
                ZIndex = 0
            })

            local function Update(input)
                local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(min + (max - min) * percent)
                
                Value = newValue
                ValueLabel.Text = tostring(Value)
                Utility:Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                callback(Value)
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            -- Init
            local startPercent = (Value - min) / (max - min)
            Fill.Size = UDim2.new(startPercent, 0, 1, 0)
        end
        
        return TabFunctions
    end
    
    return WindowFunctions
end

return Library
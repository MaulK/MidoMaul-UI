--[[ 
    -------------------------------------------------------
    PART 1: THE UI LIBRARY (MidoMaul Control Surface)
    -------------------------------------------------------
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
    CornerRadius = UDim.new(0, 12),
    AnimationSpeed = 0.4,
}

--// 🛠️ UTILITY ENGINE
local Library = {}
local Utility = {}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do instance[k] = v end
    return instance
end

function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or Theme.AnimationSpeed, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:AddRipple(button, color)
    task.spawn(function()
        local ripple = Utility:Create("Frame", {
            Name = "Ripple", Parent = button, BackgroundColor3 = color or Theme.TextPrimary,
            BackgroundTransparency = 0.8, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0), ZIndex = 10,
        })
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1, 0)
        Utility:Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.6)
        task.wait(0.6) ripple:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Utility:Tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

--// 🚀 CORE LIBRARY
function Library:Window(options)
    local Title = options.Title or "MidoMaul"
    local ScreenGui = Utility:Create("ScreenGui", { Name = "MidoMaulUI", Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    
    local ScaleObj = Utility:Create("UIScale", {Parent = ScreenGui})
    local function UpdateScale()
        if workspace.CurrentCamera.ViewportSize.Y < 600 then ScaleObj.Scale = 1.1 else ScaleObj.Scale = 1.0 end
    end
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale); UpdateScale()

    local MainFrame = Utility:Create("Frame", { Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Theme.Background, Position = UDim2.new(0.5, -250, 0.5, -175), Size = UDim2.new(0, 500, 0, 380), BorderSizePixel = 0 })
    Instance.new("UICorner", MainFrame).CornerRadius = Theme.CornerRadius
    
    -- Aesthetics
    Utility:Create("ImageLabel", { Name = "GlowShadow", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, -30, 0, -30), Size = UDim2.new(1, 60, 1, 60), ZIndex = -1, Image = "rbxassetid://5028857472", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.4, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276) })
    local TopAccent = Utility:Create("Frame", { Parent = MainFrame, BackgroundColor3 = Theme.Accent, Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0 }); Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0, 2)
    local Sidebar = Utility:Create("Frame", { Parent = MainFrame, BackgroundColor3 = Theme.Surface, Position = UDim2.new(0, 0, 0, 2), Size = UDim2.new(0, 140, 1, -2), BorderSizePixel = 0 }); Instance.new("UICorner", Sidebar).CornerRadius = Theme.CornerRadius
    Utility:Create("Frame", { Parent = Sidebar, BackgroundColor3 = Theme.Surface, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0, ZIndex = 1 })
    Utility:Create("TextLabel", { Parent = Sidebar, Text = string.upper(Title), TextColor3 = Theme.Accent, Font = Theme.FontBold, TextSize = 16, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left })
    
    local TabContainer = Utility:Create("ScrollingFrame", { Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -70), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0 })
    Utility:Create("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
    local Pages = Utility:Create("Frame", { Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 150, 0, 10), Size = UDim2.new(1, -160, 1, -20), ClipsDescendants = true })
    
    Utility:MakeDraggable(Sidebar, MainFrame)
    local WindowFunctions = {}; local FirstTab = true

    function WindowFunctions:Tab(name)
        local TabBtn = Utility:Create("TextButton", { Parent = TabContainer, BackgroundColor3 = Theme.Background, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, -20, 0, 36), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false })
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
        local TabLabel = Utility:Create("TextLabel", { Parent = TabBtn, Text = name, TextColor3 = Theme.TextSecondary, Font = Theme.FontMain, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left })
        local Indicator = Utility:Create("Frame", { Parent = TabBtn, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 0, 0.2, 0), BackgroundTransparency = 1, BorderSizePixel = 0 }); Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1,0)
        
        local Page = Utility:Create("ScrollingFrame", { Parent = Pages, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false })
        local PageLayout = Utility:Create("UIListLayout", { Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20) end)

        local function Activate()
            for _, child in pairs(TabContainer:GetChildren()) do if child:IsA("TextButton") then Utility:Tween(child.TextLabel, {TextColor3 = Theme.TextSecondary}, 0.3); Utility:Tween(child, {BackgroundTransparency = 1}, 0.3); Utility:Tween(child.Frame, {BackgroundTransparency = 1}, 0.3) end end
            for _, child in pairs(Pages:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
            Utility:Tween(TabLabel, {TextColor3 = Theme.TextPrimary}, 0.3); Utility:Tween(TabBtn, {BackgroundTransparency = 0.9}, 0.3); Utility:Tween(Indicator, {BackgroundTransparency = 0}, 0.3)
            Page.Visible = true; Page.CanvasPosition = Vector2.new(0,0); Page.Position = UDim2.new(0, 10, 0, 0); Utility:Tween(Page, {Position = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back)
        end
        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false; Activate() end
        
        local TabFunctions = {}
        function TabFunctions:Section(text)
            local SectionLabel = Utility:Create("TextLabel", { Parent = Page, Text = string.upper(text), TextColor3 = Theme.TextSecondary, TextTransparency = 0.5, Font = Theme.FontBold, TextSize = 11, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left })
            Utility:Create("UIPadding", {Parent = SectionLabel, PaddingLeft = UDim.new(0, 5)})
        end
        function TabFunctions:Button(text, callback)
            local BtnFrame = Utility:Create("TextButton", { Parent = Page, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, -4, 0, 42), AutoButtonColor = false, Text = "" })
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 8)
            Utility:Create("TextLabel", { Parent = BtnFrame, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left })
            BtnFrame.MouseButton1Click:Connect(function() Utility:AddRipple(BtnFrame, Theme.Accent); callback() end)
            BtnFrame.MouseEnter:Connect(function() Utility:Tween(BtnFrame, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.2) end)
            BtnFrame.MouseLeave:Connect(function() Utility:Tween(BtnFrame, {BackgroundColor3 = Theme.Surface}, 0.2) end)
        end
        function TabFunctions:Toggle(text, default, callback)
            local State = default or false; local ToggleFrame = Utility:Create("TextButton", { Parent = Page, BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, -4, 0, 42), AutoButtonColor = false, Text = "" }); Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
            Utility:Create("TextLabel", { Parent = ToggleFrame, Text = text, TextColor3 = Theme.TextPrimary, Font = Theme.FontMain, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left })
            local SwitchBg = Utility:Create("Frame", { Parent = ToggleFrame, BackgroundColor3 = Theme.Background, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -55, 0.5, -10) }); Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
            local Knob = Utility:Create("Frame", { Parent = SwitchBg, BackgroundColor3 = Theme.TextSecondary, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8) }); Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            local function Update()
                if State then Utility:Tween(SwitchBg, {BackgroundColor3 = Theme.Accent}, 0.3); Utility:Tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.TextPrimary}, 0.3)
                else Utility:Tween(SwitchBg, {BackgroundColor3 = Theme.Background}, 0.3); Utility:Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextSecondary}, 0.3) end
                callback(State)
            end
            ToggleFrame.MouseButton1Click:Connect(function() State = not State; Utility:AddRipple(ToggleFrame, Theme.TextSecondary); Update() end); Update()
        end
        return TabFunctions
    end
    return WindowFunctions
end

--[[ 
    -------------------------------------------------------
    PART 2: GAME LOGIC
    -------------------------------------------------------
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerName = LocalPlayer.Name

-- // REMOTES // --
local RemoteEvent = ReplicatedStorage:WaitForChild("Msg"):WaitForChild("RemoteEvent")
local RemoteFunc = ReplicatedStorage:WaitForChild("Msg"):WaitForChild("RemoteFunction")

-- // STRINGS // --
local STR_COLLECT = "领取动物赚的钱" -- Claim Money
local STR_BUY = "购买魔法药水"      -- Buy Magic Potion
local STR_UPGRADE = "检查农场升级"  -- Check Farm Upgrade

-- // CONFIGURATION // --
getgenv().FarmConfig = {
    AutoCollect = false,
    AutoUpgrade = false,
    AutoBuy = false,
    SelectedPotions = { -- true = selected, false = ignored
        [15000001] = false, -- Size
        [15000002] = false, -- Rebirth
        [15000003] = false, -- Enchant
    }
}

-- // LOGIC FUNCTIONS // --

-- 1. Auto Collect (Smart Path)
local function runAutoCollect()
    while getgenv().FarmConfig.AutoCollect do
        pcall(function()
            local battleScene = Workspace:FindFirstChild("战斗场景")
            if battleScene then
                local playerFolder = battleScene:FindFirstChild(PlayerName)
                if playerFolder then
                    local heros = playerFolder:FindFirstChild("HerosFolder")
                    if heros then
                        for _, animal in ipairs(heros:GetChildren()) do
                            local id = tonumber(animal.Name)
                            if id then
                                RemoteEvent:FireServer(STR_COLLECT, id)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end

-- 2. Auto Buy (Checks Value > 0)
local function runAutoBuy()
    local magicShop = LocalPlayer:WaitForChild("MagicShop", 5)
    if not magicShop then return end

    while getgenv().FarmConfig.AutoBuy do
        for itemId, isSelected in pairs(getgenv().FarmConfig.SelectedPotions) do
            if isSelected and getgenv().FarmConfig.AutoBuy then
                -- Check the Value in MagicShop
                local itemValueObj = magicShop:FindFirstChild(tostring(itemId))
                
                -- ONLY Buy if Value > 0
                if itemValueObj and itemValueObj.Value > 0 then
                    pcall(function()
                        RemoteFunc:InvokeServer(STR_BUY, {itemId, 1})
                    end)
                end
            end
        end
        task.wait(0.25) -- Cycle speed
    end
end

-- 3. Auto Upgrade
local function runAutoUpgrade()
    while getgenv().FarmConfig.AutoUpgrade do
        pcall(function()
            RemoteEvent:FireServer(STR_UPGRADE)
        end)
        task.wait(2)
    end
end

--[[ 
    -------------------------------------------------------
    PART 3: UI IMPLEMENTATION
    -------------------------------------------------------
]]

local Window = Library:Window({ Title = "MidoMaul Farming" })
local MainTab = Window:Tab("Main")

MainTab:Section("Automation")

MainTab:Toggle("Auto Collect Money", false, function(state)
    getgenv().FarmConfig.AutoCollect = state
    if state then task.spawn(runAutoCollect) end
end)

MainTab:Toggle("Auto Upgrade Farm", false, function(state)
    getgenv().FarmConfig.AutoUpgrade = state
    if state then task.spawn(runAutoUpgrade) end
end)

local ShopTab = Window:Tab("Shop")

ShopTab:Section("Magic Shop Settings")
ShopTab:Toggle("Master Switch: Auto Buy", false, function(state)
    getgenv().FarmConfig.AutoBuy = state
    if state then task.spawn(runAutoBuy) end
end)

ShopTab:Section("Select Potions To Buy")

-- Toggles for Potions (Replaces Dropdown)
ShopTab:Toggle("Size Potion (15000001)", false, function(state)
    getgenv().FarmConfig.SelectedPotions[15000001] = state
end)

ShopTab:Toggle("Rebirth Potion (15000002)", false, function(state)
    getgenv().FarmConfig.SelectedPotions[15000002] = state
end)

ShopTab:Toggle("Enchant Potion (15000003)", false, function(state)
    getgenv().FarmConfig.SelectedPotions[15000003] = state
end)

local CreditTab = Window:Tab("Info")
CreditTab:Section("Credits")
CreditTab:Button("UI by MidoMaul", function() end)

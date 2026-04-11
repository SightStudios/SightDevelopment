--[[
    ╔═══════════════════════════════════════════════════════╗
    ║                  SIGHT GUI LIBRARY                    ║
    ║           Premium Glassmorphism UI Framework          ║
    ║                    v2.0.0 RELEASE                     ║
    ╚═══════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local sight = {}
sight.__index = sight
sight.Windows = {}
sight.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
sight.Version = "2.0.0"

local Themes = {
    Dark = {
        Background       = Color3.fromRGB(12, 12, 14),
        Surface          = Color3.fromRGB(20, 20, 24),
        SurfaceAlt       = Color3.fromRGB(28, 28, 34),
        Border           = Color3.fromRGB(45, 45, 55),
        BorderGlow       = Color3.fromRGB(60, 60, 75),
        Text             = Color3.fromRGB(240, 240, 245),
        SubText          = Color3.fromRGB(130, 130, 150),
        Muted            = Color3.fromRGB(70, 70, 85),
        Danger           = Color3.fromRGB(220, 70, 70),
        Success          = Color3.fromRGB(70, 200, 120),
    },
    Midnight = {
        Background       = Color3.fromRGB(8, 8, 18),
        Surface          = Color3.fromRGB(14, 14, 28),
        SurfaceAlt       = Color3.fromRGB(20, 20, 38),
        Border           = Color3.fromRGB(35, 35, 65),
        BorderGlow       = Color3.fromRGB(50, 50, 90),
        Text             = Color3.fromRGB(230, 230, 255),
        SubText          = Color3.fromRGB(110, 110, 160),
        Muted            = Color3.fromRGB(55, 55, 90),
        Danger           = Color3.fromRGB(220, 70, 70),
        Success          = Color3.fromRGB(70, 200, 120),
    },
    Frost = {
        Background       = Color3.fromRGB(22, 28, 38),
        Surface          = Color3.fromRGB(30, 38, 52),
        SurfaceAlt       = Color3.fromRGB(38, 48, 64),
        Border           = Color3.fromRGB(55, 70, 95),
        BorderGlow       = Color3.fromRGB(75, 95, 125),
        Text             = Color3.fromRGB(225, 235, 250),
        SubText          = Color3.fromRGB(120, 140, 175),
        Muted            = Color3.fromRGB(60, 75, 100),
        Danger           = Color3.fromRGB(220, 80, 80),
        Success          = Color3.fromRGB(80, 200, 130),
    },
}

local AccentPresets = {
    Cyan    = Color3.fromRGB(0, 200, 255),
    Purple  = Color3.fromRGB(150, 80, 255),
    Pink    = Color3.fromRGB(255, 80, 180),
    Emerald = Color3.fromRGB(0, 210, 140),
    Orange  = Color3.fromRGB(255, 140, 40),
    Red     = Color3.fromRGB(255, 60, 60),
    Gold    = Color3.fromRGB(255, 200, 50),
}

local ActiveTheme = Themes.Dark
local ActiveAccent = AccentPresets.Cyan

local TI = {
    Fast     = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Medium   = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow     = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Spring   = TweenInfo.new(0.28, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    Bounce   = TweenInfo.new(0.30, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
}

local function tween(instance, info, props)
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(thickness, color, transparency, parent)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness
    s.Color = color or ActiveTheme.Border
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function padding(top, bottom, left, right, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left or 0)
    p.PaddingRight  = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

local function listLayout(dir, align, padding_, parent)
    local l = Instance.new("UIListLayout")
    l.FillDirection     = dir or Enum.FillDirection.Vertical
    l.SortOrder         = Enum.SortOrder.LayoutOrder
    l.Padding           = UDim.new(0, padding_ or 0)
    if align then l.HorizontalAlignment = align end
    l.Parent = parent
    return l
end

local function shadow(frame, size, trans)
    local s = new("ImageLabel", {
        Name               = "Shadow",
        Image              = "rbxassetid://6014261993",
        ImageTransparency  = trans or 0.55,
        ScaleType          = Enum.ScaleType.Slice,
        SliceCenter        = Rect.new(49, 49, 49, 49),
        Size               = UDim2.new(1, size or 24, 1, size or 24),
        Position           = UDim2.new(0, -(size or 24)/2, 0, -(size or 24)/2),
        BackgroundTransparency = 1,
        ZIndex             = frame.ZIndex - 1,
    }, frame)
    return s
end

local function glowStroke(parent, accent)
    local s = Instance.new("UIStroke")
    s.Thickness    = 1
    s.Color        = accent or ActiveAccent
    s.Transparency = 0.6
    s.Parent       = parent
    return s
end

local function makeDraggable(frame, handle)
    local dragging   = false
    local dragStart  = nil
    local startPos   = nil
    local conn1, conn2

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    conn2 = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local vp    = workspace.CurrentCamera.ViewportSize
            local newX  = math.clamp(startPos.X.Offset + delta.X, 0, vp.X - frame.AbsoluteSize.X)
            local newY  = math.clamp(startPos.Y.Offset + delta.Y, 0, vp.Y - frame.AbsoluteSize.Y)
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    return function()
        if conn2 then conn2:Disconnect() end
    end
end

local function autoSize(frame, list)
    list.Changed:Connect(function(prop)
        if prop == "AbsoluteContentSize" then
            frame.Size = UDim2.new(
                frame.Size.X.Scale,
                frame.Size.X.Offset,
                0,
                list.AbsoluteContentSize.Y + 14
            )
        end
    end)
end

local function saveConfig(name, data)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then return false end
    local key = "sight_config_" .. name
    local success = pcall(function()
        writefile(key .. ".json", encoded)
    end)
    return success
end

local function loadConfig(name)
    local key = "sight_config_" .. name .. ".json"
    local ok, content = pcall(readfile, key)
    if not ok then return nil end
    local success, data = pcall(HttpService.JSONDecode, HttpService, content)
    if success then return data end
    return nil
end

function sight.CreateWindow(config)
    config = config or {}

    local scale        = sight.IsMobile and 0.78 or 1.0
    local winW         = math.clamp(580 * scale, 300, 700)
    local winH         = math.clamp(430 * scale, 260, 500)
    local navW         = 130 * scale

    local screenGui = new("ScreenGui", {
        Name              = "SightUI_" .. (config.Title or "Window"),
        ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn      = false,
        DisplayOrder      = 100,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local overlay = new("Frame", {
        Name                  = "LicenseOverlay",
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundColor3      = Color3.fromRGB(5, 5, 8),
        BackgroundTransparency = 0.1,
        BorderSizePixel       = 0,
        ZIndex                = 500,
    }, screenGui)

    local licenseCard = new("Frame", {
        Name                  = "LicenseCard",
        Size                  = UDim2.new(0, 340 * scale, 0, 300 * scale),
        Position              = UDim2.new(0.5, -170 * scale, 0.5, -150 * scale),
        BackgroundColor3      = ActiveTheme.Surface,
        BorderSizePixel       = 0,
        ZIndex                = 501,
    }, overlay)
    corner(10, licenseCard)
    stroke(1, ActiveTheme.Border, 0, licenseCard)
    shadow(licenseCard, 30, 0.4)

    local accentBar = new("Frame", {
        Size                  = UDim2.new(1, 0, 0, 3),
        Position              = UDim2.new(0, 0, 0, 0),
        BackgroundColor3      = ActiveAccent,
        BorderSizePixel       = 0,
        ZIndex                = 502,
    }, licenseCard)
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 3)
        c.Parent = accentBar
    end

    padding(28 * scale, 24 * scale, 28 * scale, 28 * scale, licenseCard)

    local licenseList = listLayout(nil, nil, 14 * scale, licenseCard)

    local lcIcon = new("TextLabel", {
        Text                  = "◈",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 28 * scale,
        TextColor3            = ActiveAccent,
        Size                  = UDim2.new(1, 0, 0, 34 * scale),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Center,
        ZIndex                = 502,
        LayoutOrder           = 1,
    }, licenseCard)

    local lcTitle = new("TextLabel", {
        Text                  = config.Title or "SIGHT",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 20 * scale,
        TextColor3            = ActiveTheme.Text,
        Size                  = UDim2.new(1, 0, 0, 26 * scale),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Center,
        ZIndex                = 502,
        LayoutOrder           = 2,
    }, licenseCard)

    local lcSub = new("TextLabel", {
        Text                  = "Enter your license key to continue",
        Font                  = Enum.Font.Gotham,
        TextSize              = 11 * scale,
        TextColor3            = ActiveTheme.SubText,
        Size                  = UDim2.new(1, 0, 0, 16 * scale),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Center,
        ZIndex                = 502,
        LayoutOrder           = 3,
    }, licenseCard)

    local inputWrap = new("Frame", {
        Size                  = UDim2.new(1, 0, 0, 40 * scale),
        BackgroundColor3      = ActiveTheme.SurfaceAlt,
        BorderSizePixel       = 0,
        ZIndex                = 502,
        LayoutOrder           = 4,
    }, licenseCard)
    corner(7, inputWrap)
    local inputStroke = stroke(1, ActiveTheme.Border, 0, inputWrap)

    local keyInput = new("TextBox", {
        PlaceholderText       = "SIGHT-XXXX-XXXX-XXXX-XXXX",
        Text                  = "",
        Font                  = Enum.Font.Code,
        TextSize              = 12 * scale,
        TextColor3            = ActiveTheme.Text,
        PlaceholderColor3     = ActiveTheme.Muted,
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus      = false,
        ZIndex                = 503,
    }, inputWrap)
    padding(0, 0, 12 * scale, 12 * scale, keyInput)

    keyInput.Focused:Connect(function()
        tween(inputStroke, TI.Fast, {Color = ActiveAccent, Transparency = 0.3})
    end)
    keyInput.FocusLost:Connect(function()
        tween(inputStroke, TI.Fast, {Color = ActiveTheme.Border, Transparency = 0})
    end)

    local rememberFrame = new("Frame", {
        Size                  = UDim2.new(1, 0, 0, 22 * scale),
        BackgroundTransparency = 1,
        ZIndex                = 502,
        LayoutOrder           = 5,
    }, licenseCard)
    local rememberLabel = new("TextLabel", {
        Text                  = "Remember Me",
        Font                  = Enum.Font.Gotham,
        TextSize              = 11 * scale,
        TextColor3            = ActiveTheme.SubText,
        Size                  = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 502,
    }, rememberFrame)

    local remToggleBG = new("TextButton", {
        Text                  = "",
        Size                  = UDim2.new(0, 36 * scale, 0, 18 * scale),
        Position              = UDim2.new(1, -36 * scale, 0.5, -9 * scale),
        BackgroundColor3      = ActiveTheme.SurfaceAlt,
        BorderSizePixel       = 0,
        ZIndex                = 503,
    }, rememberFrame)
    corner(9 * scale, remToggleBG)
    stroke(1, ActiveTheme.Border, 0, remToggleBG)
    local remKnob = new("Frame", {
        Size                  = UDim2.new(0, 12 * scale, 0, 12 * scale),
        Position              = UDim2.new(0, 3 * scale, 0.5, -6 * scale),
        BackgroundColor3      = ActiveTheme.SubText,
        BorderSizePixel       = 0,
        ZIndex                = 504,
    }, remToggleBG)
    corner(6 * scale, remKnob)

    local rememberOn = false
    remToggleBG.MouseButton1Click:Connect(function()
        rememberOn = not rememberOn
        if rememberOn then
            tween(remToggleBG, TI.Fast, {BackgroundColor3 = ActiveAccent})
            tween(remKnob, TI.Fast, {Position = UDim2.new(1, -15 * scale, 0.5, -6 * scale), BackgroundColor3 = Color3.new(1,1,1)})
        else
            tween(remToggleBG, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt})
            tween(remKnob, TI.Fast, {Position = UDim2.new(0, 3 * scale, 0.5, -6 * scale), BackgroundColor3 = ActiveTheme.SubText})
        end
    end)

    local loginBtn = new("TextButton", {
        Text                  = "Authenticate",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13 * scale,
        TextColor3            = Color3.new(1, 1, 1),
        Size                  = UDim2.new(1, 0, 0, 40 * scale),
        BackgroundColor3      = ActiveAccent,
        BorderSizePixel       = 0,
        ZIndex                = 502,
        LayoutOrder           = 6,
    }, licenseCard)
    corner(7, loginBtn)

    local statusLabel = new("TextLabel", {
        Text                  = "",
        Font                  = Enum.Font.Gotham,
        TextSize              = 10 * scale,
        TextColor3            = ActiveTheme.SubText,
        Size                  = UDim2.new(1, 0, 0, 14 * scale),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Center,
        ZIndex                = 502,
        LayoutOrder           = 7,
    }, licenseCard)

    loginBtn.MouseEnter:Connect(function()
        tween(loginBtn, TI.Fast, {BackgroundColor3 = ActiveAccent:Lerp(Color3.new(1,1,1), 0.12)})
    end)
    loginBtn.MouseLeave:Connect(function()
        tween(loginBtn, TI.Fast, {BackgroundColor3 = ActiveAccent})
    end)

    local mainWindow = new("Frame", {
        Name                  = "MainWindow",
        Size                  = UDim2.new(0, winW, 0, winH),
        Position              = UDim2.new(0.5, -winW/2, 0.5, -winH/2),
        BackgroundColor3      = ActiveTheme.Background,
        BorderSizePixel       = 0,
        Visible               = false,
        ZIndex                = 10,
    }, screenGui)
    corner(10, mainWindow)
    stroke(1, ActiveTheme.Border, 0, mainWindow)
    shadow(mainWindow, 28, 0.45)

    local navPanel = new("Frame", {
        Name                  = "NavPanel",
        Size                  = UDim2.new(0, navW, 1, 0),
        BackgroundColor3      = ActiveTheme.Surface,
        BorderSizePixel       = 0,
        ZIndex                = 11,
    }, mainWindow)
    corner(10, navPanel)

    local navOverlay = new("Frame", {
        Size                  = UDim2.new(0, 10, 1, 0),
        Position              = UDim2.new(1, -10, 0, 0),
        BackgroundColor3      = ActiveTheme.Surface,
        BorderSizePixel       = 0,
        ZIndex                = 11,
    }, navPanel)

    stroke(1, ActiveTheme.Border, 0, navPanel)

    local navTopSection = new("Frame", {
        Name                  = "NavTop",
        Size                  = UDim2.new(1, 0, 0, 70 * scale),
        BackgroundTransparency = 1,
        ZIndex                = 12,
    }, navPanel)

    local windowIcon = new("TextLabel", {
        Text                  = "◈",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 18 * scale,
        TextColor3            = ActiveAccent,
        Size                  = UDim2.new(0, 24 * scale, 0, 24 * scale),
        Position              = UDim2.new(0, 14 * scale, 0, 14 * scale),
        BackgroundTransparency = 1,
        ZIndex                = 12,
    }, navTopSection)

    local windowTitle = new("TextLabel", {
        Text                  = config.Title or "SIGHT",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13 * scale,
        TextColor3            = ActiveTheme.Text,
        Size                  = UDim2.new(1, -42 * scale, 0, 20 * scale),
        Position              = UDim2.new(0, 40 * scale, 0, 15 * scale),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 12,
    }, navTopSection)

    local windowSubtitle = new("TextLabel", {
        Text                  = config.Subtitle or "v" .. sight.Version,
        Font                  = Enum.Font.Gotham,
        TextSize              = 9 * scale,
        TextColor3            = ActiveTheme.SubText,
        Size                  = UDim2.new(1, -42 * scale, 0, 14 * scale),
        Position              = UDim2.new(0, 40 * scale, 0, 34 * scale),
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 12,
    }, navTopSection)

    local navSeparator = new("Frame", {
        Size                  = UDim2.new(1, -28 * scale, 0, 1),
        Position              = UDim2.new(0, 14 * scale, 0, 68 * scale),
        BackgroundColor3      = ActiveTheme.Border,
        BorderSizePixel       = 0,
        ZIndex                = 12,
    }, navPanel)

    local tabListFrame = new("Frame", {
        Name                  = "TabList",
        Size                  = UDim2.new(1, 0, 1, -90 * scale),
        Position              = UDim2.new(0, 0, 0, 78 * scale),
        BackgroundTransparency = 1,
        ZIndex                = 12,
        ClipsDescendants      = true,
    }, navPanel)
    local tabList = listLayout(nil, nil, 2 * scale, tabListFrame)
    padding(4 * scale, 4 * scale, 8 * scale, 8 * scale, tabListFrame)

    local contentFrame = new("Frame", {
        Name                  = "ContentFrame",
        Size                  = UDim2.new(1, -navW, 1, 0),
        Position              = UDim2.new(0, navW, 0, 0),
        BackgroundTransparency = 1,
        ZIndex                = 11,
        ClipsDescendants      = true,
    }, mainWindow)

    local subTabBar = new("Frame", {
        Name                  = "SubTabBar",
        Size                  = UDim2.new(1, 0, 0, 36 * scale),
        BackgroundColor3      = ActiveTheme.Surface,
        BorderSizePixel       = 0,
        ZIndex                = 12,
        Visible               = false,
    }, contentFrame)
    local subTabStroke = new("Frame", {
        Size                  = UDim2.new(1, 0, 0, 1),
        Position              = UDim2.new(0, 0, 1, -1),
        BackgroundColor3      = ActiveTheme.Border,
        BorderSizePixel       = 0,
        ZIndex                = 13,
    }, subTabBar)

    local subTabScroll = new("ScrollingFrame", {
        Name                  = "SubTabScroll",
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 0,
        ZIndex                = 13,
    }, subTabBar)
    local subTabList = listLayout(Enum.FillDirection.Horizontal, nil, 4 * scale, subTabScroll)
    padding(0, 0, 12 * scale, 12 * scale, subTabScroll)

    local scrollArea = new("ScrollingFrame", {
        Name                  = "ScrollArea",
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 3,
        ScrollBarImageColor3  = ActiveAccent,
        ScrollBarImageTransparency = 0.4,
        BorderSizePixel       = 0,
        ZIndex                = 12,
        CanvasSize            = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
    }, contentFrame)

    local scrollPad = padding(14 * scale, 14 * scale, 14 * scale, 14 * scale, scrollArea)

    local columnsFrame = new("Frame", {
        Name                  = "Columns",
        Size                  = UDim2.new(1, 0, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                = 13,
    }, scrollArea)

    local colList = Instance.new("UIListLayout")
    colList.FillDirection     = Enum.FillDirection.Horizontal
    colList.SortOrder         = Enum.SortOrder.LayoutOrder
    colList.Padding           = UDim.new(0, 10 * scale)
    colList.VerticalAlignment = Enum.VerticalAlignment.Top
    colList.Parent            = columnsFrame

    local leftCol = new("Frame", {
        Name                  = "LeftCol",
        Size                  = UDim2.new(0.5, -5 * scale, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                = 13,
        LayoutOrder           = 1,
    }, columnsFrame)
    listLayout(nil, nil, 8 * scale, leftCol)

    local rightCol = new("Frame", {
        Name                  = "RightCol",
        Size                  = UDim2.new(0.5, -5 * scale, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex                = 13,
        LayoutOrder           = 2,
    }, columnsFrame)
    listLayout(nil, nil, 8 * scale, rightCol)

    local closeBtn = new("TextButton", {
        Text                  = "✕",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 10 * scale,
        TextColor3            = ActiveTheme.SubText,
        Size                  = UDim2.new(0, 20 * scale, 0, 20 * scale),
        Position              = UDim2.new(1, -26 * scale, 0, 8 * scale),
        BackgroundColor3      = ActiveTheme.SurfaceAlt,
        BorderSizePixel       = 0,
        ZIndex                = 15,
    }, mainWindow)
    corner(4, closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainWindow, TI.Medium, {Size = UDim2.new(0, winW, 0, 0), Position = UDim2.new(mainWindow.Position.X.Scale, mainWindow.Position.X.Offset, mainWindow.Position.Y.Scale, mainWindow.Position.Y.Offset + winH/2)})
        task.wait(0.25)
        mainWindow.Visible = false
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.Danger, TextColor3 = Color3.new(1,1,1)})
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt, TextColor3 = ActiveTheme.SubText})
    end)

    local minBtn = new("TextButton", {
        Text                  = "—",
        Font                  = Enum.Font.GothamBold,
        TextSize              = 10 * scale,
        TextColor3            = ActiveTheme.SubText,
        Size                  = UDim2.new(0, 20 * scale, 0, 20 * scale),
        Position              = UDim2.new(1, -50 * scale, 0, 8 * scale),
        BackgroundColor3      = ActiveTheme.SurfaceAlt,
        BorderSizePixel       = 0,
        ZIndex                = 15,
    }, mainWindow)
    corner(4, minBtn)
    local minimized = false
    local storedSize = UDim2.new(0, winW, 0, winH)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(mainWindow, TI.Medium, {Size = UDim2.new(0, navW, 0, winH)})
            contentFrame.Visible = false
        else
            tween(mainWindow, TI.Medium, {Size = storedSize})
            task.wait(0.15)
            contentFrame.Visible = true
        end
    end)
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.BorderGlow, TextColor3 = ActiveTheme.Text})
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt, TextColor3 = ActiveTheme.SubText})
    end)

    local dragDisconnect = makeDraggable(mainWindow, navTopSection)

    local mobileBtn
    if sight.IsMobile then
        mobileBtn = new("TextButton", {
            Text                  = "◈",
            Font                  = Enum.Font.GothamBold,
            TextSize              = 20,
            TextColor3            = Color3.new(1, 1, 1),
            Size                  = UDim2.new(0, 54, 0, 54),
            Position              = UDim2.new(1, -70, 1, -70),
            BackgroundColor3      = ActiveAccent,
            BorderSizePixel       = 0,
            ZIndex                = 600,
        }, screenGui)
        corner(27, mobileBtn)
        shadow(mobileBtn, 16, 0.4)
        local vis = true
        mobileBtn.MouseButton1Click:Connect(function()
            vis = not vis
            mainWindow.Visible = vis
            if vis then
                tween(mainWindow, TI.Spring, {Size = storedSize})
            end
        end)
    end

    local windowObj = {
        Gui          = screenGui,
        Main         = mainWindow,
        NavPanel     = navPanel,
        TabListFrame = tabListFrame,
        ContentFrame = contentFrame,
        SubTabBar    = subTabBar,
        SubTabScroll = subTabScroll,
        ScrollArea   = scrollArea,
        LeftCol      = leftCol,
        RightCol     = rightCol,
        Scale        = scale,
        Tabs         = {},
        ActiveTab    = nil,
        ActiveSubTab = nil,
        DragEnabled  = true,
        DragConn     = dragDisconnect,
        StoredSize   = storedSize,
        WinW         = winW,
        WinH         = winH,
        AccentColor  = ActiveAccent,
        Theme        = ActiveTheme,
        ConfigData   = {},
    }

    local settingsTabData = nil

    local function refreshSections(tabData)
        for _, child in ipairs(leftCol:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        for _, child in ipairs(rightCol:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        local hasSubTabs = tabData.SubTabs and #tabData.SubTabs > 0
        subTabBar.Visible = hasSubTabs
        if hasSubTabs then
            scrollArea.Size = UDim2.new(1, 0, 1, -36 * scale)
            scrollArea.Position = UDim2.new(0, 0, 0, 36 * scale)
        else
            scrollArea.Size  = UDim2.new(1, 0, 1, 0)
            scrollArea.Position = UDim2.new(0, 0, 0, 0)
        end
        if tabData.ActiveSubTab then
            for _, sec in ipairs(tabData.ActiveSubTab.LeftSections) do
                sec.Visible = true
            end
            for _, sec in ipairs(tabData.ActiveSubTab.RightSections) do
                sec.Visible = true
            end
        else
            for _, sec in ipairs(tabData.LeftSections) do
                sec.Visible = true
            end
            for _, sec in ipairs(tabData.RightSections) do
                sec.Visible = true
            end
        end
    end

    function windowObj:sight_SelectTab(tabData)
        for _, t in ipairs(self.Tabs) do
            tween(t.Indicator, TI.Fast, {BackgroundTransparency = 1})
            tween(t.Button, TI.Fast, {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1})
            tween(t.Label, TI.Fast, {TextColor3 = ActiveTheme.SubText})
            tween(t.Icon, TI.Fast, {TextColor3 = ActiveTheme.SubText})
        end
        tween(tabData.Indicator, TI.Fast, {BackgroundTransparency = 0})
        tween(tabData.Button, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt, BackgroundTransparency = 0})
        tween(tabData.Label, TI.Fast, {TextColor3 = ActiveTheme.Text})
        tween(tabData.Icon, TI.Fast, {TextColor3 = ActiveAccent})
        self.ActiveTab = tabData
        for _, st in ipairs(tabData.SubTabs or {}) do
            st.Button.Visible = true
        end
        refreshSections(tabData)
    end

    function windowObj:sight_CreateTab(name, icon)
        local sc = self.Scale
        local btn = new("TextButton", {
            Text                  = "",
            Size                  = UDim2.new(1, 0, 0, 34 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            ZIndex                = 13,
            LayoutOrder           = #self.Tabs + 1,
        }, self.TabListFrame)
        corner(6, btn)

        local indicator = new("Frame", {
            Size                  = UDim2.new(0, 2 * sc, 0, 18 * sc),
            Position              = UDim2.new(0, 0, 0.5, -9 * sc),
            BackgroundColor3      = ActiveAccent,
            BorderSizePixel       = 0,
            BackgroundTransparency = 1,
            ZIndex                = 14,
        }, btn)
        corner(2, indicator)

        local iconLbl = new("TextLabel", {
            Text                  = icon or "•",
            Font                  = Enum.Font.GothamBold,
            TextSize              = 13 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(0, 20 * sc, 1, 0),
            Position              = UDim2.new(0, 10 * sc, 0, 0),
            BackgroundTransparency = 1,
            ZIndex                = 14,
        }, btn)

        local lbl = new("TextLabel", {
            Text                  = name,
            Font                  = Enum.Font.Gotham,
            TextSize              = 12 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(1, -36 * sc, 1, 0),
            Position              = UDim2.new(0, 34 * sc, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 14,
        }, btn)

        local tabData = {
            Button         = btn,
            Label          = lbl,
            Icon           = iconLbl,
            Indicator      = indicator,
            Name           = name,
            LeftSections   = {},
            RightSections  = {},
            SubTabs        = {},
            ActiveSubTab   = nil,
        }
        table.insert(self.Tabs, tabData)

        btn.MouseButton1Click:Connect(function()
            if self.ActiveTab == tabData then return end
            self:sight_SelectTab(tabData)
        end)
        btn.MouseEnter:Connect(function()
            if self.ActiveTab ~= tabData then
                tween(btn, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt, BackgroundTransparency = 0.5})
            end
        end)
        btn.MouseLeave:Connect(function()
            if self.ActiveTab ~= tabData then
                tween(btn, TI.Fast, {BackgroundTransparency = 1})
            end
        end)

        if #self.Tabs == 1 then
            self:sight_SelectTab(tabData)
        end

        return tabData
    end

    function windowObj:sight_CreateSubTab(tabData, name)
        local sc = self.Scale
        local btn = new("TextButton", {
            Text                  = name,
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(0, 0, 1, -10 * sc),
            AutomaticSize         = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            ZIndex                = 14,
            LayoutOrder           = #tabData.SubTabs + 1,
        }, self.SubTabScroll)
        padding(0, 0, 8 * sc, 8 * sc, btn)

        local underline = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 2),
            Position              = UDim2.new(0, 0, 1, 0),
            BackgroundColor3      = ActiveAccent,
            BorderSizePixel       = 0,
            BackgroundTransparency = 1,
            ZIndex                = 15,
        }, btn)

        local subData = {
            Button        = btn,
            Underline     = underline,
            Name          = name,
            LeftSections  = {},
            RightSections = {},
        }
        table.insert(tabData.SubTabs, subData)

        btn.MouseButton1Click:Connect(function()
            if tabData.ActiveSubTab == subData then return end
            for _, s in ipairs(tabData.SubTabs) do
                tween(s.Underline, TI.Fast, {BackgroundTransparency = 1})
                tween(s.Button, TI.Fast, {TextColor3 = ActiveTheme.SubText})
            end
            tween(underline, TI.Fast, {BackgroundTransparency = 0})
            tween(btn, TI.Fast, {TextColor3 = ActiveTheme.Text})
            tabData.ActiveSubTab = subData
            refreshSections(tabData)
        end)
        btn.MouseEnter:Connect(function()
            if tabData.ActiveSubTab ~= subData then
                tween(btn, TI.Fast, {TextColor3 = ActiveTheme.Text})
            end
        end)
        btn.MouseLeave:Connect(function()
            if tabData.ActiveSubTab ~= subData then
                tween(btn, TI.Fast, {TextColor3 = ActiveTheme.SubText})
            end
        end)

        if #tabData.SubTabs == 1 then
            btn.MouseButton1Click:Fire()
        end

        return subData
    end

    function windowObj:sight_CreateSection(target, title, column)
        local sc   = self.Scale
        local par  = column == "right" and self.RightCol or self.LeftCol

        local sec = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            BackgroundColor3      = ActiveTheme.Surface,
            BorderSizePixel       = 0,
            Visible               = false,
            ZIndex                = 14,
        }, par)
        corner(8, sec)
        stroke(1, ActiveTheme.Border, 0, sec)
        padding(10 * sc, 10 * sc, 10 * sc, 10 * sc, sec)

        local innerList = listLayout(nil, nil, 6 * sc, sec)

        local header = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 20 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 15,
            LayoutOrder           = 0,
        }, sec)

        local headerTitle = new("TextLabel", {
            Text                  = title,
            Font                  = Enum.Font.GothamBold,
            TextSize              = 10 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0, 0, 1, 0),
            AutomaticSize         = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 15,
        }, header)

        local headerLine = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 1),
            Position              = UDim2.new(0, 0, 1, 0),
            BackgroundColor3      = ActiveAccent,
            BackgroundTransparency = 0.7,
            BorderSizePixel       = 0,
            ZIndex                = 15,
        }, header)

        if column == "right" then
            table.insert(target.RightSections, sec)
        else
            table.insert(target.LeftSections, sec)
        end

        return sec
    end

    function windowObj:sight_CreateButton(section, config)
        local sc = self.Scale
        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 32 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
        }, section)

        local btn = new("TextButton", {
            Text                  = config.Text or "Button",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 17,
        }, wrap)
        corner(6, btn)
        stroke(1, ActiveTheme.Border, 0, btn)

        if config.Description then
            local desc = new("TextLabel", {
                Text                  = config.Description,
                Font                  = Enum.Font.Gotham,
                TextSize              = 9 * sc,
                TextColor3            = ActiveTheme.SubText,
                Size                  = UDim2.new(1, -20 * sc, 1, 0),
                Position              = UDim2.new(0, 10 * sc, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment        = Enum.TextXAlignment.Right,
                ZIndex                = 18,
            }, btn)
        end

        btn.MouseEnter:Connect(function()
            tween(btn, TI.Fast, {BackgroundColor3 = ActiveTheme.BorderGlow})
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt})
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, TI.Fast, {BackgroundColor3 = ActiveAccent:Lerp(ActiveTheme.SurfaceAlt, 0.5)})
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, TI.Fast, {BackgroundColor3 = ActiveTheme.BorderGlow})
            if config.Callback then config.Callback() end
        end)

        return wrap
    end

    function windowObj:sight_CreateToggle(section, config)
        local sc = self.Scale
        local enabled = config.Default == true

        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 28 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Toggle",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(1, -52 * sc, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 16,
        }, wrap)

        if config.Description then
            lbl.Size = UDim2.new(1, -52 * sc, 0, 16 * sc)
            local sub = new("TextLabel", {
                Text                  = config.Description,
                Font                  = Enum.Font.Gotham,
                TextSize              = 9 * sc,
                TextColor3            = ActiveTheme.SubText,
                Size                  = UDim2.new(1, -52 * sc, 0, 12 * sc),
                Position              = UDim2.new(0, 0, 0, 16 * sc),
                BackgroundTransparency = 1,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 16,
            }, wrap)
        end

        local trackW, trackH = 38 * sc, 20 * sc
        local track = new("TextButton", {
            Text                  = "",
            Size                  = UDim2.new(0, trackW, 0, trackH),
            Position              = UDim2.new(1, -trackW, 0.5, -trackH/2),
            BackgroundColor3      = enabled and ActiveAccent or ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 17,
        }, wrap)
        corner(trackH/2, track)
        stroke(1, enabled and ActiveAccent or ActiveTheme.Border, 0, track)

        local knob = new("Frame", {
            Size                  = UDim2.new(0, 14 * sc, 0, 14 * sc),
            Position              = enabled
                and UDim2.new(1, -(14 + 3) * sc, 0.5, -7 * sc)
                or  UDim2.new(0, 3 * sc, 0.5, -7 * sc),
            BackgroundColor3      = Color3.new(1, 1, 1),
            BorderSizePixel       = 0,
            ZIndex                = 18,
        }, track)
        corner(7 * sc, knob)

        local toggleData = {Value = enabled}

        local function setState(state, silent)
            enabled = state
            toggleData.Value = state
            if state then
                tween(track, TI.Fast, {BackgroundColor3 = ActiveAccent})
                tween(knob, TI.Fast, {Position = UDim2.new(1, -(14 + 3) * sc, 0.5, -7 * sc)})
            else
                tween(track, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt})
                tween(knob, TI.Fast, {Position = UDim2.new(0, 3 * sc, 0.5, -7 * sc)})
            end
            if not silent and config.Callback then config.Callback(state) end
        end

        track.MouseButton1Click:Connect(function()
            setState(not enabled)
        end)

        function toggleData:Set(v) setState(v, false) end
        return toggleData
    end

    function windowObj:sight_CreateSlider(section, config)
        local sc  = self.Scale
        local min = config.Min or 0
        local max = config.Max or 100
        local val = math.clamp(config.Default or min, min, max)
        local suffix = config.Suffix or ""

        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 50 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
        }, section)

        local topRow = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 18 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
        }, wrap)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Slider",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 16,
        }, topRow)

        local valBox = new("TextBox", {
            Text                  = tostring(val),
            Font                  = Enum.Font.GothamBold,
            TextSize              = 10 * sc,
            TextColor3            = ActiveAccent,
            Size                  = UDim2.new(0, 52 * sc, 1, 0),
            Position              = UDim2.new(1, -52 * sc, 0, 0),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 17,
            TextXAlignment        = Enum.TextXAlignment.Center,
            ClearTextOnFocus      = true,
        }, topRow)
        corner(4, valBox)

        local track = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 4 * sc),
            Position              = UDim2.new(0, 0, 0, 28 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 16,
        }, wrap)
        corner(2, track)

        local fill = new("Frame", {
            Size                  = UDim2.new((val - min)/(max - min), 0, 1, 0),
            BackgroundColor3      = ActiveAccent,
            BorderSizePixel       = 0,
            ZIndex                = 17,
        }, track)
        corner(2, fill)

        local knobSz = 14 * sc
        local knob = new("Frame", {
            Size                  = UDim2.new(0, knobSz, 0, knobSz),
            Position              = UDim2.new((val - min)/(max - min), -knobSz/2, 0.5, -knobSz/2),
            BackgroundColor3      = ActiveAccent,
            BorderSizePixel       = 0,
            ZIndex                = 18,
        }, track)
        corner(knobSz/2, knob)
        stroke(2, Color3.new(1,1,1), 0.4, knob)

        local sliderData = {Value = val}
        local dragging = false

        local function setVal(v, silent)
            v = math.clamp(math.floor(v * 10 + 0.5) / 10, min, max)
            sliderData.Value = v
            val = v
            local pct = (v - min) / (max - min)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -knobSz/2, 0.5, -knobSz/2)
            valBox.Text = tostring(v) .. suffix
            if not silent and config.Callback then config.Callback(v) end
        end

        local function inputToVal(input)
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setVal(min + (max - min) * pct)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                inputToVal(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                             input.UserInputType == Enum.UserInputType.Touch) then
                inputToVal(input)
            end
        end)

        valBox.FocusLost:Connect(function(enter)
            if enter then
                local n = tonumber(valBox.Text)
                if n then
                    setVal(n)
                else
                    valBox.Text = tostring(val) .. suffix
                end
            end
        end)

        function sliderData:Set(v) setVal(v, false) end
        return sliderData
    end

    function windowObj:sight_CreateDropdown(section, config)
        local sc       = self.Scale
        local selected = config.Default or (config.Options[1])
        local open     = false

        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 30 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 20,
            ClipsDescendants      = false,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Dropdown",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0.42, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 20,
        }, wrap)

        local dropBtn = new("TextButton", {
            Text                  = "",
            Size                  = UDim2.new(0.56, 0, 0, 26 * sc),
            Position              = UDim2.new(0.44, 0, 0.5, -13 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 21,
        }, wrap)
        corner(5, dropBtn)
        stroke(1, ActiveTheme.Border, 0, dropBtn)

        local selLbl = new("TextLabel", {
            Text                  = tostring(selected),
            Font                  = Enum.Font.Gotham,
            TextSize              = 10 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(1, -20 * sc, 1, 0),
            Position              = UDim2.new(0, 8 * sc, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 22,
        }, dropBtn)

        local arrow = new("TextLabel", {
            Text                  = "⌄",
            Font                  = Enum.Font.GothamBold,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(0, 16 * sc, 1, 0),
            Position              = UDim2.new(1, -18 * sc, 0, 0),
            BackgroundTransparency = 1,
            ZIndex                = 22,
        }, dropBtn)

        local menuH = math.min(#config.Options, 6) * 26 * sc
        local menu = new("Frame", {
            Size                  = UDim2.new(0.56, 0, 0, menuH + 8 * sc),
            Position              = UDim2.new(0.44, 0, 0, 30 * sc),
            BackgroundColor3      = ActiveTheme.Surface,
            BorderSizePixel       = 0,
            Visible               = false,
            ZIndex                = 50,
            ClipsDescendants      = true,
        }, wrap)
        corner(6, menu)
        stroke(1, ActiveTheme.Border, 0, menu)
        shadow(menu, 14, 0.45)
        padding(4 * sc, 4 * sc, 4 * sc, 4 * sc, menu)
        listLayout(nil, nil, 2 * sc, menu)

        local dropData = {Value = selected}

        for _, opt in ipairs(config.Options) do
            local optBtn = new("TextButton", {
                Text                  = tostring(opt),
                Font                  = Enum.Font.Gotham,
                TextSize              = 10 * sc,
                TextColor3            = ActiveTheme.Text,
                Size                  = UDim2.new(1, 0, 0, 24 * sc),
                BackgroundColor3      = ActiveTheme.SurfaceAlt,
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                ZIndex                = 51,
            }, menu)
            corner(4, optBtn)
            padding(0, 0, 8 * sc, 8 * sc, optBtn)

            optBtn.MouseEnter:Connect(function()
                tween(optBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt, BackgroundTransparency = 0})
            end)
            optBtn.MouseLeave:Connect(function()
                tween(optBtn, TI.Fast, {BackgroundTransparency = 1})
            end)
            optBtn.MouseButton1Click:Connect(function()
                selected          = opt
                dropData.Value    = opt
                selLbl.Text       = tostring(opt)
                open              = false
                tween(menu, TI.Fast, {Size = UDim2.new(0.56, 0, 0, 0)})
                task.wait(0.12)
                menu.Visible = false
                tween(arrow, TI.Fast, {Rotation = 0})
                if config.Callback then config.Callback(opt) end
            end)
        end

        dropBtn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                menu.Visible = true
                menu.Size    = UDim2.new(0.56, 0, 0, 0)
                tween(menu, TI.Medium, {Size = UDim2.new(0.56, 0, 0, menuH + 8 * sc)})
                tween(arrow, TI.Fast, {Rotation = 180})
            else
                tween(menu, TI.Fast, {Size = UDim2.new(0.56, 0, 0, 0)})
                task.wait(0.12)
                menu.Visible = false
                tween(arrow, TI.Fast, {Rotation = 0})
            end
        end)

        function dropData:Set(v)
            selected = v
            self.Value = v
            selLbl.Text = tostring(v)
        end
        return dropData
    end

    function windowObj:sight_CreateMultiDropdown(section, config)
        local sc        = self.Scale
        local selected  = {}
        local open      = false

        for _, v in ipairs(config.Default or {}) do
            selected[v] = true
        end

        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 30 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 20,
            ClipsDescendants      = false,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Multi Select",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0.42, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 20,
        }, wrap)

        local dropBtn = new("TextButton", {
            Text                  = "",
            Size                  = UDim2.new(0.56, 0, 0, 26 * sc),
            Position              = UDim2.new(0.44, 0, 0.5, -13 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 21,
        }, wrap)
        corner(5, dropBtn)
        stroke(1, ActiveTheme.Border, 0, dropBtn)

        local selLbl = new("TextLabel", {
            Text                  = "None",
            Font                  = Enum.Font.Gotham,
            TextSize              = 10 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(1, -20 * sc, 1, 0),
            Position              = UDim2.new(0, 8 * sc, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 22,
        }, dropBtn)

        local arrow = new("TextLabel", {
            Text                  = "⌄",
            Font                  = Enum.Font.GothamBold,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(0, 16 * sc, 1, 0),
            Position              = UDim2.new(1, -18 * sc, 0, 0),
            BackgroundTransparency = 1,
            ZIndex                = 22,
        }, dropBtn)

        local menuH = math.min(#config.Options, 6) * 28 * sc
        local menu = new("Frame", {
            Size                  = UDim2.new(0.56, 0, 0, menuH + 8 * sc),
            Position              = UDim2.new(0.44, 0, 0, 30 * sc),
            BackgroundColor3      = ActiveTheme.Surface,
            BorderSizePixel       = 0,
            Visible               = false,
            ZIndex                = 50,
        }, wrap)
        corner(6, menu)
        stroke(1, ActiveTheme.Border, 0, menu)
        shadow(menu, 14, 0.45)
        padding(4 * sc, 4 * sc, 4 * sc, 4 * sc, menu)
        listLayout(nil, nil, 2 * sc, menu)

        local multiData = {Value = selected}

        local function updateLabel()
            local keys = {}
            for k in pairs(selected) do table.insert(keys, k) end
            if #keys == 0 then
                selLbl.Text  = "None"
                selLbl.TextColor3 = ActiveTheme.SubText
            else
                selLbl.Text  = table.concat(keys, ", ")
                selLbl.TextColor3 = ActiveTheme.Text
            end
        end
        updateLabel()

        for _, opt in ipairs(config.Options) do
            local optWrap = new("Frame", {
                Size                  = UDim2.new(1, 0, 0, 26 * sc),
                BackgroundColor3      = ActiveTheme.SurfaceAlt,
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                ZIndex                = 51,
            }, menu)
            corner(4, optWrap)
            padding(0, 0, 6 * sc, 6 * sc, optWrap)

            local chk = new("Frame", {
                Size                  = UDim2.new(0, 14 * sc, 0, 14 * sc),
                Position              = UDim2.new(1, -16 * sc, 0.5, -7 * sc),
                BackgroundColor3      = selected[opt] and ActiveAccent or ActiveTheme.SurfaceAlt,
                BorderSizePixel       = 0,
                ZIndex                = 52,
            }, optWrap)
            corner(3, chk)
            stroke(1, selected[opt] and ActiveAccent or ActiveTheme.Border, 0, chk)

            local chkMark = new("TextLabel", {
                Text                  = "✓",
                Font                  = Enum.Font.GothamBold,
                TextSize              = 9 * sc,
                TextColor3            = Color3.new(1,1,1),
                Size                  = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                TextXAlignment        = Enum.TextXAlignment.Center,
                ZIndex                = 53,
                Visible               = selected[opt] or false,
            }, chk)

            local optLbl = new("TextLabel", {
                Text                  = tostring(opt),
                Font                  = Enum.Font.Gotham,
                TextSize              = 10 * sc,
                TextColor3            = ActiveTheme.Text,
                Size                  = UDim2.new(1, -20 * sc, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 52,
            }, optWrap)

            local optBtn = new("TextButton", {
                Text                  = "",
                Size                  = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                ZIndex                = 54,
            }, optWrap)

            optBtn.MouseEnter:Connect(function()
                tween(optWrap, TI.Fast, {BackgroundTransparency = 0})
            end)
            optBtn.MouseLeave:Connect(function()
                tween(optWrap, TI.Fast, {BackgroundTransparency = 1})
            end)
            optBtn.MouseButton1Click:Connect(function()
                if selected[opt] then
                    selected[opt] = nil
                    tween(chk, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt})
                    chkMark.Visible = false
                else
                    selected[opt] = true
                    tween(chk, TI.Fast, {BackgroundColor3 = ActiveAccent})
                    chkMark.Visible = true
                end
                multiData.Value = selected
                updateLabel()
                if config.Callback then
                    local sel = {}
                    for k in pairs(selected) do table.insert(sel, k) end
                    config.Callback(sel)
                end
            end)
        end

        dropBtn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                menu.Visible = true
                menu.Size    = UDim2.new(0.56, 0, 0, 0)
                tween(menu, TI.Medium, {Size = UDim2.new(0.56, 0, 0, menuH + 8 * sc)})
                tween(arrow, TI.Fast, {Rotation = 180})
            else
                tween(menu, TI.Fast, {Size = UDim2.new(0.56, 0, 0, 0)})
                task.wait(0.12)
                menu.Visible = false
                tween(arrow, TI.Fast, {Rotation = 0})
            end
        end)

        return multiData
    end

    function windowObj:sight_CreateColorPicker(section, config)
        local sc       = self.Scale
        local curColor = config.Default or Color3.fromRGB(255, 100, 100)
        local open     = false

        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 30 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 20,
            ClipsDescendants      = false,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Color",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0.55, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 20,
        }, wrap)

        local preview = new("TextButton", {
            Text                  = "",
            Size                  = UDim2.new(0, 42 * sc, 0, 22 * sc),
            Position              = UDim2.new(1, -42 * sc, 0.5, -11 * sc),
            BackgroundColor3      = curColor,
            BorderSizePixel       = 0,
            ZIndex                = 21,
        }, wrap)
        corner(5, preview)
        stroke(1, ActiveTheme.Border, 0, preview)

        local pickerFrame = new("Frame", {
            Size                  = UDim2.new(1, 10 * sc, 0, 180 * sc),
            Position              = UDim2.new(0, -5 * sc, 0, 34 * sc),
            BackgroundColor3      = ActiveTheme.Surface,
            BorderSizePixel       = 0,
            Visible               = false,
            ZIndex                = 60,
        }, wrap)
        corner(8, pickerFrame)
        stroke(1, ActiveTheme.Border, 0, pickerFrame)
        shadow(pickerFrame, 14, 0.45)
        padding(10 * sc, 10 * sc, 10 * sc, 10 * sc, pickerFrame)
        listLayout(nil, nil, 8 * sc, pickerFrame)

        local H, S, V = Color3.toHSV(curColor)

        local svCanvas = new("ImageLabel", {
            Image                 = "rbxassetid://6020299385",
            Size                  = UDim2.new(1, 0, 0, 90 * sc),
            BackgroundColor3      = Color3.fromHSV(H, 1, 1),
            BorderSizePixel       = 0,
            ZIndex                = 61,
        }, pickerFrame)
        corner(5, svCanvas)

        local svKnob = new("Frame", {
            Size                  = UDim2.new(0, 10 * sc, 0, 10 * sc),
            Position              = UDim2.new(S, -5 * sc, 1 - V, -5 * sc),
            BackgroundColor3      = Color3.new(1,1,1),
            BorderSizePixel       = 0,
            ZIndex                = 62,
        }, svCanvas)
        corner(5 * sc, svKnob)
        stroke(2, Color3.new(0,0,0), 0, svKnob)

        local hueBar = new("ImageLabel", {
            Image                 = "rbxassetid://6020299084",
            Size                  = UDim2.new(1, 0, 0, 14 * sc),
            BackgroundColor3      = Color3.new(1,1,1),
            BorderSizePixel       = 0,
            ZIndex                = 61,
        }, pickerFrame)
        corner(3, hueBar)

        local hueKnob = new("Frame", {
            Size                  = UDim2.new(0, 8 * sc, 1, 2),
            Position              = UDim2.new(H, -4 * sc, 0, -1),
            BackgroundColor3      = Color3.new(1,1,1),
            BorderSizePixel       = 0,
            ZIndex                = 62,
        }, hueBar)
        corner(2, hueKnob)
        stroke(1, Color3.new(0,0,0), 0.2, hueKnob)

        local hexRow = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 26 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 61,
        }, pickerFrame)

        local hexLabel = new("TextLabel", {
            Text                  = "HEX",
            Font                  = Enum.Font.GothamBold,
            TextSize              = 9 * sc,
            TextColor3            = ActiveTheme.SubText,
            Size                  = UDim2.new(0, 30 * sc, 1, 0),
            BackgroundTransparency = 1,
            ZIndex                = 62,
        }, hexRow)

        local function colorToHex(c)
            return string.format("#%02X%02X%02X", c.R * 255, c.G * 255, c.B * 255)
        end

        local hexBox = new("TextBox", {
            Text                  = colorToHex(curColor),
            Font                  = Enum.Font.Code,
            TextSize              = 10 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(1, -34 * sc, 1, -4 * sc),
            Position              = UDim2.new(0, 34 * sc, 0, 2 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 62,
        }, hexRow)
        corner(4, hexBox)
        padding(0, 0, 6 * sc, 0, hexBox)

        local colorData = {Value = curColor}

        local function applyColor(c)
            curColor = c
            colorData.Value = c
            preview.BackgroundColor3 = c
            H, S, V = Color3.toHSV(c)
            svCanvas.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            svKnob.Position = UDim2.new(S, -5 * sc, 1 - V, -5 * sc)
            hueKnob.Position = UDim2.new(H, -4 * sc, 0, -1)
            hexBox.Text = colorToHex(c)
            if config.Callback then config.Callback(c) end
        end

        local svDragging, hueDragging = false, false

        svCanvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
                local relX = math.clamp((input.Position.X - svCanvas.AbsolutePosition.X) / svCanvas.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - svCanvas.AbsolutePosition.Y) / svCanvas.AbsoluteSize.Y, 0, 1)
                S, V = relX, 1 - relY
                applyColor(Color3.fromHSV(H, S, V))
            end
        end)
        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
                H = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                applyColor(Color3.fromHSV(H, S, V))
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                svDragging  = false
                hueDragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if (svDragging or hueDragging) and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                                input.UserInputType == Enum.UserInputType.Touch) then
                if svDragging then
                    local relX = math.clamp((input.Position.X - svCanvas.AbsolutePosition.X) / svCanvas.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((input.Position.Y - svCanvas.AbsolutePosition.Y) / svCanvas.AbsoluteSize.Y, 0, 1)
                    S, V = relX, 1 - relY
                    applyColor(Color3.fromHSV(H, S, V))
                end
                if hueDragging then
                    H = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    applyColor(Color3.fromHSV(H, S, V))
                end
            end
        end)

        hexBox.FocusLost:Connect(function(enter)
            if enter then
                local hex = hexBox.Text:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber("0x" .. hex:sub(1,2))
                    local g = tonumber("0x" .. hex:sub(3,4))
                    local b = tonumber("0x" .. hex:sub(5,6))
                    if r and g and b then
                        applyColor(Color3.fromRGB(r, g, b))
                    end
                end
            end
        end)

        preview.MouseButton1Click:Connect(function()
            open = not open
            pickerFrame.Visible = open
        end)

        function colorData:Set(c) applyColor(c) end
        return colorData
    end

    function windowObj:sight_CreateTextbox(section, config)
        local sc = self.Scale
        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 50 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Input",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(1, 0, 0, 16 * sc),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 16,
        }, wrap)

        local inputWrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 30 * sc),
            Position              = UDim2.new(0, 0, 0, 18 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 16,
        }, wrap)
        corner(6, inputWrap)
        local iStroke = stroke(1, ActiveTheme.Border, 0, inputWrap)

        local box = new("TextBox", {
            PlaceholderText       = config.Placeholder or "Enter text...",
            Text                  = config.Default or "",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            PlaceholderColor3     = ActiveTheme.Muted,
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ClearTextOnFocus      = config.ClearOnFocus ~= false,
            ZIndex                = 17,
        }, inputWrap)
        padding(0, 0, 10 * sc, 10 * sc, box)

        box.Focused:Connect(function()
            tween(iStroke, TI.Fast, {Color = ActiveAccent, Transparency = 0.3})
        end)
        box.FocusLost:Connect(function(enter)
            tween(iStroke, TI.Fast, {Color = ActiveTheme.Border, Transparency = 0})
            if config.Callback then config.Callback(box.Text, enter) end
        end)

        local tbData = {Value = box.Text}
        function tbData:Set(v) box.Text = v self.Value = v end
        return tbData
    end

    function windowObj:sight_CreateLabel(section, config)
        local sc = self.Scale
        local lbl = new("TextLabel", {
            Text                  = config.Text or "",
            Font                  = config.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize              = (config.Size or 11) * sc,
            TextColor3            = config.Color or ActiveTheme.SubText,
            Size                  = UDim2.new(1, 0, 0, (config.Height or 18) * sc),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
            TextWrapped           = config.Wrap or false,
        }, section)
        local lblData = {}
        function lblData:SetText(t) lbl.Text = t end
        function lblData:SetColor(c) lbl.TextColor3 = c end
        return lblData
    end

    function windowObj:sight_CreateKeybind(section, config)
        local sc      = self.Scale
        local curKey  = config.Default or Enum.KeyCode.Unknown
        local binding = false

        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 28 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Keybind",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0.55, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 16,
        }, wrap)

        local keyBtn = new("TextButton", {
            Text                  = curKey == Enum.KeyCode.Unknown and "None" or curKey.Name,
            Font                  = Enum.Font.GothamBold,
            TextSize              = 10 * sc,
            TextColor3            = ActiveAccent,
            Size                  = UDim2.new(0, 70 * sc, 0, 22 * sc),
            Position              = UDim2.new(1, -70 * sc, 0.5, -11 * sc),
            BackgroundColor3      = ActiveTheme.SurfaceAlt,
            BorderSizePixel       = 0,
            ZIndex                = 17,
        }, wrap)
        corner(5, keyBtn)
        stroke(1, ActiveTheme.Border, 0, keyBtn)

        local kbData = {Value = curKey}

        keyBtn.MouseButton1Click:Connect(function()
            binding = true
            keyBtn.Text = "..."
            tween(keyBtn, TI.Fast, {BackgroundColor3 = ActiveAccent:Lerp(ActiveTheme.SurfaceAlt, 0.6)})
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if binding and not processed then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    curKey  = input.KeyCode
                    kbData.Value = curKey
                    keyBtn.Text = curKey.Name
                    tween(keyBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.SurfaceAlt})
                    if config.Callback then config.Callback(curKey) end
                end
            elseif not binding and input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == curKey and config.OnPress then
                    config.OnPress()
                end
            end
        end)

        function kbData:Set(key)
            curKey = key
            self.Value = key
            keyBtn.Text = key.Name
        end
        return kbData
    end

    function windowObj:sight_CreatePickerBox(section, config)
        local sc = self.Scale
        local wrap = new("Frame", {
            Size                  = UDim2.new(1, 0, 0, 28 * sc),
            BackgroundTransparency = 1,
            ZIndex                = 16,
            LayoutOrder           = config.Order or 99,
        }, section)

        local lbl = new("TextLabel", {
            Text                  = config.Text or "Pick Vector",
            Font                  = Enum.Font.Gotham,
            TextSize              = 11 * sc,
            TextColor3            = ActiveTheme.Text,
            Size                  = UDim2.new(0.42, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 16,
        }, wrap)

        local fields = config.Fields or {"X", "Y"}
        local values = {}
        local defaults = config.Defaults or {}

        local fieldW = 0.55 / #fields
        for i, fname in ipairs(fields) do
            local fwrap = new("Frame", {
                Size                  = UDim2.new(fieldW - 0.01, 0, 0, 22 * sc),
                Position              = UDim2.new(0.44 + (i-1) * fieldW, 0, 0.5, -11 * sc),
                BackgroundColor3      = ActiveTheme.SurfaceAlt,
                BorderSizePixel       = 0,
                ZIndex                = 17,
            }, wrap)
            corner(4, fwrap)
            stroke(1, ActiveTheme.Border, 0, fwrap)

            local flbl = new("TextLabel", {
                Text                  = fname,
                Font                  = Enum.Font.GothamBold,
                TextSize              = 8 * sc,
                TextColor3            = ActiveAccent,
                Size                  = UDim2.new(0, 14 * sc, 1, 0),
                BackgroundTransparency = 1,
                ZIndex                = 18,
            }, fwrap)

            local fbox = new("TextBox", {
                Text                  = tostring(defaults[i] or 0),
                Font                  = Enum.Font.Code,
                TextSize              = 10 * sc,
                TextColor3            = ActiveTheme.Text,
                Size                  = UDim2.new(1, -16 * sc, 1, 0),
                Position              = UDim2.new(0, 16 * sc, 0, 0),
                BackgroundTransparency = 1,
                ClearTextOnFocus      = true,
                ZIndex                = 18,
            }, fwrap)

            values[fname] = tonumber(defaults[i]) or 0
            fbox.FocusLost:Connect(function()
                values[fname] = tonumber(fbox.Text) or 0
                if config.Callback then config.Callback(values) end
            end)
        end

        local pbData = {Value = values}
        return pbData
    end

    local function buildSettingsTab(wObj)
        local st = wObj:sight_CreateTab("Settings", "⚙")
        local sc = wObj.Scale

        local themesSec = wObj:sight_CreateSection(st, "Theme", "left")
        local accentSec = wObj:sight_CreateSection(st, "Accent Color", "left")
        local windowSec = wObj:sight_CreateSection(st, "Window", "right")
        local configSec = wObj:sight_CreateSection(st, "Config", "right")

        themesSec.Visible = true
        accentSec.Visible = true
        windowSec.Visible = true
        configSec.Visible = true

        for themeName, themeData in pairs(Themes) do
            wObj:sight_CreateButton(themesSec, {
                Text = themeName .. " Theme",
                Description = "Apply",
                Callback = function()
                    ActiveTheme = themeData
                end,
            })
        end

        local accentNames = {}
        for name in pairs(AccentPresets) do table.insert(accentNames, name) end
        wObj:sight_CreateDropdown(accentSec, {
            Text    = "Accent",
            Options = accentNames,
            Default = "Cyan",
            Callback = function(v)
                ActiveAccent = AccentPresets[v] or AccentPresets.Cyan
            end,
        })

        wObj:sight_CreateToggle(windowSec, {
            Text    = "Draggable",
            Default = true,
            Callback = function(v)
                wObj.DragEnabled = v
            end,
        })

        wObj:sight_CreateSlider(windowSec, {
            Text    = "UI Scale",
            Min     = 70,
            Max     = 130,
            Default = 100,
            Suffix  = "%",
            Callback = function(v)
                local factor = v / 100
                wObj.Main.Size = UDim2.new(0, wObj.WinW * factor, 0, wObj.WinH * factor)
            end,
        })

        wObj:sight_CreateButton(configSec, {
            Text     = "Save Config",
            Callback = function()
                saveConfig(config.Title or "sight", wObj.ConfigData)
            end,
        })

        wObj:sight_CreateButton(configSec, {
            Text     = "Load Config",
            Callback = function()
                local data = loadConfig(config.Title or "sight")
                if data then wObj.ConfigData = data end
            end,
        })

        return st
    end

    local validKeys = config.LicenseKeys or {"SIGHT-FREE-ACCESS-2024", ""}

    loginBtn.MouseButton1Click:Connect(function()
        local key = keyInput.Text
        local valid = false
        for _, k in ipairs(validKeys) do
            if key == k then valid = true break end
        end

        if valid then
            statusLabel.Text      = "✓ Authenticated"
            statusLabel.TextColor3 = ActiveTheme.Success
            loginBtn.Text         = "✓"
            tween(loginBtn, TI.Fast, {BackgroundColor3 = ActiveTheme.Success})
            task.wait(0.6)
            tween(overlay, TI.Medium, {BackgroundTransparency = 1})
            task.wait(0.25)
            overlay.Visible = false
            mainWindow.Visible = true
            mainWindow.Size = UDim2.new(0, 0, 0, 0)
            tween(mainWindow, TI.Spring, {Size = UDim2.new(0, winW, 0, winH)})
            buildSettingsTab(windowObj)
        else
            statusLabel.Text      = "✗ Invalid license key"
            statusLabel.TextColor3 = ActiveTheme.Danger
            tween(licenseCard, TI.Fast, {Position = UDim2.new(0.5, -170 * scale + 8 * scale, 0.5, -150 * scale)})
            task.wait(0.05)
            tween(licenseCard, TI.Fast, {Position = UDim2.new(0.5, -170 * scale - 8 * scale, 0.5, -150 * scale)})
            task.wait(0.05)
            tween(licenseCard, TI.Fast, {Position = UDim2.new(0.5, -170 * scale, 0.5, -150 * scale)})
        end
    end)

    table.insert(sight.Windows, windowObj)
    return windowObj
end

return sight

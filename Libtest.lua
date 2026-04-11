local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local sight = {}
sight.Windows = {}
sight.IsMobile = UserInputService.TouchEnabled
sight.AccentColor = Color3.fromRGB(80, 180, 255)
sight.Themes = {
	Default = {
		Background     = Color3.fromRGB(18, 18, 18),
		Surface        = Color3.fromRGB(24, 24, 24),
		Elevated       = Color3.fromRGB(30, 30, 30),
		Border         = Color3.fromRGB(42, 42, 42),
		Text           = Color3.fromRGB(230, 230, 230),
		SubText        = Color3.fromRGB(130, 130, 130),
		Accent         = Color3.fromRGB(80, 180, 255),
		AccentDim      = Color3.fromRGB(50, 120, 190),
		Knob           = Color3.fromRGB(240, 240, 240),
		InputBg        = Color3.fromRGB(22, 22, 22),
	}
}
sight.ActiveTheme = "Default"
sight.Keybinds = {}
sight.UIScale = 1.0

local T = sight.Themes.Default

local TWEEN_FAST  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED   = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SLOW  = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local function ci(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local function tw(obj, goal, info)
	TweenService:Create(obj, info or TWEEN_MED, goal):Play()
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function addShadow(frame, transp, size)
	local s = ci("ImageLabel", {
		Name              = "Shadow",
		Image             = "rbxassetid://6014261993",
		ImageTransparency = transp or 0.5,
		ScaleType         = Enum.ScaleType.Slice,
		SliceCenter       = Rect.new(49, 49, 49, 49),
		Size              = UDim2.new(1, size or 20, 1, size or 20),
		Position          = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2),
		BackgroundTransparency = 1,
		ZIndex            = frame.ZIndex - 1,
		Parent            = frame,
	})
	return s
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color     = color or T.Border
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent    = parent
	return s
end

local function addPadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or 8)
	p.PaddingBottom = UDim.new(0, bottom or 8)
	p.PaddingLeft   = UDim.new(0, left   or 8)
	p.PaddingRight  = UDim.new(0, right  or 8)
	p.Parent        = parent
	return p
end

local function addListLayout(parent, dir, padding, halign, valign)
	local l = Instance.new("UIListLayout")
	l.FillDirection      = dir    or Enum.FillDirection.Vertical
	l.Padding            = UDim.new(0, padding or 6)
	l.SortOrder          = Enum.SortOrder.LayoutOrder
	l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment  = valign  or Enum.VerticalAlignment.Top
	l.Parent             = parent
	return l
end

local function glassFill(parent, col, transp)
	local g = ci("Frame", {
		Size                = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3    = col or Color3.new(1,1,1),
		BackgroundTransparency = transp or 0.82,
		ZIndex              = parent.ZIndex + 1,
		Parent              = parent,
	})
	addCorner(g, 6)
	return g
end

local function makeDraggable(frame, handle)
	local dragging, start, startPos = false, nil, nil
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			start     = inp.Position
			startPos  = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - start
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

local function hoverEffect(btn, base, hov)
	btn.MouseEnter:Connect(function()  tw(btn, {BackgroundColor3 = hov},  TWEEN_FAST) end)
	btn.MouseLeave:Connect(function()  tw(btn, {BackgroundColor3 = base}, TWEEN_FAST) end)
	btn.MouseButton1Down:Connect(function() tw(btn, {BackgroundColor3 = base:lerp(Color3.new(0,0,0), 0.15)}, TWEEN_FAST) end)
	btn.MouseButton1Up:Connect(function()   tw(btn, {BackgroundColor3 = hov},  TWEEN_FAST) end)
end

local function registerKeybind(key, callback)
	sight.Keybinds[key] = callback
end

UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	for key, cb in pairs(sight.Keybinds) do
		if inp.KeyCode == key then
			task.spawn(cb)
		end
	end
end)

local function buildSettingsTab(win)
	local sc = win.Scale
	local settingsTab = win:sightCreateTab("Settings", "⚙")

	local leftSec  = win:sightAddSection(settingsTab, "Config & Theme", "left")
	local rightSec = win:sightAddSection(settingsTab, "Customization", "right")

	win:sightAddLabel(leftSec, "Theme / Config Manager")

	win:sightAddButton(leftSec, {
		Text     = "Save Config",
		Callback = function()
			if win.OnSaveConfig then win.OnSaveConfig() end
		end
	})
	win:sightAddButton(leftSec, {
		Text     = "Load Config",
		Callback = function()
			if win.OnLoadConfig then win.OnLoadConfig() end
		end
	})

	local accentOptions = {"Blue", "Red", "Green", "Purple", "Orange"}
	win:sightAddDropdown(leftSec, {
		Text    = "Accent Color",
		Options = accentOptions,
		Default = "Blue",
		Callback = function(val)
			local map = {
				Blue   = Color3.fromRGB(80,  180, 255),
				Red    = Color3.fromRGB(255,  80,  80),
				Green  = Color3.fromRGB(80,  220, 130),
				Purple = Color3.fromRGB(160,  90, 255),
				Orange = Color3.fromRGB(255, 160,  60),
			}
			sight.AccentColor = map[val] or sight.AccentColor
		end
	})

	win:sightAddToggle(rightSec, {
		Text     = "Draggable",
		Default  = true,
		Callback = function(state)
			win.DraggingEnabled = state
		end
	})

	win:sightAddSlider(rightSec, {
		Text     = "UI Scale",
		Min      = 0.6,
		Max      = 1.4,
		Default  = 1.0,
		Suffix   = "x",
		Callback = function(val)
			sight.UIScale = val
		end
	})

	win:sightAddSlider(rightSec, {
		Text     = "UI Width",
		Min      = 380,
		Max      = 620,
		Default  = 440,
		Suffix   = "px",
		Callback = function(val)
			win.Main.Size = UDim2.new(0, val, 0, win.Main.Size.Y.Offset)
		end
	})

	win:sightAddSlider(rightSec, {
		Text     = "UI Height",
		Min      = 300,
		Max      = 560,
		Default  = 380,
		Suffix   = "px",
		Callback = function(val)
			win.Main.Size = UDim2.new(0, win.Main.Size.X.Offset, 0, val)
		end
	})
end

local function createWindowInternal(config)
	local sc = sight.IsMobile and 0.72 or 1.0
	local W  = (config.Width  or 440) * sc
	local H  = (config.Height or 380) * sc

	local screenGui = ci("ScreenGui", {
		Name            = "SightUI_" .. (config.Title or "Window"),
		Parent          = CoreGui,
		ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn    = false,
	})

	local mainFrame = ci("Frame", {
		Name             = "MainWindow",
		Size             = UDim2.new(0, W, 0, H),
		Position         = UDim2.new(0.5, -W/2 - (config.OffsetX or 100), 0.5, -H/2),
		BackgroundColor3 = T.Background,
		BorderSizePixel  = 0,
		Parent           = screenGui,
		ZIndex           = 2,
		ClipsDescendants = true,
	})
	addCorner(mainFrame, 8)
	addStroke(mainFrame, T.Border, 1)
	addShadow(mainFrame, 0.55, 24)

	local titleBar = ci("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 36 * sc),
		BackgroundColor3 = T.Surface,
		BorderSizePixel  = 0,
		Parent           = mainFrame,
		ZIndex           = 3,
	})
	addStroke(titleBar, T.Border, 1)

	local titleLabel = ci("TextLabel", {
		Text             = (config.Title or "SIGHT"):upper(),
		Font             = Enum.Font.GothamBold,
		TextSize         = math.floor(13 * sc),
		TextXAlignment   = Enum.TextXAlignment.Left,
		Size             = UDim2.new(0, 120 * sc, 1, 0),
		Position         = UDim2.new(0, 14 * sc, 0, 0),
		BackgroundTransparency = 1,
		TextColor3       = T.Text,
		Parent           = titleBar,
		ZIndex           = 4,
	})

	local subtitleLabel = ci("TextLabel", {
		Text             = config.Subtitle or "Premium Interface",
		Font             = Enum.Font.Gotham,
		TextSize         = math.floor(9 * sc),
		TextXAlignment   = Enum.TextXAlignment.Left,
		Size             = UDim2.new(0, 140 * sc, 1, 0),
		Position         = UDim2.new(0, 14 * sc, 0, 18 * sc),
		BackgroundTransparency = 1,
		TextColor3       = T.SubText,
		Parent           = titleBar,
		ZIndex           = 4,
	})

	local accentLine = ci("Frame", {
		Size             = UDim2.new(0, 3 * sc, 0.6, 0),
		Position         = UDim2.new(0, 6 * sc, 0.2, 0),
		BackgroundColor3 = sight.AccentColor,
		BorderSizePixel  = 0,
		Parent           = titleBar,
		ZIndex           = 4,
	})
	addCorner(accentLine, 2)

	local mainTabRow = ci("Frame", {
		Name             = "MainTabRow",
		Size             = UDim2.new(1, -(280 * sc), 1, 0),
		Position         = UDim2.new(0, 160 * sc, 0, 0),
		BackgroundTransparency = 1,
		Parent           = titleBar,
		ZIndex           = 4,
	})
	addListLayout(mainTabRow, Enum.FillDirection.Horizontal, math.floor(4 * sc), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

	local closeBtn = ci("TextButton", {
		Text             = "✕",
		Font             = Enum.Font.GothamBold,
		TextSize         = math.floor(10 * sc),
		Size             = UDim2.new(0, 26 * sc, 0, 26 * sc),
		Position         = UDim2.new(1, -32 * sc, 0.5, -13 * sc),
		BackgroundColor3 = Color3.fromRGB(200, 60, 60),
		TextColor3       = Color3.new(1,1,1),
		BorderSizePixel  = 0,
		Parent           = titleBar,
		ZIndex           = 5,
	})
	addCorner(closeBtn, 5)
	hoverEffect(closeBtn, Color3.fromRGB(200, 60, 60), Color3.fromRGB(230, 80, 80))
	closeBtn.MouseButton1Click:Connect(function()
		tw(mainFrame, {Size = UDim2.new(0, W, 0, 0)}, TWEEN_MED)
		task.wait(0.25)
		screenGui:Destroy()
	end)

	local minBtn = ci("TextButton", {
		Text             = "—",
		Font             = Enum.Font.GothamBold,
		TextSize         = math.floor(10 * sc),
		Size             = UDim2.new(0, 26 * sc, 0, 26 * sc),
		Position         = UDim2.new(1, -62 * sc, 0.5, -13 * sc),
		BackgroundColor3 = Color3.fromRGB(60, 60, 60),
		TextColor3       = T.SubText,
		BorderSizePixel  = 0,
		Parent           = titleBar,
		ZIndex           = 5,
	})
	addCorner(minBtn, 5)
	hoverEffect(minBtn, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		local targetH = minimized and (36 * sc) or H
		tw(mainFrame, {Size = UDim2.new(0, W, 0, targetH)}, TWEEN_MED)
	end)

	local subTabRow = ci("Frame", {
		Name             = "SubTabRow",
		Size             = UDim2.new(1, 0, 0, 28 * sc),
		Position         = UDim2.new(0, 0, 0, 36 * sc),
		BackgroundColor3 = T.Surface,
		BorderSizePixel  = 0,
		Parent           = mainFrame,
		ZIndex           = 3,
	})
	addStroke(subTabRow, T.Border, 1)
	local subTabPad = Instance.new("UIPadding")
	subTabPad.PaddingLeft = UDim.new(0, 10 * sc)
	subTabPad.Parent = subTabRow
	addListLayout(subTabRow, Enum.FillDirection.Horizontal, math.floor(8 * sc), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

	local contentHolder = ci("Frame", {
		Name             = "ContentHolder",
		Size             = UDim2.new(1, -16 * sc, 1, -(36 + 28 + 8) * sc),
		Position         = UDim2.new(0, 8 * sc, 0, (36 + 28 + 8) * sc),
		BackgroundTransparency = 1,
		Parent           = mainFrame,
		ZIndex           = 2,
		ClipsDescendants = true,
	})

	local leftCol = ci("Frame", {
		Name             = "LeftCol",
		Size             = UDim2.new(0.5, -4 * sc, 1, 0),
		BackgroundTransparency = 1,
		Parent           = contentHolder,
		ZIndex           = 2,
		ClipsDescendants = true,
	})
	local leftScroll = ci("ScrollingFrame", {
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = sight.AccentColor,
		CanvasSize       = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent           = leftCol,
		ZIndex           = 2,
	})
	addListLayout(leftScroll, Enum.FillDirection.Vertical, math.floor(6 * sc))

	local rightCol = ci("Frame", {
		Name             = "RightCol",
		Size             = UDim2.new(0.5, -4 * sc, 1, 0),
		Position         = UDim2.new(0.5, 4 * sc, 0, 0),
		BackgroundTransparency = 1,
		Parent           = contentHolder,
		ZIndex           = 2,
		ClipsDescendants = true,
	})
	local rightScroll = ci("ScrollingFrame", {
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = sight.AccentColor,
		CanvasSize       = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent           = rightCol,
		ZIndex           = 2,
	})
	addListLayout(rightScroll, Enum.FillDirection.Vertical, math.floor(6 * sc))

	local win = {
		Gui            = screenGui,
		Main           = mainFrame,
		TitleBar       = titleBar,
		MainTabRow     = mainTabRow,
		SubTabRow      = subTabRow,
		LeftScroll     = leftScroll,
		RightScroll    = rightScroll,
		Tabs           = {},
		ActiveTab      = nil,
		ActiveSubTab   = nil,
		Scale          = sc,
		DraggingEnabled = true,
	}

	makeDraggable(mainFrame, titleBar)

	local function refreshColumns(tabData)
		for _, c in ipairs(leftScroll:GetChildren()) do
			if c:IsA("Frame") then c.Visible = false end
		end
		for _, c in ipairs(rightScroll:GetChildren()) do
			if c:IsA("Frame") then c.Visible = false end
		end
		if not tabData then return end
		for _, sec in ipairs(tabData.LeftSections  or {}) do sec.Frame.Visible = true end
		for _, sec in ipairs(tabData.RightSections or {}) do sec.Frame.Visible = true end
	end

	function win:sightCreateTab(name, icon)
		local tabSc = self.Scale
		local tabBtn = ci("TextButton", {
			Text             = "",
			Size             = UDim2.new(0, 0, 1, 0),
			AutomaticSize    = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent           = self.MainTabRow,
			ZIndex           = 5,
		})
		addPadding(tabBtn, 0, 0, math.floor(10 * tabSc), math.floor(10 * tabSc))

		local innerRow = ci("Frame", {
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent           = tabBtn,
			ZIndex           = 5,
		})
		addListLayout(innerRow, Enum.FillDirection.Horizontal, math.floor(4 * tabSc), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

		local icLbl = ci("TextLabel", {
			Text             = icon or "○",
			Font             = Enum.Font.GothamBold,
			TextSize         = math.floor(10 * tabSc),
			Size             = UDim2.new(0, 14 * tabSc, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			Parent           = innerRow,
			ZIndex           = 5,
		})
		local txtLbl = ci("TextLabel", {
			Text             = name,
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(11 * tabSc),
			Size             = UDim2.new(0, 0, 1, 0),
			AutomaticSize    = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			Parent           = innerRow,
			ZIndex           = 5,
		})
		local underline = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, 2),
			Position         = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = sight.AccentColor,
			BorderSizePixel  = 0,
			Visible          = false,
			Parent           = tabBtn,
			ZIndex           = 6,
		})

		local tabData = {
			Button       = tabBtn,
			Icon         = icLbl,
			Text         = txtLbl,
			Underline    = underline,
			Name         = name,
			LeftSections = {},
			RightSections= {},
		}
		table.insert(self.Tabs, tabData)

		local function activateTab()
			if self.ActiveTab == tabData then return end
			for _, t in ipairs(self.Tabs) do
				tw(t.Icon, {TextColor3 = T.SubText}, TWEEN_FAST)
				tw(t.Text, {TextColor3 = T.SubText}, TWEEN_FAST)
				t.Underline.Visible = false
			end
			tw(icLbl,  {TextColor3 = sight.AccentColor}, TWEEN_FAST)
			tw(txtLbl, {TextColor3 = T.Text},            TWEEN_FAST)
			underline.Visible = true
			self.ActiveTab = tabData
			refreshColumns(tabData)
		end

		tabBtn.MouseButton1Click:Connect(activateTab)
		tabBtn.MouseEnter:Connect(function()
			if self.ActiveTab ~= tabData then
				tw(txtLbl, {TextColor3 = T.Text}, TWEEN_FAST)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if self.ActiveTab ~= tabData then
				tw(txtLbl, {TextColor3 = T.SubText}, TWEEN_FAST)
			end
		end)

		if #self.Tabs == 1 then
			activateTab()
		end

		return tabData
	end

	function win:sightCreateSubTab(name)
		local tabSc = self.Scale
		local subBtn = ci("TextButton", {
			Text             = name,
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * tabSc),
			Size             = UDim2.new(0, 0, 1, 0),
			AutomaticSize    = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			Parent           = self.SubTabRow,
			ZIndex           = 4,
		})
		addPadding(subBtn, 0, 0, math.floor(8 * tabSc), math.floor(8 * tabSc))

		local subUnder = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, 2),
			Position         = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = sight.AccentColor,
			BorderSizePixel  = 0,
			Visible          = false,
			Parent           = subBtn,
			ZIndex           = 5,
		})

		local subData = {Button = subBtn, Underline = subUnder, Name = name}
		table.insert(self.Tabs[#self.Tabs] and {} or {}, subData)

		local function activateSub()
			if self.ActiveSubTab == subData then return end
			for _, s in pairs(self.SubTabRow:GetChildren()) do
				if s:IsA("TextButton") then
					tw(s, {TextColor3 = T.SubText}, TWEEN_FAST)
					local u = s:FindFirstChildOfClass("Frame")
					if u then u.Visible = false end
				end
			end
			tw(subBtn, {TextColor3 = T.Text}, TWEEN_FAST)
			subUnder.Visible = true
			self.ActiveSubTab = subData
			if self.SubTabChanged then self:SubTabChanged(subData) end
		end

		subBtn.MouseButton1Click:Connect(activateSub)
		subBtn.MouseEnter:Connect(function()
			if self.ActiveSubTab ~= subData then tw(subBtn, {TextColor3 = T.Text}, TWEEN_FAST) end
		end)
		subBtn.MouseLeave:Connect(function()
			if self.ActiveSubTab ~= subData then tw(subBtn, {TextColor3 = T.SubText}, TWEEN_FAST) end
		end)

		return subData
	end

	function win:sightAddSection(tab, title, column)
		local secSc = self.Scale
		local parent = column == "left" and self.LeftScroll or self.RightScroll

		local secFrame = ci("Frame", {
			Size             = UDim2.new(1, -4 * secSc, 0, 0),
			AutomaticSize    = Enum.AutomaticSize.Y,
			BackgroundColor3 = T.Surface,
			BorderSizePixel  = 0,
			Visible          = false,
			Parent           = parent,
			ZIndex           = 2,
		})
		addCorner(secFrame, 6)
		addStroke(secFrame, T.Border, 1)
		addShadow(secFrame, 0.75, 12)
		addPadding(secFrame, math.floor(6 * secSc), math.floor(8 * secSc), math.floor(8 * secSc), math.floor(8 * secSc))

		local layout = addListLayout(secFrame, Enum.FillDirection.Vertical, math.floor(5 * secSc))

		local header = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(20 * secSc)),
			BackgroundTransparency = 1,
			Parent           = secFrame,
			ZIndex           = 3,
			LayoutOrder      = -999,
		})

		local headerDot = ci("Frame", {
			Size             = UDim2.new(0, 3 * secSc, 0, 12 * secSc),
			Position         = UDim2.new(0, 0, 0.5, -6 * secSc),
			BackgroundColor3 = sight.AccentColor,
			BorderSizePixel  = 0,
			Parent           = header,
			ZIndex           = 3,
		})
		addCorner(headerDot, 2)

		local headerTxt = ci("TextLabel", {
			Text             = title:upper(),
			Font             = Enum.Font.GothamBold,
			TextSize         = math.floor(9 * secSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0, 0, 1, 0),
			Position         = UDim2.new(0, math.floor(8 * secSc), 0, 0),
			AutomaticSize    = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			Parent           = header,
			ZIndex           = 3,
		})

		local lineFrame = ci("Frame", {
			Size             = UDim2.new(1, -8 * secSc, 0, 1),
			Position         = UDim2.new(0, 0, 0, math.floor(22 * secSc)),
			BackgroundColor3 = T.Border,
			BorderSizePixel  = 0,
			Parent           = secFrame,
			ZIndex           = 3,
			LayoutOrder      = -998,
		})

		local secData = {
			Frame     = secFrame,
			Layout    = layout,
			Elements  = {},
		}

		if column == "left" then
			table.insert(tab.LeftSections,  secData)
		else
			table.insert(tab.RightSections, secData)
		end

		return secData
	end

	function win:sightAddLabel(section, text)
		local lSc = self.Scale
		local lbl = ci("TextLabel", {
			Text             = text or "",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * lSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(1, 0, 0, math.floor(18 * lSc)),
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			TextWrapped      = true,
			Parent           = section.Frame,
			ZIndex           = 3,
		})
		return lbl
	end

	function win:sightAddButton(section, config)
		local bSc = self.Scale
		local btn = ci("TextButton", {
			Text             = config.Text or "Button",
			Font             = Enum.Font.GothamBold,
			TextSize         = math.floor(11 * bSc),
			Size             = UDim2.new(1, 0, 0, math.floor(26 * bSc)),
			BackgroundColor3 = T.Elevated,
			TextColor3       = T.Text,
			BorderSizePixel  = 0,
			Parent           = section.Frame,
			ZIndex           = 3,
		})
		addCorner(btn, 5)
		addStroke(btn, T.Border, 1)
		hoverEffect(btn, T.Elevated, T.Elevated:lerp(sight.AccentColor, 0.12))

		if config.Keybind then
			local kLbl = ci("TextLabel", {
				Text             = "[" .. config.Keybind .. "]",
				Font             = Enum.Font.Gotham,
				TextSize         = math.floor(8 * bSc),
				Size             = UDim2.new(0, 36 * bSc, 1, 0),
				Position         = UDim2.new(1, -38 * bSc, 0, 0),
				BackgroundTransparency = 1,
				TextColor3       = T.SubText,
				Parent           = btn,
				ZIndex           = 4,
			})
		end

		btn.MouseButton1Click:Connect(function()
			if config.Callback then task.spawn(config.Callback) end
			tw(btn, {BackgroundColor3 = sight.AccentColor:lerp(T.Elevated, 0.5)}, TWEEN_FAST)
			task.wait(0.12)
			tw(btn, {BackgroundColor3 = T.Elevated}, TWEEN_MED)
		end)

		return btn
	end

	function win:sightAddToggle(section, config)
		local tSc = self.Scale
		local row = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(24 * tSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local lbl = ci("TextLabel", {
			Text             = config.Text or "Toggle",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(11 * tSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(1, -48 * tSc, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = row,
			ZIndex           = 3,
		})

		if config.Keybind then
			local kLbl = ci("TextLabel", {
				Text             = "[" .. config.Keybind .. "]",
				Font             = Enum.Font.Gotham,
				TextSize         = math.floor(8 * tSc),
				Size             = UDim2.new(0, 36 * tSc, 1, 0),
				Position         = UDim2.new(0.6, 0, 0, 0),
				BackgroundTransparency = 1,
				TextColor3       = T.SubText,
				Parent           = row,
				ZIndex           = 3,
			})
		end

		local trackW, trackH = math.floor(36 * tSc), math.floor(18 * tSc)
		local track = ci("TextButton", {
			Text             = "",
			Size             = UDim2.new(0, trackW, 0, trackH),
			Position         = UDim2.new(1, -trackW, 0.5, -trackH/2),
			BackgroundColor3 = config.Default and sight.AccentColor or T.Elevated,
			BorderSizePixel  = 0,
			Parent           = row,
			ZIndex           = 4,
		})
		addCorner(track, trackH)
		addStroke(track, T.Border, 1)

		local knobSz = math.floor(12 * tSc)
		local knobOff = config.Default and (trackW - knobSz - 3) or 3
		local knob = ci("Frame", {
			Size             = UDim2.new(0, knobSz, 0, knobSz),
			Position         = UDim2.new(0, knobOff, 0.5, -knobSz/2),
			BackgroundColor3 = T.Knob,
			BorderSizePixel  = 0,
			Parent           = track,
			ZIndex           = 5,
		})
		addCorner(knob, knobSz)
		glassFill(knob, Color3.new(1,1,1), 0.65)

		local enabled = config.Default or false
		local function setState(state, silent)
			enabled = state
			local goalPos  = state and UDim2.new(0, trackW - knobSz - 3, 0.5, -knobSz/2) or UDim2.new(0, 3, 0.5, -knobSz/2)
			local goalCol  = state and sight.AccentColor or T.Elevated
			tw(knob,  {Position = goalPos},         TWEEN_MED)
			tw(track, {BackgroundColor3 = goalCol}, TWEEN_MED)
			if not silent and config.Callback then task.spawn(config.Callback, state) end
		end

		track.MouseButton1Click:Connect(function() setState(not enabled) end)

		if config.Keybind then
			registerKeybind(Enum.KeyCode[config.Keybind] or config.Keybind, function()
				setState(not enabled)
			end)
		end

		local obj = {
			Set = function(_, state) setState(state, true) end,
			Get = function() return enabled end,
		}
		return obj
	end

	function win:sightAddSlider(section, config)
		local sSc = self.Scale
		local min, max = config.Min or 0, config.Max or 100
		local def = math.clamp(config.Default or min, min, max)
		local pct = (def - min) / (max - min)

		local outer = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(40 * sSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local topRow = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(16 * sSc)),
			BackgroundTransparency = 1,
			Parent           = outer,
			ZIndex           = 3,
		})
		local nameLbl = ci("TextLabel", {
			Text             = config.Text or "Slider",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * sSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.7, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = topRow,
			ZIndex           = 3,
		})
		local valLbl = ci("TextLabel", {
			Text             = tostring(def) .. (config.Suffix or ""),
			Font             = Enum.Font.GothamBold,
			TextSize         = math.floor(9 * sSc),
			TextXAlignment   = Enum.TextXAlignment.Right,
			Size             = UDim2.new(0.3, 0, 1, 0),
			Position         = UDim2.new(0.7, 0, 0, 0),
			BackgroundTransparency = 1,
			TextColor3       = sight.AccentColor,
			Parent           = topRow,
			ZIndex           = 3,
		})

		local barH = math.floor(4 * sSc)
		local track = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, barH),
			Position         = UDim2.new(0, 0, 0, math.floor(22 * sSc)),
			BackgroundColor3 = T.Elevated,
			BorderSizePixel  = 0,
			Parent           = outer,
			ZIndex           = 3,
		})
		addCorner(track, barH)
		addStroke(track, T.Border, 1)

		local fill = ci("Frame", {
			Size             = UDim2.new(pct, 0, 1, 0),
			BackgroundColor3 = sight.AccentColor,
			BorderSizePixel  = 0,
			Parent           = track,
			ZIndex           = 4,
		})
		addCorner(fill, barH)

		local knobSz = math.floor(12 * sSc)
		local knob = ci("Frame", {
			Size             = UDim2.new(0, knobSz, 0, knobSz),
			Position         = UDim2.new(pct, -knobSz/2, 0.5, -knobSz/2),
			BackgroundColor3 = T.Knob,
			BorderSizePixel  = 0,
			Parent           = track,
			ZIndex           = 5,
		})
		addCorner(knob, knobSz)
		addShadow(knob, 0.6, 8)
		glassFill(knob, Color3.new(1,1,1), 0.55)

		local function round(n, dec)
			local m = 10^(dec or 0)
			return math.floor(n * m + 0.5) / m
		end
		local function updateSlider(relX)
			relX = math.clamp(relX, 0, 1)
			local raw  = min + (max - min) * relX
			local dp   = (config.Step and 0) or (tostring(config.Min or 0):find("%.") and 1 or 0)
			local val  = round(raw, dp)
			fill.Size  = UDim2.new(relX, 0, 1, 0)
			knob.Position = UDim2.new(relX, -knobSz/2, 0.5, -knobSz/2)
			valLbl.Text = tostring(val) .. (config.Suffix or "")
			if config.Callback then task.spawn(config.Callback, val) end
		end

		local dragging = false
		local ib = Instance.new("TextButton")
		ib.Size = UDim2.new(1, 0, 1, 0)
		ib.BackgroundTransparency = 1
		ib.Text = ""
		ib.ZIndex = 6
		ib.Parent = track

		ib.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local rx = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
				updateSlider(rx)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local rx = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
				updateSlider(rx)
			end
		end)

		return outer
	end

	function win:sightAddDropdown(section, config)
		local dSc = self.Scale
		local selected = config.Default or (config.Options and config.Options[1]) or ""
		local isOpen = false

		local wrap = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(28 * dSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local nameLbl = ci("TextLabel", {
			Text             = config.Text or "Dropdown",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * dSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = wrap,
			ZIndex           = 3,
		})

		local btnW = math.floor(0.56 * (section.Frame.AbsoluteSize.X > 0 and section.Frame.AbsoluteSize.X or 160))
		local dropBtn = ci("TextButton", {
			Text             = selected,
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * dSc),
			Size             = UDim2.new(0.58, 0, 0, math.floor(22 * dSc)),
			Position         = UDim2.new(0.42, 0, 0.5, -math.floor(11 * dSc)),
			BackgroundColor3 = T.Elevated,
			TextColor3       = T.Text,
			BorderSizePixel  = 0,
			Parent           = wrap,
			ZIndex           = 4,
		})
		addCorner(dropBtn, 5)
		addStroke(dropBtn, T.Border, 1)

		local arrow = ci("TextLabel", {
			Text             = "▾",
			Font             = Enum.Font.GothamBold,
			TextSize         = math.floor(10 * dSc),
			Size             = UDim2.new(0, 16 * dSc, 1, 0),
			Position         = UDim2.new(1, -18 * dSc, 0, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			Parent           = dropBtn,
			ZIndex           = 5,
		})

		local menuHeight = #(config.Options or {}) * math.floor(22 * dSc)
		local menu = ci("Frame", {
			Size             = UDim2.new(0.58, 0, 0, menuHeight),
			Position         = UDim2.new(0.42, 0, 0, math.floor(30 * dSc)),
			BackgroundColor3 = T.Surface,
			BorderSizePixel  = 0,
			Visible          = false,
			ZIndex           = 20,
			Parent           = section.Frame,
		})
		addCorner(menu, 5)
		addStroke(menu, T.Border, 1)
		addShadow(menu, 0.5, 14)
		addListLayout(menu, Enum.FillDirection.Vertical, 0)

		local function closeMenu()
			isOpen = false
			tw(menu, {Size = UDim2.new(0.58, 0, 0, 0)}, TWEEN_FAST)
			task.wait(0.12)
			menu.Visible = false
			tw(arrow, {Rotation = 0}, TWEEN_FAST)
		end
		local function openMenu()
			isOpen = true
			menu.Visible = true
			menu.Size = UDim2.new(0.58, 0, 0, 0)
			tw(menu, {Size = UDim2.new(0.58, 0, 0, menuHeight)}, TWEEN_MED)
			tw(arrow, {Rotation = 180}, TWEEN_FAST)
		end

		for _, opt in ipairs(config.Options or {}) do
			local optBtn = ci("TextButton", {
				Text             = opt,
				Font             = Enum.Font.Gotham,
				TextSize         = math.floor(10 * dSc),
				Size             = UDim2.new(1, 0, 0, math.floor(22 * dSc)),
				BackgroundColor3 = T.Surface,
				TextColor3       = T.Text,
				BorderSizePixel  = 0,
				Parent           = menu,
				ZIndex           = 21,
			})
			optBtn.MouseEnter:Connect(function() tw(optBtn, {BackgroundColor3 = T.Elevated}, TWEEN_FAST) end)
			optBtn.MouseLeave:Connect(function() tw(optBtn, {BackgroundColor3 = T.Surface},  TWEEN_FAST) end)
			optBtn.MouseButton1Click:Connect(function()
				selected = opt
				dropBtn.Text = opt
				closeMenu()
				if config.Callback then task.spawn(config.Callback, opt) end
			end)
		end

		dropBtn.MouseButton1Click:Connect(function()
			if isOpen then closeMenu() else openMenu() end
		end)

		return wrap
	end

	function win:sightAddMultiDropdown(section, config)
		local mSc = self.Scale
		local selected = {}
		if config.Default then for _, v in ipairs(config.Default) do selected[v] = true end end
		local isOpen = false

		local wrap = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(28 * mSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local nameLbl = ci("TextLabel", {
			Text             = config.Text or "Multi-Select",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * mSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = wrap,
			ZIndex           = 3,
		})

		local function getDisplayText()
			local keys = {}
			for k in pairs(selected) do table.insert(keys, k) end
			return #keys == 0 and "None" or table.concat(keys, ", ")
		end

		local dropBtn = ci("TextButton", {
			Text             = getDisplayText(),
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(9 * mSc),
			TextTruncate     = Enum.TextTruncate.AtEnd,
			Size             = UDim2.new(0.58, 0, 0, math.floor(22 * mSc)),
			Position         = UDim2.new(0.42, 0, 0.5, -math.floor(11 * mSc)),
			BackgroundColor3 = T.Elevated,
			TextColor3       = T.Text,
			BorderSizePixel  = 0,
			Parent           = wrap,
			ZIndex           = 4,
		})
		addCorner(dropBtn, 5)
		addStroke(dropBtn, T.Border, 1)

		local arrow = ci("TextLabel", {
			Text             = "▾",
			Font             = Enum.Font.GothamBold,
			TextSize         = math.floor(10 * mSc),
			Size             = UDim2.new(0, 16 * mSc, 1, 0),
			Position         = UDim2.new(1, -18 * mSc, 0, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.SubText,
			Parent           = dropBtn,
			ZIndex           = 5,
		})

		local optH   = math.floor(22 * mSc)
		local menuH  = #(config.Options or {}) * optH
		local menu   = ci("Frame", {
			Size             = UDim2.new(0.58, 0, 0, menuH),
			Position         = UDim2.new(0.42, 0, 0, math.floor(30 * mSc)),
			BackgroundColor3 = T.Surface,
			BorderSizePixel  = 0,
			Visible          = false,
			ZIndex           = 20,
			Parent           = section.Frame,
		})
		addCorner(menu, 5)
		addStroke(menu, T.Border, 1)
		addShadow(menu, 0.5, 14)
		addListLayout(menu, Enum.FillDirection.Vertical, 0)

		local checkFrames = {}
		for _, opt in ipairs(config.Options or {}) do
			local optBtn = ci("TextButton", {
				Text             = "",
				Size             = UDim2.new(1, 0, 0, optH),
				BackgroundColor3 = T.Surface,
				BorderSizePixel  = 0,
				Parent           = menu,
				ZIndex           = 21,
			})
			local checkBox = ci("Frame", {
				Size             = UDim2.new(0, 12 * mSc, 0, 12 * mSc),
				Position         = UDim2.new(0, 6 * mSc, 0.5, -6 * mSc),
				BackgroundColor3 = selected[opt] and sight.AccentColor or T.Elevated,
				BorderSizePixel  = 0,
				Parent           = optBtn,
				ZIndex           = 22,
			})
			addCorner(checkBox, 3)
			addStroke(checkBox, T.Border, 1)

			local checkMark = ci("TextLabel", {
				Text             = "✓",
				Font             = Enum.Font.GothamBold,
				TextSize         = math.floor(8 * mSc),
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3       = Color3.new(1,1,1),
				Visible          = selected[opt] or false,
				Parent           = checkBox,
				ZIndex           = 23,
			})
			local optLbl = ci("TextLabel", {
				Text             = opt,
				Font             = Enum.Font.Gotham,
				TextSize         = math.floor(10 * mSc),
				TextXAlignment   = Enum.TextXAlignment.Left,
				Size             = UDim2.new(1, -24 * mSc, 1, 0),
				Position         = UDim2.new(0, 24 * mSc, 0, 0),
				BackgroundTransparency = 1,
				TextColor3       = T.Text,
				Parent           = optBtn,
				ZIndex           = 22,
			})

			checkFrames[opt] = {box = checkBox, mark = checkMark}
			optBtn.MouseEnter:Connect(function() tw(optBtn, {BackgroundColor3 = T.Elevated}, TWEEN_FAST) end)
			optBtn.MouseLeave:Connect(function() tw(optBtn, {BackgroundColor3 = T.Surface},  TWEEN_FAST) end)
			optBtn.MouseButton1Click:Connect(function()
				selected[opt] = not selected[opt]
				tw(checkBox, {BackgroundColor3 = selected[opt] and sight.AccentColor or T.Elevated}, TWEEN_FAST)
				checkMark.Visible = selected[opt]
				dropBtn.Text = getDisplayText()
				if config.Callback then
					local result = {}
					for k, v in pairs(selected) do if v then table.insert(result, k) end end
					task.spawn(config.Callback, result)
				end
			end)
		end

		local function closeMenu()
			isOpen = false
			tw(menu, {Size = UDim2.new(0.58, 0, 0, 0)}, TWEEN_FAST)
			task.wait(0.12)
			menu.Visible = false
			tw(arrow, {Rotation = 0}, TWEEN_FAST)
		end
		local function openMenu()
			isOpen = true
			menu.Visible = true
			menu.Size = UDim2.new(0.58, 0, 0, 0)
			tw(menu, {Size = UDim2.new(0.58, 0, 0, menuH)}, TWEEN_MED)
			tw(arrow, {Rotation = 180}, TWEEN_FAST)
		end

		dropBtn.MouseButton1Click:Connect(function()
			if isOpen then closeMenu() else openMenu() end
		end)

		return wrap
	end

	function win:sightAddTextbox(section, config)
		local tbSc = self.Scale
		local wrap = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(28 * tbSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local nameLbl = ci("TextLabel", {
			Text             = config.Text or "Input",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * tbSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = wrap,
			ZIndex           = 3,
		})

		local box = ci("TextBox", {
			PlaceholderText  = config.Placeholder or "Enter text...",
			Text             = config.Default or "",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * tbSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.58, 0, 0, math.floor(22 * tbSc)),
			Position         = UDim2.new(0.42, 0, 0.5, -math.floor(11 * tbSc)),
			BackgroundColor3 = T.InputBg,
			TextColor3       = T.Text,
			PlaceholderColor3 = T.SubText,
			BorderSizePixel  = 0,
			ClearTextOnFocus = config.ClearOnFocus ~= false,
			Parent           = wrap,
			ZIndex           = 4,
		})
		addCorner(box, 5)
		addStroke(box, T.Border, 1)
		addPadding(box, 0, 0, math.floor(6 * tbSc), math.floor(6 * tbSc))

		box.Focused:Connect(function()
			tw(box, {BackgroundColor3 = T.Elevated}, TWEEN_FAST)
		end)
		box.FocusLost:Connect(function(enter)
			tw(box, {BackgroundColor3 = T.InputBg}, TWEEN_FAST)
			if config.Callback then task.spawn(config.Callback, box.Text, enter) end
		end)

		return wrap
	end

	function win:sightAddColorBox(section, config)
		local cSc = self.Scale
		local currentColor = config.Default or Color3.fromRGB(255, 255, 255)

		local wrap = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(26 * cSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local nameLbl = ci("TextLabel", {
			Text             = config.Text or "Color",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * cSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.65, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = wrap,
			ZIndex           = 3,
		})

		local boxSz = math.floor(22 * cSc)
		local colorBtn = ci("TextButton", {
			Text             = "",
			Size             = UDim2.new(0, boxSz * 2, 0, boxSz),
			Position         = UDim2.new(1, -boxSz * 2, 0.5, -boxSz/2),
			BackgroundColor3 = currentColor,
			BorderSizePixel  = 0,
			Parent           = wrap,
			ZIndex           = 4,
		})
		addCorner(colorBtn, 5)
		addStroke(colorBtn, T.Border, 1)
		glassFill(colorBtn, Color3.new(1,1,1), 0.75)

		local hexLbl = ci("TextLabel", {
			Text             = "#" .. string.format("%02X%02X%02X", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255)),
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(8 * cSc),
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = Color3.new(1,1,1),
			Parent           = colorBtn,
			ZIndex           = 5,
		})

		colorBtn.MouseButton1Click:Connect(function()
			if config.Callback then task.spawn(config.Callback, currentColor) end
		end)

		local obj = {
			SetColor = function(_, col)
				currentColor = col
				tw(colorBtn, {BackgroundColor3 = col}, TWEEN_FAST)
				hexLbl.Text = "#" .. string.format("%02X%02X%02X", math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255))
			end,
			GetColor = function() return currentColor end,
		}
		return obj
	end

	function win:sightAddPickerBox(section, config)
		local pSc = self.Scale
		local wrap = ci("Frame", {
			Size             = UDim2.new(1, 0, 0, math.floor(26 * pSc)),
			BackgroundTransparency = 1,
			Parent           = section.Frame,
			ZIndex           = 3,
		})

		local nameLbl = ci("TextLabel", {
			Text             = config.Text or "Picker",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(10 * pSc),
			TextXAlignment   = Enum.TextXAlignment.Left,
			Size             = UDim2.new(0.65, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3       = T.Text,
			Parent           = wrap,
			ZIndex           = 3,
		})

		local btnSz = math.floor(22 * pSc)
		local pickerBtn = ci("TextButton", {
			Text             = config.Default or "Select…",
			Font             = Enum.Font.Gotham,
			TextSize         = math.floor(9 * pSc),
			TextTruncate     = Enum.TextTruncate.AtEnd,
			Size             = UDim2.new(0, btnSz * 3, 0, btnSz),
			Position         = UDim2.new(1, -btnSz * 3, 0.5, -btnSz/2),
			BackgroundColor3 = T.Elevated,
			TextColor3       = sight.AccentColor,
			BorderSizePixel  = 0,
			Parent           = wrap,
			ZIndex           = 4,
		})
		addCorner(pickerBtn, 5)
		addStroke(pickerBtn, T.Border, 1)
		hoverEffect(pickerBtn, T.Elevated, T.Elevated:lerp(sight.AccentColor, 0.1))

		pickerBtn.MouseButton1Click:Connect(function()
			if config.Callback then task.spawn(config.Callback) end
		end)

		local obj = {
			SetText = function(_, txt) pickerBtn.Text = txt end,
			GetText = function() return pickerBtn.Text end,
		}
		return obj
	end

	function win:sightSetKeybind(key, callback)
		registerKeybind(key, callback)
	end

	return win
end

function sight.CreateWindow(config)
	config = config or {}
	local win = createWindowInternal(config)
	table.insert(sight.Windows, win)

	buildSettingsTab(win)

	local sc = win.Scale
	local loginW = math.floor(210 * sc)
	local loginH = math.floor(170 * sc)

	local loginFrame = ci("Frame", {
		Name             = "LoginWindow",
		Size             = UDim2.new(0, loginW, 0, loginH),
		Position         = UDim2.new(0.5, win.Main.Size.X.Offset/2 + math.floor(18 * sc), 0.5, -loginH/2),
		BackgroundColor3 = T.Background,
		BorderSizePixel  = 0,
		Parent           = win.Gui,
		ZIndex           = 3,
	})
	addCorner(loginFrame, 8)
	addStroke(loginFrame, T.Border, 1)
	addShadow(loginFrame, 0.5, 24)

	local loginTitleBar = ci("Frame", {
		Size             = UDim2.new(1, 0, 0, math.floor(28 * sc)),
		BackgroundTransparency = 1,
		Parent           = loginFrame,
		ZIndex           = 4,
	})
	makeDraggable(loginFrame, loginTitleBar)

	local loginInner = ci("Frame", {
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent           = loginFrame,
		ZIndex           = 4,
	})
	addPadding(loginInner, math.floor(14 * sc), math.floor(14 * sc), math.floor(14 * sc), math.floor(14 * sc))
	addListLayout(loginInner, Enum.FillDirection.Vertical, math.floor(10 * sc), Enum.HorizontalAlignment.Center)

	local logoRow = ci("Frame", {
		Size             = UDim2.new(1, 0, 0, math.floor(28 * sc)),
		BackgroundTransparency = 1,
		Parent           = loginInner,
		ZIndex           = 4,
	})
	local logoAccent = ci("Frame", {
		Size             = UDim2.new(0, 3 * sc, 1, 0),
		Position         = UDim2.new(0.5, -38 * sc, 0, 0),
		BackgroundColor3 = sight.AccentColor,
		BorderSizePixel  = 0,
		Parent           = logoRow,
		ZIndex           = 5,
	})
	addCorner(logoAccent, 2)
	local loginTitle = ci("TextLabel", {
		Text             = (config.Title or "SIGHT"):upper(),
		Font             = Enum.Font.GothamBold,
		TextSize         = math.floor(15 * sc),
		Size             = UDim2.new(0.7, 0, 1, 0),
		Position         = UDim2.new(0.15, 0, 0, 0),
		BackgroundTransparency = 1,
		TextColor3       = T.Text,
		Parent           = logoRow,
		ZIndex           = 5,
	})

	local inputH = math.floor(30 * sc)
	local licenseBox = ci("TextBox", {
		PlaceholderText  = "Enter license key…",
		Text             = "",
		Font             = Enum.Font.Gotham,
		TextSize         = math.floor(10 * sc),
		TextXAlignment   = Enum.TextXAlignment.Left,
		Size             = UDim2.new(1, 0, 0, inputH),
		BackgroundColor3 = T.InputBg,
		TextColor3       = T.Text,
		PlaceholderColor3 = T.SubText,
		BorderSizePixel  = 0,
		ClearTextOnFocus = false,
		Parent           = loginInner,
		ZIndex           = 5,
	})
	addCorner(licenseBox, 5)
	addStroke(licenseBox, T.Border, 1)
	addPadding(licenseBox, 0, 0, math.floor(8 * sc), math.floor(8 * sc))
	licenseBox.Focused:Connect(function()
		tw(licenseBox, {BackgroundColor3 = T.Elevated}, TWEEN_FAST)
	end)
	licenseBox.FocusLost:Connect(function()
		tw(licenseBox, {BackgroundColor3 = T.InputBg}, TWEEN_FAST)
	end)

	local loginBtn = ci("TextButton", {
		Text             = "LOGIN",
		Font             = Enum.Font.GothamBold,
		TextSize         = math.floor(12 * sc),
		Size             = UDim2.new(1, 0, 0, math.floor(30 * sc)),
		BackgroundColor3 = sight.AccentColor,
		TextColor3       = Color3.new(1, 1, 1),
		BorderSizePixel  = 0,
		Parent           = loginInner,
		ZIndex           = 5,
	})
	addCorner(loginBtn, 5)
	addShadow(loginBtn, 0.55, 10)
	glassFill(loginBtn, Color3.new(1,1,1), 0.82)
	hoverEffect(loginBtn, sight.AccentColor, sight.AccentColor:lerp(Color3.new(1,1,1), 0.12))

	local statusLbl = ci("TextLabel", {
		Text             = "",
		Font             = Enum.Font.Gotham,
		TextSize         = math.floor(9 * sc),
		Size             = UDim2.new(1, 0, 0, math.floor(14 * sc)),
		BackgroundTransparency = 1,
		TextColor3       = Color3.fromRGB(255, 80, 80),
		Parent           = loginInner,
		ZIndex           = 5,
	})

	win.LoginFrame   = loginFrame
	win.LoginButton  = loginBtn
	win.LicenseInput = licenseBox
	win.StatusLabel  = statusLbl

	loginBtn.MouseButton1Click:Connect(function()
		local key = licenseBox.Text
		if config.OnLogin then
			task.spawn(config.OnLogin, key, function(success, msg)
				statusLbl.TextColor3 = success and Color3.fromRGB(80, 220, 130) or Color3.fromRGB(255, 80, 80)
				statusLbl.Text = msg or ""
				if success then
					task.wait(0.5)
					tw(loginFrame, {Size = UDim2.new(0, loginW, 0, 0)}, TWEEN_MED)
					task.wait(0.25)
					loginFrame:Destroy()
				end
			end)
		else
			statusLbl.TextColor3 = Color3.fromRGB(80, 220, 130)
			statusLbl.Text = "✓ Authenticated"
			task.wait(0.6)
			tw(loginFrame, {Size = UDim2.new(0, loginW, 0, 0)}, TWEEN_MED)
			task.wait(0.25)
			loginFrame:Destroy()
		end
	end)

	if sight.IsMobile then
		local toggleBtnSz = 44
		local mobileToggle = ci("TextButton", {
			Text             = "👁",
			Font             = Enum.Font.GothamBold,
			TextSize         = 18,
			Size             = UDim2.new(0, toggleBtnSz, 0, toggleBtnSz),
			Position         = UDim2.new(1, -toggleBtnSz - 12, 0.5, -toggleBtnSz/2),
			BackgroundColor3 = T.Surface,
			TextColor3       = T.Text,
			BorderSizePixel  = 0,
			Parent           = win.Gui,
			ZIndex           = 99,
		})
		addCorner(mobileToggle, toggleBtnSz)
		addStroke(mobileToggle, sight.AccentColor, 2)
		addShadow(mobileToggle, 0.5, 12)
		glassFill(mobileToggle, sight.AccentColor, 0.75)

		local guiVisible = true
		mobileToggle.MouseButton1Click:Connect(function()
			guiVisible = not guiVisible
			tw(win.Main, {BackgroundTransparency = guiVisible and 0 or 1}, TWEEN_MED)
			win.Main.Visible = guiVisible
			loginFrame.Visible = guiVisible
		end)
	else
		local uiVisible = true
		if config.ToggleKey then
			sight.Keybinds[config.ToggleKey] = function()
				uiVisible = not uiVisible
				win.Main.Visible = uiVisible
				if win.LoginFrame and win.LoginFrame.Parent then
					win.LoginFrame.Visible = uiVisible
				end
			end
		end
	end

	tw(win.Main, {BackgroundTransparency = 0}, TWEEN_SLOW)

	return win
end

return sight

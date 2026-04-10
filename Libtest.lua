local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Sight = {}
Sight.Windows = {}
Sight.IsMobile = UserInputService.TouchEnabled
Sight.AccentColor = Color3.fromRGB(80, 180, 255)

local function createInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties) do
		instance[prop] = value
	end
	return instance
end

local function applyTheme(element, themeType, customColor)
	local themes = {
		Background = Color3.fromRGB(18, 18, 18),
		LighterBackground = Color3.fromRGB(28, 28, 28),
		Accent = Sight.AccentColor,
		Text = Color3.fromRGB(235, 235, 235),
		SubText = Color3.fromRGB(150, 150, 150),
		Border = Color3.fromRGB(45, 45, 45)
	}
	local color = customColor or themes[themeType]
	if themeType == "Background" then
		element.BackgroundColor3 = color
	elseif themeType == "LighterBackground" then
		element.BackgroundColor3 = color
	elseif themeType == "Accent" then
		element.BackgroundColor3 = color
	elseif themeType == "Text" then
		element.TextColor3 = color
	elseif themeType == "SubText" then
		element.TextColor3 = color
	elseif themeType == "Border" then
		element.BackgroundColor3 = color
	end
end

local function addShadow(frame, transparency, size)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageTransparency = transparency or 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 49, 49)
	shadow.Size = UDim2.new(1, size or 16, 1, size or 16)
	shadow.Position = UDim2.new(0, -(size or 16)/2, 0, -(size or 16)/2)
	shadow.BackgroundTransparency = 1
	shadow.ZIndex = frame.ZIndex - 1
	shadow.Parent = frame
	return shadow
end

local function makeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function createWindow(config)
	local scale = Sight.IsMobile and 0.8 or 1.0
	local windowWidth = 440 * scale
	local windowHeight = 380 * scale

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SightUI"
	screenGui.Parent = CoreGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local mainWindow = createInstance("Frame", {
		Name = "MainWindow",
		Size = UDim2.new(0, windowWidth, 0, windowHeight),
		Position = UDim2.new(0.5, -windowWidth/2 - 90, 0.5, -windowHeight/2),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
		Parent = screenGui,
		ZIndex = 1
	})
	addShadow(mainWindow, 0.6, 20)
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 6)
	mainCorner.Parent = mainWindow

	local mainPadding = Instance.new("UIPadding")
	mainPadding.PaddingTop = UDim.new(0, 8 * scale)
	mainPadding.PaddingBottom = UDim.new(0, 8 * scale)
	mainPadding.PaddingLeft = UDim.new(0, 8 * scale)
	mainPadding.PaddingRight = UDim.new(0, 8 * scale)
	mainPadding.Parent = mainWindow

	local titleBar = createInstance("Frame", {
		Size = UDim2.new(1, -16 * scale, 0, 24 * scale),
		Position = UDim2.new(0, 8 * scale, 0, 8 * scale),
		BackgroundTransparency = 1,
		Parent = mainWindow
	})

	local titleLabel = createInstance("TextLabel", {
		Text = config.Title or "SIGHT",
		Font = Enum.Font.GothamBold,
		TextSize = 16 * scale,
		Size = UDim2.new(0, 100 * scale, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = titleBar
	})
	applyTheme(titleLabel, "Text")

	local tabContainer = createInstance("Frame", {
		Size = UDim2.new(1, -108 * scale, 1, 0),
		Position = UDim2.new(0, 108 * scale, 0, 0),
		BackgroundTransparency = 1,
		Parent = titleBar
	})

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.FillDirection = Enum.FillDirection.Horizontal
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 12 * scale)
	tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabListLayout.Parent = tabContainer

	local separatorLine = createInstance("Frame", {
		Size = UDim2.new(1, -16 * scale, 0, 1),
		Position = UDim2.new(0, 8 * scale, 0, 40 * scale),
		BackgroundColor3 = Sight.AccentColor,
		BorderSizePixel = 0,
		Parent = mainWindow
	})

	local subTabContainer = createInstance("Frame", {
		Size = UDim2.new(1, -16 * scale, 0, 22 * scale),
		Position = UDim2.new(0, 8 * scale, 0, 46 * scale),
		BackgroundTransparency = 1,
		Parent = mainWindow
	})
	local subTabListLayout = Instance.new("UIListLayout")
	subTabListLayout.FillDirection = Enum.FillDirection.Horizontal
	subTabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	subTabListLayout.Padding = UDim.new(0, 14 * scale)
	subTabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	subTabListLayout.Parent = subTabContainer

	local contentArea = createInstance("Frame", {
		Size = UDim2.new(1, -16 * scale, 1, -76 * scale),
		Position = UDim2.new(0, 8 * scale, 0, 74 * scale),
		BackgroundTransparency = 1,
		Parent = mainWindow
	})

	local leftColumn = createInstance("Frame", {
		Size = UDim2.new(0.5, -6 * scale, 1, 0),
		BackgroundTransparency = 1,
		Parent = contentArea
	})
	local leftList = Instance.new("UIListLayout")
	leftList.Padding = UDim.new(0, 6 * scale)
	leftList.SortOrder = Enum.SortOrder.LayoutOrder
	leftList.Parent = leftColumn

	local rightColumn = createInstance("Frame", {
		Size = UDim2.new(0.5, -6 * scale, 1, 0),
		Position = UDim2.new(0.5, 6 * scale, 0, 0),
		BackgroundTransparency = 1,
		Parent = contentArea
	})
	local rightList = Instance.new("UIListLayout")
	rightList.Padding = UDim.new(0, 6 * scale)
	rightList.SortOrder = Enum.SortOrder.LayoutOrder
	rightList.Parent = rightColumn

	local windowObject = {
		Gui = screenGui,
		Main = mainWindow,
		TitleBar = titleBar,
		TitleLabel = titleLabel,
		TabContainer = tabContainer,
		SubTabContainer = subTabContainer,
		ContentArea = contentArea,
		LeftColumn = leftColumn,
		RightColumn = rightColumn,
		Tabs = {},
		SubTabs = {},
		ActiveTab = nil,
		ActiveSubTab = nil,
		Scale = scale
	}

	makeDraggable(mainWindow, titleBar)

	function windowObject:CreateTab(name, icon)
		local tabButton = createInstance("TextButton", {
			Text = "",
			Size = UDim2.new(0, 60 * scale, 1, 0),
			BackgroundTransparency = 1,
			Parent = self.TabContainer,
			LayoutOrder = #self.Tabs + 1
		})
		local iconLabel = createInstance("TextLabel", {
			Text = icon or "•",
			Font = Enum.Font.SourceSans,
			TextSize = 12 * scale,
			Size = UDim2.new(0, 16 * scale, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Parent = tabButton
		})
		applyTheme(iconLabel, "Text")
		local textLabel = createInstance("TextLabel", {
			Text = name,
			Font = Enum.Font.SourceSans,
			TextSize = 12 * scale,
			Size = UDim2.new(0, 40 * scale, 1, 0),
			Position = UDim2.new(0, 18 * scale, 0, 0),
			BackgroundTransparency = 1,
			Parent = tabButton
		})
		applyTheme(textLabel, "Text")
		local underline = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 2 * scale),
			Position = UDim2.new(0, 0, 1, -2 * scale),
			BackgroundColor3 = Sight.AccentColor,
			BorderSizePixel = 0,
			Visible = false,
			Parent = tabButton
		})

		local tabData = {
			Button = tabButton,
			Icon = iconLabel,
			Text = textLabel,
			Underline = underline,
			Name = name,
			LeftSections = {},
			RightSections = {}
		}
		table.insert(self.Tabs, tabData)

		tabButton.MouseButton1Click:Connect(function()
			if self.ActiveTab == tabData then return end
			for _, t in ipairs(self.Tabs) do
				t.Underline.Visible = false
				applyTheme(t.Icon, "Text")
				applyTheme(t.Text, "Text")
			end
			underline.Visible = true
			applyTheme(iconLabel, "Accent")
			applyTheme(textLabel, "Accent")
			self.ActiveTab = tabData
			self:RefreshSections(tabData)
		end)

		tabButton.MouseEnter:Connect(function()
			if self.ActiveTab ~= tabData then
				applyTheme(iconLabel, "SubText")
				applyTheme(textLabel, "SubText")
			end
		end)
		tabButton.MouseLeave:Connect(function()
			if self.ActiveTab ~= tabData then
				applyTheme(iconLabel, "Text")
				applyTheme(textLabel, "Text")
			end
		end)

		if #self.Tabs == 1 then
			tabButton.MouseButton1Click:Fire()
		end

		return tabData
	end

	function windowObject:RefreshSections(tab)
		for _, child in ipairs(self.LeftColumn:GetChildren()) do
			if child:IsA("Frame") then child.Visible = false end
		end
		for _, child in ipairs(self.RightColumn:GetChildren()) do
			if child:IsA("Frame") then child.Visible = false end
		end
		for _, section in ipairs(tab.LeftSections) do
			section.Frame.Visible = true
		end
		for _, section in ipairs(tab.RightSections) do
			section.Frame.Visible = true
		end
	end

	function windowObject:CreateSubTab(name)
		local subButton = createInstance("TextButton", {
			Text = name,
			Font = Enum.Font.SourceSans,
			TextSize = 11 * scale,
			Size = UDim2.new(0, 60 * scale, 1, 0),
			BackgroundTransparency = 1,
			Parent = self.SubTabContainer,
			LayoutOrder = #self.SubTabs + 1
		})
		applyTheme(subButton, "SubText")
		local subUnderline = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 2 * scale),
			Position = UDim2.new(0, 0, 1, -2 * scale),
			BackgroundColor3 = Sight.AccentColor,
			BorderSizePixel = 0,
			Visible = false,
			Parent = subButton
		})

		local subData = {
			Button = subButton,
			Underline = subUnderline,
			Name = name
		}
		table.insert(self.SubTabs, subData)

		subButton.MouseButton1Click:Connect(function()
			if self.ActiveSubTab == subData then return end
			for _, s in ipairs(self.SubTabs) do
				s.Underline.Visible = false
				applyTheme(s.Button, "SubText")
			end
			subUnderline.Visible = true
			applyTheme(subButton, "Text")
			self.ActiveSubTab = subData
			if self.SubTabChanged then
				self:SubTabChanged(subData)
			end
		end)

		subButton.MouseEnter:Connect(function()
			if self.ActiveSubTab ~= subData then
				applyTheme(subButton, "Text")
			end
		end)
		subButton.MouseLeave:Connect(function()
			if self.ActiveSubTab ~= subData then
				applyTheme(subButton, "SubText")
			end
		end)

		if #self.SubTabs == 1 then
			subButton.MouseButton1Click:Fire()
		end

		return subData
	end

	function windowObject:AddSection(tab, title, column)
		local scale = self.Scale
		local parent = column == "left" and self.LeftColumn or self.RightColumn

		local sectionFrame = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			Visible = false,
			Parent = parent
		})
		local sectionCorner = Instance.new("UICorner")
		sectionCorner.CornerRadius = UDim.new(0, 4 * scale)
		sectionCorner.Parent = sectionFrame

		local sectionPadding = Instance.new("UIPadding")
		sectionPadding.PaddingTop = UDim.new(0, 6 * scale)
		sectionPadding.PaddingBottom = UDim.new(0, 6 * scale)
		sectionPadding.PaddingLeft = UDim.new(0, 6 * scale)
		sectionPadding.PaddingRight = UDim.new(0, 6 * scale)
		sectionPadding.Parent = sectionFrame

		local sectionList = Instance.new("UIListLayout")
		sectionList.Padding = UDim.new(0, 4 * scale)
		sectionList.SortOrder = Enum.SortOrder.LayoutOrder
		sectionList.Parent = sectionFrame

		local header = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 18 * scale),
			BackgroundTransparency = 1,
			Parent = sectionFrame
		})
		local headerText = createInstance("TextLabel", {
			Text = title,
			Font = Enum.Font.SourceSansBold,
			TextSize = 11 * scale,
			Size = UDim2.new(0, 35 * scale, 1, 0),
			BackgroundTransparency = 1,
			Parent = header
		})
		applyTheme(headerText, "Text")
		local headerLine = createInstance("Frame", {
			Size = UDim2.new(1, -40 * scale, 0, 1 * scale),
			Position = UDim2.new(0, 40 * scale, 0.5, 0),
			BackgroundColor3 = Sight.AccentColor,
			BorderSizePixel = 0,
			Parent = header
		})

		local sectionData = {
			Frame = sectionFrame,
			Header = header,
			Elements = {}
		}

		if column == "left" then
			table.insert(tab.LeftSections, sectionData)
		else
			table.insert(tab.RightSections, sectionData)
		end

		return sectionData
	end

	function windowObject:AddToggle(section, config)
		local scale = self.Scale
		local toggleFrame = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 24 * scale),
			BackgroundTransparency = 1,
			Parent = section.Frame
		})
		local label = createInstance("TextLabel", {
			Text = config.Text,
			Font = Enum.Font.SourceSans,
			TextSize = 11 * scale,
			Size = UDim2.new(0.5, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = toggleFrame
		})
		applyTheme(label, "Text")
		if config.Keybind then
			local keybindLabel = createInstance("TextLabel", {
				Text = config.Keybind,
				Font = Enum.Font.SourceSans,
				TextSize = 10 * scale,
				Size = UDim2.new(0.25, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				Parent = toggleFrame
			})
			applyTheme(keybindLabel, "SubText")
		end

		local toggleButton = createInstance("TextButton", {
			Text = "",
			Size = UDim2.new(0, 34 * scale, 0, 16 * scale),
			Position = UDim2.new(1, -34 * scale, 0.5, -8 * scale),
			BackgroundColor3 = config.Default and Sight.AccentColor or Color3.fromRGB(35, 35, 35),
			Parent = toggleFrame
		})
		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(1, 0)
		toggleCorner.Parent = toggleButton
		local knob = createInstance("Frame", {
			Size = UDim2.new(0, 12 * scale, 0, 12 * scale),
			Position = config.Default and UDim2.new(1, -14 * scale, 0.5, -6 * scale) or UDim2.new(0, 2 * scale, 0.5, -6 * scale),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = toggleButton
		})
		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob

		local enabled = config.Default or false
		local function setState(state)
			enabled = state
			local goalPos = state and UDim2.new(1, -14 * scale, 0.5, -6 * scale) or UDim2.new(0, 2 * scale, 0.5, -6 * scale)
			local goalColor = state and Sight.AccentColor or Color3.fromRGB(35, 35, 35)
			TweenService:Create(knob, TweenInfo.new(0.15), {Position = goalPos}):Play()
			TweenService:Create(toggleButton, TweenInfo.new(0.15), {BackgroundColor3 = goalColor}):Play()
			if config.Callback then config.Callback(state) end
		end

		toggleButton.MouseButton1Click:Connect(function()
			setState(not enabled)
		end)
		return toggleFrame
	end

	function windowObject:AddSlider(section, config)
		local scale = self.Scale
		local sliderFrame = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 36 * scale),
			BackgroundTransparency = 1,
			Parent = section.Frame
		})
		local label = createInstance("TextLabel", {
			Text = config.Text,
			Font = Enum.Font.SourceSans,
			TextSize = 11 * scale,
			Size = UDim2.new(1, 0, 0, 14 * scale),
			BackgroundTransparency = 1,
			Parent = sliderFrame
		})
		applyTheme(label, "Text")
		local valueLabel = createInstance("TextLabel", {
			Text = tostring(config.Default) .. (config.Suffix or ""),
			Font = Enum.Font.SourceSans,
			TextSize = 10 * scale,
			Size = UDim2.new(0, 40 * scale, 0, 14 * scale),
			Position = UDim2.new(1, -40 * scale, 0, 0),
			BackgroundTransparency = 1,
			Parent = sliderFrame
		})
		applyTheme(valueLabel, "SubText")

		local sliderBar = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 4 * scale),
			Position = UDim2.new(0, 0, 0, 20 * scale),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			Parent = sliderFrame
		})
		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 2 * scale)
		barCorner.Parent = sliderBar

		local fill = createInstance("Frame", {
			Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0),
			BackgroundColor3 = Sight.AccentColor,
			Parent = sliderBar
		})
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 2 * scale)
		fillCorner.Parent = fill

		local knob = createInstance("Frame", {
			Size = UDim2.new(0, 10 * scale, 0, 10 * scale),
			Position = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), -5 * scale, 0.5, -5 * scale),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = sliderBar
		})
		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob

		local dragging = false
		local function updateValue(input)
			local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
			local value = config.Min + (config.Max - config.Min) * relX
			value = math.floor(value * 10 + 0.5) / 10
			fill.Size = UDim2.new(relX, 0, 1, 0)
			knob.Position = UDim2.new(relX, -5 * scale, 0.5, -5 * scale)
			valueLabel.Text = tostring(value) .. (config.Suffix or "")
			if config.Callback then config.Callback(value) end
		end

		sliderBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateValue(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateValue(input)
			end
		end)
		return sliderFrame
	end

	function windowObject:AddDropdown(section, config)
		local scale = self.Scale
		local dropFrame = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 28 * scale),
			BackgroundTransparency = 1,
			Parent = section.Frame,
			ZIndex = 2
		})
		local label = createInstance("TextLabel", {
			Text = config.Text,
			Font = Enum.Font.SourceSans,
			TextSize = 11 * scale,
			Size = UDim2.new(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = dropFrame,
			ZIndex = 2
		})
		applyTheme(label, "Text")

		local dropButton = createInstance("TextButton", {
			Text = config.Default or config.Options[1],
			Font = Enum.Font.SourceSans,
			TextSize = 11 * scale,
			Size = UDim2.new(0.55, 0, 0, 22 * scale),
			Position = UDim2.new(0.45, 0, 0.5, -11 * scale),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			Parent = dropFrame,
			ZIndex = 3
		})
		applyTheme(dropButton, "Text")
		local dropCorner = Instance.new("UICorner")
		dropCorner.CornerRadius = UDim.new(0, 4 * scale)
		dropCorner.Parent = dropButton

		local menu = createInstance("Frame", {
			Size = UDim2.new(0.55, 0, 0, #config.Options * 22 * scale),
			Position = UDim2.new(0.45, 0, 0, 24 * scale),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			Visible = false,
			Parent = dropFrame,
			ZIndex = 10
		})
		local menuCorner = Instance.new("UICorner")
		menuCorner.CornerRadius = UDim.new(0, 4 * scale)
		menuCorner.Parent = menu
		addShadow(menu, 0.5, 12)
		local menuList = Instance.new("UIListLayout")
		menuList.SortOrder = Enum.SortOrder.LayoutOrder
		menuList.Parent = menu

		local function closeMenu()
			menu.Visible = false
		end

		for _, opt in ipairs(config.Options) do
			local optButton = createInstance("TextButton", {
				Text = opt,
				Font = Enum.Font.SourceSans,
				TextSize = 11 * scale,
				Size = UDim2.new(1, 0, 0, 22 * scale),
				BackgroundTransparency = 1,
				Parent = menu,
				ZIndex = 11
			})
			applyTheme(optButton, "Text")
			optButton.MouseButton1Click:Connect(function()
				dropButton.Text = opt
				closeMenu()
				if config.Callback then config.Callback(opt) end
			end)
			optButton.MouseEnter:Connect(function()
				optButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				optButton.BackgroundTransparency = 0
			end)
			optButton.MouseLeave:Connect(function()
				optButton.BackgroundTransparency = 1
			end)
		end

		dropButton.MouseButton1Click:Connect(function()
			menu.Visible = not menu.Visible
		end)

		UserInputService.InputBegan:Connect(function(input)
			if menu.Visible then
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local target = input.UserInputState == Enum.UserInputState.Begin and UserInputService:GetFocusedTextBox()
					if not dropFrame:IsAncestorOf(target) and target ~= dropButton then
						closeMenu()
					end
				end
			end
		end)
		return dropFrame
	end

	return windowObject
end

function Sight:CreateWindow(config)
	config = config or {}
	local window = createWindow(config)
	table.insert(Sight.Windows, window)

	local loginScale = window.Scale
	local loginWidth = 220 * loginScale
	local loginHeight = 160 * loginScale

	local loginWindow = createInstance("Frame", {
		Name = "LoginWindow",
		Size = UDim2.new(0, loginWidth, 0, loginHeight),
		Position = UDim2.new(0.5, window.Main.Size.X.Offset/2 + 15 * loginScale, 0.5, -loginHeight/2),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
		Parent = window.Gui,
		ZIndex = 1
	})
	addShadow(loginWindow, 0.6, 20)
	local loginCorner = Instance.new("UICorner")
	loginCorner.CornerRadius = UDim.new(0, 6)
	loginCorner.Parent = loginWindow

	local loginTitleBar = createInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 24 * loginScale),
		BackgroundTransparency = 1,
		Parent = loginWindow
	})
	makeDraggable(loginWindow, loginTitleBar)

	local loginPadding = Instance.new("UIPadding")
	loginPadding.PaddingTop = UDim.new(0, 12 * loginScale)
	loginPadding.PaddingBottom = UDim.new(0, 12 * loginScale)
	loginPadding.PaddingLeft = UDim.new(0, 12 * loginScale)
	loginPadding.PaddingRight = UDim.new(0, 12 * loginScale)
	loginPadding.Parent = loginWindow

	local loginList = Instance.new("UIListLayout")
	loginList.Padding = UDim.new(0, 10 * loginScale)
	loginList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	loginList.SortOrder = Enum.SortOrder.LayoutOrder
	loginList.Parent = loginWindow

	local loginTitle = createInstance("TextLabel", {
		Text = config.Title or "SIGHT",
		Font = Enum.Font.GothamBold,
		TextSize = 18 * loginScale,
		Size = UDim2.new(1, 0, 0, 24 * loginScale),
		BackgroundTransparency = 1,
		Parent = loginWindow
	})
	applyTheme(loginTitle, "Text")

	local licenseInput = createInstance("TextBox", {
		PlaceholderText = "License Key",
		Text = "",
		Font = Enum.Font.SourceSans,
		TextSize = 12 * loginScale,
		Size = UDim2.new(1, 0, 0, 32 * loginScale),
		BackgroundColor3 = Color3.fromRGB(28, 28, 28),
		BorderSizePixel = 0,
		Parent = loginWindow
	})
	applyTheme(licenseInput, "Text")
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 4)
	inputCorner.Parent = licenseInput
	local inputPadding = Instance.new("UIPadding")
	inputPadding.PaddingLeft = UDim.new(0, 10 * loginScale)
	inputPadding.Parent = licenseInput

	local loginButton = createInstance("TextButton", {
		Text = "Login",
		Font = Enum.Font.SourceSansBold,
		TextSize = 13 * loginScale,
		Size = UDim2.new(1, 0, 0, 32 * loginScale),
		BackgroundColor3 = Sight.AccentColor,
		BorderSizePixel = 0,
		Parent = loginWindow
	})
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = loginButton

	loginButton.MouseEnter:Connect(function()
		TweenService:Create(loginButton, TweenInfo.new(0.15), {BackgroundColor3 = Sight.AccentColor:lerp(Color3.new(1,1,1), 0.1)}):Play()
	end)
	loginButton.MouseLeave:Connect(function()
		TweenService:Create(loginButton, TweenInfo.new(0.15), {BackgroundColor3 = Sight.AccentColor}):Play()
	end)

	window.LoginWindow = loginWindow
	window.LoginButton = loginButton
	window.LicenseInput = licenseInput

	return window
end

return Sight
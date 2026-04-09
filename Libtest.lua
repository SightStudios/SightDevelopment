local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Sight = {}
Sight.Windows = {}
Sight.ActiveTab = nil
Sight.ActiveSubTab = nil
Sight.IsMobile = UserInputService.TouchEnabled

local function createInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties) do
		instance[prop] = value
	end
	return instance
end

local function applyTheme(element, themeType)
	local themes = {
		Background = Color3.fromRGB(25, 25, 25),
		LighterBackground = Color3.fromRGB(35, 35, 35),
		Accent = Color3.fromRGB(80, 180, 255),
		Text = Color3.fromRGB(240, 240, 240),
		SubText = Color3.fromRGB(150, 150, 150),
		Border = Color3.fromRGB(50, 50, 50)
	}
	if themeType == "Background" then
		element.BackgroundColor3 = themes.Background
	elseif themeType == "LighterBackground" then
		element.BackgroundColor3 = themes.LighterBackground
	elseif themeType == "Accent" then
		element.BackgroundColor3 = themes.Accent
	elseif themeType == "Text" then
		element.TextColor3 = themes.Text
	elseif themeType == "SubText" then
		element.TextColor3 = themes.SubText
	elseif themeType == "Border" then
		element.BackgroundColor3 = themes.Border
	end
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

function Sight:CreateWindow(config)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SightUI"
	screenGui.Parent = CoreGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local scaleFactor = Sight.IsMobile and 0.75 or 1.0
	local mainWidth = 550 * scaleFactor
	local mainHeight = 450 * scaleFactor

	local mainWindow = createInstance("Frame", {
		Name = "MainWindow",
		Size = UDim2.new(0, mainWidth, 0, mainHeight),
		Position = UDim2.new(0.5, -mainWidth/2 - 135, 0.5, -mainHeight/2),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Parent = screenGui
	})
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 6)
	mainCorner.Parent = mainWindow

	local mainPadding = Instance.new("UIPadding")
	mainPadding.PaddingTop = UDim.new(0, 10 * scaleFactor)
	mainPadding.PaddingBottom = UDim.new(0, 10 * scaleFactor)
	mainPadding.PaddingLeft = UDim.new(0, 10 * scaleFactor)
	mainPadding.PaddingRight = UDim.new(0, 10 * scaleFactor)
	mainPadding.Parent = mainWindow

	local titleBar = createInstance("Frame", {
		Size = UDim2.new(1, -20 * scaleFactor, 0, 30 * scaleFactor),
		Position = UDim2.new(0, 10 * scaleFactor, 0, 10 * scaleFactor),
		BackgroundTransparency = 1,
		Parent = mainWindow
	})

	makeDraggable(mainWindow, titleBar)

	local titleLabel = createInstance("TextLabel", {
		Text = "SIGHT BETA",
		Font = Enum.Font.SourceSansBold,
		TextSize = 20 * scaleFactor,
		Size = UDim2.new(0, 120 * scaleFactor, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = titleBar
	})
	applyTheme(titleLabel, "Text")

	local tabHolder = createInstance("Frame", {
		Size = UDim2.new(1, -130 * scaleFactor, 1, 0),
		Position = UDim2.new(0, 130 * scaleFactor, 0, 0),
		BackgroundTransparency = 1,
		Parent = titleBar
	})

	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Padding = UDim.new(0, 20 * scaleFactor)
	tabList.Parent = tabHolder

	local tabs = {}
	local function createTab(name, iconText, order)
		local tabButton = createInstance("TextButton", {
			Text = "",
			Size = UDim2.new(0, 80 * scaleFactor, 1, 0),
			BackgroundTransparency = 1,
			Parent = tabHolder,
			LayoutOrder = order
		})
		local iconLabel = createInstance("TextLabel", {
			Text = iconText,
			Font = Enum.Font.SourceSans,
			TextSize = 14 * scaleFactor,
			Size = UDim2.new(0, 20 * scaleFactor, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Parent = tabButton
		})
		applyTheme(iconLabel, "Text")
		local textLabel = createInstance("TextLabel", {
			Text = name,
			Font = Enum.Font.SourceSans,
			TextSize = 14 * scaleFactor,
			Size = UDim2.new(0, 50 * scaleFactor, 1, 0),
			Position = UDim2.new(0, 22 * scaleFactor, 0, 0),
			BackgroundTransparency = 1,
			Parent = tabButton
		})
		applyTheme(textLabel, "Text")
		local underline = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 2 * scaleFactor),
			Position = UDim2.new(0, 0, 1, -2 * scaleFactor),
			BackgroundColor3 = Color3.fromRGB(80, 180, 255),
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
			Content = nil
		}
		table.insert(tabs, tabData)
		tabButton.MouseButton1Click:Connect(function()
			for _, t in ipairs(tabs) do
				t.Underline.Visible = false
				applyTheme(t.Icon, "Text")
				applyTheme(t.Text, "Text")
				if t.Content then t.Content.Visible = false end
			end
			underline.Visible = true
			applyTheme(iconLabel, "Accent")
			applyTheme(textLabel, "Accent")
			if tabData.Content then tabData.Content.Visible = true end
			Sight.ActiveTab = tabData
		end)
		return tabData
	end

	local combatTab = createTab("Combat", "⌖", 1)
	combatTab.Underline.Visible = true
	applyTheme(combatTab.Icon, "Accent")
	applyTheme(combatTab.Text, "Accent")
	createTab("Visuals", "👁", 2)
	createTab("Character", "👤", 3)
	createTab("Players", "👥", 4)
	createTab("Options", "⚙", 5)
	createTab("Config", "📁", 6)

	local separator = createInstance("Frame", {
		Size = UDim2.new(1, -20 * scaleFactor, 0, 1 * scaleFactor),
		Position = UDim2.new(0, 10 * scaleFactor, 0, 50 * scaleFactor),
		BackgroundColor3 = Color3.fromRGB(80, 180, 255),
		BorderSizePixel = 0,
		Parent = mainWindow
	})

	local subTabFrame = createInstance("Frame", {
		Size = UDim2.new(1, -20 * scaleFactor, 0, 30 * scaleFactor),
		Position = UDim2.new(0, 10 * scaleFactor, 0, 55 * scaleFactor),
		BackgroundTransparency = 1,
		Parent = mainWindow
	})
	local subTabList = Instance.new("UIListLayout")
	subTabList.FillDirection = Enum.FillDirection.Horizontal
	subTabList.SortOrder = Enum.SortOrder.LayoutOrder
	subTabList.Padding = UDim.new(0, 15 * scaleFactor)
	subTabList.Parent = subTabFrame

	local subTabs = {}
	local function createSubTab(name, order)
		local subButton = createInstance("TextButton", {
			Text = name,
			Font = Enum.Font.SourceSans,
			TextSize = 13 * scaleFactor,
			Size = UDim2.new(0, 70 * scaleFactor, 1, 0),
			BackgroundTransparency = 1,
			Parent = subTabFrame,
			LayoutOrder = order
		})
		applyTheme(subButton, "SubText")
		local subUnderline = createInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 2 * scaleFactor),
			Position = UDim2.new(0, 0, 1, -2 * scaleFactor),
			BackgroundColor3 = Color3.fromRGB(80, 180, 255),
			BorderSizePixel = 0,
			Visible = false,
			Parent = subButton
		})
		local subData = {
			Button = subButton,
			Underline = subUnderline,
			Name = name,
			Content = nil
		}
		table.insert(subTabs, subData)
		subButton.MouseButton1Click:Connect(function()
			for _, s in ipairs(subTabs) do
				s.Underline.Visible = false
				applyTheme(s.Button, "SubText")
				if s.Content then s.Content.Visible = false end
			end
			subUnderline.Visible = true
			applyTheme(subButton, "Text")
			if subData.Content then subData.Content.Visible = true end
			Sight.ActiveSubTab = subData
		end)
		return subData
	end

	local aimbotSubTab = createSubTab("Aimbot", 1)
	aimbotSubTab.Underline.Visible = true
	applyTheme(aimbotSubTab.Button, "Text")
	createSubTab("Predictions", 2)
	createSubTab("Smoothness", 3)
	createSubTab("Fov", 4)

	local contentFrame = createInstance("Frame", {
		Size = UDim2.new(1, -20 * scaleFactor, 1, -100 * scaleFactor),
		Position = UDim2.new(0, 10 * scaleFactor, 0, 90 * scaleFactor),
		BackgroundTransparency = 1,
		Parent = mainWindow
	})

	local function createContentForTab(tab)
		local content = createInstance("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = contentFrame
		})
		tab.Content = content
		if tab.Name == "Combat" then
			content.Visible = true
			local leftCol = createInstance("Frame", {
				Size = UDim2.new(0.5, -10 * scaleFactor, 1, 0),
				BackgroundTransparency = 1,
				Parent = content
			})
			local leftList = Instance.new("UIListLayout")
			leftList.Padding = UDim.new(0, 8 * scaleFactor)
			leftList.SortOrder = Enum.SortOrder.LayoutOrder
			leftList.Parent = leftCol

			local rightCol = createInstance("Frame", {
				Size = UDim2.new(0.5, -10 * scaleFactor, 1, 0),
				Position = UDim2.new(0.5, 10 * scaleFactor, 0, 0),
				BackgroundTransparency = 1,
				Parent = content
			})
			local rightList = Instance.new("UIListLayout")
			rightList.Padding = UDim.new(0, 8 * scaleFactor)
			rightList.SortOrder = Enum.SortOrder.LayoutOrder
			rightList.Parent = rightCol

			local function addToggle(parent, config)
				local toggleFrame = createInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 30 * scaleFactor),
					BackgroundTransparency = 1,
					Parent = parent
				})
				local label = createInstance("TextLabel", {
					Text = config.Text,
					Font = Enum.Font.SourceSans,
					TextSize = 14 * scaleFactor,
					Size = UDim2.new(0.6, 0, 1, 0),
					BackgroundTransparency = 1,
					Parent = toggleFrame
				})
				applyTheme(label, "Text")
				local keybindLabel = createInstance("TextLabel", {
					Text = config.Keybind or "",
					Font = Enum.Font.SourceSans,
					TextSize = 13 * scaleFactor,
					Size = UDim2.new(0.3, 0, 1, 0),
					Position = UDim2.new(0.6, 0, 0, 0),
					BackgroundTransparency = 1,
					Parent = toggleFrame
				})
				applyTheme(keybindLabel, "SubText")
				local toggleButton = createInstance("TextButton", {
					Text = "",
					Size = UDim2.new(0, 40 * scaleFactor, 0, 20 * scaleFactor),
					Position = UDim2.new(1, -45 * scaleFactor, 0.5, -10 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					Parent = toggleFrame
				})
				local toggleCorner = Instance.new("UICorner")
				toggleCorner.CornerRadius = UDim.new(1, 0)
				toggleCorner.Parent = toggleButton
				local toggleKnob = createInstance("Frame", {
					Size = UDim2.new(0, 16 * scaleFactor, 0, 16 * scaleFactor),
					Position = UDim2.new(0, 2 * scaleFactor, 0.5, -8 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(240, 240, 240),
					Parent = toggleButton
				})
				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = toggleKnob
				local toggled = config.Default or false
				local function updateToggle(state)
					toggled = state
					if state then
						toggleButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
						toggleKnob:TweenPosition(UDim2.new(1, -18 * scaleFactor, 0.5, -8 * scaleFactor), "Out", "Quad", 0.15, true)
					else
						toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
						toggleKnob:TweenPosition(UDim2.new(0, 2 * scaleFactor, 0.5, -8 * scaleFactor), "Out", "Quad", 0.15, true)
					end
					if config.Callback then config.Callback(state) end
				end
				updateToggle(toggled)
				toggleButton.MouseButton1Click:Connect(function()
					updateToggle(not toggled)
				end)
				return toggleFrame
			end

			local function addSlider(parent, config)
				local sliderFrame = createInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 40 * scaleFactor),
					BackgroundTransparency = 1,
					Parent = parent
				})
				local label = createInstance("TextLabel", {
					Text = config.Text,
					Font = Enum.Font.SourceSans,
					TextSize = 14 * scaleFactor,
					Size = UDim2.new(1, 0, 0, 18 * scaleFactor),
					BackgroundTransparency = 1,
					Parent = sliderFrame
				})
				applyTheme(label, "Text")
				local valueLabel = createInstance("TextLabel", {
					Text = tostring(config.Default) .. (config.Suffix or ""),
					Font = Enum.Font.SourceSans,
					TextSize = 13 * scaleFactor,
					Size = UDim2.new(0, 50 * scaleFactor, 0, 18 * scaleFactor),
					Position = UDim2.new(1, -55 * scaleFactor, 0, 0),
					BackgroundTransparency = 1,
					Parent = sliderFrame
				})
				applyTheme(valueLabel, "SubText")
				local sliderBar = createInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 6 * scaleFactor),
					Position = UDim2.new(0, 0, 0, 24 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					Parent = sliderFrame
				})
				local barCorner = Instance.new("UICorner")
				barCorner.CornerRadius = UDim.new(0, 3 * scaleFactor)
				barCorner.Parent = sliderBar
				local fill = createInstance("Frame", {
					Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(80, 180, 255),
					Parent = sliderBar
				})
				local fillCorner = Instance.new("UICorner")
				fillCorner.CornerRadius = UDim.new(0, 3 * scaleFactor)
				fillCorner.Parent = fill
				local knob = createInstance("Frame", {
					Size = UDim2.new(0, 12 * scaleFactor, 0, 12 * scaleFactor),
					Position = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), -6 * scaleFactor, 0.5, -6 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(240, 240, 240),
					Parent = sliderBar
				})
				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = knob
				local dragging = false
				local function updateSlider(input)
					local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local value = config.Min + (config.Max - config.Min) * relativeX
					value = math.floor(value * 100) / 100
					fill.Size = UDim2.new(relativeX, 0, 1, 0)
					knob.Position = UDim2.new(relativeX, -6 * scaleFactor, 0.5, -6 * scaleFactor)
					valueLabel.Text = tostring(value) .. (config.Suffix or "")
					if config.Callback then config.Callback(value) end
				end
				sliderBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateSlider(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateSlider(input)
					end
				end)
				return sliderFrame
			end

			local function addDropdown(parent, config)
				local dropFrame = createInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 35 * scaleFactor),
					BackgroundTransparency = 1,
					Parent = parent
				})
				local label = createInstance("TextLabel", {
					Text = config.Text,
					Font = Enum.Font.SourceSans,
					TextSize = 14 * scaleFactor,
					Size = UDim2.new(0.4, 0, 1, 0),
					BackgroundTransparency = 1,
					Parent = dropFrame
				})
				applyTheme(label, "Text")
				local dropButton = createInstance("TextButton", {
					Text = config.Default or config.Options[1],
					Font = Enum.Font.SourceSans,
					TextSize = 14 * scaleFactor,
					Size = UDim2.new(0.55, 0, 0, 28 * scaleFactor),
					Position = UDim2.new(0.45, 0, 0.5, -14 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					Parent = dropFrame,
					ZIndex = 2
				})
				applyTheme(dropButton, "Text")
				local dropCorner = Instance.new("UICorner")
				dropCorner.CornerRadius = UDim.new(0, 4 * scaleFactor)
				dropCorner.Parent = dropButton

				local dropdownMenu = createInstance("Frame", {
					Size = UDim2.new(0.55, 0, 0, #config.Options * 28 * scaleFactor),
					Position = UDim2.new(0.45, 0, 0, 30 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(45, 45, 45),
					Visible = false,
					Parent = dropFrame,
					ZIndex = 10
				})
				local menuCorner = Instance.new("UICorner")
				menuCorner.CornerRadius = UDim.new(0, 4 * scaleFactor)
				menuCorner.Parent = dropdownMenu
				local menuList = Instance.new("UIListLayout")
				menuList.SortOrder = Enum.SortOrder.LayoutOrder
				menuList.Parent = dropdownMenu

				local optionButtons = {}
				for _, opt in ipairs(config.Options) do
					local optButton = createInstance("TextButton", {
						Text = opt,
						Font = Enum.Font.SourceSans,
						TextSize = 14 * scaleFactor,
						Size = UDim2.new(1, 0, 0, 28 * scaleFactor),
						BackgroundTransparency = 1,
						Parent = dropdownMenu,
						ZIndex = 11
					})
					applyTheme(optButton, "Text")
					optButton.MouseButton1Click:Connect(function()
						dropButton.Text = opt
						dropdownMenu.Visible = false
						if config.Callback then config.Callback(opt) end
					end)
					table.insert(optionButtons, optButton)
				end

				local function closeDropdown()
					dropdownMenu.Visible = false
				end

				dropButton.MouseButton1Click:Connect(function()
					dropdownMenu.Visible = not dropdownMenu.Visible
				end)

				local function onInputBegan(input)
					if dropdownMenu.Visible then
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							local guiObj = input.UserInputState == Enum.UserInputState.Begin and UserInputService:GetFocusedTextBox()
							if not dropFrame:IsAncestorOf(guiObj) and guiObj ~= dropButton then
								closeDropdown()
							end
						end
					end
				end
				UserInputService.InputBegan:Connect(onInputBegan)
				return dropFrame
			end

			addToggle(leftCol, {Text = "Enabled", Keybind = "[MouseX2]", Default = true})
			addToggle(leftCol, {Text = "Team Check"})
			addToggle(leftCol, {Text = "visible Check"})
			addToggle(leftCol, {Text = "sticky Aim"})
			addSlider(leftCol, {Text = "Distance", Min = 0, Max = 10000, Default = 10000, Suffix = "m"})
			addDropdown(leftCol, {Text = "Aim Type", Options = {"Mouse"}, Default = "Mouse"})
			addDropdown(leftCol, {Text = "Hit Target", Options = {"Head", "Neck", "Chest"}, Default = "Head"})

			local function createSectionBox(parent, title)
				local box = createInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 120 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					Parent = parent
				})
				local boxCorner = Instance.new("UICorner")
				boxCorner.CornerRadius = UDim.new(0, 6 * scaleFactor)
				boxCorner.Parent = box
				local boxPadding = Instance.new("UIPadding")
				boxPadding.PaddingTop = UDim.new(0, 8 * scaleFactor)
				boxPadding.PaddingBottom = UDim.new(0, 8 * scaleFactor)
				boxPadding.PaddingLeft = UDim.new(0, 8 * scaleFactor)
				boxPadding.PaddingRight = UDim.new(0, 8 * scaleFactor)
				boxPadding.Parent = box
				local header = createInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 20 * scaleFactor),
					BackgroundTransparency = 1,
					Parent = box
				})
				local headerText = createInstance("TextLabel", {
					Text = title,
					Font = Enum.Font.SourceSansBold,
					TextSize = 14 * scaleFactor,
					Size = UDim2.new(0, 40 * scaleFactor, 1, 0),
					BackgroundTransparency = 1,
					Parent = header
				})
				applyTheme(headerText, "Text")
				local headerLine = createInstance("Frame", {
					Size = UDim2.new(1, -50 * scaleFactor, 0, 2 * scaleFactor),
					Position = UDim2.new(0, 50 * scaleFactor, 0.5, -1 * scaleFactor),
					BackgroundColor3 = Color3.fromRGB(80, 180, 255),
					BorderSizePixel = 0,
					Parent = header
				})
				return box
			end

			local topBox = createSectionBox(rightCol, "top")
			local triggerBox = createSectionBox(rightCol, "Triggerbot")
		end
	end

	for _, tab in ipairs(tabs) do
		createContentForTab(tab)
	end

	local loginWidth = 260 * scaleFactor
	local loginHeight = 180 * scaleFactor
	local loginWindow = createInstance("Frame", {
		Name = "LoginWindow",
		Size = UDim2.new(0, loginWidth, 0, loginHeight),
		Position = UDim2.new(0.5, mainWidth/2 + 10 * scaleFactor, 0.5, -loginHeight/2),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Parent = screenGui
	})
	local loginCorner = Instance.new("UICorner")
	loginCorner.CornerRadius = UDim.new(0, 6)
	loginCorner.Parent = loginWindow

	local loginTitleBar = createInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 30 * scaleFactor),
		BackgroundTransparency = 1,
		Parent = loginWindow
	})
	makeDraggable(loginWindow, loginTitleBar)

	local loginPadding = Instance.new("UIPadding")
	loginPadding.PaddingTop = UDim.new(0, 15 * scaleFactor)
	loginPadding.PaddingBottom = UDim.new(0, 15 * scaleFactor)
	loginPadding.PaddingLeft = UDim.new(0, 15 * scaleFactor)
	loginPadding.PaddingRight = UDim.new(0, 15 * scaleFactor)
	loginPadding.Parent = loginWindow

	local loginList = Instance.new("UIListLayout")
	loginList.Padding = UDim.new(0, 15 * scaleFactor)
	loginList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	loginList.SortOrder = Enum.SortOrder.LayoutOrder
	loginList.Parent = loginWindow

	local loginTitle = createInstance("TextLabel", {
		Text = "SIGHT BETA",
		Font = Enum.Font.SourceSansBold,
		TextSize = 22 * scaleFactor,
		Size = UDim2.new(1, 0, 0, 30 * scaleFactor),
		BackgroundTransparency = 1,
		Parent = loginWindow
	})
	applyTheme(loginTitle, "Text")

	local licenseInput = createInstance("TextBox", {
		PlaceholderText = "License",
		Text = "",
		Font = Enum.Font.SourceSans,
		TextSize = 14 * scaleFactor,
		Size = UDim2.new(1, 0, 0, 40 * scaleFactor),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BorderSizePixel = 0,
		Parent = loginWindow
	})
	applyTheme(licenseInput, "Text")
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 6)
	inputCorner.Parent = licenseInput
	local inputPadding = Instance.new("UIPadding")
	inputPadding.PaddingLeft = UDim.new(0, 10 * scaleFactor)
	inputPadding.Parent = licenseInput

	local loginButton = createInstance("TextButton", {
		Text = "Login",
		Font = Enum.Font.SourceSansBold,
		TextSize = 16 * scaleFactor,
		Size = UDim2.new(1, 0, 0, 40 * scaleFactor),
		BackgroundColor3 = Color3.fromRGB(80, 180, 255),
		BorderSizePixel = 0,
		Parent = loginWindow
	})
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = loginButton

	local windowObject = {
		Main = mainWindow,
		Login = loginWindow,
		LoginButton = loginButton,
		LicenseInput = licenseInput
	}

	table.insert(Sight.Windows, windowObject)
	return windowObject
end

return Sight
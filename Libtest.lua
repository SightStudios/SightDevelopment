local Sight = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Theme = {
	Background = Color3.fromRGB(26, 26, 26),
	Surface = Color3.fromRGB(35, 35, 35),
	Border = Color3.fromRGB(15, 15, 15),
	Accent = Color3.fromRGB(0, 150, 255),
	Text = Color3.fromRGB(240, 240, 240),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Glass = Color3.fromRGB(255, 255, 255),
	GlassTint = Color3.fromRGB(0, 150, 255)
}

local GlassProperties = {
	BackgroundTransparency = 0.85,
	BorderSizePixel = 0,
	BackgroundColor3 = Theme.Glass
}

local function CreateShadow(instance)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 449, 449)
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.BackgroundTransparency = 1
	shadow.ZIndex = instance.ZIndex - 1
	shadow.Parent = instance
	return shadow
end

local function CreateTween(instance, properties)
	local tween = TweenService:Create(instance, TweenInfo, properties)
	tween:Play()
	return tween
end

local function MakeDraggable(frame, handle)
	local dragStart, startPos, dragging
	handle = handle or frame
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			startPos = frame.Position
			dragging = true
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass:Tab(name)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = name
	tabButton.Size = UDim2.new(0, 80, 1, 0)
	tabButton.Position = UDim2.new(0, 0, 0, 0)
	tabButton.BackgroundTransparency = 1
	tabButton.Text = name
	tabButton.TextColor3 = Theme.TextSecondary
	tabButton.Font = Enum.Font.GothamSemibold
	tabButton.TextSize = 14
	tabButton.Parent = self.TabContainer

	local tabFrame = Instance.new("Frame")
	tabFrame.Name = name
	tabFrame.Size = UDim2.new(1, 0, 1, -40)
	tabFrame.Position = UDim2.new(0, 0, 0, 40)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Visible = false
	tabFrame.Parent = self.ContentArea

	local highlight = Instance.new("Frame")
	highlight.Size = UDim2.new(1, 0, 0, 2)
	highlight.Position = UDim2.new(0, 0, 1, -2)
	highlight.BackgroundColor3 = Theme.Accent
	highlight.BorderSizePixel = 0
	highlight.Visible = false
	highlight.Parent = tabButton

	local subTabContainer = Instance.new("Frame")
	subTabContainer.Size = UDim2.new(1, 0, 0, 30)
	subTabContainer.Position = UDim2.new(0, 0, 0, 0)
	subTabContainer.BackgroundTransparency = 1
	subTabContainer.Parent = tabFrame

	local subTabList = Instance.new("UIListLayout")
	subTabList.FillDirection = Enum.FillDirection.Horizontal
	subTabList.SortOrder = Enum.SortOrder.LayoutOrder
	subTabList.Padding = UDim.new(0, 5)
	subTabList.Parent = subTabContainer

	local subTabFrameContainer = Instance.new("Frame")
	subTabFrameContainer.Size = UDim2.new(1, 0, 1, -30)
	subTabFrameContainer.Position = UDim2.new(0, 0, 0, 30)
	subTabFrameContainer.BackgroundTransparency = 1
	subTabFrameContainer.Parent = tabFrame

	local tabObj = {
		Button = tabButton,
		Frame = tabFrame,
		Highlight = highlight,
		SubTabContainer = subTabContainer,
		SubTabFrameContainer = subTabFrameContainer,
		SubTabs = {},
		CurrentSubTab = nil,
		Window = self
	}

	function tabObj:Select()
		for _, t in pairs(self.Tabs) do
			t.Frame.Visible = false
			t.Highlight.Visible = false
			t.Button.TextColor3 = Theme.TextSecondary
		end
		tabFrame.Visible = true
		highlight.Visible = true
		tabButton.TextColor3 = Theme.Text
	end

	function tabObj:SubTab(name)
		local subButton = Instance.new("TextButton")
		subButton.Name = name
		subButton.Size = UDim2.new(0, 70, 1, 0)
		subButton.BackgroundTransparency = 1
		subButton.Text = name
		subButton.TextColor3 = Theme.TextSecondary
		subButton.Font = Enum.Font.Gotham
		subButton.TextSize = 13
		subButton.Parent = subTabContainer

		local subFrame = Instance.new("Frame")
		subFrame.Name = name
		subFrame.Size = UDim2.new(1, 0, 1, 0)
		subFrame.BackgroundTransparency = 1
		subFrame.Visible = false
		subFrame.Parent = subTabFrameContainer

		local leftList = Instance.new("UIListLayout")
		leftList.Padding = UDim.new(0, 10)
		leftList.SortOrder = Enum.SortOrder.LayoutOrder
		leftList.Parent = subFrame

		local rightFrame = Instance.new("Frame")
		rightFrame.Size = UDim2.new(0.5, -5, 1, 0)
		rightFrame.Position = UDim2.new(0.5, 5, 0, 0)
		rightFrame.BackgroundTransparency = 1
		rightFrame.Parent = subFrame

		local rightList = Instance.new("UIListLayout")
		rightList.Padding = UDim.new(0, 10)
		rightList.SortOrder = Enum.SortOrder.LayoutOrder
		rightList.Parent = rightFrame

		local subObj = {
			Button = subButton,
			Frame = subFrame,
			LeftContainer = subFrame,
			RightContainer = rightFrame,
			Window = self,
			Tab = tabObj
		}

		function subObj:Select()
			for _, s in pairs(tabObj.SubTabs) do
				s.Frame.Visible = false
				s.Button.TextColor3 = Theme.TextSecondary
			end
			subFrame.Visible = true
			subButton.TextColor3 = Theme.Text
			tabObj.CurrentSubTab = subObj
		end

		function subObj:AddGroup(name)
			local group = Instance.new("Frame")
			group.Size = UDim2.new(1, -10, 0, 40)
			group.BackgroundColor3 = Theme.Surface
			group.BorderColor3 = Theme.Border
			group.BorderSizePixel = 1
			group.Parent = subFrame
			CreateShadow(group)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -10, 0, 30)
			title.Position = UDim2.new(0, 10, 0, 5)
			title.BackgroundTransparency = 1
			title.Text = name
			title.TextColor3 = Theme.Text
			title.Font = Enum.Font.GothamBold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = group

			local content = Instance.new("Frame")
			content.Size = UDim2.new(1, -10, 1, -40)
			content.Position = UDim2.new(0, 5, 0, 35)
			content.BackgroundTransparency = 1
			content.Parent = group

			local list = Instance.new("UIListLayout")
			list.Padding = UDim.new(0, 8)
			list.SortOrder = Enum.SortOrder.LayoutOrder
			list.Parent = content

			group.Size = UDim2.new(1, -10, 0, 40 + (#content:GetChildren() * 30))

			local groupObj = {
				Container = group,
				Content = content,
				SubTab = subObj
			}

			function groupObj:UpdateSize()
				local count = 0
				for _, child in pairs(content:GetChildren()) do
					if child:IsA("Frame") or child:IsA("TextButton") then count += 1 end
				end
				group.Size = UDim2.new(1, -10, 0, 40 + (count * 30))
			end

			function groupObj:AddButton(name, callback)
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 28)
				btn.BackgroundColor3 = Theme.Surface
				btn.BorderColor3 = Theme.Border
				btn.BorderSizePixel = 1
				btn.Text = name
				btn.TextColor3 = Theme.Text
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 13
				btn.Parent = content
				CreateShadow(btn)

				btn.MouseEnter:Connect(function()
					CreateTween(btn, {BackgroundColor3 = Theme.Background})
				end)
				btn.MouseLeave:Connect(function()
					CreateTween(btn, {BackgroundColor3 = Theme.Surface})
				end)
				btn.MouseButton1Click:Connect(callback or function() end)

				groupObj:UpdateSize()
				return btn
			end

			function groupObj:AddToggle(name, default, callback)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 28)
				frame.BackgroundTransparency = 1
				frame.Parent = content

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.7, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = name
				label.TextColor3 = Theme.Text
				label.Font = Enum.Font.Gotham
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = frame

				local toggleFrame = Instance.new("Frame")
				toggleFrame.Size = UDim2.new(0, 40, 0, 20)
				toggleFrame.Position = UDim2.new(1, -40, 0.5, -10)
				toggleFrame.BackgroundColor3 = Theme.Background
				toggleFrame.BorderColor3 = Theme.Border
				toggleFrame.BorderSizePixel = 1
				toggleFrame.Parent = frame

				local toggleButton = Instance.new("TextButton")
				toggleButton.Size = UDim2.new(0, 18, 0, 18)
				toggleButton.Position = UDim2.new(0, 1, 0, 1)
				toggleButton.BackgroundColor3 = Theme.Accent
				toggleButton.BorderSizePixel = 0
				toggleButton.Text = ""
				toggleButton.AutoButtonColor = false
				toggleButton.Parent = toggleFrame

				local glassOverlay = Instance.new("Frame")
				glassOverlay.Size = UDim2.new(1, 0, 1, 0)
				glassOverlay.BackgroundColor3 = Theme.Glass
				glassOverlay.BackgroundTransparency = 0.8
				glassOverlay.BorderSizePixel = 0
				glassOverlay.Parent = toggleButton

				local state = default or false
				toggleButton.Position = state and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)

				toggleButton.MouseButton1Click:Connect(function()
					state = not state
					CreateTween(toggleButton, {Position = state and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)})
					if callback then callback(state) end
				end)

				groupObj:UpdateSize()
				return {SetState = function(self, value) state = value; toggleButton.Position = state and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1) end}
			end

			function groupObj:AddSlider(name, min, max, default, callback)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 50)
				frame.BackgroundTransparency = 1
				frame.Parent = content

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.7, 0, 0, 20)
				label.BackgroundTransparency = 1
				label.Text = name
				label.TextColor3 = Theme.Text
				label.Font = Enum.Font.Gotham
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = frame

				local valueLabel = Instance.new("TextLabel")
				valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
				valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
				valueLabel.BackgroundTransparency = 1
				valueLabel.Text = tostring(default or min)
				valueLabel.TextColor3 = Theme.Text
				valueLabel.Font = Enum.Font.Gotham
				valueLabel.TextSize = 13
				valueLabel.TextXAlignment = Enum.TextXAlignment.Right
				valueLabel.Parent = frame

				local sliderFrame = Instance.new("Frame")
				sliderFrame.Size = UDim2.new(1, 0, 0, 20)
				sliderFrame.Position = UDim2.new(0, 0, 0, 25)
				sliderFrame.BackgroundColor3 = Theme.Background
				sliderFrame.BorderColor3 = Theme.Border
				sliderFrame.BorderSizePixel = 1
				sliderFrame.Parent = frame

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BackgroundColor3 = Theme.Accent
				fill.BorderSizePixel = 0
				fill.Parent = sliderFrame

				local thumb = Instance.new("TextButton")
				thumb.Size = UDim2.new(0, 14, 0, 14)
				thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
				thumb.BackgroundColor3 = Theme.Accent
				thumb.BorderSizePixel = 0
				thumb.Text = ""
				thumb.AutoButtonColor = false
				thumb.Parent = sliderFrame

				local glassThumb = Instance.new("Frame")
				glassThumb.Size = UDim2.new(1, 0, 1, 0)
				glassThumb.BackgroundColor3 = Theme.Glass
				glassThumb.BackgroundTransparency = 0.7
				glassThumb.BorderSizePixel = 0
				glassThumb.Parent = thumb

				local draggingSlider = false

				local function updateValue(percent)
					local val = min + (max - min) * percent
					val = math.floor(val * 100 + 0.5) / 100
					fill.Size = UDim2.new(percent, 0, 1, 0)
					thumb.Position = UDim2.new(percent, -7, 0.5, -7)
					valueLabel.Text = tostring(val)
					if callback then callback(val) end
				end

				thumb.MouseButton1Down:Connect(function()
					draggingSlider = true
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local mousePos = UserInputService:GetMouseLocation()
						local relativeX = mousePos.X - sliderFrame.AbsolutePosition.X
						local percent = math.clamp(relativeX / sliderFrame.AbsoluteSize.X, 0, 1)
						updateValue(percent)
					end
				end)

				groupObj:UpdateSize()
				return {SetValue = function(self, val) updateValue((val - min) / (max - min)) end}
			end

			function groupObj:AddDropdown(name, options, default, callback)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 28)
				frame.BackgroundTransparency = 1
				frame.Parent = content

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.4, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = name
				label.TextColor3 = Theme.Text
				label.Font = Enum.Font.Gotham
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = frame

				local dropdownButton = Instance.new("TextButton")
				dropdownButton.Size = UDim2.new(0.6, 0, 1, 0)
				dropdownButton.Position = UDim2.new(0.4, 0, 0, 0)
				dropdownButton.BackgroundColor3 = Theme.Surface
				dropdownButton.BorderColor3 = Theme.Border
				dropdownButton.BorderSizePixel = 1
				dropdownButton.Text = default or options[1]
				dropdownButton.TextColor3 = Theme.Text
				dropdownButton.Font = Enum.Font.Gotham
				dropdownButton.TextSize = 13
				dropdownButton.Parent = frame
				CreateShadow(dropdownButton)

				local listFrame = Instance.new("Frame")
				listFrame.Size = UDim2.new(0.6, 0, 0, 0)
				listFrame.Position = UDim2.new(0.4, 0, 1, 2)
				listFrame.BackgroundColor3 = Theme.Surface
				listFrame.BorderColor3 = Theme.Border
				listFrame.BorderSizePixel = 1
				listFrame.Visible = false
				listFrame.ZIndex = 5
				listFrame.Parent = frame
				CreateShadow(listFrame)

				local listLayout = Instance.new("UIListLayout")
				listLayout.Parent = listFrame

				local function toggleDropdown()
					listFrame.Visible = not listFrame.Visible
					if listFrame.Visible then
						local totalHeight = #options * 28
						CreateTween(listFrame, {Size = UDim2.new(0.6, 0, 0, totalHeight)})
					else
						CreateTween(listFrame, {Size = UDim2.new(0.6, 0, 0, 0)})
					end
				end

				dropdownButton.MouseButton1Click:Connect(toggleDropdown)

				for _, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 28)
					optBtn.BackgroundTransparency = 1
					optBtn.Text = opt
					optBtn.TextColor3 = Theme.Text
					optBtn.Font = Enum.Font.Gotham
					optBtn.TextSize = 13
					optBtn.Parent = listFrame

					optBtn.MouseEnter:Connect(function()
						CreateTween(optBtn, {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0})
					end)
					optBtn.MouseLeave:Connect(function()
						CreateTween(optBtn, {BackgroundTransparency = 1})
					end)
					optBtn.MouseButton1Click:Connect(function()
						dropdownButton.Text = opt
						toggleDropdown()
						if callback then callback(opt) end
					end)
				end

				groupObj:UpdateSize()
				return dropdownButton
			end

			function groupObj:AddMultiDropdown(name, options, callback)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 28)
				frame.BackgroundTransparency = 1
				frame.Parent = content

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.4, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = name
				label.TextColor3 = Theme.Text
				label.Font = Enum.Font.Gotham
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = frame

				local displayButton = Instance.new("TextButton")
				displayButton.Size = UDim2.new(0.6, 0, 1, 0)
				displayButton.Position = UDim2.new(0.4, 0, 0, 0)
				displayButton.BackgroundColor3 = Theme.Surface
				displayButton.BorderColor3 = Theme.Border
				displayButton.BorderSizePixel = 1
				displayButton.Text = "Select..."
				displayButton.TextColor3 = Theme.Text
				displayButton.Font = Enum.Font.Gotham
				displayButton.TextSize = 13
				displayButton.Parent = frame
				CreateShadow(displayButton)

				local listFrame = Instance.new("Frame")
				listFrame.Size = UDim2.new(0.6, 0, 0, 0)
				listFrame.Position = UDim2.new(0.4, 0, 1, 2)
				listFrame.BackgroundColor3 = Theme.Surface
				listFrame.BorderColor3 = Theme.Border
				listFrame.BorderSizePixel = 1
				listFrame.Visible = false
				listFrame.ZIndex = 5
				listFrame.Parent = frame
				CreateShadow(listFrame)

				local listLayout = Instance.new("UIListLayout")
				listLayout.Parent = listFrame

				local selected = {}
				local checkboxes = {}

				local function updateDisplay()
					local selectedList = {}
					for opt, state in pairs(selected) do if state then table.insert(selectedList, opt) end end
					displayButton.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "Select..."
					if callback then callback(selectedList) end
				end

				local function toggleDropdown()
					listFrame.Visible = not listFrame.Visible
					if listFrame.Visible then
						local totalHeight = #options * 28
						CreateTween(listFrame, {Size = UDim2.new(0.6, 0, 0, totalHeight)})
					else
						CreateTween(listFrame, {Size = UDim2.new(0.6, 0, 0, 0)})
					end
				end

				displayButton.MouseButton1Click:Connect(toggleDropdown)

				for _, opt in ipairs(options) do
					local optFrame = Instance.new("Frame")
					optFrame.Size = UDim2.new(1, 0, 0, 28)
					optFrame.BackgroundTransparency = 1
					optFrame.Parent = listFrame

					local check = Instance.new("TextButton")
					check.Size = UDim2.new(0, 20, 0, 20)
					check.Position = UDim2.new(0, 5, 0.5, -10)
					check.BackgroundColor3 = Theme.Background
					check.BorderColor3 = Theme.Border
					check.BorderSizePixel = 1
					check.Text = ""
					check.Parent = optFrame

					local checkFill = Instance.new("Frame")
					checkFill.Size = UDim2.new(1, -4, 1, -4)
					checkFill.Position = UDim2.new(0, 2, 0, 2)
					checkFill.BackgroundColor3 = Theme.Accent
					checkFill.BorderSizePixel = 0
					checkFill.Visible = false
					checkFill.Parent = check

					local optLabel = Instance.new("TextLabel")
					optLabel.Size = UDim2.new(1, -30, 1, 0)
					optLabel.Position = UDim2.new(0, 30, 0, 0)
					optLabel.BackgroundTransparency = 1
					optLabel.Text = opt
					optLabel.TextColor3 = Theme.Text
					optLabel.Font = Enum.Font.Gotham
					optLabel.TextSize = 13
					optLabel.TextXAlignment = Enum.TextXAlignment.Left
					optLabel.Parent = optFrame

					selected[opt] = false

					check.MouseButton1Click:Connect(function()
						selected[opt] = not selected[opt]
						checkFill.Visible = selected[opt]
						updateDisplay()
					end)
				end

				groupObj:UpdateSize()
				return {SetSelected = function(self, opts) for _, opt in pairs(opts) do selected[opt] = true; checkboxes[opt].Visible = true end; updateDisplay() end}
			end

			function groupObj:AddColorBox(name, default, callback)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 28)
				frame.BackgroundTransparency = 1
				frame.Parent = content

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.7, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = name
				label.TextColor3 = Theme.Text
				label.Font = Enum.Font.Gotham
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = frame

				local colorButton = Instance.new("TextButton")
				colorButton.Size = UDim2.new(0, 28, 0, 28)
				colorButton.Position = UDim2.new(1, -28, 0, 0)
				colorButton.BackgroundColor3 = default or Color3.new(1,1,1)
				colorButton.BorderColor3 = Theme.Border
				colorButton.BorderSizePixel = 1
				colorButton.Text = ""
				colorButton.Parent = frame

				colorButton.MouseButton1Click:Connect(function()
					local picker = Instance.new("ScreenGui")
					picker.Parent = CoreGui
					local pickerFrame = Instance.new("Frame")
					pickerFrame.Size = UDim2.new(0, 200, 0, 200)
					pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
					pickerFrame.BackgroundColor3 = Theme.Surface
					pickerFrame.BorderColor3 = Theme.Border
					pickerFrame.BorderSizePixel = 1
					pickerFrame.Parent = picker
					CreateShadow(pickerFrame)

					local hueGradient = Instance.new("UIGradient")
					hueGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
						ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)),
						ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)),
						ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
						ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)),
						ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
						ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
					})

					local colorCanvas = Instance.new("Frame")
					colorCanvas.Size = UDim2.new(1, -10, 1, -40)
					colorCanvas.Position = UDim2.new(0, 5, 0, 5)
					colorCanvas.BackgroundColor3 = Color3.new(1,1,1)
					colorCanvas.BorderSizePixel = 0
					colorCanvas.Parent = pickerFrame
					hueGradient.Parent = colorCanvas

					local satValCanvas = Instance.new("Frame")
					satValCanvas.Size = UDim2.new(1, 0, 1, 0)
					satValCanvas.BackgroundColor3 = Color3.new(1,1,1)
					satValCanvas.BorderSizePixel = 0
					satValCanvas.Parent = colorCanvas
					local satValGradient = Instance.new("UIGradient")
					satValGradient.Rotation = 90
					satValGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
						ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
					})
					satValGradient.Parent = satValCanvas

					local confirm = Instance.new("TextButton")
					confirm.Size = UDim2.new(1, -10, 0, 25)
					confirm.Position = UDim2.new(0, 5, 1, -30)
					confirm.BackgroundColor3 = Theme.Accent
					confirm.BorderSizePixel = 0
					confirm.Text = "Confirm"
					confirm.TextColor3 = Theme.Text
					confirm.Font = Enum.Font.Gotham
					confirm.TextSize = 13
					confirm.Parent = pickerFrame

					confirm.MouseButton1Click:Connect(function()
						if callback then callback(colorButton.BackgroundColor3) end
						picker:Destroy()
					end)

					local huePicker = Instance.new("Frame")
					huePicker.Size = UDim2.new(0, 20, 1, -40)
					huePicker.Position = UDim2.new(1, -25, 0, 5)
					huePicker.BackgroundColor3 = Color3.new(1,1,1)
					huePicker.BorderSizePixel = 0
					huePicker.Parent = pickerFrame
					local hueGrad = Instance.new("UIGradient")
					hueGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
						ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)),
						ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)),
						ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
						ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)),
						ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
						ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
					})
					hueGrad.Parent = huePicker

					groupObj:UpdateSize()
				end)

				groupObj:UpdateSize()
				return colorButton
			end

			function groupObj:AddPickerBox(name, options, default, callback)
				return groupObj:AddDropdown(name, options, default, callback)
			end

			function groupObj:AddLabel(text)
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0, 20)
				label.BackgroundTransparency = 1
				label.Text = text
				label.TextColor3 = Theme.TextSecondary
				label.Font = Enum.Font.Gotham
				label.TextSize = 12
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = content
				groupObj:UpdateSize()
				return label
			end

			function groupObj:AddTextbox(name, default, callback)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 28)
				frame.BackgroundTransparency = 1
				frame.Parent = content

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.4, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = name
				label.TextColor3 = Theme.Text
				label.Font = Enum.Font.Gotham
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = frame

				local box = Instance.new("TextBox")
				box.Size = UDim2.new(0.6, 0, 1, 0)
				box.Position = UDim2.new(0.4, 0, 0, 0)
				box.BackgroundColor3 = Theme.Surface
				box.BorderColor3 = Theme.Border
				box.BorderSizePixel = 1
				box.Text = default or ""
				box.TextColor3 = Theme.Text
				box.Font = Enum.Font.Gotham
				box.TextSize = 13
				box.Parent = frame

				box.FocusLost:Connect(function(enterPressed)
					if callback then callback(box.Text) end
				end)

				groupObj:UpdateSize()
				return box
			end

			table.insert(tabObj.SubTabs, subObj)
			subButton.MouseButton1Click:Connect(function() subObj:Select() end)
			if #tabObj.SubTabs == 1 then subObj:Select() end
			return subObj
		end

		table.insert(self.Tabs, tabObj)
		tabButton.MouseButton1Click:Connect(function() tabObj:Select() end)
		if #self.Tabs == 1 then tabObj:Select() end
		return tabObj
	end

	self.Tabs[1]:Select()
	return self.Tabs[1]
end

function Sight.CreateWindow(options)
	options = options or {}
	local title = options.Title or "sight"
	local keybind = options.Keybind or Enum.KeyCode.RightShift

	local gui = Instance.new("ScreenGui")
	gui.Name = "sight"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = CoreGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 600, 0, 450)
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
	mainFrame.BackgroundColor3 = Theme.Background
	mainFrame.BorderColor3 = Theme.Border
	mainFrame.BorderSizePixel = 1
	mainFrame.Parent = gui
	CreateShadow(mainFrame)

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Theme.Surface
	titleBar.BorderColor3 = Theme.Border
	titleBar.BorderSizePixel = 1
	titleBar.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Text
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 1, 0)
	closeButton.Position = UDim2.new(1, -30, 0, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "×"
	closeButton.TextColor3 = Theme.TextSecondary
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 18
	closeButton.Parent = titleBar

	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, 0, 0, 30)
	tabContainer.Position = UDim2.new(0, 0, 0, 30)
	tabContainer.BackgroundColor3 = Theme.Surface
	tabContainer.BorderColor3 = Theme.Border
	tabContainer.BorderSizePixel = 1
	tabContainer.Parent = mainFrame

	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Parent = tabContainer

	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, -10, 1, -65)
	contentArea.Position = UDim2.new(0, 5, 0, 60)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainFrame

	local windowObj = setmetatable({
		Gui = gui,
		MainFrame = mainFrame,
		TabContainer = tabContainer,
		ContentArea = contentArea,
		Tabs = {},
		Keybind = keybind,
		Visible = true,
		Draggable = true,
		Scale = 1
	}, WindowClass)

	MakeDraggable(mainFrame, titleBar)

	closeButton.MouseButton1Click:Connect(function()
		windowObj.Visible = false
		mainFrame.Visible = false
	end)

	local function toggleUI()
		windowObj.Visible = not windowObj.Visible
		mainFrame.Visible = windowObj.Visible
	end

	ContextActionService:BindAction("sight_toggle", toggleUI, false, keybind)

	local mobileToggle
	if UserInputService.TouchEnabled then
		mobileToggle = Instance.new("ImageButton")
		mobileToggle.Size = UDim2.new(0, 50, 0, 50)
		mobileToggle.Position = UDim2.new(0, 20, 0.5, -25)
		mobileToggle.BackgroundColor3 = Theme.Surface
		mobileToggle.BorderColor3 = Theme.Border
		mobileToggle.BorderSizePixel = 1
		mobileToggle.Image = "rbxassetid://3926305904"
		mobileToggle.ImageRectSize = Vector2.new(36, 36)
		mobileToggle.ImageRectOffset = Vector2.new(4, 4)
		mobileToggle.ImageColor3 = Theme.Accent
		mobileToggle.Parent = gui
		CreateShadow(mobileToggle)

		mobileToggle.MouseButton1Click:Connect(toggleUI)

		local glassOverlay = Instance.new("Frame")
		glassOverlay.Size = UDim2.new(1, 0, 1, 0)
		glassOverlay.BackgroundColor3 = Theme.Glass
		glassOverlay.BackgroundTransparency = 0.8
		glassOverlay.BorderSizePixel = 0
		glassOverlay.Parent = mobileToggle
	end

	local settingsTab = windowObj:Tab("Settings")
	local settingsSub = settingsTab:SubTab("General")
	local configGroup = settingsSub:AddGroup("Configuration")

	configGroup:AddButton("Save Config", function()
		local config = {Theme = Theme, Scale = windowObj.Scale}
		writefile("sight_config.json", HttpService:JSONEncode(config))
	end)

	configGroup:AddButton("Load Config", function()
		pcall(function()
			local data = readfile("sight_config.json")
			local config = HttpService:JSONDecode(data)
			if config.Theme then
				for k, v in pairs(config.Theme) do Theme[k] = v end
			end
			if config.Scale then
				windowObj.Scale = config.Scale
				mainFrame.Size = UDim2.new(0, 600 * config.Scale, 0, 450 * config.Scale)
				mainFrame.Position = UDim2.new(0.5, -300 * config.Scale, 0.5, -225 * config.Scale)
			end
		end)
	end)

	local accentGroup = settingsSub:AddGroup("Accent Color")
	accentGroup:AddColorBox("Accent", Theme.Accent, function(color)
		Theme.Accent = color
	end)

	local draggableToggle = settingsSub:AddToggle("Draggable", true, function(state)
		windowObj.Draggable = state
		MakeDraggable(mainFrame, state and titleBar or nil)
	end)

	local scaleSlider = settingsSub:AddSlider("UI Scale", 0.5, 1.5, 1, function(val)
		windowObj.Scale = val
		mainFrame.Size = UDim2.new(0, 600 * val, 0, 450 * val)
		mainFrame.Position = UDim2.new(0.5, -300 * val, 0.5, -225 * val)
	end)

	local keybindSub = settingsTab:SubTab("Keybinds")
	local keyGroup = keybindSub:AddGroup("UI Toggle")
	keyGroup:AddLabel("Current: " .. tostring(keybind))
	keyGroup:AddButton("Set Keybind", function()
		keyGroup:AddLabel("Press any key...")
		local connection
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
				ContextActionService:UnbindAction("sight_toggle")
				ContextActionService:BindAction("sight_toggle", toggleUI, false, input.KeyCode)
				keyGroup:AddLabel("New key: " .. tostring(input.KeyCode))
				connection:Disconnect()
			end
		end)
		task.wait(5)
		connection:Disconnect()
	end)

	local licenseFrame = Instance.new("Frame")
	licenseFrame.Size = UDim2.new(0, 200, 0, 100)
	licenseFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
	licenseFrame.BackgroundColor3 = Theme.Surface
	licenseFrame.BorderColor3 = Theme.Border
	licenseFrame.BorderSizePixel = 1
	licenseFrame.Parent = mainFrame
	licenseFrame.Visible = false
	CreateShadow(licenseFrame)

	local licenseTitle = Instance.new("TextLabel")
	licenseTitle.Size = UDim2.new(1, 0, 0, 25)
	licenseTitle.BackgroundTransparency = 1
	licenseTitle.Text = "License"
	licenseTitle.TextColor3 = Theme.Text
	licenseTitle.Font = Enum.Font.GothamBold
	licenseTitle.TextSize = 14
	licenseTitle.Parent = licenseFrame

	local licenseInput = Instance.new("TextBox")
	licenseInput.Size = UDim2.new(1, -20, 0, 30)
	licenseInput.Position = UDim2.new(0, 10, 0, 30)
	licenseInput.BackgroundColor3 = Theme.Background
	licenseInput.BorderColor3 = Theme.Border
	licenseInput.BorderSizePixel = 1
	licenseInput.Text = ""
	licenseInput.PlaceholderText = "Enter key..."
	licenseInput.TextColor3 = Theme.Text
	licenseInput.Font = Enum.Font.Gotham
	licenseInput.TextSize = 13
	licenseInput.Parent = licenseFrame

	local loginButton = Instance.new("TextButton")
	loginButton.Size = UDim2.new(1, -20, 0, 28)
	loginButton.Position = UDim2.new(0, 10, 0, 65)
	loginButton.BackgroundColor3 = Theme.Accent
	loginButton.BorderSizePixel = 0
	loginButton.Text = "Login"
	loginButton.TextColor3 = Theme.Text
	loginButton.Font = Enum.Font.GothamBold
	loginButton.TextSize = 13
	loginButton.Parent = licenseFrame

	local glassLogin = Instance.new("Frame")
	glassLogin.Size = UDim2.new(1, 0, 1, 0)
	glassLogin.BackgroundColor3 = Theme.Glass
	glassLogin.BackgroundTransparency = 0.7
	glassLogin.BorderSizePixel = 0
	glassLogin.Parent = loginButton

	loginButton.MouseButton1Click:Connect(function()
		licenseFrame.Visible = false
	end)

	if not options.SkipLicense then
		licenseFrame.Visible = true
	end

	return windowObj
end

return Sight
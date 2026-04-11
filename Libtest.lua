local SightLibrary = {}
SightLibrary.__index = SightLibrary

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function ApplyGlassmorphism(Frame, Transparency, BlurAmount)
	Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Frame.BackgroundTransparency = Transparency or 0.65
	Frame.BorderSizePixel = 0
	Frame.ClipsDescendants = true

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(255, 255, 255)
	Stroke.Thickness = 1
	Stroke.Transparency = 0.8
	Stroke.Parent = Frame

	local Gradient = Instance.new("UIGradient")
	Gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
	})
	Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(1, 0.5)
	})
	Gradient.Rotation = 135
	Gradient.Parent = Frame

	local Blur = Instance.new("BlurEffect")
	Blur.Size = BlurAmount or 12
	Blur.Parent = Frame
end

local function ApplyTween(Object, Properties, Duration, EasingStyle, EasingDirection)
	local TweenInfo = TweenInfo.new(Duration, EasingStyle or Enum.EasingStyle.Quart, EasingDirection or Enum.EasingDirection.Out)
	local Tween = TweenService:Create(Object, TweenInfo, Properties)
	Tween:Play()
	return Tween
end

function SightLibrary:CreateWindow(Config)
	Config = Config or {}
	local Window = setmetatable({
		Title = Config.Title or "Sight UI",
		Theme = Config.Theme or "Dark",
		AccentColor = Config.AccentColor or Color3.fromRGB(100, 150, 255),
		Draggable = Config.Draggable ~= false,
		Scale = Config.Scale or 1,
		Tabs = {},
		Subtabs = {},
		CurrentTab = nil,
		CurrentSubtab = nil,
		Elements = {},
		LicenseValidated = false,
		RememberMe = false
	}, SightLibrary)

	Window.ScreenGui = Instance.new("ScreenGui")
	Window.ScreenGui.Name = "SightLibrary"
	Window.ScreenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(Window.ScreenGui)) or CoreGui
	Window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Blur = Instance.new("BlurEffect")
	Blur.Size = 0
	Blur.Parent = Window.ScreenGui

	Window.MainContainer = Instance.new("Frame")
	Window.MainContainer.Size = UDim2.new(0, 600, 0, 400)
	Window.MainContainer.Position = UDim2.new(0.5, -300, 0.5, -200)
	Window.MainContainer.BackgroundTransparency = 1
	Window.MainContainer.BorderSizePixel = 0
	Window.MainContainer.Parent = Window.ScreenGui

	local UIScale = Instance.new("UIScale")
	UIScale.Scale = Window.Scale
	UIScale.Parent = Window.MainContainer

	Window.MainFrame = Instance.new("Frame")
	Window.MainFrame.Size = UDim2.new(1, 0, 1, 0)
	Window.MainFrame.Parent = Window.MainContainer
	ApplyGlassmorphism(Window.MainFrame, 0.7, 16)

	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 30)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = Window.MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -60, 1, 0)
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Window.Title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextSize = 16
	TitleLabel.Parent = TopBar

	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -30, 0, 0)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "×"
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
	CloseButton.TextSize = 20
	CloseButton.Parent = TopBar
	CloseButton.MouseButton1Click:Connect(function()
		Window.ScreenGui:Destroy()
	end)

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1, 0, 0, 35)
	TabContainer.Position = UDim2.new(0, 0, 0, 30)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = Window.MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 2)
	UIListLayout.Parent = TabContainer

	local SubtabContainer = Instance.new("Frame")
	SubtabContainer.Size = UDim2.new(1, 0, 0, 30)
	SubtabContainer.Position = UDim2.new(0, 0, 0, 65)
	SubtabContainer.BackgroundTransparency = 1
	SubtabContainer.Visible = false
	SubtabContainer.Parent = Window.MainFrame

	local SubtabListLayout = Instance.new("UIListLayout")
	SubtabListLayout.FillDirection = Enum.FillDirection.Horizontal
	SubtabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SubtabListLayout.Padding = UDim.new(0, 2)
	SubtabListLayout.Parent = SubtabContainer

	Window.ContentFrame = Instance.new("Frame")
	Window.ContentFrame.Size = UDim2.new(1, -20, 1, -110)
	Window.ContentFrame.Position = UDim2.new(0, 10, 0, 100)
	Window.ContentFrame.BackgroundTransparency = 1
	Window.ContentFrame.Parent = Window.MainFrame

	local LeftContainer = Instance.new("ScrollingFrame")
	LeftContainer.Size = UDim2.new(0.5, -5, 1, 0)
	LeftContainer.BackgroundTransparency = 1
	LeftContainer.BorderSizePixel = 0
	LeftContainer.ScrollBarThickness = 4
	LeftContainer.ScrollBarImageColor3 = Window.AccentColor
	LeftContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	LeftContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	LeftContainer.Parent = Window.ContentFrame

	local LeftListLayout = Instance.new("UIListLayout")
	LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	LeftListLayout.Padding = UDim.new(0, 5)
	LeftListLayout.Parent = LeftContainer

	local RightContainer = Instance.new("ScrollingFrame")
	RightContainer.Size = UDim2.new(0.5, -5, 1, 0)
	RightContainer.Position = UDim2.new(0.5, 5, 0, 0)
	RightContainer.BackgroundTransparency = 1
	RightContainer.BorderSizePixel = 0
	RightContainer.ScrollBarThickness = 4
	RightContainer.ScrollBarImageColor3 = Window.AccentColor
	RightContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	RightContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	RightContainer.Parent = Window.ContentFrame

	local RightListLayout = Instance.new("UIListLayout")
	RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	RightListLayout.Padding = UDim.new(0, 5)
	RightListLayout.Parent = RightContainer

	Window.LeftContainer = LeftContainer
	Window.RightContainer = RightContainer
	Window.TabContainer = TabContainer
	Window.SubtabContainer = SubtabContainer
	Window.UIScale = UIScale
	Window.Blur = Blur

	if Window.Draggable then
		local Dragging, DragStart, StartPos
		TopBar.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = Input.Position
				StartPos = Window.MainContainer.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		TopBar.InputChanged:Connect(function(Input)
			if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
				local Delta = Input.Position - DragStart
				Window.MainContainer.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
			end
		end)
	end

	Window:CreateLicenseFrame()
	Window:CreateSettingsTab()

	if IsMobile() then
		Window:CreateFloatingButton()
	end

	return Window
end

function SightLibrary:CreateLicenseFrame()
	local LicenseFrame = Instance.new("Frame")
	LicenseFrame.Size = UDim2.new(1, 0, 1, 0)
	LicenseFrame.BackgroundTransparency = 1
	LicenseFrame.Visible = true
	LicenseFrame.Parent = self.MainFrame

	local LicenseContainer = Instance.new("Frame")
	LicenseContainer.Size = UDim2.new(0, 300, 0, 180)
	LicenseContainer.Position = UDim2.new(0.5, -150, 0.5, -90)
	LicenseContainer.Parent = LicenseFrame
	ApplyGlassmorphism(LicenseContainer, 0.6, 20)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 30)
	Title.Position = UDim2.new(0, 0, 0, 10)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.Text = "License Activation"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 18
	Title.Parent = LicenseContainer

	local InputBox = Instance.new("TextBox")
	InputBox.Size = UDim2.new(1, -40, 0, 30)
	InputBox.Position = UDim2.new(0, 20, 0, 50)
	InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	InputBox.BackgroundTransparency = 0.5
	InputBox.BorderSizePixel = 0
	InputBox.Font = Enum.Font.Code
	InputBox.PlaceholderText = "XXXX-XXXX-XXXX"
	InputBox.Text = ""
	InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	InputBox.TextSize = 14
	InputBox.ClearTextOnFocus = false
	Instance.new("UIStroke", InputBox).Color = self.AccentColor
	InputBox.Parent = LicenseContainer

	local RememberToggle = self:CreateToggle({
		Title = "Remember Me",
		Default = false,
		Callback = function(Value)
			self.RememberMe = Value
		end
	})
	RememberToggle.Frame.Parent = LicenseContainer
	RememberToggle.Frame.Position = UDim2.new(0, 20, 0, 90)

	local ValidateButton = Instance.new("TextButton")
	ValidateButton.Size = UDim2.new(1, -40, 0, 35)
	ValidateButton.Position = UDim2.new(0, 20, 1, -45)
	ValidateButton.BackgroundColor3 = self.AccentColor
	ValidateButton.BorderSizePixel = 0
	ValidateButton.Font = Enum.Font.GothamBold
	ValidateButton.Text = "Validate"
	ValidateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ValidateButton.TextSize = 16
	ValidateButton.Parent = LicenseContainer

	ValidateButton.MouseButton1Click:Connect(function()
		local Success, Result = pcall(function()
			if InputBox.Text == "SIGHT-2024-DEMO" or InputBox.Text == "" then
				return true
			end
			return false
		end)
		if Success and Result then
			ApplyTween(LicenseContainer, {Position = UDim2.new(1.5, 0, 0.5, 0)}, 0.3)
			task.wait(0.3)
			LicenseFrame:Destroy()
			self.LicenseValidated = true
		else
			InputBox.Text = ""
			InputBox.PlaceholderText = "Invalid License"
			ApplyTween(InputBox, {TextColor3 = Color3.fromRGB(255, 100, 100)}, 0.1)
		end
	end)

	self.LicenseFrame = LicenseFrame
end

function SightLibrary:CreateTab(Config)
	local TabButton = Instance.new("TextButton")
	TabButton.Size = UDim2.new(0, 100, 1, 0)
	TabButton.BackgroundTransparency = 1
	TabButton.Font = Enum.Font.Gotham
	TabButton.Text = Config.Title
	TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
	TabButton.TextSize = 14
	TabButton.Parent = self.TabContainer

	local Tab = {
		Button = TabButton,
		Title = Config.Title,
		Subtabs = {},
		Elements = {},
		Active = false
	}

	TabButton.MouseButton1Click:Connect(function()
		self:SwitchTab(Tab)
	end)

	table.insert(self.Tabs, Tab)
	return Tab
end

function SightLibrary:SwitchTab(Tab)
	if self.CurrentTab == Tab then return end
	if self.CurrentTab then
		self.CurrentTab.Active = false
		ApplyTween(self.CurrentTab.Button, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
	end
	self.CurrentTab = Tab
	Tab.Active = true
	ApplyTween(Tab.Button, {TextColor3 = self.AccentColor}, 0.2)

	self.SubtabContainer.Visible = #Tab.Subtabs > 0
	if #Tab.Subtabs > 0 then
		for _, Subtab in ipairs(Tab.Subtabs) do
			Subtab.Button.Visible = true
		end
		self:SwitchSubtab(Tab.Subtabs[1])
	else
		self:ClearContent()
		self:PopulateElements(Tab.Elements)
	end
end

function SightLibrary:CreateSubTab(ParentTab, Config)
	local SubtabButton = Instance.new("TextButton")
	SubtabButton.Size = UDim2.new(0, 80, 1, 0)
	SubtabButton.BackgroundTransparency = 1
	SubtabButton.Font = Enum.Font.Gotham
	SubtabButton.Text = Config.Title
	SubtabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
	SubtabButton.TextSize = 13
	SubtabButton.Visible = false
	SubtabButton.Parent = self.SubtabContainer

	local Subtab = {
		Button = SubtabButton,
		Title = Config.Title,
		ParentTab = ParentTab,
		Elements = {},
		Active = false
	}

	SubtabButton.MouseButton1Click:Connect(function()
		self:SwitchSubtab(Subtab)
	end)

	table.insert(ParentTab.Subtabs, Subtab)
	return Subtab
end

function SightLibrary:SwitchSubtab(Subtab)
	if self.CurrentSubtab == Subtab then return end
	if self.CurrentSubtab then
		self.CurrentSubtab.Active = false
		ApplyTween(self.CurrentSubtab.Button, {TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.2)
	end
	self.CurrentSubtab = Subtab
	Subtab.Active = true
	ApplyTween(Subtab.Button, {TextColor3 = self.AccentColor}, 0.2)

	self:ClearContent()
	self:PopulateElements(Subtab.Elements)
end

function SightLibrary:ClearContent()
	for _, Child in ipairs(self.LeftContainer:GetChildren()) do
		if Child:IsA("Frame") then Child:Destroy() end
	end
	for _, Child in ipairs(self.RightContainer:GetChildren()) do
		if Child:IsA("Frame") then Child:Destroy() end
	end
end

function SightLibrary:PopulateElements(Elements)
	local LeftCount, RightCount = 0, 0
	for _, Element in ipairs(Elements) do
		Element.Frame.LayoutOrder = LeftCount + RightCount
		if #self.LeftContainer:GetChildren() <= #self.RightContainer:GetChildren() then
			Element.Frame.Parent = self.LeftContainer
			LeftCount = LeftCount + 1
		else
			Element.Frame.Parent = self.RightContainer
			RightCount = RightCount + 1
		end
	end
	self.LeftContainer.CanvasSize = UDim2.new(0, 0, 0, LeftCount * 45)
	self.RightContainer.CanvasSize = UDim2.new(0, 0, 0, RightCount * 45)
end

function SightLibrary:CreateButton(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.BackgroundColor3 = self.AccentColor
	Button.BackgroundTransparency = 0.8
	Button.BorderSizePixel = 0
	Button.Font = Enum.Font.Gotham
	Button.Text = Config.Title
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 14
	Button.Parent = Frame
	ApplyGlassmorphism(Button, 0.85, 8)

	Button.MouseEnter:Connect(function()
		ApplyTween(Button, {BackgroundTransparency = 0.7}, 0.2)
	end)
	Button.MouseLeave:Connect(function()
		ApplyTween(Button, {BackgroundTransparency = 0.85}, 0.2)
	end)
	Button.MouseButton1Click:Connect(function()
		ApplyTween(Button, {BackgroundTransparency = 0.5}, 0.1)
		task.wait(0.1)
		ApplyTween(Button, {BackgroundTransparency = 0.7}, 0.1)
		if Config.Callback then Config.Callback() end
	end)

	return { Frame = Frame, Button = Button }
end

function SightLibrary:CreateToggle(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.7, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(0, 40, 0, 20)
	ToggleFrame.Position = UDim2.new(1, -45, 0.5, -10)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	ToggleFrame.BackgroundTransparency = 0.5
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = Frame
	Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(1, 0)

	local ToggleKnob = Instance.new("Frame")
	ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
	ToggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
	ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ToggleKnob.BorderSizePixel = 0
	ToggleKnob.Parent = ToggleFrame
	Instance.new("UICorner", ToggleKnob).CornerRadius = UDim.new(1, 0)

	local State = Config.Default or false
	local function Update()
		if State then
			ApplyTween(ToggleFrame, {BackgroundColor3 = self.AccentColor}, 0.2)
			ApplyTween(ToggleKnob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
		else
			ApplyTween(ToggleFrame, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.2)
			ApplyTween(ToggleKnob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
		end
		if Config.Callback then Config.Callback(State) end
	end
	Update()

	ToggleFrame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			State = not State
			Update()
		end
	end)

	return { Frame = Frame, Toggle = ToggleFrame, State = State }
end

function SightLibrary:CreateSlider(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 60)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title .. ": " .. tostring(Config.Default or Config.Min or 0)
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, -10, 0, 6)
	SliderFrame.Position = UDim2.new(0, 5, 0, 25)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	SliderFrame.BackgroundTransparency = 0.5
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = Frame
	Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(0, 0, 1, 0)
	Fill.BackgroundColor3 = self.AccentColor
	Fill.BorderSizePixel = 0
	Fill.Parent = SliderFrame
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local Knob = Instance.new("TextButton")
	Knob.Size = UDim2.new(0, 14, 0, 14)
	Knob.Position = UDim2.new(0, 0, 0.5, -7)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Knob.BorderSizePixel = 0
	Knob.Text = ""
	Knob.Parent = SliderFrame
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local InputBox = Instance.new("TextBox")
	InputBox.Size = UDim2.new(0, 50, 0, 20)
	InputBox.Position = UDim2.new(1, -55, 0, 0)
	InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	InputBox.BackgroundTransparency = 0.5
	InputBox.BorderSizePixel = 0
	InputBox.Font = Enum.Font.Code
	InputBox.Text = tostring(Config.Default or Config.Min or 0)
	InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	InputBox.TextSize = 12
	InputBox.Parent = Frame

	local Min = Config.Min or 0
	local Max = Config.Max or 100
	local Value = Config.Default or Min

	local function SetValue(NewValue)
		Value = math.clamp(tonumber(NewValue) or Min, Min, Max)
		Label.Text = Config.Title .. ": " .. tostring(Value)
		InputBox.Text = tostring(Value)
		local Percent = (Value - Min) / (Max - Min)
		Fill.Size = UDim2.new(Percent, 0, 1, 0)
		Knob.Position = UDim2.new(Percent, -7, 0.5, -7)
		if Config.Callback then Config.Callback(Value) end
	end

	local function Slide(Input)
		local MousePos = UserInputService:GetMouseLocation()
		local RelativePos = MousePos - SliderFrame.AbsolutePosition
		local Percent = math.clamp(RelativePos.X / SliderFrame.AbsoluteSize.X, 0, 1)
		SetValue(Min + (Max - Min) * Percent)
	end

	Knob.MouseButton1Down:Connect(function()
		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				Connection:Disconnect()
				return
			end
			Slide()
		end)
	end)

	SliderFrame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Slide()
		end
	end)

	InputBox.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then
			SetValue(tonumber(InputBox.Text))
		end
	end)

	SetValue(Value)
	return { Frame = Frame, Slider = SliderFrame, SetValue = SetValue }
end

function SightLibrary:CreateDropdown(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.4, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local DropButton = Instance.new("TextButton")
	DropButton.Size = UDim2.new(0.55, 0, 1, 0)
	DropButton.Position = UDim2.new(0.45, 0, 0, 0)
	DropButton.BackgroundColor3 = self.AccentColor
	DropButton.BackgroundTransparency = 0.8
	DropButton.BorderSizePixel = 0
	DropButton.Font = Enum.Font.Gotham
	DropButton.Text = Config.Default or "Select..."
	DropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	DropButton.TextSize = 13
	DropButton.Parent = Frame
	ApplyGlassmorphism(DropButton, 0.85, 8)

	local DropdownList = Instance.new("ScrollingFrame")
	DropdownList.Size = UDim2.new(0.55, 0, 0, 120)
	DropdownList.Position = UDim2.new(0.45, 0, 1, 2)
	DropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	DropdownList.BackgroundTransparency = 0.3
	DropdownList.BorderSizePixel = 0
	DropdownList.ScrollBarThickness = 3
	DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
	DropdownList.Visible = false
	DropdownList.ZIndex = 10
	DropdownList.Parent = Frame
	ApplyGlassmorphism(DropdownList, 0.5, 10)

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = DropdownList

	local Options = Config.Options or {}
	local Selected = Config.Default or (Options[1] or "None")

	local function ToggleDropdown()
		DropdownList.Visible = not DropdownList.Visible
	end

	DropButton.MouseButton1Click:Connect(ToggleDropdown)

	local function SelectOption(Option)
		Selected = Option
		DropButton.Text = Option
		DropdownList.Visible = false
		if Config.Callback then Config.Callback(Option) end
	end

	for _, Option in ipairs(Options) do
		local OptionButton = Instance.new("TextButton")
		OptionButton.Size = UDim2.new(1, 0, 0, 25)
		OptionButton.BackgroundTransparency = 1
		OptionButton.Font = Enum.Font.Gotham
		OptionButton.Text = Option
		OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		OptionButton.TextSize = 13
		OptionButton.ZIndex = 10
		OptionButton.Parent = DropdownList
		OptionButton.MouseButton1Click:Connect(function()
			SelectOption(Option)
		end)
	end

	DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)

	return { Frame = Frame, Dropdown = DropButton, SetSelected = SelectOption }
end

function SightLibrary:CreateMultiDropdown(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.4, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local DropButton = Instance.new("TextButton")
	DropButton.Size = UDim2.new(0.55, 0, 1, 0)
	DropButton.Position = UDim2.new(0.45, 0, 0, 0)
	DropButton.BackgroundColor3 = self.AccentColor
	DropButton.BackgroundTransparency = 0.8
	DropButton.BorderSizePixel = 0
	DropButton.Font = Enum.Font.Gotham
	DropButton.Text = "Select..."
	DropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	DropButton.TextSize = 13
	DropButton.Parent = Frame
	ApplyGlassmorphism(DropButton, 0.85, 8)

	local DropdownList = Instance.new("ScrollingFrame")
	DropdownList.Size = UDim2.new(0.55, 0, 0, 120)
	DropdownList.Position = UDim2.new(0.45, 0, 1, 2)
	DropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	DropdownList.BackgroundTransparency = 0.3
	DropdownList.BorderSizePixel = 0
	DropdownList.ScrollBarThickness = 3
	DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
	DropdownList.Visible = false
	DropdownList.ZIndex = 10
	DropdownList.Parent = Frame
	ApplyGlassmorphism(DropdownList, 0.5, 10)

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = DropdownList

	local Options = Config.Options or {}
	local Selected = {}

	local function ToggleDropdown()
		DropdownList.Visible = not DropdownList.Visible
	end

	DropButton.MouseButton1Click:Connect(ToggleDropdown)

	local function UpdateSelected()
		local Names = {}
		for _, Opt in ipairs(Selected) do
			table.insert(Names, Opt)
		end
		DropButton.Text = #Names > 0 and table.concat(Names, ", ") or "Select..."
		if Config.Callback then Config.Callback(Selected) end
	end

	for _, Option in ipairs(Options) do
		local OptionFrame = Instance.new("Frame")
		OptionFrame.Size = UDim2.new(1, 0, 0, 25)
		OptionFrame.BackgroundTransparency = 1
		OptionFrame.ZIndex = 10
		OptionFrame.Parent = DropdownList

		local Check = Instance.new("TextButton")
		Check.Size = UDim2.new(0, 20, 0, 20)
		Check.Position = UDim2.new(0, 5, 0.5, -10)
		Check.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		Check.BackgroundTransparency = 0.5
		Check.BorderSizePixel = 0
		Check.Text = ""
		Check.ZIndex = 10
		Check.Parent = OptionFrame

		local CheckLabel = Instance.new("TextLabel")
		CheckLabel.Size = UDim2.new(1, -30, 1, 0)
		CheckLabel.Position = UDim2.new(0, 30, 0, 0)
		CheckLabel.BackgroundTransparency = 1
		CheckLabel.Font = Enum.Font.Gotham
		CheckLabel.Text = Option
		CheckLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		CheckLabel.TextSize = 13
		CheckLabel.TextXAlignment = Enum.TextXAlignment.Left
		CheckLabel.ZIndex = 10
		CheckLabel.Parent = OptionFrame

		local IsSelected = false
		Check.MouseButton1Click:Connect(function()
			IsSelected = not IsSelected
			if IsSelected then
				table.insert(Selected, Option)
				Check.BackgroundColor3 = self.AccentColor
			else
				for i, v in ipairs(Selected) do
					if v == Option then table.remove(Selected, i) break end
				end
				Check.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			end
			UpdateSelected()
		end)
	end

	DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
	return { Frame = Frame, Dropdown = DropButton, GetSelected = function() return Selected end }
end

function SightLibrary:CreateColorPicker(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 45)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.4, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local ColorButton = Instance.new("TextButton")
	ColorButton.Size = UDim2.new(0.2, 0, 1, -5)
	ColorButton.Position = UDim2.new(0.45, 0, 0, 2)
	ColorButton.BackgroundColor3 = Config.Default or Color3.fromRGB(255, 255, 255)
	ColorButton.BorderSizePixel = 0
	ColorButton.Text = ""
	ColorButton.Parent = Frame
	Instance.new("UICorner", ColorButton).CornerRadius = UDim.new(0.3, 0)

	local PickerFrame = Instance.new("Frame")
	PickerFrame.Size = UDim2.new(0, 200, 0, 200)
	PickerFrame.Position = UDim2.new(0.45, 0, 1, 5)
	PickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	PickerFrame.BackgroundTransparency = 0.2
	PickerFrame.BorderSizePixel = 0
	PickerFrame.Visible = false
	PickerFrame.ZIndex = 10
	PickerFrame.Parent = Frame
	ApplyGlassmorphism(PickerFrame, 0.5, 10)

	local ColorWheel = Instance.new("ImageButton")
	ColorWheel.Size = UDim2.new(1, -10, 0, 150)
	ColorWheel.Position = UDim2.new(0, 5, 0, 5)
	ColorWheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorWheel.Image = "rbxassetid://4155801252"
	ColorWheel.ScaleType = Enum.ScaleType.Fit
	ColorWheel.Parent = PickerFrame

	local HueSlider = Instance.new("Frame")
	HueSlider.Size = UDim2.new(1, -10, 0, 20)
	HueSlider.Position = UDim2.new(0, 5, 0, 160)
	HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HueSlider.BorderSizePixel = 0
	HueSlider.Parent = PickerFrame
	local HueGradient = Instance.new("UIGradient", HueSlider)
	HueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	})

	local HueKnob = Instance.new("Frame")
	HueKnob.Size = UDim2.new(0, 8, 1, 4)
	HueKnob.Position = UDim2.new(0, 0, 0.5, -2)
	HueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HueKnob.BorderSizePixel = 0
	HueKnob.Parent = HueSlider

	local CurrentColor = Config.Default or Color3.fromRGB(255, 255, 255)
	local Hue, Sat, Val = 0, 1, 1

	local function UpdateColor()
		ColorButton.BackgroundColor3 = CurrentColor
		if Config.Callback then Config.Callback(CurrentColor) end
	end

	ColorWheel.MouseButton1Down:Connect(function()
		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				Connection:Disconnect()
				return
			end
			local MousePos = UserInputService:GetMouseLocation()
			local Relative = MousePos - ColorWheel.AbsolutePosition
			local Percent = Vector2.new(math.clamp(Relative.X / ColorWheel.AbsoluteSize.X, 0, 1), math.clamp(Relative.Y / ColorWheel.AbsoluteSize.Y, 0, 1))
			Sat = Percent.X
			Val = 1 - Percent.Y
			CurrentColor = Color3.fromHSV(Hue, Sat, Val)
			UpdateColor()
		end)
	end)

	HueSlider.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			local Connection
			Connection = RunService.RenderStepped:Connect(function()
				if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					Connection:Disconnect()
					return
				end
				local MousePos = UserInputService:GetMouseLocation()
				local RelativeX = math.clamp((MousePos.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
				Hue = RelativeX
				HueKnob.Position = UDim2.new(RelativeX, -4, 0.5, -2)
				CurrentColor = Color3.fromHSV(Hue, Sat, Val)
				UpdateColor()
			end)
		end
	end)

	ColorButton.MouseButton1Click:Connect(function()
		PickerFrame.Visible = not PickerFrame.Visible
	end)

	UpdateColor()
	return { Frame = Frame, Picker = ColorButton, SetColor = function(c) CurrentColor = c; UpdateColor() end }
end

function SightLibrary:CreatePickerBox(Config)
	return self:CreateColorPicker(Config)
end

function SightLibrary:CreateTextbox(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.4, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local TextBox = Instance.new("TextBox")
	TextBox.Size = UDim2.new(0.55, 0, 1, 0)
	TextBox.Position = UDim2.new(0.45, 0, 0, 0)
	TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	TextBox.BackgroundTransparency = 0.5
	TextBox.BorderSizePixel = 0
	TextBox.Font = Enum.Font.Code
	TextBox.PlaceholderText = Config.Placeholder or ""
	TextBox.Text = Config.Default or ""
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.TextSize = 14
	TextBox.ClearTextOnFocus = Config.ClearTextOnFocus or false
	TextBox.Parent = Frame
	ApplyGlassmorphism(TextBox, 0.85, 8)

	TextBox.FocusLost:Connect(function(EnterPressed)
		if Config.Callback then Config.Callback(TextBox.Text, EnterPressed) end
	end)

	return { Frame = Frame, TextBox = TextBox }
end

function SightLibrary:CreateLabel(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 25)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Text
	Label.TextColor3 = Config.Color or Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Config.Alignment or Enum.TextXAlignment.Left
	Label.Parent = Frame

	return { Frame = Frame, Label = Label }
end

function SightLibrary:CreateGroup(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 60)
	Frame.BackgroundTransparency = 1

	local GroupFrame = Instance.new("Frame")
	GroupFrame.Size = UDim2.new(1, 0, 1, -20)
	GroupFrame.Position = UDim2.new(0, 0, 0, 20)
	GroupFrame.BackgroundTransparency = 1
	GroupFrame.Parent = Frame

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 20)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.Text = Config.Title
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Frame

	local Elements = {}
	local ListLayout = Instance.new("UIListLayout")
	ListLayout.FillDirection = Enum.FillDirection.Horizontal
	ListLayout.Padding = UDim.new(0, 5)
	ListLayout.Parent = GroupFrame

	local function AddElement(Element)
		Element.Frame.Parent = GroupFrame
		table.insert(Elements, Element)
	end

	return { Frame = Frame, Group = GroupFrame, AddElement = AddElement }
end

function SightLibrary:CreateKeybind(Config)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.4, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Config.Title
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local KeyButton = Instance.new("TextButton")
	KeyButton.Size = UDim2.new(0.55, 0, 1, 0)
	KeyButton.Position = UDim2.new(0.45, 0, 0, 0)
	KeyButton.BackgroundColor3 = self.AccentColor
	KeyButton.BackgroundTransparency = 0.8
	KeyButton.BorderSizePixel = 0
	KeyButton.Font = Enum.Font.Code
	KeyButton.Text = Config.Default or "None"
	KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyButton.TextSize = 13
	KeyButton.Parent = Frame
	ApplyGlassmorphism(KeyButton, 0.85, 8)

	local CurrentKey = Config.Default or Enum.KeyCode.Unknown
	local Binding = false

	KeyButton.MouseButton1Click:Connect(function()
		Binding = true
		KeyButton.Text = "..."
		local Connection
		Connection = UserInputService.InputBegan:Connect(function(Input, GPE)
			if not Binding then return end
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				CurrentKey = Input.KeyCode
				KeyButton.Text = Input.KeyCode.Name
				Binding = false
				Connection:Disconnect()
				if Config.Callback then Config.Callback(CurrentKey) end
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
				CurrentKey = Input.UserInputType
				KeyButton.Text = "MB1"
				Binding = false
				Connection:Disconnect()
				if Config.Callback then Config.Callback(CurrentKey) end
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
				CurrentKey = Input.UserInputType
				KeyButton.Text = "MB2"
				Binding = false
				Connection:Disconnect()
				if Config.Callback then Config.Callback(CurrentKey) end
			end
		end)
		task.delay(10, function()
			if Binding then
				Binding = false
				KeyButton.Text = CurrentKey == Enum.KeyCode.Unknown and "None" or CurrentKey.Name
				Connection:Disconnect()
			end
		end)
	end)

	return { Frame = Frame, Keybind = KeyButton, GetKey = function() return CurrentKey end }
end

function SightLibrary:CreateSettingsTab()
	local SettingsTab = self:CreateTab({ Title = "Settings" })
	local AppearanceSubtab = self:CreateSubTab(SettingsTab, { Title = "Appearance" })
	local ConfigSubtab = self:CreateSubTab(SettingsTab, { Title = "Config" })

	local ThemeDropdown = self:CreateDropdown({
		Title = "Theme",
		Options = {"Dark", "Light", "Amethyst"},
		Default = "Dark",
		Callback = function(Value)
			self.Theme = Value
		end
	})
	table.insert(AppearanceSubtab.Elements, ThemeDropdown)

	local AccentPicker = self:CreateColorPicker({
		Title = "Accent Color",
		Default = self.AccentColor,
		Callback = function(Color)
			self.AccentColor = Color
		end
	})
	table.insert(AppearanceSubtab.Elements, AccentPicker)

	local DraggableToggle = self:CreateToggle({
		Title = "Draggable UI",
		Default = self.Draggable,
		Callback = function(Value)
			self.Draggable = Value
		end
	})
	table.insert(AppearanceSubtab.Elements, DraggableToggle)

	local ScaleSlider = self:CreateSlider({
		Title = "UI Scale",
		Min = 0.7,
		Max = 1.5,
		Default = self.Scale,
		Callback = function(Value)
			self.UIScale.Scale = Value
		end
	})
	table.insert(AppearanceSubtab.Elements, ScaleSlider)

	local SaveButton = self:CreateButton({
		Title = "Save Config",
		Callback = function()
			local ConfigData = {
				Theme = self.Theme,
				AccentColor = {self.AccentColor.R, self.AccentColor.G, self.AccentColor.B},
				Draggable = self.Draggable,
				Scale = self.UIScale.Scale
			}
			local Success, Err = pcall(function()
				writefile("sight_config.json", HttpService:JSONEncode(ConfigData))
			end)
		end
	})
	table.insert(ConfigSubtab.Elements, SaveButton)

	local LoadButton = self:CreateButton({
		Title = "Load Config",
		Callback = function()
			local Success, Data = pcall(function()
				return readfile("sight_config.json")
			end)
			if Success and Data then
				local ConfigData = HttpService:JSONDecode(Data)
				self.Theme = ConfigData.Theme
				self.AccentColor = Color3.new(ConfigData.AccentColor[1], ConfigData.AccentColor[2], ConfigData.AccentColor[3])
				self.Draggable = ConfigData.Draggable
				self.UIScale.Scale = ConfigData.Scale
			end
		end
	})
	table.insert(ConfigSubtab.Elements, LoadButton)
end

function SightLibrary:CreateFloatingButton()
	local Button = Instance.new("ImageButton")
	Button.Size = UDim2.new(0, 50, 0, 50)
	Button.Position = UDim2.new(1, -70, 1, -70)
	Button.BackgroundColor3 = self.AccentColor
	Button.BackgroundTransparency = 0.2
	Button.Image = "rbxassetid://3926305904"
	Button.ImageColor3 = Color3.fromRGB(255, 255, 255)
	Button.ScaleType = Enum.ScaleType.Fit
	Button.Parent = self.ScreenGui
	ApplyGlassmorphism(Button, 0.3, 12)

	Button.MouseButton1Click:Connect(function()
		self.MainContainer.Visible = not self.MainContainer.Visible
	end)
end

return SightLibrary
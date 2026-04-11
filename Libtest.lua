local sight = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "sight"
gui.Parent = game:GetService("CoreGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function sightTween(o,p)
    TweenService:Create(o,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play()
end

local function sightGlass(obj)
    obj.BackgroundTransparency = 0.25
    obj.BackgroundColor3 = Color3.fromRGB(20,20,20)
    local stroke = Instance.new("UIStroke",obj)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    local corner = Instance.new("UICorner",obj)
    corner.CornerRadius = UDim.new(0,12)
end

local function sightShadow(obj)
    local shadow = Instance.new("ImageLabel",obj)
    shadow.Size = UDim2.new(1,20,1,20)
    shadow.Position = UDim2.new(0,-10,0,-10)
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.7
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = obj.ZIndex - 1
end

local function sightDrag(frame)
    local dragging,dragInput,dragStart,startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,startPos.Y.Scale,startPos.Y.Offset + delta.Y)
        end
    end)
end

function sight.CreateWindow(title)
    local main = Instance.new("Frame",gui)
    main.Size = UDim2.new(0,520,0,360)
    main.Position = UDim2.new(0.5,-260,0.5,-180)
    sightGlass(main)
    sightShadow(main)
    sightDrag(main)

    local top = Instance.new("TextLabel",main)
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundTransparency = 1
    top.Text = title or "sight"
    top.TextColor3 = Color3.new(1,1,1)
    top.Font = Enum.Font.GothamBold
    top.TextSize = 18

    local tabs = Instance.new("Frame",main)
    tabs.Size = UDim2.new(0,120,1,-40)
    tabs.Position = UDim2.new(0,0,0,40)
    tabs.BackgroundTransparency = 1

    local container = Instance.new("Frame",main)
    container.Size = UDim2.new(1,-120,1,-40)
    container.Position = UDim2.new(0,120,0,40)
    container.BackgroundTransparency = 1

    local window = {}
    window.Tabs = {}

    function window.CreateTab(name)
        local btn = Instance.new("TextButton",tabs)
        btn.Size = UDim2.new(1,0,0,40)
        btn.Text = name
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14

        local page = Instance.new("Frame",container)
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.BackgroundTransparency = 1

        btn.MouseButton1Click:Connect(function()
            for _,v in pairs(container:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            page.Visible = true
        end)

        local tab = {}

        function tab.CreateButton(txt,cb)
            local b = Instance.new("TextButton",page)
            b.Size = UDim2.new(1,-20,0,40)
            b.Position = UDim2.new(0,10,0,#page:GetChildren()*45)
            b.Text = txt
            sightGlass(b)

            b.MouseEnter:Connect(function()
                sightTween(b,{BackgroundTransparency = 0.15})
            end)

            b.MouseLeave:Connect(function()
                sightTween(b,{BackgroundTransparency = 0.25})
            end)

            b.MouseButton1Click:Connect(function()
                if cb then cb() end
            end)
        end

        function tab.CreateToggle(txt,default,cb)
            local state = default
            local t = Instance.new("TextButton",page)
            t.Size = UDim2.new(1,-20,0,40)
            t.Position = UDim2.new(0,10,0,#page:GetChildren()*45)
            t.Text = txt.." : "..tostring(state)
            sightGlass(t)

            t.MouseButton1Click:Connect(function()
                state = not state
                t.Text = txt.." : "..tostring(state)
                if cb then cb(state) end
            end)
        end

        function tab.CreateSlider(txt,min,max,cb)
            local val = min
            local s = Instance.new("TextButton",page)
            s.Size = UDim2.new(1,-20,0,40)
            s.Position = UDim2.new(0,10,0,#page:GetChildren()*45)
            s.Text = txt.." : "..val
            sightGlass(s)

            s.MouseButton1Click:Connect(function()
                val = val + 1
                if val > max then val = min end
                s.Text = txt.." : "..val
                if cb then cb(val) end
            end)
        end

        function tab.CreateTextbox(txt,cb)
            local box = Instance.new("TextBox",page)
            box.Size = UDim2.new(1,-20,0,40)
            box.Position = UDim2.new(0,10,0,#page:GetChildren()*45)
            box.PlaceholderText = txt
            sightGlass(box)

            box.FocusLost:Connect(function()
                if cb then cb(box.Text) end
            end)
        end

        return tab
    end

    return window
end

return sight

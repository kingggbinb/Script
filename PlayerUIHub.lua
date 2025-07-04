
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Library = {}
Library.__index = Library

function Library:CreateWindow(title)
    local Player = game.Players.LocalPlayer
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PlayerUI Hub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    -- Open/Close Button
    local ToggleButton = Instance.new("TextButton", ScreenGui)
    ToggleButton.Size = UDim2.new(0,120,0,35)
    ToggleButton.Position = UDim2.new(0,15,0,15)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 14
    ToggleButton.Text = "Open UI"
    Instance.new("UICorner", ToggleButton)

    -- Main UI Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0,550,0,370)
    Main.Position = UDim2.new(0.5,-275,0.5,-185)
    Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Main.BorderSizePixel = 0
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.Visible = false
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main)

    -- Draggable TopBar
    local TopBar = Instance.new("TextLabel", Main)
    TopBar.Text = title or "PlayerUI Hub"
    TopBar.Font = Enum.Font.GothamBold
    TopBar.TextSize = 18
    TopBar.TextColor3 = Color3.new(1,1,1)
    TopBar.Size = UDim2.new(1,0,0,40)
    TopBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    TopBar.BorderSizePixel = 0

    local dragging, dragStart, startPos = false, nil, nil
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart, startPos = i.Position, Main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tabs
    local TabsFrame = Instance.new("Frame", Main)
    TabsFrame.Size = UDim2.new(0,120,1,-40)
    TabsFrame.Position = UDim2.new(0,0,0,40)
    TabsFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", TabsFrame)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1,-130,1,-50)
    Content.Position = UDim2.new(0,130,0,45)
    Content.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UICorner", Content)

    -- Animate Open/Close
    local isOpen = false
    local function showUI()
        Main.Visible = true
        Main.BackgroundTransparency = 1
        TweenService:Create(Main, TweenInfo.new(0.25), {BackgroundTransparency=0}):Play()
    end
    local function hideUI()
        local t = TweenService:Create(Main, TweenInfo.new(0.25), {BackgroundTransparency=1})
        t:Play()
        t.Completed:Wait()
        Main.Visible = false
    end

    ToggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ToggleButton.Text = isOpen and "Close UI" or "Open UI"
        if isOpen then showUI() else hideUI() end
    end)

    -- Tab API
    local tabs = {}

    function Library:AddTab(name)
        local btn = Instance.new("TextButton", TabsFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamSemibold
        btn.Text = name
        btn.TextColor3 = Color3.new(1,1,1)

        local frame = Instance.new("ScrollingFrame", Content)
        frame.Name = name
        frame.Size = UDim2.new(1,0,1,0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 6
        frame.CanvasSize = UDim2.new(0,0,0,0)
        frame.Visible = false
        Instance.new("UIListLayout", frame).Padding = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            for _,c in pairs(Content:GetChildren()) do
                if c:IsA("ScrollingFrame") then c.Visible = false end
            end
            frame.Visible = true
        end)

        local tab = {}

        function tab:Button(txt, cb)
            local b = Instance.new("TextButton", frame)
            b.Size = UDim2.new(1,-10,0,30)
            b.Position = UDim2.new(0,5,0,0)
            b.Text = txt
            b.Font = Enum.Font.Gotham
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(55,55,55)
            b.BorderSizePixel = 0
            b.MouseButton1Click:Connect(cb)
        end

        function tab:Toggle(txt, cb)
            local cont = Instance.new("Frame", frame)
            cont.Size = UDim2.new(1,-10,0,30)
            cont.Position = UDim2.new(0,5,0,0)
            cont.BackgroundTransparency = 1

            local tbtn = Instance.new("TextButton", cont)
            tbtn.Size = UDim2.new(0,25,0,25)
            tbtn.Position = UDim2.new(0,0,0.5,-12)
            tbtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
            tbtn.BorderSizePixel = 0
            tbtn.Text = ""

            local lbl = Instance.new("TextLabel", cont)
            lbl.Size = UDim2.new(1,-35,1,0)
            lbl.Position = UDim2.new(0,35,0,0)
            lbl.Text = txt
            lbl.Font = Enum.Font.Gotham
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.BackgroundTransparency = 1

            local state = false
            tbtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(tbtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(0,180,0) or Color3.fromRGB(80,80,80)
                }):Play()
                cb(state)
            end)
        end

        function tab:TextBox(ph, cb)
            local box = Instance.new("TextBox", frame)
            box.Size = UDim2.new(1,-10,0,30)
            box.Position = UDim2.new(0,5,0,0)
            box.PlaceholderText = ph
            box.Font = Enum.Font.Gotham
            box.TextColor3 = Color3.new(1,1,1)
            box.BackgroundColor3 = Color3.fromRGB(55,55,55)
            box.BorderSizePixel = 0
            box.FocusLost:Connect(function()
                cb(box.Text)
            end)
        end

        function tab:Label(txt)
            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1,-10,0,25)
            lbl.Position = UDim2.new(0,5,0,0)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = txt
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.BackgroundTransparency = 1
        end

        table.insert(tabs, tab)
        if #tabs == 1 then frame.Visible = true end
        return tab
    end

    return Library
end

return Library
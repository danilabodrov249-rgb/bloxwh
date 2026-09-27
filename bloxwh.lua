local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Cam = workspace.CurrentCamera
local LP = Players.LocalPlayer
local isOpen = false

local gui = Instance.new("ScreenGui")
gui.Name = "LuaBloxWH"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local mf = Instance.new("Frame")
mf.Size = UDim2.new(0, 280, 0, 90)
mf.Position = UDim2.new(0.5, -140, 0.5, -45)
mf.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
mf.BorderSizePixel = 0
mf.Visible = false
mf.Parent = gui
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 8)
local st = Instance.new("UIStroke", mf)
st.Color = Color3.fromRGB(0, 180, 255)
st.Thickness = 1.5

local title = Instance.new("TextLabel", mf)
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "LUA BLOXSTRIKE // WH"
title.TextColor3 = Color3.fromRGB(240, 240, 250)
title.TextSize = 12

local state = false
local btn = Instance.new("TextButton", mf)
btn.Size = UDim2.new(1, -24, 0, 34)
btn.Position = UDim2.new(0, 12, 0, 42)
btn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
btn.Font = Enum.Font.GothamBold
btn.Text = "WH: ВЫКЛ"
btn.TextColor3 = Color3.fromRGB(200, 200, 220)
btn.TextSize = 12
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    state = not state
    btn.Text = state and "WH: ВКЛ" or "WH: ВЫКЛ"
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(35, 38, 50)
    btn.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(200, 200, 220)
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isOpen = not isOpen
        mf.Visible = isOpen
    end
end)

local drag, ds, sp = false, nil, nil
mf.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag, ds, sp = true, i.Position, mf.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - ds
        mf.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)

local cache = {}
local HAS_D = (typeof(Drawing) == "table")

local function make(p)
    if p == LP or not HAS_D then return end
    if cache[p] then return end
    local name = Drawing.new("Text")
    name.Center = true; name.Outline = true; name.Size = 13
    name.Color = Color3.fromRGB(255, 255, 255); name.Visible = false
    
    local dist = Drawing.new("Text")
    dist.Center = true; dist.Outline = true; dist.Size = 12
    dist.Color = Color3.fromRGB(200, 200, 200); dist.Visible = false
    
    cache[p] = {name = name, dist = dist}
end

for _, p in ipairs(Players:GetPlayers()) do make(p) end
Players.PlayerAdded:Connect(make)
Players.PlayerRemoving:Connect(function(p)
    local c = cache[p]
    if c then
        if c.name then c.name:Remove() end
        if c.dist then c.dist:Remove() end
    end
    cache[p] = nil
end)

RunService.RenderStepped:Connect(function()
    if not HAS_D then return end
    for p, c in pairs(cache) do
        if c.name then c.name.Visible = false end
        if c.dist then c.dist.Visible = false end

        if not state then continue end
        if not p.Character then continue end
        if p.Character:GetAttribute("Dead") == true then continue end
        local hp = p.Character:GetAttribute("Health")
        if hp and hp <= 0 then continue end
        if LP:GetAttribute("Team") == p:GetAttribute("Team") then continue end

        local head = p.Character:FindFirstChild("Head")
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not head or not root then continue end

        local sp, onScreen = Cam:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
        if not onScreen then continue end

        local distVal = math.round((root.Position - Cam.CFrame.Position).Magnitude)

        c.name.Position = Vector2.new(sp.X, sp.Y - 18)
        c.name.Text = p.DisplayName
        c.name.Visible = true

        c.dist.Position = Vector2.new(sp.X, sp.Y)
        c.dist.Text = "[" .. distVal .. "m]"
        c.dist.Visible = true
    end
end)

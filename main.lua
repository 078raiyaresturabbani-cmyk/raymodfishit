-- RAYMOD FISHIT V1 | FULL GUI + SAFETY + AUTO FARM CORE

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- ===== SAFETY MODULE =====

local Safety = {}

function Safety.HumanWait(min, max)
    local r = math.random()
    local t = min + (max - min) * r
    task.wait(t)
end

function Safety.SafeLoop(step, fn)
    task.spawn(function()
        while task.wait(step) do
            local ok, err = pcall(fn)
            if not ok then
                warn("RAYMOD SAFELOOP ERROR:", err)
                Safety.HumanWait(0.5, 1.5)
            end
        end
    end)
end

_G.RAY_Safety = Safety

-- ===== GUI SETUP =====

local old = plr.PlayerGui:FindFirstChild("RAYMOD_FISHIT_GUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "RAYMOD_FISHIT_GUI"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 640, 0, 360)
main.Position = UDim2.new(0.5, -320, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

do
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 190, 255)
    stroke.Thickness = 2
end

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 34)
top.BackgroundColor3 = Color3.fromRGB(12, 16, 40)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RAYMOD FISHIT V1"
title.TextColor3 = Color3.fromRGB(240, 246, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 26, 0, 22)
close.Position = UDim2.new(1, -32, 0.5, -11)
close.BackgroundColor3 = Color3.fromRGB(220, 65, 90)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = top
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 26, 0, 22)
mini.Position = UDim2.new(1, -64, 0.5, -11)
mini.BackgroundColor3 = Color3.fromRGB(90, 95, 140)
mini.Text = "-"
mini.TextColor3 = Color3.new(1,1,1)
mini.Font = Enum.Font.GothamBold
mini.TextSize = 18
mini.Parent = top
Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 6)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -34)
content.Position = UDim2.new(0, 0, 0, 34)
content.BackgroundTransparency = 1
content.Parent = main

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    mini.Text = minimized and "+" or "-"
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -16)
sidebar.Position = UDim2.new(0, 10, 0, 8)
sidebar.BackgroundColor3 = Color3.fromRGB(14, 18, 40)
sidebar.BorderSizePixel = 0
sidebar.Parent = content
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 4)
sideLayout.FillDirection = Enum.FillDirection.Vertical
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local sideHeader = Instance.new("TextLabel")
sideHeader.Size = UDim2.new(1, -16, 0, 26)
sideHeader.BackgroundTransparency = 1
sideHeader.Text = "RAYMOD MENU"
sideHeader.TextColor3 = Color3.fromRGB(180, 200, 255)
sideHeader.Font = Enum.Font.GothamBold
sideHeader.TextSize = 14
sideHeader.Parent = sidebar

local pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -180, 1, -16)
pageHolder.Position = UDim2.new(0, 170, 0, 8)
pageHolder.BackgroundColor3 = Color3.fromRGB(18, 20, 42)
pageHolder.BorderSizePixel = 0
pageHolder.Parent = content
Instance.new("UICorner", pageHolder).CornerRadius = UDim.new(0, 10)

local Pages = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, -14, 1, -14)
    Page.Position = UDim2.new(0, 7, 0, 7)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Visible = false
    Page.Parent = pageHolder

    local layout = Instance.new("UIListLayout", Page)
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    Pages[name] = Page
    return Page
end

local function SwitchPage(name)
    for _,p in pairs(Pages) do
        p.Visible = false
    end
    if Pages[name] then
        Pages[name].Visible = true
    end
end

local function CreateTabButton(text, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(22, 26, 56)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(210, 220, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        SwitchPage(pageName)
    end)
end

-- PAGES
local pageInfo      = CreatePage("Info")
local pageFishing   = CreatePage("Fishing")
local pageShop      = CreatePage("Shop")
local pageBackpack  = CreatePage("Backpack")
local pageTeleport  = CreatePage("Teleport")
local pageQuest     = CreatePage("Quest")
local pageBoat      = CreatePage("Boat")
local pageMisc      = CreatePage("Misc")

CreateTabButton("│ Info",      "Info")
CreateTabButton("│ Fishing",   "Fishing")
CreateTabButton("│ Shop",      "Shop")
CreateTabButton("│ Backpack",  "Backpack")
CreateTabButton("│ Teleport",  "Teleport")
CreateTabButton("│ Quest",     "Quest")
CreateTabButton("│ Boat",      "Boat")
CreateTabButton("│ Misc",      "Misc")

SwitchPage("Fishing")

-- COMPONENTS
local function AddSection(parent, titleText, subText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, subText and 56 or 40)
    frame.BackgroundColor3 = Color3.fromRGB(24, 28, 60)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.BackgroundColor3 = Color3.fromRGB(255, 75, 170)
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 22)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(235, 230, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    if subText then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -40, 0, 18)
        sub.Position = UDim2.new(0, 10, 0, 26)
        sub.BackgroundTransparency = 1
        sub.Text = subText
        sub.TextColor3 = Color3.fromRGB(180, 190, 230)
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 12
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent = frame
    end

    return frame
end

local function AddToggle(parent, label, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(18, 20, 44)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 225, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 16)
    btn.Position = UDim2.new(1, -42, 0.5, -8)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 80, 170) or Color3.fromRGB(70, 72, 110)
    btn.Text = ""
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
    knob.BorderSizePixel = 0
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    if callback then task.spawn(callback, state) end

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 80, 170) or Color3.fromRGB(70, 72, 110)
        knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if callback then task.spawn(callback, state) end
    end)

    return function() return state end
end

local function AddSlider(parent, label, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(18, 20, 44)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 225, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, -10, 1, 0)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.new(0, 10, 1, -10)
    bar.BackgroundColor3 = Color3.fromRGB(70, 72, 110)
    bar.BorderSizePixel = 0
    bar.Parent = row
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 80, 170)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local current = default or min
    local function apply(v)
        current = math.clamp(v, min, max)
        local alpha = (max == min) and 0 or (current - min) / (max - min)
        knob.Position = UDim2.new(alpha, -5, 0.5, -5)
        valueLabel.Text = string.format("%.2f s", current)
        if callback then task.spawn(callback, current) end
    end

    apply(current)

    local dragging = false

    local function updateFromInput(input)
        local relX = (input.Position.X - bar.AbsolutePosition.X)
        local alpha = math.clamp(relX / bar.AbsoluteSize.X, 0, 1)
        local v = min + (max - min) * alpha
        apply(v)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        updateFromInput(input)
    end)

    return function() return current end
end

-- ===== GLOBAL FLAGS =====
_G.RAY_Fish_Auto    = false
_G.RAY_AutoEquipRod = false
_G.RAY_AutoSell     = false
_G.RAY_TP_Event     = false
_G.RAY_InfJump      = false
_G.RAY_Fullbright   = false
_G.RAY_EnableWalk   = false
_G.RAY_WalkSpeed    = 16
_G.RAY_FreezePos    = false
_G.RAY_FreezeSet    = false
_G.RAY_FreezeCFrame = nil

_G.RAY_DelayCast   = 0.05
_G.RAY_DelayFinish = 0.10

-- ===== GUI LAYOUT =====

AddSection(pageFishing, "Auto Fishing Status", "Control auto fish & delay")
AddToggle(pageFishing, "Auto Fish", false, function(v) _G.RAY_Fish_Auto = v end)
AddToggle(pageFishing, "Auto Equip Rod", false, function(v) _G.RAY_AutoEquipRod = v end)
AddSlider(pageFishing, "Delay Cast", 0, 0.5, _G.RAY_DelayCast, function(v)
    _G.RAY_DelayCast = v
end)
AddSlider(pageFishing, "Delay Finish", 0, 0.5, _G.RAY_DelayFinish, function(v)
    _G.RAY_DelayFinish = v
end)

AddSection(pageBackpack, "Auto Sell Features", "Manage auto sell behaviour")
AddToggle(pageBackpack, "Auto Sell", false, function(v) _G.RAY_AutoSell = v end)

AddSection(pageTeleport, "Teleport Core", "Players / islands / events")
AddToggle(pageTeleport, "Teleport To Event", false, function(v) _G.RAY_TP_Event = v end)

AddSection(pageMisc, "Utility Player", "Walkspeed, jumps, visuals")
AddToggle(pageMisc, "Enable Walkspeed", false, function(v) _G.RAY_EnableWalk = v end)
AddToggle(pageMisc, "Infinite Jump", false, function(v) _G.RAY_InfJump = v end)
AddToggle(pageMisc, "Fullbright", false, function(v) _G.RAY_Fullbright = v end)
AddToggle(pageMisc, "Freeze Position", false, function(v) _G.RAY_FreezePos = v end)

-- ===== AUTO FARM CORE (ISI REMOTE SENDIRI) =====

local function DoCast()
    -- TODO: isi dengan RemoteEvent / Function cast dari Fish It
    -- contoh:
    -- ReplicatedStorage.Remotes.Cast:FireServer()
end

local function DoFinish()
    -- TODO: isi dengan RemoteEvent / Function complete dari Fish It
    -- contoh:
    -- ReplicatedStorage.Remotes.Complete:FireServer()
end

Safety.SafeLoop(0.2, function()
    if not _G.RAY_Fish_Auto then return end

    DoCast()
    Safety.HumanWait(_G.RAY_DelayCast, _G.RAY_DelayCast + 0.03)

    DoFinish()
    Safety.HumanWait(_G.RAY_DelayFinish, _G.RAY_DelayFinish + 0.05)
end)

-- ===== AUTO SELL (KERANGKA) =====

local sellCount = 0
Safety.SafeLoop(1.0, function()
    if not _G.RAY_AutoSell then
        sellCount = 0
        return
    end

    sellCount += 1
    if sellCount > 50 then
        _G.RAY_AutoSell = false
        warn("RAYMOD: AutoSell safety off")
        return
    end

    -- TODO: isi Remote jual semua backpack di sini
    Safety.HumanWait(2.0, 4.0)
end)

-- ===== WALK / FREEZE / MISC =====

Safety.SafeLoop(0.1, function()
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if _G.RAY_EnableWalk then
        local base = _G.RAY_WalkSpeed
        local jitter = math.random(-1, 1)
        hum.WalkSpeed = math.clamp(base + jitter, 8, 40)
    else
        hum.WalkSpeed = 16
    end
end)

Safety.SafeLoop(0.05, function()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if _G.RAY_FreezePos then
        if not _G.RAY_FreezeSet then
            _G.RAY_FreezeCFrame = hrp.CFrame
            _G.RAY_FreezeSet = true
        end
        hrp.Anchored = true
        hrp.CFrame = _G.RAY_FreezeCFrame
    else
        if _G.RAY_FreezeSet then
            hrp.Anchored = false
            _G.RAY_FreezeSet = false
        end
    end
end)

Safety.SafeLoop(0.05, function()
    if not _G.RAY_InfJump then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial == Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Safety.SafeLoop(1.0, function()
    if not _G.RAY_Fullbright then return end
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 1e5
end)

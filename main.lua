-- ===== RAYMOD 1 SCRIPT 1 DEVICE (NO KEY) =====
local Players             = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService         = game:GetService("HttpService")
local StarterGui          = game:GetService("StarterGui")
local CoreGui             = game:GetService("CoreGui")
local Lighting            = game:GetService("Lighting")


local DEVICE_FILE = "raymod_fishit_device.json"

-- ===== OFFLINE KEY SYSTEM (PER DEVICE) =====

local KEY_FILE = "raymod_fishit_key.json"

-- daftar 10 key offline
local RAYMOD_KEYS = {
    "RAYMOD-1",
    "RAYMOD-2",
    "RAYMOD-3",
    "RAYMOD-4",
    "RAYMOD-5",
    "RAYMOD-6",
    "RAYMOD-7",
    "RAYMOD-8",
    "RAYMOD-9",
    "RAYMOD-10",
}

local function loadSavedKey()
    if not (isfile and readfile and isfile(KEY_FILE)) then return nil end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(KEY_FILE))
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

local function saveKeyOk()
    if not writefile then return end
    local data = {
        ok   = true,
        hwid = getHWID(),
    }
    writefile(KEY_FILE, HttpService:JSONEncode(data))
end

local function isValidKey(str)
    for _, k in ipairs(RAYMOD_KEYS) do
        if str == k then
            return true
        end
    end
    return false
end

local function CheckKey()
    local saved = loadSavedKey()
    local hwid  = getHWID()

    -- sudah pernah isi key yang valid di device ini
    if saved and saved.ok and saved.hwid == hwid then
        return true
    end

    -- GUI input key sederhana
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "RAYMOD_KEY_GUI"
    keyGui.ResetOnSpawn = false
    keyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 130)
    frame.Position = UDim2.new(0.5, -140, 0.5, -65)
    frame.BackgroundColor3 = Color3.fromRGB(10, 12, 25)
    frame.BorderSizePixel = 0
    frame.Parent = keyGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 24)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "RAYMOD FISHIT V2"
    title.TextColor3 = Color3.fromRGB(235, 240, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 18)
    info.Position = UDim2.new(0, 10, 0, 32)
    info.BackgroundTransparency = 1
    info.Text = "Masukkan key untuk unlock script"
    info.TextColor3 = Color3.fromRGB(190, 195, 230)
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextWrapped = true
    info.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 28)
    box.Position = UDim2.new(0, 10, 0, 58)
    box.BackgroundColor3 = Color3.fromRGB(18, 22, 50)
    box.TextColor3 = Color3.fromRGB(230, 230, 255)
    box.PlaceholderText = "RAYMOD-1 ..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 26)
    btn.Position = UDim2.new(0, 10, 0, 94)
    btn.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = "CONFIRM KEY"
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local result = false

    btn.MouseButton1Click:Connect(function()
        local input = (box.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if isValidKey(input) then
            saveKeyOk()
            Notify("Key valid. Script unlocked untuk device ini.")
            result = true
            keyGui:Destroy()
        else
            Notify("Key salah. Coba lagi.")
        end
    end)

    -- tunggu sampai key benar atau GUI ditutup paksa
    while keyGui.Parent and not result do
        task.wait(0.1)
    end

    return result
end



local function getHWID()
    local hwid
    pcall(function()
        hwid = RbxAnalyticsService:GetClientId()
    end)
    return hwid or "UNKNOWN_HWID"
end


local function loadDevice()
    if not (isfile and readfile and isfile(DEVICE_FILE)) then return nil end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(DEVICE_FILE))
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end


local function saveDevice(tbl)
    if not writefile then return end
    local ok, js = pcall(function()
        return HttpService:JSONEncode(tbl)
    end)
    if ok then
        writefile(DEVICE_FILE, js)
    end
end


local function deleteDevice()
    if delfile and isfile and isfile(DEVICE_FILE) then
        pcall(function() delfile(DEVICE_FILE) end)
    end
end


local function checkOneDevice()
    local uid  = Players.LocalPlayer.UserId
    local hwid = getHWID()
    local saved = loadDevice()


    if saved then
        if saved.UserId == uid and saved.HWID == hwid then
            return true
        else
            return false
        end
    end


    saveDevice({
        UserId = uid,
        HWID   = hwid,
    })


    return true
end


if not checkOneDevice() then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "RAYMOD FISHIT V2",
            Text = "Script ini sudah ke-bind ke device lain.",
            Duration = 5
        })
    end)
    return
end


-- ===== LANJUTAN SCRIPT ASLI =====


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")


-- ===== SAFETY =====


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
local function Notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "RAYMOD FISHIT V2",
            Text = msg,
            Duration = 3
        })
    end)
end
_G.RAY_Safety = Safety


-- ===== ANTI AFK =====


Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- wajib lolos key offline dulu
if not CheckKey() then
    return
end



-- ===== GUI BASE (SMALL + TRANSPARENT + BLUR) =====


local oldGui = Players.LocalPlayer.PlayerGui:FindFirstChild("RAYMOD_FISHIT_GUI")
if oldGui then oldGui:Destroy() end


local gui = Instance.new("ScreenGui")
gui.Name = "RAYMOD_FISHIT_GUI"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")


-- PREMIUM BLUR
local blur = Instance.new("BlurEffect")
blur.Name = "RAYMOD_Blur"
blur.Enabled = false
blur.Size = 0
blur.Parent = Lighting


local function SetBlur(enabled)
    blur.Enabled = enabled
    blur.Size = enabled and 18 or 0
end


local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 260)
main.Position = UDim2.new(0.5, -210, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
do
    local corner = Instance.new("UICorner", main); corner.CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(120, 200, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.1
end


local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 34)
top.BackgroundColor3 = Color3.fromRGB(12, 16, 40)
top.BackgroundTransparency = 0.15
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)


local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RAYMOD FISHIT V2"
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


local miniText = Instance.new("TextButton")
miniText.Name = "RAYMOD_MinimizeButton"
miniText.Size = UDim2.new(0, 140, 0, 28)
miniText.Position = UDim2.new(0, 10, 0, 10)
miniText.BackgroundColor3 = Color3.fromRGB(24, 28, 60)
miniText.BackgroundTransparency = 0.2
miniText.Text = "RAYMOD FISHIT V2"
miniText.TextColor3 = Color3.fromRGB(230, 230, 255)
miniText.Font = Enum.Font.GothamBold
miniText.TextSize = 14
miniText.Visible = false
miniText.ZIndex = 999
miniText.Parent = gui
Instance.new("UICorner", miniText).CornerRadius = UDim.new(0, 8)


local minimized = false
SetBlur(true)


mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Visible = not minimized
    miniText.Visible = minimized
    SetBlur(not minimized)
end)


miniText.MouseButton1Click:Connect(function()
    minimized = false
    main.Visible = true
    miniText.Visible = false
    SetBlur(true)
end)


close.MouseButton1Click:Connect(function()
    SetBlur(false)
    gui:Destroy()
end)


local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -32)   -- sidebar sedikit lebih pendek
sidebar.Position = UDim2.new(0, 10, 0, 16)
sidebar.BackgroundColor3 = Color3.fromRGB(14, 18, 40)
sidebar.BackgroundTransparency = 0.25
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
pageHolder.Size = UDim2.new(1, -140, 1, -8)   -- tinggi +8 px
pageHolder.Position = UDim2.new(0, 140, 0, 4)
pageHolder.BackgroundColor3 = Color3.fromRGB(18, 20, 42)
pageHolder.BackgroundTransparency = 0.3
pageHolder.BorderSizePixel = 0
pageHolder.Parent = content
Instance.new("UICorner", pageHolder).CornerRadius = UDim.new(0, 10)


local Pages = {}
local PageLayouts = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, -14, 1, -14)
    Page.Position = UDim2.new(0, 7, 0, 7)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 6
    Page.AutomaticCanvasSize = Enum.AutomaticSize.None
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Visible = false
    Page.Parent = pageHolder

    local layout = Instance.new("UIListLayout", Page)
    layout.Padding = UDim.new(0, 0)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- SIMPAN
    Pages[name] = Page
    PageLayouts[name] = layout

    -- AUTO CANVAS UNTUK PAGE INI
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local h = layout.AbsoluteContentSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, h + 10)
    end)

    return Page
end

local function SwitchPage(name)
    for _,p in pairs(Pages) do p.Visible = false end
    if Pages[name] then Pages[name].Visible = true end
end
local function CreateTabButton(text, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(22, 26, 56)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(210, 220, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() SwitchPage(pageName) end)
end


local pageFishing   = CreatePage("Fishing")
local pageBackpack  = CreatePage("Backpack")
local pageTeleport  = CreatePage("Teleport")
local pageQuest     = CreatePage("Quest")
local pageBoat      = CreatePage("Boat")
local pageMisc      = CreatePage("Misc")




CreateTabButton(" Fishing",   "Fishing")
CreateTabButton(" Backpack",  "Backpack")
CreateTabButton(" Teleport",  "Teleport")
CreateTabButton(" Quest",     "Quest")
CreateTabButton(" Boat",      "Boat")
CreateTabButton(" Misc",      "Misc")


SwitchPage("Fishing")


-- ===== CONFIG AUTO SAVE (DELAY) =====


local CFG_PATH = "raymod_fishit_config.json"


_G.RAY_DelayCast      = 0.9
_G.RAY_DelayFinish    = 0.2
_G.RAY_DelayCast_V2   = 0.9
_G.RAY_DelayFinish_V2 = 0.2
_G.RAY_DelayCast_V3   = 0.4
_G.RAY_DelayFinish_V3 = 0.08
_G.RAY_SellDelay      = 30


local function LoadConfig()
    if isfile and readfile and isfile(CFG_PATH) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CFG_PATH))
        end)
        if ok and type(data) == "table" then
            _G.RAY_DelayCast      = data.DelayCast      or _G.RAY_DelayCast
            _G.RAY_DelayFinish    = data.DelayFinish    or _G.RAY_DelayFinish
            _G.RAY_DelayCast_V2   = data.DelayCast_V2   or _G.RAY_DelayCast_V2
            _G.RAY_DelayFinish_V2 = data.DelayFinish_V2 or _G.RAY_DelayFinish_V2
            _G.RAY_DelayCast_V3   = data.DelayCast_V3   or _G.RAY_DelayCast_V3
            _G.RAY_DelayFinish_V3 = data.DelayFinish_V3 or _G.RAY_DelayFinish_V3
            _G.RAY_SellDelay      = data.SellDelay      or _G.RAY_SellDelay
        end
    end
end


local function SaveConfig()
    if writefile then
        local data = {
            DelayCast      = _G.RAY_DelayCast,
            DelayFinish    = _G.RAY_DelayFinish,
            DelayCast_V2   = _G.RAY_DelayCast_V2,
            DelayFinish_V2 = _G.RAY_DelayFinish_V2,
            DelayCast_V3   = _G.RAY_DelayCast_V3,
            DelayFinish_V3 = _G.RAY_DelayFinish_V3,
            SellDelay      = _G.RAY_SellDelay,
        }
        writefile(CFG_PATH, HttpService:JSONEncode(data))
    end
end


LoadConfig()


-- ===== GUI HELPERS =====


local function AddSection(parent, titleText, subText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, subText and 56 or 40)
    frame.BackgroundColor3 = Color3.fromRGB(24, 28, 60)
    frame.BackgroundTransparency = 0.2
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
    row.BackgroundTransparency = 0.2
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
end


local function AddDelayBox(parent, label, defaultValue, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(18, 20, 44)
    row.BackgroundTransparency = 0.2
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


    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.4, -14, 0, 24)
    box.Position = UDim2.new(0.6, 4, 0.5, -12)
    box.BackgroundColor3 = Color3.fromRGB(12, 16, 40)
    box.BackgroundTransparency = 0.1
    box.TextColor3 = Color3.fromRGB(230, 230, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)


    box.Text = tostring(defaultValue)
    box.FocusLost:Connect(function(enter)
        if not enter then return end
        local num = tonumber(box.Text)
        if not num or num < 0 then
            box.Text = tostring(defaultValue)
            return
        end
        if onChange then onChange(num) end
    end)
end


-- ===== GLOBAL FLAGS =====


_G.RAY_Fish_Auto      = false
_G.RAY_Fish_AutoV2    = false
_G.RAY_Fish_AutoV3    = false
_G.RAY_AutoCatch      = false
_G.RAY_AutoSell       = false


_G.RAY_TP_Location    = "Spawn"


_G.RAY_InfJump        = false
_G.RAY_EnableWalk     = false
_G.RAY_WalkSpeed      = 16
_G.RAY_FreezePos      = false
_G.RAY_FreezeSet      = false
_G.RAY_FreezeCFrame   = nil


_G.RAY_BoatSpeedEnabled = false
_G.RAY_BoatSpeedValue   = 120


_G.RAY_HideName         = false
_G.RAY_HideFishNotif = false






-- CFrame Sisyphus Room
local GHOSFIN_CF = CFrame.new(
    -3708.77563, -135.073914, -1012.4093,
    -0.944233716, -5.7476135e-09, 0.329275966,
     4.86078999e-09, 1, 3.13941371e-08,
    -0.329275966, 3.12439461e-08, -0.944233716
)


-- ===== NETWORK EVENTS =====


local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")


local Events = {
    fishing = Net:WaitForChild("RE/FishingCompleted"),
    sell    = Net:WaitForChild("RF/SellAllItems"),
    charge  = Net:WaitForChild("RF/ChargeFishingRod"),
    minigame= Net:WaitForChild("RF/RequestFishingMinigameStarted"),
    cancel  = Net:WaitForChild("RF/CancelFishingInputs"),
    equip   = Net:WaitForChild("RE/EquipToolFromHotbar"),
    unequip = Net:WaitForChild("RE/UnequipToolFromHotbar"),
}


-- ===== TELEPORT LOCATIONS =====


local LOCATIONS = {
    ["Spawn"]            = CFrame.new(45.2788086, 252.562927, 2987.10913),
    ["Sisyphus Statue"]  = CFrame.new(-3728.21606, -135.074417, -1012.12744),
    ["Coral Reefs"]      = CFrame.new(-3114.78198, 1.32066584, 2237.52295),
    ["Esoteric Depths"]  = CFrame.new(3248.37109, -1301.53027, 1403.82727),
    ["Crater Island"]    = CFrame.new(1016.49072, 20.0919304, 5069.27295),
    ["Lost Isle"]        = CFrame.new(-3618.15698, 240.836655, -1317.45801),
    ["Weather Machine"]  = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
    ["Tropical Grove"]   = CFrame.new(-2095.34106, 197.199997, 3718.08008),
    ["Mount Hallow"]     = CFrame.new(2136.62305, 78.9163895, 3272.50439),
    ["Treasure Room"]    = CFrame.new(-3606.34985, -266.57373, -1580.97339),
    ["Kohana"]           = CFrame.new(-663.904236, 3.04580712, 718.796875),
    ["Underground Cellar"]=CFrame.new(2109.52148, -94.1875076, -708.609131),
    ["Ancient Jungle"]   = CFrame.new(1831.71362, 6.62499952, -299.279175),
    ["Sacred Temple"]    = CFrame.new(1466.92151, -21.8750591, -622.835693),
}


local function TeleportTo(name)
    local cf = LOCATIONS[name]
    if not cf then
        Notify("TP: lokasi tidak dikenal")
        return
    end
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = cf
end








-- ===== GUI: FISHING TAB =====


AddSection(pageFishing, "Legit Auto Fishing (V1)", "Pola normal, aman, delay diatur")
AddToggle(pageFishing, "Auto Fish (Legit)", false, function(v) _G.RAY_Fish_Auto = v end)


AddDelayBox(pageFishing, "Fish Delay V1 (s)", _G.RAY_DelayCast, function(v)
    _G.RAY_DelayCast = v; SaveConfig()
end)
AddDelayBox(pageFishing, "Catch Delay V1 (s)", _G.RAY_DelayFinish, function(v)
    _G.RAY_DelayFinish = v; SaveConfig()
end)


AddSection(pageFishing, "Blatant Auto Fishing (V2)", "2x cast paralel + spam reel")
AddToggle(pageFishing, "Auto Fish (Blatant V2)", false, function(v) _G.RAY_Fish_AutoV2 = v end)


AddDelayBox(pageFishing, "Fish Delay V2 (s)", _G.RAY_DelayCast_V2, function(v)
    _G.RAY_DelayCast_V2 = v; SaveConfig()
end)
AddDelayBox(pageFishing, "Catch Delay V2 (s)", _G.RAY_DelayFinish_V2, function(v)
    _G.RAY_DelayFinish_V2 = v; SaveConfig()
end)


AddSection(pageFishing, "Blatant Auto Fishing (V3 x8)", "4x cast + 8x reel, sangat risk")
AddToggle(pageFishing, "Auto Fish (Blatant V3 x8)", false, function(v) _G.RAY_Fish_AutoV3 = v end)


AddDelayBox(pageFishing, "Fish Delay V3 (s)", _G.RAY_DelayCast_V3, function(v)
    _G.RAY_DelayCast_V3 = v; SaveConfig()
end)
AddDelayBox(pageFishing, "Catch Delay V3 (s)", _G.RAY_DelayFinish_V3, function(v)
    _G.RAY_DelayFinish_V3 = v; SaveConfig()
end)


AddSection(pageFishing, "Extra Fishing", "Auto catch tambahan")
AddToggle(pageFishing, "Auto Catch (Spam Reel)", false, function(v) _G.RAY_AutoCatch = v end)


-- ===== GUI: BACKPACK / AUTO SELL =====


AddSection(pageBackpack, "Auto Sell", "Sell semua ikan")
AddToggle(pageBackpack, "Auto Sell", false, function(v) _G.RAY_AutoSell = v end)


AddDelayBox(pageBackpack, "Sell Delay (s)", _G.RAY_SellDelay, function(v)
    _G.RAY_SellDelay = v; SaveConfig()
end)

-- ===== GUI: TELEPORT =====

-- ===== GUI: TELEPORT =====


AddSection(pageTeleport, "Teleport Lokasi", "Klik tombol untuk TP")
for name, _ in pairs(LOCATIONS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 60)
    btn.BackgroundTransparency = 0.2
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(230, 230, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = pageTeleport
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() TeleportTo(name) end)
end








-- ===== GUI: QUEST (CLEAN CARD STYLE) =====

-- helper bikin CARD quest
local function MakeQuestCard(parent, titleText, subText)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 82) -- tinggi card, muat 2 row
    card.BackgroundColor3 = Color3.fromRGB(18, 20, 44)
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout", card)
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- judul + subtext di atas card
    AddSection(card, titleText, subText)

    return card
end

-- helper baris tombol (dalam satu card)
local function MakeQuestButtonsRow(card)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 26)
    row.BackgroundTransparency = 1
    row.Parent = card

    local layout = Instance.new("UIListLayout", row)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)

    return row
end

local function MakeQuestButtonIn(row, text, cf)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -8, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(24, 28, 60)
    b.BackgroundTransparency = 0.2
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Parent = row
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
        local char = Players.LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cf end
    end)
end

----------------------------------------------------------------
-- CARD 1: SISYPHUS STATUE QUEST
----------------------------------------------------------------

local cardG = MakeQuestCard(
    pageQuest,
    "Sisyphus Statue Quest",
    "Deep Sea Panel helper + teleport"
)

local rowG = MakeQuestButtonsRow(cardG)
MakeQuestButtonIn(rowG, "Treasure Room", LOCATIONS["Treasure Room"])
MakeQuestButtonIn(rowG, "Sisyphus Statue", LOCATIONS["Sisyphus Statue"])

----------------------------------------------------------------
-- SPACER ANTAR CARD (kecil, biar elemen naik)
----------------------------------------------------------------

local spacerQ = Instance.new("Frame")
spacerQ.Size = UDim2.new(1, -4, 0, 2)
spacerQ.BackgroundTransparency = 1
spacerQ.Parent = pageQuest

----------------------------------------------------------------
-- CARD 2: ELEMENT QUEST
----------------------------------------------------------------

local cardE = MakeQuestCard(
    pageQuest,
    "Element Quest",
    "Teleport ke spot elemen utama"
)

-- baris pertama: 2 tombol kiri–kanan
local rowE1 = MakeQuestButtonsRow(cardE)
MakeQuestButtonIn(rowE1, "Hutan Kuno", CFrame.new(1491.9374, 2.755493, -337.64642))
MakeQuestButtonIn(rowE1, "Sacred Temple", CFrame.new(1454.14417, -22.125002, -621.98749))

-- baris kedua: 1 tombol di tengah
local rowE2 = MakeQuestButtonsRow(cardE)
local layout2 = rowE2:FindFirstChildOfClass("UIListLayout")
layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center

local b3 = Instance.new("TextButton")
b3.Size = UDim2.new(0.5, -8, 0, 28)
b3.BackgroundColor3 = Color3.fromRGB(24, 28, 60)
b3.BackgroundTransparency = 0.2
b3.Text = "Underground Cellar"
b3.TextColor3 = Color3.fromRGB(230, 230, 255)
b3.Font = Enum.Font.Gotham
b3.TextSize = 13
b3.Parent = rowE2
Instance.new("UICorner", b3).CornerRadius = UDim.new(0, 8)

b3.MouseButton1Click:Connect(function()
    local char = Players.LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(2136, -91.448585, -701) end
end)



-- ===== GUI: BOAT =====


AddSection(pageBoat, "Boat Speed", "Boost kecepatan boat lokal")
AddToggle(pageBoat, "Enable Boat Speed", false, function(v)
    _G.RAY_BoatSpeedEnabled = v
end)
AddDelayBox(pageBoat, "Boat Speed (stud/s)", _G.RAY_BoatSpeedValue, function(v)
    _G.RAY_BoatSpeedValue = v
end)


AddSection(pageMisc, "Movement / Visuals", "Walkspeed, jump, freeze, hide name")


AddToggle(pageMisc, "Enable Walkspeed", false, function(v)
    _G.RAY_EnableWalk = v
end)


AddDelayBox(pageMisc, "Walkspeed Value", _G.RAY_WalkSpeed, function(v)
    _G.RAY_WalkSpeed = v
end)


AddToggle(pageMisc, "Infinite Jump", false, function(v)
    _G.RAY_InfJump = v
end)


AddToggle(pageMisc, "Freeze Position", false, function(v)
    _G.RAY_FreezePos = v
end)


AddToggle(pageMisc, "Hide Player Names", false, function(v)
    _G.RAY_HideName = v
end)
AddToggle(pageMisc, "Hide Fish Image & Rarity", false, function(v)
    _G.RAY_HideFishNotif = v
end)








-- Tombol RESET HWID (1 script 1 device)
local resetHwidBtn = Instance.new("TextButton")
resetHwidBtn.Size = UDim2.new(1, -4, 0, 28)
resetHwidBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 90)
resetHwidBtn.Text = "RESET HWID (UNBIND DEVICE)"
resetHwidBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
resetHwidBtn.Font = Enum.Font.GothamBold
resetHwidBtn.TextSize = 13
resetHwidBtn.Parent = pageMisc
Instance.new("UICorner", resetHwidBtn).CornerRadius = UDim.new(0, 8)


resetHwidBtn.MouseButton1Click:Connect(function()
    deleteDevice()
    Notify("HWID/dev binding dihapus. Rejoin & jalankan ulang script untuk bind ke device baru.")
end)


-- ===== ENGINE AUTO FISH =====


local isFishing = false


local function castRod_V1()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
    end)
end


local function reelIn()
    pcall(function()
        Events.fishing:FireServer()
    end)
end


local function NormalCycle_V1()
    if isFishing then return end
    isFishing = true
    castRod_V1()
    task.wait(_G.RAY_DelayCast)
    reelIn()
    task.wait(_G.RAY_DelayFinish)
    isFishing = false
end


local function BlatantCycle_V2()
    if isFishing then return end
    isFishing = true
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.01)
        for _ = 1,2 do
            task.spawn(function()
                Events.charge:InvokeServer(1755848498.4834)
                task.wait(0.01)
                Events.minigame:InvokeServer(1.2854545116425, 1)
            end)
            task.wait(0.03)
        end
    end)
    task.wait(_G.RAY_DelayCast_V2)
    for _ = 1,5 do
        reelIn()
        task.wait(0.01)
    end
    task.wait(_G.RAY_DelayFinish_V2 * 0.5)
    isFishing = false
end


local function BlatantCycle_V3()
    if isFishing then return end
    isFishing = true
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.005)
        for _ = 1,4 do
            task.spawn(function()
                Events.charge:InvokeServer(1755848498.4834)
                task.wait(0.005)
                Events.minigame:InvokeServer(1.2854545116425, 1)
            end)
            task.wait(0.01)
        end
    end)
    task.wait(_G.RAY_DelayCast_V3)
    for _ = 1,8 do
        reelIn()
        task.wait(0.005)
    end
    task.wait(_G.RAY_DelayFinish_V3)
    isFishing = false
end


Safety.SafeLoop(0.05, function()
    if _G.RAY_Fish_AutoV3 then
        BlatantCycle_V3()
    elseif _G.RAY_Fish_AutoV2 then
        BlatantCycle_V2()
    elseif _G.RAY_Fish_Auto then
        NormalCycle_V1()
    end
end)


-- AUTO CATCH


Safety.SafeLoop(0.05, function()
    if not _G.RAY_AutoCatch then return end
    if isFishing then return end
    reelIn()
    task.wait(_G.RAY_DelayFinish)
end)


-- ===== AUTO SELL =====

local function ToggleBackpack()
    local pg  = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local bpGui = pg:FindFirstChild("Backpack")  -- ini yang nampilin angka 36/3000
    if bpGui and bpGui:IsA("ScreenGui") then
        local old = bpGui.Enabled
        bpGui.Enabled = true     -- buka sebentar
        task.wait(0.1)
        bpGui.Enabled = old      -- balikin ke kondisi awal
    end
end

local sellCount = 0
Safety.SafeLoop(1.0, function()
    if not _G.RAY_AutoSell then
        sellCount = 0
        return
    end

    sellCount += 1
    if sellCount > 999 then
        _G.RAY_AutoSell = false
        Notify("AutoSell dimatikan (limit).")
        return
    end

    if Events.sell then
        pcall(function()
            Events.sell:InvokeServer()
            ToggleBackpack()     -- paksa UI backpack refresh tiap selesai sell
        end)
    end

    Safety.HumanWait(_G.RAY_SellDelay - 1, _G.RAY_SellDelay + 1)
end)




-- ===== WALK / FREEZE / VISUAL =====


Safety.SafeLoop(0.1, function()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if _G.RAY_EnableWalk then
        local base = _G.RAY_WalkSpeed
        hum.WalkSpeed = math.clamp(base + math.random(-1,1), 8, 40)
    else
        hum.WalkSpeed = 16
    end
end)


Safety.SafeLoop(0.05, function()
    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial == Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)



-- ===== BOAT SPEED ENGINE =====


local function GetBoatSeat()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seatPart = hum.SeatPart
    if seatPart and seatPart:IsA("VehicleSeat") then
        local model = seatPart:FindFirstAncestorOfClass("Model")
        if model and model.PrimaryPart then
            return seatPart, model
        end
    end
    return nil
end


RunService.Heartbeat:Connect(function()
    if not _G.RAY_BoatSpeedEnabled then return end
    local seat, boat = GetBoatSeat()
    if not (seat and boat and boat.PrimaryPart) then return end
    local speed = _G.RAY_BoatSpeedValue or 120
    if speed <= 0 then return end
    local dir = seat.CFrame.LookVector
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.01 then return end
    boat.PrimaryPart.AssemblyLinearVelocity = flat.Unit * speed
end)


-- ===== HIDE NAME ENGINE =====


local function SetCharNameVisible(char, visible)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.DisplayDistanceType = visible
        and Enum.HumanoidDisplayDistanceType.Viewer
        or  Enum.HumanoidDisplayDistanceType.None
end


Safety.SafeLoop(1.0, function()
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            SetCharNameVisible(char, not _G.RAY_HideName)
        end
    end
end)

-- ===== HIDE FISH NOTIFICATION (HANYA NOTIF PERTAMA) =====

local function RAY_SetupHideFishNotif()
    local plr = Players.LocalPlayer
    local pg = plr:WaitForChild("PlayerGui")

    local TARGET_GUIS = {
        ["Small Notification"] = true,
        ["Text Notifications"] = true,
    }

    -- hitung berapa kali GUI notif ini sudah dipakai
    local notifCount = {}

    local function hideObj(obj)
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            obj.ImageTransparency = 1
            obj.Visible = false
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.TextTransparency = 1
            obj.Visible = false
        end
    end

    local function processGui(gui)
        if not _G.RAY_HideFishNotif then return end
        if not TARGET_GUIS[gui.Name] then return end

        -- increment counter
        notifCount[gui] = (notifCount[gui] or 0) + 1

        -- HANYA hide untuk notif pertama
        if notifCount[gui] ~= 1 then
            return
        end

        for _, obj in ipairs(gui:GetDescendants()) do
            hideObj(obj)
        end
    end

    -- notif yang GUI-nya sudah ada
    for _, gui in ipairs(pg:GetChildren()) do
        if TARGET_GUIS[gui.Name] then
            processGui(gui)
            gui.DescendantAdded:Connect(function(obj)
                if not _G.RAY_HideFishNotif then return end
                if notifCount[gui] == 1 then
                    hideObj(obj)
                end
            end)
        end
    end

    -- notif baru (GUI muncul belakangan)
    pg.ChildAdded:Connect(function(child)
        if not _G.RAY_HideFishNotif then return end
        if TARGET_GUIS[child.Name] then
            processGui(child)
            child.DescendantAdded:Connect(function(obj)
                if not _G.RAY_HideFishNotif then return end
                if notifCount[child] == 1 then
                    hideObj(obj)
                end
            end)
        end
    end)
end

task.delay(5, RAY_SetupHideFishNotif)







Notify("RAYMOD FISHIT V2 loaded. ")

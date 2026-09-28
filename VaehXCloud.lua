--[[
    Vaeh X Cloud — Mobile Only | Delta Fixed
    WindUI + cool backgrounds
    Close → floating reopen button + FPS
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not UserInputService.TouchEnabled then
    warn("[Vaeh X Cloud] Designed for mobile.")
end

-- ── Safe helpers (Delta) ──────────────────────────────────────
local function SafeSplit(str, sep)
    local t = {}
    if not str or str == "" then return t end
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, part)
    end
    return t
end

local function SafeRead(path)
    local ok, data = pcall(function() return readfile(path) end)
    if ok and data then return data end
    return nil
end

local function SafeWrite(path, data)
    pcall(function() writefile(path, data) end)
end

local function Now()
    local ok, t = pcall(function() return os.time() end)
    if ok and t then return t end
    return math.floor(tick())
end

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local USED_VIP_FILE = "vaehxcloud_used_vips.txt"
local FREE_KEY_FILE = "vaehxcloud_freekey.txt"
local REMEMBER_FILE = "vaehxcloud_remember.txt"
local FREE_EXPIRE_H = 12

local VIP_KEYS = {
    ["VIPKEY_WGR_XZJ_7FY"] = true,
    ["VIPKEY_SJC_LMH_K6Q"] = true,
    ["VIPKEY_96H_FRP_TEH"] = true,
    ["VIPKEY_USC_6J2_2HG"] = true,
    ["VIPKEY_YQU_WMT_KUL"] = true,
    ["VIPKEY_AYV_AZH_LUZ"] = true,
    ["VIPKEY_JTR_ZAX_6BC"] = true,
    ["VIPKEY_HSQ_X29_NAB"] = true,
    ["VIPKEY_PZF_FAN_G62"] = true,
    ["VIPKEY_TFN_FTZ_2WJ"] = true,
    ["VIPKEY_4H6_629_M3N"] = true,
    ["VIPKEY_SN2_6AY_Q5Y"] = true,
    ["VIPKEY_7VG_JZL_VB8"] = true,
    ["VIPKEY_Q7G_E2T_A5Y"] = true,
    ["VIPKEY_KKQ_YZP_FH8"] = true,
    ["VIPKEY_P5C_2A4_T4P"] = true,
    ["VIPKEY_8KU_TFH_GZV"] = true,
    ["VIPKEY_FT9_VJH_SSR"] = true,
    ["VIPKEY_K72_KTL_USF"] = true,
    ["VIPKEY_YFJ_JGE_ZUH"] = true,
    ["VIPKEY_GJ4_LYZ_5WM"] = true,
    ["VIPKEY_CBA_BCC_Z7P"] = true,
    ["VIPKEY_UUK_8DN_44S"] = true,
    ["VIPKEY_NAB_FH3_PFR"] = true,
    ["VIPKEY_NXA_44C_NF5"] = true,
}

local function LoadUsedVips()
    local used = {}
    local data = SafeRead(USED_VIP_FILE)
    if data and data ~= "" then
        for key in string.gmatch(data, "[^|]+") do
            used[string.upper(key)] = true
        end
    end
    return used
end

local function MarkVipUsed(key)
    local used = LoadUsedVips()
    used[string.upper(key)] = true
    local list = {}
    for k in pairs(used) do table.insert(list, k) end
    SafeWrite(USED_VIP_FILE, table.concat(list, "|"))
end

local function IsVipUsed(key)
    return LoadUsedVips()[string.upper(key)] == true
end

local function CountUsedVips()
    local c = 0
    for _ in pairs(LoadUsedVips()) do c = c + 1 end
    return c
end

local function SaveFreeKey(key, exp)
    SafeWrite(FREE_KEY_FILE, string.upper(key) .. "|" .. tostring(exp))
end

local function LoadFreeKey()
    local data = SafeRead(FREE_KEY_FILE)
    if data and data ~= "" then
        local p = SafeSplit(data, "|")
        if #p == 2 then return p[1], tonumber(p[2]) end
    end
    return nil, nil
end

local function ClearFreeKey()
    SafeWrite(FREE_KEY_FILE, "")
end

local function SaveRememberedKey(k, t)
    SafeWrite(REMEMBER_FILE, string.upper(k) .. "|" .. t)
end

local function LoadRememberedKey()
    local data = SafeRead(REMEMBER_FILE)
    if data and data ~= "" then
        local p = SafeSplit(data, "|")
        if #p == 2 then return p[1], p[2] end
    end
    return nil, nil
end

local function ClearRememberedKey()
    SafeWrite(REMEMBER_FILE, "")
end

-- ═══════════════════════════════════════════════════════════════
-- KEY UI
-- ═══════════════════════════════════════════════════════════════

local function ShowKeyGate(onSuccess)
    pcall(function()
        local old = CoreGui:FindFirstChild("VAEHXCLOUD_KEY")
        if old then old:Destroy() end
    end)

    local rem, remT = LoadRememberedKey()
    if rem and remT == "VIP" and VIP_KEYS[rem] then
        onSuccess()
        return
    end
    if rem and remT == "FREE" then
        local sf, exp = LoadFreeKey()
        if sf and string.upper(sf) == rem and exp and Now() < exp then
            onSuccess()
            return
        else
            ClearRememberedKey()
            ClearFreeKey()
        end
    end

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "VAEHXCLOUD_KEY"
    KeyGui.ResetOnSpawn = false
    KeyGui.IgnoreGuiInset = true
    KeyGui.DisplayOrder = 1000
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() KeyGui.Parent = CoreGui end)
    if not KeyGui.Parent then
        pcall(function() KeyGui.Parent = LP:WaitForChild("PlayerGui") end)
    end

    local Backdrop = Instance.new("Frame")
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Color3.fromRGB(6, 4, 12)
    Backdrop.BackgroundTransparency = 0.12
    Backdrop.BorderSizePixel = 0
    Backdrop.Parent = KeyGui

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0, 320, 0, 420)
    Card.Position = UDim2.new(0.5, -160, 0.5, -210)
    Card.BackgroundColor3 = Color3.fromRGB(16, 10, 28)
    Card.BorderSizePixel = 0
    Card.Parent = Backdrop
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)
    local cs = Instance.new("UIStroke", Card)
    cs.Color = Color3.fromRGB(160, 80, 255)
    cs.Thickness = 1.5
    cs.Transparency = 0.25

    local TopBar = Instance.new("Frame", Card)
    TopBar.Size = UDim2.new(1, 0, 0, 4)
    TopBar.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

    local Logo = Instance.new("Frame", Card)
    Logo.Size = UDim2.new(0, 52, 0, 52)
    Logo.Position = UDim2.new(0.5, -26, 0, 22)
    Logo.BackgroundColor3 = Color3.fromRGB(140, 50, 255)
    Logo.BorderSizePixel = 0
    Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)

    local LogoTxt = Instance.new("TextLabel", Logo)
    LogoTxt.Size = UDim2.new(1, 0, 1, 0)
    LogoTxt.BackgroundTransparency = 1
    LogoTxt.Text = "⚡"
    LogoTxt.TextSize = 24
    LogoTxt.Font = Enum.Font.GothamBold
    LogoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Title = Instance.new("TextLabel", Card)
    Title.Size = UDim2.new(1, -20, 0, 24)
    Title.Position = UDim2.new(0, 10, 0, 82)
    Title.BackgroundTransparency = 1
    Title.Text = "VAEH X CLOUD"
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Sub = Instance.new("TextLabel", Card)
    Sub.Size = UDim2.new(1, -20, 0, 16)
    Sub.Position = UDim2.new(0, 10, 0, 106)
    Sub.BackgroundTransparency = 1
    Sub.Text = "KEY SYSTEM  •  MOBILE"
    Sub.TextSize = 11
    Sub.Font = Enum.Font.GothamBold
    Sub.TextColor3 = Color3.fromRGB(170, 120, 255)

    local function MakeOption(y, text)
        local b = Instance.new("TextButton", Card)
        b.Size = UDim2.new(1, -28, 0, 40)
        b.Position = UDim2.new(0, 14, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(28, 16, 48)
        b.BorderSizePixel = 0
        b.Text = text
        b.TextSize = 12
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.fromRGB(230, 220, 255)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        return b
    end

    local Opt1 = MakeOption(136, "①  JOIN OUR DISCORD")
    Opt1.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
        Opt1.Text = "✓  DISCORD LINK COPIED"
        Opt1.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
    end)

    local Opt2 = MakeOption(184, "②  GET KEY FROM DISCORD APK")
    Opt2.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
        Opt2.Text = "✓  LINK COPIED"
        Opt2.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
    end)

    local KeyHint = Instance.new("TextLabel", Card)
    KeyHint.Size = UDim2.new(1, -28, 0, 16)
    KeyHint.Position = UDim2.new(0, 14, 0, 234)
    KeyHint.BackgroundTransparency = 1
    KeyHint.Text = "③  PASTE YOUR KEY"
    KeyHint.TextSize = 11
    KeyHint.Font = Enum.Font.GothamBold
    KeyHint.TextColor3 = Color3.fromRGB(190, 170, 230)
    KeyHint.TextXAlignment = Enum.TextXAlignment.Left

    local KeyBox = Instance.new("TextBox", Card)
    KeyBox.Size = UDim2.new(1, -28, 0, 42)
    KeyBox.Position = UDim2.new(0, 14, 0, 254)
    KeyBox.BackgroundColor3 = Color3.fromRGB(10, 6, 18)
    KeyBox.PlaceholderText = "VIPKEY_XXX_XXX_XXX"
    KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 85, 130)
    KeyBox.Text = ""
    KeyBox.TextSize = 13
    KeyBox.Font = Enum.Font.GothamBold
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.ClearTextOnFocus = false
    KeyBox.BorderSizePixel = 0
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 10)

    local remember = true
    local RemBtn = Instance.new("TextButton", Card)
    RemBtn.Size = UDim2.new(1, -28, 0, 26)
    RemBtn.Position = UDim2.new(0, 14, 0, 304)
    RemBtn.BackgroundTransparency = 1
    RemBtn.Text = "☑  Remember this key"
    RemBtn.TextSize = 12
    RemBtn.Font = Enum.Font.GothamBold
    RemBtn.TextColor3 = Color3.fromRGB(180, 160, 220)
    RemBtn.TextXAlignment = Enum.TextXAlignment.Left
    RemBtn.MouseButton1Click:Connect(function()
        remember = not remember
        RemBtn.Text = (remember and "☑  " or "☐  ") .. "Remember this key"
    end)

    local Status = Instance.new("TextLabel", Card)
    Status.Size = UDim2.new(1, -28, 0, 16)
    Status.Position = UDim2.new(0, 14, 0, 332)
    Status.BackgroundTransparency = 1
    Status.Text = (25 - CountUsedVips()) .. " VIP left  •  FREEKEY = 12H"
    Status.TextSize = 11
    Status.Font = Enum.Font.GothamBold
    Status.TextColor3 = Color3.fromRGB(140, 180, 255)

    local Enter = Instance.new("TextButton", Card)
    Enter.Size = UDim2.new(1, -28, 0, 44)
    Enter.Position = UDim2.new(0, 14, 0, 356)
    Enter.BackgroundColor3 = Color3.fromRGB(140, 55, 255)
    Enter.Text = "ENTER KEY"
    Enter.TextSize = 14
    Enter.Font = Enum.Font.GothamBold
    Enter.TextColor3 = Color3.fromRGB(255, 255, 255)
    Enter.BorderSizePixel = 0
    Instance.new("UICorner", Enter).CornerRadius = UDim.new(0, 10)

    local function accept()
        Status.Text = "✓ ACCESS GRANTED"
        Status.TextColor3 = Color3.fromRGB(80, 230, 140)
        Enter.Text = "LOADING..."
        Enter.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
        task.wait(0.5)
        KeyGui:Destroy()
        onSuccess()
    end

    local function check()
        local input = string.upper((KeyBox.Text or ""):gsub("%s+", ""))
        if input == "" then
            Status.Text = "✗ ENTER A KEY FIRST"
            Status.TextColor3 = Color3.fromRGB(255, 90, 90)
            return
        end
        local isVip = string.match(input, "^VIPKEY_[%w]+_[%w]+_[%w]+$")
        local isFree = string.match(input, "^FREEKEY_[%w]+_[%w]+_[%w]+$")
        if not isVip and not isFree then
            Status.Text = "✗ INVALID FORMAT"
            Status.TextColor3 = Color3.fromRGB(255, 90, 90)
            return
        end
        if isVip then
            if not VIP_KEYS[input] then
                Status.Text = "✗ INVALID VIP KEY"
                Status.TextColor3 = Color3.fromRGB(255, 90, 90)
                return
            end
            local used = IsVipUsed(input)
            local r = select(1, LoadRememberedKey())
            if used and r ~= input then
                Status.Text = "✗ KEY ALREADY USED"
                Status.TextColor3 = Color3.fromRGB(255, 90, 90)
                return
            end
            if not used and CountUsedVips() >= 25 then
                Status.Text = "✗ ALL VIP KEYS USED"
                Status.TextColor3 = Color3.fromRGB(255, 90, 90)
                return
            end
            if not used then MarkVipUsed(input) end
            if remember then SaveRememberedKey(input, "VIP") else ClearRememberedKey() end
            accept()
            return
        end
        if isFree then
            local sv, exp = LoadFreeKey()
            if sv and string.upper(sv) == input and exp then
                if Now() > exp then
                    Status.Text = "✗ FREEKEY EXPIRED"
                    Status.TextColor3 = Color3.fromRGB(255, 90, 90)
                    ClearFreeKey()
                    return
                end
            else
                SaveFreeKey(input, Now() + FREE_EXPIRE_H * 3600)
            end
            if remember then SaveRememberedKey(input, "FREE") else ClearRememberedKey() end
            accept()
        end
    end

    Enter.MouseButton1Click:Connect(check)
    KeyBox.FocusLost:Connect(function(enter)
        if enter then check() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- FEATURES
-- ═══════════════════════════════════════════════════════════════

local CFG = {
    aimbot = {
        enabled = true, bone = "Head", smooth = 0.35, fov = 120,
        predict = true, predict_str = 0.09, team_check = true, wall_check = false,
        silent = true, auto_shoot = true, draw_fov = true,
    },
    esp = {
        enabled = false, boxes = true, names = true, health = true,
        distance = true, chams = true, team_check = true,
    },
    fps = { booster = false, show_fps = true },
}

local FovCircle, LockLine, LockDot
local hasDrawing = false
pcall(function()
    FovCircle = Drawing.new("Circle")
    FovCircle.Filled = false
    FovCircle.Thickness = 1.5
    FovCircle.NumSides = 64
    FovCircle.Color = Color3.fromRGB(170, 60, 255)
    FovCircle.Transparency = 0.55
    FovCircle.Radius = CFG.aimbot.fov
    FovCircle.Visible = false

    LockLine = Drawing.new("Line")
    LockLine.Thickness = 1.4
    LockLine.Color = Color3.fromRGB(255, 60, 80)
    LockLine.Transparency = 0.3
    LockLine.Visible = false

    LockDot = Drawing.new("Circle")
    LockDot.Filled = true
    LockDot.Radius = 5
    LockDot.Color = Color3.fromRGB(255, 60, 80)
    LockDot.Visible = false
    hasDrawing = true
end)

local ESPObjects = {}
local PrevPos = {}

local function ClearESP(player)
    local data = ESPObjects[player]
    if not data then return end
    for _, obj in pairs(data) do
        if typeof(obj) == "Instance" then
            pcall(function() obj:Destroy() end)
        elseif type(obj) == "table" and obj.Remove then
            pcall(function() obj:Remove() end)
        end
    end
    ESPObjects[player] = nil
end

local function CreateESP(player)
    if not hasDrawing then return end
    if ESPObjects[player] then return end
    local data = {}
    local ok = pcall(function()
        local box = Drawing.new("Square")
        box.Thickness = 1.3
        box.Filled = false
        box.Color = Color3.fromRGB(168, 85, 247)
        box.Transparency = 0.75
        box.Visible = false
        data.box = box

        local name = Drawing.new("Text")
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Visible = false
        data.name = name

        local dist = Drawing.new("Text")
        dist.Size = 12
        dist.Center = true
        dist.Outline = true
        dist.Color = Color3.fromRGB(170, 150, 200)
        dist.Visible = false
        data.dist = dist

        local hbg = Drawing.new("Square")
        hbg.Filled = true
        hbg.Color = Color3.fromRGB(25, 20, 35)
        hbg.Visible = false
        data.hbg = hbg

        local hfill = Drawing.new("Square")
        hfill.Filled = true
        hfill.Color = Color3.fromRGB(80, 230, 150)
        hfill.Visible = false
        data.hfill = hfill
    end)
    if not ok then return end

    local char = player.Character
    if char then
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(160, 50, 255)
            hl.OutlineColor = Color3.fromRGB(200, 100, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.15
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled = false
            hl.Parent = char
            data.chams = hl
        end)
    end
    ESPObjects[player] = data
end

local function Predicted(part, player)
    local id = player.UserId
    local cur = part.Position
    if PrevPos[id] then
        local vel = (cur - PrevPos[id]) / 0.016
        PrevPos[id] = cur
        return cur + vel * CFG.aimbot.predict_str
    end
    PrevPos[id] = cur
    return cur
end

local function IsTeammate(p, check)
    if not check then return false end
    if LP.Team == nil or p.Team == nil then return false end
    return LP.Team == p.Team
end

local function HasWall(from, to, targetChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ig = { LP.Character }
    if targetChar then table.insert(ig, targetChar) end
    params.FilterDescendantsInstances = ig
    params.IgnoreWater = true
    return workspace:Raycast(from, to - from, params) ~= nil
end

local function GetClosestTarget()
    local best, bestDist, bestPlayer = nil, math.huge, nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local camPos = Camera.CFrame.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            if not IsTeammate(p, CFG.aimbot.team_check) then
                local char = p.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local part = char:FindFirstChild(CFG.aimbot.bone) or char:FindFirstChild("HumanoidRootPart")
                        if part then
                            local blocked = CFG.aimbot.wall_check and HasWall(camPos, part.Position, char)
                            if not blocked then
                                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                    if dist <= CFG.aimbot.fov and dist < bestDist then
                                        best = part
                                        bestDist = dist
                                        bestPlayer = p
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestDist, bestPlayer
end

-- ═══════════════════════════════════════════════════════════════
-- WINDUI MAIN + FLOATING REOPEN + FPS
-- ═══════════════════════════════════════════════════════════════

local function loadMain()
    local WindUI
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua",
    }
    for i = 1, #urls do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(urls[i]))()
        end)
        if ok and result then
            WindUI = result
            break
        end
    end
    if not WindUI then
        warn("[Vaeh X Cloud] WindUI failed to load")
        return
    end

    pcall(function() WindUI:SetNotificationLower(true) end)

    local Window = WindUI:CreateWindow({
        Title = "Vaeh X Cloud",
        Icon = "zap",
        Author = "Mobile • Delta",
        Folder = "VaehXCloud",
        Size = UDim2.fromOffset(460, 340),
        MinSize = Vector2.new(300, 220),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        HideSearchBar = true,
    })

    pcall(function()
        if Window.ToggleTransparency then
            Window:ToggleTransparency(true)
        end
    end)

    local MainTab  = Window:Tab({ Title = "Main", Icon = "home" })
    local AimTab   = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
    local EspTab   = Window:Tab({ Title = "ESP", Icon = "eye" })
    local ExtraTab = Window:Tab({ Title = "Extra", Icon = "sparkles" })
    local FpsTab   = Window:Tab({ Title = "FPS", Icon = "gauge" })
    local ThemeTab = Window:Tab({ Title = "Theme", Icon = "palette" })
    local CfgTab   = Window:Tab({ Title = "Config", Icon = "settings" })

    -- MAIN
    MainTab:Paragraph({
        Title = "Vaeh X Cloud",
        Desc = "Created by Curd.exe",
    })
    MainTab:Paragraph({
        Title = "Script Status",
        Desc = "🟢 Working — good bypass",
    })
    MainTab:Paragraph({
        Title = "Status Guide",
        Desc = "🔴 Not working\n🟡 Kinda works — low bypass\n🟢 Good — strong bypass",
    })
    MainTab:Button({
        Title = "Join Discord",
        Icon = "message-circle",
        Callback = function()
            pcall(function() setclipboard("https://discord.gg/nr7QdQuzbM") end)
            WindUI:Notify({ Title = "Discord", Content = "Link copied!", Duration = 3 })
        end,
    })
    MainTab:Paragraph({
        Title = "Features",
        Desc = "• Aimbot (FOV, Smooth, Silent, Prediction)\n• Team Check / Wall Check\n• ESP (Boxes, Names, Health, Distance, Chams)\n• FPS Booster + Counter\n• Theme + Gradient Effects\n• Config Save / Load\n• VIP / FREE Key System\n• Floating reopen + FPS/Ping",
    })
    MainTab:Paragraph({
        Title = "What's New",
        Desc = "• New screen UI\n• WindUI library\n• Gradient effects (unique per theme)\n• Super Light Liquid Glass\n• Main tab + status\n• Ping + FPS when UI closed",
    })

    -- AIMBOT
    AimTab:Toggle({ Title = "Enable Aimbot", Value = CFG.aimbot.enabled, Callback = function(v) CFG.aimbot.enabled = v end })
    AimTab:Toggle({ Title = "Team Check", Value = CFG.aimbot.team_check, Callback = function(v) CFG.aimbot.team_check = v end })
    AimTab:Toggle({ Title = "Wall Check", Value = CFG.aimbot.wall_check, Callback = function(v) CFG.aimbot.wall_check = v end })
    AimTab:Toggle({ Title = "Draw FOV Circle", Value = CFG.aimbot.draw_fov, Callback = function(v) CFG.aimbot.draw_fov = v end })
    AimTab:Dropdown({ Title = "Target Part", Values = { "Head", "HumanoidRootPart" }, Value = CFG.aimbot.bone, Callback = function(v) CFG.aimbot.bone = v end })
    AimTab:Slider({ Title = "FOV Radius", Step = 1, Value = { Min = 40, Max = 400, Default = CFG.aimbot.fov }, Callback = function(v)
        CFG.aimbot.fov = v
        if hasDrawing and FovCircle then FovCircle.Radius = v end
    end })
    AimTab:Slider({ Title = "Smoothness", Step = 0.01, Value = { Min = 0.05, Max = 1, Default = CFG.aimbot.smooth }, Callback = function(v) CFG.aimbot.smooth = v end })

    -- ESP
    EspTab:Toggle({ Title = "Enable ESP", Value = CFG.esp.enabled, Callback = function(v) CFG.esp.enabled = v end })
    EspTab:Toggle({ Title = "Team Check", Value = CFG.esp.team_check, Callback = function(v) CFG.esp.team_check = v end })
    EspTab:Toggle({ Title = "Boxes", Value = CFG.esp.boxes, Callback = function(v) CFG.esp.boxes = v end })
    EspTab:Toggle({ Title = "Names", Value = CFG.esp.names, Callback = function(v) CFG.esp.names = v end })
    EspTab:Toggle({ Title = "Health Bars", Value = CFG.esp.health, Callback = function(v) CFG.esp.health = v end })
    EspTab:Toggle({ Title = "Distance", Value = CFG.esp.distance, Callback = function(v) CFG.esp.distance = v end })
    EspTab:Toggle({ Title = "Chams", Value = CFG.esp.chams, Callback = function(v) CFG.esp.chams = v end })

    -- EXTRA
    ExtraTab:Toggle({ Title = "Silent Aim", Value = CFG.aimbot.silent, Callback = function(v) CFG.aimbot.silent = v end })
    ExtraTab:Toggle({ Title = "Auto Shoot", Value = CFG.aimbot.auto_shoot, Callback = function(v) CFG.aimbot.auto_shoot = v end })
    ExtraTab:Toggle({ Title = "Prediction", Value = CFG.aimbot.predict, Callback = function(v) CFG.aimbot.predict = v end })
    ExtraTab:Slider({ Title = "Prediction Strength", Step = 0.01, Value = { Min = 0.01, Max = 0.5, Default = CFG.aimbot.predict_str }, Callback = function(v) CFG.aimbot.predict_str = v end })

    -- FPS
    FpsTab:Toggle({ Title = "Show FPS Counter", Value = CFG.fps.show_fps, Callback = function(v) CFG.fps.show_fps = v end })
    FpsTab:Toggle({ Title = "FPS Booster", Value = CFG.fps.booster, Callback = function(v)
        CFG.fps.booster = v
        if v then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                Lighting.GlobalShadows = true
            end)
        end
    end })

    -- THEME (base) SEPARATE from GRADIENT effects
    -- Each gradient has its OWN custom effect (not the same shine)

    local GRADIENTS = {
        ["None"]             = nil,
        ["Purple Dream"]     = { Color3.fromRGB(127,0,255), Color3.fromRGB(225,0,255) },
        ["Ocean"]            = { Color3.fromRGB(33,147,176), Color3.fromRGB(109,213,237) },
        ["Sunset"]           = { Color3.fromRGB(255,81,47), Color3.fromRGB(221,36,118) },
        ["Fire"]             = { Color3.fromRGB(255,81,47), Color3.fromRGB(240,152,25) },
        ["Mint"]             = { Color3.fromRGB(0,176,155), Color3.fromRGB(150,201,61) },
        ["Cosmic"]           = { Color3.fromRGB(65,41,90), Color3.fromRGB(47,7,67) },
        ["Neon Cyber"]       = { Color3.fromRGB(0,242,96), Color3.fromRGB(5,117,230) },
        ["Cotton Candy"]     = { Color3.fromRGB(252,92,125), Color3.fromRGB(106,130,251) },
        ["Royal"]            = { Color3.fromRGB(20,30,48), Color3.fromRGB(36,59,85) },
        ["Crimson"]          = { Color3.fromRGB(142,14,0), Color3.fromRGB(31,28,24) },
        ["Ice"]              = { Color3.fromRGB(116,235,213), Color3.fromRGB(172,182,229) },
        ["Gold"]             = { Color3.fromRGB(247,151,30), Color3.fromRGB(255,210,0) },
        ["Liquid Glass"]     = { Color3.fromRGB(200,220,255), Color3.fromRGB(255,255,255) },
        ["Super Light Glass"] = { Color3.fromRGB(240,245,255), Color3.fromRGB(255,255,255) },
    }
    local GRAD_NAMES = {
        "None", "Purple Dream", "Ocean", "Sunset", "Fire", "Mint", "Cosmic",
        "Neon Cyber", "Cotton Candy", "Royal", "Crimson", "Ice", "Gold",
        "Liquid Glass", "Super Light Glass",
    }

    local fxActive = false
    local fxLayer = nil
    local fxThread = nil
    local currentGrad = "None"

    -- Cache WindUI main frame once (avoid applying to random GUIs)
    local cachedMainFrame = nil
    local function FindMainFrame()
        if cachedMainFrame and cachedMainFrame.Parent then
            return cachedMainFrame
        end
        for _, sg in ipairs(CoreGui:GetChildren()) do
            if sg:IsA("ScreenGui") then
                local n = string.lower(sg.Name)
                if sg.Name == "VAEHXCLOUD_KEY" or sg.Name == "VAEHXCLOUD_FLOAT" then
                    -- skip
                elseif string.find(n, "wind") or string.find(n, "vaeh") or string.find(n, "fluent") then
                    for _, f in ipairs(sg:GetDescendants()) do
                        if f:IsA("Frame") and f.AbsoluteSize.X > 250 and f.AbsoluteSize.Y > 180 then
                            cachedMainFrame = f
                            return f
                        end
                    end
                end
            end
        end
        -- fallback: largest recent frame that is not our overlays
        local best, bestArea = nil, 0
        for _, sg in ipairs(CoreGui:GetChildren()) do
            if sg:IsA("ScreenGui") and sg.Name ~= "VAEHXCLOUD_KEY" and sg.Name ~= "VAEHXCLOUD_FLOAT" then
                for _, f in ipairs(sg:GetDescendants()) do
                    if f:IsA("Frame") then
                        local a = f.AbsoluteSize.X * f.AbsoluteSize.Y
                        if a > bestArea and f.AbsoluteSize.X > 250 and f.AbsoluteSize.Y > 180 then
                            bestArea = a
                            best = f
                        end
                    end
                end
            end
        end
        cachedMainFrame = best
        return best
    end

    -- Wait a moment then cache frame (WindUI needs to build)
    task.defer(function()
        task.wait(0.5)
        FindMainFrame()
    end)

    local function ClearFx()
        fxActive = false
        if fxThread then
            pcall(function() task.cancel(fxThread) end)
            fxThread = nil
        end
        if fxLayer then
            pcall(function() fxLayer:Destroy() end)
            fxLayer = nil
        end
        local frame = FindMainFrame()
        if frame then
            for _, ch in ipairs(frame:GetChildren()) do
                if ch.Name == "VXGrad" or ch.Name == "VXFxLayer" then
                    pcall(function() ch:Destroy() end)
                end
            end
        end
    end

    local function ApplyGradientColors(name)
        local frame = FindMainFrame()
        if not frame then return end
        for _, ch in ipairs(frame:GetChildren()) do
            if ch:IsA("UIGradient") and ch.Name == "VXGrad" then
                ch:Destroy()
            end
        end
        local cols = GRADIENTS[name]
        if not cols then return end
        local g = Instance.new("UIGradient")
        g.Name = "VXGrad"
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, cols[1]),
            ColorSequenceKeypoint.new(1, cols[2]),
        })
        g.Rotation = 135
        g.Parent = frame
    end

    -- Unique effect per gradient
    local function StartGradEffect(name)
        ClearFx()
        currentGrad = name
        if name == "None" then return end

        local frame = FindMainFrame()
        if not frame then return end

        ApplyGradientColors(name)
        fxActive = true

        local layer = Instance.new("Frame")
        layer.Name = "VXFxLayer"
        layer.Size = UDim2.new(1, 0, 1, 0)
        layer.BackgroundTransparency = 1
        layer.BorderSizePixel = 0
        layer.ZIndex = 22
        layer.ClipsDescendants = true
        layer.Parent = frame
        fxLayer = layer
        Instance.new("UICorner", layer).CornerRadius = UDim.new(0, 12)

        local cols = GRADIENTS[name]
        local c1 = cols and cols[1] or Color3.fromRGB(255, 255, 255)
        local c2 = cols and cols[2] or Color3.fromRGB(200, 200, 255)

        -- ── Super Light Glass: random soft orb every 2s (new place each time) ──
        if name == "Super Light Glass" then
            local orb = Instance.new("Frame", layer)
            orb.Size = UDim2.new(0, 90, 0, 90)
            orb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            orb.BackgroundTransparency = 0.7
            orb.BorderSizePixel = 0
            orb.ZIndex = 23
            Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
            local og = Instance.new("UIGradient", orb)
            og.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(1, 1),
            })
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    local x = math.random(5, 70) / 100
                    local y = math.random(5, 70) / 100
                    orb.Position = UDim2.new(x, 0, y, 0)
                    orb.BackgroundTransparency = 0.55
                    local tw = TweenService:Create(orb, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.92,
                        Size = UDim2.new(0, 120, 0, 120),
                    })
                    tw:Play()
                    tw.Completed:Wait()
                    orb.Size = UDim2.new(0, 90, 0, 90)
                    task.wait(1.1)
                end
            end)
            return
        end

        -- ── Liquid Glass: horizontal wave sweep ──
        if name == "Liquid Glass" then
            local wave = Instance.new("Frame", layer)
            wave.Size = UDim2.new(0.5, 0, 1.2, 0)
            wave.Position = UDim2.new(-0.5, 0, -0.1, 0)
            wave.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            wave.BackgroundTransparency = 0.6
            wave.BorderSizePixel = 0
            wave.Rotation = 18
            wave.ZIndex = 23
            local wg = Instance.new("UIGradient", wave)
            wg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            })
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    wave.Position = UDim2.new(-0.55, 0, -0.1, 0)
                    local tw = TweenService:Create(wave, TweenInfo.new(1.6, Enum.EasingStyle.Sine), {
                        Position = UDim2.new(1.1, 0, -0.1, 0),
                    })
                    tw:Play()
                    tw.Completed:Wait()
                    task.wait(0.4)
                end
            end)
            return
        end

        -- ── Fire: rising heat flicker ──
        if name == "Fire" then
            local bar = Instance.new("Frame", layer)
            bar.Size = UDim2.new(1, 0, 0.25, 0)
            bar.Position = UDim2.new(0, 0, 1, 0)
            bar.BackgroundColor3 = c1
            bar.BackgroundTransparency = 0.55
            bar.BorderSizePixel = 0
            bar.ZIndex = 23
            local bg = Instance.new("UIGradient", bar)
            bg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(1, c2),
            })
            bg.Rotation = 90
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    bar.Position = UDim2.new(0, 0, 0.85, 0)
                    bar.BackgroundTransparency = 0.45
                    local tw = TweenService:Create(bar, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 0, 0.55, 0),
                        BackgroundTransparency = 0.9,
                    })
                    tw:Play()
                    tw.Completed:Wait()
                    task.wait(0.8)
                end
            end)
            return
        end

        -- ── Ocean: slow vertical drift ──
        if name == "Ocean" then
            local band = Instance.new("Frame", layer)
            band.Size = UDim2.new(1.2, 0, 0.3, 0)
            band.BackgroundColor3 = c2
            band.BackgroundTransparency = 0.65
            band.BorderSizePixel = 0
            band.ZIndex = 23
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    band.Position = UDim2.new(-0.1, 0, -0.2, 0)
                    local tw = TweenService:Create(band, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        Position = UDim2.new(-0.1, 0, 0.9, 0),
                    })
                    tw:Play()
                    tw.Completed:Wait()
                end
            end)
            return
        end

        -- ── Neon Cyber: edge pulse ──
        if name == "Neon Cyber" then
            local edge = Instance.new("UIStroke", layer)
            edge.Color = c1
            edge.Thickness = 2
            edge.Transparency = 0.3
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    local tw1 = TweenService:Create(edge, TweenInfo.new(0.9), { Transparency = 0.05, Thickness = 3 })
                    tw1:Play()
                    tw1.Completed:Wait()
                    local tw2 = TweenService:Create(edge, TweenInfo.new(0.9), { Transparency = 0.5, Thickness = 1.5 })
                    tw2:Play()
                    tw2.Completed:Wait()
                    task.wait(0.2)
                end
            end)
            return
        end

        -- ── Cosmic: star dots blink ──
        if name == "Cosmic" then
            local dots = {}
            for i = 1, 6 do
                local d = Instance.new("Frame", layer)
                d.Size = UDim2.new(0, 4, 0, 4)
                d.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
                d.BackgroundTransparency = 0.3
                d.BorderSizePixel = 0
                d.ZIndex = 23
                Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
                d.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(10, 90) / 100, 0)
                table.insert(dots, d)
            end
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    for _, d in ipairs(dots) do
                        d.Position = UDim2.new(math.random(8, 92) / 100, 0, math.random(8, 92) / 100, 0)
                        TweenService:Create(d, TweenInfo.new(0.5), { BackgroundTransparency = 0.1 }):Play()
                    end
                    task.wait(0.6)
                    for _, d in ipairs(dots) do
                        TweenService:Create(d, TweenInfo.new(0.5), { BackgroundTransparency = 0.85 }):Play()
                    end
                    task.wait(1.4)
                end
            end)
            return
        end

        -- ── Gold: diagonal spark flash ──
        if name == "Gold" then
            local spark = Instance.new("Frame", layer)
            spark.Size = UDim2.new(0.15, 0, 1.5, 0)
            spark.BackgroundColor3 = Color3.fromRGB(255, 230, 120)
            spark.BackgroundTransparency = 0.4
            spark.BorderSizePixel = 0
            spark.Rotation = -35
            spark.ZIndex = 23
            local spg = Instance.new("UIGradient", spark)
            spg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.2),
                NumberSequenceKeypoint.new(1, 1),
            })
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    spark.Position = UDim2.new(-0.3, 0, -0.3, 0)
                    local tw = TweenService:Create(spark, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
                        Position = UDim2.new(1.1, 0, 0.5, 0),
                    })
                    tw:Play()
                    tw.Completed:Wait()
                    task.wait(1.3)
                end
            end)
            return
        end

        -- ── Crimson: bottom glow breathe ──
        if name == "Crimson" then
            local glow = Instance.new("Frame", layer)
            glow.Size = UDim2.new(1, 0, 0.4, 0)
            glow.Position = UDim2.new(0, 0, 0.65, 0)
            glow.BackgroundColor3 = c1
            glow.BackgroundTransparency = 0.7
            glow.BorderSizePixel = 0
            glow.ZIndex = 23
            local gg = Instance.new("UIGradient", glow)
            gg.Rotation = 90
            gg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0.3),
            })
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    TweenService:Create(glow, TweenInfo.new(1.1), { BackgroundTransparency = 0.45 }):Play()
                    task.wait(1.1)
                    TweenService:Create(glow, TweenInfo.new(1.1), { BackgroundTransparency = 0.85 }):Play()
                    task.wait(1.1)
                end
            end)
            return
        end

        -- ── Ice: frost corner freeze ──
        if name == "Ice" then
            local frost = Instance.new("Frame", layer)
            frost.Size = UDim2.new(0.4, 0, 0.4, 0)
            frost.Position = UDim2.new(0.6, 0, 0, 0)
            frost.BackgroundColor3 = Color3.fromRGB(200, 240, 255)
            frost.BackgroundTransparency = 0.75
            frost.BorderSizePixel = 0
            frost.ZIndex = 23
            Instance.new("UICorner", frost).CornerRadius = UDim.new(1, 0)
            fxThread = task.spawn(function()
                while fxActive and layer.Parent do
                    local side = math.random(1, 4)
                    if side == 1 then frost.Position = UDim2.new(0, 0, 0, 0)
                    elseif side == 2 then frost.Position = UDim2.new(0.6, 0, 0, 0)
                    elseif side == 3 then frost.Position = UDim2.new(0, 0, 0.6, 0)
                    else frost.Position = UDim2.new(0.6, 0, 0.6, 0) end
                    frost.BackgroundTransparency = 0.5
                    TweenService:Create(frost, TweenInfo.new(1.5), { BackgroundTransparency = 0.95 }):Play()
                    task.wait(2)
                end
            end)
            return
        end

        -- ── Purple Dream: soft color breathe (rotation) ──
        if name == "Purple Dream" then
            local g = frame:FindFirstChild("VXGrad")
            fxThread = task.spawn(function()
                local rot = 135
                while fxActive and layer.Parent do
                    rot = rot + 25
                    if g and g.Parent then
                        TweenService:Create(g, TweenInfo.new(2, Enum.EasingStyle.Sine), { Rotation = rot }):Play()
                    end
                    task.wait(2)
                end
            end)
            return
        end

        -- ── Sunset / Cotton Candy / Mint / Royal: gentle opacity pulse on gradient ──
        local g = frame:FindFirstChild("VXGrad")
        if g then
            fxThread = task.spawn(function()
                while fxActive and layer.Parent and g.Parent do
                    TweenService:Create(g, TweenInfo.new(1.2, Enum.EasingStyle.Sine), { Offset = Vector2.new(0.15, 0) }):Play()
                    task.wait(1.2)
                    TweenService:Create(g, TweenInfo.new(1.2, Enum.EasingStyle.Sine), { Offset = Vector2.new(-0.15, 0) }):Play()
                    task.wait(1.2)
                end
            end)
        end
    end

    ThemeTab:Paragraph({ Title = "Base Theme", Desc = "WindUI color theme (separate from gradients)" })
    ThemeTab:Dropdown({
        Title = "Base Theme",
        Values = { "Dark", "Light", "Rose", "Aqua", "Amethyst", "Emerald", "Indigo", "Orange" },
        Value = "Dark",
        Callback = function(t)
            pcall(function()
                if WindUI.SetTheme then WindUI:SetTheme(t) end
                if Window.SetTheme then Window:SetTheme(t) end
            end)
            WindUI:Notify({ Title = "Base Theme", Content = tostring(t), Duration = 2 })
        end,
    })
    ThemeTab:Toggle({
        Title = "Transparent / Glass",
        Value = true,
        Callback = function(v)
            pcall(function()
                if Window.ToggleTransparency then Window:ToggleTransparency(v) end
            end)
        end,
    })

    ThemeTab:Paragraph({ Title = "Gradient Effects", Desc = "Each gradient has its own custom animation" })
    ThemeTab:Dropdown({
        Title = "Gradient Effect",
        Values = GRAD_NAMES,
        Value = "None",
        Callback = function(name)
            task.defer(function()
                StartGradEffect(name)
            end)
            WindUI:Notify({ Title = "Gradient", Content = tostring(name), Duration = 2 })
        end,
    })

    -- CONFIG
    CfgTab:Button({ Title = "Save Config", Icon = "save", Callback = function()
        local data = { aimbot = CFG.aimbot, esp = CFG.esp, fps = CFG.fps }
        local ok = pcall(function()
            writefile("vaehxcloud_config.json", HttpService:JSONEncode(data))
        end)
        WindUI:Notify({ Title = "Vaeh X Cloud", Content = ok and "Config saved!" or "Failed", Duration = 3 })
    end })
    CfgTab:Button({ Title = "Load Config", Icon = "folder-open", Callback = function()
        local raw = SafeRead("vaehxcloud_config.json")
        if raw then
            local s, dec = pcall(function() return HttpService:JSONDecode(raw) end)
            if s and type(dec) == "table" then
                if dec.aimbot then for k, v in pairs(dec.aimbot) do if CFG.aimbot[k] ~= nil then CFG.aimbot[k] = v end end end
                if dec.esp then for k, v in pairs(dec.esp) do if CFG.esp[k] ~= nil then CFG.esp[k] = v end end end
                if dec.fps then for k, v in pairs(dec.fps) do if CFG.fps[k] ~= nil then CFG.fps[k] = v end end end
                WindUI:Notify({ Title = "Vaeh X Cloud", Content = "Config loaded!", Duration = 3 })
                return
            end
        end
        WindUI:Notify({ Title = "Vaeh X Cloud", Content = "No config found", Duration = 3 })
    end })

    -- ── Floating reopen + FPS (always on screen) ──────────────
    local FloatGui = Instance.new("ScreenGui")
    FloatGui.Name = "VAEHXCLOUD_FLOAT"
    FloatGui.ResetOnSpawn = false
    FloatGui.IgnoreGuiInset = true
    FloatGui.DisplayOrder = 50
    pcall(function() FloatGui.Parent = CoreGui end)

    -- FPS + Ping centered at top middle
    local FpsPill = Instance.new("TextLabel", FloatGui)
    FpsPill.Size = UDim2.new(0, 72, 0, 26)
    FpsPill.Position = UDim2.new(0.5, -80, 0, 12)
    FpsPill.AnchorPoint = Vector2.new(0, 0)
    FpsPill.BackgroundColor3 = Color3.fromRGB(14, 8, 24)
    FpsPill.BackgroundTransparency = 0.15
    FpsPill.TextColor3 = Color3.fromRGB(80, 230, 150)
    FpsPill.TextSize = 12
    FpsPill.Font = Enum.Font.GothamBold
    FpsPill.Text = "FPS --"
    FpsPill.Visible = true
    Instance.new("UICorner", FpsPill).CornerRadius = UDim.new(0, 8)
    local fpsStroke = Instance.new("UIStroke", FpsPill)
    fpsStroke.Color = Color3.fromRGB(100, 50, 200)
    fpsStroke.Thickness = 1
    fpsStroke.Transparency = 0.4

    local PingPill = Instance.new("TextLabel", FloatGui)
    PingPill.Size = UDim2.new(0, 80, 0, 26)
    PingPill.Position = UDim2.new(0.5, -4, 0, 12)
    PingPill.BackgroundColor3 = Color3.fromRGB(14, 8, 24)
    PingPill.BackgroundTransparency = 0.15
    PingPill.TextColor3 = Color3.fromRGB(120, 200, 255)
    PingPill.TextSize = 12
    PingPill.Font = Enum.Font.GothamBold
    PingPill.Text = "PING --"
    PingPill.Visible = true
    Instance.new("UICorner", PingPill).CornerRadius = UDim.new(0, 8)
    local pingStroke = Instance.new("UIStroke", PingPill)
    pingStroke.Color = Color3.fromRGB(60, 120, 200)
    pingStroke.Thickness = 1
    pingStroke.Transparency = 0.4

    -- Tiny reopen button (shown when window closed)
    local ReopenBtn = Instance.new("TextButton", FloatGui)
    ReopenBtn.Size = UDim2.new(0, 44, 0, 44)
    ReopenBtn.Position = UDim2.new(0, 10, 0, 44)
    ReopenBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 240)
    ReopenBtn.Text = "⚡"
    ReopenBtn.TextSize = 20
    ReopenBtn.Font = Enum.Font.GothamBold
    ReopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReopenBtn.Visible = false
    ReopenBtn.BorderSizePixel = 0
    Instance.new("UICorner", ReopenBtn).CornerRadius = UDim.new(1, 0)
    local rbStroke = Instance.new("UIStroke", ReopenBtn)
    rbStroke.Color = Color3.fromRGB(200, 140, 255)
    rbStroke.Thickness = 1.5

    -- Drag reopen button
    local dragging, dragStart, startPos = false, nil, nil
    ReopenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ReopenBtn.Position
        end
    end)
    ReopenBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            ReopenBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local windowOpen = true

    local function showWindow()
        windowOpen = true
        ReopenBtn.Visible = false
        pcall(function()
            if Window.Open then Window:Open() end
            if Window.SetVisible then Window:SetVisible(true) end
        end)
        -- Try find WindUI screen and show
        pcall(function()
            for _, sg in ipairs(CoreGui:GetChildren()) do
                if sg:IsA("ScreenGui") and sg.Name ~= "VAEHXCLOUD_KEY" and sg.Name ~= "VAEHXCLOUD_FLOAT" then
                    local n = string.lower(sg.Name)
                    if string.find(n, "wind") or string.find(n, "vaeh") or string.find(n, "cloud") then
                        sg.Enabled = true
                    end
                end
            end
        end)
    end

    local function hideWindow()
        windowOpen = false
        ReopenBtn.Visible = true
        pcall(function()
            if Window.Close then Window:Close() end
            if Window.SetVisible then Window:SetVisible(false) end
        end)
        pcall(function()
            for _, sg in ipairs(CoreGui:GetChildren()) do
                if sg:IsA("ScreenGui") and sg.Name ~= "VAEHXCLOUD_KEY" and sg.Name ~= "VAEHXCLOUD_FLOAT" then
                    local n = string.lower(sg.Name)
                    if string.find(n, "wind") or string.find(n, "vaeh") or string.find(n, "cloud") then
                        -- don't disable everything blindly; WindUI may use different names
                    end
                end
            end
        end)
    end

    ReopenBtn.MouseButton1Click:Connect(function()
        if not dragging then
            showWindow()
        end
    end)

    -- Hook WindUI close if possible
    pcall(function()
        if Window.OnClose then
            Window:OnClose(function()
                hideWindow()
            end)
        end
    end)

    -- Keep pills visible (FPS toggle only hides FPS; ping always on when closed)
    task.spawn(function()
        while true do
            task.wait(0.4)
            FpsPill.Visible = CFG.fps.show_fps or (not windowOpen)
            PingPill.Visible = true
        end
    end)

    WindUI:Notify({ Title = "Vaeh X Cloud", Content = "WindUI loaded — close shows ⚡ + FPS/Ping", Duration = 4 })

    -- Game loop
    local fpsCounter = 0
    local fpsLast = tick()
    local Stats = game:GetService("Stats")

    RunService.RenderStepped:Connect(function()
        fpsCounter = fpsCounter + 1
        if tick() - fpsLast >= 1 then
            local cur = fpsCounter
            fpsCounter = 0
            fpsLast = tick()
            FpsPill.Text = "FPS " .. tostring(cur)
            if cur >= 50 then
                FpsPill.TextColor3 = Color3.fromRGB(80, 230, 150)
            elseif cur >= 30 then
                FpsPill.TextColor3 = Color3.fromRGB(255, 200, 50)
            else
                FpsPill.TextColor3 = Color3.fromRGB(230, 60, 60)
            end

            -- Ping
            local pingMs = 0
            pcall(function()
                local net = Stats.Network
                if net and net.ServerStatsItem then
                    local item = net.ServerStatsItem["Data Ping"]
                    if item then
                        pingMs = math.floor(item:GetValue())
                    end
                end
            end)
            if pingMs <= 0 then
                pcall(function()
                    pingMs = math.floor(LP:GetNetworkPing() * 1000)
                end)
            end
            PingPill.Text = "PING " .. tostring(pingMs)
            if pingMs <= 80 then
                PingPill.TextColor3 = Color3.fromRGB(80, 230, 150)
            elseif pingMs <= 150 then
                PingPill.TextColor3 = Color3.fromRGB(255, 200, 50)
            else
                PingPill.TextColor3 = Color3.fromRGB(230, 60, 60)
            end
        end

        if hasDrawing and FovCircle then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FovCircle.Position = center
            FovCircle.Visible = CFG.aimbot.enabled and CFG.aimbot.draw_fov
        end

        if CFG.aimbot.enabled then
            local target, _, tPlayer = GetClosestTarget()
            if target and tPlayer then
                local aimPos = target.Position
                if CFG.aimbot.predict then
                    aimPos = Predicted(target, tPlayer)
                end
                local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
                if onScreen then
                    if not CFG.aimbot.silent then
                        Camera.CFrame = Camera.CFrame:Lerp(
                            CFrame.lookAt(Camera.CFrame.Position, aimPos),
                            CFG.aimbot.smooth
                        )
                    end
                    if hasDrawing and LockLine and LockDot then
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        LockLine.From = center
                        LockLine.To = Vector2.new(sp.X, sp.Y)
                        LockLine.Visible = true
                        LockDot.Position = Vector2.new(sp.X, sp.Y)
                        LockDot.Visible = true
                    end
                else
                    if hasDrawing and LockLine then LockLine.Visible = false end
                    if hasDrawing and LockDot then LockDot.Visible = false end
                end
            else
                if hasDrawing and LockLine then LockLine.Visible = false end
                if hasDrawing and LockDot then LockDot.Visible = false end
            end
        else
            if hasDrawing and LockLine then LockLine.Visible = false end
            if hasDrawing and LockDot then LockDot.Visible = false end
        end

        if CFG.esp.enabled and hasDrawing then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    if IsTeammate(p, CFG.esp.team_check) then
                        ClearESP(p)
                    else
                        local char = p.Character
                        if not char then
                            ClearESP(p)
                        else
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if not hum or not root or hum.Health <= 0 then
                                ClearESP(p)
                            else
                                if not ESPObjects[p] then CreateESP(p) end
                                local data = ESPObjects[p]
                                if data then
                                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                                    if not onScreen then
                                        if data.box then data.box.Visible = false end
                                        if data.name then data.name.Visible = false end
                                        if data.dist then data.dist.Visible = false end
                                        if data.hbg then data.hbg.Visible = false end
                                        if data.hfill then data.hfill.Visible = false end
                                        if data.chams then data.chams.Enabled = false end
                                    else
                                        local size = 2000 / math.max(pos.Z, 1)
                                        local h = size * 1.8
                                        local w = size
                                        if CFG.esp.boxes and data.box then
                                            data.box.Size = Vector2.new(w, h)
                                            data.box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                                            data.box.Visible = true
                                        elseif data.box then
                                            data.box.Visible = false
                                        end
                                        if CFG.esp.names and data.name then
                                            data.name.Text = p.Name
                                            data.name.Position = Vector2.new(pos.X, pos.Y - h / 2 - 16)
                                            data.name.Visible = true
                                        elseif data.name then
                                            data.name.Visible = false
                                        end
                                        if CFG.esp.distance and data.dist then
                                            data.dist.Text = math.floor((root.Position - Camera.CFrame.Position).Magnitude) .. "m"
                                            data.dist.Position = Vector2.new(pos.X, pos.Y + h / 2 + 4)
                                            data.dist.Visible = true
                                        elseif data.dist then
                                            data.dist.Visible = false
                                        end
                                        if CFG.esp.health and data.hbg and data.hfill then
                                            local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                            data.hbg.Size = Vector2.new(3, h)
                                            data.hbg.Position = Vector2.new(pos.X - w / 2 - 6, pos.Y - h / 2)
                                            data.hbg.Visible = true
                                            data.hfill.Size = Vector2.new(3, h * hp)
                                            data.hfill.Position = Vector2.new(pos.X - w / 2 - 6, pos.Y - h / 2 + h * (1 - hp))
                                            data.hfill.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 40)
                                            data.hfill.Visible = true
                                        else
                                            if data.hbg then data.hbg.Visible = false end
                                            if data.hfill then data.hfill.Visible = false end
                                        end
                                        if data.chams then
                                            data.chams.Enabled = CFG.esp.chams
                                            if not data.chams.Parent then data.chams.Parent = char end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            for p in pairs(ESPObjects) do ClearESP(p) end
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        ClearESP(p)
        PrevPos[p.UserId] = nil
    end)
    LP.CharacterRemoving:Connect(function()
        PrevPos = {}
    end)

    -- Expose hide for WindUI X button (best-effort)
    pcall(function()
        task.delay(1, function()
            for _, sg in ipairs(CoreGui:GetChildren()) do
                if sg:IsA("ScreenGui") then
                    for _, desc in ipairs(sg:GetDescendants()) do
                        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                            local t = string.lower(tostring(desc.Text or ""))
                            local n = string.lower(desc.Name or "")
                            if t == "x" or t == "×" or string.find(n, "close") then
                                desc.MouseButton1Click:Connect(function()
                                    task.defer(hideWindow)
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end)

    print("[Vaeh X Cloud] WindUI + floating reopen ready")
end

ShowKeyGate(loadMain)

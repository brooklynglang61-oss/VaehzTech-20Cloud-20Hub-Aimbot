--[[
    Vaeh X Cloud — Mobile Only
    FluentPro UI (StyearX) — themes like the showcase video
    Velvet / Galaxy Purple default + Acrylic + Liquid Glass
    Theme SEPARATE from Config
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) then
    warn("[Vaeh X Cloud] Mobile only.")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local USED_VIP_FILE = "vaehxcloud_used_vips.txt"
local FREE_KEY_FILE = "vaehxcloud_freekey.txt"
local REMEMBER_FILE = "vaehxcloud_remember.txt"
local FREE_EXPIRE_H = 12

local VIP_KEYS = {
    ["VIPKEY_WGR_XZJ_7FY"]=true,["VIPKEY_SJC_LMH_K6Q"]=true,
    ["VIPKEY_96H_FRP_TEH"]=true,["VIPKEY_USC_6J2_2HG"]=true,
    ["VIPKEY_YQU_WMT_KUL"]=true,["VIPKEY_AYV_AZH_LUZ"]=true,
    ["VIPKEY_JTR_ZAX_6BC"]=true,["VIPKEY_HSQ_X29_NAB"]=true,
    ["VIPKEY_PZF_FAN_G62"]=true,["VIPKEY_TFN_FTZ_2WJ"]=true,
    ["VIPKEY_4H6_629_M3N"]=true,["VIPKEY_SN2_6AY_Q5Y"]=true,
    ["VIPKEY_7VG_JZL_VB8"]=true,["VIPKEY_Q7G_E2T_A5Y"]=true,
    ["VIPKEY_KKQ_YZP_FH8"]=true,["VIPKEY_P5C_2A4_T4P"]=true,
    ["VIPKEY_8KU_TFH_GZV"]=true,["VIPKEY_FT9_VJH_SSR"]=true,
    ["VIPKEY_K72_KTL_USF"]=true,["VIPKEY_YFJ_JGE_ZUH"]=true,
    ["VIPKEY_GJ4_LYZ_5WM"]=true,["VIPKEY_CBA_BCC_Z7P"]=true,
    ["VIPKEY_UUK_8DN_44S"]=true,["VIPKEY_NAB_FH3_PFR"]=true,
    ["VIPKEY_NXA_44C_NF5"]=true,
}

local function LoadUsedVips()
    local used = {}
    local ok, data = pcall(function() return readfile(USED_VIP_FILE) end)
    if ok and data and data ~= "" then
        for key in string.gmatch(data, "[^|]+") do used[string.upper(key)] = true end
    end
    return used
end
local function MarkVipUsed(key)
    local used = LoadUsedVips(); used[string.upper(key)] = true
    local list = {}; for k in pairs(used) do table.insert(list, k) end
    pcall(function() writefile(USED_VIP_FILE, table.concat(list, "|")) end)
end
local function IsVipUsed(key) return LoadUsedVips()[string.upper(key)] == true end
local function CountUsedVips()
    local c = 0; for _ in pairs(LoadUsedVips()) do c = c + 1 end; return c
end
local function SaveFreeKey(key, exp)
    pcall(function() writefile(FREE_KEY_FILE, string.upper(key).."|"..tostring(exp)) end)
end
local function LoadFreeKey()
    local ok, data = pcall(function() return readfile(FREE_KEY_FILE) end)
    if ok and data and data ~= "" then
        local p = string.split(data, "|"); if #p == 2 then return p[1], tonumber(p[2]) end
    end
    return nil, nil
end
local function ClearFreeKey() pcall(function() writefile(FREE_KEY_FILE, "") end) end
local function SaveRememberedKey(k, t) pcall(function() writefile(REMEMBER_FILE, string.upper(k).."|"..t) end) end
local function LoadRememberedKey()
    local ok, data = pcall(function() return readfile(REMEMBER_FILE) end)
    if ok and data and data ~= "" then
        local p = string.split(data, "|"); if #p == 2 then return p[1], p[2] end
    end
    return nil, nil
end
local function ClearRememberedKey() pcall(function() writefile(REMEMBER_FILE, "") end) end

local function ShowKeyGate(onSuccess)
    local CoreGui = game:GetService("CoreGui")
    pcall(function()
        local old = CoreGui:FindFirstChild("VAEHXCLOUD_KEY"); if old then old:Destroy() end
    end)
    local rem, remT = LoadRememberedKey()
    if rem and remT == "VIP" and VIP_KEYS[rem] then onSuccess() return end
    if rem and remT == "FREE" then
        local sf, exp = LoadFreeKey()
        if sf and string.upper(sf) == rem and exp and os.time() < exp then onSuccess() return
        else ClearRememberedKey(); ClearFreeKey() end
    end

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "VAEHXCLOUD_KEY"; KeyGui.ResetOnSpawn = false
    KeyGui.IgnoreGuiInset = true; KeyGui.DisplayOrder = 1000
    pcall(function() KeyGui.Parent = CoreGui end)

    local Overlay = Instance.new("Frame", KeyGui)
    Overlay.Size = UDim2.new(1,0,1,0)
    Overlay.BackgroundColor3 = Color3.fromRGB(8,4,16); Overlay.BorderSizePixel = 0

    local Card = Instance.new("Frame", Overlay)
    Card.Size = UDim2.new(0,340,0,380); Card.Position = UDim2.new(0.5,-170,0.5,-190)
    Card.BackgroundColor3 = Color3.fromRGB(18,10,32); Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0,14)
    local stroke = Instance.new("UIStroke", Card)
    stroke.Color = Color3.fromRGB(168,85,247); stroke.Thickness = 1.5

    local function lbl(text,y,size,color)
        local l = Instance.new("TextLabel", Card)
        l.Size = UDim2.new(1,-24,0,size+6); l.Position = UDim2.new(0,12,0,y)
        l.BackgroundTransparency = 1; l.Text = text; l.TextSize = size
        l.Font = Enum.Font.GothamBold; l.TextColor3 = color
        return l
    end
    lbl("⚡  VAEH X CLOUD", 18, 20, Color3.fromRGB(255,255,255))
    lbl("VIP / FREEKEY  •  MOBILE", 48, 12, Color3.fromRGB(180,120,255))

    local function mkbtn(text,y)
        local b = Instance.new("TextButton", Card)
        b.Size = UDim2.new(1,-24,0,38); b.Position = UDim2.new(0,12,0,y)
        b.BackgroundColor3 = Color3.fromRGB(32,18,55); b.Text = text
        b.TextColor3 = Color3.fromRGB(235,225,255); b.TextSize = 12
        b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end
    local Opt1 = mkbtn("①  JOIN DISCORD", 90)
    Opt1.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
        Opt1.Text = "✓  LINK COPIED"
    end)
    local Opt2 = mkbtn("②  DOWNLOAD APK FROM DISCORD", 138)
    Opt2.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
        Opt2.Text = "✓  LINK COPIED"
    end)
    lbl("③  PASTE KEY (VIPKEY / FREEKEY)", 190, 12, Color3.fromRGB(200,190,230))

    local KeyBox = Instance.new("TextBox", Card)
    KeyBox.Size = UDim2.new(1,-24,0,40); KeyBox.Position = UDim2.new(0,12,0,220)
    KeyBox.BackgroundColor3 = Color3.fromRGB(10,6,18)
    KeyBox.PlaceholderText = "VIPKEY_... or FREEKEY_..."
    KeyBox.PlaceholderColor3 = Color3.fromRGB(110,90,140)
    KeyBox.Text = ""; KeyBox.TextSize = 14; KeyBox.Font = Enum.Font.GothamBold
    KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
    KeyBox.BorderSizePixel = 0; KeyBox.ClearTextOnFocus = false
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0,8)

    local remember = true
    local RemBtn = Instance.new("TextButton", Card)
    RemBtn.Size = UDim2.new(1,-24,0,28); RemBtn.Position = UDim2.new(0,12,0,268)
    RemBtn.BackgroundTransparency = 1; RemBtn.Text = "☑  Remember this key"
    RemBtn.TextColor3 = Color3.fromRGB(190,170,230); RemBtn.TextSize = 12
    RemBtn.Font = Enum.Font.GothamBold; RemBtn.TextXAlignment = Enum.TextXAlignment.Left
    RemBtn.MouseButton1Click:Connect(function()
        remember = not remember
        RemBtn.Text = (remember and "☑  " or "☐  ").."Remember this key"
    end)

    local Status = lbl("", 300, 11, Color3.fromRGB(255,90,90))
    Status.Text = (25 - CountUsedVips()).." VIP left  •  FREEKEY = 12H"

    local Enter = Instance.new("TextButton", Card)
    Enter.Size = UDim2.new(1,-24,0,42); Enter.Position = UDim2.new(0,12,0,325)
    Enter.BackgroundColor3 = Color3.fromRGB(140,55,255); Enter.Text = "ENTER KEY"
    Enter.TextColor3 = Color3.fromRGB(255,255,255); Enter.TextSize = 14
    Enter.Font = Enum.Font.GothamBold; Enter.BorderSizePixel = 0
    Instance.new("UICorner", Enter).CornerRadius = UDim.new(0,8)

    local function accept()
        Status.Text = "✓ ACCESS GRANTED"; Status.TextColor3 = Color3.fromRGB(80,230,140)
        Enter.Text = "LOADING..."; task.wait(0.55); KeyGui:Destroy(); onSuccess()
    end
    local function check()
        local input = string.upper((KeyBox.Text or ""):gsub("%s+",""))
        if input == "" then Status.Text = "✗ ENTER A KEY FIRST"; Status.TextColor3 = Color3.fromRGB(255,90,90) return end
        local isVip = string.match(input, "^VIPKEY_[%w]+_[%w]+_[%w]+$")
        local isFree = string.match(input, "^FREEKEY_[%w]+_[%w]+_[%w]+$")
        if not isVip and not isFree then Status.Text = "✗ INVALID FORMAT"; Status.TextColor3 = Color3.fromRGB(255,90,90) return end
        if isVip then
            if not VIP_KEYS[input] then Status.Text = "✗ INVALID VIP KEY"; Status.TextColor3 = Color3.fromRGB(255,90,90) return end
            local used = IsVipUsed(input); local r = select(1, LoadRememberedKey())
            if used and r ~= input then Status.Text = "✗ VIP KEY ALREADY USED"; Status.TextColor3 = Color3.fromRGB(255,90,90) return end
            if not used and CountUsedVips() >= 25 then Status.Text = "✗ ALL VIP KEYS USED"; Status.TextColor3 = Color3.fromRGB(255,90,90) return end
            if not used then MarkVipUsed(input) end
            if remember then SaveRememberedKey(input, "VIP") else ClearRememberedKey() end
            accept(); return
        end
        if isFree then
            local sv, exp = LoadFreeKey()
            if sv and string.upper(sv) == input and exp then
                if os.time() > exp then Status.Text = "✗ FREEKEY EXPIRED"; Status.TextColor3 = Color3.fromRGB(255,90,90); ClearFreeKey(); return end
            else SaveFreeKey(input, os.time() + FREE_EXPIRE_H * 3600) end
            if remember then SaveRememberedKey(input, "FREE") else ClearRememberedKey() end
            accept()
        end
    end
    Enter.MouseButton1Click:Connect(check)
    KeyBox.FocusLost:Connect(function(e) if e then check() end end)
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
        distance = true, chams = true, chams_color = Color3.fromRGB(160,50,255), team_check = true,
    },
    fps = { booster = false, show_fps = true },
}

local FovCircle = Drawing.new("Circle")
FovCircle.Filled = false; FovCircle.Thickness = 1.5; FovCircle.NumSides = 64
FovCircle.Color = Color3.fromRGB(170,60,255); FovCircle.Transparency = 0.55
FovCircle.Radius = CFG.aimbot.fov; FovCircle.Visible = false

local LockLine = Drawing.new("Line")
LockLine.Thickness = 1.4; LockLine.Color = Color3.fromRGB(255,60,80)
LockLine.Transparency = 0.3; LockLine.Visible = false

local LockDot = Drawing.new("Circle")
LockDot.Filled = true; LockDot.Radius = 5
LockDot.Color = Color3.fromRGB(255,60,80); LockDot.Visible = false

local ESPObjects, PrevPos = {}, {}

local function ClearESP(player)
    local data = ESPObjects[player]; if not data then return end
    for _, obj in pairs(data) do
        if typeof(obj) == "Instance" then obj:Destroy()
        elseif typeof(obj) == "table" and obj.Remove then obj:Remove() end
    end
    ESPObjects[player] = nil
end

local function CreateESP(player)
    if ESPObjects[player] then return end
    local data = {}
    local box = Drawing.new("Square"); box.Thickness = 1.3; box.Filled = false
    box.Color = Color3.fromRGB(168,85,247); box.Transparency = 0.75; box.Visible = false; data.box = box
    local name = Drawing.new("Text"); name.Size = 14; name.Center = true; name.Outline = true
    name.Color = Color3.fromRGB(255,255,255); name.Visible = false; data.name = name
    local dist = Drawing.new("Text"); dist.Size = 12; dist.Center = true; dist.Outline = true
    dist.Color = Color3.fromRGB(170,150,200); dist.Visible = false; data.dist = dist
    local hbg = Drawing.new("Square"); hbg.Filled = true; hbg.Color = Color3.fromRGB(25,20,35); hbg.Visible = false; data.hbg = hbg
    local hfill = Drawing.new("Square"); hfill.Filled = true; hfill.Color = Color3.fromRGB(80,230,150); hfill.Visible = false; data.hfill = hfill
    local char = player.Character
    if char then
        local hl = Instance.new("Highlight")
        hl.FillColor = CFG.esp.chams_color; hl.OutlineColor = Color3.fromRGB(200,100,255)
        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.15
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = false; hl.Parent = char; data.chams = hl
    end
    ESPObjects[player] = data
end

local function Predicted(part, player)
    local id = player.UserId; local cur = part.Position
    if PrevPos[id] then
        local vel = (cur - PrevPos[id]) / 0.016; PrevPos[id] = cur
        return cur + vel * CFG.aimbot.predict_str
    end
    PrevPos[id] = cur; return cur
end
local function IsTeammate(p, check)
    if not check then return false end
    if LP.Team == nil or p.Team == nil then return false end
    return LP.Team == p.Team
end
local function HasWall(from, to, targetChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ig = {LP.Character}; if targetChar then table.insert(ig, targetChar) end
    params.FilterDescendantsInstances = ig; params.IgnoreWater = true
    return workspace:Raycast(from, to - from, params) ~= nil
end
local function GetClosestTarget()
    local best, bestDist, bestPlayer = nil, math.huge, nil
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local camPos = Camera.CFrame.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if IsTeammate(p, CFG.aimbot.team_check) then continue end
        local char = p.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(CFG.aimbot.bone) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        if CFG.aimbot.wall_check and HasWall(camPos, part.Position, char) then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist <= CFG.aimbot.fov and dist < bestDist then best, bestDist, bestPlayer = part, dist, p end
    end
    return best, bestDist, bestPlayer
end

-- ═══════════════════════════════════════════════════════════════
-- FLUENTPRO (video style)
-- ═══════════════════════════════════════════════════════════════

local THEME_LIST = {
    "Galaxy Purple", "Cosmic Violet", "Neon Purple", "Deep Violet",
    "Velvet", "AMOLED", "Charcoal", "Ash Gray",
    "Arctic Frost", "Pearl White", "Midnight Blue", "Royal Blue",
    "Deep Ocean", "Cyanic", "Neon Cyber", "NeonBlue",
    "EmeraldDark", "Blood Red", "Amber Glow", "Orange",
    "Sunset", "Cotton Candy", "RGB", "Dark", "Darker", "Light", "Aqua", "Amethyst", "Rose",
}

local function loadMain()
    local Fluent
    -- FluentPro first (matches the video)
    local ok = pcall(function()
        Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"))()
    end)
    if not ok or not Fluent then
        ok = pcall(function()
            Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/1.6.0/FluentPro.lua"))()
        end)
    end
    if not ok or not Fluent then
        ok = pcall(function()
            Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        end)
    end
    if not Fluent then
        warn("[Vaeh X Cloud] Failed to load FluentPro")
        return
    end

    -- Register Velvet if custom themes supported
    pcall(function()
        if Fluent.RegisterCustomTheme then
            Fluent:RegisterCustomTheme("Velvet", {
                Accent = Color3.fromRGB(168, 85, 247),
                AcrylicMain = Color3.fromRGB(18, 10, 28),
                Acrylic = Color3.fromRGB(28, 16, 42),
                Text = Color3.fromRGB(245, 240, 255),
                SubText = Color3.fromRGB(170, 150, 200),
            })
        end
        if Fluent.AddTheme then
            Fluent:AddTheme("Velvet", {
                Accent = Color3.fromRGB(168, 85, 247),
                AcrylicMain = Color3.fromRGB(18, 10, 28),
            })
        end
    end)

    local Window = Fluent:CreateWindow({
        Title = "Vaeh X Cloud",
        SubTitle = "Mobile Only  •  Velvet",
        TabWidth = 150,
        Size = UDim2.fromOffset(500, 380),
        Acrylic = true,          -- liquid glass / blur
        Theme = "Galaxy Purple", -- velvet-like default (from video)
        MinimizeKey = Enum.KeyCode.LeftControl,
        Search = true,
    })

    -- Mobile minimizer if available
    pcall(function()
        if Window.CreateMinimizer then
            Window:CreateMinimizer({
                Icon = "rbxassetid://109639117875913",
                Size = UDim2.fromOffset(56, 56),
                Position = UDim2.new(0, 14, 0.5, -28),
                Corner = 14,
                Draggable = true,
            })
        end
    end)

    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
        ESP    = Window:AddTab({ Title = "ESP", Icon = "eye" }),
        Extra  = Window:AddTab({ Title = "Extra", Icon = "sparkles" }),
        FPS    = Window:AddTab({ Title = "FPS", Icon = "gauge" }),
        Theme  = Window:AddTab({ Title = "Theme", Icon = "palette" }),
        Config = Window:AddTab({ Title = "Config", Icon = "settings" }),
    }

    -- AIMBOT
    Tabs.Aimbot:AddToggle("AimEnabled", { Title = "Enable Aimbot", Default = CFG.aimbot.enabled, Callback = function(v) CFG.aimbot.enabled = v end })
    Tabs.Aimbot:AddToggle("TeamCheck", { Title = "Team Check", Description = "Ignore teammates", Default = CFG.aimbot.team_check, Callback = function(v) CFG.aimbot.team_check = v end })
    Tabs.Aimbot:AddToggle("WallCheck", { Title = "Wall Check", Description = "Only visible targets", Default = CFG.aimbot.wall_check, Callback = function(v) CFG.aimbot.wall_check = v end })
    Tabs.Aimbot:AddToggle("DrawFOV", { Title = "Draw FOV Circle", Default = CFG.aimbot.draw_fov, Callback = function(v) CFG.aimbot.draw_fov = v end })
    Tabs.Aimbot:AddDropdown("TargetPart", { Title = "Target Part", Values = {"Head","HumanoidRootPart"}, Default = CFG.aimbot.bone, Callback = function(v) CFG.aimbot.bone = v end })
    Tabs.Aimbot:AddSlider("FOVRadius", { Title = "FOV Radius", Default = CFG.aimbot.fov, Min = 40, Max = 400, Rounding = 0, Callback = function(v) CFG.aimbot.fov = v; FovCircle.Radius = v end })
    Tabs.Aimbot:AddSlider("Smoothness", { Title = "Smoothness", Default = CFG.aimbot.smooth, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) CFG.aimbot.smooth = v end })

    -- ESP
    Tabs.ESP:AddToggle("ESPEnabled", { Title = "Enable ESP", Default = CFG.esp.enabled, Callback = function(v) CFG.esp.enabled = v end })
    Tabs.ESP:AddToggle("ESPTeam", { Title = "Team Check", Default = CFG.esp.team_check, Callback = function(v) CFG.esp.team_check = v end })
    Tabs.ESP:AddToggle("ESPBoxes", { Title = "Boxes", Default = CFG.esp.boxes, Callback = function(v) CFG.esp.boxes = v end })
    Tabs.ESP:AddToggle("ESPNames", { Title = "Names", Default = CFG.esp.names, Callback = function(v) CFG.esp.names = v end })
    Tabs.ESP:AddToggle("ESPHealth", { Title = "Health Bars", Default = CFG.esp.health, Callback = function(v) CFG.esp.health = v end })
    Tabs.ESP:AddToggle("ESPDistance", { Title = "Distance", Default = CFG.esp.distance, Callback = function(v) CFG.esp.distance = v end })
    Tabs.ESP:AddToggle("ESPChams", { Title = "Chams", Default = CFG.esp.chams, Callback = function(v) CFG.esp.chams = v end })

    -- EXTRA
    Tabs.Extra:AddParagraph({ Title = "Silent & Automation", Content = "Advanced options" })
    Tabs.Extra:AddToggle("SilentAim", { Title = "Silent Aim", Default = CFG.aimbot.silent, Callback = function(v) CFG.aimbot.silent = v end })
    Tabs.Extra:AddToggle("AutoShoot", { Title = "Auto Shoot", Default = CFG.aimbot.auto_shoot, Callback = function(v) CFG.aimbot.auto_shoot = v end })
    Tabs.Extra:AddToggle("Prediction", { Title = "Prediction", Default = CFG.aimbot.predict, Callback = function(v) CFG.aimbot.predict = v end })
    Tabs.Extra:AddSlider("PredStr", { Title = "Prediction Strength", Default = CFG.aimbot.predict_str, Min = 0.01, Max = 0.5, Rounding = 2, Callback = function(v) CFG.aimbot.predict_str = v end })

    -- FPS
    Tabs.FPS:AddToggle("ShowFPS", { Title = "Show FPS Counter", Default = CFG.fps.show_fps, Callback = function(v) CFG.fps.show_fps = v end })
    Tabs.FPS:AddToggle("FPSBooster", {
        Title = "FPS Booster", Description = "Lower graphics",
        Default = CFG.fps.booster,
        Callback = function(v)
            CFG.fps.booster = v
            if v then
                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
                    for _, fx in ipairs(Lighting:GetChildren()) do
                        if fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect") or fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") then fx.Enabled = false end
                    end
                end)
            else
                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                    Lighting.GlobalShadows = true
                end)
            end
        end,
    })

    -- THEME TAB (separate from config) — like the video
    Tabs.Theme:AddParagraph({
        Title = "Interface Theme",
        Content = "Themes do NOT save with game config",
    })
    Tabs.Theme:AddDropdown("ThemeSelect", {
        Title = "Theme",
        Description = "Galaxy Purple / Velvet style default",
        Values = THEME_LIST,
        Default = "Galaxy Purple",
        Callback = function(theme)
            pcall(function()
                if Fluent.SetTheme then Fluent:SetTheme(theme)
                elseif Window.SetTheme then Window:SetTheme(theme) end
            end)
            Fluent:Notify({ Title = "Theme", Content = tostring(theme), Duration = 2 })
        end,
    })
    Tabs.Theme:AddToggle("AcrylicToggle", {
        Title = "Acrylic / Liquid Glass",
        Description = "Blur glass effect (needs graphics quality)",
        Default = true,
        Callback = function(v)
            pcall(function()
                if Fluent.ToggleAcrylic then Fluent:ToggleAcrylic(v) end
            end)
        end,
    })
    Tabs.Theme:AddToggle("TransparencyToggle", {
        Title = "Transparency",
        Description = "Make the interface transparent",
        Default = true,
        Callback = function(v)
            pcall(function()
                if Fluent.ToggleTransparency then Fluent:ToggleTransparency(v) end
            end)
        end,
    })
    Tabs.Theme:AddToggle("AnimatedWindow", {
        Title = "Animated Window",
        Description = "Shine / stroke animation on theme",
        Default = true,
        Callback = function() end,
    })

    -- CONFIG TAB (game only)
    Tabs.Config:AddParagraph({
        Title = "Game Config",
        Content = "Aimbot / ESP settings only — theme ignored",
    })
    Tabs.Config:AddButton({
        Title = "Save Config",
        Callback = function()
            local data = {
                aimbot = CFG.aimbot,
                esp = {
                    enabled = CFG.esp.enabled, boxes = CFG.esp.boxes, names = CFG.esp.names,
                    health = CFG.esp.health, distance = CFG.esp.distance, chams = CFG.esp.chams,
                    team_check = CFG.esp.team_check,
                },
                fps = CFG.fps,
            }
            local ok2 = pcall(function()
                writefile("vaehxcloud_config.json", HttpService:JSONEncode(data))
            end)
            Fluent:Notify({ Title = "Vaeh X Cloud", Content = ok2 and "Config saved!" or "Failed", Duration = 3 })
        end,
    })
    Tabs.Config:AddButton({
        Title = "Load Config",
        Callback = function()
            local ok2, raw = pcall(function() return readfile("vaehxcloud_config.json") end)
            if ok2 and raw then
                local s, dec = pcall(function() return HttpService:JSONDecode(raw) end)
                if s and type(dec) == "table" then
                    if dec.aimbot then for k,v in pairs(dec.aimbot) do if CFG.aimbot[k] ~= nil then CFG.aimbot[k] = v end end end
                    if dec.esp then for k,v in pairs(dec.esp) do if CFG.esp[k] ~= nil then CFG.esp[k] = v end end end
                    if dec.fps then for k,v in pairs(dec.fps) do if CFG.fps[k] ~= nil then CFG.fps[k] = v end end end
                    Fluent:Notify({ Title = "Vaeh X Cloud", Content = "Config loaded!", Duration = 3 })
                    return
                end
            end
            Fluent:Notify({ Title = "Vaeh X Cloud", Content = "No config found", Duration = 3 })
        end,
    })

    pcall(function() Window:SelectTab(1) end)

    Fluent:Notify({
        Title = "Vaeh X Cloud",
        Content = "FluentPro loaded — drag from title bar",
        Duration = 4,
    })

    -- FPS label
    local CoreGui = game:GetService("CoreGui")
    local FpsGui = Instance.new("TextLabel")
    FpsGui.Size = UDim2.new(0,90,0,22); FpsGui.Position = UDim2.new(0,8,0,8)
    FpsGui.BackgroundColor3 = Color3.fromRGB(12,8,18); FpsGui.BackgroundTransparency = 0.2
    FpsGui.TextColor3 = Color3.fromRGB(80,230,150); FpsGui.TextSize = 12
    FpsGui.Font = Enum.Font.GothamBold; FpsGui.Text = "FPS: --"
    FpsGui.Visible = CFG.fps.show_fps
    Instance.new("UICorner", FpsGui).CornerRadius = UDim.new(0,6)
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "VAEHXCLOUD_FPS"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.Parent = CoreGui; FpsGui.Parent = sg
    end)

    local fpsCounter, fpsLast = 0, tick()
    RunService.RenderStepped:Connect(function()
        fpsCounter = fpsCounter + 1
        if tick() - fpsLast >= 1 then
            local cur = fpsCounter; fpsCounter = 0; fpsLast = tick()
            FpsGui.Text = "FPS: "..cur
            FpsGui.TextColor3 = cur >= 50 and Color3.fromRGB(80,230,150)
                or (cur >= 30 and Color3.fromRGB(255,200,50) or Color3.fromRGB(230,60,60))
        end
        FpsGui.Visible = CFG.fps.show_fps

        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FovCircle.Position = center
        FovCircle.Visible = CFG.aimbot.enabled and CFG.aimbot.draw_fov

        if CFG.aimbot.enabled then
            local target, _, tPlayer = GetClosestTarget()
            if target and tPlayer then
                local aimPos = CFG.aimbot.predict and Predicted(target, tPlayer) or target.Position
                local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
                if onScreen then
                    if not CFG.aimbot.silent then
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, aimPos), CFG.aimbot.smooth)
                    end
                    LockLine.From = center; LockLine.To = Vector2.new(sp.X, sp.Y); LockLine.Visible = true
                    LockDot.Position = Vector2.new(sp.X, sp.Y); LockDot.Visible = true
                else LockLine.Visible = false; LockDot.Visible = false end
            else LockLine.Visible = false; LockDot.Visible = false end
        else LockLine.Visible = false; LockDot.Visible = false end

        if CFG.esp.enabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP then continue end
                if IsTeammate(p, CFG.esp.team_check) then ClearESP(p) continue end
                local char = p.Character; if not char then ClearESP(p) continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not hum or not root or hum.Health <= 0 then ClearESP(p) continue end
                if not ESPObjects[p] then CreateESP(p) end
                local data = ESPObjects[p]; if not data then continue end
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if not onScreen then
                    data.box.Visible = false; data.name.Visible = false; data.dist.Visible = false
                    data.hbg.Visible = false; data.hfill.Visible = false
                    if data.chams then data.chams.Enabled = false end
                    continue
                end
                local size = 2000 / pos.Z; local h, w = size * 1.8, size
                if CFG.esp.boxes then
                    data.box.Size = Vector2.new(w,h); data.box.Position = Vector2.new(pos.X-w/2, pos.Y-h/2); data.box.Visible = true
                else data.box.Visible = false end
                if CFG.esp.names then
                    data.name.Text = p.Name; data.name.Position = Vector2.new(pos.X, pos.Y-h/2-16); data.name.Visible = true
                else data.name.Visible = false end
                if CFG.esp.distance then
                    data.dist.Text = math.floor((root.Position - Camera.CFrame.Position).Magnitude).."m"
                    data.dist.Position = Vector2.new(pos.X, pos.Y+h/2+4); data.dist.Visible = true
                else data.dist.Visible = false end
                if CFG.esp.health then
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    data.hbg.Size = Vector2.new(3,h); data.hbg.Position = Vector2.new(pos.X-w/2-6, pos.Y-h/2); data.hbg.Visible = true
                    data.hfill.Size = Vector2.new(3, h*hp); data.hfill.Position = Vector2.new(pos.X-w/2-6, pos.Y-h/2+h*(1-hp))
                    data.hfill.Color = Color3.fromRGB(255*(1-hp), 255*hp, 40); data.hfill.Visible = true
                else data.hbg.Visible = false; data.hfill.Visible = false end
                if data.chams then
                    data.chams.Enabled = CFG.esp.chams
                    if not data.chams.Parent then data.chams.Parent = char end
                end
            end
        else
            for p in pairs(ESPObjects) do ClearESP(p) end
        end
    end)

    Players.PlayerRemoving:Connect(function(p) ClearESP(p); PrevPos[p.UserId] = nil end)
    LP.CharacterRemoving:Connect(function() PrevPos = {} end)
    print("[Vaeh X Cloud] FluentPro loaded")
end

ShowKeyGate(loadMain)

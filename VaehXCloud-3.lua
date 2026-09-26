--[[
    Vaeh X Cloud — Mobile Only
    WindUI Library + VIP/FREE Key System
    Config Save/Load + Gradient Themes + Custom Background

    ── BACKGROUND IMAGE SETUP ──────────────────────────────────────
    The logo background requires a Roblox asset ID.
    Steps:
      1. Go to create.roblox.com → Decals → Upload
      2. Upload your logo image
      3. Copy the asset ID from the URL (the number)
      4. Paste it in: BG_ASSET_ID below
    ────────────────────────────────────────────────────────────────
]]

local BG_ASSET_ID = "rbxassetid://YOUR_ASSET_ID_HERE"
-- ↑ Replace YOUR_ASSET_ID_HERE with the number from Roblox after uploading your logo

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if not isMobile then
    warn("[Vaeh X Cloud] Mobile devices only. Unloading.")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local USED_VIP_FILE = "cloudbot_used_vips.txt"
local FREE_KEY_FILE = "cloudbot_freekey.txt"
local REMEMBER_FILE = "cloudbot_remember.txt"
local CONFIG_FILE   = "cloudbot_config.json"
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
    local used={}
    local ok,data=pcall(function() return readfile(USED_VIP_FILE) end)
    if ok and data and data~="" then
        for key in string.gmatch(data,"[^|]+") do used[string.upper(key)]=true end
    end
    return used
end
local function MarkVipUsed(key)
    local used=LoadUsedVips(); used[string.upper(key)]=true
    local list={}; for k in pairs(used) do table.insert(list,k) end
    pcall(function() writefile(USED_VIP_FILE,table.concat(list,"|")) end)
end
local function IsVipUsed(key)   return LoadUsedVips()[string.upper(key)]==true end
local function CountUsedVips()
    local c=0; for _ in pairs(LoadUsedVips()) do c=c+1 end; return c
end
local function SaveFreeKey(key,exp)
    pcall(function() writefile(FREE_KEY_FILE,string.upper(key).."|"..tostring(exp)) end)
end
local function LoadFreeKey()
    local ok,data=pcall(function() return readfile(FREE_KEY_FILE) end)
    if ok and data and data~="" then
        local p=string.split(data,"|"); if #p==2 then return p[1],tonumber(p[2]) end
    end
    return nil,nil
end
local function ClearFreeKey()       pcall(function() writefile(FREE_KEY_FILE,"") end) end
local function SaveRememberedKey(k,t) pcall(function() writefile(REMEMBER_FILE,string.upper(k).."|"..t) end) end
local function LoadRememberedKey()
    local ok,data=pcall(function() return readfile(REMEMBER_FILE) end)
    if ok and data and data~="" then
        local p=string.split(data,"|"); if #p==2 then return p[1],p[2] end
    end
    return nil,nil
end
local function ClearRememberedKey() pcall(function() writefile(REMEMBER_FILE,"") end) end

local function ShowKeyGate(onSuccess)
    local CoreGui=game:GetService("CoreGui")
    pcall(function()
        local old=CoreGui:FindFirstChild("VAEHXCLOUD_KEY"); if old then old:Destroy() end
    end)
    local rem,remT=LoadRememberedKey()
    if rem and remT=="VIP" and VIP_KEYS[rem] then onSuccess() return end
    if rem and remT=="FREE" then
        local sf,exp=LoadFreeKey()
        if sf and string.upper(sf)==rem and exp and os.time()<exp then onSuccess() return
        else ClearRememberedKey() ClearFreeKey() end
    end

    local KeyGui=Instance.new("ScreenGui")
    KeyGui.Name="VAEHXCLOUD_KEY"; KeyGui.ResetOnSpawn=false
    KeyGui.IgnoreGuiInset=true; KeyGui.DisplayOrder=1000
    pcall(function() KeyGui.Parent=CoreGui end)

    local Overlay=Instance.new("Frame",KeyGui)
    Overlay.Size=UDim2.new(1,0,1,0)
    Overlay.BackgroundColor3=Color3.fromRGB(5,3,10); Overlay.BorderSizePixel=0

    -- Background image on key gate overlay
    if BG_ASSET_ID~="rbxassetid://YOUR_ASSET_ID_HERE" then
        local bgImg=Instance.new("ImageLabel",Overlay)
        bgImg.Size=UDim2.new(1,0,1,0); bgImg.Position=UDim2.new(0,0,0,0)
        bgImg.BackgroundTransparency=1; bgImg.Image=BG_ASSET_ID
        bgImg.ScaleType=Enum.ScaleType.Fit; bgImg.ImageTransparency=0.45
        bgImg.ZIndex=0
    end

    local Card=Instance.new("Frame",Overlay)
    Card.Size=UDim2.new(0,340,0,380); Card.Position=UDim2.new(0.5,-170,0.5,-190)
    Card.BackgroundColor3=Color3.fromRGB(8,5,16); Card.BorderSizePixel=0; Card.ZIndex=2
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,14)
    local st=Instance.new("UIStroke",Card); st.Color=Color3.fromRGB(150,80,255); st.Thickness=1.5

    local function lbl(text,y,size,color)
        local l=Instance.new("TextLabel",Card)
        l.Size=UDim2.new(1,-24,0,size+6); l.Position=UDim2.new(0,12,0,y)
        l.BackgroundTransparency=1; l.Text=text; l.TextSize=size
        l.Font=Enum.Font.GothamBold; l.TextColor3=color; l.ZIndex=3
        return l
    end
    lbl("⚡  VAEH X CLOUD",18,22,Color3.fromRGB(255,255,255))
    lbl("VIP / FREEKEY  •  MOBILE",48,12,Color3.fromRGB(160,100,255))

    local function mkbtn(text,y)
        local b=Instance.new("TextButton",Card)
        b.Size=UDim2.new(1,-24,0,38); b.Position=UDim2.new(0,12,0,y)
        b.BackgroundColor3=Color3.fromRGB(20,12,35); b.Text=text
        b.TextColor3=Color3.fromRGB(230,220,255); b.TextSize=12
        b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=3
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        local bs=Instance.new("UIStroke",b); bs.Color=Color3.fromRGB(100,50,200); bs.Thickness=1
        return b
    end
    local Opt1=mkbtn("①  JOIN DISCORD",90)
    Opt1.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
        Opt1.Text="✓  LINK COPIED"
    end)
    local Opt2=mkbtn("②  DOWNLOAD APK FROM DISCORD",138)
    Opt2.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
        Opt2.Text="✓  LINK COPIED"
    end)
    lbl("③  PASTE KEY (VIPKEY / FREEKEY)",190,12,Color3.fromRGB(200,190,230))

    local KeyBox=Instance.new("TextBox",Card)
    KeyBox.Size=UDim2.new(1,-24,0,40); KeyBox.Position=UDim2.new(0,12,0,220)
    KeyBox.BackgroundColor3=Color3.fromRGB(6,4,12)
    KeyBox.PlaceholderText="VIPKEY_... or FREEKEY_..."
    KeyBox.PlaceholderColor3=Color3.fromRGB(100,90,130)
    KeyBox.Text=""; KeyBox.TextSize=14; KeyBox.Font=Enum.Font.GothamBold
    KeyBox.TextColor3=Color3.fromRGB(255,255,255)
    KeyBox.BorderSizePixel=0; KeyBox.ClearTextOnFocus=false; KeyBox.ZIndex=3
    Instance.new("UICorner",KeyBox).CornerRadius=UDim.new(0,8)
    local ks=Instance.new("UIStroke",KeyBox); ks.Color=Color3.fromRGB(100,50,200); ks.Thickness=1

    local remember=true
    local RemBtn=Instance.new("TextButton",Card)
    RemBtn.Size=UDim2.new(1,-24,0,28); RemBtn.Position=UDim2.new(0,12,0,268)
    RemBtn.BackgroundTransparency=1; RemBtn.Text="☑  Remember this key"
    RemBtn.TextColor3=Color3.fromRGB(180,160,220); RemBtn.TextSize=12
    RemBtn.Font=Enum.Font.GothamBold; RemBtn.TextXAlignment=Enum.TextXAlignment.Left; RemBtn.ZIndex=3
    RemBtn.MouseButton1Click:Connect(function()
        remember=not remember
        RemBtn.Text=(remember and "☑  " or "☐  ").."Remember this key"
    end)

    local Status=lbl("",300,11,Color3.fromRGB(255,90,90))
    Status.Text=(25-CountUsedVips()).." VIP left  •  FREEKEY = 12H"

    local Enter=Instance.new("TextButton",Card)
    Enter.Size=UDim2.new(1,-24,0,42); Enter.Position=UDim2.new(0,12,0,325)
    Enter.BackgroundColor3=Color3.fromRGB(120,40,230); Enter.Text="ENTER KEY"
    Enter.TextColor3=Color3.fromRGB(255,255,255); Enter.TextSize=14
    Enter.Font=Enum.Font.GothamBold; Enter.BorderSizePixel=0; Enter.ZIndex=3
    Instance.new("UICorner",Enter).CornerRadius=UDim.new(0,8)

    local function accept()
        Status.Text="✓ ACCESS GRANTED"; Status.TextColor3=Color3.fromRGB(80,230,140)
        Enter.Text="LOADING..."; task.wait(0.6); KeyGui:Destroy(); onSuccess()
    end
    local function check()
        local input=string.upper((KeyBox.Text or ""):gsub("%s+",""))
        if input=="" then Status.Text="✗ ENTER A KEY FIRST"; Status.TextColor3=Color3.fromRGB(255,90,90) return end
        local isVip=string.match(input,"^VIPKEY_[%w]+_[%w]+_[%w]+$")
        local isFree=string.match(input,"^FREEKEY_[%w]+_[%w]+_[%w]+$")
        if not isVip and not isFree then Status.Text="✗ INVALID FORMAT"; Status.TextColor3=Color3.fromRGB(255,90,90) return end
        if isVip then
            if not VIP_KEYS[input] then Status.Text="✗ INVALID VIP KEY"; Status.TextColor3=Color3.fromRGB(255,90,90) return end
            local used=IsVipUsed(input); local r=select(1,LoadRememberedKey())
            if used and r~=input then Status.Text="✗ VIP KEY ALREADY USED"; Status.TextColor3=Color3.fromRGB(255,90,90) return end
            if not used and CountUsedVips()>=25 then Status.Text="✗ ALL VIP KEYS USED"; Status.TextColor3=Color3.fromRGB(255,90,90) return end
            if not used then MarkVipUsed(input) end
            if remember then SaveRememberedKey(input,"VIP") else ClearRememberedKey() end
            accept() return
        end
        if isFree then
            local sv,exp=LoadFreeKey()
            if sv and string.upper(sv)==input and exp then
                if os.time()>exp then Status.Text="✗ FREEKEY EXPIRED"; Status.TextColor3=Color3.fromRGB(255,90,90) ClearFreeKey() return end
            else SaveFreeKey(input,os.time()+FREE_EXPIRE_H*3600) end
            if remember then SaveRememberedKey(input,"FREE") else ClearRememberedKey() end
            accept()
        end
    end
    Enter.MouseButton1Click:Connect(check)
    KeyBox.FocusLost:Connect(function(e) if e then check() end end)
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════

local CFG = {
    aimbot = {
        enabled=true, bone="Head", smooth=0.35, fov=120,
        predict=true, predict_str=0.09, team_check=true, wall_check=false,
        silent=true, auto_shoot=true, draw_fov=true,
    },
    esp = {
        enabled=false, boxes=true, names=true, health=true,
        distance=true, chams=true, chams_color=Color3.fromRGB(160,50,255), team_check=true,
    },
    fps={ booster=false, show_fps=true },
}

local function SaveConfig()
    local data={
        aimbot={
            enabled=CFG.aimbot.enabled, bone=CFG.aimbot.bone, smooth=CFG.aimbot.smooth,
            fov=CFG.aimbot.fov, predict=CFG.aimbot.predict, predict_str=CFG.aimbot.predict_str,
            team_check=CFG.aimbot.team_check, wall_check=CFG.aimbot.wall_check,
            silent=CFG.aimbot.silent, auto_shoot=CFG.aimbot.auto_shoot, draw_fov=CFG.aimbot.draw_fov,
        },
        esp={
            enabled=CFG.esp.enabled, boxes=CFG.esp.boxes, names=CFG.esp.names,
            health=CFG.esp.health, distance=CFG.esp.distance, chams=CFG.esp.chams,
            team_check=CFG.esp.team_check,
        },
        fps={booster=CFG.fps.booster, show_fps=CFG.fps.show_fps},
    }
    return pcall(function() writefile(CONFIG_FILE,HttpService:JSONEncode(data)) end)
end

local function LoadConfig()
    local ok,raw=pcall(function() return readfile(CONFIG_FILE) end)
    if not ok or not raw or raw=="" then return false end
    local s,dec=pcall(function() return HttpService:JSONDecode(raw) end)
    if not s or type(dec)~="table" then return false end
    if dec.aimbot then for k,v in pairs(dec.aimbot) do if CFG.aimbot[k]~=nil then CFG.aimbot[k]=v end end end
    if dec.esp    then for k,v in pairs(dec.esp)    do if CFG.esp[k]   ~=nil then CFG.esp[k]   =v end end end
    if dec.fps    then for k,v in pairs(dec.fps)    do if CFG.fps[k]   ~=nil then CFG.fps[k]   =v end end end
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- DRAWINGS
-- ═══════════════════════════════════════════════════════════════

local FovCircle=Drawing.new("Circle")
FovCircle.Filled=false; FovCircle.Thickness=1.5; FovCircle.NumSides=64
FovCircle.Color=Color3.fromRGB(170,60,255); FovCircle.Transparency=0.55
FovCircle.Radius=CFG.aimbot.fov; FovCircle.Visible=false

local LockLine=Drawing.new("Line")
LockLine.Thickness=1.4; LockLine.Color=Color3.fromRGB(255,60,80)
LockLine.Transparency=0.3; LockLine.Visible=false

local LockDot=Drawing.new("Circle")
LockDot.Filled=true; LockDot.Radius=5
LockDot.Color=Color3.fromRGB(255,60,80); LockDot.Visible=false

-- ═══════════════════════════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════════════════════════

local ESPObjects,PrevPos={},{}

local function ClearESP(player)
    local data=ESPObjects[player]; if not data then return end
    for _,obj in pairs(data) do
        if typeof(obj)=="Instance" then obj:Destroy()
        elseif typeof(obj)=="table" and obj.Remove then obj:Remove() end
    end
    ESPObjects[player]=nil
end

local function CreateESP(player)
    if ESPObjects[player] then return end
    local data={}
    local box=Drawing.new("Square"); box.Thickness=1.3; box.Filled=false
    box.Color=Color3.fromRGB(168,85,247); box.Transparency=0.75; box.Visible=false; data.box=box
    local name=Drawing.new("Text"); name.Size=14; name.Center=true; name.Outline=true
    name.Color=Color3.fromRGB(255,255,255); name.Visible=false; data.name=name
    local dist=Drawing.new("Text"); dist.Size=12; dist.Center=true; dist.Outline=true
    dist.Color=Color3.fromRGB(170,150,200); dist.Visible=false; data.dist=dist
    local hbg=Drawing.new("Square"); hbg.Filled=true; hbg.Color=Color3.fromRGB(25,20,35); hbg.Visible=false; data.hbg=hbg
    local hfill=Drawing.new("Square"); hfill.Filled=true; hfill.Color=Color3.fromRGB(80,230,150); hfill.Visible=false; data.hfill=hfill
    local char=player.Character
    if char then
        local hl=Instance.new("Highlight")
        hl.FillColor=CFG.esp.chams_color; hl.OutlineColor=Color3.fromRGB(200,100,255)
        hl.FillTransparency=0.5; hl.OutlineTransparency=0.15
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled=false; hl.Parent=char; data.chams=hl
    end
    ESPObjects[player]=data
end

-- ═══════════════════════════════════════════════════════════════
-- GAME LOGIC
-- ═══════════════════════════════════════════════════════════════

local function Predicted(part,player)
    local id=player.UserId; local cur=part.Position
    if PrevPos[id] then
        local vel=(cur-PrevPos[id])/0.016; PrevPos[id]=cur
        return cur+vel*CFG.aimbot.predict_str
    end
    PrevPos[id]=cur; return cur
end
local function IsTeammate(p,check)
    if not check then return false end
    if LP.Team==nil or p.Team==nil then return false end
    return LP.Team==p.Team
end
local function HasWall(from,to,targetChar)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    local ig={LP.Character}; if targetChar then table.insert(ig,targetChar) end
    params.FilterDescendantsInstances=ig; params.IgnoreWater=true
    return workspace:Raycast(from,to-from,params)~=nil
end
local function GetClosestTarget()
    local best,bestDist,bestPlayer=nil,math.huge,nil
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local camPos=Camera.CFrame.Position
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if IsTeammate(p,CFG.aimbot.team_check) then continue end
        local char=p.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local part=char:FindFirstChild(CFG.aimbot.bone) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        if CFG.aimbot.wall_check and HasWall(camPos,part.Position,char) then continue end
        local sp,onScreen=Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if dist<=CFG.aimbot.fov and dist<bestDist then best,bestDist,bestPlayer=part,dist,p end
    end
    return best,bestDist,bestPlayer
end

-- ═══════════════════════════════════════════════════════════════
-- GRADIENTS
-- ═══════════════════════════════════════════════════════════════

local GRADIENTS={
    ["🌌 Midnight"]={"0F2027","203A43","2C5364"},
    ["🌊 Ocean Blue"]={"2193B0","6DD5ED"},
    ["🔥 Fire"]={"FF512F","F09819"},
    ["🌅 Sunset"]={"FF512F","DD2476"},
    ["💜 Purple Dream"]={"7F00FF","E100FF"},
    ["🌸 Pink Glow"]={"FF758C","FF7EB3"},
    ["🌿 Forest"]={"134E5E","71B280"},
    ["⚡ Electric"]={"00F2FE","4FACFE"},
    ["🍭 Candy"]={"FC5C7D","6A82FB"},
    ["🧊 Ice"]={"74EBD5","ACB6E5"},
    ["🖤 Dark Neon"]={"232526","414345"},
    ["💚 Toxic"]={"56AB2F","A8E063"},
    ["🌈 Rainbow"]={"FF0000","FF00FF"},
    ["👑 Royal"]={"141E30","243B55"},
    ["☄️ Cosmic"]={"41295A","2F0743"},
    ["🌙 Night Sky"]={"0F0C29","302B63","24243E"},
    ["🍊 Tangerine"]={"FF8008","FFC837"},
    ["🌊 Aqua"]={"00C6FF","0072FF"},
    ["💎 Crystal"]={"8EC5FC","E0C3FC"},
    ["🩸 Crimson"]={"8E0E00","1F1C18"},
    ["🌺 Flamingo"]={"F953C6","B91D73"},
    ["🌱 Mint"]={"00B09B","96C93D"},
    ["🟣 Violet"]={"4776E6","8E54E9"},
    ["☀️ Golden"]={"F7971E","FFD200"},
    ["🛸 Cyberpunk"]={"00F260","0575E6"},
}
local GRADIENT_NAMES={
    "None",
    "🌌 Midnight","🌊 Ocean Blue","🔥 Fire","🌅 Sunset",
    "💜 Purple Dream","🌸 Pink Glow","🌿 Forest","⚡ Electric",
    "🍭 Candy","🧊 Ice","🖤 Dark Neon","💚 Toxic",
    "🌈 Rainbow","👑 Royal","☄️ Cosmic","🌙 Night Sky",
    "🍊 Tangerine","🌊 Aqua","💎 Crystal","🩸 Crimson",
    "🌺 Flamingo","🌱 Mint","🟣 Violet","☀️ Golden","🛸 Cyberpunk",
}
local function BuildColorSeq(hexArr)
    local kps={}; local n=#hexArr
    for i,hex in ipairs(hexArr) do
        local pos=(i==1) and 0 or (i==n) and 1 or (i-1)/(n-1)
        table.insert(kps,ColorSequenceKeypoint.new(pos,Color3.fromHex(hex)))
    end
    return ColorSequence.new(kps)
end

-- ═══════════════════════════════════════════════════════════════
-- BACKGROUND INJECTOR
-- ═══════════════════════════════════════════════════════════════

local function InjectBackground(parentFrame)
    if BG_ASSET_ID=="rbxassetid://YOUR_ASSET_ID_HERE" then return end
    pcall(function()
        -- Dark overlay first (behind content, above game)
        local overlay=Instance.new("Frame",parentFrame)
        overlay.Size=UDim2.new(1,0,1,0)
        overlay.BackgroundColor3=Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency=0.35
        overlay.BorderSizePixel=0
        overlay.ZIndex=parentFrame.ZIndex

        -- Logo image centered
        local bg=Instance.new("ImageLabel",parentFrame)
        bg.Size=UDim2.new(1,0,1,0)
        bg.Position=UDim2.new(0,0,0,0)
        bg.BackgroundTransparency=1
        bg.Image=BG_ASSET_ID
        bg.ScaleType=Enum.ScaleType.Fit
        bg.ImageTransparency=0.18
        bg.ZIndex=parentFrame.ZIndex
        bg.SizeConstraint=Enum.SizeConstraint.RelativeYY

        -- Move bg and overlay to be behind children
        overlay.Parent=parentFrame
        bg.Parent=parentFrame
        overlay.ZIndex=1
        bg.ZIndex=1

        -- Push WindUI content above
        for _,child in ipairs(parentFrame:GetChildren()) do
            if child~=bg and child~=overlay then
                pcall(function() child.ZIndex=5 end)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- WINDUI MAIN
-- ═══════════════════════════════════════════════════════════════

local function loadMain()
    LoadConfig()

    local WindUI
    local ok=pcall(function()
        WindUI=loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not ok or not WindUI then
        ok=pcall(function()
            WindUI=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end)
    end
    if not WindUI then
        warn("[Vaeh X Cloud] Failed to load WindUI")
        return
    end

    pcall(function() WindUI:SetNotificationLower(true) end)

    local WIN_W, WIN_H = 500, 255

    local Window=WindUI:CreateWindow({
        Title       = "Vaeh X Cloud",
        Icon        = "zap",
        Author      = "Mobile Only",
        Folder      = "VaehXCloud",
        Size        = UDim2.fromOffset(WIN_W,WIN_H),
        MinSize     = Vector2.new(WIN_W,WIN_H),
        Transparent = true,
        Theme       = "Dark",
        Resizable   = false,
        HideSearchBar = true,
    })

    -- ── Background injection ─────────────────────────────────────
    -- Find the main window frame and inject the logo behind content
    local GradBg=nil
    local function FindWindowFrame()
        if GradBg and GradBg.Parent then return GradBg end
        local function scan(parent)
            for _,sg in ipairs(parent:GetChildren()) do
                if sg:IsA("ScreenGui")
                   and sg.Name~="VAEHXCLOUD_KEY"
                   and sg.Name~="VAEHXCLOUD_FPS" then
                    for _,f in ipairs(sg:GetDescendants()) do
                        if f:IsA("Frame")
                           and f.AbsoluteSize.X>200
                           and f.AbsoluteSize.Y>80 then
                            return f
                        end
                    end
                end
            end
            return nil
        end
        GradBg=scan(game:GetService("CoreGui")) or scan(LP.PlayerGui)
        return GradBg
    end

    task.defer(function()
        task.wait(0.2)
        local frame=FindWindowFrame()
        if frame then InjectBackground(frame) end
    end)

    -- ── Gradient apply ───────────────────────────────────────────
    local function ApplyGradient(name)
        pcall(function()
            local frame=FindWindowFrame(); if not frame then return end
            for _,ch in ipairs(frame:GetDescendants()) do
                if ch:IsA("UIGradient") then ch:Destroy() end
            end
            if name=="None" then return end
            local hexArr=GRADIENTS[name]; if not hexArr then return end
            local grad=Instance.new("UIGradient")
            grad.Color=BuildColorSeq(hexArr)
            grad.Rotation=135
            grad.Parent=frame
        end)
    end

    -- ── Tabs ─────────────────────────────────────────────────────
    local AimTab    = Window:Tab({ Title="Aimbot",       Icon="crosshair" })
    local EspTab    = Window:Tab({ Title="ESP",           Icon="eye"       })
    local ExtraTab  = Window:Tab({ Title="Extra Options", Icon="sparkles"  })
    local FpsTab    = Window:Tab({ Title="FPS",           Icon="gauge"     })
    local CfgTab    = Window:Tab({ Title="Config",        Icon="settings"  })

    -- ── AIMBOT ───────────────────────────────────────────────────
    AimTab:Toggle({ Title="Enable Aimbot",   Value=CFG.aimbot.enabled,    Callback=function(v) CFG.aimbot.enabled    =v end })
    AimTab:Toggle({ Title="Team Check",      Desc="Ignore teammates",
                                             Value=CFG.aimbot.team_check,  Callback=function(v) CFG.aimbot.team_check =v end })
    AimTab:Toggle({ Title="Wall Check",      Desc="Only target visible players",
                                             Value=CFG.aimbot.wall_check,  Callback=function(v) CFG.aimbot.wall_check =v end })
    AimTab:Toggle({ Title="Draw FOV Circle", Value=CFG.aimbot.draw_fov,   Callback=function(v) CFG.aimbot.draw_fov   =v end })
    AimTab:Dropdown({ Title="Target Part", Values={"Head","HumanoidRootPart"}, Value=CFG.aimbot.bone,
        Callback=function(v) CFG.aimbot.bone=v end })
    AimTab:Slider({ Title="FOV Radius", Step=1,
        Value={Min=40,Max=400,Default=CFG.aimbot.fov},
        Callback=function(v) CFG.aimbot.fov=v FovCircle.Radius=v end })
    AimTab:Slider({ Title="Smoothness", Step=0.01,
        Value={Min=0.05,Max=1,Default=CFG.aimbot.smooth},
        Callback=function(v) CFG.aimbot.smooth=v end })

    -- ── ESP ──────────────────────────────────────────────────────
    EspTab:Toggle({ Title="Enable ESP",   Value=CFG.esp.enabled,    Callback=function(v) CFG.esp.enabled    =v end })
    EspTab:Toggle({ Title="Team Check",   Value=CFG.esp.team_check, Callback=function(v) CFG.esp.team_check =v end })
    EspTab:Toggle({ Title="Boxes",        Value=CFG.esp.boxes,      Callback=function(v) CFG.esp.boxes      =v end })
    EspTab:Toggle({ Title="Names",        Value=CFG.esp.names,      Callback=function(v) CFG.esp.names      =v end })
    EspTab:Toggle({ Title="Health Bars",  Value=CFG.esp.health,     Callback=function(v) CFG.esp.health     =v end })
    EspTab:Toggle({ Title="Distance",     Value=CFG.esp.distance,   Callback=function(v) CFG.esp.distance   =v end })
    EspTab:Toggle({ Title="Chams",        Value=CFG.esp.chams,      Callback=function(v) CFG.esp.chams      =v end })

    -- ── EXTRA OPTIONS ─────────────────────────────────────────────
    ExtraTab:Paragraph({ Title="Silent & Automation", Desc="Advanced fire-control options" })
    ExtraTab:Toggle({ Title="Silent Aim",  Desc="Lock bullets without moving camera",
        Value=CFG.aimbot.silent,     Callback=function(v) CFG.aimbot.silent     =v end })
    ExtraTab:Toggle({ Title="Auto Shoot",  Desc="Fire automatically when target is locked",
        Value=CFG.aimbot.auto_shoot, Callback=function(v) CFG.aimbot.auto_shoot =v end })
    ExtraTab:Space()
    ExtraTab:Paragraph({ Title="Prediction", Desc="Lead target based on velocity" })
    ExtraTab:Toggle({ Title="Prediction",  Desc="Compensate for target movement",
        Value=CFG.aimbot.predict, Callback=function(v) CFG.aimbot.predict=v end })
    ExtraTab:Slider({ Title="Prediction Strength", Desc="How far ahead to lead",
        Step=0.01, Value={Min=0.01,Max=0.5,Default=CFG.aimbot.predict_str},
        Callback=function(v) CFG.aimbot.predict_str=v end })
    ExtraTab:Space()
    ExtraTab:Paragraph({ Title="Glass Output", Desc="Window transparency" })
    ExtraTab:Toggle({ Title="Glass / Transparent", Desc="Frosted-glass look", Value=true,
        Callback=function(v)
            pcall(function()
                if Window.ToggleTransparency then Window:ToggleTransparency(v) end
            end)
        end })

    -- ── FPS ──────────────────────────────────────────────────────
    FpsTab:Toggle({ Title="Show FPS Counter", Value=CFG.fps.show_fps,
        Callback=function(v) CFG.fps.show_fps=v end })
    FpsTab:Toggle({ Title="FPS Booster", Desc="Lower graphics for more FPS",
        Value=CFG.fps.booster,
        Callback=function(v)
            CFG.fps.booster=v
            if v then
                pcall(function()
                    settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
                    Lighting.GlobalShadows=false; Lighting.FogEnd=9e9
                    for _,fx in ipairs(Lighting:GetChildren()) do
                        if fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect")
                           or fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") then
                            fx.Enabled=false
                        end
                    end
                end)
            else
                pcall(function()
                    settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic
                    Lighting.GlobalShadows=true
                end)
            end
        end })

    -- ── CONFIG + GRADIENT ─────────────────────────────────────────
    CfgTab:Paragraph({ Title="Config", Desc="Save or load your settings" })
    CfgTab:Button({ Title="Save Config", Icon="save",
        Callback=function()
            local ok2=SaveConfig()
            WindUI:Notify({ Title="Vaeh X Cloud", Content=ok2 and "Config saved!" or "Failed to save", Duration=3 })
        end })
    CfgTab:Button({ Title="Load Config", Icon="folder-open",
        Callback=function()
            local ok2=LoadConfig()
            WindUI:Notify({ Title="Vaeh X Cloud", Content=ok2 and "Config loaded!" or "No config found", Duration=3 })
        end })
    CfgTab:Space()
    CfgTab:Paragraph({ Title="Gradient Theme", Desc="Apply color gradient over window background" })
    CfgTab:Dropdown({ Title="Gradient", Values=GRADIENT_NAMES, Value="None",
        Callback=function(name)
            ApplyGradient(name)
            if name~="None" then
                WindUI:Notify({ Title="Gradient", Content=name, Duration=2 })
            end
        end })

    -- ── FPS OVERLAY ───────────────────────────────────────────────
    local CoreGui=game:GetService("CoreGui")
    local FpsGui=Instance.new("TextLabel")
    FpsGui.Size=UDim2.new(0,90,0,22); FpsGui.Position=UDim2.new(0,8,0,8)
    FpsGui.BackgroundColor3=Color3.fromRGB(5,3,12); FpsGui.BackgroundTransparency=0.2
    FpsGui.TextColor3=Color3.fromRGB(80,230,150); FpsGui.TextSize=12
    FpsGui.Font=Enum.Font.GothamBold; FpsGui.Text="FPS: --"
    FpsGui.Visible=CFG.fps.show_fps
    Instance.new("UICorner",FpsGui).CornerRadius=UDim.new(0,6)
    pcall(function()
        local sg=Instance.new("ScreenGui")
        sg.Name="VAEHXCLOUD_FPS"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
        sg.Parent=CoreGui; FpsGui.Parent=sg
    end)

    local fpsCounter,fpsLast=0,tick()

    RunService.RenderStepped:Connect(function()
        fpsCounter=fpsCounter+1
        if tick()-fpsLast>=1 then
            local cur=fpsCounter; fpsCounter=0; fpsLast=tick()
            FpsGui.Text="FPS: "..cur
            FpsGui.TextColor3=cur>=50 and Color3.fromRGB(80,230,150)
                or (cur>=30 and Color3.fromRGB(255,200,50) or Color3.fromRGB(230,60,60))
        end
        FpsGui.Visible=CFG.fps.show_fps

        local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
        FovCircle.Position=center
        FovCircle.Visible=CFG.aimbot.enabled and CFG.aimbot.draw_fov

        if CFG.aimbot.enabled then
            local target,_,tPlayer=GetClosestTarget()
            if target and tPlayer then
                local aimPos=CFG.aimbot.predict and Predicted(target,tPlayer) or target.Position
                local sp,onScreen=Camera:WorldToViewportPoint(aimPos)
                if onScreen then
                    if not CFG.aimbot.silent then
                        Camera.CFrame=Camera.CFrame:Lerp(
                            CFrame.lookAt(Camera.CFrame.Position,aimPos),CFG.aimbot.smooth)
                    end
                    LockLine.From=center; LockLine.To=Vector2.new(sp.X,sp.Y); LockLine.Visible=true
                    LockDot.Position=Vector2.new(sp.X,sp.Y); LockDot.Visible=true
                else LockLine.Visible=false; LockDot.Visible=false end
            else LockLine.Visible=false; LockDot.Visible=false end
        else LockLine.Visible=false; LockDot.Visible=false end

        if CFG.esp.enabled then
            for _,p in ipairs(Players:GetPlayers()) do
                if p==LP then continue end
                if IsTeammate(p,CFG.esp.team_check) then ClearESP(p) continue end
                local char=p.Character; if not char then ClearESP(p) continue end
                local hum=char:FindFirstChildOfClass("Humanoid")
                local root=char:FindFirstChild("HumanoidRootPart")
                if not hum or not root or hum.Health<=0 then ClearESP(p) continue end
                if not ESPObjects[p] then CreateESP(p) end
                local data=ESPObjects[p]; if not data then continue end
                local pos,onScreen=Camera:WorldToViewportPoint(root.Position)
                if not onScreen then
                    data.box.Visible=false; data.name.Visible=false; data.dist.Visible=false
                    data.hbg.Visible=false; data.hfill.Visible=false
                    if data.chams then data.chams.Enabled=false end
                    continue
                end
                local size=2000/pos.Z; local h,w=size*1.8,size
                if CFG.esp.boxes then
                    data.box.Size=Vector2.new(w,h)
                    data.box.Position=Vector2.new(pos.X-w/2,pos.Y-h/2); data.box.Visible=true
                else data.box.Visible=false end
                if CFG.esp.names then
                    data.name.Text=p.Name
                    data.name.Position=Vector2.new(pos.X,pos.Y-h/2-16); data.name.Visible=true
                else data.name.Visible=false end
                if CFG.esp.distance then
                    data.dist.Text=math.floor((root.Position-Camera.CFrame.Position).Magnitude).."m"
                    data.dist.Position=Vector2.new(pos.X,pos.Y+h/2+4); data.dist.Visible=true
                else data.dist.Visible=false end
                if CFG.esp.health then
                    local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
                    data.hbg.Size=Vector2.new(3,h)
                    data.hbg.Position=Vector2.new(pos.X-w/2-6,pos.Y-h/2); data.hbg.Visible=true
                    data.hfill.Size=Vector2.new(3,h*hp)
                    data.hfill.Position=Vector2.new(pos.X-w/2-6,pos.Y-h/2+h*(1-hp))
                    data.hfill.Color=Color3.fromRGB(255*(1-hp),255*hp,40); data.hfill.Visible=true
                else data.hbg.Visible=false; data.hfill.Visible=false end
                if data.chams then
                    data.chams.Enabled=CFG.esp.chams
                    if not data.chams.Parent then data.chams.Parent=char end
                end
            end
        else
            for p in pairs(ESPObjects) do ClearESP(p) end
        end
    end)

    Players.PlayerRemoving:Connect(function(p) ClearESP(p); PrevPos[p.UserId]=nil end)
    LP.CharacterRemoving:Connect(function() PrevPos={} end)
    print("[Vaeh X Cloud] WindUI loaded — background injection ready")
end

ShowKeyGate(loadMain)

--[[
    ╔══════════════════════════════════════════════════════════╗
    ║                      VaehzTech                           ║
    ║          Ride A Pet • Keyless Instant Pickup             ║
    ║              + New Volcanic Egg Support                  ║
    ╚══════════════════════════════════════════════════════════╝
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local env = (getgenv and getgenv()) or _G

if env.__VAEHZTECH_LOADING then
    return
end

env.__VAEHZTECH_LOADING = true

local function notify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "VaehzTech",
            Text = tostring(msg),
            Duration = 4
        })
    end)
    print("[VaehzTech] " .. tostring(msg))
end

notify("Loading VaehzTech...")

local SOURCE_URL = "https://raw.githubusercontent.com/ronilo191002/rap/refs/heads/main/rap.lua"
local source

for attempt = 1, 3 do
    local success, result = pcall(game.HttpGet, game, SOURCE_URL, true)
    if success and type(result) == "string" and #result > 100 then
        source = result
        break
    end
    task.wait(attempt * 0.6)
end

if not source then
    notify("Failed to download script source")
    env.__VAEHZTECH_LOADING = nil
    return
end

local chunk, compileErr = loadstring(source)

if not chunk then
    notify("Compile error: " .. tostring(compileErr))
    env.__VAEHZTECH_LOADING = nil
    return
end

-- Rebrand so any internal prints show VaehzTech instead of ZanjiHub
pcall(function()
    local oldEnv = getfenv(chunk)
    setfenv(chunk, setmetatable({
        print = function(...)
            local args = {...}
            for i = 1, #args do
                if type(args[i]) == "string" then
                    args[i] = args[i]
                        :gsub("[Zz]anji[Hh]ub", "VaehzTech")
                        :gsub("[Zz]anji", "VaehzTech")
                end
            end
            print("[VaehzTech]", unpack(args))
        end,
        warn = function(...)
            local args = {...}
            for i = 1, #args do
                if type(args[i]) == "string" then
                    args[i] = args[i]
                        :gsub("[Zz]anji[Hh]ub", "VaehzTech")
                        :gsub("[Zz]anji", "VaehzTech")
                end
            end
            warn("[VaehzTech]", unpack(args))
        end,
    }, { __index = oldEnv }))
end)

local ok, err = pcall(chunk)

env.__VAEHZTECH_LOADING = nil

if ok then
    notify("VaehzTech loaded successfully • Instant Pickup + Volcanic Egg ready")
else
    notify("Runtime error: " .. tostring(err))
end

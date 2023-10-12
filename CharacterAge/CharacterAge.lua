local events = {}
local currentPlayed = 0
local currentLevelPlayed = 0
local currentLevel = 0
local measureOffset = GetTime()
local frameUpdaterCounter = 0
local currnetLevelXP_Percent = 0

local frame = CreateFrame("Frame", "CharacterAge_Timers", UIParent)
local gametime = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
local leveltime = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")

frame:SetFrameStrata("DIALOG")
frame:SetWidth(200)
frame:SetHeight(20)
frame:SetPoint("CENTER", 0, 0)
frame:SetMovable(true)
gametime:SetTextColor(1, 1, 0, 1)
gametime:SetPoint("TOPRIGHT", -105, 0)
gametime:SetJustifyH("RIGHT")
local fontPath, _, flags = gametime:GetFont()
gametime:SetFont(fontPath, 24, flags)
leveltime:SetTextColor(1, 1, 1, 1)
leveltime:SetPoint("TOPLEFT", 105, 0)
leveltime:SetJustifyH("LEFT")
fontPath, _, flags = leveltime:GetFont()
leveltime:SetFont(fontPath, 24, flags)

function number2time(t)
    local t_s = t % 60
    t = (t - t_s) / 60
    local t_m = t % 60
    t = (t - t_m) / 60
    local t_h = t % 24
    t = (t - t_h) / 24
    return t_s, t_m, t_h, t
end

function time2string(s, m, h, d)
    local t = tostring(s) .. "s"
    if (m > 0 or h > 0 or d > 0) then
        if (s < 10) then
            t = "0" .. t
        end
        t = tostring(m) .. "m " .. t
        if (h > 0 or d > 0) then
            if (m < 10) then
                t = "0" .. t
            end
            t = tostring(h) .. "h " .. t
            if (d > 0) then
                if (h < 10) then
                    t = "0" .. t
                end
                t = tostring(d) .. "d " .. t
            end
        end
    end
    return t
end

function events:TIME_PLAYED_MSG(...)
    local played, played_level = ...
    currentPlayed = played
    currentLevelPlayed = played_level
    measureOffset = GetTime()
end

function events:PLAYER_ENTERING_WORLD(...)
    RequestTimePlayed()
    currentLevel = UnitLevel("player")
    currnetLevelXP_Percent = getCurrentLevelXP_Percent()
end

function events:PLAYER_LEVEL_UP(...)
    currentLevelPlayed = 0
    currentPlayed = currentPlayed + math.floor(GetTime() - measureOffset)
    currentLevel = currentLevel + 1
    measureOffset = GetTime()
    currnetLevelXP_Percent = getCurrentLevelXP_Percent()
end

function getCurrentLevelXP_Percent()
    local currentXP = UnitXP("player")
    local nextLevelXP = UnitXPMax("player")
    return tostring(math.floor(currentXP / nextLevelXP * 100 + .5))
end

function events:PLAYER_XP_UPDATE(...)
    local currentXP = UnitXP("player")
    local nextLevelXP = UnitXPMax("player")
    currnetLevelXP_Percent = getCurrentLevelXP_Percent()
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

frame:SetScript("OnUpdate", function(self, event, ...)
    frameUpdaterCounter = frameUpdaterCounter + 1
    if (frameUpdaterCounter > GetFramerate() / 6) then
        currentOffset = math.floor(GetTime() - measureOffset)
        gametime:SetText("Total " .. time2string(number2time(currentPlayed + currentOffset)))
        leveltime:SetText(time2string(number2time(currentLevelPlayed + currentOffset)) .. " @ Level " ..
                              tostring(currentLevel) .. "." .. currnetLevelXP_Percent)
        frameUpdaterCounter = 0
    end
end)

frame:SetScript("OnMouseDown", frame.StartMoving)
frame:SetScript("OnMouseUp", frame.StopMovingOrSizing)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

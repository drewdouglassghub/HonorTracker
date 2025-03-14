--------------------------------------------------
-- Namespaces
--------------------------------------------------
local _, core = ...;

local Config = core.Config;


strTable = { };

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

SLASH_FRAMESTK1 = "/fs" -- For quicker access to frame stack
SlashCmdList.FRAMESTK = function()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

-- SLASH_HONORTOGGLE1 = "/togglehnr"
--     SlashCmdList.HONORTOGGLE = function()
--         if PVPFrameHonorCounter:IsShown() then
--             print("HONOR HIDDEN")
--             PVPFrameHonorCounter:Hide()
--         else
--             print("HONOR SHOWN")
--             PVPFrameHonorCounter:Show()
--         end
-- end
--     local toggle = PVPFrameHonorCounter:IsShown()
--     -- if (toggle == true) then
--         print("Toggle: " .. toggle)
--         PVPFrameHonorCounter:Hide();
--         print(“Honor UI has been disabled.”);
--     -- else
--     --     PVPFrameHonorCounter:Show();

--     end


-- SLASH_HIDEHONOR1 = "/hidehonor"
--     SlashCmdList.HIDEHONOR = function()
--         print("HONOR HIDDEN")
--         PVPFrameHonorCounter:Hide()
-- end


-- SLASH_UPDATEHONOR1 = "/updatehonor" -- For quicker access to frame stack
-- SlashCmdList.UPDATEHONOR = function()
--    core:init()
-- end

for i = 1, NUM_CHAT_WINDOWS do
    _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
end

local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
print("VERSION: " .. tocversion)
----------------------------------------------------------------

-- Build the frame we use to display total honor on the PVPFrame
-- Config:CreateMenu()

local PVPFrameHonorCounter
local PVPFrameHonorCounter = CreateFrame('Frame', 'PVPFrameHonorCounter', UIParent,  "BasicFrameTemplateWithInset")
PVPFrameHonorCounter:SetSize(195,140)
PVPFrameHonorCounter:EnableMouse(true)
PVPFrameHonorCounter:SetPoint("BOTTOMLEFT", UIParent, "LEFT"); -- point, relativeFrame, relativePoint, xOffset, yOffset
PVPFrameHonorCounter:SetMovable(true)
PVPFrameHonorCounter:SetScript("OnMouseDown",PVPFrameHonorCounter.StartMoving)
PVPFrameHonorCounter:SetScript("OnMouseUp",PVPFrameHonorCounter.StopMovingOrSizing)

-- Child frames and regions:
PVPFrameHonorCounter.title = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal");
PVPFrameHonorCounter.title:SetFontObject("GameFontHighlight");
PVPFrameHonorCounter.title:SetPoint("LEFT", PVPFrameHonorCounter.TitleBg, "LEFT", 5, 0);
PVPFrameHonorCounter.title:SetText("BG Honor Tracker");

PVPFrameHonorCounter.mapName = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PVPFrameHonorCounter.mapName:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -10);
PVPFrameHonorCounter.mapName:SetText("Map: ")

PVPFrameHonorCounter.status = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PVPFrameHonorCounter.status:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -30);
PVPFrameHonorCounter.status:SetText("Status: ")

PVPFrameHonorCounter.player = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PVPFrameHonorCounter.player:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -50);
PVPFrameHonorCounter.player:SetText("Player: " .. UnitName("player"))

PVPFrameHonorCounter.honorGained = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PVPFrameHonorCounter.honorGained:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -70);
PVPFrameHonorCounter.honorGained:SetText("Honor Gained: ")

PVPFrameHonorCounter.honorableKills = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PVPFrameHonorCounter.honorableKills:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -90);
PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills: ")
-- PVPFrameHonorCounter:Hide()

local eventFrame= CreateFrame("Frame", "eventFrame");
eventFrame:RegisterAllEvents();
-- eventFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
-- eventFrame:RegisterUserEvent("HONOR_XP_UPDATE");
local currentHonor = 0;
local newHonor = 0;
local killCount = 0;
PVPFrameHonorCounter.honorGained:SetText("Honor Gained: " .. newHonor)
PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills: " .. killCount)  

local function eventHandler(self, event, ...)
    if(event == "UPDATE_BATTLEFIELD_STATUS") then
        print("***** Updating Status *****")
        local status, mapName, instanceID, bracketMin, bracketMax, teamSize, registeredMatch = GetBattlefieldStatus(1)
        PVPFrameHonorCounter.mapName:SetText("Map: " .. mapName)
        PVPFrameHonorCounter.status:SetText("Status: " .. status)
        return
    elseif(event == "UPDATE_ACTIVE_BATTLEFIELD") then
        local status, mapName, instanceID, bracketMin, bracketMax, teamSize, registeredMatch = GetBattlefieldStatus(1)
        PVPFrameHonorCounter.mapName:SetText("Map: ".. mapName)
        PVPFrameHonorCounter.status:SetText("Status: " .. status) 
        for i=1, numScores do
            local name, killingBlows, honorableKills, deaths, honorGained, faction = GetBattlefieldScore(i);
            if(playerName == name) then
                PVPFrameHonorCounter.honorGained:SetText("Honor Gained: " .. honorGained)
                PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills: " .. honorableKills)  
                killCount = 0;
                newHonor = 0;
                return
            end
        end
    elseif(event == "CHAT_MSG_COMBAT_HONOR_GAIN") then
        local text = ...
        local substring = string.sub(text, 1, 3)
        if substring == "You" then
            local honorPattern1 = "([%d%.]+)%s+honor%spoints"
            local start_pos, end_pos, points = string.find(text, honorPattern1)
            newHonor = newHonor + points
            PVPFrameHonorCounter.honorGained:SetText("Honor Gained: " .. newHonor)
        else
            local honorPattern2 = "(%a+)%sdies.*Rank:%s(%a+)%s%(([%d%.]+)%sHonor Points%)"    
            local start_pos, end_pos, name, rank, points = string.find(text, honorPattern2)
            newHonor = newHonor + points
            killCount = killCount + 1
            PVPFrameHonorCounter.honorGained:SetText("Honor Gained: " .. newHonor)
            PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills: " .. killCount)  
        end
    elseif(event == "CHAT_MSG_TRADESKILLS") then
        local text = ...
        print("*** TRADESKILLS: " .. text)
        local size = string.len(text) - 1
        local temp = string.sub(text, 1,3)    
        --local _, _, player = string.find(text, "[%a+] create [%a+]")
        if(temp == "You") then
            local tradeSkillPattern1 = "(%a+) create (%a+)"
            local s, f, player, item = string.find(text, pattern)
            local substring = string.sub(text, f, size)
            local itemName, itemLink = GetItemInfo(substring);
            --local itemLink = "|cff9d9d9d|Hitem:3299::::::::20:257::::::|h["..substring.."]|h|r"
            print("*** TRADESKILLS MSG: " .. itemLink)
        else 
            local tradeSkillPattern2 = "(%a+) creates (%a+)"
            local s, f, player, item = string.find(text, pattern)
            local substring = string.sub(text, f, size)
            local itemName, itemLink = GetItemInfo(substring);
            print("*** TRADESKILLS MSG: " .. itemLink)
        end
    elseif(event == "CHAT_MSG_ADDON") then
        -- print("chat message _ADDON")
        local prefix, text = ...
        
        -- local indexStart, indexEnd, addon = string.gsub(text)
        -- print("chat message _ADDON" .. addon)
    -- --    local start, end, killed, rank, honor =   local newpattern = string.gsub(CHAT_MSG_COMBAT_HONOR_GAIN = (%%s)", "(.+))
        -- local newString = string.find(arg1, CHAT_MSG_TRADESKILLS)
        -- PVPFrameHonorCounter.honorGained:SetText("Honor Gained: " .. newString)
        --print(newString)
    end
end

eventFrame:SetScript("OnEvent", eventHandler);

local function split(string, separator)
    local tabl = {}
    for str in string.gmatch(string, "[^"..separator.."]+") do
        table.insert (tabl, str)
    end
    return tabl
end

local function updateHonor(HONOR_XP_UPDATE, ...)
    print("***** Updating honor *****")
    local numScores = GetNumBattlefieldScores()
    local playerName = UnitName("player")
    print(playerName)
    for i=1, numScores do
        local name, killingBlows, honorableKills, deaths, honorGained, faction = GetBattlefieldScore(i);
        if(playerName == name) then
            print("Honorable kills: " .. honorableKills)
            print("Honor Gained: " .. honorGained .. " Honorable Kills: " .. honorableKills)
                PVPFrameHonorCounter.honorGained:SetText("Honor Gained: " .. honorGained)
                PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills: " .. honorableKills)
        end
    end
    -- return honorGained, honorableKills
end

SLASH_HONORTOGGLE1 = "/togglehonor"
    SlashCmdList.HONORTOGGLE = function()
        if PVPFrameHonorCounter:IsShown() then
            print("HONOR HIDDEN")
            PVPFrameHonorCounter:Hide()
        else
            print("HONOR SHOWN")
            PVPFrameHonorCounter:Show()
        end
end

-- local function setHonorXP(honorGained)
--     PVPFrameHonorCounter.honorGained:SetText("Honor Gained .. ": " .. honorGained)
-- end

-- local function setHonorableKills(honorableKills)
--     PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills .. ": " .. honorableKills)
-- end

-- local playerIndex = GetUnitIndex()

-- local function GetUnitIndex()
--     print("***** Getting Unit Index *****")
--     local numPlayers = GetNumBattlefieldScores()
--     for i, numPlayers do 
--         local playerName = UnitName("player")
--         local name, killingBlows, honorableKills, deaths, honorGained, faction = GetBattlefieldScore(i);
--         print("***** " .. name .. " *****")
--         if (playerName == name)
--             print("***** Unit Index Found *****")
--             break
--         end
--     end
--     return i
-- end



-- name: 
-- killingBlows:
-- honorableKills:
-- deaths:
-- honorGained:

-- Pattern Breakdown:

-- (%a+): Captures a sequence of alphabetic characters for the name (e.g., "Natelp").

-- %sdies.*Rank:%s: Matches " dies, honorable kill Rank: " but doesn’t capture it.

-- ([%a]+): Captures a sequence of alphabetic characters for the rank (e.g., "Scout").

-- %s%(([%d%.]+)%sHonor Points%): Captures a numeric value (e.g., "0.92") surrounded by parentheses and followed by " Honor Points".



-- local function showHonor()
--     print("***** Inside showHonor *****")
    
    
--     local playerName = UnitName("Thett")
--     for playerIndex = 1, GetNumBattlefieldStats() do
--         local name =    
--         if name == playerName then
--             local output = "Battleground stats for "..name..":\n"
--             for statIndex = 1, GetNumBattlefieldStats() do
--                 output = output .. "    " .. GetBattlefieldStatInfo(statIndex) .. ": " ..GetBattlefieldStatData(statIndex) .. "\n"
--                 PVPFrameHonorCounter.honor:SetText("HONOR: " .. output) 
--             end
--         print(output)
--         break
--         end
--     end
-- end

    
-- local function hideHonor()
 
-- end
-- function calculateCurrentHonor(currentHonor, newHonor)
--     currentHonor = currentHonor + newHonor
--     return currentHonor

-- end


-- PVPFrameHonorCounter.honor:SetAllPoints(PVPFrameHonorCounter)

-- Adjust the positioning of the frames to leave room for our text.
-- local function adjust_pvp_frame()
-- 	PVPFrameHonor:ClearAllPoints()
-- 	PVPFrameHonor:SetPoint('TOPLEFT',PVPFrameBackground,'TOPLEFT',78,-2)
-- 	PVPFrameHonorCounter:ClearAllPoints()
-- 	PVPFrameHonorCounter:SetPoint('LEFT',PVPFrameHonorPoints,'RIGHT')
-- 	PVPFrameHonorIcon:ClearAllPoints()
-- 	PVPFrameHonorIcon:SetPoint('LEFT',PVPFrameHonorCounter,'RIGHT',4,-6)
-- 	PVPFrameHonorCounter:Show()
-- end


-- local CELL_WIDTH = 70
-- local CELL_HEIGHT = 10
-- local NUM_CELLS = 1 -- cells per row

-- local columnData = GetBattlefieldStatData(index, statIndex)
-- print(columnData)


-- local UIConfig;
-- local UIConfig = CreateFrame("Frame", "DrewUI_BuffFrame", UIParent, "BasicFrameTemplateWithInset");

-- UIConfig:SetSize(CELL_WIDTH*NUM_CELLS+60,300); --width, height
-- UIConfig:SetPoint("BOTTOMLEFT", UIParent, "LEFT"); -- point, relativeFrame, relativePoint, xOffset, yOffset
-- UIConfig:SetMovable(true)
-- UIConfig:SetScript("OnMouseDown",UIConfig.StartMoving)
-- UIConfig:SetScript("OnMouseUp",UIConfig.StopMovingOrSizing)

-- -- -- Child frames and regions:

-- UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY");
-- UIConfig.title:SetFontObject("GameFontHighlight");
-- UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
-- UIConfig.title:SetText("Drew UI");
-- local soundType = {
--     SOUND = 1,
--     GAME_MUSIC = 2,
--     CUSTOM = 3
-- }





-- local sounds = {
--     ["Elwynn"] = {
--         ["sound"] = 441521,
--         ["description"] = "peace",
--         ["type"] = soundType.GAME_MUSIC
--     },
--     ["fart"] = {
--         ["sound"] = 598718,
--         ["description"] = "aaaahhhhhh!",
--         ["type"] = soundType.SOUND
--     },
--     ["train"] = {
--         ["sound"] = 540275,
--         ["description"] = "choo choo!",
--         ["type"] = soundType.SOUND
--     },
--     ["custom"] = {
--         ["sound"] = "\\Interface\\AddOns\\MusicPlayer\\Sounds\\custom.mp3",
--         ["description"] = "aaaahhhhhh",
--         ["type"] = soundType.CUSTOM
--     }
-- }


-- local function displaySoundList()
--     print("-----------------------------")
--     for command in pairs(sounds) do 
        
--         print("Command: /playsound " .. command)
--     end
--     print("-----------------------------")
-- end

-- SLASH_SOUND1 = "/playsound"
-- SLASH_STOPSOUND1 = "/stopsound"

-- local function playTrack(track)
    
--     if(track.type == soundType.GAME_MUSIC) then
--         PlayMusic(track.sound)
--     elseif(track.type == soundType.SOUND) then
--         PlayMusic(track.sound)
--     elseif(track.type == soundType.CUSTOM) then
--         print("Play custom sound")
--     end
-- end

-- local function playSoundHandler(trackId)

--     if(string.len(trackId) > 0) then
--         local matchesTrack = sounds[trackId] ~= nil
--         if(matchesTrack) then
--             local track = sounds[trackId]
--             playTrack(track)
--         end
--     else
--         displaySoundList()
--     end 
-- end


-- local function stopSoundHandler()
--     StopSound()
-- end

-- SlashCmdList["SOUND"] = playSoundHandler
-- SlashCmdList["STOPSOUND"] = stopSoundHandler
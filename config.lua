--------------------------------------------------
-- Namespaces
--------------------------------------------------
local _, core = ...;
core.Config = {};

local Config = core.Config;
local PVPFrameHonorCounter;

--------------------------------------------------
-- Defaults -> usually a database
--------------------------------------------------

-- Config:CreateMenu()
-- 	local PVPFrameHonorCounter = CreateFrame('Frame', 'PVPFrameHonorCounter', UIParent,  "BasicFrameTemplateWithInset")
-- 	PVPFrameHonorCounter:SetSize(150,250)
-- 	PVPFrameHonorCounter:EnableMouse(true)
-- 	PVPFrameHonorCounter:SetPoint("BOTTOMLEFT", UIParent, "LEFT"); -- point, relativeFrame, relativePoint, xOffset, yOffset
-- 	PVPFrameHonorCounter:SetMovable(true)
-- 	PVPFrameHonorCounter:SetScript("OnMouseDown",PVPFrameHonorCounter.StartMoving)
-- 	PVPFrameHonorCounter:SetScript("OnMouseUp",PVPFrameHonorCounter.StopMovingOrSizing)

-- 	-- Child frames and regions:
-- 	PVPFrameHonorCounter.title = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal");
-- 	PVPFrameHonorCounter.title:SetFontObject("GameFontHighlight");
-- 	PVPFrameHonorCounter.title:SetPoint("LEFT", PVPFrameHonorCounter.TitleBg, "LEFT", 5, 0);
-- 	PVPFrameHonorCounter.title:SetText("BG Honor Tracker");

-- 	PVPFrameHonorCounter.name = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- 	PVPFrameHonorCounter.name:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -10);
-- 	PVPFrameHonorCounter.name:SetText("BG Name: ")

-- 	PVPFrameHonorCounter.status = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- 	PVPFrameHonorCounter.status:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -30);
-- 	PVPFrameHonorCounter.status:SetText("Status: ")

-- 	PVPFrameHonorCounter.player = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- 	PVPFrameHonorCounter.player:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -70);
-- 	PVPFrameHonorCounter.player:SetText("Player: " .. UnitName("player"))

-- 	PVPFrameHonorCounter.honorGained = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- 	PVPFrameHonorCounter.honorGained:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -90);
-- 	PVPFrameHonorCounter.honorGained:SetText("Honor Gained: ")

-- 	PVPFrameHonorCounter.honorableKills = PVPFrameHonorCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- 	PVPFrameHonorCounter.honorableKills:SetPoint("TOPLEFT", PVPFrameHonorCounter.Bg, 10, -110);
-- 	PVPFrameHonorCounter.honorableKills:SetText("Honorable Kills: ")
-- -- end


local addonName, addon = ...

---------------------------------------------------------
-- Main Frame
---------------------------------------------------------
local frame = CreateFrame("Frame", "CofferKeysAddon", UIParent)
frame:SetSize(420, 30)
frame:SetFrameStrata("HIGH")
frame:Hide()

---------------------------------------------------------
-- Keys Text
---------------------------------------------------------
frame.keysText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.keysText:SetPoint("LEFT", frame, "LEFT", 0, 0)
frame.keysText:SetFont("Fonts\\FRIZQT__.TTF", 14)
frame.keysText:SetShadowColor(0, 0, 0, 1)
frame.keysText:SetShadowOffset(-1, -1)
frame.keysText:SetTextColor(1, 1, 1)

---------------------------------------------------------
-- Key Icon
---------------------------------------------------------
frame.keyIcon = frame:CreateTexture(nil, "ARTWORK")
frame.keyIcon:SetSize(26, 26)
frame.keyIcon:SetPoint("LEFT", frame.keysText, "RIGHT", 5, 0)
frame.keyIcon:SetTexture(4622270)

---------------------------------------------------------
-- Fragment Icon
---------------------------------------------------------
frame.fragmentIcon = frame:CreateTexture(nil, "ARTWORK")
frame.fragmentIcon:SetSize(26, 26)
frame.fragmentIcon:SetPoint("LEFT", frame.keyIcon, "RIGHT", 5, 0)
frame.fragmentIcon:SetTexture("Interface\\Icons\\inv_gizmo_hardenedadamantitetube")

---------------------------------------------------------
-- Fragment Count
---------------------------------------------------------
frame.fragmentText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.fragmentText:SetPoint("LEFT", frame.fragmentIcon, "RIGHT", 4, 0)
frame.fragmentText:SetFont("Fonts\\FRIZQT__.TTF", 12)
frame.fragmentText:SetShadowColor(0, 0, 0, 1)
frame.fragmentText:SetShadowOffset(-1, -1)
frame.fragmentText:SetTextColor(1, 1, 1)

---------------------------------------------------------
-- Radiant Echo Label
---------------------------------------------------------
frame.radiantLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.radiantLabel:SetPoint("LEFT", frame.fragmentText, "RIGHT", 7, 0)
frame.radiantLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)
frame.radiantLabel:SetShadowColor(0, 0, 0, 1)
frame.radiantLabel:SetShadowOffset(-1, -1)
frame.radiantLabel:SetTextColor(1, 1, 1)
frame.radiantLabel:SetText("Radiant Echo:")

---------------------------------------------------------
-- Radiant Echo Icon
---------------------------------------------------------
frame.radiantIcon = frame:CreateTexture(nil, "ARTWORK")
frame.radiantIcon:SetSize(26, 26)
frame.radiantIcon:SetPoint("LEFT", frame.radiantLabel, "RIGHT", 5, 0)
frame.radiantIcon:SetTexture("Interface\\Icons\\spell_holy_pureofheart")

---------------------------------------------------------
-- Radiant Echo Count
---------------------------------------------------------
frame.radiantText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.radiantText:SetPoint("LEFT", frame.radiantIcon, "RIGHT", 4, 0)
frame.radiantText:SetFont("Fonts\\FRIZQT__.TTF", 12)
frame.radiantText:SetShadowColor(0, 0, 0, 1)
frame.radiantText:SetShadowOffset(-1, -1)
frame.radiantText:SetTextColor(1, 1, 1)

---------------------------------------------------------
-- Update Logic
---------------------------------------------------------
local function UpdateCounts()
    local keys = 0
    if C_QuestLog.IsQuestFlaggedCompleted(91175) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(91176) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(91177) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(91178) then keys = keys + 1 end

    frame.keysText:SetText("Keys: " .. keys .. "/4")

    local fragments = GetItemCount(245653) or 0
    frame.fragmentText:SetText(fragments .. "/100")

    local radiant = GetItemCount(246771) or 0
    frame.radiantText:SetText(radiant)
end

---------------------------------------------------------
-- Positioning (LEFT of Bountiful)
---------------------------------------------------------
local function TryAttach()
    local journal = EncounterJournalJourneysFrame
    local bountiful = _G.BountifulContainer
    if not journal or not bountiful then return false end

    frame:SetParent(journal)
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", bountiful, "TOPLEFT", 35, -2)
    frame:Show()
    return true
end

---------------------------------------------------------
-- Events
---------------------------------------------------------
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        UpdateCounts()

        frame.attachTicker = C_Timer.NewTicker(0.2, function()
            if TryAttach() then
                frame.attachTicker:Cancel()
                frame.attachTicker = nil
            end
        end)

        if EncounterJournal then
            EncounterJournal:HookScript("OnShow", function()
                UpdateCounts()
                frame.attachTicker = C_Timer.NewTicker(0.2, function()
                    if TryAttach() then
                        frame.attachTicker:Cancel()
                        frame.attachTicker = nil
                    end
                end)
            end)

            EncounterJournal:HookScript("OnHide", function()
                frame:Hide()
            end)
        end
    else
        UpdateCounts()
    end
end)

local addonName, addon = ...

---------------------------------------------------------
-- Main Frame
---------------------------------------------------------
local frame = CreateFrame("Frame", "CofferKeysAddon", UIParent)
frame:SetSize(220, 60)
frame:SetFrameStrata("HIGH")
frame:Hide()

---------------------------------------------------------
-- Texts
---------------------------------------------------------
frame.keysText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.keysText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
frame.keysText:SetFont("Fonts\\FRIZQT__.TTF", 13)
frame.keysText:SetShadowColor(0, 0, 0, 1)
frame.keysText:SetShadowOffset(-1, -1)
frame.keysText:SetTextColor(1, 0.85, 0.2)

frame.fragmentText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.fragmentText:SetPoint("TOPLEFT", frame.keysText, "BOTTOMLEFT", 0, -2)
frame.fragmentText:SetFont("Fonts\\FRIZQT__.TTF", 12)
frame.fragmentText:SetShadowColor(0, 0, 0, 1)
frame.fragmentText:SetShadowOffset(-1, -1)
frame.fragmentText:SetTextColor(0.9, 0.9, 0.9)

frame.radiantText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.radiantText:SetPoint("TOPLEFT", frame.fragmentText, "BOTTOMLEFT", 0, -2)
frame.radiantText:SetFont("Fonts\\FRIZQT__.TTF", 12)
frame.radiantText:SetShadowColor(0, 0, 0, 1)
frame.radiantText:SetShadowOffset(-1, -1)
frame.radiantText:SetTextColor(0.7, 0.9, 1)

---------------------------------------------------------
-- Delve button atlas (одинаковый в WW и Midnight)
---------------------------------------------------------
local DELVE_BUTTON_ATLAS = "UI-Journeys-Delve-Button"

---------------------------------------------------------
-- Season detection (приоритет Midnight по валюте 3310)
---------------------------------------------------------
local function DetectSeason()
    local shardsInfo = C_CurrencyInfo.GetCurrencyInfo(3310)
    if shardsInfo and shardsInfo.discovered and shardsInfo.quantityMax > 0 then
        return "MIDNIGHT"
    end
    return "WAR_WITHIN"
end

---------------------------------------------------------
-- Update Logic
---------------------------------------------------------
local function UpdateCounts()
    local season = DetectSeason()

    if season == "WAR_WITHIN" then
        local keys = 0
        if C_QuestLog.IsQuestFlaggedCompleted(91175) then keys = keys + 1 end
        if C_QuestLog.IsQuestFlaggedCompleted(91176) then keys = keys + 1 end
        if C_QuestLog.IsQuestFlaggedCompleted(91177) then keys = keys + 1 end
        if C_QuestLog.IsQuestFlaggedCompleted(91178) then keys = keys + 1 end
        frame.keysText:SetText("Keys: " .. keys .. "/4")

        local fragments = GetItemCount(245653) or 0
        frame.fragmentText:SetText("Fragments: " .. fragments .. "/100")

        local radiant = GetItemCount(246771) or 0
        frame.radiantText:SetText("Radiant Echo: " .. radiant)
        frame.radiantText:Show()

    elseif season == "MIDNIGHT" then
        local keysInfo = C_CurrencyInfo.GetCurrencyInfo(3028)
        local keys = keysInfo and keysInfo.quantity or 0
        frame.keysText:SetText("Keys: " .. keys)

        local fragInfo = C_CurrencyInfo.GetCurrencyInfo(3310)
        local fragments = fragInfo and fragInfo.quantity or 0
        frame.fragmentText:SetText("Shards: " .. fragments .. "/600")

        frame.radiantText:Hide()
    end
end

---------------------------------------------------------
-- Find Delves Button
---------------------------------------------------------
local function FindDelvesButton()
    if not EncounterJournalJourneysFrame or not EncounterJournalJourneysFrame.JourneysList then
        return nil
    end

    local scrollTarget = EncounterJournalJourneysFrame.JourneysList.ScrollTarget
    if not scrollTarget then return nil end

    for _, child in ipairs({scrollTarget:GetChildren()}) do
        if child.GetNormalTexture then
            local tex = child:GetNormalTexture()
            if tex and tex.GetAtlas and tex:GetAtlas() == DELVE_BUTTON_ATLAS then
                return child
            end
        end
    end
    return nil
end

---------------------------------------------------------
-- Attach frame
---------------------------------------------------------
local function TryAttach()
    local btn = FindDelvesButton()
    if not btn then return false end

    frame:SetParent(btn)
    frame:SetFrameLevel(btn:GetFrameLevel() + 10)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", btn, "CENTER", 0, -28)
    frame:SetScale(0.9)

    UpdateCounts()
    frame:Show()
    return true
end

---------------------------------------------------------
-- Events
---------------------------------------------------------
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        if self.attachTicker then self.attachTicker:Cancel() end
        self.attachTicker = C_Timer.NewTicker(0.4, function(t)
            if TryAttach() then
                t:Cancel()
                self.attachTicker = nil
            end
        end)

        if EncounterJournal then
            EncounterJournal:HookScript("OnShow", function()
                if not self.attachTicker then
                    self.attachTicker = C_Timer.NewTicker(0.4, function(t)
                        if TryAttach() then
                            t:Cancel()
                            self.attachTicker = nil
                        end
                    end)
                end
            end)

            EncounterJournal:HookScript("OnHide", function()
                frame:Hide()
            end)
        end

    else
        UpdateCounts()
    end
end)
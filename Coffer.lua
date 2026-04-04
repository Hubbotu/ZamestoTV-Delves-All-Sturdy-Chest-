local addonName, addon = ...

---------------------------------------------------------
-- Main Frame
---------------------------------------------------------
local frame = CreateFrame("Frame", "CofferKeysAddon", UIParent)
frame:SetSize(220, 45)
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

frame.shardsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.shardsText:SetPoint("TOPLEFT", frame.keysText, "BOTTOMLEFT", 0, -2)
frame.shardsText:SetFont("Fonts\\FRIZQT__.TTF", 12)
frame.shardsText:SetShadowColor(0, 0, 0, 1)
frame.shardsText:SetShadowOffset(-1, -1)
frame.shardsText:SetTextColor(0.9, 0.9, 0.9)

---------------------------------------------------------
-- Quest Icon and Status
---------------------------------------------------------
frame.questIcon = frame:CreateTexture(nil, "OVERLAY")
frame.questIcon:SetSize(34, 34) 
frame.questIcon:SetPoint("RIGHT", frame.keysText, "LEFT", -25, 22)
frame.questIcon:SetTexture(1064187)

frame.questStatusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.questStatusText:SetPoint("TOP", frame.questIcon, "BOTTOM", 0, -2)
frame.questStatusText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

---------------------------------------------------------
-- IDs
---------------------------------------------------------
local DELVE_BUTTON_ATLAS = "UI-Journeys-Delve-Button"
local COFFER_KEY_ID = 3028
local SHARDS_ID     = 3310
local ITEM_ID       = 252415
local QUEST_ID      = 86371

---------------------------------------------------------
-- Update Logic
---------------------------------------------------------
local function UpdateCounts()
    -- Keys
    local keyInfo = C_CurrencyInfo.GetCurrencyInfo(COFFER_KEY_ID)
    local keys = keyInfo and keyInfo.quantity or 0
    frame.keysText:SetText("Keys: " .. keys)

    -- Shards
    local shardInfo = C_CurrencyInfo.GetCurrencyInfo(SHARDS_ID)
    if shardInfo and shardInfo.discovered then
        local weeklyEarned = shardInfo.quantityEarnedThisWeek or 0
        frame.shardsText:SetText("Shards: " .. weeklyEarned .. " / 600")
    else
        frame.shardsText:SetText("Shards: —")
    end

    -- Quest/Item Logic
    local hasItem = C_Item.GetItemCount(ITEM_ID) > 0
    local isQuestCompleted = C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID)

    if hasItem then
        frame.questStatusText:SetText("In the bag")
        frame.questStatusText:SetTextColor(1, 1, 0)
    elseif isQuestCompleted then
        frame.questStatusText:SetText("Completed")
        frame.questStatusText:SetTextColor(0, 1, 0)
    else
        frame.questStatusText:SetText("Not completed")
        frame.questStatusText:SetTextColor(1, 0, 0)
    end
end

---------------------------------------------------------
-- Find Delves Button & Attach
---------------------------------------------------------
local function FindDelvesButton()
    if not EncounterJournalJourneysFrame or not EncounterJournalJourneysFrame.JourneysList then return nil end
    local scrollTarget = EncounterJournalJourneysFrame.JourneysList.ScrollTarget
    if not scrollTarget then return nil end
    for _, child in ipairs({scrollTarget:GetChildren()}) do
        if child.GetNormalTexture then
            local tex = child:GetNormalTexture()
            if tex and tex.GetAtlas and tex:GetAtlas() == DELVE_BUTTON_ATLAS then return child end
        end
    end
    return nil
end

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
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_TURNED_IN")

frame:SetScript("OnEvent", function(self, event)
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
                        if TryAttach() then t:Cancel(); self.attachTicker = nil end
                    end)
                end
            end)
            EncounterJournal:HookScript("OnHide", function() frame:Hide() end)
        end
        C_Timer.After(1, UpdateCounts)
    else
        UpdateCounts()
    end
end)
local addonName, addon = ...

local frame = CreateFrame("Frame", "CofferKeysAddon", UIParent)
frame:SetSize(220, 45)
frame:SetFrameStrata("HIGH")
frame:Hide()

frame.keysText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.keysText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 9)
frame.keysText:SetFont("Fonts\\FRIZQT__.TTF", 13)
frame.keysText:SetTextColor(1, 0.85, 0.2)

frame.shardsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.shardsText:SetPoint("TOPLEFT", frame.keysText, "BOTTOMLEFT", 0, -2)
frame.shardsText:SetFont("Fonts\\FRIZQT__.TTF", 12)
frame.shardsText:SetTextColor(0.9, 0.9, 0.9)

frame.questIcon = frame:CreateTexture(nil, "OVERLAY")
frame.questIcon:SetSize(34, 34) 
frame.questIcon:SetPoint("RIGHT", frame.keysText, "LEFT", -25, 22)
frame.questIcon:SetTexture(1064187)

frame.questStatusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.questStatusText:SetPoint("TOP", frame.questIcon, "BOTTOM", 0, -2)
frame.questStatusText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

local DELVE_BUTTON_ATLAS = "UI-Journeys-Delve-Button"
local MIDNIGHT_BUTTON_ATLAS = "UI-Journeys-Midnight-Button"
local COFFER_KEY_ID = 3028
local SHARDS_ID     = 3310
local ITEM_ID       = 252415
local QUEST_ID      = 86371

local function UpdateCounts()
    local keyInfo = C_CurrencyInfo.GetCurrencyInfo(COFFER_KEY_ID)
    frame.keysText:SetText("Keys: " .. (keyInfo and keyInfo.quantity or 0))
    local shardInfo = C_CurrencyInfo.GetCurrencyInfo(SHARDS_ID)
    if shardInfo and shardInfo.discovered then
        frame.shardsText:SetText("Shards: " .. (shardInfo.quantityEarnedThisWeek or 0) .. " / 600")
    else
        frame.shardsText:SetText("Shards: —")
    end
    local hasItem = C_Item.GetItemCount(ITEM_ID) > 0
    if hasItem then
        frame.questStatusText:SetText("In the bag")
        frame.questStatusText:SetTextColor(1, 1, 0)
    elseif C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
        frame.questStatusText:SetText("Completed")
        frame.questStatusText:SetTextColor(0, 1, 0)
    else
        frame.questStatusText:SetText("Not completed")
        frame.questStatusText:SetTextColor(1, 0, 0)
    end
end

local function RefreshAttachment()
    if not EncounterJournal or not EncounterJournal:IsVisible() then 
        frame:Hide()
        return 
    end

    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    local scrollTarget = list and list.ScrollTarget
    if not scrollTarget then return end

    local foundBtn = nil
    for _, child in ipairs({scrollTarget:GetChildren()}) do
        if child.GetNormalTexture then
            local atlas = child:GetNormalTexture():GetAtlas()
            if atlas == DELVE_BUTTON_ATLAS or atlas == MIDNIGHT_BUTTON_ATLAS then
                foundBtn = child
                break
            end
        end
    end

    if foundBtn and foundBtn:IsVisible() then
        if frame:GetParent() ~= foundBtn then frame:SetParent(foundBtn) end
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", foundBtn, "CENTER", 0, -28)
        frame:SetScale(0.9)
        UpdateCounts()
        frame:Show()
    else
        frame:Hide()
    end
end

local function SetupHooks()
    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    if list then
        hooksecurefunc(list, "Update", RefreshAttachment)
        if list.ScrollBox then
            list.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, RefreshAttachment)
        end
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("QUEST_LOG_UPDATE")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_EncounterJournal" then
            SetupHooks()
        elseif arg1 == addonName and C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
            SetupHooks()
        end
    elseif frame:IsVisible() then
        UpdateCounts()
    end
end)
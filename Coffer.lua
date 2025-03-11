local addonName, addon = ...

local frame = CreateFrame("Frame", "CofferKeysAddon", UIParent)
frame:SetSize(30, 30)
frame:SetFrameStrata("MEDIUM")
frame.texture = frame:CreateTexture(nil, "ARTWORK")
frame.texture:SetAllPoints()
frame.texture:SetTexture(4622270) 

-- Create FontString for "keys" label, positioned 3 pixels above texture
frame.keysLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.keysLabel:SetPoint("BOTTOM", frame, "TOP", 0, 3)  -- 3 pixels above texture
frame.keysLabel:SetTextColor(1, 1, 1, 1)
frame.keysLabel:SetShadowColor(0, 0, 0, 1)
frame.keysLabel:SetShadowOffset(-1, -1)
frame.keysLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)  -- Added size 14 for consistency
frame.keysLabel:SetText("Keys")

-- Count text centered within the texture
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)  -- Centered in the 30x30 texture
frame.text:SetTextColor(1, 1, 1, 1)
frame.text:SetShadowColor(0, 0, 0, 1)
frame.text:SetShadowOffset(-1, -1)
frame.text:SetFont("Fonts\\FRIZQT__.TTF", 14)  -- Added size 14 for consistency

local function UpdateKeyCount()
    local keys = 0
    if C_QuestLog.IsQuestFlaggedCompleted(84736) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(84737) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(84738) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(84739) then keys = keys + 1 end
    frame.text:SetText(keys .. "/4")
end

local function PositionFrame()
    local anchorFrame = _G.DelvesDashboardFrame and _G.DelvesDashboardFrame.ButtonPanelLayoutFrame.GreatVaultButtonPanel
    if anchorFrame then
        frame:ClearAllPoints()
        frame:SetPoint("RIGHT", anchorFrame, "RIGHT", 80, 15)
        frame:SetParent(anchorFrame)
        frame:SetShown(anchorFrame:IsVisible())
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_UI_WIDGET")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        PositionFrame()
        UpdateKeyCount()
        if DelvesDashboardFrame then
            DelvesDashboardFrame:HookScript("OnShow", function() frame:Show() end)
            DelvesDashboardFrame:HookScript("OnHide", function() frame:Hide() end)
        end
    else
        UpdateKeyCount()
        PositionFrame()
    end
end)
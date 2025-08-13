local addonName, addon = ...

local frame = CreateFrame("Frame", "CofferKeysAddon", UIParent)
frame:SetSize(30, 30)
frame:SetFrameStrata("MEDIUM")
frame.texture = frame:CreateTexture(nil, "ARTWORK")
frame.texture:SetSize(30, 30)
frame.texture:SetPoint("CENTER", frame, "CENTER", -33, 0) -- Shift left by 2 pixels from -30 to -32
frame.texture:SetTexture(4622270) 

-- Create FontString for "keys" label, positioned 3 pixels above texture, centered over icon row
frame.keysLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.keysLabel:SetPoint("BOTTOM", frame, "TOP", 25.5, 3)  -- Centered at chain midpoint
frame.keysLabel:SetTextColor(1, 1, 1, 1)
frame.keysLabel:SetShadowColor(0, 0, 0, 1)
frame.keysLabel:SetShadowOffset(-1, -1)
frame.keysLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)
frame.keysLabel:SetWidth(100)  -- Set explicit width for consistency
frame.keysLabel:SetJustifyH("CENTER")  -- Center text
frame.keysLabel:SetText("Keys")

-- Count text to the right of the texture
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("LEFT", frame.texture, "RIGHT", 5, 0)  -- Positioned to the right of frame.texture
frame.text:SetTextColor(1, 1, 1, 1)  -- White, no color highlighting
frame.text:SetShadowColor(0, 0, 0, 1)
frame.text:SetShadowOffset(-1, -1)
frame.text:SetFont("Fonts\\FRIZQT__.TTF", 14)

-- Create FontString for "Radiant Echo" label, positioned 3 pixels below frame, centered over icon row
frame.radiantLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.radiantLabel:SetPoint("TOP", frame, "BOTTOM", 25.5, -3)  -- Centered at chain midpoint
frame.radiantLabel:SetTextColor(1, 1, 1, 1)
frame.radiantLabel:SetShadowColor(0, 0, 0, 1)
frame.radiantLabel:SetShadowOffset(-1, -1)
frame.radiantLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)
frame.radiantLabel:SetWidth(100)  -- Matching width with keysLabel
frame.radiantLabel:SetJustifyH("CENTER")  -- Center text
frame.radiantLabel:SetText("Radiant Echo")

-- Create textures for items 246771 and 245653
frame.item1Texture = frame:CreateTexture(nil, "ARTWORK")
frame.item1Texture:SetSize(30, 30)  -- 30x30 size
frame.item1Texture:SetPoint("TOP", frame.radiantLabel, "BOTTOM", 0, -3)  -- Below Radiant Echo label
frame.item1Texture:SetTexture("Interface\\Icons\\spell_holy_pureofheart")  -- Icon for item 246771

frame.item2Texture = frame:CreateTexture(nil, "ARTWORK")
frame.item2Texture:SetSize(30, 30)  -- 30x30 size
frame.item2Texture:SetPoint("LEFT", frame.text, "RIGHT", 5, 0)  -- To the right of frame.text
frame.item2Texture:SetTexture("Interface\\Icons\\inv_gizmo_hardenedadamantitetube")  -- Icon for item 245653

-- Create FontString for item 246771 quantity, to the right of the icon
frame.item1Quantity = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.item1Quantity:SetPoint("LEFT", frame.item1Texture, "RIGHT", 5, 0)  -- Positioned to the right of item1Texture
frame.item1Quantity:SetTextColor(1, 1, 1, 1)  -- White, no color highlighting
frame.item1Quantity:SetShadowColor(0, 0, 0, 1)
frame.item1Quantity:SetShadowOffset(-1, -1)
frame.item1Quantity:SetFont("Fonts\\FRIZQT__.TTF", 12)

-- Create FontString for item 245653 quantity with "/100", to the right of the icon
frame.item2Quantity = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.item2Quantity:SetPoint("LEFT", frame.item2Texture, "RIGHT", 5, 0)  -- Positioned to the right of item2Texture
frame.item2Quantity:SetTextColor(1, 1, 1, 1)  -- White, no color highlighting
frame.item2Quantity:SetShadowColor(0, 0, 0, 1)
frame.item2Quantity:SetShadowOffset(-1, -1)
frame.item2Quantity:SetFont("Fonts\\FRIZQT__.TTF", 12)

local function UpdateItemQuantities()
    local item1Count = GetItemCount(246771) or 0
    local item2Count = GetItemCount(245653) or 0
    frame.item1Quantity:SetText(item1Count)
    frame.item2Quantity:SetText(item2Count .. "\n/100")
end

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
        frame:SetPoint("RIGHT", anchorFrame, "RIGHT", 50, 15)
        frame:SetParent(anchorFrame)
        frame:SetShown(anchorFrame:IsVisible())
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_UI_WIDGET")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("BAG_UPDATE")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        PositionFrame()
        UpdateKeyCount()
        UpdateItemQuantities()
        if DelvesDashboardFrame then
            DelvesDashboardFrame:HookScript("OnShow", function() frame:Show() end)
            DelvesDashboardFrame:HookScript("OnHide", function() frame:Hide() end)
        end
    else
        UpdateKeyCount()
        UpdateItemQuantities()
        PositionFrame()
    end
end)
local addonName = ...

local levelFrame = CreateFrame("Frame", "ValeeraLevelTrackerFrame", UIParent)
levelFrame:SetSize(41, 41)
levelFrame:SetFrameStrata("HIGH")
levelFrame:Hide()

local circleMask = levelFrame:CreateMaskTexture()
circleMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortrait-Mask-WithSand", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
circleMask:SetSize(35, 35)
circleMask:SetPoint("CENTER", levelFrame, "CENTER", 0, 0)

levelFrame.bg = levelFrame:CreateTexture(nil, "BACKGROUND")
levelFrame.bg:SetSize(50, 50)
levelFrame.bg:SetPoint("CENTER", levelFrame, "CENTER", 0, 0)
levelFrame.bg:SetColorTexture(0.08, 0.08, 0.08, 0.9)
levelFrame.bg:AddMaskTexture(circleMask)

levelFrame.border = levelFrame:CreateTexture(nil, "OVERLAY")
levelFrame.border:SetSize(51, 51)
levelFrame.border:SetPoint("CENTER", levelFrame, "CENTER", 0, 0)
levelFrame.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

levelFrame.levelText = levelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
levelFrame.levelText:SetPoint("CENTER", levelFrame.bg, "CENTER", -8, 10)
levelFrame.levelText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
levelFrame.levelText:SetTextColor(1, 0.9, 0.2)
levelFrame.levelText:SetJustifyH("CENTER")
levelFrame.levelText:SetJustifyV("MIDDLE")

---------------------------------------------------------
-- 2. Valeera Sanguinar
---------------------------------------------------------
local function GetValeeraLevel()
    if not C_DelvesUI or not C_DelvesUI.GetFactionForCompanion then 
        return nil 
    end

    local factionID = C_DelvesUI.GetFactionForCompanion(nil)
    if not factionID or factionID == 0 then 
        return nil 
    end

    local rankInfo = C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks 
        and C_GossipInfo.GetFriendshipReputationRanks(factionID)

    return rankInfo and rankInfo.currentLevel or nil
end

local function UpdateLevelDisplay()
    local level = GetValeeraLevel()
    if level then
        levelFrame.levelText:SetText(level)
    end
end

---------------------------------------------------------
-- 3. Alignment (10px left, 15px down)
---------------------------------------------------------
local MIDNIGHT_BUTTON_ATLAS = "UI-Journeys-Midnight-Button"
local DELVE_BUTTON_ATLAS = "UI-Journeys-Delve-Button"

local function AttachToJourneysFrame()
    if not EncounterJournal or not EncounterJournal:IsVisible() then 
        levelFrame:Hide()
        return 
    end

    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    local scrollTarget = list and list.ScrollTarget
    if not scrollTarget then 
        levelFrame:Hide()
        return 
    end

    local targetButton = nil
    for _, child in ipairs({scrollTarget:GetChildren()}) do
        if child.GetNormalTexture then
            local atlas = child:GetNormalTexture():GetAtlas()
            if atlas == MIDNIGHT_BUTTON_ATLAS or atlas == DELVE_BUTTON_ATLAS then
                targetButton = child
                break
            end
        end
    end

    if targetButton and targetButton:IsVisible() then
        if levelFrame:GetParent() ~= targetButton then 
            levelFrame:SetParent(targetButton) 
        end
        levelFrame:ClearAllPoints()
        
        levelFrame:SetPoint("TOPRIGHT", targetButton, "TOPRIGHT", -12, -17)
        
        UpdateLevelDisplay()
        levelFrame:Show()
    else
        levelFrame:Hide()
    end
end

local function InitHooks()
    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    if list then
        hooksecurefunc(list, "Update", AttachToJourneysFrame)
        if list.ScrollBox then
            list.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, AttachToJourneysFrame)
        end
    end
end

---------------------------------------------------------
-- 4. Event logging
---------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("UPDATE_FACTION")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_EncounterJournal" then
            InitHooks()
        elseif arg1 == addonName and C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
            InitHooks()
        end
    elseif event == "UPDATE_FACTION" then
        if levelFrame:IsVisible() then
            UpdateLevelDisplay()
        end
    end
end)
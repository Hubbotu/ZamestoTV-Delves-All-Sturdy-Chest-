local addonName, addon = ...
local JourneyTracker = CreateFrame("Frame")

local TARGET_ACHIEVEMENT_ID = 63717
local MAX_CHESTS = 44

local Container = nil
local TotalText = nil
local AvailableText = nil

local function GetAchievementProgress(achievementID)
    local numCriteria = GetAchievementNumCriteria(achievementID) or 0
    local completedCount = 0

    if numCriteria > 0 then
        for i = 1, numCriteria do
            local _, _, completed, quantity = GetAchievementCriteriaInfo(achievementID, i)
            if completed then
                completedCount = completedCount + 1
            elseif quantity and quantity > 0 then
                completedCount = completedCount + quantity
            end
        end
        if completedCount > 0 then return completedCount end
    end

    local _, _, _, completed, _, _, _, _, _, _, _, _, _, _, progress = GetAchievementInfo(achievementID)
    if completed then return MAX_CHESTS end
    
    if type(progress) == "number" and progress > 0 then
        return progress
    end

    return completedCount
end

local function ScanFrameForData(frame)
    if not frame then return false, 0 end
    
    local hasKindo = false
    local level = 0

    if frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if region:IsObjectType("FontString") then
                local text = region:GetText()
                if text then
                    if text:find("Kindo'jan") or text:find("Киндо'джан") or text:find("Labyrinth") or text:find("Лабиринт") then
                        hasKindo = true
                    end
                    local lvl = text:match("(%d+)%s*/%s*9")
                    if lvl then
                        local nLvl = tonumber(lvl)
                        if nLvl and nLvl >= 1 and nLvl <= 9 then
                            level = nLvl
                        end
                    end
                end
            end
        end
    end

    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            local name = child:GetName() or ""
            if not name:find("JourneyShadowsTrackerContainer") then
                local childHasKindo, childLevel = ScanFrameForData(child)
                if childHasKindo then hasKindo = true end
                if childLevel > 0 then level = childLevel end
            end
        end
    end

    return hasKindo, level
end

local function FindKindoJanCardAndLevel()
    local scrollTarget = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList and EncounterJournalJourneysFrame.JourneysList.ScrollTarget
    if not scrollTarget then return nil, 0 end

    for _, child in ipairs({ scrollTarget:GetChildren() }) do
        if child:IsObjectType("Button") and child:IsShown() then
            local hasKindo, level = ScanFrameForData(child)
            if hasKindo then
                return child, level
            end
        end
    end

    return nil, 0
end

local function GetAvailableChestsByLevel(level)
    if level == 1 or level == 2 then return 24
    elseif level == 3 or level == 4 then return 30
    elseif level == 5 or level == 6 then return 34
    elseif level == 7 or level == 8 then return 38
    elseif level >= 9 then return 44 end
    return 0
end

local function EnsureTrackerUI(parentFrame)
    if not Container then
        Container = CreateFrame("Frame", "JourneyShadowsTrackerContainer", parentFrame)
        Container:SetSize(300, 46)

        TotalText = Container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        TotalText:SetPoint("TOPLEFT", Container, "TOPLEFT", 0, 0)
        TotalText:SetJustifyH("LEFT")

        AvailableText = Container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        AvailableText:SetPoint("TOPLEFT", TotalText, "BOTTOMLEFT", 0, -4)
        AvailableText:SetJustifyH("LEFT")
    end
end

local function UpdateDisplay()
    local journeysList = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    if not journeysList or not journeysList:IsVisible() then
        if Container then Container:Hide() end
        return
    end

    local cardFrame, level = FindKindoJanCardAndLevel()

    if not cardFrame or not cardFrame:IsVisible() then
        if Container then Container:Hide() end
        return
    end

    EnsureTrackerUI(cardFrame)

    if Container:GetParent() ~= cardFrame then
        Container:SetParent(cardFrame)
    end

    if not TotalText or not AvailableText then return end

    Container:ClearAllPoints()
    Container:SetPoint("TOPLEFT", cardFrame, "TOPLEFT", 50, -50)

    local currentProgress = GetAchievementProgress(TARGET_ACHIEVEMENT_ID)
    local availableChests = GetAvailableChestsByLevel(level)

    TotalText:SetText(string.format("Total Chests: |cffffd100%02d/%d|r", currentProgress, MAX_CHESTS))

    if level > 0 then
        AvailableText:SetText(string.format("Currently Available: |cff00ff00%d of %d|r (Level %d/9)", availableChests, MAX_CHESTS, level))
    else
        AvailableText:SetText(string.format("Currently Available: |cff00ff00%d of %d|r", availableChests, MAX_CHESTS))
    end

    Container:Show()
end

local function SetupHooks()
    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    if list then
        hooksecurefunc(list, "Update", function()
            UpdateDisplay()
            C_Timer.After(0.05, UpdateDisplay)
        end)
        hooksecurefunc(list, "Show", function()
            UpdateDisplay()
            C_Timer.After(0.05, UpdateDisplay)
        end)

        if list.ScrollBox then
            list.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, UpdateDisplay)
            list.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnLayout, UpdateDisplay)
        end
    end
end

JourneyTracker:RegisterEvent("ADDON_LOADED")
JourneyTracker:RegisterEvent("CRITERIA_UPDATE")
JourneyTracker:RegisterEvent("ACHIEVEMENT_EARNED")
JourneyTracker:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_EncounterJournal" then
            SetupHooks()
        elseif arg1 == addonName and C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
            SetupHooks()
        end
    end

    UpdateDisplay()
end)
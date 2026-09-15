local addonName, addon = ...
local DelveApp = { UI = {} }

DelveApp.Zones = {
    ["Eversong Woods / Silvermoon City"] = {
        {id = 93372, name = "Delver's Call: Shadow Enclave"},
        {id = 93384, name = "Delver's Call: Collegiate Calamity"},
        {id = 93385, name = "Delver's Call: The Darkway"},
        {id = 93386, name = "Delver's Call: Parhelion Plaza"},
    },
    ["Harandar"] = {
        {id = 93416, name = "Delver's Call: The Gulf of Memory"},
        {id = 93421, name = "Delver's Call: The Grudge Pit"},
    },
    ["Zul'Aman"] = {
        {id = 93409, name = "Delver's Call: Atal'Aman"},
        {id = 93410, name = "Delver's Call: Twilight Crypts"},
    },
    ["Voidstorm"] = {
        {id = 93428, name = "Delver's Call: Shadowguard Point"},
        {id = 93427, name = "Delver's Call: Sunkiller Sanctum"},
    }
}

DelveApp.XPSteps = {
    [80] = 403725, [81] = 423390, [82] = 443395, [83] = 463740, [84] = 484430,
    [85] = 505455, [86] = 526825, [87] = 548535, [88] = 570590, [89] = 592980,
}

DelveApp.Config = {
    Tag = "delver's call",
    Spells = { 
        Winds = 1214848, 
        Surge = 1221184, 
        WmA = 269083, 
        WmB = 282559, 
        DMF = 46668 
    },
    Mentors = { 
        {42332, 0.25}, 
        {42331, 0.20}, 
        {42330, 0.15}, 
        {42329, 0.10}, 
        {42328, 0.05} 
    },
    Atlases = { "UI-Journeys-Midnight-Button", "UI-Journeys-Delve-Button" }
}

----------------------------------------------------
-- Helper & Buff Functions
----------------------------------------------------
function DelveApp:CheckPlayerAura(id)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        local ok, data = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
        return ok and data ~= nil
    end
    return false
end

function DelveApp:IsDarkmoonFaireActive()
    local dateTable = date("*t")
    local day = dateTable.day
    local wday = dateTable.wday
    local firstSunday = ((8 - wday) % 7) + 1
    local dmfEnd = firstSunday + 6
    return day >= firstSunday and day <= dmfEnd
end

function DelveApp:FetchMentorBonus()
    for _, info in ipairs(self.Config.Mentors) do
        local _, _, _, done = GetAchievementInfo(info[1])
        if done then return info[2] end
    end
    return 0
end

function DelveApp:IsWarModeActive()
    if C_PvP and C_PvP.IsWarModeDesired then 
        return C_PvP.IsWarModeDesired() 
    end
    return self:CheckPlayerAura(self.Config.Spells.WmA) or self:CheckPlayerAura(self.Config.Spells.WmB)
end

function DelveApp:IsTurnInReady(qID)
    return C_QuestLog.IsComplete(qID) or (C_QuestLog.ReadyForTurnIn and C_QuestLog.ReadyForTurnIn(qID)) or false
end

function DelveApp:GetCapXP(level)
    return level < 80 and UnitXPMax("player") or (self.XPSteps[level] or 592980)
end

----------------------------------------------------
-- Quest & XP Computation Logic
----------------------------------------------------
function DelveApp:GetQuestCounts()
    local avail, ready, done, total = 0, 0, 0, 0

    for _, list in pairs(self.Zones) do
        for _, quest in ipairs(list) do
            total = total + 1
            local id = quest.id
            if C_QuestLog.IsQuestFlaggedCompleted(id) then
                done = done + 1
            elseif C_QuestLog.IsOnQuest(id) and self:IsTurnInReady(id) then
                ready = ready + 1
            else
                avail = avail + 1
            end
        end
    end

    return avail, ready, done, total
end

function DelveApp:CalculateXPGain()
    local lvl = UnitLevel("player")
    if lvl < 80 or lvl >= 90 then return nil end

    local buffMultiplier = 0.0
    buffMultiplier = buffMultiplier + self:FetchMentorBonus()

    if self:CheckPlayerAura(self.Config.Spells.Winds) then
        buffMultiplier = buffMultiplier + 0.20
    end
    if self:CheckPlayerAura(self.Config.Spells.Surge) then
        buffMultiplier = buffMultiplier + 0.10
    end
    if self:IsDarkmoonFaireActive() and self:CheckPlayerAura(self.Config.Spells.DMF) then
        buffMultiplier = buffMultiplier + 0.10
    end

    local zoneID = C_Map.GetBestMapForUnit("player")
    local isSilvermoonZone = (zoneID == 2393)
    local wmActive = self:IsWarModeActive() and not isSilvermoonZone
    local wmBonus = 0.10
    if C_PvP and C_PvP.GetWarModeRewardBonus then
        local rawBonus = C_PvP.GetWarModeRewardBonus() or 0
        if rawBonus > 0 then wmBonus = rawBonus / 100 end
    end

    local finalMultiplier = 1.00 + buffMultiplier + (wmActive and wmBonus or 0.0)

    local readyXP = 0
    local questCount = 0

    local trackedIDs = {}
    for _, list in pairs(self.Zones) do
        for _, quest in ipairs(list) do
            if quest.id then
                trackedIDs[quest.id] = true
            end
        end
    end

    local entries = C_QuestLog.GetNumQuestLogEntries()
    for i = 1, entries do
        local q = C_QuestLog.GetInfo(i)
        if q and not q.isHeader and not q.isHidden then
            local titleLower = q.title and q.title:lower() or ""
            local isTagQuest = string.find(titleLower, self.Config.Tag, 1, true) ~= nil
            local isTrackedQuest = trackedIDs[q.questID] == true

            if (isTagQuest or isTrackedQuest) and self:IsTurnInReady(q.questID) then
                local rawVal = GetQuestLogRewardXP(q.questID) or 0
                if rawVal > 0 then
                    readyXP = readyXP + rawVal
                    questCount = questCount + 1
                end
            end
        end
    end

    if questCount == 0 then return nil end

    local simLvl = lvl
    local simXP = UnitXP("player") + readyXP

    while simLvl < 90 do
        local required = self:GetCapXP(simLvl)
        if simXP < required then break end
        simXP = simXP - required
        simLvl = simLvl + 1
    end

    local nextTargetXP = (simLvl >= 90) and 0 or self:GetCapXP(simLvl)
    local progressPct = (nextTargetXP > 0) and ((simXP / nextTargetXP) * 100) or 100.0

    return {
        count = questCount,
        totalXP = readyXP,
        startLevel = lvl,
        endLevel = simLvl,
        leftoverXP = simXP,
        maxXP = nextTargetXP,
        progressPct = progressPct
    }
end

----------------------------------------------------
-- UI Integration into Journal
----------------------------------------------------
function DelveApp.UI:Refresh()
    local playerLvl = UnitLevel("player")
    if playerLvl < 80 or playerLvl >= 90 then
        if self.Host then self.Host:Hide() end
        return
    end

    if not self.Host or not self.Host:IsVisible() then return end

    local avail, ready, done = DelveApp:GetQuestCounts()
    self.Text1:SetText(string.format(
        "|cffffd100Delver's Call:|r Available: |cffffffff%d|r | Ready: |cff00ff00%d|r | Turned In: |cff808080%d|r",
        avail, ready, done
    ))

    local stats = DelveApp:CalculateXPGain()
    if stats and stats.count > 0 then
        if stats.endLevel >= 90 then
            self.Text2:SetText(string.format(
                "|cffffd100XP (%d Quests):|r +%s XP (|cff00ff00Reaches Lvl 90!|r)",
                stats.count, BreakUpLargeNumbers(stats.totalXP)
            ))
        else
            self.Text2:SetText(string.format(
                "|cffffd100XP (%d Quests):|r +%s XP -> |cff00ff00Lvl %d|r (|cffffd100%.1f%%|r)",
                stats.count, BreakUpLargeNumbers(stats.totalXP), stats.endLevel, stats.progressPct
            ))
        end
    else
        self.Text2:SetText("|cffffd100XP:|r No completed quests ready")
    end
end

function DelveApp.UI:AttachToJournal()
    local lvl = UnitLevel("player")
    if lvl < 80 or lvl >= 90 then
        if self.Host then self.Host:Hide() end
        return
    end

    if not EncounterJournal or not EncounterJournal:IsVisible() then return end

    local scrollTarget = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList and EncounterJournalJourneysFrame.JourneysList.ScrollTarget
    if not scrollTarget then return end

    local parentFrame = nil
    for _, item in ipairs({scrollTarget:GetChildren()}) do
        if item.GetNormalTexture then
            local atlas = item:GetNormalTexture():GetAtlas()
            for _, targetAtlas in ipairs(DelveApp.Config.Atlases) do
                if atlas == targetAtlas then
                    parentFrame = item
                    break
                end
            end
        end
        if parentFrame then break end
    end

    if parentFrame and parentFrame:IsVisible() then
        if not self.Host then
            self.Host = CreateFrame("Frame", "ZamestoTVDelversCallContainer", parentFrame)
            self.Host:SetSize(320, 40)
            self.Host:SetPoint("CENTER", parentFrame, "CENTER", 40, 7)

            self.Text1 = self.Host:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            self.Text1:SetPoint("TOPLEFT", self.Host, "TOPLEFT", 0, 0)
            self.Text1:SetJustifyH("LEFT")

            self.Text2 = self.Host:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            self.Text2:SetPoint("TOPLEFT", self.Text1, "BOTTOMLEFT", 0, -4)
            self.Text2:SetJustifyH("LEFT")
        else
            if self.Host:GetParent() ~= parentFrame then
                self.Host:SetParent(parentFrame)
            end
            self.Host:SetPoint("CENTER", parentFrame, "CENTER", 40, 7)
        end

        self.Host:Show()
        self:Refresh()
    elseif self.Host then
        self.Host:Hide()
    end
end

----------------------------------------------------
-- Event Handlers & Hooks
----------------------------------------------------
local function BindHooks()
    local journeys = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    if journeys then
        hooksecurefunc(journeys, "Update", function() DelveApp.UI:AttachToJournal() end)
        if journeys.ScrollBox then
            journeys.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, function() DelveApp.UI:AttachToJournal() end)
        end
    end
end

local Listener = CreateFrame("Frame")
Listener:RegisterEvent("ADDON_LOADED")
Listener:RegisterEvent("PLAYER_LEVEL_UP")
Listener:RegisterEvent("QUEST_LOG_UPDATE")
Listener:RegisterEvent("QUEST_TURNED_IN")
Listener:RegisterEvent("PLAYER_XP_UPDATE")
Listener:RegisterEvent("UNIT_AURA")

Listener:SetScript("OnEvent", function(_, event, arg1)
    if event == "UNIT_AURA" and arg1 ~= "player" then return end

    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_EncounterJournal" or (arg1 == addonName and C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal")) then
            BindHooks()
        end
    end

    if event == "PLAYER_LEVEL_UP" and arg1 >= 90 then
        if DelveApp.UI.Host then DelveApp.UI.Host:Hide() end
        return
    end

    if DelveApp.UI.Host and DelveApp.UI.Host:IsVisible() then
        DelveApp.UI:Refresh()
    end
end)
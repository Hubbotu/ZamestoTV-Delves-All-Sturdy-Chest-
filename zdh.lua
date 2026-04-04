-- Bountiful Delves Tracker Addon for WoW 12.0: Midnight
-- Saved Variables
ZDH_SavedVars = ZDH_SavedVars or {
    mode = 1, -- 1 = Default, 2 = Minimalist, 3 = Anchor
    autohide = false,
    isMinimized = false,
    wasVisible = true,
    position = { x = 0, y = 0 },
}

-- Global Scripting Table
ZDH_GlobalScripting = {}

-- Core Functionality
function ZDH_GlobalScripting:IsWeeklyRewardForDelvesFull()
    local worldActivitiesRewards = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    local bestReward = worldActivitiesRewards[3]
    return bestReward and bestReward.level == 8 or false
end

function ZDH_GlobalScripting:GetShowValue(mode, wantVisible, ...)
    local args = {...}
    local allTrue = true
    if mode ~= ZDH_SavedVars.mode then
        return false
    end
    for _, value in ipairs(args) do
        if not value then
            allTrue = false
            break
        end
    end
    if ZDH_SavedVars.autohide then
        local done = ZDH_GlobalScripting:IsWeeklyRewardForDelvesFull()
        return allTrue and wantVisible and not done
    end
   
    return allTrue and wantVisible
end

-- Delve Progress Functions
local function GetLevel8DelvesDoneCount()
    local worldActivities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    for i = 2, 1, -1 do
        local activity = worldActivities[i]
        if activity and activity.level >= 8 then
            return activity.progress
        end
    end
    return "?"
end

local function GetDelveRewardLevel(index)
    local worldActivitiesRewards = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    local reward = worldActivitiesRewards[index]
    return reward and reward.level or "?"
end

-- Key Tracking
local function GetKeyNumber()
    local keys = "|T4622270:20|t Keys: "
    local keyInfos = C_CurrencyInfo.GetCurrencyInfo(3028) -- Delve Key Currency ID
    keys = keys .. (keyInfos.quantity == 0 and "|cFFFF0000" or "") .. keyInfos.quantity .. "|r"
    return keys
end

-- Shards (3310) — WEEKLY MAX / 600
local function GetShardsText()
    local shardInfo = C_CurrencyInfo.GetCurrencyInfo(3310)
    if shardInfo and shardInfo.discovered then
        local weeklyEarned = shardInfo.quantityEarnedThisWeek or 0
        local WEEKLY_CAP = 600
        return "Shards: |cFF00FF00" .. weeklyEarned .. "|r / " .. WEEKLY_CAP
    else
        return "Shards: —"
    end
end

-- Delve List Management
local DelvesBountifulList = {
    Zones = {
        ["Voidstorm"] = { uiMapID = 2405, delves = {{id = 8432, name = "Shadowguard Point"}, {id = 8430, name = "Sunkiller Sanctum"}} },
        ["Harandar"] = { uiMapID = 2413, delves = {{id = 8436, name = "The Gulf of Memory"}, {id = 8434, name = "The Grudge Pit"}} },
        ["Zul'Aman"] = { uiMapID = 2437, delves = {{id = 8444, name = "Atal'Aman"}, {id = 8442, name = "Twilight Crypts"}} },
        ["Eversong Woods"] = { uiMapID = 2395, delves = {{id = 8438, name = "Shadow Enclave"}} },
        ["Silvermoon City"] = { uiMapID = 2393, delves = {{id = 8426, name = "Collegiate Calamity"}, {id = 8440, name = "The Darkway"}} },
        ["Isle of Quel'Danas"] = { uiMapID = 2424, delves = {{id = 8428, name = "Parhelion Plaza"}} },
    }
}

function DelvesBountifulList:GetMapAtZoneLevel3(uiMapID)
    local mapInfo = C_Map.GetMapInfo(uiMapID)
    if mapInfo and mapInfo.mapType > 3 and mapInfo.parentMapID > 0 then
        return self:GetMapAtZoneLevel3(mapInfo.parentMapID)
    end
    return uiMapID
end

function DelvesBountifulList:GetBountifulDelves()
    local bountifulDelves, addedDelves = {}, {}
    for _, zoneData in pairs(self.Zones) do
        for _, delve in ipairs(zoneData.delves) do
            if not addedDelves[delve.id] then
                local areaPoiInfo = C_AreaPoiInfo.GetAreaPOIInfo(zoneData.uiMapID, delve.id)
                if areaPoiInfo then
                    table.insert(bountifulDelves, areaPoiInfo)
                    addedDelves[delve.id] = true
                end
            end
        end
    end
    return bountifulDelves
end

function DelvesBountifulList:GetActiveDelveTimer()
    return GetQuestResetTime()
end

function DelvesBountifulList:LayoutText()
    local allDelves = self:GetBountifulDelves()
    local text = ""
    
    local blueDelves = {
        ["Shadowguard Point"] = true, ["Sunkiller Sanctum"] = true,
        ["The Gulf of Memory"] = true, ["The Grudge Pit"] = true,
        ["Atal'Aman"] = true, ["Twilight Crypts"] = true,
        ["Shadow Enclave"] = true,
        ["Collegiate Calamity"] = true, ["The Darkway"] = true,
        ["Parhelion Plaza"] = true,
    }

    for zoneName, zoneData in pairs(self.Zones) do
        local zoneInfo = C_Map.GetMapInfo(zoneData.uiMapID)
        if zoneInfo and self:ZoneHasDelves(zoneData.delves, allDelves) then
            if text ~= "" then 
                text = text .. "\n" 
            end
            text = text .. "|cffffd700" .. zoneInfo.name .. "|r\n"
            
            for _, delve in ipairs(zoneData.delves) do
                for _, otherDelve in ipairs(allDelves) do
                    if delve.id == otherDelve.areaPoiID then
                        local color = blueDelves[otherDelve.name] and "|cADD8E6FF" or "|cffffffff"
                        text = text .. color .. otherDelve.name .. "|r\n"
                        break
                    end
                end
            end
        end
    end
    return text
end

function DelvesBountifulList:ZoneHasDelves(zoneDelves, allDelvesList)
    for _, delve in ipairs(zoneDelves) do
        for _, activeDelve in ipairs(allDelvesList) do
            if delve.id == activeDelve.areaPoiID then
                return true
            end
        end
    end
    return false
end

-- UI Frame Creation
local ZDH = CreateFrame("Frame", "ZDHFrame", UIParent)
ZDH:SetSize(210, 340)
ZDH:SetPoint("CENTER", UIParent, "CENTER", ZDH_SavedVars.position.x, ZDH_SavedVars.position.y)
ZDH:SetMovable(true)
ZDH:EnableMouse(true)
ZDH:RegisterForDrag("LeftButton")
ZDH:SetScript("OnDragStart", ZDH.StartMoving)
ZDH:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    ZDH_SavedVars.position.x = x - GetScreenWidth() / 2
    ZDH_SavedVars.position.y = y - GetScreenHeight() / 2
end)
ZDH:Hide()

-- Background and Border
ZDH.bg = ZDH:CreateTexture(nil, "BACKGROUND")
ZDH.bg:SetAllPoints()
ZDH.bg:SetColorTexture(0, 0, 0, 0.5)

ZDH.border = CreateFrame("Frame", nil, ZDH, "BackdropTemplate")
ZDH.border:SetAllPoints()
ZDH.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10})
ZDH.border:SetBackdropBorderColor(0, 0, 0, 1)

-- Title
ZDH.title = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.title:SetPoint("TOP", ZDH, "TOP", 0, -10)
ZDH.title:SetText("Delves Helper Tracker")

-- Minimize/Maximize Button
ZDH.toggleButton = CreateFrame("Button", nil, ZDH)
ZDH.toggleButton:SetSize(24, 24)
ZDH.toggleButton:SetPoint("TOPRIGHT", ZDH, "TOPRIGHT", -5, -5)
ZDH.toggleButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
ZDH.toggleButton:SetScript("OnClick", function()
    ZDH_SavedVars.isMinimized = not ZDH_SavedVars.isMinimized
    ZDH:UpdateUI()
end)

-- Text elements
ZDH.progressText = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
ZDH.progressText:SetPoint("TOPLEFT", ZDH, "TOPLEFT", 10, -40)
ZDH.progressText:SetJustifyH("LEFT")

ZDH.rewardText1 = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.rewardText1:SetPoint("TOPLEFT", ZDH.progressText, "BOTTOMLEFT", 0, -10)

ZDH.rewardText2 = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.rewardText2:SetPoint("TOPLEFT", ZDH.rewardText1, "BOTTOMLEFT", 0, -5)

ZDH.rewardText3 = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.rewardText3:SetPoint("TOPLEFT", ZDH.rewardText2, "BOTTOMLEFT", 0, -5)

ZDH.delveList = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.delveList:SetPoint("TOPLEFT", ZDH.rewardText3, "BOTTOMLEFT", 0, -15)
ZDH.delveList:SetJustifyH("LEFT")
ZDH.delveList:SetWidth(180)

ZDH.keysText = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.keysText:SetPoint("TOPLEFT", ZDH.delveList, "BOTTOMLEFT", 0, -15)

ZDH.shardsText = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.shardsText:SetPoint("TOPLEFT", ZDH.keysText, "BOTTOMLEFT", 0, -5)

ZDH.timerText = ZDH:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ZDH.timerText:SetPoint("TOPLEFT", ZDH.shardsText, "BOTTOMLEFT", 0, -8)

-- Update UI
function ZDH:UpdateUI(forceShow)
    local mode = ZDH_SavedVars.mode
    local shouldBeVisible = forceShow or ZDH_SavedVars.wasVisible
   
    local show = ZDH_GlobalScripting:GetShowValue(
        mode,
        shouldBeVisible,
        not ZDH_SavedVars.isMinimized
    )
    if not show then
        ZDH:Hide()
        return
    end

    ZDH:Show()
    ZDH.toggleButton:SetNormalTexture(
        ZDH_SavedVars.isMinimized and "Interface\\Buttons\\UI-PlusButton-Up"
                                 or "Interface\\Buttons\\UI-MinusButton-Up"
    )

    if mode == 1 then
        ZDH.progressText:SetText("Level 8+: " .. GetLevel8DelvesDoneCount())
        ZDH.rewardText1:SetText("Reward 1: " .. GetDelveRewardLevel(1))
        ZDH.rewardText2:SetText("Reward 2: " .. GetDelveRewardLevel(2))
        ZDH.rewardText3:SetText("Reward 3: " .. GetDelveRewardLevel(3))
    elseif mode == 2 then
        ZDH.progressText:SetText("8+: " .. GetLevel8DelvesDoneCount())
        ZDH.rewardText1:SetText(GetDelveRewardLevel(1))
        ZDH.rewardText2:SetText("/ " .. GetDelveRewardLevel(2))
        ZDH.rewardText3:SetText("/ " .. GetDelveRewardLevel(3))
    elseif mode == 3 then
        if _G["DelvesDashboardFrame"] and _G["DelvesDashboardFrame"]:IsShown() then
            ZDH:SetParent(DelvesDashboardFrame)
            ZDH:ClearAllPoints()
            ZDH:SetPoint("RIGHT", DelvesDashboardFrame, "RIGHT", 10, -25)
        else
            ZDH:Hide()
            return
        end
    end

    -- Common elements
    ZDH.delveList:SetText(DelvesBountifulList:LayoutText())
    ZDH.keysText:SetText(GetKeyNumber())
    ZDH.shardsText:SetText(GetShardsText())
end

-- Real-Time Timer
ZDH:SetScript("OnUpdate", function(self, elapsed)
    if self:IsShown() then
        local timer = DelvesBountifulList:GetActiveDelveTimer()
        self.timerText:SetText("|cFF00FF00Daily Reset: |r" .. SecondsToTime(timer))
    end
end)

-- Restore state on load
ZDH:RegisterEvent("PLAYER_ENTERING_WORLD")
ZDH:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0.5, function()
            self:UpdateUI()
        end)
    elseif self:IsShown() then
        self:UpdateUI()
    end
end)

-- Slash Command
SLASH_ZDH1 = "/zdh"
SlashCmdList["ZDH"] = function(msg)
    msg = (msg or ""):trim():lower()
    if msg == "hide" then
        ZDH_SavedVars.wasVisible = false
        ZDH:Hide()
        return
    elseif msg == "show" then
        ZDH_SavedVars.wasVisible = true
        ZDH_SavedVars.isMinimized = false
        ZDH:UpdateUI(true)
        return
    elseif msg == "reset" then
        ZDH_SavedVars.isMinimized = false
        ZDH_SavedVars.wasVisible = true
        ZDH_SavedVars.position = { x = 0, y = 0 }
        ZDH:ClearAllPoints()
        ZDH:SetPoint("CENTER")
        ZDH:UpdateUI(true)
        print("|cFF00FF00Delves Helper Tracker|r reset to center.")
        return
    end

    -- Default toggle
    if ZDH:IsShown() then
        ZDH_SavedVars.wasVisible = false
        ZDH:Hide()
    else
        ZDH_SavedVars.wasVisible = true
        ZDH_SavedVars.isMinimized = false
        ZDH:UpdateUI(true)
        if not ZDH:IsShown() then
            print("|cFF00FF00Delves Helper Tracker|r is hidden due to weekly complete + autohide. Use /zdh show to override.")
        end
    end
end

-- Initial load message
print("|cFF00FF00Delves Helper Tracker|r loaded. Use /zdh to toggle • /zdh show • /zdh hide • /zdh reset")
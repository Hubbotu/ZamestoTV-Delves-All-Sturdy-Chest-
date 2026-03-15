-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")

-- Main UI frame
local questFrame = CreateFrame("Frame", "DelversQuestTrackerFrame", UIParent, "DialogBoxFrame")
questFrame:SetSize(420, 320)
questFrame:SetPoint("CENTER")
questFrame:SetMovable(true)
questFrame:EnableMouse(true)
questFrame:RegisterForDrag("LeftButton")
questFrame:SetScript("OnDragStart", questFrame.StartMoving)
questFrame:SetScript("OnDragStop", questFrame.StopMovingOrSizing)
questFrame:Hide()

questFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

-- Tab system
local tabs = {}
local currentTab = nil

-- Function to create a tab
local function CreateTab(name, index)
    local tab = CreateFrame("Button", nil, questFrame, "UIPanelButtonTemplate")
    tab:SetSize(120, 28)
    tab:SetPoint("TOPRIGHT", questFrame, "TOPLEFT", -8, -35 - (index - 1) * 30)
    
    tab:SetText(name)
    tab:GetFontString():SetTextColor(0.7, 0.7, 0.7)  -- inactive by default
    
    tab:SetScript("OnClick", function(self)
        if currentTab == self then return end
        
        if currentTab then
            currentTab.content:Hide()
            currentTab:GetFontString():SetTextColor(0.7, 0.7, 0.7)
        end
        
        self.content:Show()
        self:GetFontString():SetTextColor(1.0, 1.0, 1.0)
        currentTab = self
        
        -- Update content when switching
        if UpdateVisibleTab then
            UpdateVisibleTab()
        end
    end)
    
    -- Content (scroll + text)
    local scroll = CreateFrame("ScrollFrame", nil, questFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", questFrame, "TOPLEFT", 14, -32)
    scroll:SetPoint("BOTTOMRIGHT", questFrame, "BOTTOMRIGHT", -28, 14)
    
    local child = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(child)
    child:SetSize(360, 300)
    
    local text = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetSpacing(2)
    text:SetWidth(360)
    
    tab.content = scroll
    tab.text = text
    
    tabs[name] = tab
    return tab
end

-- Data: The War Within
local warWithinData = {
    ["Isle of Dorn"] = {
        {id = 85648, name = "Delver's Call: Earthcrawl Mines"},
        {id = 83759, name = "Delver's Call: Kriegval's Rest"},
        {id = 83758, name = "Delver's Call: Fungal Folly"},
    },
    ["Hallowfall"] = {
        {id = 83768, name = "Delver's Call: The Skittering Breach"},
        {id = 85664, name = "Delver's Call: Nightfall Sanctum"},
        {id = 83767, name = "Delver's Call: The Sinkhole"},
        {id = 83769, name = "Delver's Call: Mycomancer Cavern"},
    },
    ["The Ringing Deeps"] = {
        {id = 85649, name = "Delver's Call: The Waterworks"},
        {id = 83766, name = "Delver's Call: The Dread Pit"},
    },
    ["Azj-Kahet"] = {
        {id = 83770, name = "Delver's Call: The Spiral Weave"},
        {id = 83771, name = "Delver's Call: Tak'Rethan Abyss"},
        {id = 85667, name = "Delver's Call: The Underkeep"},
    }
}

-- Data: Midnight
local midnightData = {
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

-- Generate formatted text
local function GenerateStatusText(dataTable)
    local output = ""
    for zone, quests in pairs(dataTable) do
        output = output .. "|cffffcc00" .. zone .. "|r\n"
        for _, quest in ipairs(quests) do
            if C_QuestLog.IsQuestFlaggedCompleted(quest.id) then
                output = output .. "  • " .. quest.name .. ": |cff00ff00Completed|r\n"
            else
                output = output .. "  • " .. quest.name .. ": |cffff0000Not Completed|r\n"
            end
        end
        output = output .. "\n"
    end
    return output or "No data"
end

-- Check if in raid/dungeon
local function IsInRaidOrDungeon()
    local _, instanceType = IsInInstance()
    return instanceType == "raid" or instanceType == "dungeon"
end

-- Main update function
function UpdateVisibleTab()
    if not currentTab or not currentTab.text then return end
    
    if IsInRaidOrDungeon() then
        currentTab.text:SetText("|cffff8800Tracking disabled in instances|r")
    else
        local data = (currentTab:GetText() == "The War Within") and warWithinData or midnightData
        currentTab.text:SetText(GenerateStatusText(data))
    end
    
    currentTab.content:UpdateScrollChildRect()
end

-- Create tabs
local tabWarWithin = CreateTab("The War Within", 1)
local tabMidnight   = CreateTab("Midnight", 2)

-- Initial content fill
tabWarWithin.text:SetText(GenerateStatusText(warWithinData))
tabMidnight.text:SetText(GenerateStatusText(midnightData))

-- Show function with switch to Midnight
local function ShowTracker()
    if questFrame:IsShown() then return end
    
    questFrame:Show()
    
    -- First War Within
    tabWarWithin:Click()
    
    -- Then Midnight (small delay for UI to settle)
    C_Timer.After(0.01, function()
        if tabMidnight and tabMidnight:IsShown() then
            tabMidnight:Click()
        end
    end)
end

-- Events
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" or event == "ZONE_CHANGED" or event == "QUEST_LOG_UPDATE" then
        if questFrame:IsShown() then
            UpdateVisibleTab()
        end
    end
end)

-- Slash command
SLASH_DELVERSQUESTTRACKER1 = "/dqt"
SlashCmdList["DELVERSQUESTTRACKER"] = function()
    if questFrame:IsShown() then
        questFrame:Hide()
    else
        ShowTracker()
    end
end

-- Extra update on show
questFrame:SetScript("OnShow", UpdateVisibleTab)
local addonName, addon = ...

-- Localization
local L = {}
if GetLocale() == "ruRU" then
    L["Explorer"] = "Исследователь"
    L["Adventurer"] = "Приключенец"
    L["Veteran"] = "Ветеран"
    L["Champion"] = "Защитник"
    L["Hero"] = "Герой"
    L["Myth"] = "Легенда"
    L["Run"] = "Run"
    L["Vault"] = "Хранилище"
else
    L["Explorer"] = "Explorer"
    L["Adventurer"] = "Adventurer"
    L["Veteran"] = "Veteran"
    L["Champion"] = "Champion"
    L["Hero"] = "Hero"
    L["Myth"] = "Myth"
    L["Run"] = "Run"
    L["Vault"] = "Vault"
end

local lootData = {
    raid = {
        bosses = {-1, 1, 2, 3, 4, 5, 6},
        headers = {"LFR", "Normal", "Heroic", "Mythic"},
        LFR = {
            index = 0,
            bosses = {
            [1] = 233,
            [2] = 237,
            [3] = 240,
            [4] = 243,
            [5] = 246,
            [6] = 250,
            },
            rare = 243,
        },
        Normal = {
            index = 10,
            bosses = {
            [1] = 246,
            [2] = 250,
            [3] = 253,
            [4] = 256,
            [5] = 259,
            [6] = 263,
            },
            ["Very Rare"] = 256,
        },
        Heroic = {
            index = 20,
            bosses = {
            [1] = 259,
            [2] = 263,
            [3] = 266,
            [4] = 269,
            [5] = 272,
            [6] = 276,
            },        
            rare = 269,
        },
        Mythic = {
            index = 30,
            bosses = {
            [1] = 272,
            [2] = 276,
            [3] = 279,
            [4] = 282,
            [5] = 285,
            [6] = 289,
            },        
            rare = 282,
        },
    },
    mythicPlus = {
        types = {"Run", "Vault"},
        headers = {-1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
    [2] = {run = 250, vault = 259},
    [3] = {run = 250, vault = 259},
    [4] = {run = 253, vault = 263},
    [5] = {run = 256, vault = 263},
    [6] = {run = 256, vault = 266},
    [7] = {run = 259, vault = 269},
    [8] = {run = 263, vault = 269},
    [9] = {run = 263, vault = 269},
    [10] = {run = 266, vault = 272},
    },
    delve = {
        types = {"Run", "Vault"},
        headers = {-1, 1, 2, 3, 4, 5, 6, 7, 8},
        [1] = {run = 220, vault = 233},
        [2] = {run = 224, vault = 237},
        [3] = {run = 227, vault = 240},
        [4] = {run = 230, vault = 243},
        [5] = {run = 233, vault = 246},
        [6] = {run = 237, vault = 253},
        [7] = {run = 250, vault = 256},
        [8] = {run = 250, vault = 259},
    },
}

local tracks = {
    [208] = "Explorer", [211] = "Explorer", [214] = "Explorer", [217] = "Explorer",
    [220] = "Adventurer", [224] = "Adventurer", [227] = "Adventurer", [230] = "Adventurer",
    [233] = "Veteran", [237] = "Veteran", [240] = "Veteran", [243] = "Veteran",
    [246] = "Champion", [250] = "Champion", [253] = "Champion", [256] = "Champion",
    [259] = "Hero", [263] = "Hero", [266] = "Hero", [269] = "Hero",
    [272] = "Myth", [276] = "Myth", [279] = "Myth", [282] = "Myth", [285] = "Myth", [289] = "Myth",
}

local trackColors = {
    Explorer = {0.69, 0.69, 0.69, 1}, -- #B0B0B0 (Light Gray, Common)
    Adventurer = {0, 1, 0.59, 1}, -- #00FF96 (Pale Green, Uncommon)
    Veteran = {0, 0.64, 1, 1}, -- #00A2FF (Bright Blue, Rare)
    Champion = {0.64, 0.21, 0.93, 1}, -- #A335EE (Deep Purple, Epic)
    Hero = {1, 0.82, 0, 1}, -- #FFD100 (Gold, Legendary)
    Myth = {1, 0.27, 0, 1}, -- #FF4500 (Fiery Orange, Mythic)
}

-- Frame creation
local function CreateTextureFrame(parent, width, height, color, text, fontSize, justify, anchorFrame, anchorPoint, selfPoint, xOffset, yOffset)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint(selfPoint, anchorFrame, anchorPoint, xOffset, yOffset)
    
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture("Interface\\Buttons\\WHITE8X8")
    texture:SetAllPoints()
    
    color = type(color) == "table" and color or {1, 1, 1, 1}
    texture:SetVertexColor(unpack(color))
    texture:SetBlendMode("BLEND")
    
    local textFrame = frame:CreateFontString(nil, "OVERLAY")
    textFrame:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    textFrame:SetJustifyH(justify)
    textFrame:SetPoint("CENTER")
    textFrame:SetText(text or "")
    textFrame:SetTextColor(1, 1, 1, 1)
    
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0, 0, 0, 1)
    frame.border = border
    
    frame:Show()
    return frame
end

-- Main frame
local mainFrame = CreateFrame("Frame", "GreatVaultInfoFrame", WeeklyRewardsFrame)
mainFrame:Hide()
mainFrame:SetFrameStrata("HIGH")
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")

-- Tracks display
local function CreateTracks()
    local tracksFrame = CreateFrame("Frame", nil, mainFrame)
    tracksFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 41.999938964844, -22.999877929688)
    tracksFrame:SetSize(300 * 0.8, 30 * 0.8)
    tracksFrame:Show()
    
    local trackOrder = {"Explorer", "Adventurer", "Veteran", "Champion", "Hero", "Myth"}
    local ilvlRanges = {
        Explorer = "208 - 217",
        Adventurer = "220 - 230",
        Veteran = "233 - 243",
        Champion = "246 - 256",
        Hero = "259 - 269",
        Myth = "272 - 289",
    }
    
    for i, track in ipairs(trackOrder) do
        local xOffset = (i - 1) * 50
        local frame = CreateTextureFrame(
            tracksFrame, 50, 14, trackColors[track] or {1, 1, 1, 1}, L[track], 8, "CENTER",
            tracksFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
        
        local ilvlFrame = CreateTextureFrame(
            tracksFrame, 50, 14, {0, 0, 0, 0}, ilvlRanges[track], 8, "CENTER",
            tracksFrame, "TOPLEFT", "TOPLEFT", xOffset, -14
        )
        if ilvlFrame.border then
            ilvlFrame.border:Hide()
        end
    end
end

-- Raid data display
local function CreateRaidData()
    local raidFrame = CreateFrame("Frame", nil, mainFrame)
    raidFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 150 * 0.8, -80 * 0.8)
    raidFrame:SetSize(150 * 0.8, 30 * 0.8)
    raidFrame:Show()
    for i, header in ipairs(lootData.raid.headers) do
        local xOffset = i * 30
        CreateTextureFrame(
            raidFrame, 30, 16, {0, 0, 0, 1}, header, 8, "CENTER",
            raidFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
    end
    local rowCounter = 1
    for i = 2, #lootData.raid.bosses do 
        local key = lootData.raid.bosses[i]
        local yOffset = -16 * rowCounter
        CreateTextureFrame(
            raidFrame, 30, 16, {0, 0, 0, 1}, tostring(key), 8, "CENTER",
            raidFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        for j, header in ipairs(lootData.raid.headers) do
            local ilvl = lootData.raid[header].bosses[key]
            if ilvl then
                local track = tracks[ilvl]
                local color = trackColors[track] or {1, 1, 1, 1}
                local xOffset = j * 30
                CreateTextureFrame(
                    raidFrame, 30, 16, color, tostring(ilvl), 8, "CENTER",
                    raidFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
                )
            end
        end
        rowCounter = rowCounter + 1
    end
end

-- Mythic+ data display
local function CreateMythicPlusData()
    local mpFrame = CreateFrame("Frame", nil, mainFrame)
    mpFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 40 * 0.8, -330 * 0.8)
    mpFrame:SetSize(150 * 0.8, 30 * 0.8)
    mpFrame:Show()
    
    for i, key in ipairs(lootData.mythicPlus.headers) do
        local xOffset = (i - 1) * 25
        local text = key == -1 and "" or "+" .. key
        CreateTextureFrame(
            mpFrame, 25, 16, {0, 0, 0, 1}, text, 8, "CENTER",
            mpFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
    end
    
    for i, label in ipairs(lootData.mythicPlus.types) do
        local yOffset = -16 * i
        CreateTextureFrame(
            mpFrame, 25, 16, {0, 0, 0, 1}, L[label], 8, "CENTER",
            mpFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        
        for j, key in ipairs({2, 3, 4, 5, 6, 7, 8, 9, 10}) do
            local data = lootData.mythicPlus[key]
            local ilvl = data[label:lower()]
            local track = tracks[ilvl]
            local color = trackColors[track] or {1, 1, 1, 1}
            local xOffset = j * 25
            CreateTextureFrame(
                mpFrame, 25, 16, color, tostring(ilvl), 8, "CENTER",
                mpFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
            )
        end
    end
end

-- Delve data display
local function CreateDelveData()
    local delveFrame = CreateFrame("Frame", nil, mainFrame)
    delveFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 40, -381.49951171875)
    delveFrame:SetSize(210 * 0.8, 30 * 0.8)
    delveFrame:Show()
    
    for i, key in ipairs(lootData.delve.headers) do
        local xOffset = (i - 1) * 25
        local text = key == -1 and "" or tostring(key)
        CreateTextureFrame(
            delveFrame, 25, 16, {0, 0, 0, 1}, text, 8, "CENTER",
            delveFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
    end
    
    for i, label in ipairs(lootData.delve.types) do
        local yOffset = -16 * i
        CreateTextureFrame(
            delveFrame, 25, 16, {0, 0, 0, 1}, L[label], 8, "CENTER",
            delveFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        
        for j, key in ipairs({1, 2, 3, 4, 5, 6, 7, 8}) do
            local data = lootData.delve[key]
            local ilvl = data[label:lower()]
            local color
            -- Override color for vault = 694 at delve tier 7 to use Champion color
            if key == 7 and label:lower() == "vault" and ilvl == 694 then
                color = {0.64, 0.21, 0.93, 1} -- Champion color
            else
                local track = tracks[ilvl]
                color = trackColors[track] or {1, 1, 1, 1}
            end
            local xOffset = j * 25
            CreateTextureFrame(
                delveFrame, 25, 16, color, tostring(ilvl), 8, "CENTER",
                delveFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
            )
        end
    end
end

-- Initialize displays
local function InitializeDisplays()
    if not WeeklyRewardsFrame or not (WeeklyRewardsFrame:IsShown() or WeeklyRewardsFrame:IsVisible()) then
        mainFrame:Hide()
        return
    end
    
    CreateTracks()
    CreateRaidData()
    CreateMythicPlusData()
    CreateDelveData()
    
    if GWA_SavedVars and GWA_SavedVars.framesVisible then
        mainFrame:Show()
    else
        mainFrame:Hide()
    end
end

-- SavedVariables to store frame visibility state
local function SetupSavedVariables()
    GWA_SavedVars = GWA_SavedVars or {
        framesVisible = true
    }
end

-- Function to toggle frame visibility
local function ToggleFrames()
    GWA_SavedVars.framesVisible = not GWA_SavedVars.framesVisible
    if GWA_SavedVars.framesVisible then
        mainFrame:Show()
    else
        mainFrame:Hide()
    end
end

-- Slash command handler
SLASH_GWA1 = "/gwa"
SlashCmdList["GWA"] = function()
    ToggleFrames()
end

-- Event handling
mainFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            SetupSavedVariables()
            if not GWA_SavedVars.framesVisible then
                mainFrame:Hide()
            end
        elseif arg1 == "Blizzard_WeeklyRewards" then
            if WeeklyRewardsFrame then
                hooksecurefunc(WeeklyRewardsFrame, "Show", function()
                    InitializeDisplays()
                end)
                hooksecurefunc(WeeklyRewardsFrame, "Hide", function()
                    mainFrame:Hide()
                end)
                if WeeklyRewardsFrame:IsShown() or WeeklyRewardsFrame:IsVisible() then
                    InitializeDisplays()
                end
            end
        end
    elseif event == "PLAYER_LOGIN" then
        SetupSavedVariables()
        if C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") and WeeklyRewardsFrame and (WeeklyRewardsFrame:IsShown() or WeeklyRewardsFrame:IsVisible()) then
            InitializeDisplays()
        end
    end
end)
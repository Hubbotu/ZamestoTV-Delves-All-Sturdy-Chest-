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
        bosses = {-1, 1, 2, 3, 4, 5, 6, 7, 8},
        headers = {"LFR", "Normal", "Heroic", "Mythic"},
        LFR = {
            index = 0,
            bosses = {
            [1] = 671,
            [2] = 671,
            [3] = 671,
            [4] = 675,
            [5] = 675,
            [6] = 675,
            [7] = 678,
            [8] = 678,
            },
            rare = 675,
        },
        Normal = {
            index = 10,
            bosses = {
            [1] = 684,
            [2] = 684,
            [3] = 684,
            [4] = 688,
            [5] = 688,
            [6] = 688,
            [7] = 691,
            [8] = 691,
            },
            ["Very Rare"] = 688,
        },
        Heroic = {
            index = 20,
            bosses = {
            [1] = 697,
            [2] = 697,
            [3] = 697,
            [4] = 701,
            [5] = 701,
            [6] = 701,
            [7] = 704,
            [8] = 704,
            },        
            rare = 701,
        },
        Mythic = {
            index = 30,
            bosses = {
            [1] = 710,
            [2] = 710,
            [3] = 710,
            [4] = 714,
            [5] = 714,
            [6] = 714,
            [7] = 717,
            [8] = 717,
            },        
            rare = 714,
        },
    },
    mythicPlus = {
        types = {"Run", "Vault"},
        headers = {-1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
    [2] = {run = 684, vault = 694},
    [3] = {run = 684, vault = 694},
    [4] = {run = 688, vault = 697},
    [5] = {run = 691, vault = 697},
    [6] = {run = 694, vault = 701},
    [7] = {run = 694, vault = 704},
    [8] = {run = 697, vault = 704},
    [9] = {run = 697, vault = 704},
    [10] = {run = 701, vault = 707},
    },
    delve = {
        types = {"Run", "Vault"},
        headers = {-1, 1, 2, 3, 4, 5, 6, 7, 8},
        [1] = {run = 655, vault = 668},
        [2] = {run = 658, vault = 671},
        [3] = {run = 662, vault = 675},
        [4] = {run = 665, vault = 678},
        [5] = {run = 668, vault = 681},
        [6] = {run = 671, vault = 688},
        [7] = {run = 681, vault = 691},
        [8] = {run = 684, vault = 694},
    },
}

local tracks = {
    [642] = "Explorer", [646] = "Explorer", [649] = "Explorer", [652] = "Explorer",
    [655] = "Adventurer", [658] = "Adventurer", [662] = "Adventurer", [665] = "Adventurer",
    [668] = "Veteran", [671] = "Veteran", [675] = "Veteran", [678] = "Veteran",
    [681] = "Champion", [684] = "Champion", [688] = "Champion", [691] = "Champion",
    [694] = "Hero", [697] = "Hero", [701] = "Hero", [704] = "Hero",
    [707] = "Myth", [710] = "Myth", [714] = "Myth", [717] = "Myth", [720] = "Myth", [723] = "Myth",
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
        Explorer = "642 - 652",
        Adventurer = "655 - 665",
        Veteran = "668 - 678",
        Champion = "681 - 691",
        Hero = "694 - 704",
        Myth = "707 - 723",
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
    
    for i = 2, 9 do
        local key = lootData.raid.bosses[i]
        local yOffset = -16 * (i - 1)
        CreateTextureFrame(
            raidFrame, 30, 16, {0, 0, 0, 1}, tostring(key), 8, "CENTER",
            raidFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        
        for j, header in ipairs(lootData.raid.headers) do
            local ilvl = lootData.raid[header].bosses[key]
            local track = tracks[ilvl]
            local color = trackColors[track] or {1, 1, 1, 1}
            local xOffset = j * 30
            CreateTextureFrame(
                raidFrame, 30, 16, color, tostring(ilvl), 8, "CENTER",
                raidFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
            )
        end
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
            local track = tracks[ilvl]
            local color = trackColors[track] or {1, 1, 1, 1}
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
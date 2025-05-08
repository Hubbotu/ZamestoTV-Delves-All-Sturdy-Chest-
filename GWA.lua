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

-- Data from WeakAuras (updated from Boss_ruRU.lua)
local lootData = {
    raid = {
        bosses = {-1, 1, 2, 3, 4, 5, 6, 7, 8},
        headers = {"LFR", "Normal", "Heroic", "Mythic"},
        LFR = {
            index = 0,
            bosses = {
                [1] = 623,
                [2] = 626,
                [3] = 626,
                [4] = 626,
                [5] = 629,
                [6] = 629,
                [7] = 632,
                [8] = 632,
            },
            rare = 639,
        },
        Normal = {
            index = 10,
            bosses = {
                [1] = 636,
                [2] = 639,
                [3] = 639,
                [4] = 639,
                [5] = 642,
                [6] = 642,
                [7] = 645,
                [8] = 645,
            },
            ["Very Rare"] = 652,
        },
        Heroic = {
            index = 20,
            bosses = {
                [1] = 649,
                [2] = 652,
                [3] = 652,
                [4] = 652,
                [5] = 655,
                [6] = 655,
                [7] = 658,
                [8] = 658,
            },        
            rare = 665,
        },
        Mythic = {
            index = 30,
            bosses = {
                [1] = 662,
                [2] = 665,
                [3] = 665,
                [4] = 665,
                [5] = 668,
                [6] = 668,
                [7] = 671,
                [8] = 671,
            },        
            rare = 678,
        },
    },
    mythicPlus = {
        types = {"Run", "Vault"},
        headers = {-1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
        [2] = {run = 639, vault = 649},
        [3] = {run = 639, vault = 649},
        [4] = {run = 642, vault = 652},
        [5] = {run = 645, vault = 652},
        [6] = {run = 649, vault = 655},
        [7] = {run = 649, vault = 658},
        [8] = {run = 652, vault = 658},
        [9] = {run = 652, vault = 658},
        [10] = {run = 655, vault = 662},
    },
    delve = {
        types = {"Run", "Vault"},
        headers = {-1, 1, 2, 3, 4, 5, 6, 7, 8},
        [1] = {run = 610, vault = 623},
        [2] = {run = 613, vault = 623},
        [3] = {run = 616, vault = 626},
        [4] = {run = 619, vault = 636},
        [5] = {run = 623, vault = 642},
        [6] = {run = 626, vault = 645},
        [7] = {run = 636, vault = 649},
        [8] = {run = 639, vault = 649},
    },
}

local tracks = {
    [597] = "Explorer", [600] = "Explorer", [603] = "Explorer", [606] = "Explorer",
    [610] = "Adventurer", [613] = "Adventurer", [616] = "Adventurer", [619] = "Adventurer",
    [623] = "Veteran", [626] = "Veteran", [629] = "Veteran", [632] = "Veteran",
    [636] = "Champion", [639] = "Champion", [642] = "Champion", [645] = "Champion",
    [649] = "Hero", [652] = "Hero", [655] = "Hero", [658] = "Hero",
    [662] = "Myth", [665] = "Myth", [668] = "Myth", [671] = "Myth", [678] = "Myth",
}

local trackColors = {
    Explorer = {0.6156862745098, 0.6156862745098, 0.6156862745098, 1}, -- #9d9d9d
    Adventurer = {1, 1, 1, 1}, -- #fff
    Veteran = {0.11764705882353, 1, 0, 1}, -- #1eff00
    Champion = {0, 0.43921568627451, 0.86666666666667, 1}, -- #0070dd
    Hero = {0.57647058823529, 0.27058823529412, 1, 1}, -- #9345ff
    Myth = {1, 0.50196078431373, 0, 1}, -- #ff8000
}

-- Frame creation
local function CreateTextureFrame(parent, width, height, color, text, font, fontSize, justify, anchorFrame, anchorPoint, selfPoint, xOffset, yOffset)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint(selfPoint, anchorFrame, anchorPoint, xOffset, yOffset)
    
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    -- Fallback to Blizzard default if texture is missing
    texture:SetTexture("Interface\\AddOns\\ZamestoTV_Delves\\Textures\\Square_White")
    if not texture:GetTexture() then
        texture:SetTexture("Interface\\Buttons\\WHITE8X8")
    end
    texture:SetAllPoints()
    
    -- Safeguard for nil or invalid color
    color = type(color) == "table" and color or {1, 1, 1, 1}
    texture:SetVertexColor(unpack(color))
    texture:SetBlendMode("BLEND")
    
    local textFrame = frame:CreateFontString(nil, "OVERLAY")
    -- Fallback to Blizzard default font if missing
    local fontPath = "Interface\\AddOns\\ZamestoTV_Delves\\Fonts\\" .. font
    textFrame:SetFont(fontPath, fontSize, "OUTLINE")
    if not textFrame:GetFont() then
        textFrame:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    end
    textFrame:SetJustifyH(justify)
    textFrame:SetPoint("CENTER")
    textFrame:SetText(text or "")
    
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\ZamestoTV_Delves\\Textures\\Square_White",
        edgeSize = 1,
    })
    if not border:GetBackdrop().edgeFile then
        border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    end
    border:SetBackdropBorderColor(0, 0, 0, 1)
    frame.border = border -- Attach border to frame
    
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
    tracksFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 80 * 0.8, -25 * 0.8)
    tracksFrame:SetSize(300 * 0.8, 30 * 0.8)
    tracksFrame:Show()
    
    local trackOrder = {"Explorer", "Adventurer", "Veteran", "Champion", "Hero", "Myth"}
    local ilvlRanges = {
        Explorer = "597 - 619",
        Adventurer = "610 - 632",
        Veteran = "623 - 645",
        Champion = "636 - 658",
        Hero = "649 - 671",
        Myth = "662 - 678",
    }
    
    for i, track in ipairs(trackOrder) do
        local xOffset = (i - 1) * 50
        local frame = CreateTextureFrame(
            tracksFrame, 50, 14, trackColors[track] or {1, 1, 1, 1}, L[track], "arial.ttf", 8, "CENTER",
            tracksFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
        
        local ilvlFrame = CreateTextureFrame(
            tracksFrame, 50, 14, {0, 0, 0, 0}, ilvlRanges[track], "Chekharda-BoldItalic.ttf", 8, "CENTER",
            tracksFrame, "TOPLEFT", "TOPLEFT", xOffset, -14
        )
        if ilvlFrame.border then
            ilvlFrame.border:Hide() -- Hide border for ilvl frames
        end
    end
end

-- Raid data display
local function CreateRaidData()
    local raidFrame = CreateFrame("Frame", nil, mainFrame)
    raidFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 150 * 0.8, -80 * 0.8)
    raidFrame:SetSize(150 * 0.8, 30 * 0.8)
    raidFrame:Show()
    
    -- Headers
    for i, header in ipairs(lootData.raid.headers) do
        local xOffset = i * 30
        CreateTextureFrame(
            raidFrame, 30, 16, {0, 0, 0, 1}, header, "arial.ttf", 8, "CENTER",
            raidFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
    end
    
    -- Bosses and item levels
    for i = 2, 9 do -- Skip index 1 (key -1)
        local key = lootData.raid.bosses[i]
        local yOffset = -16 * (i - 1)
        CreateTextureFrame(
            raidFrame, 30, 16, {0, 0, 0, 1}, tostring(key), "Chekharda-BoldItalic.ttf", 8, "CENTER",
            raidFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        
        for j, header in ipairs(lootData.raid.headers) do
            local ilvl = lootData.raid[header].bosses[key]
            local track = tracks[ilvl]
            local color = trackColors[track] or {1, 1, 1, 1} -- Safeguard for nil track
            local xOffset = j * 30
            CreateTextureFrame(
                raidFrame, 30, 16, color, ilvl, "arial.ttf", 8, "CENTER",
                raidFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
            )
        end
    end
end

-- Mythic+ data display
local function CreateMythicPlusData()
    local mpFrame = CreateFrame("Frame", nil, mainFrame)
    mpFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 40 * 0.8, -340 * 0.8)
    mpFrame:SetSize(150 * 0.8, 30 * 0.8)
    mpFrame:Show()
    
    -- Headers
    for i, key in ipairs(lootData.mythicPlus.headers) do
        local xOffset = (i - 1) * 25
        local text = key == -1 and "" or "+" .. key
        CreateTextureFrame(
            mpFrame, 25, 16, {0, 0, 0, 1}, text, "Chekharda-BoldItalic.ttf", 8, "CENTER",
            mpFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
    end
    
    -- Types and item levels
    for i, label in ipairs(lootData.mythicPlus.types) do
        local yOffset = -16 * i
        CreateTextureFrame(
            mpFrame, 25, 16, {0, 0, 0, 1}, L[label], "Chekharda-BoldItalic.ttf", 8, "CENTER",
            mpFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        
        for j, key in ipairs({2, 3, 4, 5, 6, 7, 8, 9, 10}) do
            local data = lootData.mythicPlus[key]
            local ilvl = data[label:lower()]
            local track = tracks[ilvl]
            local color = trackColors[track] or {1, 1, 1, 1} -- Safeguard for nil track
            local xOffset = j * 25
            CreateTextureFrame(
                mpFrame, 25, 16, color, ilvl, "arial.ttf", 8, "CENTER",
                mpFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
            )
        end
    end
end

-- Delve data display
local function CreateDelveData()
    local delveFrame = CreateFrame("Frame", nil, mainFrame)
    delveFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 40 * 0.8, -480 * 0.8)
    delveFrame:SetSize(210 * 0.8, 30 * 0.8)
    delveFrame:Show()
    
    -- Headers
    for i, key in ipairs(lootData.delve.headers) do
        local xOffset = (i - 1) * 25
        local text = key == -1 and "" or key
        CreateTextureFrame(
            delveFrame, 25, 16, {0, 0, 0, 1}, text, "Chekharda-BoldItalic.ttf", 8, "CENTER",
            delveFrame, "TOPLEFT", "TOPLEFT", xOffset, 0
        )
    end
    
    -- Types and item levels
    for i, label in ipairs(lootData.delve.types) do
        local yOffset = -16 * i
        CreateTextureFrame(
            delveFrame, 25, 16, {0, 0, 0, 1}, L[label], "Chekharda-BoldItalic.ttf", 8, "CENTER",
            delveFrame, "TOPLEFT", "TOPLEFT", 0, yOffset
        )
        
        for j, key in ipairs({1, 2, 3, 4, 5, 6, 7, 8}) do
            local data = lootData.delve[key]
            local ilvl = data[label:lower()]
            local track = tracks[ilvl]
            local color = trackColors[track] or {1, 1, 1, 1} -- Safeguard for nil track
            local xOffset = j * 25
            CreateTextureFrame(
                delveFrame, 25, 16, color, ilvl, "arial.ttf", 8, "CENTER",
                delveFrame, "TOPLEFT", "TOPLEFT", xOffset, yOffset
            )
        end
    end
end

-- Initialize displays
local function InitializeDisplays()
    if not WeeklyRewardsFrame or not WeeklyRewardsFrame:IsShown() then
        mainFrame:Hide()
        return
    end
    
    CreateTracks()
    CreateRaidData()
    CreateMythicPlusData()
    CreateDelveData()
    mainFrame:Show()
end

-- SavedVariables to store frame visibility state
local function SetupSavedVariables()
    GWA_SavedVars = GWA_SavedVars or {
        framesVisible = true -- Default to visible
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
    print("GreatVaultInfoFrame " .. (GWA_SavedVars.framesVisible and "shown" or "hidden"))
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
            -- Apply saved visibility state
            if not GWA_SavedVars.framesVisible then
                mainFrame:Hide()
            end
        elseif arg1 == "Blizzard_WeeklyRewards" then
            if WeeklyRewardsFrame then
                -- Hook OnShow and OnHide
                hooksecurefunc(WeeklyRewardsFrame, "Show", function()
                    InitializeDisplays()
                    -- Respect saved visibility state
                    if not GWA_SavedVars.framesVisible then
                        mainFrame:Hide()
                    end
                end)
                hooksecurefunc(WeeklyRewardsFrame, "Hide", function()
                    mainFrame:Hide()
                end)
                -- Initialize if WeeklyRewardsFrame is already shown
                if WeeklyRewardsFrame:IsShown() then
                    InitializeDisplays()
                    if not GWA_SavedVars.framesVisible then
                        mainFrame:Hide()
                    end
                end
            end
        end
    elseif event == "PLAYER_LOGIN" then
        SetupSavedVariables()
        if C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") and WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown() then
            InitializeDisplays()
            if not GWA_SavedVars.framesVisible then
                mainFrame:Hide()
            end
        end
    end
end)
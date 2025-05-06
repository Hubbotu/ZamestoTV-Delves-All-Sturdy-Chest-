local addonName, addon = ...

-- Localization
local L = {}
if GetLocale() == "ruRU" then
    L["Explorer"] = "Исследователь"
    L["Adventurer"] = "Авантюрист"
    L["Veteran"] = "Ветеран"
    L["Champion"] = "Чемпион"
    L["Hero"] = "Герой"
    L["Myth"] = "Миф"
    L["Run"] = "Прогон"
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
    Explorer = {0.60000002384186, 0.60000002384186, 0.60000002384186, 1},
    Adventurer = {0.85098046064377, 0.85098046064377, 0.85098046064377, 1},
    Veteran = {0.33725491166115, 0.77647066116333, 0.50196081399918, 1},
    Champion = {0.35294118523598, 0.5686274766922, 0.78431379795074, 1},
    Hero = {0.67058825492859, 0.086274512112141, 0.90980398654938, 1},
    Myth = {1, 0.49803924560547, 0, 1},
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
    raidFrame:SetPoint("TOPLEFT", WeeklyRewardsFrame, "TOPLEFT", 150 * 0.8, -80 * 0.8) -- Changed from 30 to 80 (50 pixels right)
    raidFrame:SetSize(150 * 0.8, 30 * 0.8) -- Reduced height from 50 to 30 (20 pixels less)
    raidFrame:Show()
    
    -- Headers
    for i, header in ipairs(lootData.raid.headers) do
        local xOffset = i * 30 -- Changed from (i + 1)*25 to i*28 (3 pixels wider columns)
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
            local xOffset = j * 30 -- Changed from (j + 1)*25 to j*28 (3 pixels wider columns)
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

-- Event handling
mainFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_WeeklyRewards" then
        if WeeklyRewardsFrame then
            -- Hook OnShow and OnHide
            hooksecurefunc(WeeklyRewardsFrame, "Show", function()
                InitializeDisplays()
            end)
            hooksecurefunc(WeeklyRewardsFrame, "Hide", function()
                mainFrame:Hide()
            end)
            -- Initialize if WeeklyRewardsFrame is already shown
            if WeeklyRewardsFrame:IsShown() then
                InitializeDisplays()
            end
        end
    elseif event == "PLAYER_LOGIN" then
        if C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") and WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown() then
            InitializeDisplays()
        end
    end
end)
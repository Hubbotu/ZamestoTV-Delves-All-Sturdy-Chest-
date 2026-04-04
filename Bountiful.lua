local addonName, addon = ...

local VladDelves = CreateFrame("Frame")
VladDelves:RegisterEvent("ADDON_LOADED")
VladDelves:RegisterEvent("PLAYER_REGEN_DISABLED")
VladDelves:RegisterEvent("PLAYER_REGEN_ENABLED")
VladDelves:RegisterEvent("QUEST_LOG_UPDATE")
VladDelves:RegisterEvent("BAG_UPDATE_DELAYED")
VladDelves:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

local G = {
    DelveButtons = {},
    Container     = nil,
    ExpansionMapID = 2537, -- Quel'Thalas
    config = {
        onlyBountiful = true,
        taintSafe     = false,
    },
    -- Исправленные areaPoiID -> widgetID для Midnight
    DelveConfig = {
        [8432] = 0, -- Shadowguard Point
        [8430] = 0, -- Sunkiller Sanctum
        [8436] = 0,    -- The Gulf of Memory
        [8434] = 0,    -- The Grudge Pit
        [8444] = 0,    -- Atal'Aman
        [8442] = 0,    -- Twilight Crypts
        [8673] = 0,    -- Shadow Enclave
        [8426] = 0, -- Collegiate Calamity
        [8440] = 0,    -- The Darkway
        [8428] = 0, -- Parhelion Plaza
    },
}

---------------------------------------------------------
-- Сбор данных (GetDelves)
---------------------------------------------------------
function G.GetDelves()
    local result = {}
    local dupe = {}
    local mapIDs = {2405, 2413, 2437, 2395, 2393, 2424, 2537}

    for _, mapID in ipairs(mapIDs) do
        local areaPOIs = C_AreaPoiInfo.GetDelvesForMap(mapID) or {}
        for _, areaPoiID in ipairs(areaPOIs) do
            if G.DelveConfig[areaPoiID] or not G.config.onlyBountiful then
                local poi = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
                if poi and poi.atlasName and poi.atlasName:find("bountiful") then
                    if not dupe[areaPoiID] then
                        dupe[areaPoiID] = true
                        
                        local isOvercharged = false
                        local widgetID = G.DelveConfig[areaPoiID]
                        if widgetID and widgetID > 0 then
                            local vis = C_UIWidgetManager.GetSpacerVisualizationInfo(widgetID)
                            isOvercharged = vis and vis.shownState == 1
                        end

                        table.insert(result, {
                            name          = poi.name,
                            zone          = C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name or "Unknown",
                            atlas         = poi.atlasName,
                            mapID         = mapID,
                            areaPoiID     = areaPoiID,
                            isOvercharged = isOvercharged,
                        })
                    end
                end
            end
        end
    end
    return result
end

---------------------------------------------------------
-- Фабрика кнопок (Оригинальный стиль из 1-го сообщения)
---------------------------------------------------------
function G.CreateDelveButton(parent, index)
    local button = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    local size    = 24
    local spacing = 4
    local perRow  = 6

    local row = math.floor((index-1) / perRow)
    local col = (index-1) % perRow

    button:SetSize(size, size)
    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", - (col * (size + spacing)), - (row * (size + spacing)))

    button:RegisterForClicks("AnyUp")

    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetAllPoints()
    button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.Border = button:CreateTexture(nil, "OVERLAY")
    button.Border:SetPoint("CENTER")
    button.Border:SetSize(size + 6, size + 6)
    button.Border:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button.Border:SetVertexColor(0.4, 0.7, 1, 0.9)
    button.Border:Hide()

    button:SetScript("OnEnter", function(self)
        local d = self.delve
        if not d then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(format("|A:%s:0:0|a %s", d.atlas, d.name), 1,1,1)
        GameTooltip:AddLine(d.zone, 0.9,0.9,0.9)
        if d.isOvercharged then
            GameTooltip:AddLine("Overcharged Today", 1, 0.6, 0)
        else
            GameTooltip:AddLine("Bountiful", 0, 1, 0)
        end
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    button:SetScript("OnClick", function(self)
        local d = self.delve
        if not d then return end
        if not WorldMapFrame:IsShown() then WorldMapFrame:HandleUserActionOpenSelf() end
        WorldMapFrame:SetMapID(d.mapID)
    end)

    return button
end

---------------------------------------------------------
-- Обновление (Update)
---------------------------------------------------------
function G.Update()
    if InCombatLockdown() or not G.Container then return end

    for _, btn in ipairs(G.DelveButtons) do btn:Hide() end

    local delves = G.GetDelves()
    if #delves == 0 then return end

    for i, delve in ipairs(delves) do
        local btn = G.DelveButtons[i]
        if not btn then
            btn = G.CreateDelveButton(G.Container, i)
            G.DelveButtons[i] = btn
        end

        btn.delve = delve
        btn.Icon:SetAtlas(delve.atlas)
        btn.Border:SetShown(delve.isOvercharged)
        btn:Show()
    end
end

---------------------------------------------------------
-- Привязка
---------------------------------------------------------
local SEASON_WAR_WITHIN = "UI-Journeys-Delve-Button"
local SEASON_MIDNIGHT   = "UI-Journeys-Midnight-Button"

local function FindDelvesButtonFrame()
    if not EncounterJournalJourneysFrame or not EncounterJournalJourneysFrame.JourneysList then return nil end
    local scroll = EncounterJournalJourneysFrame.JourneysList.ScrollTarget
    if not scroll then return nil end

    for _, child in ipairs({scroll:GetChildren()}) do
        if child.GetNormalTexture then
            local tex = child:GetNormalTexture()
            if tex and tex.GetAtlas then
                local atlas = tex:GetAtlas()
                if atlas == SEASON_WAR_WITHIN or atlas == SEASON_MIDNIGHT then
                    return child
                end
            end
        end
    end
    return nil
end

local function TryAttachBountiful()
    if G.Container then return true end
    local btn = FindDelvesButtonFrame()
    if not btn then return false end

    local container = CreateFrame("Frame", "VladBountifulContainer", btn)
    container:SetSize(180, 80)
    container:SetPoint("CENTER", btn, "CENTER", -92, -8)
    container:SetScale(0.92)
    
    G.Container = container
    btn:HookScript("OnShow", G.Update)
    G.Update()
    return true
end

---------------------------------------------------------
-- Загрузка
---------------------------------------------------------
local function StartAttachTicker()
    C_Timer.NewTicker(0.4, function(t)
        if TryAttachBountiful() then t:Cancel() end
    end, 10)
end

VladDelves:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        StartAttachTicker()
    elseif event == "PLAYER_REGEN_ENABLED" then
        G.Update()
    else
        C_Timer.After(0.1, G.Update)
    end
end)

if EncounterJournal then
    EncounterJournal:HookScript("OnShow", StartAttachTicker)
end
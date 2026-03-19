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
    ExpansionExtraMapIDs = {2537},
    config = {
        onlyBountiful = true,
        prioBountiful = false,
        taintSafe     = false,
    },
    -- areaPoiID → overcharged widgetID
    DelveConfig = {
        [76162] = 7105, -- Deadly Deeps
        [27120] = 7041, -- Collegiate Calamity
        [27120] = 7052, -- Parhelion Plaza
        [27120] = 7051, -- Sunkiller Sanctum
        [27120] = 7053, -- Shadowguard Point
    },
}

---------------------------------------------------------
-- Collect Bountiful Delves
---------------------------------------------------------
function G.GetDelves()
    local dupe = {}
    local result = {}
    local areas = C_Map.GetMapChildrenInfo(G.ExpansionMapID, Enum.UIMapType.Zone, true) or {}

    for _, mapID in ipairs(G.ExpansionExtraMapIDs) do
        local info = C_Map.GetMapInfo(mapID)
        if info then
            info.isExtraMap = true
            table.insert(areas, info)
        end
    end

    for _, area in ipairs(areas) do
        local mapID = area.mapID
        local areaPOIs = C_AreaPoiInfo.GetDelvesForMap(mapID) or {}
        for _, areaPoiID in ipairs(areaPOIs) do
            local poi = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
            if poi and poi.atlasName and (poi.isPrimaryMapForPOI or area.isExtraMap) then
                if poi.atlasName:find("bountiful") and not dupe[poi.name] then
                    dupe[poi.name] = true

                    local isOvercharged = false
                    local widgetID = G.DelveConfig[areaPoiID]
                    if widgetID then
                        local vis = C_UIWidgetManager.GetSpacerVisualizationInfo(widgetID)
                        isOvercharged = vis and vis.shownState == 1
                    end

                    result[#result+1] = {
                        name         = poi.name,
                        zone         = area.name,
                        atlas        = poi.atlasName,
                        mapID        = mapID,
                        areaPoiID    = areaPoiID,
                        bountiful    = true,
                        isOvercharged = isOvercharged,
                    }
                end
            end
        end
    end

    table.sort(result, function(a,b)
        if a.isOvercharged ~= b.isOvercharged then return a.isOvercharged end
        if a.zone ~= b.zone then return a.zone > b.zone end
        return a.name > b.name
    end)

    return result
end

---------------------------------------------------------
-- Tooltip
---------------------------------------------------------
local function OnDelveEnter(self)
    local delve = self.delve
    if not delve then return end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(format("|A:%s:0:0|a %s", delve.atlas, delve.name), 1,1,1)
    GameTooltip:AddLine(delve.zone, 0.9,0.9,0.9)

    if delve.isOvercharged then
        GameTooltip:AddLine("Overcharged Today", 1, 0.6, 0)
    else
        GameTooltip:AddLine("Bountiful", 0, 1, 0)
    end
    GameTooltip:Show()
end

local function OnDelveLeave()
    GameTooltip:Hide()
end

---------------------------------------------------------
-- Click → open world map + highlight pin
---------------------------------------------------------
local function OnDelveClick(self, button, down)
    if G.config.taintSafe or down then return end

    local delve = self.delve
    if not delve then return end

    if not WorldMapFrame:IsShown() then
        WorldMapFrame:HandleUserActionOpenSelf()
    end

    WorldMapFrame:SetMapID(delve.mapID)

    for pin in WorldMapFrame:EnumeratePinsByTemplate("DelveEntrancePinTemplate") do
        if pin.areaPoiID == delve.areaPoiID then
            pin:OnClick(button, down)
            break
        end
    end
end

---------------------------------------------------------
-- Button factory
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
    button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)   -- чуть красивее обрезка

    button.Border = button:CreateTexture(nil, "OVERLAY")
    button.Border:SetPoint("CENTER")
    button.Border:SetSize(size + 6, size + 6)
    button.Border:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button.Border:SetVertexColor(0.4, 0.7, 1, 0.9)
    button.Border:Hide()

    button:SetScript("OnEnter", OnDelveEnter)
    button:SetScript("OnLeave", OnDelveLeave)
    button:SetScript("OnClick", OnDelveClick)

    return button
end

---------------------------------------------------------
-- Update icons
---------------------------------------------------------
function G.Update()
    if InCombatLockdown() or not G.Container then return end

    for _, btn in ipairs(G.DelveButtons) do
        btn:Hide()
    end

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
-- Attach to the same frame as the keys addon
---------------------------------------------------------
local SEASON_WAR_WITHIN = "UI-Journeys-Delve-Button"
local SEASON_MIDNIGHT   = "UI-Journeys-Midnight-Button"

local function FindDelvesButtonFrame()
    if not EncounterJournalJourneysFrame or not EncounterJournalJourneysFrame.JourneysList then
        return nil
    end

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
-- Loader & events
---------------------------------------------------------
local attachTicker

local function StartAttachTicker()
    if attachTicker then return end
    attachTicker = C_Timer.NewTicker(0.4, function(t)
        if TryAttachBountiful() then
            t:Cancel()
            attachTicker = nil
        end
    end)
end

VladDelves:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        StartAttachTicker()
    elseif event == "PLAYER_REGEN_ENABLED" then
        StartAttachTicker()
    elseif event == "ADDON_LOADED" then
        StartAttachTicker()
    else
        C_Timer.After(0.1, G.Update)
    end
end)

if EncounterJournal then
    EncounterJournal:HookScript("OnShow", StartAttachTicker)
end
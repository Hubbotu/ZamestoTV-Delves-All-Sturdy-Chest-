local VladDelves = CreateFrame("Frame")
VladDelves:RegisterEvent("ADDON_LOADED")
VladDelves:RegisterEvent("PLAYER_REGEN_DISABLED")
VladDelves:RegisterEvent("PLAYER_REGEN_ENABLED")

local G = {
    DelveButtons = {},
    Container = nil,

    ExpansionMapID = 2274, -- Khaz Algar
    ExpansionExtraMapIDs = {
        2274, -- Khaz Algar
        2346, -- Undermine
        2371, -- K'aresh
    },

    config = {
        onlyBountiful = true,
        prioBountiful = false,
        taintSafe = false,
    },

    -- areaPoiID => overchargedUiWidgetID
    DelveConfig = {
        [7779] = 7105, -- Fungal Folly
        [7781] = 7041, -- Kriegval's Rest
        [7785] = 7052, -- Nightfall Sanctum
        [7789] = 7051, -- Skittering Breach
        [7790] = 7053, -- The Spiral Weave
        [8246] = 7104, -- Sidestreet Sluice
    },
}

---------------------------------------------------------
-- Collect delves
---------------------------------------------------------
function G.GetDelves()
    local dupe = {}
    local result = {}

    local areas = C_Map.GetMapChildrenInfo(
        G.ExpansionMapID,
        Enum.UIMapType.Zone,
        true
    )

    for _, mapID in ipairs(G.ExpansionExtraMapIDs) do
        local area = C_Map.GetMapInfo(mapID)
        if area then
            area.isExtraMap = true
            table.insert(areas, area)
        end
    end

    for _, area in ipairs(areas) do
        local mapID = area.mapID
        local areaPOIs = C_AreaPoiInfo.GetDelvesForMap(mapID)

        for _, areaPoiID in ipairs(areaPOIs) do
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
            if poiInfo and poiInfo.atlasName and (poiInfo.isPrimaryMapForPOI or area.isExtraMap) then
                if not dupe[poiInfo.name] then
                    dupe[poiInfo.name] = true

                    local isBountiful = poiInfo.atlasName:find("bountiful") ~= nil
                    if isBountiful then
                        local isOvercharged = false
                        local widgetID = G.DelveConfig[areaPoiID]

                        if widgetID then
                            local vis = C_UIWidgetManager.GetSpacerVisualizationInfo(widgetID)
                            isOvercharged = vis and vis.shownState == 1
                        end

                        result[#result + 1] = {
                            name = poiInfo.name,
                            zone = area.name,
                            atlas = poiInfo.atlasName,
                            mapID = mapID,
                            areaPoiID = areaPoiID,
                            bountiful = true,
                            isOvercharged = isOvercharged,
                        }
                    end
                end
            end
        end
    end

    table.sort(result, function(a, b)
        if a.isOvercharged ~= b.isOvercharged then
            return a.isOvercharged
        end
        if a.zone ~= b.zone then
            return a.zone > b.zone
        end
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
    GameTooltip:AddLine(
        format("|A:%s:0:0|a %s", delve.atlas, delve.name),
        1, 1, 1
    )
    GameTooltip:AddLine(delve.zone, 0.9, 0.9, 0.9)

    if delve.isOvercharged then
        GameTooltip:AddLine("Overcharged Today", 1, 0.6, 0)
    else
        GameTooltip:AddLine("Bountiful", 0, 1, 0)
    end

    GameTooltip:Show()
end

---------------------------------------------------------
-- Click → world map
---------------------------------------------------------
local function OnDelveClick(self, button, down)
    if G.config.taintSafe then return end
    if down then return end

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

    local size = 26
    local spacing = 4
    local perRow = 6

    local row = math.floor((index - 1) / perRow)
    local col = (index - 1) % perRow

    button:SetSize(size, size)
    button:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -(col * (size + spacing)),
        -(row * (size + spacing))
    )

    button:RegisterForClicks("AnyUp", "AnyDown")

    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetAllPoints()
    button.Icon:SetAtlas("Dungeon")

    button.Border = button:CreateTexture(nil, "OVERLAY")
    button.Border:SetPoint("CENTER")
    button.Border:SetSize(size + 4, size + 4)
    button.Border:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button.Border:SetVertexColor(0.4, 0.6, 1, 1)
    button.Border:Hide()

    button:SetScript("OnEnter", OnDelveEnter)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetScript("OnClick", OnDelveClick)

    return button
end

---------------------------------------------------------
-- Update display
---------------------------------------------------------
function G.Update()
    if InCombatLockdown() then return end
    if not G.Container then return end

    for _, btn in ipairs(G.DelveButtons) do
        btn:Hide()
    end

    local delves = G.GetDelves()

    for i, delve in ipairs(delves) do
        local button = G.DelveButtons[i]
        if not button then
            button = G.CreateDelveButton(G.Container, i)
            G.DelveButtons[i] = button
        end

        button.delve = delve
        button.Icon:SetAtlas(delve.atlas)

        if delve.isOvercharged then
            button.Border:Show()
        else
            button.Border:Hide()
        end

        button:Show()
    end
end

---------------------------------------------------------
-- Init container
---------------------------------------------------------
function G.Init()
    if G.Container then return end
    if not EncounterJournalJourneysFrame then return end

    local frame = CreateFrame("Frame", nil, EncounterJournalJourneysFrame)
    frame:SetSize(200, 100)
    frame:SetPoint("TOPRIGHT", EncounterJournalJourneysFrame, "TOPRIGHT", -26, -16)

    G.Container = frame
    _G.BountifulContainer = frame
    EncounterJournalJourneysFrame:HookScript("OnShow", function()
        G.Update()
    end)

    G.Update()
end

---------------------------------------------------------
-- Loader
---------------------------------------------------------
function G.TryLoad()
    if InCombatLockdown() then return end
    if EncounterJournalJourneysFrame then
        G.Init()
    end
end

---------------------------------------------------------
-- Events
---------------------------------------------------------
VladDelves:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" then
        G.TryLoad()
    elseif event == "PLAYER_REGEN_ENABLED" then
        G.TryLoad()
    end
end)

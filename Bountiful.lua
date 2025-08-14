local VladDelves = CreateFrame("Frame")
VladDelves:RegisterEvent("ADDON_LOADED")
VladDelves:RegisterEvent("PLAYER_REGEN_DISABLED")
VladDelves:RegisterEvent("PLAYER_REGEN_ENABLED")

local G = {
    DelveButtons = {},
    ExpansionMapID = 2274, -- Khaz Algar
    ExpansionExtraMapIDs = {
        2274, -- Khaz Algar
        2346, -- Undermine
        2371, -- Undermine		
    },
    config = {
        onlyBountiful = true,
        prioBountiful = false,
        taintSafe = false
    },
    -- Mapping of bountiful areaPoiID to overchargedUiWidgetID from Config.lua
    DelveConfig = {
        [7779] = 7105, -- Fungal Folly
        [7781] = 7041, -- Kriegval's Rest
        [7785] = 7052, -- Nightfall Sanctum
        [7789] = 7051, -- Skittering Breach
        [7790] = 7053, -- The Spiral Weave
        [8246] = 7104, -- Sidestreet Sluice
    }
}

function G.GetDelves()
    local dupe = {}
    local temp = {}
    local onlyBountiful = G.config.onlyBountiful
    local areas = C_Map.GetMapChildrenInfo(G.ExpansionMapID, Enum.UIMapType.Zone, true)
    
    -- Add extra map IDs
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
                    local bountiful = not not poiInfo.atlasName:find("bountiful")
                    if bountiful then
                        -- Check for Overcharged status
                        local isOvercharged = false
                        local overchargedUiWidgetID = G.DelveConfig[areaPoiID]
                        if overchargedUiWidgetID then
                            local visInfo = C_UIWidgetManager.GetSpacerVisualizationInfo(overchargedUiWidgetID)
                            isOvercharged = visInfo and visInfo.shownState == 1
                        end
                        temp[#temp + 1] = {
                            bountiful = bountiful,
                            isOvercharged = isOvercharged,
                            atlas = poiInfo.atlasName,
                            name = poiInfo.name,
                            zone = area.name,
                            mapID = mapID,
                            areaPoiID = areaPoiID,
                        }
                    end
                end
            end
        end
    end
    table.sort(temp, function(a, b)
        -- Prioritize Overcharged delves, then sort by zone and name
        if a.isOvercharged ~= b.isOvercharged then
            return a.isOvercharged
        end
        return a.zone > b.zone or (a.zone == b.zone and a.name > b.name)
    end)
    return temp
end

local function OnDelveEnter(self)
    local delve = self.delve
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine(format("|A:%s:0:0|a %s", delve.atlas, delve.name), 1, 1, 1, false)
    GameTooltip:AddLine(format("%s", delve.zone), 1, 1, 1, false)
    if delve.isOvercharged then
        GameTooltip:AddLine("Overcharged Today", 1, 0.5, 0, false)
    else
        GameTooltip:AddLine("Bountiful", 0, 1, 0, false)
    end
    GameTooltip:Show()
end

local function OnDelveClick(self, button, down)
    if G.config.taintSafe then return end
    local delve = self.delve
    if not WorldMapFrame:IsShown() then
        WorldMapFrame:HandleUserActionOpenSelf()
    end
    WorldMapFrame:SetMapID(delve.mapID)
    if down then return end
    for pin in WorldMapFrame:EnumeratePinsByTemplate("DelveEntrancePinTemplate") do
        if delve.areaPoiID == pin.areaPoiID then
            pin:OnClick(button, down)
            break
        end
    end
end

function G.CreateDelveButton(frame, index)
    local maxPerRow = 4
    local rowIndex = (index - 1) % maxPerRow
    local colIndex = math.floor((index - 1) / maxPerRow) % 2
    local yOffset = -colIndex * 30
    local xOffset = rowIndex * 30
    
    local button = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset - 64)
    button:SetSize(24, 24)
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", "")
    button:RegisterForClicks("AnyUp", "AnyDown")
    button.Icon = button:CreateTexture(nil, "OVERLAY")
    button.Icon:SetAllPoints()
    button.Icon:SetAtlas("Dungeon")
    -- Create border texture for Overcharged outline
    button.Border = button:CreateTexture(nil, "BORDER")
    button.Border:SetPoint("CENTER", button.Icon)
    button.Border:SetSize(26, 26) -- 1px outline
    button.Border:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button.Border:SetVertexColor(0.4, 0.6, 1, 1) -- Brighter blue (R=0.4, G=0.6, B=1, A=1)
    button.Border:Hide() -- Hidden by default
    button:HookScript("OnLeave", GameTooltip_Hide)
    button:HookScript("OnEnter", OnDelveEnter)
    button:HookScript("OnClick", OnDelveClick)
    return button
end

function G.DelvesUpdate(self)
    if InCombatLockdown() then return end
    for _, button in pairs(G.DelveButtons) do
        button:Hide()
    end
    local delves = G.GetDelves()
    for i, delve in ipairs(delves) do
        local button = G.DelveButtons[i]
        if not button then
            button = G.CreateDelveButton(self, i)
            G.DelveButtons[i] = button
        end
        button.delve = delve
        button.Icon:SetAtlas(delve.atlas)
        -- Show blue border for Overcharged delves
        if delve.isOvercharged then
            button.Border:Show()
        else
            button.Border:Hide()
        end
        button:Show()
    end
end

function G.DelvesInit()
    local panel = DelvesDashboardFrame.ButtonPanelLayoutFrame
    local frame = CreateFrame("Frame", nil, panel, "DelvesDashboardButtonPanelFrame")
    frame.layoutIndex = 3
    frame:SetWidth(120)
    frame.ButtonPanelBackground:Hide()
    frame.PanelTitle:SetText("Bountiful & Overcharged")
    frame.PanelDescription:SetText("")
    panel:HookScript("OnShow", function(...) G.DelvesUpdate(frame, ...) panel:Layout() end)
end

function G.TryLoad()
    if InCombatLockdown() then return end
    if DelvesDashboardFrame and not G.Delves then
        G.Delves = true
        G.DelvesInit()
    end
end

VladDelves:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        G.TryLoad()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        G.TryLoad()
    end
end)
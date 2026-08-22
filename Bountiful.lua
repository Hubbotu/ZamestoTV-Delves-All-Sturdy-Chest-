local addonName, addon = ...
local VladDelves = CreateFrame("Frame")

local G = {
    DelveButtons = {},
    Container = nil,
    ExpansionMapID = 2537,
    Zones = {
        [2395] = "Eversong Woods",
        [2393] = "Silvermoon City",
        [2424] = "Isle of Quel'Danas",
        [2405] = "Voidstorm",
        [2437] = "Zul'Aman",
        [2413] = "Harandar",
		[2512] = "The Coiled Isle",
    },
    config = { onlyBountiful = true, taintSafe = false },
    DelveConfig = {
        [76162] = 7105, -- Deadly Deeps
        [27120] = 7041, -- Collegiate Calamity
        [27121] = 7052, -- Parhelion Plaza
        [27122] = 7051, -- Sunkiller Sanctum
        [27123] = 7053, -- Shadowguard Point
    },
}

---------------------------------------------------------
-- Логика получения данных
---------------------------------------------------------
function G.GetDelves()
    local dupe, result = {}, {}
    local scanOrder = {2395, 2393, 2424, 2405, 2437, 2413, 2537, 2512}
    for _, mapID in ipairs(scanOrder) do
        local areaPOIs = C_AreaPoiInfo.GetDelvesForMap(mapID) or {}
        for _, areaPoiID in ipairs(areaPOIs) do
            local poi = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
            if poi and poi.atlasName and poi.atlasName:find("bountiful") then
                if not dupe[poi.name] or (mapID ~= 2537) then
                    local isOvercharged = false
                    local widgetID = G.DelveConfig[areaPoiID]
                    if widgetID then
                        local vis = C_UIWidgetManager.GetSpacerVisualizationInfo(widgetID)
                        isOvercharged = (vis and vis.shownState == 1)
                    end
                    dupe[poi.name] = {
                        name = poi.name, 
                        zone = G.Zones[mapID] or (C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name) or "Unknown",
                        atlas = poi.atlasName, 
                        mapID = mapID, 
                        areaPoiID = areaPoiID, 
                        isOvercharged = isOvercharged,
                    }
                end
            end
        end
    end
    for _, data in pairs(dupe) do table.insert(result, data) end
    table.sort(result, function(a, b) 
        if a.isOvercharged ~= b.isOvercharged then return a.isOvercharged end
        return a.name < b.name 
    end)
    return result
end

---------------------------------------------------------
-- Интерфейс кнопок
---------------------------------------------------------
local function OnDelveEnter(self)
    local delve = self.delve
    if not delve then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(format("|A:%s:0:0|a %s", delve.atlas, delve.name), 1, 1, 1)
    GameTooltip:AddLine(delve.zone, 0.4, 0.8, 1)
    if delve.isOvercharged then
        GameTooltip:AddLine("Overcharged Today", 1, 0.6, 0)
    else
        GameTooltip:AddLine("Bountiful", 0, 1, 0)
    end
    GameTooltip:Show()
end

local function OnDelveClick(self, button, down)
    if G.config.taintSafe or down then return end
    local delve = self.delve
    if not delve then return end
    if not WorldMapFrame:IsShown() then WorldMapFrame:HandleUserActionOpenSelf() end
    WorldMapFrame:SetMapID(delve.mapID)
    for pin in WorldMapFrame:EnumeratePinsByTemplate("DelveEntrancePinTemplate") do
        if pin.areaPoiID == delve.areaPoiID then
            pin:OnClick(button, down)
            break
        end
    end
end

function G.CreateDelveButton(parent, index)
    local button = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    local size, spacing, perRow = 24, 4, 6
    local row = math.floor((index - 1) / perRow)
    local col = (index - 1) % perRow
    
    button:SetSize(size, size)
    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -(col * (size + spacing)), -(row * (size + spacing)))
    
    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetAllPoints()
    button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.Border = button:CreateTexture(nil, "OVERLAY")
    button.Border:SetPoint("CENTER")
    button.Border:SetSize(size + 6, size + 6)
    button.Border:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button.Border:SetVertexColor(0.4, 0.7, 1, 0.9)

    button:SetScript("OnEnter", OnDelveEnter)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", OnDelveClick)

    return button
end

function G.Update()
    if InCombatLockdown() or not G.Container then return end
    local parent = G.Container:GetParent()
    if not parent or not parent:IsVisible() then return end

    local delves = G.GetDelves()
    for _, btn in ipairs(G.DelveButtons) do btn:Hide() end
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
-- Привязка к Атласу
---------------------------------------------------------
local SEASON_MIDNIGHT = "UI-Journeys-Midnight-Button"
local SEASON_WAR_WITHIN = "UI-Journeys-Delve-Button"

local function TryAttach()
    if not EncounterJournal or not EncounterJournal:IsVisible() then return end
    
    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    local scroll = list and list.ScrollTarget
    if not scroll then return end

    local targetFrame = nil
    for _, child in ipairs({scroll:GetChildren()}) do
        if child.GetNormalTexture then
            local atlas = child:GetNormalTexture():GetAtlas()
            if atlas == SEASON_MIDNIGHT or atlas == SEASON_WAR_WITHIN then
                targetFrame = child; break
            end
        end
    end

    if targetFrame and targetFrame:IsVisible() then
        if not G.Container then G.Container = CreateFrame("Frame", "VladBountifulContainer", targetFrame) end
        if G.Container:GetParent() ~= targetFrame then G.Container:SetParent(targetFrame) end
        
        G.Container:SetSize(180, 80)
        G.Container:ClearAllPoints()
        G.Container:SetPoint("CENTER", targetFrame, "CENTER", -92, -8)
        G.Container:SetScale(0.92)
        G.Container:Show()
        G.Update()
    elseif G.Container then
        G.Container:Hide()
    end
end

---------------------------------------------------------
-- Инициализация
---------------------------------------------------------
local function SetupBountifulHooks()
    local list = EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneysList
    if list then
        hooksecurefunc(list, "Update", TryAttach)
        if list.ScrollBox then
            list.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, TryAttach)
        end
    end
end

VladDelves:RegisterEvent("ADDON_LOADED")
VladDelves:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
VladDelves:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_EncounterJournal" then
            SetupBountifulHooks()
        elseif arg1 == addonName and C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
            SetupBountifulHooks()
        end
    end
    if G.Container and G.Container:IsVisible() then G.Update() end
end)
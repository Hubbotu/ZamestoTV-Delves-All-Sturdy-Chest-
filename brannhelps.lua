local addonName, addon = "DelveCurioReminder", {}
_G[addonName] = addon

-- Constants
local FRAME_WIDTH, FRAME_HEIGHT = 381, 240
local ICON_SIZE = 35 -- Size for item and role icons

-- Curio Data with corrected texture coordinates
local curioData = {
    TANK = {
        combatCurio = {name = "Mechasaur EZ-Build Kit", itemID = 234015},
        utilityCurio = {name = "Three Dimensional Bioprinter", itemID = 230226},
        roleTexture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
        roleTexCoord = {0, 0.26171875, 0.26171875, 0.5234375}, -- Corrected Tank coords
        groupIcon = 135806,
        xOffset = -132,
        yOffset = -70
    },
    HEALER = {
        combatCurio = {name = "Mechasaur EZ-Build Kit", itemID = 234015},
        utilityCurio = {name = "Three Dimensional Bioprinter", itemID = 230226},
        roleTexture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
        roleTexCoord = {0.26171875, 0.5234375, 0, 0.26171875}, -- Unchanged, correct
        groupIcon = 135769,
        xOffset = -132,
        yOffset = 0
    },
    DAMAGE = {
        combatCurio = {name = "Pinged Augment Chip", itemID = 230234},
        utilityCurio = {name = "Biofuel Rocket Gear", itemID = 230233},
        roleTexture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
        roleTexCoord = {0.26171875, 0.5234375, 0.26171875, 0.5234375}, -- Corrected DPS coords
        groupIcon = 135274,
        xOffset = -132,
        yOffset = 70
    }
}

-- Main Frame Creation with Draggable Functionality
local function CreateMainFrame()
    local frame = CreateFrame("Frame", "DelveCurioReminderFrame", UIParent)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetFrameStrata("MEDIUM")
    frame:SetAlpha(1)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide() -- Explicitly hide the frame by default

    -- Load position from SavedVariables or set default
    if DelveCurioReminderDB and DelveCurioReminderDB.mainFrame then
        frame:SetPoint(
            DelveCurioReminderDB.mainFrame.point or "CENTER",
            UIParent,
            DelveCurioReminderDB.mainFrame.relativePoint or "CENTER",
            DelveCurioReminderDB.mainFrame.xOffset or 0,
            DelveCurioReminderDB.mainFrame.yOffset or -377.5
        )
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, -377.5)
    end

    -- Drag Script
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        if not DelveCurioReminderDB then DelveCurioReminderDB = {} end
        if not DelveCurioReminderDB.mainFrame then DelveCurioReminderDB.mainFrame = {} end
        DelveCurioReminderDB.mainFrame.point = point
        DelveCurioReminderDB.mainFrame.relativePoint = relativePoint
        DelveCurioReminderDB.mainFrame.xOffset = xOffset
        DelveCurioReminderDB.mainFrame.yOffset = yOffset
    end)

    frame.timeoutEnabled = false -- Default timeout state
    frame.timeoutDuration = 10 -- Timeout duration in seconds

    return frame
end

-- Role Frame Creation with Role and Item Icons
local function CreateRoleFrame(parent, role, data)
    local frame = CreateFrame("Frame", "DelveCurioReminder_" .. role, parent)
    frame:SetSize(300, ICON_SIZE * 2 + 20)
    frame:SetPoint("CENTER", parent, "CENTER", data.xOffset, data.yOffset)
    frame:SetFrameStrata("MEDIUM")
    frame:SetAlpha(1)

    -- Role Icon
    local roleIcon = frame:CreateTexture(nil, "ARTWORK")
    roleIcon:SetSize(ICON_SIZE, ICON_SIZE)
    roleIcon:SetPoint("LEFT", frame, "LEFT", 0, ICON_SIZE / 2)
    roleIcon:SetTexture(data.roleTexture)
    roleIcon:SetTexCoord(unpack(data.roleTexCoord))
    roleIcon:SetBlendMode("BLEND")
    roleIcon:SetVertexColor(1, 1, 1, 1)

    -- Combat Curio Icon
    local combatIcon = frame:CreateTexture(nil, "ARTWORK")
    combatIcon:SetSize(ICON_SIZE, ICON_SIZE)
    combatIcon:SetPoint("LEFT", roleIcon, "RIGHT", 5, 0)
    combatIcon:SetTexture(GetItemIcon(data.combatCurio.itemID))
    combatIcon:SetBlendMode("BLEND")
    combatIcon:SetVertexColor(1, 1, 1, 1)

    -- Combat Curio Text
    local combatText = frame:CreateFontString(nil, "OVERLAY")
    combatText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    combatText:SetTextColor(0.9764706492424, 1, 0, 1)
    combatText:SetPoint("LEFT", combatIcon, "RIGHT", 5, 0)
    combatText:SetText("Combat Curio: " .. data.combatCurio.name)
    combatText:SetJustifyH("LEFT")
    combatText:SetShadowColor(0, 0, 0, 1)
    combatText:SetShadowOffset(1, -1)

    -- Combat Item Count
    local combatCount = frame:CreateFontString(nil, "OVERLAY")
    combatCount:SetFont("Fonts\\FRIZQT__.TTF", 24)
    combatCount:SetTextColor(1, 1, 1, 1)
    combatCount:SetPoint("LEFT", combatText, "RIGHT", 5, 0)
    combatCount:SetText("")
    combatCount:SetJustifyH("LEFT")
    combatCount:SetShadowColor(0, 0, 0, 1)
    combatCount:SetShadowOffset(1, -1)

    -- Utility Curio Icon
    local utilityIcon = frame:CreateTexture(nil, "ARTWORK")
    utilityIcon:SetSize(ICON_SIZE, ICON_SIZE)
    utilityIcon:SetPoint("LEFT", frame, "LEFT", ICON_SIZE + 5, -ICON_SIZE / 2)
    utilityIcon:SetTexture(GetItemIcon(data.utilityCurio.itemID))
    utilityIcon:SetBlendMode("BLEND")
    utilityIcon:SetVertexColor(1, 1, 1, 1)

    -- Utility Curio Text
    local utilityText = frame:CreateFontString(nil, "OVERLAY")
    utilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    utilityText:SetTextColor(0, 1, 0.80392163991928, 1)
    utilityText:SetPoint("LEFT", utilityIcon, "RIGHT", 5, 0)
    utilityText:SetText("Utility Curio: " .. data.utilityCurio.name)
    utilityText:SetJustifyH("LEFT")
    utilityText:SetShadowColor(0, 0, 0, 1)
    utilityText:SetShadowOffset(1, -1)

    -- Utility Item Count
    local utilityCount = frame:CreateFontString(nil, "OVERLAY")
    utilityCount:SetFont("Fonts\\FRIZQT__.TTF", 24)
    utilityCount:SetTextColor(1, 1, 1, 1)
    utilityCount:SetPoint("LEFT", utilityText, "RIGHT", 5, 0)
    utilityCount:SetText("")
    utilityCount:SetJustifyH("LEFT")
    utilityCount:SetShadowColor(0, 0, 0, 1)
    utilityCount:SetShadowOffset(1, -1)

    -- Subregion: Background (transparent)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetTexture(0, 0, 0, 0)

    frame.combatCount = combatCount
    frame.utilityCount = utilityCount
    frame.combatItemID = data.combatCurio.itemID
    frame.utilityItemID = data.utilityCurio.itemID

    return frame
end

-- Update Item Counts (Hide Zeros)
local function UpdateItemCounts(frame)
    local combatCount = GetItemCount(frame.combatItemID, false)
    local utilityCount = GetItemCount(frame.utilityItemID, false)
    
    frame.combatCount:SetText(combatCount > 0 and tostring(combatCount) or "")
    frame.utilityCount:SetText(utilityCount > 0 and tostring(utilityCount) or "")
end

-- Timeout Functionality
local function StartTimeout(frame)
    if frame.timeoutEnabled then
        C_Timer.After(frame.timeoutDuration, function()
            if frame:IsShown() and not DelvesCompanionConfigurationFrame:IsShown() then
                frame:Hide()
                print("Delve Curio Reminder: Frame hidden due to timeout.")
            end
        end)
    end
end

-- Event Handler
local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Initialize SavedVariables if not already done
        if not DelveCurioReminderDB then
            DelveCurioReminderDB = {}
        end

        addon.mainFrame = CreateMainFrame()
        addon.roleFrames = {}

        for role, data in pairs(curioData) do
            addon.roleFrames[role] = CreateRoleFrame(addon.mainFrame, role, data)
        end

        self:RegisterEvent("BAG_UPDATE")
        self:RegisterEvent("ADDON_LOADED")

        -- Hook into DelvesCompanionConfigurationFrame show/hide
        if DelvesCompanionConfigurationFrame then
            DelvesCompanionConfigurationFrame:HookScript("OnShow", function()
                addon.mainFrame:Show()
                for _, frame in pairs(addon.roleFrames) do
                    UpdateItemCounts(frame)
                end
                StartTimeout(addon.mainFrame)
            end)
            DelvesCompanionConfigurationFrame:HookScript("OnHide", function()
                addon.mainFrame:Hide()
            end)
        end

    elseif event == "ADDON_LOADED" and select(1, ...) == "Blizzard_DelvesCompanionConfiguration" then
        -- Hook into DelvesCompanionConfigurationFrame after it's loaded
        if DelvesCompanionConfigurationFrame then
            DelvesCompanionConfigurationFrame:HookScript("OnShow", function()
                addon.mainFrame:Show()
                for _, frame in pairs(addon.roleFrames) do
                    UpdateItemCounts(frame)
                end
                StartTimeout(addon.mainFrame)
            end)
            DelvesCompanionConfigurationFrame:HookScript("OnHide", function()
                addon.mainFrame:Hide()
            end)
        end

    elseif event == "BAG_UPDATE" then
        for _, frame in pairs(addon.roleFrames) do
            UpdateItemCounts(frame)
        end
        if DelvesCompanionConfigurationFrame and DelvesCompanionConfigurationFrame:IsShown() then
            StartTimeout(addon.mainFrame) -- Trigger timeout only if companion frame is open
        end
    end
end

-- Initialize Addon
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnEvent)

-- Slash Command with Timeout Toggle
SLASH_HELPBRANN1 = "/helpbrann"
SlashCmdList["HELPBRANN"] = function(msg)
    if msg == "show" then
        addon.mainFrame:Show()
        StartTimeout(addon.mainFrame)
    elseif msg == "hide" then
        addon.mainFrame:Hide()
    elseif msg == "enable" then
        addon.mainFrame.timeoutEnabled = true
        if not DelveCurioReminderDB then DelveCurioReminderDB = {} end
        DelveCurioReminderDB.timeoutEnabled = true
        print("Delve Curio Reminder: Timeout enabled. Frame will hide after " .. addon.mainFrame.timeoutDuration .. " seconds.")
        if addon.mainFrame:IsShown() then
            StartTimeout(addon.mainFrame)
        end
    elseif msg == "disable" then
        addon.mainFrame.timeoutEnabled = false
        if not DelveCurioReminderDB then DelveCurioReminderDB = {} end
        DelveCurioReminderDB.timeoutEnabled = false
        print("Delve Curio Reminder: Timeout disabled. Frame will remain visible.")
    elseif msg == "reset" then
        addon.mainFrame:ClearAllPoints()
        addon.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -377.5)
        if not DelveCurioReminderDB then DelveCurioReminderDB = {} end
        DelveCurioReminderDB.mainFrame = {
            point = "CENTER",
            relativePoint = "CENTER",
            xOffset = 0,
            yOffset = -377.5
        }
        print("Frame position reset to default.")
    else
        print("Delve Curio Reminder - Usage:")
        print("/helpbrann show - Show the reminder frame")
        print("/helpbrann hide - Hide the reminder frame")
        print("/helpbrann enable - Enable auto-hide timeout")
        print("/helpbrann disable - Disable auto-hide timeout")
        print("/helpbrann reset - Reset frame position to default")
    end
end

-- Load timeout setting from SavedVariables
local function LoadSettings()
    if DelveCurioReminderDB and DelveCurioReminderDB.timeoutEnabled ~= nil then
        addon.mainFrame.timeoutEnabled = DelveCurioReminderDB.timeoutEnabled
    end
end

-- Call LoadSettings after frame creation
eventFrame:HookScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        LoadSettings()
    end
    OnEvent(self, event, ...)
end)
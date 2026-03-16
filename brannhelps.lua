local addonName, addon = "DelveCurioReminder", {}
_G[addonName] = addon

-- ==================== Constants ====================
local FRAME_WIDTH, FRAME_HEIGHT = 381, 240
local ICON_SIZE = 35

-- ==================== Companion-specific Curio Data ====================
local companionCurioData = {
    Brann = {
        TANK = {
            combatCurio   = {name = "Mana-Tinted Glasses", itemID = 239576},
            utilityCurio  = {name = "Tailwind Conduit",    itemID = 239567},
            roleTexture   = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
            roleTexCoord  = {0, 0.26171875, 0.26171875, 0.5234375},
            groupIcon     = 135806,
            xOffset       = -132,
            yOffset       = -70
        },
        HEALER = {
            combatCurio   = {name = "Nether Overlay Matrix", itemID = 239580},
            utilityCurio  = {name = "Tailwind Conduit",      itemID = 239567},
            roleTexture   = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
            roleTexCoord  = {0.26171875, 0.5234375, 0, 0.26171875},
            groupIcon     = 135769,
            xOffset       = -132,
            yOffset       = 0
        },
        DAMAGE = {
            combatCurio   = {name = "Quizzical Device", itemID = 239578},
            utilityCurio  = {name = "Tailwind Conduit", itemID = 239567},
            roleTexture   = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
            roleTexCoord  = {0.26171875, 0.5234375, 0.26171875, 0.5234375},
            groupIcon     = 135274,
            xOffset       = -132,
            yOffset       = 70
        }
    },

    Valeera = {
        TANK = {
            combatCurio   = {name = "Porcelain Blade Tip",   itemID = 257683},
            utilityCurio  = {name = "Mandate of Sacred Death", itemID = 249225},
            roleTexture   = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
            roleTexCoord  = {0, 0.26171875, 0.26171875, 0.5234375},
            groupIcon     = 135806,
            xOffset       = -132,
            yOffset       = -70
        },
        HEALER = {
            combatCurio   = {name = "Porcelain Blade Tip",   itemID = 257683},
            utilityCurio  = {name = "Mandate of Sacred Death", itemID = 249225},
            roleTexture   = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
            roleTexCoord  = {0.26171875, 0.5234375, 0, 0.26171875},
            groupIcon     = 135769,
            xOffset       = -132,
            yOffset       = 0
        },
        DAMAGE = {
            combatCurio   = {name = "Porcelain Blade Tip",   itemID = 257683},
            utilityCurio  = {name = "Mandate of Sacred Death", itemID = 249225},
            roleTexture   = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
            roleTexCoord  = {0.26171875, 0.5234375, 0.26171875, 0.5234375},
            groupIcon     = 135274,
            xOffset       = -132,
            yOffset       = 70
        }
    }
}

-- ==================== Helper Functions ====================
local function GetCurrentCompanionName()
    if not DelvesCompanionConfigurationFrame then return nil end
    local infoFrame = DelvesCompanionConfigurationFrame.CompanionInfoFrame
    if not infoFrame then return nil end

    for _, region in ipairs({infoFrame:GetRegions()}) do
        if region:IsObjectType("FontString") then
            local txt = region:GetText()
            if txt then
                if txt:find("Brann Bronzebeard") or txt:find("Бранн Бронзобород") then
                    return "Brann"
                elseif txt:find("Valeera Sanguinar") or txt:find("Валира") then
                    return "Valeera"
                end
            end
        end
    end
    return nil
end

local function GetCurioDataForCompanion()
    local companion = GetCurrentCompanionName()
    if not companion then return nil end
    return companionCurioData[companion]
end

-- ==================== Role Frame Creation ====================
local function CreateRoleFrame(parent, role, data)
    local frame = CreateFrame("Frame", "DelveCurioReminder_" .. role, parent)
    frame:SetSize(300, ICON_SIZE * 2 + 20)
    frame:SetPoint("CENTER", parent, "CENTER", data.xOffset, data.yOffset)
    frame:SetFrameStrata("MEDIUM")

    -- Role icon
    local roleIcon = frame:CreateTexture(nil, "ARTWORK")
    roleIcon:SetSize(ICON_SIZE, ICON_SIZE)
    roleIcon:SetPoint("LEFT", frame, "LEFT", 0, ICON_SIZE / 2)
    roleIcon:SetTexture(data.roleTexture)
    roleIcon:SetTexCoord(unpack(data.roleTexCoord))

    -- Combat curio icon
    local combatIcon = frame:CreateTexture(nil, "ARTWORK")
    combatIcon:SetSize(ICON_SIZE, ICON_SIZE)
    combatIcon:SetPoint("LEFT", roleIcon, "RIGHT", 5, 0)
    combatIcon:SetTexture(GetItemIcon(data.combatCurio.itemID))

    local combatText = frame:CreateFontString(nil, "OVERLAY")
    combatText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    combatText:SetTextColor(0.976, 1, 0, 1)
    combatText:SetPoint("LEFT", combatIcon, "RIGHT", 5, 0)
    combatText:SetText("Combat Curio: " .. data.combatCurio.name)

    local combatCount = frame:CreateFontString(nil, "OVERLAY")
    combatCount:SetFont("Fonts\\FRIZQT__.TTF", 24)
    combatCount:SetTextColor(1,1,1,1)
    combatCount:SetPoint("LEFT", combatText, "RIGHT", 5, 0)
    combatCount:SetText("")

    -- Utility curio icon
    local utilityIcon = frame:CreateTexture(nil, "ARTWORK")
    utilityIcon:SetSize(ICON_SIZE, ICON_SIZE)
    utilityIcon:SetPoint("LEFT", frame, "LEFT", ICON_SIZE + 5, -ICON_SIZE / 2)
    utilityIcon:SetTexture(GetItemIcon(data.utilityCurio.itemID))

    local utilityText = frame:CreateFontString(nil, "OVERLAY")
    utilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    utilityText:SetTextColor(0, 1, 0.804, 1)
    utilityText:SetPoint("LEFT", utilityIcon, "RIGHT", 5, 0)
    utilityText:SetText("Utility Curio: " .. data.utilityCurio.name)

    local utilityCount = frame:CreateFontString(nil, "OVERLAY")
    utilityCount:SetFont("Fonts\\FRIZQT__.TTF", 24)
    utilityCount:SetTextColor(1,1,1,1)
    utilityCount:SetPoint("LEFT", utilityText, "RIGHT", 5, 0)
    utilityCount:SetText("")

    frame.combatCount   = combatCount
    frame.utilityCount  = utilityCount
    frame.combatItemID  = data.combatCurio.itemID
    frame.utilityItemID = data.utilityCurio.itemID

    return frame
end

local function UpdateItemCounts(frame)
    if not frame then return end
    local combatCount  = GetItemCount(frame.combatItemID,  false) or 0
    local utilityCount = GetItemCount(frame.utilityItemID, false) or 0
    frame.combatCount:SetText(combatCount > 0 and tostring(combatCount) or "")
    frame.utilityCount:SetText(utilityCount > 0 and tostring(utilityCount) or "")
end

-- ==================== Main Frame ====================
local function CreateMainFrame()
    local f = CreateFrame("Frame", "DelveCurioReminderFrame", UIParent)
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:Hide()

    -- Load saved position or use default
    if DelveCurioReminderDB and DelveCurioReminderDB.mainFrame then
        f:SetPoint(
            DelveCurioReminderDB.mainFrame.point or "CENTER",
            UIParent,
            DelveCurioReminderDB.mainFrame.relativePoint or "CENTER",
            DelveCurioReminderDB.mainFrame.xOffset or 0,
            DelveCurioReminderDB.mainFrame.yOffset or -377.5
        )
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, -377.5)
    end

    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        if not DelveCurioReminderDB then DelveCurioReminderDB = {} end
        DelveCurioReminderDB.mainFrame = {
            point = point,
            relativePoint = relPoint,
            xOffset = x,
            yOffset = y
        }
    end)

    f.timeoutEnabled  = false
    f.timeoutDuration = 10

    return f
end

-- ==================== Refresh Logic ====================
local function RefreshRoleFrames()
    if not addon.mainFrame then return end

    -- Clear old frames
    if addon.roleFrames then
        for _, frm in pairs(addon.roleFrames) do
            frm:Hide()
            frm:ClearAllPoints()
        end
    end

    local data = GetCurioDataForCompanion()
    if not data then
        addon.mainFrame:Hide()
        return
    end

    addon.roleFrames = {}
    for role, curio in pairs(data) do
        local frm = CreateRoleFrame(addon.mainFrame, role, curio)
        addon.roleFrames[role] = frm
        UpdateItemCounts(frm)
        frm:Show()
    end
end

local function StartTimeout()
    if not addon.mainFrame or not addon.mainFrame.timeoutEnabled then return end

    C_Timer.After(addon.mainFrame.timeoutDuration, function()
        if addon.mainFrame:IsShown() 
           and (not DelvesCompanionConfigurationFrame or not DelvesCompanionConfigurationFrame:IsShown()) then
            addon.mainFrame:Hide()
        end
    end)
end

-- ==================== Event Handler ====================
local function OnEvent(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        if not DelveCurioReminderDB then DelveCurioReminderDB = {} end
        addon.mainFrame = CreateMainFrame()

        -- Load timeout setting
        addon.mainFrame.timeoutEnabled = DelveCurioReminderDB.timeoutEnabled ~= false

        local function HookCompanionFrame()
            if not DelvesCompanionConfigurationFrame then return end

            DelvesCompanionConfigurationFrame:HookScript("OnShow", function()
                RefreshRoleFrames()
                addon.mainFrame:Show()
                StartTimeout()
            end)

            DelvesCompanionConfigurationFrame:HookScript("OnHide", function()
                addon.mainFrame:Hide()
            end)

            if DelvesCompanionConfigurationFrame:IsShown() then
                RefreshRoleFrames()
                addon.mainFrame:Show()
            end
        end

        if DelvesCompanionConfigurationFrame then
            HookCompanionFrame()
        else
            self:RegisterEvent("ADDON_LOADED")
        end

    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_DelvesCompanionConfiguration" then
        local function HookCompanionFrame() -- redefined locally to avoid global leak
            if not DelvesCompanionConfigurationFrame then return end
            DelvesCompanionConfigurationFrame:HookScript("OnShow", function()
                RefreshRoleFrames()
                addon.mainFrame:Show()
                StartTimeout()
            end)
            DelvesCompanionConfigurationFrame:HookScript("OnHide", function()
                addon.mainFrame:Hide()
            end)
            if DelvesCompanionConfigurationFrame:IsShown() then
                RefreshRoleFrames()
                addon.mainFrame:Show()
            end
        end
        HookCompanionFrame()

    elseif event == "BAG_UPDATE" then
        if addon.roleFrames and DelvesCompanionConfigurationFrame and DelvesCompanionConfigurationFrame:IsShown() then
            for _, frm in pairs(addon.roleFrames) do
                UpdateItemCounts(frm)
            end
            StartTimeout()
        end
    end
end

local ef = CreateFrame("Frame")
ef:RegisterEvent("PLAYER_LOGIN")
ef:RegisterEvent("BAG_UPDATE")
ef:SetScript("OnEvent", OnEvent)

-- ==================== Slash Commands ====================
SLASH_DELVEREMINDER1 = "/delvereminder"
SLASH_DELVEREMINDER2 = "/helpbrann"

SlashCmdList["DELVEREMINDER"] = function(msg)
    msg = (msg or ""):trim():lower()

    if msg == "show" then
        RefreshRoleFrames()
        if GetCurioDataForCompanion() then
            addon.mainFrame:Show()
        end
        StartTimeout()
    elseif msg == "hide" then
        if addon.mainFrame then addon.mainFrame:Hide() end
    elseif msg == "enable" then
        if addon.mainFrame then
            addon.mainFrame.timeoutEnabled = true
            DelveCurioReminderDB.timeoutEnabled = true
            print("Delve Curio Reminder: Auto-hide timeout enabled (" .. addon.mainFrame.timeoutDuration .. " seconds)")
        end
    elseif msg == "disable" then
        if addon.mainFrame then
            addon.mainFrame.timeoutEnabled = false
            DelveCurioReminderDB.timeoutEnabled = false
            print("Delve Curio Reminder: Auto-hide timeout disabled")
        end
    elseif msg == "reset" then
        if addon.mainFrame then
            addon.mainFrame:ClearAllPoints()
            addon.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -377.5)
            DelveCurioReminderDB.mainFrame = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = -377.5
            }
            print("Delve Curio Reminder: Frame position reset to default")
        end
    else
        print("Delve Curio Reminder commands:")
        print("  /delvereminder show     - Show the curio reminder frame")
        print("  /delvereminder hide     - Hide the curio reminder frame")
        print("  /delvereminder enable   - Enable auto-hide after inactivity")
        print("  /delvereminder disable  - Disable auto-hide")
        print("  /delvereminder reset    - Reset frame position to center")
    end
end
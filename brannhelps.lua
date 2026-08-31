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
        combatCurio  = {name = "Corrosive Bilespear",        itemID = 249223},
        utilityCurio = {name = "Soul-Cracking Dreamcatcher", itemID = 249228},
        curioToxin   = {name = "Bursting Toad Toxin",        spellID = 1305904},
        roles = {
            { texture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", texCoord = {0, 0.26171875, 0.26171875, 0.5234375} }, -- Tank
            { texture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", texCoord = {0.26171875, 0.5234375, 0, 0.26171875} }, -- Healer
            { texture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", texCoord = {0.26171875, 0.5234375, 0.26171875, 0.5234375} } -- DPS
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

-- ==================== Role Frame Creation (Brann) ====================
local function CreateRoleFrame(parent, role, data)
    local frame = CreateFrame("Frame", "DelveCurioReminder_" .. role, parent)
    frame:SetSize(300, ICON_SIZE * 2 + 20)
    frame:SetPoint("CENTER", parent, "CENTER", data.xOffset, data.yOffset)
    frame:SetFrameStrata("MEDIUM")

    local roleIcon = frame:CreateTexture(nil, "ARTWORK")
    roleIcon:SetSize(ICON_SIZE, ICON_SIZE)
    roleIcon:SetPoint("LEFT", frame, "LEFT", 0, ICON_SIZE / 2)
    roleIcon:SetTexture(data.roleTexture)
    roleIcon:SetTexCoord(unpack(data.roleTexCoord))

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

    local utilityIcon = frame:CreateTexture(nil, "ARTWORK")
    utilityIcon:SetSize(ICON_SIZE, ICON_SIZE)
    utilityIcon:SetPoint("LEFT", frame, "LEFT", ICON_SIZE + 5, -ICON_SIZE / 2)
    utilityIcon:SetTexture(GetItemIcon(data.utilityCurio.itemID))

    local utilityText = frame:CreateFontString(nil, "OVERLAY")
    utilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    utilityText:SetTextColor(0, 1, 0.804, 1)
    utilityText:SetPoint("LEFT", utilityIcon, "RIGHT", 5, 0)
    utilityText:SetText("Utility Curio: " .. data.utilityCurio.name) -- Исправлено: SetText вместо Text

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

-- ==================== Role Frame Creation (Valeera) ====================
local function CreateValeeraFrame(parent, data)
    local frame = CreateFrame("Frame", "DelveCurioReminder_Valeera", parent)
    frame:SetSize(320, ICON_SIZE * 3 + 40)
    frame:SetPoint("CENTER", parent, "CENTER", -80, 0)
    frame:SetFrameStrata("MEDIUM")

    -- 1. Иконки ролей сверху
    local prevRoleIcon = nil
    for i, roleData in ipairs(data.roles) do
        local rIcon = frame:CreateTexture(nil, "ARTWORK")
        rIcon:SetSize(ICON_SIZE * 0.8, ICON_SIZE * 0.8)
        if not prevRoleIcon then
            rIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, 0)
        else
            rIcon:SetPoint("LEFT", prevRoleIcon, "RIGHT", 6, 0)
        end
        rIcon:SetTexture(roleData.texture)
        rIcon:SetTexCoord(unpack(roleData.texCoord))
        prevRoleIcon = rIcon
    end

    -- 2. Спек строка 1: Combat Curio
    local combatIcon = frame:CreateTexture(nil, "ARTWORK")
    combatIcon:SetSize(ICON_SIZE, ICON_SIZE)
    combatIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -ICON_SIZE)
    combatIcon:SetTexture(GetItemIcon(data.combatCurio.itemID))

    local combatText = frame:CreateFontString(nil, "OVERLAY")
    combatText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    combatText:SetTextColor(0.976, 1, 0, 1)
    combatText:SetPoint("LEFT", combatIcon, "RIGHT", 8, 0)
    combatText:SetText("Combat: " .. data.combatCurio.name)

    local combatCount = frame:CreateFontString(nil, "OVERLAY")
    combatCount:SetFont("Fonts\\FRIZQT__.TTF", 20)
    combatCount:SetTextColor(1, 1, 1, 1)
    combatCount:SetPoint("LEFT", combatText, "RIGHT", 6, 0)

    -- 3. Спек строка 2: Utility Curio
    local utilityIcon = frame:CreateTexture(nil, "ARTWORK")
    utilityIcon:SetSize(ICON_SIZE, ICON_SIZE)
    utilityIcon:SetPoint("TOPLEFT", combatIcon, "BOTTOMLEFT", 0, -8)
    utilityIcon:SetTexture(GetItemIcon(data.utilityCurio.itemID))

    local utilityText = frame:CreateFontString(nil, "OVERLAY")
    utilityText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    utilityText:SetTextColor(0, 1, 0.804, 1)
    utilityText:SetPoint("LEFT", utilityIcon, "RIGHT", 8, 0)
    utilityText:SetText("Utility: " .. data.utilityCurio.name)

    local utilityCount = frame:CreateFontString(nil, "OVERLAY")
    utilityCount:SetFont("Fonts\\FRIZQT__.TTF", 20)
    utilityCount:SetTextColor(1, 1, 1, 1)
    utilityCount:SetPoint("LEFT", utilityText, "RIGHT", 6, 0)

    -- 4. Спек строка 3: Curio Toxin
    local toxinIcon = frame:CreateTexture(nil, "ARTWORK")
    toxinIcon:SetSize(ICON_SIZE, ICON_SIZE)
    toxinIcon:SetPoint("TOPLEFT", utilityIcon, "BOTTOMLEFT", 0, -8)
    
    local spellInfo = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(data.curioToxin.spellID)
    local toxinTexture = spellInfo and spellInfo.iconID or 136068
    toxinIcon:SetTexture(toxinTexture)

    local toxinText = frame:CreateFontString(nil, "OVERLAY")
    toxinText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    toxinText:SetTextColor(0.6, 1, 0.2, 1)
    toxinText:SetPoint("LEFT", toxinIcon, "RIGHT", 8, 0)
    toxinText:SetText("Toxin: " .. data.curioToxin.name)

    local toxinCount = frame:CreateFontString(nil, "OVERLAY")
    toxinCount:SetFont("Fonts\\FRIZQT__.TTF", 20)
    toxinCount:SetTextColor(1, 1, 1, 1)
    toxinCount:SetPoint("LEFT", toxinText, "RIGHT", 6, 0)

    frame.combatCount   = combatCount
    frame.utilityCount  = utilityCount
    frame.toxinCount    = toxinCount
    frame.combatItemID  = data.combatCurio.itemID
    frame.utilityItemID = data.utilityCurio.itemID
    frame.toxinSpellID  = data.curioToxin.spellID

    return frame
end

local function UpdateItemCounts(frame)
    if not frame then return end
    if frame.combatItemID then
        local combatCount = GetItemCount(frame.combatItemID, false) or 0
        frame.combatCount:SetText(combatCount > 0 and tostring(combatCount) or "")
    end
    if frame.utilityItemID then
        local utilityCount = GetItemCount(frame.utilityItemID, false) or 0
        frame.utilityCount:SetText(utilityCount > 0 and tostring(utilityCount) or "")
    end
    if frame.toxinSpellID and frame.toxinCount then
        local toxinCount = GetItemCount(frame.toxinSpellID, false) or 0
        frame.toxinCount:SetText(toxinCount > 0 and tostring(toxinCount) or "")
    end
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

    if addon.roleFrames then
        for _, frm in pairs(addon.roleFrames) do
            frm:Hide()
            frm:ClearAllPoints()
        end
    end

    local companion = GetCurrentCompanionName()
    local data = GetCurioDataForCompanion()
    if not data or not companion then
        addon.mainFrame:Hide()
        return
    end

    addon.roleFrames = {}

    if companion == "Valeera" then
        local frm = CreateValeeraFrame(addon.mainFrame, data)
        addon.roleFrames["Valeera"] = frm
        UpdateItemCounts(frm)
        frm:Show()
    else
        for role, curio in pairs(data) do
            local frm = CreateRoleFrame(addon.mainFrame, role, curio)
            addon.roleFrames[role] = frm
            UpdateItemCounts(frm)
            frm:Show()
        end
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
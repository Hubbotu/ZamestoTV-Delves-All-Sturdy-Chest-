local addonName, addon = ...

---------------------------------------------------------
-- DB (will be initialized on ADDON_LOADED)
---------------------------------------------------------
local DB

---------------------------------------------------------
-- UI Helpers
---------------------------------------------------------
local function CreateCheckbox(parent, label, tooltip, getter, setter, y)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 16, y)

    cb.Text:SetText(label)

    if tooltip then
        cb.tooltipText = label
        cb.tooltipRequirement = tooltip
    end

    cb:SetScript("OnShow", function(self)
        self:SetChecked(getter())
    end)

    cb:SetScript("OnClick", function(self)
        setter(self:GetChecked())
    end)

    cb:SetChecked(getter())
    return cb
end

local function CreateButton(parent, text, y, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(220, 22)
    btn:SetPoint("TOPLEFT", 16, y)
    btn:SetText(text)
    btn:SetScript("OnClick", onClick)
    return btn
end

---------------------------------------------------------
-- Settings Panel
---------------------------------------------------------
local function BuildOptionsPanel()
    if addon.optionsBuilt then return end
    addon.optionsBuilt = true

    local panel = CreateFrame("Frame")
    panel.name = "Delves Helper"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Delves Helper")

    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    sub:SetText("Manage Delves addons via interface")

    local y = -60

    ---------------------------------------------------------
    -- DELVEREMINDER
    ---------------------------------------------------------
    CreateCheckbox(panel,
        "Delve Reminder: Show Frame",
        "/delvereminder show / hide",
        function() return DB.delvereminder.visible end,
        function(v)
            DB.delvereminder.visible = v
            if SlashCmdList["DELVEREMINDER"] then
                if v then
                    SlashCmdList["DELVEREMINDER"]("show")
                else
                    SlashCmdList["DELVEREMINDER"]("hide")
                end
            end
        end,
        y
    )
    y = y - 28

    CreateCheckbox(panel,
        "Delve Reminder: Auto Hide",
        "/delvereminder enable / disable",
        function() return DB.delvereminder.autoHide end,
        function(v)
            DB.delvereminder.autoHide = v
            if SlashCmdList["DELVEREMINDER"] then
                if v then
                    SlashCmdList["DELVEREMINDER"]("enable")
                else
                    SlashCmdList["DELVEREMINDER"]("disable")
                end
            end
        end,
        y
    )
    y = y - 28

    CreateButton(panel, "Reset Position (Delve Reminder)", y, function()
        if SlashCmdList["DELVEREMINDER"] then
            SlashCmdList["DELVEREMINDER"]("reset")
        end
    end)
    y = y - 40

    ---------------------------------------------------------
    -- GWA
    ---------------------------------------------------------
    CreateCheckbox(panel,
        "Great Vault Rewards (GWA)",
        "/gwa — toggle visibility",
        function() return DB.gwa.visible end,
        function(v)
            DB.gwa.visible = v
            if SlashCmdList["GWA"] then
                SlashCmdList["GWA"]()
            end
        end,
        y
    )
    y = y - 40

    ---------------------------------------------------------
    -- DQT
    ---------------------------------------------------------
    CreateCheckbox(panel,
        "Delves Quest Tracker",
        "/dqt — toggle visibility",
        function() return DB.dqt.visible end,
        function(v)
            DB.dqt.visible = v
            if SlashCmdList["DELVERSQUESTTRACKER"] then
                SlashCmdList["DELVERSQUESTTRACKER"]()
            end
        end,
        y
    )
    y = y - 40

    ---------------------------------------------------------
    -- ZDH
    ---------------------------------------------------------
    CreateCheckbox(panel,
        "Delves Helper Tracker",
        "/zdh show / hide",
        function() return DB.zdh.visible end,
        function(v)
            DB.zdh.visible = v
            if SlashCmdList["ZDH"] then
                if v then
                    SlashCmdList["ZDH"]("show")
                else
                    SlashCmdList["ZDH"]("hide")
                end
            end
        end,
        y
    )
    y = y - 28

    CreateButton(panel, "Reset Position (ZDH)", y, function()
        if SlashCmdList["ZDH"] then
            SlashCmdList["ZDH"]("reset")
        end
    end)

    ---------------------------------------------------------
    -- Register panel
    ---------------------------------------------------------
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)

        if category then
            if category.GetID then
                addon.settingsID = category:GetID()
            elseif category.ID then
                addon.settingsID = category.ID
            end
        end
    else
        InterfaceOptions_AddCategory(panel)
    end
end

---------------------------------------------------------
-- Init
---------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end

    ---------------------------------------------------------
    -- SavedVariables INIT (FIXED)
    ---------------------------------------------------------
    ZamestoTV_DelvesDB = ZamestoTV_DelvesDB or {}
    DB = ZamestoTV_DelvesDB

    DB.delvereminder = DB.delvereminder or {}
    DB.delvereminder.visible = DB.delvereminder.visible ~= false
    DB.delvereminder.autoHide = DB.delvereminder.autoHide ~= false

    DB.gwa = DB.gwa or {}
    DB.gwa.visible = DB.gwa.visible ~= false

    DB.dqt = DB.dqt or {}
    DB.dqt.visible = DB.dqt.visible ~= false

    DB.zdh = DB.zdh or {}
    DB.zdh.visible = DB.zdh.visible ~= false

    ---------------------------------------------------------

    BuildOptionsPanel()

    -- Apply saved settings on login
    if SlashCmdList["DELVEREMINDER"] then
        SlashCmdList["DELVEREMINDER"](DB.delvereminder.visible and "show" or "hide")
        SlashCmdList["DELVEREMINDER"](DB.delvereminder.autoHide and "enable" or "disable")
    end

    if SlashCmdList["ZDH"] then
        SlashCmdList["ZDH"](DB.zdh.visible and "show" or "hide")
    end
end)
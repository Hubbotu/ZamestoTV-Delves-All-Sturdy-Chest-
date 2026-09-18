local ICONS = {
    ["Ophidian Maw"]        = 7966624,
    ["Plague of Corrosion"] = 840941,
    ["Ula'tek's Gift"]      = 840189,
    ["Miasma Geyser"]       = 840191,
    ["Virulent Mucus"]      = 7956747,
    ["Lithic Plumage"]      = 2103798,
    ["Gorgoneion Gaze"]     = 7956734,
    ["Accursed Poison"]     = 1323036,
    ["Viperine Grasp"]      = 7956742,
    ["Mephitic Cloud"]      = 5764921,
    ["Ouroboric Cycle"]     = 636337,
    ["Insidious Venom"]     = 5764919,
}

local ROLE_ICONS = {
    HEALER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t",
    TANK   = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t",
    DAMAGER= "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t",
}

local function FormatAbility(name)
    local iconID = ICONS[name]
    if iconID then
        return string.format("|T%d:16:16:0:0|t %s", iconID, name)
    end
    return name
end

local guideFrame = nil
local toggleButton = nil

local function IsCorrosiveCodexOpen(choiceFrame)
    if not choiceFrame or not choiceFrame:IsShown() then return false end
    
    local titleText = ""
    if choiceFrame.Title and choiceFrame.Title.Text then
        titleText = choiceFrame.Title.Text:GetText() or ""
    elseif choiceFrame.TitleText then
        titleText = choiceFrame.TitleText:GetText() or ""
    end

    if titleText:find("Corrosive Codex") or titleText:find("Codex") then
        return true
    end

    return false
end

local function SetupGuideUI(parent)
    if parent ~= _G.PlayerChoiceFrame then return end

    if not toggleButton then
        -- 1. Создание кнопки
        toggleButton = CreateFrame("Button", "PlayerChoiceGuideButton", parent, "UIPanelButtonTemplate")
        toggleButton:SetSize(90, 22)
        toggleButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -45, -12)
        
        local btnText = toggleButton:GetFontString() or toggleButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btnText:SetFontObject("GameFontHighlightSmall")
        btnText:SetText("Guide")
        btnText:SetTextColor(1, 0.82, 0, 1)
        toggleButton:SetFontString(btnText)

        toggleButton:SetFrameStrata("HIGH")
        toggleButton:SetFrameLevel(parent:GetFrameLevel() + 25)

        guideFrame = CreateFrame("Frame", "PlayerChoiceGuideFrame", parent, "BasicFrameTemplateWithInset")
        guideFrame:SetSize(520, 440)
        guideFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 15, 0)
        guideFrame:SetFrameStrata("HIGH")
        guideFrame:SetFrameLevel(parent:GetFrameLevel() + 25)
        guideFrame:Hide()

        guideFrame.title = guideFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        guideFrame.title:SetPoint("CENTER", guideFrame.TitleBg, "CENTER", 0, 0)
        guideFrame.title:SetText("Optimal Combinations & Specialization Tips")

        local scrollFrame = CreateFrame("ScrollFrame", nil, guideFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", guideFrame.InsetBg, "TOPLEFT", 8, -8)
        scrollFrame:SetPoint("BOTTOMRIGHT", guideFrame.InsetBg, "BOTTOMRIGHT", -28, 8)

        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(470, 620)
        scrollFrame:SetScrollChild(content)

        local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
        text:SetJustifyH("LEFT")
        text:SetWidth(460)

        local guideText = string.format([[
|cffffd200=== RECOMMENDED PAIRINGS (2-SLOT LOADOUTS) ===|r

|cff00ff00Open World & Trash Mobs:|r
• %s + %s
|cffaaaaaa> Rapid poison dissemination paired with execution mechanics; unmatched area clear.|r

|cff00ff00Elites & Single Targets:|r
• %s + %s
|cffaaaaaa> Self-inflicted poison doubles Gift stacks to trigger accelerated Corrode burst windows.|r

|cff00ff00Delves & High Damage Survival:|r
• %s + %s
|cffaaaaaa> High damage mitigation coupled with emergency crowd control. Essential defensive baseline.|r

|cff00ff00Group Play & Public Events:|r
• %s + %s
|cffaaaaaa> Groups enemies together efficiently to maximize cleave output and finish off low-HP targets.|r

|cff00ff00Sustained Stat Ramp:|r
• %s + %s (or %s)
|cffaaaaaa> Maintains active poison triggers to prolong powerful primary attribute enhancement cycles.|r


|cffffd200=== SPEC-SPECIFIC PRIORITIES ===|r

%s |cff00ccffHealers:|r
Prioritize defensive setups (%s + %s or %s). %s offers minor group utility. Transition to offensive combos (%s + %s or %s + %s) once incoming damage is manageable.

%s |cff00ccffTanks:|r
Utilize the healer defensive core for challenging Delves. Once the second slot unlocks, incorporate %s or %s to enhance threat generation and mob grouping.

%s |cff00ccffMelee DPS:|r
Opt for %s + %s for mass AoE, or %s + %s for single-target focus. Use %s to bundle enemies together.

%s |cff00ccffRanged & Caster DPS:|r
Mirror the Melee DPS setups. Pairing %s with any poison applicator guarantees stable, long-term damage escalation.
]], 
            FormatAbility("Plague of Corrosion"), FormatAbility("Ophidian Maw"),
            FormatAbility("Ula'tek's Gift"), FormatAbility("Insidious Venom"),
            FormatAbility("Virulent Mucus"), FormatAbility("Gorgoneion Gaze"),
            FormatAbility("Viperine Grasp"), FormatAbility("Ophidian Maw"),
            FormatAbility("Ouroboric Cycle"), FormatAbility("Plague of Corrosion"), FormatAbility("Accursed Poison"),
            
            ROLE_ICONS.HEALER, FormatAbility("Virulent Mucus"), FormatAbility("Gorgoneion Gaze"), FormatAbility("Lithic Plumage"), FormatAbility("Miasma Geyser"), FormatAbility("Ula'tek's Gift"), FormatAbility("Insidious Venom"), FormatAbility("Plague of Corrosion"), FormatAbility("Ophidian Maw"),
            ROLE_ICONS.TANK, FormatAbility("Virulent Mucus"), FormatAbility("Gorgoneion Gaze"), FormatAbility("Ophidian Maw"), FormatAbility("Viperine Grasp"),
            ROLE_ICONS.DAMAGER, FormatAbility("Plague of Corrosion"), FormatAbility("Ophidian Maw"), FormatAbility("Ula'tek's Gift"), FormatAbility("Insidious Venom"), FormatAbility("Viperine Grasp"),
            ROLE_ICONS.DAMAGER, FormatAbility("Ouroboric Cycle")
        )

        text:SetText(guideText)

        toggleButton:SetScript("OnClick", function()
            if guideFrame:IsShown() then
                guideFrame:Hide()
            else
                guideFrame:Show()
            end
        end)

        parent:HookScript("OnHide", function()
            if guideFrame then guideFrame:Hide() end
            if toggleButton then toggleButton:Hide() end
        end)
    end
end

local monitor = CreateFrame("Frame")
monitor:RegisterEvent("PLAYER_LOGIN")
monitor:RegisterEvent("PLAYER_CHOICE_UPDATE")
monitor:RegisterEvent("PLAYER_ENTERING_WORLD")

monitor:SetScript("OnEvent", function()
    local choiceFrame = _G.PlayerChoiceFrame

    if not choiceFrame then return end

    SetupGuideUI(choiceFrame)

    if toggleButton then
        if IsCorrosiveCodexOpen(choiceFrame) then
            toggleButton:Show()
        else
            toggleButton:Hide()
            if guideFrame then guideFrame:Hide() end
        end
    end
end)
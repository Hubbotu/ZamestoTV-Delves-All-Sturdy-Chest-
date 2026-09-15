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

local guideFrame = CreateFrame("Frame", "PlayerChoiceGuideFrame", UIParent, "BasicFrameTemplateWithInset")
guideFrame:SetSize(520, 440)
guideFrame:SetFrameStrata("DIALOG")
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

local toggleButton = CreateFrame("Button", "PlayerChoiceGuideButton", UIParent, "UIPanelButtonTemplate")
toggleButton:SetSize(80, 24)
toggleButton:SetText("Guide")
toggleButton:SetFrameStrata("DIALOG")
toggleButton:Hide()

toggleButton:SetScript("OnClick", function()
    local parentFrame = _G["PlayerChoiceFrame"]
    if guideFrame:IsShown() then
        guideFrame:Hide()
    elseif parentFrame then
        guideFrame:ClearAllPoints()
        guideFrame:SetPoint("LEFT", parentFrame, "RIGHT", 10, 0)
        guideFrame:Show()
    end
end)

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_CHOICE_UPDATE")

eventHandler:SetScript("OnEvent", function(self, event)
    local choiceFrame = _G["PlayerChoiceFrame"]
    
    if choiceFrame and choiceFrame:IsShown() then
        toggleButton:SetParent(choiceFrame)
        toggleButton:ClearAllPoints()
        toggleButton:SetPoint("TOPRIGHT", choiceFrame, "TOPRIGHT", -45, -15)
        toggleButton:Show()

        if not choiceFrame.guideHooked then
            choiceFrame:HookScript("OnHide", function()
                toggleButton:Hide()
                guideFrame:Hide()
            end)
            choiceFrame.guideHooked = true
        end
    end
end)
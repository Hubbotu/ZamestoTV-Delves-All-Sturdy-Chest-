local addonName, addon = "ValeeraMuter", {}
_G[addonName] = addon

-- Registry of audio assets stored as hash map keys
local audioRegistry = {
    [7243762] = true, [7243934] = true, [7329273] = true, [7430043] = true, [7430047] = true,
    [7430050] = true, [7430053] = true, [7430056] = true, [7430059] = true, [7430063] = true,
    [7430066] = true, [7430069] = true, [7430072] = true, [7430075] = true, [7430078] = true,
    [7430082] = true, [7430086] = true, [7430089] = true, [7430092] = true, [7430095] = true,
    [7430098] = true, [7430101] = true, [7430104] = true, [7430107] = true, [7430110] = true,
    [7430113] = true, [7430116] = true, [7430119] = true, [7430122] = true, [7430125] = true,
    [7430156] = true, [7430159] = true, [7430162] = true, [7430165] = true, [7430168] = true,
    [7430171] = true, [7430174] = true, [7430177] = true, [7430180] = true, [7430183] = true,
    [7430186] = true, [7430189] = true, [7430192] = true, [7430196] = true, [7430199] = true,
    [7430202] = true, [7430205] = true, [7430208] = true, [7430211] = true, [7430230] = true,
    [7430233] = true, [7430237] = true, [7430257] = true, [7430268] = true, [7430275] = true,
    [7430283] = true, [7430294] = true, [7430314] = true, [7430324] = true, [7430333] = true,
    [7430336] = true, [7430339] = true, [7430342] = true, [7430345] = true, [7430348] = true,
    [7430351] = true, [7430354] = true, [7430357] = true, [7430360] = true, [7430363] = true,
    [7430366] = true, [7430369] = true, [7430372] = true, [7430375] = true, [7430378] = true,
    [7430381] = true, [7430384] = true, [7430388] = true, [7430391] = true, [7430394] = true,
    [7430397] = true, [7430400] = true, [7430405] = true, [7430416] = true, [7430423] = true,
    [7430428] = true, [7430431] = true, [7430434] = true, [7430437] = true, [7430440] = true,
    [7430443] = true, [7430446] = true, [7430449] = true, [7430452] = true, [7430456] = true,
    [7430459] = true, [7430462] = true, [7430465] = true, [7430468] = true, [7430471] = true,
    [7430474] = true, [7430477] = true, [7430480] = true, [7430483] = true, [7430486] = true,
    [7430489] = true, [7430492] = true, [7430498] = true, [7430506] = true, [7430512] = true,
    [7430516] = true, [7430519] = true, [7430538] = true, [7430547] = true, [7430550] = true,
    [7430555] = true, [7430561] = true, [7430565] = true, [7430733] = true, [7430740] = true,
    [7430751] = true, [7430754] = true, [7430778] = true, [7430781] = true, [7430784] = true,
    [7430787] = true, [7430790] = true, [7430793] = true, [7430796] = true, [7430799] = true,
    [7430864] = true, [7430867] = true, [7430870] = true, [7430881] = true, [7430973] = true,
    [7430985] = true, [7430989] = true, [7431077] = true, [7431084] = true, [7431087] = true,
    [7431093] = true, [7431103] = true, [7431106] = true, [7431109] = true, [7431112] = true,
    [7431115] = true, [7431119] = true, [7431123] = true, [7440991] = true, [7461759] = true
}

-- Execute audio state change across registered IDs
function addon:ToggleAudioMute(state)
    local handler = state and MuteSoundFile or UnmuteSoundFile
    for fileID in pairs(audioRegistry) do
        handler(fileID)
    end
end

-- Inspect active companion identity
function addon:IsValeeraPresent()
    local frame = _G["DelvesCompanionConfigurationFrame"]
    if not frame or not frame.CompanionInfoFrame then return false end

    local elements = { frame.CompanionInfoFrame:GetRegions() }
    for index = 1, #elements do
        local child = elements[index]
        if child:IsObjectType("FontString") then
            local str = child:GetText()
            if str and (str:find("Valeera Sanguinar") or str:find("Валира")) then
                return true
            end
        end
    end
    return false
end

-- Check if sender is Valeera Sanguinar
local function IsValeeraSender(sender)
    if not sender then return false end
    return sender:find("Valeera Sanguinar") or sender:find("Валира")
end

-- Temporarily suppress chat bubbles globally upon Valeera message
local function SuppressBubblesTemporarily()
    if C_CVar and C_CVar.GetCVar and C_CVar.SetCVar then
        local originalState = C_CVar.GetCVar("chatBubbles")
        C_CVar.SetCVar("chatBubbles", "0")
        C_Timer.After(0.2, function()
            C_CVar.SetCVar("chatBubbles", originalState or "1")
        end)
    end
end

-- Filter Chat Messages and disable bubble creation
local function ChatMessageFilter(self, event, msg, sender, ...)
    if ValeeraMuterDB and ValeeraMuterDB.isMuted and IsValeeraSender(sender) then
        SuppressBubblesTemporarily()
        return true -- Block message in chat frame
    end
    return false, msg, sender, ...
end

-- Register Chat Filters
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", ChatMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", ChatMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", ChatMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_PARTY", ChatMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", ChatMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_WHISPER", ChatMessageFilter)

-- Hook Talking Head Frame to hide it when Valeera speaks
local function HookTalkingHead()
    if TalkingHeadFrame_PlayCurrent and not addon.talkingHeadHooked then
        hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
            if ValeeraMuterDB and ValeeraMuterDB.isMuted and TalkingHeadFrame then
                local name = TalkingHeadFrame.NameFrame and TalkingHeadFrame.NameFrame.Text and TalkingHeadFrame.NameFrame.Text:GetText()
                if IsValeeraSender(name) then
                    TalkingHeadFrame:Hide()
                    if C_TalkingHead and C_TalkingHead.IgnoreCurrentTalkingHead then
                        C_TalkingHead.IgnoreCurrentTalkingHead()
                    end
                end
            end
        end)
        addon.talkingHeadHooked = true
    end
end

-- Synchronize button state and colors
function addon:UpdateInterfaceState()
    if not self.toggleBtn then return end
    local isMuted = ValeeraMuterDB and ValeeraMuterDB.isMuted
    self.toggleBtn:SetText(isMuted and "Mute: ON" or "Mute: OFF")
    if self.toggleBtn.Text then
        self.toggleBtn.Text:SetTextColor(isMuted and 1 or 0.2, isMuted and 0.2 or 1, 0.2)
    end
end

-- Construct trigger control
function addon:BuildToggleButton()
    if self.toggleBtn or not DelvesCompanionConfigurationFrame then return end

    local btn = CreateFrame("Button", "ValeeraMuterButton", DelvesCompanionConfigurationFrame, "UIPanelButtonTemplate")
    btn:SetSize(90, 24)
    btn:SetPoint("TOPRIGHT", DelvesCompanionConfigurationFrame, "TOPRIGHT", -35, -5)
    btn:SetFrameLevel(DelvesCompanionConfigurationFrame:GetFrameLevel() + 10)

    btn:SetScript("OnClick", function()
        ValeeraMuterDB.isMuted = not ValeeraMuterDB.isMuted
        addon:ToggleAudioMute(ValeeraMuterDB.isMuted)
        addon:UpdateInterfaceState()
    end)

    self.toggleBtn = btn
    self:UpdateInterfaceState()
end

-- Handle companion interface display logic
function addon:OnCompanionFrameShown()
    if self:IsValeeraPresent() then
        self:BuildToggleButton()
        if self.toggleBtn then self.toggleBtn:Show() end
    elseif self.toggleBtn then
        self.toggleBtn:Hide()
    end
end

-- Register interface hooks
function addon:BindFrameHooks()
    if not DelvesCompanionConfigurationFrame or self.hooked then return end
    DelvesCompanionConfigurationFrame:HookScript("OnShow", function()
        self:OnCompanionFrameShown()
    end)
    if DelvesCompanionConfigurationFrame:IsShown() then
        self:OnCompanionFrameShown()
    end
    self.hooked = true
end

-- Primary event listener
local eventDispatcher = CreateFrame("Frame")
eventDispatcher:RegisterEvent("PLAYER_LOGIN")
eventDispatcher:RegisterEvent("ADDON_LOADED")

eventDispatcher:SetScript("OnEvent", function(_, event, name)
    if event == "PLAYER_LOGIN" then
        if type(ValeeraMuterDB) ~= "table" then
            ValeeraMuterDB = { isMuted = true }
        end

        addon:ToggleAudioMute(ValeeraMuterDB.isMuted)
        addon:BindFrameHooks()

        if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_TalkingHeadUI") then
            HookTalkingHead()
        elseif IsAddOnLoaded and IsAddOnLoaded("Blizzard_TalkingHeadUI") then
            HookTalkingHead()
        end

    elseif event == "ADDON_LOADED" then
        if name == "Blizzard_DelvesCompanionConfiguration" then
            addon:BindFrameHooks()
        elseif name == "Blizzard_TalkingHeadUI" then
            HookTalkingHead()
        end
    end
end)
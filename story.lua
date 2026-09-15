local addonName, addonTable = ...
local DelveStoryStatus = CreateFrame("Frame")

-- Story achievements table
local storyAchievements = {
    [40525] = true, [40526] = true, [40527] = true, [40528] = true,
    [40529] = true, [40530] = true, [40531] = true, [40532] = true,
    [40533] = true, [40534] = true, [40535] = true, [40536] = true,
    [41099] = true, [41098] = true, [42771] = true, [61724] = true, 
    [61726] = true, [61728] = true, [61730] = true, [61732] = true, 
    [61725] = true, [61727] = true, [61729] = true, [61731] = true, 
    [61733] = true, [63437] = true, [63436] = true,   
}

local function CacheAchievements()
    for aid in pairs(storyAchievements) do
        local _, _, _, achievementCompleted = GetAchievementInfo(aid)
        local numCriteria = GetAchievementNumCriteria and GetAchievementNumCriteria(aid) or 0
        for criteriaIndex = 1, numCriteria do
            local storyName, _, criteriaCompleted = GetAchievementCriteriaInfo(aid, criteriaIndex)
            if storyName and storyName ~= "" then
                storyName = storyName:match("^%s*(.-)%s*$")
                addonTable[storyName] = {
                    achievement = achievementCompleted,
                    criteria = criteriaCompleted
                }
            end
        end
    end
end

local function ModifyDescriptionText()
    if not (DelvesDifficultyPickerFrame and DelvesDifficultyPickerFrame:IsShown()) then return end

    local descFrame = DelvesDifficultyPickerFrame.Description
    if not descFrame or not descFrame.GetText then return end

    local currentText = descFrame:GetText() or ""
    if currentText == "" or currentText:find("BATTLENET_FONT_COLOR") then 
        return 
    end

    CacheAchievements()

    local matchedStory = nil
    for storyName, data in pairs(addonTable) do
        if currentText:find(storyName, 1, true) then
            matchedStory = data
            break
        end
    end

    if matchedStory then
        local progressText = STORY_PROGRESS or "Story Progress"
        local completeText = GOAL_COMPLETED or "Completed"
        local incompleteText = INCOMPLETE or "Incomplete"
        local achievementEarnedText = ACHIEVEMENT_UNLOCKED or "Unlocked"
        local achievementIncompleteText = SUMMARY_ACHIEVEMENT_INCOMPLETE or "Locked"

        local progressFormat = "\n\n|cnBATTLENET_FONT_COLOR:" .. progressText
        local checkIcon = ":|r\n|A:common-icon-checkmark:0:0|a |cn"
        local crossIcon = ":|r\n|A:common-icon-redx:0:0|a |cn"
        local styleComplete = checkIcon .. "GREEN_FONT_COLOR:" .. completeText .. "|r"
        local styleIncomplete = crossIcon .. "RED_FONT_COLOR:" .. incompleteText .. "|r"
        local achievementYes = "\n(|cnGREEN_FONT_COLOR:" .. achievementEarnedText .. "|r)"
        local achievementNo = "\n(|cnRED_FONT_COLOR:" .. achievementIncompleteText .. "|r)"

        local statusText = progressFormat .. (matchedStory.criteria and styleComplete or styleIncomplete)
        local achievementText = matchedStory.criteria and (matchedStory.achievement and achievementYes or achievementNo) or ""

        descFrame:SetHeight(200)
        descFrame:SetText(currentText .. statusText .. achievementText)
    end
end

local function ApplyHooks()
    if DelvesDifficultyPickerFrame and not DelveStoryStatus.hooked then
        -- Хукаем событие показа самого фрейма
        DelvesDifficultyPickerFrame:HookScript("OnShow", function()
            C_Timer.After(0.05, ModifyDescriptionText)
        end)
        
        if DelvesDifficultyPickerFrame.Description and DelvesDifficultyPickerFrame.Description.SetText then
            hooksecurefunc(DelvesDifficultyPickerFrame.Description, "SetText", function(_, text)
                if text and text ~= "" and not text:find("BATTLENET_FONT_COLOR") then
                    C_Timer.After(0.01, ModifyDescriptionText)
                end
            end)
        end
        
        DelveStoryStatus.hooked = true
    end
end

DelveStoryStatus:RegisterEvent("ADDON_LOADED")
DelveStoryStatus:RegisterEvent("GOSSIP_SHOW")
DelveStoryStatus:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_DelvesDifficultyPicker" then
        ApplyHooks()
    elseif event == "GOSSIP_SHOW" then
        ApplyHooks()
        C_Timer.After(0.05, ModifyDescriptionText)
    end
end)
local myname, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(myname, false)

ns.defaults = {
    profile = {
        show_on_world = true,
        show_on_minimap = true,
        show_ZamestoTV_Remix = true,
        repeatable = true,
        icon_scale = 0.6,
        icon_alpha = 1.0,
    },
    char = {
        hidden = {
            ['*'] = {},
        },
    },
}

ns.options = {
    type = "group",
    name = myname:gsub("HandyNotes_", ""):gsub("([A-Z])", " %1"):gsub("^%s+", ""),
    get = function(info) return ns.db[info[#info]] end,
    set = function(info, v)
        ns.db[info[#info]] = v
        ns.HL:SendMessage("HandyNotes_NotifyUpdate", myname:gsub("HandyNotes_", ""))
    end,
    args = {
        icon = {
            type = "group",
            name = L["Icon settings"],
            inline = true,
            args = {
                desc = {
                    name = L["These settings control the look of the icon."],
                    type = "description",
                    order = 0,
                },
                icon_scale = {
                    type = "range",
                    name = L["Icon Scale"],
                    desc = L["The scale of the icons"],
                    min = 0.25, max = 2, step = 0.01,
                    order = 10,
                },
                icon_alpha = {
                    type = "range",
                    name = L["Icon Alpha"],
                    desc = L["The alpha transparency of the icons"],
                    min = 0, max = 1, step = 0.01,
                    order = 20,
                },
                show_on_world = {
                    type = "toggle",
                    name = L["World Map"],
                    desc = L["Show icons on world map"],
                    order = 30,
                },
                show_on_minimap = {
                    type = "toggle",
                    name = L["Minimap"],
                    desc = L["Show icons on the minimap"],
                    order = 40,
                },
            },
        },
        display = {
            type = "group",
            name = L["What to display"],
            inline = true,
            args = {
                show_ZamestoTV_Remix = {
                    type = "toggle",
                    name = L["Show Zamros"],
                    desc = L["Show Zamros Delves"],
                    order = 20,
                },
                unhide = {
                    type = "execute",
                    name = L["Reset hidden nodes"],
                    desc = L["Show all nodes that you manually hid by right-clicking on them and choosing \"hide\"."],
                    func = function()
                        for map,coords in pairs(ns.hidden) do
                            wipe(coords)
                        end
                        ns.HL:Refresh()
                    end,
                    order = 30,
                },
            },
        },
    },
}

local GetCriteriaCompleted = function(achievementTable)
    if not achievementTable or not achievementTable.criteria then return false end

    local completed = false

    if achievementTable.id then
        local success, _, _, isCompleted = pcall(GetAchievementCriteriaInfoByID, achievementTable.id, achievementTable.criteria)
        if success and isCompleted ~= nil then
            return isCompleted
        end

        local numCriteria = GetAchievementNumCriteria(achievementTable.id)
        if numCriteria and numCriteria > 0 then
            for i = 1, numCriteria do
                local _, _, isComp, _, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(achievementTable.id, i)
                if criteriaID == achievementTable.criteria or i == achievementTable.criteria then
                    return isComp
                end
            end
        end
    else
        local success, _, _, isCompleted = pcall(GetAchievementCriteriaInfoByID, achievementTable.criteria)
        if success and isCompleted ~= nil then
            return isCompleted
        end
    end

    return completed
end

local player_faction = UnitFactionGroup("player")
local player_name = UnitName("player")

ns.should_show_point = function(coord, point, currentZone, isMinimap)
    if isMinimap and not ns.db.show_on_minimap and not point.minimap then
        return false
    elseif not isMinimap and not ns.db.show_on_world then
        return false
    end
    if ns.hidden[currentZone] and ns.hidden[currentZone][coord] then
        return false
    end
    if ns.outdoors_only and IsIndoors() then
        return false
    end
    if point.faction and point.faction ~= player_faction then
        return false
    end
    if point.ZamestoTV_Remix and not ns.db.show_ZamestoTV_Remix then
        return false
    end
    if point.hide_before and not ns.db.upcoming then
        return false
    end
    if point.quest and C_QuestLog.IsQuestFlaggedCompleted(point.quest) then
        return false
    end

    if point.achievement and GetCriteriaCompleted(point.achievement) then
        return false
    end

    return true
end

local plugin = LibStub("AceAddon-3.0"):GetAddon(myname, true)
if plugin then
    local function RefreshIcons()
        if ns.HL then
            ns.HL:SendMessage("HandyNotes_NotifyUpdate", myname:gsub("HandyNotes_", ""))
        end
    end

    plugin:RegisterEvent("CRITERIA_UPDATE", RefreshIcons)
    plugin:RegisterEvent("ACHIEVEMENT_EARNED", RefreshIcons)
    plugin:RegisterEvent("QUEST_TURNED_IN", RefreshIcons)
end
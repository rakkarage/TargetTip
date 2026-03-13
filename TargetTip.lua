-- TargetTip
-- Shows Show targets target & targetoftarget on player tooltips.

local function GetClassColor(unit)
    local _, classFile = UnitClass(unit)
    if not classFile then return "|cFFaaaaaa" end
    local c = RAID_CLASS_COLORS[classFile]
    if not c then return "|cFFaaaaaa" end
    return string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

local function GetUnitLabel(unit)
    if not UnitExists(unit) then return nil end

    local name = UnitName(unit)
    if not name then return nil end

    if UnitIsPlayer(unit) then
        local color = GetClassColor(unit)
        local _, classFile = UnitClass(unit)
        local className = classFile and LOCALIZED_CLASS_NAMES_MALE[classFile] or "?"
        return color .. name .. "|r |cFF888888(" .. className .. ")|r"
    else
        -- NPC: use threat/reaction color
        local reaction = UnitReaction(unit, "player")
        local color
        if UnitIsDead(unit) then
            color = "|cFF888888"
        elseif reaction and reaction >= 5 then
            color = "|cFF1eff00" -- friendly
        elseif reaction and reaction == 4 then
            color = "|cFFffff00" -- neutral
        else
            color = "|cFFff2020" -- hostile
        end
        local level = UnitLevel(unit)
        local levelStr = level and level > 0 and (" |cFFaaaaaa(L" .. level .. ")|r") or ""
        return color .. name .. "|r" .. levelStr
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
    if tooltip ~= GameTooltip or not data then return end

    local unit = data.unitToken
    if not unit and UnitExists("mouseover") then unit = "mouseover" end
    if not unit or UnitIsUnit(unit, "player") then return end

    local motUnit = unit .. "target"
    local motLabel = GetUnitLabel(motUnit)

    if not motLabel then return end

    local isSelf = UnitIsUnit(motUnit, "player")
    local selfTag = isSelf and " |cFFffd700(you)|r" or ""

    tooltip:AddLine(" ")
    tooltip:AddLine("|cFFaaaaaa" .. UnitName(unit) .. "'s target:|r")
    tooltip:AddLine("  " .. motLabel .. selfTag)

    -- target's target (who has aggro / is being focused back)
    if not isSelf then
        local motmotUnit = motUnit .. "target"
        local motmotLabel = GetUnitLabel(motmotUnit)
        if motmotLabel then
            local motmotSelf = UnitIsUnit(motmotUnit, "player")
            local motmotSelfTag = motmotSelf and " |cFFffd700(you)|r" or ""
            tooltip:AddLine("|cFFaaaaaa" .. UnitName(motUnit) .. "'s target:|r")
            tooltip:AddLine("  " .. motmotLabel .. motmotSelfTag)
        end
    end

    tooltip:Show()
end)

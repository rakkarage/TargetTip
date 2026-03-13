-- TargetTip
-- Shows Show targets target & targetoftarget on player tooltips.

local ICON = "|TInterface\\Icons\\ability_marksmanship:14|t "

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

    if UnitIsUnit(unit, "player") then
        return "|cFFffd700" .. name .. "|r"
    elseif UnitIsPlayer(unit) then
        return GetClassColor(unit) .. name .. "|r"
    else
        local reaction = UnitReaction(unit, "player")
        local color
        if UnitIsDead(unit) then
            color = "|cFF888888"
        elseif reaction and reaction >= 5 then
            color = "|cFF1eff00"
        elseif reaction and reaction == 4 then
            color = "|cFFffff00"
        else
            color = "|cFFff2020"
        end
        return color .. name .. "|r"
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
    if tooltip ~= GameTooltip or not data then return end

    local unit = data.unitToken
    if not unit and UnitExists("mouseover") then unit = "mouseover" end
    if not unit then return end

    local targetUnit = unit .. "target"
    local targetLabel = GetUnitLabel(targetUnit)
    if not targetLabel then return end

    local targetTargetUnit = targetUnit .. "target"
    local targetTargetLabel = not UnitIsUnit(targetUnit, "player") and GetUnitLabel(targetTargetUnit) or nil

    local line = ICON .. targetLabel
    if targetTargetLabel then
        line = line .. "    " .. ICON .. targetTargetLabel
    end

    tooltip:AddLine(line)
    tooltip:Show()
end)

-- TargetTip
-- Shows `target` & `targetoftarget` on unit tooltips.

local ICON = "|TInterface\\Icons\\ability_marksmanship:14|t "

local classColorCache = {}

local function GetColor(unit)
    local _, classFile = UnitClass(unit)
    if not classFile then return "|cFFaaaaaa" end

    if classColorCache[classFile] then
        return classColorCache[classFile]
    end

    local c = RAID_CLASS_COLORS[classFile]
    if not c then return "|cFFaaaaaa" end

    local colorString = string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
    classColorCache[classFile] = colorString
    return colorString
end

local function GetUnitLabel(unit)
    if not UnitExists(unit) then return nil end
    local name = UnitName(unit)
    if not name then return nil end
    if UnitIsPlayer(unit) then
        return GetColor(unit) .. name .. "|r"
    else
        local color
        local reaction = UnitReaction(unit, "player")
        if reaction then
            if reaction >= 5 then
                color = "|cFF4db24d"
            elseif reaction == 4 then
                color = "|cFFb2b200"
            else
                color = "|cFFb24d4d"
            end
        else
            color = "|cFFffffff"
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
    local targetTargetLabel = GetUnitLabel(targetTargetUnit)

    local line = ICON .. targetLabel
    if targetTargetLabel then
        line = line .. "    " .. ICON .. targetTargetLabel
    end

    tooltip:AddLine(line)
end)

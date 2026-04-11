-- 🎯 TargetTip: Shows target information on unit tooltips.

local ICON_NPC = "|TInterface\\Icons\\ability_marksmanship:14|t "

-- Pre-computed role icons: stored as constants to avoid table allocation on every load
local ROLE_ICONS = {
	TANK    = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:0:19:22:41|t ",
	HEALER  = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:1:20|t ",
	DAMAGER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:22:41|t ",
}
local CLASS_ICONS = {}
for classFile, coords in pairs(CLASS_ICON_TCOORDS) do
	CLASS_ICONS[classFile] = string.format(
		"|TInterface\\WorldStateFrame\\Icons-Classes:14:14:0:0:256:256:%d:%d:%d:%d|t ",
		coords[1] * 256, coords[2] * 256, coords[3] * 256, coords[4] * 256)
end

local classColorCache = {}
local nameCache = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
	wipe(classColorCache)
	wipe(nameCache)
end)

local function GetColor(unit)
	local _, classFile = UnitClass(unit)
	if not classFile then return "|cFFaaaaaa" end
	if classColorCache[classFile] then return classColorCache[classFile] end
	local c = RAID_CLASS_COLORS[classFile]
	if not c then return "|cFFaaaaaa" end
	local colorString = string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
	classColorCache[classFile] = colorString
	return colorString
end

local function GetReactionColor(unit)
	local reaction = UnitReaction(unit, "player")
	local c = reaction and FACTION_BAR_COLORS[reaction]
	if c then
		return string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
	end
	return "|cFFaaaaaa"
end

-- Guard UnitGUID for compound tokens (e.g. mouseovertarget).
local function GetSafeGUID(unit)
	local ok, guid = pcall(UnitGUID, unit)
	if ok then return guid end
	return nil
end

local function GetCachedName(unit)
	local guid = GetSafeGUID(unit)
	if guid and not issecretvalue(guid) then
		if nameCache[guid] then return nameCache[guid] end
		local name = UnitName(unit)
		if name then nameCache[guid] = name end
		return name
	end
	return UnitName(unit)
end

local function GetRoleIcon(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role and ROLE_ICONS[role] then return ROLE_ICONS[role] end
	local _, classFile = UnitClass(unit)
	return classFile and CLASS_ICONS[classFile] or ""
end

local function GetUnitLabel(unit)
	if not UnitExists(unit) then return nil end
	local name = GetCachedName(unit)
	if not name then return nil end
	if UnitIsPlayer(unit) then
		return GetRoleIcon(unit) .. GetColor(unit) .. name .. "|r"
	else
		return ICON_NPC .. GetReactionColor(unit) .. name .. "|r"
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
	if tooltip ~= GameTooltip or not data then return end
	local unit = data.unitToken
	if not unit and UnitExists("mouseover") then unit = "mouseover" end
	if not unit then return end

	-- Resolve and display target chain: unit -> unit's target -> unit's target's target
	local targetUnit = unit .. "target"
	local targetLabel = GetUnitLabel(targetUnit)
	if not targetLabel then return end -- Unit has no valid target; abort

	local targetTargetLabel = GetUnitLabel(targetUnit .. "target")
	local line = targetLabel
	if targetTargetLabel then
		line = line .. "    " .. targetTargetLabel -- Append target's target if it exists
	end
	tooltip:AddLine(line)
end)

--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds aggregate statuses to Grid for debuffs which reduce or prevent healing received.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx.
	See README for license terms and additional information.
	http://www.wowinterface.com/downloads/info7364-GridStatusHealingReduced.html
	http://wow.curse.com/downloads/wow-addons/details/gridstatushealingreduced.aspx
----------------------------------------------------------------------]]

local HEALING_REDUCED = "Healing reduced"
local HEALING_PREVENTED = "Healing prevented"

local LOCALE = GetLocale()

if LOCALE == "deDE" then
	HEALING_REDUCED = "Heilung reduziert"
	HEALING_PREVENTED = "Heilung verhindert"
elseif LOCALE == "esES" or LOCALE == "esMX" then
	HEALING_REDUCED = "Sanación reducida"
	HEALING_PREVENTED = "Sanación impedida"
elseif LOCALE == "frFR" then
	HEALING_REDUCED = "Soins diminués"
	HEALING_PREVENTED = "Soins empêché"
elseif LOCALE == "ruRU" then
	HEALING_REDUCED = "Исцеление уменьшено"
	HEALING_PREVENTED = "Препятствие исцелению"
elseif LOCALE == "koKR" then
	HEALING_REDUCED = "치유량 감소"
	HEALING_PREVENTED = "치유량 방해"
elseif LOCALE == "zhCN" then
	HEALING_REDUCED = "治疗效果被降低"
	HEALING_PREVENTED = "治疗无效果"
elseif LOCALE == "zhTW" then
	HEALING_REDUCED = "治療效果被降低"
	HEALING_PREVENTED = "治療無效果"
end

------------------------------------------------------------------------

local ReductionDebuffs
local PreventionDebuffs

local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID

local enabled = 0

local valid = { player = true, pet = true, vehicle = true }
for i = 1, 4 do
	valid["party" .. i] = true
	valid["partypet" .. i] = true
end
for i = 1, 40 do
	valid["raid" .. i] = true
	valid["raidpet" .. i] = true
end

local function debug(str)
	print("|cffff9933GridStatusHealingReduced:|r " .. str)
end

------------------------------------------------------------------------

local GridStatusHealingReduced = Grid:GetModule("GridStatus"):NewModule("GridStatusHealingReduced")

GridStatusHealingReduced.options = false

GridStatusHealingReduced.defaultDB = {
	alert_healingReduced = {
		enable = true,
		color = { r = 0.8, g = 0.4, b = 0.8, a = 1 },
		priority = 90,
		range = false,
		text = "H-",
	},
	alert_healingPrevented = {
		enable = true,
		color = { r = 0.6, g = 0.2, b = 0.6, a = 1 },
		priority = 99,
		range = false,
		text = "Hx",
	}
}

------------------------------------------------------------------------

function GridStatusHealingReduced:OnInitialize()
--	debug("OnInitialize")
	self.super.OnInitialize(self)

	ReductionDebuffs = { }
	for id in string.split(",", "48871,59243,65883,67977,67978,67979,63038,48291,56112,70671,70710,30213,48301,12294,13737,16856,32736,35054,39171,57789,65926,67542,68782,68783,68784,71552,28467,48187,59265,54378,71127,69674,28776,68391,59525,54525,32315,70588,28440,53803,69633,82654,13218,13222,13223,13224,27189,57974,57975,52771") do
		local name = GetSpellInfo(id)
		if name then
			ReductionDebuffs[id] = true
		end
	end

	PreventionDebuffs = { }
	for id in string.split(",", "59513,55593") do
		local name = GetSpellInfo(id)
		if name then
			PreventionDebuffs[id] = true
		end
	end

	self:RegisterStatus("alert_healingReduced", HEALING_REDUCED, nil, true)
	self:RegisterStatus("alert_healingPrevented", HEALING_PREVENTED, nil, true)
end

function GridStatusHealingReduced:OnEnable()
--	debug("OnEnable")
	self.super.OnEnable(self)
end

function GridStatusHealingReduced:OnStatusEnable(status)
--	debug("OnStatusEnable, " .. status)

	if status ~= "alert_healingReduced" and status ~= "alert_healingPrevented" then return end

	enabled = enabled + 1
	self:RegisterEvent("UNIT_AURA", "UpdateUnit")
	self:UpdateAllUnits()
end

function GridStatusHealingReduced:OnStatusDisable(status)
--	debug("OnStatusDisable, " .. status)

	if status ~= "alert_healingReduced" and status ~= "alert_healingPrevented" then return end

	enabled = enabled - 1
	if enabled == 0 then
		self:UnregisterEvent("UNIT_AURA")
	end
	self.core:SendStatusLostAllUnits(status)
end

------------------------------------------------------------------------

function GridStatusHealingReduced:UpdateAllUnits()
	if enabled > 0 then
		for guid, unitid in Grid:GetModule("GridRoster"):IterateRoster() do
			self:UpdateUnit("UpdateAllUnits", unitid)
		end
	end
end

function GridStatusHealingReduced:UpdateUnit(event, unit)
	if not valid[unit] then return end
--	debug("UNIT_AURA, " .. unit)

	local prevented, reduced, name, icon, count, duration, expiration, id, _
	for i = 1, 100 do
		name, _, icon, count, _, duration, expirationTime, _, _, _, id = UnitDebuff(unit, i)
		if not id then
			break
		end
		if duration then
			if PreventionDebuffs[id] then
			--	debug(id .. " " .. name)
				prevented = true
				reduced = false
				break
			elseif not reduced and ReductionDebuffs[id] then
			--	debug(id .. " " .. name)
				reduced = true
			end
		end
	end

	local settings
	if prevented then
	--	debug("SendStatusGained")
		settings = self.db.profile.alert_healingPrevented
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingPrevented",
			settings.priority,
			(settings.range and 40),
			settings.color,
			settings.text,
			nil,
			nil,
			icon,
			expiration and (expiration - duration),
			count)
	else
	--	debug("SendStatusLost")
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingPrevented")
	end

	if reduced then
	--	debug("SendStatusGained")
		settings = self.db.profile.alert_healingReduced
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingReduced",
			settings.priority,
			(settings.range and 40),
			settings.color,
			settings.text,
			nil,
			nil,
			icon,
			expiration and (expiration - duration),
			count)
	else
	--	debug("SendStatusLost")
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingReduced")
	end
end

------------------------------------------------------------------------
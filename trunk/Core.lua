--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds generic statuses to Grid for debuffs which reduce or prevent healing received.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2008–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
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

	local function maketable(...)
		local t = { }
		for i = 1, select("#", ...) do
			local id = select(i, ...)
			id = id and tonumber(id) or 0

			local name = GetSpellInfo(id)
			if name then
				t[id] = true
			end
		end
		return t
	end

	local RD = {
		-- [[ Player Classes ]]
		56112,30213,48301,54680,12294,82654,13218,
		-- [[ Classic WoW ]]
		-- 23169,13583,19716,22859,13737,24573,27580,25646,31464,17820,22687,
		-- 78841,43410,19643,32736,
		-- [[ The Burning Crusade ]]
		-- 56112,30213,48301,54680,12294,82654,13218,23169,13583,19716,22859,13737,24573,27580,25646,31464,17820,22687,40599,41478,45347,36023,36917,37335,44268,30641,36814,30423,45885,35189,32858,38377,44534,
		-- 34073,34366,32378,17547,38770,
		-- [[ Wrath of the Lich King ]]
		-- 48871,59243,65883,67977,67978,67979,63038,48291,59300,70671,70710,15708,16856,35054,57789,65926,67542,68782,68783,68784,71552,28467,48137,54378,59265,71127,69674,71224,73022,73023,28776,54121,59525,54525,59745,59746,32315,28440,53803,69633,69651,72569,72570,72571,
		-- 54615,52645,44475,80390,60626,
		-- [[ Cataclysm ]]
		93956,83908,86157,86158,86158,76727,90526,91801,93675,93771,7068,23224,83926,52771,58830,75571,93452,
		-- 86816,
		-- [[ Unknown ]]
		23230,95353,76189,36054,34625,95437,38572,39595,61042,29572,31911,40220,43441,95410,54715,54716,59454,59455,36693,46296,68391,60084,68881,24674,30984,36974,39665,43461,54074,65962,
	}
	local PD = {
		-- [[ The Burning Crusade ]]
		-- 41292,42071,30843,
		-- [[ Wrath of the Lich King ]]
		-- 59513,55593,
		-- [[ Cataclysm ]]
		76903,82170,92787,92981,92982,92983,82890,85576,93181,93182,93183,
	}

	ReductionDebuffs = { }
	for _, id in ipairs( RD ) do
		local name = GetSpellInfo(id)
		if name then
			ReductionDebuffs[ id ] = true
		end
	end

	PreventionDebuffs = { }
	for _, id in ipairs( PD ) do
		local name = GetSpellInfo(id)
		if name then
			PreventionDebuffs[ id ] = true
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
		name, _, icon, count, _, duration, expiration, _, _, _, id = UnitDebuff(unit, i)
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
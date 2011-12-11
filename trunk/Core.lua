--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds generic statuses to Grid for debuffs which reduce or prevent healing received.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2008–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info7364-GridStatusHealingReduced.html
	http://wow.curse.com/downloads/wow-addons/details/gridstatushealingreduced.aspx
----------------------------------------------------------------------]]

local GridStatusHealingReduced = Grid:GetModule("GridStatus"):NewModule("GridStatusHealingReduced")

------------------------------------------------------------------------

local L = setmetatable({ }, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

L["Classic"] = EXPANSION_NAME0
L["The Burning Crusade"] = EXPANSION_NAME1
L["Wrath of the Lich King"] = EXPANSION_NAME2
L["Cataclysm"] = EXPANSION_NAME3
L["PvP"] = PVP

do
	local GAME_LOCALE = GetLocale()
	if GAME_LOCALE == "deDE" then
		L["Healing reduced"] = "Heilung reduziert"
		L["Healing prevented"] = "Heilung verhindert"
	elseif GAME_LOCALE == "esES" or GAME_LOCALE == "esMX" then
		L["Healing reduced"] = "Sanación reducida"
		L["Healing prevented"] = "Sanación impedida"
		L["Include debuffs from level %d content."] = "Incluyen perjuicios de contenido de nivel %d."
		L["Include debuffs applied by players."] = "Incluyen perjuicios aplicado por jugadores."
	elseif GAME_LOCALE == "frFR" then
		L["Healing reduced"] = "Soins diminués"
		L["Healing prevented"] = "Soins empêché"
	elseif GAME_LOCALE == "ptBR" then
		L["Healing reduced"] = "Cura reduzida"
		L["Healing prevented"] = "Cura impedida"
		L["Include debuffs from level %d content."] = "Incluem penalidades do conteúdo de nível %d."
		L["Include debuffs applied by players."] = "Incluem penalidades aplicados pelos jogadores."
	elseif GAME_LOCALE == "ruRU" then
		L["Healing reduced"] = "Исцеление уменьшено"
		L["Healing prevented"] = "Препятствие исцелению"
	elseif GAME_LOCALE == "koKR" then
		L["Healing reduced"] = "치유량 감소"
		L["Healing prevented"] = "치유량 방해"
	elseif GAME_LOCALE == "zhCN" then
		L["Healing reduced"] = "治疗效果被降低"
		L["Healing prevented"] = "治疗无效果"
	elseif GAME_LOCALE == "zhTW" then
		L["Healing reduced"] = "治療效果被降低"
		L["Healing prevented"] = "治療無效果"
	end
end

------------------------------------------------------------------------

local ReductionDebuffs, PreventionDebuffs = { }, { }
local UpdateDebuffLists
do
	local RD = {
		-- [[ Classic ]]
		["60"] = {
			23169,13583,19716,22859,13737,24573,27580,25646,31464,17820,22687,
			78841,43410,19643,32736,
		},
		-- [[ The Burning Crusade ]]
		["70"] = {
			56112,30213,48301,54680,12294,82654,13218,23169,13583,19716,22859,13737,24573,27580,25646,31464,17820,22687,40599,41478,45347,36023,36917,37335,44268,30641,36814,30423,45885,35189,32858,38377,44534,
			34073,34366,32378,17547,38770,
		},
		-- [[ Wrath of the Lich King ]]
		["80"] = {
			48871,59243,65883,67977,67978,67979,63038,48291,59300,70671,70710,15708,16856,35054,57789,65926,67542,68782,68783,68784,71552,28467,48137,54378,59265,71127,69674,71224,73022,73023,28776,54121,59525,54525,59745,59746,32315,28440,53803,69633,69651,72569,72570,72571,
			54615,52645,44475,80390,60626,
		},
		-- [[ Cataclysm ]]
		["85"] = {
			93956,83908,86157,86158,86158,76727,90526,91801,93675,93771,7068,23224,83926,52771,58830,75571,93452,99506,
			86816,
		},
		-- [[ Players ]]
		["pvp"] = {
			56112,30213,48301,54680,12294,82654,13218,
		},
		-- [[ Unknown ]]
		["etc"] = {
			23230,95353,76189,36054,34625,95437,38572,39595,61042,29572,31911,40220,43441,95410,54715,54716,59454,59455,36693,46296,68391,60084,68881,24674,30984,36974,39665,43461,54074,65962,
		},
	}
	local PD = {
		-- [[ The Burning Crusade ]]
		["70"] = {
			41292,42071,30843,
		},
		-- [[ Wrath of the Lich King ]]
		["80"] = {
			59513,55593,
		},
		-- [[ Cataclysm ]]
		["85"] = {
			76903,82170,92787,92981,92982,92983,82890,85576,93181,93182,93183,
		},
	}

	local function copyDebuffs(src, dst)
		if type(src) ~= "table" then return end
		for _, id in ipairs(src) do
			local name = GetSpellInfo(id)
			if name then
				dst[id] = true
			end
		end
	end

	function UpdateDebuffLists()
		wipe(ReductionDebuffs)
		wipe(PreventionDebuffs)
		for k, v in pairs(GridStatusHealingReduced.db.profile.include) do
			if v then
				copyDebuffs(RD[k], ReductionDebuffs)
				copyDebuffs(PD[k], PreventionDebuffs)
			end
		end
	end
end

------------------------------------------------------------------------

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
	},
	include = {
		["60"] = false,
		["70"] = false,
		["80"] = false,
		["85"] = true,
		["pvp"] = false,
		["etc"] = true,
	}
}

GridStatusHealingReduced.menuName = L["Healing reduced"]
--GridStatusHealingReduced.options = false
do
		local optget = function(info)
			return GridStatusHealingReduced.db.profile.include[info[#info]]
		end
		local optset = function(info, v)
			GridStatusHealingReduced.db.profile.include[info[#info]] = v
			UpdateDebuffLists()
			GridStatusHealingReduced:UpdateAllUnits()
		end
	GridStatusHealingReduced.extraOptions = {
		["60"] = {
			order = 60, width = "double",
			name = L["Classic"],
			desc = L["Include debuffs from level %d content."]:format(60),
			type = "toggle", get = optget, set = optset,
		},
		["70"] = {
			order = 70, width = "double",
			name = L["The Burning Crusade"],
			desc = L["Include debuffs from level %d content."]:format(70),
			type = "toggle", get = optget, set = optset,
		},
		["80"] = {
			order = 80, width = "double",
			name = L["Wrath of the Lich King"],
			desc = L["Include debuffs from level %d content."]:format(80),
			type = "toggle", get = optget, set = optset,
		},
		["85"] = {
			order = 85, width = "double",
			name = L["Cataclysm"],
			desc = L["Include debuffs from level %d content."]:format(85),
			type = "toggle", get = optget, set = optset,
		},
		["pvp"] = {
			order = 1000, width = "double",
			name = L["PvP"],
			desc = L["Include debuffs applied by players."],
			type = "toggle", get = optget, set = optset,
		}
	}
end

------------------------------------------------------------------------

function GridStatusHealingReduced:OnInitialize()
--	debug("OnInitialize")
	self.super.OnInitialize(self)

	self:RegisterStatus("alert_healingReduced", L["Healing reduced"]) -- , nil, true)
	self:RegisterStatus("alert_healingPrevented", L["Healing prevented"]) -- , nil, true)
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
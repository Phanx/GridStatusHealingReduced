--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds aggregate statuses to Grid for debuffs which reduce or prevent healing received.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2009 Alyssa "Phanx" Kinley
	See README for license terms and additional information.
	http://www.wowinterface.com/downloads/info7364-GridStatusHealingReduced.html
	http://wow.curse.com/downloads/wow-addons/details/gridstatushealingreduced.aspx
----------------------------------------------------------------------]]

local L = {}
do
	local locale = GetLocale()
	if locale == "deDE" then
		L["Healing reduced"] = "Heilung reduziert"
		L["Healing prevented"] = "Heilung verhindert"
	elseif locale == "esES" or locale == "esMX" then
		L["Healing reduced"] = "Sanación reducida"
		L["Healing prevented"] = "Sanación impedida"
	elseif locale == "frFR" then
		L["Healing reduced"] = "Soins diminués"
		L["Healing prevented"] = "Soins empêché"
	elseif locale == "ruRU" then
		L["Healing reduced"] = "Исцеление уменьшено"
		L["Healing prevented"] = "Препятствие исцелению"
	elseif locale == "koKR" then
		L["Healing reduced"] = "치유량 감소"
		L["Healing prevented"] = "치유량 방해"
	elseif locale == "zhCN" then
		L["Healing reduced"] = "治疗效果被降低"
		L["Healing prevented"] = "治疗无效果"
	elseif locale == "zhTW" then
		L["Healing reduced"] = "治療效果被降低"
		L["Healing prevented"] = "治療無效果"
	end
	setmetatable(L, { __index = function(t, k)
		t[k] = k
		return k
	end })
end

------------------------------------------------------------------------

local function GetSpellName(id)
	local name = GetSpellInfo(id)
	return name or ""
end

-- Debuffs which reduce healing received
local debuffs_reduced = {
	[GetSpellName(19434)] = true, -- Aimed Shot
	[GetSpellName(40599)] = true, -- Arcing Smash
	[GetSpellName(23169)] = true, -- Brood Affliction: Green
	[GetSpellName(43410)] = true, -- Chop
	[GetSpellName(34073)] = true, -- Curse of the Bleeding Hollow
	[GetSpellName(13583)] = true, -- Curse of the Deadwood
	[GetSpellName(45347)] = true, -- Dark Touched
	[GetSpellName(63038)] = true, -- Dark Volley
	[GetSpellName(36023)] = true, -- Deathblow
	[GetSpellName(34625)] = true, -- Demolish
	[GetSpellName(34366)] = true, -- Ebon Poison
	[GetSpellName(48291)] = true, -- Fetid Rot
	[GetSpellName(32378)] = true, -- Filet
	[GetSpellName(56112)] = true, -- Furious Attacks
	[GetSpellName(19716)] = true, -- Gehennas' Curse
	[GetSpellName(52645)] = true, -- Hex of Weakness
	[GetSpellName(36917)] = true, -- Magma-Thrower's Curse
	[GetSpellName(48301)] = true, -- Mind Trauma
	[GetSpellName(22859)] = true, -- Mortal Cleave
	[GetSpellName(12294)] = true, -- Mortal Strike (warrior)
	[GetSpellName(24573)] = true, -- Mortal Strike (Broodlord Lashlayer)
	[GetSpellName(43441)] = true, -- Mortal Strike (Hex Lord Malacrass)
	[GetSpellName(44268)] = true, -- Mortal Strike (Warlord Salaris)
	[GetSpellName(25646)] = true, -- Mortal Wound
	[GetSpellName(31464)] = true, -- Mortal Wound
	[GetSpellName(36814)] = true, -- Mortal Wound
	[GetSpellName(54378)] = true, -- Mortal Wound
	[GetSpellName(69674)] = true, -- Mutated Infection
	[GetSpellName(28776)] = true, -- Necrotic Poison
	[GetSpellName(60626)] = true, -- Necrotic Strike
	[GetSpellName(30423)] = true, -- Nether Portal - Dominance
	[GetSpellName(68391)] = true, -- Permafrost
	[GetSpellName(59525)] = true, -- Ray of Pain
	[GetSpellName(45885)] = true, -- Shadow Spike
	[GetSpellName(54525)] = true, -- Shroud of Darkness
	[GetSpellName(35189)] = true, -- Solar Strike
	[GetSpellName(32315)] = true, -- Soul Strike
	[GetSpellName(70588)] = true, -- Suppression
	[GetSpellName(32858)] = true, -- Touch of the Forgotten
	[GetSpellName(7068)]  = true, -- Veil of Shadow (Nefarian)
	[GetSpellName(28440)] = true, -- Veil of Shadow (Dread Creeper)
	[GetSpellName(69633)] = true, -- Veil of Shadow (Spectral Warden)
	[GetSpellName(13218)] = true, -- Wound Poison (rogue)
	[GetSpellName(43461)] = true, -- Wound Poison (Hex Lord Malacrass)
	[GetSpellName(13222)] = true, -- Wound Poison II
	[GetSpellName(13223)] = true, -- Wound Poison III
	[GetSpellName(13224)] = true, -- Wound Poison IV
	[GetSpellName(27189)] = true, -- Wound Poison V
	[GetSpellName(57974)] = true, -- Wound Poison VI
	[GetSpellName(57975)] = true, -- Wound Poison VII
	[GetSpellName(52771)] = true, -- Wounding Strike
	[GetSpellName(44534)] = true, -- Wretched Strike
}

-- Debuffs which prevent healing received
local debuffs_prevented = {
	[GetSpellName(41292)] = true, -- Aura of Suffering
	[GetSpellName(45996)] = true, -- Darkness
	[GetSpellName(59513)] = true, -- Embrace of the Vampyr
	[GetSpellName(30843)] = true, -- Enfeeble
	[GetSpellName(55593)] = true, -- Necrotic Aura
}

------------------------------------------------------------------------

local GridStatusHealingReduced = GridStatus:NewModule("GridStatusHealingReduced")

local GetNumRaidMembers = GetNumRaidMembers
local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID

local party_units, raid_units, valid_units, enabled, db = { }, { }, { }, 0

local function debug(str)
	print("|cffff7f7fGridStatusHealingReduced:|r " .. str)
end

GridStatusHealingReduced.options = false
GridStatusHealingReduced.defaultDB = {
	alert_healingReduced = {
		text = L["Healing reduced"],
		enable = true,
		color = { r = 0.8, g = 0.4, b = 0.8, a = 1 },
		priority = 90,
		range = false,
	},
	alert_healingPrevented = {
		text = L["Healing prevented"],
		enable = true,
		color = { r = 0.6, g = 0.2, b = 0.6, a = 1 },
		priority = 99,
		range = false,
	}
}

------------------------------------------------------------------------

function GridStatusHealingReduced:OnInitialize()
--	debug("OnInitialize")

	self.super.OnInitialize(self)

	self:RegisterStatus("alert_healingReduced", L["Healing reduced"], nil, true)
	self:RegisterStatus("alert_healingPrevented", L["Healing prevented"], nil, true)

	db = self.db.profile

	for i = 1, 40 do
		raid_units["raid"..i] = true
		raid_units["raidpet"..i] = true
	end

	party_units["player"] = true
	party_units["pet"] = true
	for i = 1, 4 do
		party_units["party"..i] = true
		party_units["partypet"..i] = true
	end
end

function GridStatusHealingReduced:OnEnable()
--	debug("OnEnable")

	self.super.OnEnable(self)
end

function GridStatusHealingReduced:OnStatusEnable(status)
--	debug("OnStatusEnable, " .. status)

	enabled = enabled + 1

	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_AURA", "UpdateUnit")

	self:RAID_ROSTER_UPDATE()

	self:UpdateAllUnits()
end

function GridStatusHealingReduced:OnStatusDisable(status)
--	debug("OnStatusDisable, " .. status)

	enabled = enabled - 1

	if enabled == 0 then
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterEvent("RAID_ROSTER_UPDATE")
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
	end

	self.core:SendStatusLostAllUnits(status)
end

------------------------------------------------------------------------

function GridStatusHealingReduced:UpdateAllUnits()
	if enabled > 0 then
		for guid, unitid in GridRoster:IterateRoster() do
			self:UpdateUnit(unitid)
		end
	end
end

function GridStatusHealingReduced:UpdateUnit(unit)
	if not valid_units[unit] then return end
--	debug("UNIT_AURA, " .. unit)
	local settings, name, icon, count, duration, expirationTime, _

	local prevented, reduced = false, false
	for i = 1, 40 do
		name, _, icon, count, _, duration, expirationTime = UnitDebuff(unit, i)
		if not name then
			break
		end
		if duration then
			if debuffs_prevented[name] then
				prevented = true
				reduced = false
				break
			elseif not reduced and debuffs_reduced[name] then
				reduced = true
			end
		end
	end

	if prevented then
	--	debug("SendStatusGained")
		settings = db.alert_healingPrevented
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingPrevented", settings.priority, (settings.range and 40), settings.color, settings.text, nil, nil, icon, expirationTime and (expirationTime - duration), count)
	else
	--	debug("SendStatusLost")
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingPrevented")
	end

	if reduced then
	--	debug("SendStatusGained")
		settings = db.alert_healingReduced
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingReduced", settings.priority, (settings.range and 40), settings.color, settings.text, nil, nil, icon, expirationTime and (expirationTime - duration), count)
	else
	--	debug("SendStatusLost")
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingReduced")
	end
end

------------------------------------------------------------------------

function GridStatusHealingReduced:RAID_ROSTER_UPDATE()
--	debug("RAID_ROSTER_UPDATE")

	if GetNumRaidMembers() > 0 then
	--	debug("In raid")
		valid_units = raid_units
	else
	--	debug("Not in raid")
		valid_units = party_units
	end
end

------------------------------------------------------------------------
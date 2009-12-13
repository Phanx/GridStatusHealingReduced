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

-- Debuffs which reduce healing received
local debuffs_reduced = {
	19434, -- Aimed Shot
	40599, -- Arcing Smash
	23169, -- Brood Affliction: Green
	43410, -- Chop
	34073, -- Curse of the Bleeding Hollow
	13583, -- Curse of the Deadwood
	45347, -- Dark Touched
	63038, -- Dark Volley
	36023, -- Deathblow
	34625, -- Demolish
	34366, -- Ebon Poison
	48291, -- Fetid Rot
	32378, -- Filet
	56112, -- Furious Attacks
	19716, -- Gehennas' Curse
	52645, -- Hex of Weakness
	36917, -- Magma-Thrower's Curse
	48301, -- Mind Trauma
	22859, -- Mortal Cleave
	12294, -- Mortal Strike (warrior)
	24573, -- Mortal Strike (Broodlord Lashlayer)
	43441, -- Mortal Strike (Hex Lord Malacrass)
	44268, -- Mortal Strike (Warlord Salaris)
	25646, -- Mortal Wound
	31464, -- Mortal Wound
	36814, -- Mortal Wound
	54378, -- Mortal Wound
	69674, -- Mutated Infection
	28776, -- Necrotic Poison
	60626, -- Necrotic Strike
	30423, -- Nether Portal - Dominance
	68391, -- Permafrost
	59525, -- Ray of Pain
	45885, -- Shadow Spike
	54525, -- Shroud of Darkness
	35189, -- Solar Strike
	32315, -- Soul Strike
	70588, -- Suppression
	32858, -- Touch of the Forgotten
	7068,  -- Veil of Shadow (Nefarian)
	28440, -- Veil of Shadow (Dread Creeper)
	69633, -- Veil of Shadow (Spectral Warden)
	13218, -- Wound Poison (rogue)
	43461, -- Wound Poison (Hex Lord Malacrass)
	13222, -- Wound Poison II
	13223, -- Wound Poison III
	13224, -- Wound Poison IV
	27189, -- Wound Poison V
	57974, -- Wound Poison VI
	57975, -- Wound Poison VII
	52771, -- Wounding Strike
	44534, -- Wretched Strike
}
for _, id in ipairs(debuffs_reduced) do
	local name = GetSpellInfo(spellID)
	if name and not debuffs_reduced[name] then
		debuffs_reduced[name] = true
	end
end

-- Debuffs which prevent healing received
local debuffs_prevented = {
	41292, -- Aura of Suffering
	45996, -- Darkness
	59513, -- Embrace of the Vampyr
	30843, -- Enfeeble
	55593, -- Necrotic Aura
}
for _, id in ipairs(debuffs_prevented) do
	local name = GetSpellInfo(spellID)
	if name and not debuffs_prevented[name] then
		debuffs_prevented[name] = true
	end
end

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
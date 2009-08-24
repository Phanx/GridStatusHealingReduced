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
		L["Healing Reduced"] = "Heilung reduziert"
		L["Healing Prevented"] = "Heilung verhindert"
--	elseif locale == "esES" then
--		L["Healing Reduced"] = ""
--		L["Healing Prevented"] = ""
--	elseif locale == "esMX" then
--		L["Healing Reduced"] = ""
--		L["Healing Prevented"] = ""
--	elseif locale == "frFR" then
--		L["Healing Reduced"] = ""
--		L["Healing Prevented"] = ""
	elseif locale == "ruRU" then
		L["Healing Reduced"] = "Исцеление уменьшено"
		L["Healing Prevented"] = "Препятствие исцелению"
	elseif locale == "koKR" then
		L["Healing Reduced"] = "치유량 감소"
		L["Healing Prevented"] = "치유량 방해"
	elseif locale == "zhCN" then
		L["Healing Reduced"] = "治疗效果被降低"
		L["Healing Prevented"] = "治疗无效果"
	elseif locale == "zhTW" then
		L["Healing Reduced"] = "治療效果被降低"
		L["Healing Prevented"] = "治療無效果"
	end
	setmetatable(L, { __index = function(t, k) t[k] = k return k end })
end

------------------------------------------------------------------------

-- Debuffs which reduce healing received
local debuffs_reduced = {
	[GetSpellInfo(19434)] = true,	-- 0.50, -- Aimed Shot
	[GetSpellInfo(56112)] = true, -- 0.25, -- Furious Attacks
	[GetSpellInfo(48301)] = true, -- 0.20, -- Mind Trauma
	[GetSpellInfo(12294)] = true,	-- 0.50, -- Mortal Strike
	[GetSpellInfo(13218)] = true,	-- 0.50, -- Wound Poison
--	[GetSpellInfo(43461)] = true,	-- 0.50, -- Wound Poison / Hex Lord Malacrass / Zul'Gurub
	[GetSpellInfo(13222)] = true,	-- 0.50, -- Wound Poison II
	[GetSpellInfo(13223)] = true,	-- 0.50, -- Wound Poison III
	[GetSpellInfo(13224)] = true,	-- 0.50, -- Wound Poison IV
	[GetSpellInfo(27189)] = true,	-- 0.50, -- Wound Poison V
	[GetSpellInfo(57974)] = true,	-- 0.50, -- Wound Poison VI
	[GetSpellInfo(57975)] = true,	-- 0.50, -- Wound Poison VII

--	[GetSpellInfo(32858)] = true,	-- -345, -- Touch of the Forgotten / Auchenai Soulpriest / Auchenai Crypts
	[GetSpellInfo(38377)] = true,	-- -690, -- Touch of the Forgotten / Auchenai Soulpriest / Auchenai Crypts (Heroic)

	[GetSpellInfo(40599)] = true,	-- 0.50, -- Arcing Smash / Gurtogg Bloodboil / Black Temple
	[GetSpellInfo(34073)] = true,	-- 0.15, -- Curse of the Bleeding Hollow / Bleeding Hollow orcs / Hellfire Peninsula
	[GetSpellInfo(13583)] = true,	-- 0.50, -- Curse of the Deadwood / Deadwood furbolgs / Felwood
	[GetSpellInfo(23169)] = true,	-- 0.50, -- Brood Affliction: Green / Chromaggus / Blackwing Lair
	[GetSpellInfo(45347)] = true,	-- 0.04, -- Dark Touched / Lady Sacrolash / Sunwell Plateau / stacks to 25
	[GetSpellInfo(63038)] = true, -- 0.25, -- Dark Volley / Guardian of Yogg-Saron / Ulduar
--	[GetSpellInfo(36023)] = true,	-- 0.50, -- Deathblow / Shattered Hand Savage / Shattered Halls
	[GetSpellInfo(36054)] = true,	-- 0.50, -- Deathblow / Shattered Hand Savage / Shattered Halls (Heroic)
	[GetSpellInfo(34625)] = true,	-- 0.75, -- Demolish / Negatron / Netherstorm
	[GetSpellInfo(34366)] = true,	-- 0.35, -- Ebon Poison / Blackfang Tarantula / The Black Morass
	[GetSpellInfo(32378)] = true,	-- 0.50, -- Filet / Spectral Chef / Karazhan
	[GetSpellInfo(19716)] = true,	-- 0.75, -- Gehennas' Curse / Gehennas / Molten Core
	[GetSpellInfo(52645)] = true, -- 0.20, -- Hex of Weakness / Zol'Maz Stronghold Cache / Zul'Drak
	[GetSpellInfo(36917)] = true,	-- 0.50, -- Magma-Thrower's Curse / Sulfuron Magma-Thrower / The Arcatraz
	[GetSpellInfo(22859)] = true,	-- 0.50, -- Mortal Cleave / High Priestess Thekal / Zul'Gurub
--	[GetSpellInfo(25646)] = true, -- 0.10, -- Mortal Wound / Bonechewer Spectator / Black Temple / stacks to 10
--	[GetSpellInfo(25646)] = true, -- 0.10, -- Mortal Wound / Fankriss the Unyielding / Temple of Ahn'Qiraj / stacks to 10
	[GetSpellInfo(54378)] = true, -- 0.10, -- Mortal Wound / Gluth / Naxxramas / stacks to 10
--	[GetSpellInfo(25646)] = true, -- 0.10, -- Mortal Wound / Kurinnaxx / Ruins of Ahn'Qiraj / stacks to 10
--	[GetSpellInfo(28467)] = true, -- 0.10, -- Mortal Wound / Unstoppable Abomination / Naxxramas
--	[GetSpellInfo(25646)] = true,	-- 0.10, -- Mortal Wound / Temporus / The Black Morass / stacks to 7
--	[GetSpellInfo(36814)] = true,	-- 0.10, -- Mortal Wound / Watchkeeper Gargolmar / Hellfire Ramparts (Heroic) / stacks to 8
--	[GetSpellInfo(30641)] = true,	-- 0.10, -- Mortal Wound / Watchkeeper Gargolmar / Hellfire Ramparts / stacks to 8
--	[GetSpellInfo(54121)] = true,	-- 0.75, -- Necrotic Poison / Maexxna / Naxxramas
	[GetSpellInfo(28776)] = true,	-- 0.90, -- Necrotic Poison / Maexxna / Naxxramas (Heroic)
	[GetSpellInfo(60626)] = true, -- 0.10, -- Necrotic Strike / Undying Minion / Icecrown / stacks to 10
	[GetSpellInfo(30423)] = true,	-- 0.01, -- Nether Portal / Dominance / Netherspite / Karazhan / stacks to 99
	[GetSpellInfo(59525)] = true, -- 0.15, -- Ray of Pain / Moragg / The Violet Hold
	[GetSpellInfo(45885)] = true, -- 0.50, -- Shadow Spike / Kil'jaeden / Sunwell Plateau
	[GetSpellInfo(54525)] = true, -- 0.20, -- Shroud of Darkness / Zuramat the Obliterator / The Violet Hold / stacks to 5
	[GetSpellInfo(35189)] = true,	-- 0.50, -- Solar Strike / Bloodwarder Slayer / The Mechanar
	[GetSpellInfo(32315)] = true,	-- 0.50, -- Soul Strike / Ethereal Crypt Raider / Mana-Tombs
--	[GetSpellInfo(53803)] = true,	-- 0.50, -- Veil of Shadow / Dread Creeper / Naxxramas
	[GetSpellInfo(28440)] = true,	-- 0.75, -- Veil of Shadow / Dread Creeper / Naxxramas (Heroic)
--	[GetSpellInfo(7068)]  = true,	-- 0.75, -- Veil of Shadow / Nefarian / Blackwing Lair
	[GetSpellInfo(44534)] = true,	-- 0.50, -- Wretched Strike / Wretched Bruiser / Magisters' Terrace
}

-- Debuffs which prevent healing received
local debuffs_prevented = {
	[GetSpellInfo(41292)] = true, -- Aura of Suffering / Essence of Suffering / Black Temple
	[GetSpellInfo(45996)] = true, -- Darkness / M'uru / Sunwell Plateau
	[GetSpellInfo(30843)] = true, -- Enfeeble / Prince Malchezaar / Karazhan
	[GetSpellInfo(55593)] = true, -- Necrotic Aura / Loatheb / Naxxramas
}

------------------------------------------------------------------------

local GridStatusHealingReduced = GridStatus:NewModule("GridStatusHealingReduced")

local GetNumRaidMembers = GetNumRaidMembers
local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID

local valid_units, enabled, db = {}, 0

local function debug(str)
	print("|cffff7f7fGridStatusHealingReduced:|r " .. str)
end

GridStatusHealingReduced.menuName = L["Healing Reduced"]
GridStatusHealingReduced.options = false
GridStatusHealingReduced.defaultDB = {
--	debug = false,
	alert_healingReduced = {
		text = L["Healing Reduced"],
		enable = true,
		color = { r = 0.8, g = 0.4, b = 0.8, a = 1 },
		priority = 90,
		range = true,
	},
	alert_healingPrevented = {
		text = L["Healing Prevented"],
		enable = true,
		color = { r = 0.6, g = 0.2, b = 0.6, a = 1 },
		priority = 99,
		range = true,
	}
}

------------------------------------------------------------------------

function GridStatusHealingReduced:OnInitialize()
--	debug("OnInitialize")

	self.super.OnInitialize(self)

	self:RegisterStatus("alert_healingReduced", L["Healing Reduced"], nil, true)
	self:RegisterStatus("alert_healingPrevented", L["Healing Prevented"], nil, true)

	db = self.db.profile

	self.raid_units = {}
	for i = 1, 40 do
		self.raid_units["raid"..i] = true
		self.raid_units["raidpet"..i] = true
	end

	self.party_units = {
		player = true,
		pet = true,
	}
	for i = 1, 4 do
		self.party_units["party"..i] = true
		self.party_units["partypet"..i] = true
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
		valid_units = self.raid_units
	else
	--	debug("Not in raid")
		valid_units = self.party_units
	end
end

------------------------------------------------------------------------
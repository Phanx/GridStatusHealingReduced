----------------------------------------------------------------
--	GridStatusHealingReduced
--	Adds a Grid status for debuffs that reduce healing taken.
----------------------------------------------------------------

local L = {}
do
	local locale = GetLocale()
	if locale ~= "enUS" and locale ~= "enGB" then
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
		for english, localized in pairs(LibStub("LibBabble-Zone-3.0"):GetLookupTable()) do
			L[english] = localized
		end
	end
	setmetatable(L, { __index = function(t, k) rawset(t, k, k) return k end })
end

----------------------------------------------------------------

local reductionDebuffs = {
	["*"] = {
		[GetSpellInfo(19434)] = true,	-- 0.50, -- Aimed Shot
--		[GetSpellInfo(23230)] = true,	-- 0.50, -- Blood Fury -- debuff component REMOVED in WoW 3.0
--		[GetSpellInfo(9035)]  = true,	-- 0.80, -- Hex of Weakness -- priest racial REMOVED in WoW 3.0
		[GetSpellInfo(12294)] = true,	-- 0.50, -- Mortal Strike
		[GetSpellInfo(13218)] = true,	-- 1 - (.10 * 5),  -- Wound Poison
	},
	[L["Auchenai Crypts"]] = {
		[GetSpellInfo(32858)] = true,	-- -345, -- Touch of the Forgotten (Auchenai Soulpriest)
--		[GetSpellInfo(32377)] = true,	-- -690, -- Touch of the Forgotten (Auchenai Soulpriest)
	},
	[L["Black Temple"]] = {
		[GetSpellInfo(40599)] = true,	-- 0.50, -- Arcing Smash (Gurtogg Bloodboil)
	},
	[L["Blackwing Lair"]] = {
		[GetSpellInfo(23169)] = true,	-- 0.50, -- Brood Affliction: Green (Chromaggus)
		[GetSpellInfo(7068)]  = true,	-- 0.25, -- Veil of Shadow (Nefarian)
	},
	[L["Felwood"]] = {
		[GetSpellInfo(13583)] = true,	-- 0.50, -- Curse of the Deadwood (Deadwood furbolgs)
	},
	[L["Hellfire Peninsula"]] = {
		[GetSpellInfo(34073)] = true,	-- 0.85, -- Curse of the Bleeding Hollow (Bleeding Hollow orcs)
	},
	[L["Karazhan"]] = {
		[GetSpellInfo(32378)] = true,	-- 0.50, -- Filet (Spectral Chef)
		[GetSpellInfo(30423)] = true,	-- 1 - (.01 * 99), -- Nether Portal - Dominance (Netherspite)
	},
	[L["Magister's Terrace"]] = {
		[GetSpellInfo(44534)] = true,	-- 0.50, -- Wretched Strike (Wretched Bruiser)
	},
	[L["Mana-Tombs"]] = {
		[GetSpellInfo(32315)] = true,	-- 0.50, -- Soul Strike (Ethereal Crypt Raider)
	},
	[L["Molten Core"]] = {
		[GetSpellInfo(19716)] = true,	-- 0.25, -- Gehennas' Curse (Gehennas)
	},
	[L["Naxxramas"]] = {
		[GetSpellInfo(28776)] = true,	-- 0.10, -- Necrotic Poison (Maexxna)
	},
	[L["Netherstorm"]] = {
		[GetSpellInfo(34625)] = true,	-- 0.25, -- Demolish (Negatron)
	},
	[L["Shattered Halls"]] = {
		[GetSpellInfo(36023)] = true,	-- 0.50, -- Deathblow (Shattered Hand Savage)
		[GetSpellInfo(36054)] = true,	-- 0.50, -- Deathblow (Shattered Hand Savage)
	},
	[L["Sunwell Plateau"]] = {
		[GetSpellInfo(45885)] = true, -- 0.50, -- Shadow Spike (Kil'jaeden)
		[GetSpellInfo(45347)] = true,	-- 1 - (.04 * 25), -- Dark Touched (Lady Sacrolash)
	},
	[L["The Arcatraz"]] = {
		[GetSpellInfo(36917)] = true,	-- 0.50, -- Magma-Thrower's Curse (Sulfuron Magma-Thrower)
	},
	[L["The Black Morass"]] = {
		[GetSpellInfo(34366)] = true,	-- 0.75, -- Ebon Poison (Blackfang Tarantula)
		[GetSpellInfo(25646)] = true,	-- 1 - (.10 * 7),  -- Mortal Wound (Temporuss)
	},
	[L["The Mechanar"]] = {
		[GetSpellInfo(35189)] = true,	-- 0.50, -- Solar Strike (Bloodwarder Slayer)
	},
	[L["Zul'Gurub"]] = {
		[GetSpellInfo(22859)] = true,	-- 0.50, -- Mortal Cleave (High Priestess Thekal)
	},
}

local preventionDebuffs = {
	[L["Black Temple"]] = {
		[GetSpellInfo(41292)] = true, -- Aura of Suffering (Essence of Suffering - Black Temple)
	},
	[L["Karazhan"]] = {
		[GetSpellInfo(30843)] = true, -- Enfeeble (Prince Malchezaar - Karazhan)
	},
	[L["Sunwell Plateau"]] = {
		[GetSpellInfo(45996)] = true, -- Darkness (M'uru - Sunwell Plateau)
	},
}

----------------------------------------------------------------

local GridStatusHealingReduced = GridStatus:NewModule("GridStatusHealingReduced")

local UnitAura = UnitAura
local UnitGUID = Grid:HasModule("GridRoster") and UnitGUID or UnitName

local reduction_debuffs, prevention_debuffs, reduced_units, prevented_units, valid_units, db = {}, {}, {}, {}

GridStatusHealingReduced.menuName = L["Healing Reduced"]
GridStatusHealingReduced.options = false
GridStatusHealingReduced.defaultDB = {
	debug = false,
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

function GridStatusHealingReduced:OnInitialize()
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
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE")

	self:RAID_ROSTER_UPDATE()
	self:ZONE_CHANGED_NEW_AREA()
end

function GridStatusHealingReduced:RAID_ROSTER_UPDATE()
	if GetNumRaidMembers() > 0 then
		valid_units = self.raid_units
	else
		valid_units = self.party_units
	end
end

function GridStatusHealingReduced:ZONE_CHANGED_NEW_AREA()
	wipe(reduction_debuffs)
	wipe(prevention_debuffs)

	for debuff in pairs(reductionDebuffs["*"]) do
		reduction_debuffs[debuff] = true
	end

	if reductionDebuffs[GetRealZoneText()] then
		for debuff in pairs(reductionDebuffs[GetRealZoneText()]) do
			reduction_debuffs[debuff] = true
		end
	end

	if preventionDebuffs[GetRealZoneText()] then
		for debuff in pairs(preventionDebuffs[GetRealZoneText()]) do
			prevention_debuffs[debuff] = true
		end
	end
end

local reduced, prevented, settings
function GridStatusHealingReduced:UNIT_AURA(unit)
	if not valid_units[unit] then return end

	prevented = false
	reduced = false

	for debuff in pairs(prevention_debuffs) do
		if UnitAura(unit, debuff) then
			prevented = true
			break
		end
	end

	if prevented and not prevented_units[unit] then
		prevented_units[unit] = true
		settings = db.alert_healingPrevented
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingPrevented", settings.priority, (settings.range and 40), settings.color, settings.text)
	elseif prevented_units[unit] then
		prevented_units[unit] = false
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingPrevented")
	end

	for debuff in pairs(reduction_debuffs) do
		if UnitAura(unit, debuff) then
			reduced = true
			break
		end
	end

	if reduced and not reduced_units[units] then
		reduced_units[unit] = true
		settings = db.alert_healingReduced
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingReduced", settings.priority, (settings.range and 40), settings.color, settings.text)
	elseif reduced_units[unit] then
		reduced_units[unit] = false
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingReduced")
	end
end
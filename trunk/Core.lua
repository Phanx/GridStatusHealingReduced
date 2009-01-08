--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds aggregate statuses to Grid for debuffs which reduce or prevent healing received.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info7364-GridStatusHealingReduced.html
	http://wow.curse.com/downloads/wow-addons/details/gridstatushealingreduced.aspx
	Copyright © 2007–2009 Alyssa S. Kinley, a.k.a. Phanx
	Do not redistribute. See README for full license terms.
----------------------------------------------------------------------]]

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

------------------------------------------------------------------------

local data_reduced = {
	["*"] = {
		[GetSpellInfo(19434)] = true,	-- 0.50, -- Aimed Shot (also various: see README)
		[GetSpellInfo(12294)] = true,	-- 0.50, -- Mortal Strike (also various: see README)
		[GetSpellInfo(13218)] = true,	-- 0.50, -- Wound Poison (also 43461: Hex Lord Malacrass, Zul'Aman)
		[GetSpellInfo(13222)] = true,	-- 0.50, -- Wound Poison II
		[GetSpellInfo(13223)] = true,	-- 0.50, -- Wound Poison III
		[GetSpellInfo(13224)] = true,	-- 0.50, -- Wound Poison IV
		[GetSpellInfo(27189)] = true,	-- 0.50, -- Wound Poison V
		[GetSpellInfo(57974)] = true,	-- 0.50, -- Wound Poison VI
		[GetSpellInfo(57975)] = true,	-- 0.50, -- Wound Poison VII
	},
	[L["Auchenai Crypts"]] = {
		[GetSpellInfo(32858)] = true,	-- -345, -- Touch of the Forgotten (Auchenai Soulpriest)
	--	[GetSpellInfo(32377)] = true,	-- -690, -- Touch of the Forgotten (Auchenai Soulpriest) (Heroic)
	},
	[L["Black Temple"]] = {
		[GetSpellInfo(40599)] = true,	-- 0.50, -- Arcing Smash (Gurtogg Bloodboil)
	},
	[L["Blackwing Lair"]] = {
		[GetSpellInfo(23169)] = true,	-- 0.50, -- Brood Affliction: Green (Chromaggus)
		[GetSpellInfo(7068)]  = true,	-- 0.75, -- Veil of Shadow (Nefarian)
	},
	[L["Felwood"]] = {
		[GetSpellInfo(13583)] = true,	-- 0.50, -- Curse of the Deadwood (Deadwood furbolgs)
	},
	[L["Hellfire Peninsula"]] = {
		[GetSpellInfo(34073)] = true,	-- 0.15, -- Curse of the Bleeding Hollow (Bleeding Hollow orcs)
	},
	[L["Karazhan"]] = {
		[GetSpellInfo(32378)] = true,	-- 0.50, -- Filet (Spectral Chef)
		[GetSpellInfo(30423)] = true,	-- 0.01, -- Nether Portal - Dominance (Netherspite) (stacks to 99)
	},
	[L["Magister's Terrace"]] = {
		[GetSpellInfo(44534)] = true,	-- 0.50, -- Wretched Strike (Wretched Bruiser)
	},
	[L["Mana-Tombs"]] = {
		[GetSpellInfo(32315)] = true,	-- 0.50, -- Soul Strike (Ethereal Crypt Raider)
	},
	[L["Molten Core"]] = {
		[GetSpellInfo(19716)] = true,	-- 0.75, -- Gehennas' Curse (Gehennas)
	},
	[L["Naxxramas"]] = {
		[GetSpellInfo(54378)] = true, -- 0.10, -- Mortal Wound (Gluth) (stacks to 10)
	--	[GetSpellInfo(28467)] = true, -- 0.10, -- Mortal Wound (Unstoppable Abomination)
	--	[GetSpellInfo(28776)] = true,	-- 0.90, -- Necrotic Poison (Maexxna) (Heroic)
		[GetSpellInfo(54121)] = true,	-- 0.75, -- Necrotic Poison (Maexxna)
	},
	[L["Netherstorm"]] = {
		[GetSpellInfo(34625)] = true,	-- 0.75, -- Demolish (Negatron)
	},
	[L["Shattered Halls"]] = {
		[GetSpellInfo(36023)] = true,	-- 0.50, -- Deathblow (Shattered Hand Savage)
	--	[GetSpellInfo(36054)] = true,	-- 0.50, -- Deathblow (Shattered Hand Savage) (Heroic)
	},
	[L["Sunwell Plateau"]] = {
		[GetSpellInfo(45885)] = true, -- 0.50, -- Shadow Spike (Kil'jaeden)
		[GetSpellInfo(45347)] = true,	-- 0.04, -- Dark Touched (Lady Sacrolash) (stacks to 25)
	},
	[L["The Arcatraz"]] = {
		[GetSpellInfo(36917)] = true,	-- 0.50, -- Magma-Thrower's Curse (Sulfuron Magma-Thrower)
	},
	[L["The Black Morass"]] = {
		[GetSpellInfo(34366)] = true,	-- 0.35, -- Ebon Poison (Blackfang Tarantula)
	--	[GetSpellInfo(25646)] = true,	-- 0.10, -- Mortal Wound (Temporus) (stacks to 7)
	},
	[L["The Mechanar"]] = {
		[GetSpellInfo(35189)] = true,	-- 0.50, -- Solar Strike (Bloodwarder Slayer)
	},
	[L["Zul'Gurub"]] = {
		[GetSpellInfo(22859)] = true,	-- 0.50, -- Mortal Cleave (High Priestess Thekal)
	},
}

local data_prevented = {
	[L["Black Temple"]] = {
		[GetSpellInfo(41292)] = true, -- Aura of Suffering (Essence of Suffering)
	},
	[L["Karazhan"]] = {
		[GetSpellInfo(30843)] = true, -- Enfeeble (Prince Malchezaar)
	},
	[L["Naxxramas"]] = {
		[GetSpellInfo(55593)] = true, -- Necrotic Aura (Loatheb)
	},
	[L["Sunwell Plateau"]] = {
		[GetSpellInfo(45996)] = true, -- Darkness (M'uru)
	},
}

------------------------------------------------------------------------

local GridStatusHealingReduced = GridStatus:NewModule("GridStatusHealingReduced")

local UnitAura = UnitAura
local UnitGUID = Grid:HasModule("GridRoster") and UnitGUID or UnitName

local debuffs_reduced, debuffs_prevented, units_reduced, units_prevented, valid_units, db = {}, {}, {}, {}

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

	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE")

	self:RAID_ROSTER_UPDATE()
	self:ZONE_CHANGED_NEW_AREA()
end

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

function GridStatusHealingReduced:ZONE_CHANGED_NEW_AREA()
--	debug("ZONE_CHANGED_NEW_AREA")
	
	local zone = GetRealZoneText()
	if not zone or string.len(zone) == 0 then return end

	wipe(debuffs_reduced)
	wipe(debuffs_prevented)

--	debug("Adding reduction debuffs...")
	for debuff in pairs(data_reduced["*"]) do
	--	debug("Adding debuff: " .. debuff)
		debuffs_reduced[debuff] = true
	end

--	debug("Adding reduction debuffs for " .. zone .. "...")
	if data_reduced[GetRealZoneText()] then
		for debuff in pairs(data_reduced[zone]) do
		--	debug("Adding debuff: " .. debuff)
			debuffs_reduced[debuff] = true
		end
	end

--	debug("Adding prevention debuffs for " .. zone .. "...")
	if data_prevented[GetRealZoneText()] then
		for debuff in pairs(data_prevented[zone]) do
		--	debug("Adding debuff: " .. debuff)
			debuffs_prevented[debuff] = true
		end
	end
end

local reduced, prevented, settings
function GridStatusHealingReduced:UNIT_AURA(unit)
	if not valid_units[unit] then return end
--	debug("UNIT_AURA, " .. unit)

	prevented = false
	reduced = false

	for debuff in pairs(debuffs_prevented) do
		if UnitDebuff(unit, debuff) then
		--	debug("Healing prevented!")
			prevented = true
			break
		end
	end

	if prevented and not units_prevented[unit] then
	--	debug("SendStatusGained")
		units_prevented[unit] = true
		settings = db.alert_healingPrevented
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingPrevented", settings.priority, (settings.range and 40), settings.color, settings.text)
	elseif units_prevented[unit] then
	--	debug("SendStatusLost")
		units_prevented[unit] = false
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingPrevented")
	end

	for debuff in pairs(debuffs_reduced) do
	--	debug("Scanning for " .. debuff .. "...")
		if UnitDebuff(unit, debuff) then
		--	debug("Healing reduced!")
			reduced = true
			break
		end
	end

	if reduced and not units_reduced[units] then
	--	debug("SendStatusGained")
		units_reduced[unit] = true
		settings = db.alert_healingReduced
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingReduced", settings.priority, (settings.range and 40), settings.color, settings.text)
	elseif units_reduced[unit] then
	--	debug("SendStatusLost")
		units_reduced[unit] = false
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingReduced")
	end
end

------------------------------------------------------------------------
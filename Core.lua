--[[--------------------------------------------------------------------
GridStatusHealingReduced
Adds statuses to Grid for debuffs which reduce or prevent healing received.
by Phanx < addons AT phanx net >
http://www.wowinterface.com/downloads/info7364.html
Please see the included README text file for license terms and additional information.
----------------------------------------------------------------------]]

--[[--------------------------------------------------------------------
To-Do:

Improve debuff scanning efficiency by only looking for debuffs that can
exist in the player's current location; i.e, don't scan for Kil'jaeden's
Shadow Spike if the player is in Durotar.

Add translations for esES, esMX, and frFR locales.
----------------------------------------------------------------------]]

local locale = GetLocale()
local L = locale == "deDE" and {
	["Healing Reduced"] = "Heilung reduziert",
	["Healing Prevented"] = "Heilung verhindert",
} or locale == "ruRU" and {
	["Healing Reduced"] = "Исцеление уменьшено",
	["Healing Prevented"] = "Препятствие исцелению",
} or locale == "koKR" and {
	["Healing Reduced"] = "치유량 감소",
	["Healing Prevented"] = "치유량 방해",
} or locale == "zhCN" and {
	["Healing Reduced"] = "治疗效果被降低",
	["Healing Prevented"] = "治疗无效果",
} or locale == "zhTW" and {
	["Healing Reduced"] = "治療效果被降低",
	["Healing Prevented"] = "治療無效果",
} or {}
setmetatable(L, { __index = function(t, k) rawset(t, k, k); return k; end })

----------------------------------------------------------------

local healingReductionDebuffs = {
	[GetSpellInfo(19434)] = true,	-- 0.50, -- Aimed Shot
	[GetSpellInfo(40599)] = true,	-- 0.50, -- Arcing Smash (Gurtogg Bloodboil - Black Temple)
--	[GetSpellInfo(23230)] = true,	-- 0.50, -- Blood Fury (Orc racial skill) -- REMOVED in patch 3.0.2
	[GetSpellInfo(23169)] = true,	-- 0.50, -- Brood Affliction: Green (Chromaggus - Blackwing Lair)
	[GetSpellInfo(34073)] = true,	-- 0.85, -- Curse of the Bleeding Hollow (Bleeding Hollow orcs - Hellfire Peninsula)
	[GetSpellInfo(13583)] = true,	-- 0.50, -- Curse of the Deadwood (Deadwood furbolgs - Felwood)
	[GetSpellInfo(36023)] = true,	-- 0.50, -- Deathblow (Shattered Hand Savage - Shattered Halls)
	[GetSpellInfo(36054)] = true,	-- 0.50, -- Deathblow (Shattered Hand Savage - Shattered Halls)
	[GetSpellInfo(34625)] = true,	-- 0.25, -- Demolish (Negatron - Netherstorm)
	[GetSpellInfo(34366)] = true,	-- 0.75, -- Ebon Poison (Blackfang Tarantula - The Black Morass)
	[GetSpellInfo(32378)] = true,	-- 0.50, -- Filet (Spectral Chef - Karazhan)
	[GetSpellInfo(19716)] = true,	-- 0.25, -- Gehennas' Curse (Gehennas - Molten Core)
--	[GetSpellInfo(9035)]  = true,	-- 0.80, -- Hex of Weakness -- REMOVED in patch 3.0.2, at least for priests
	[GetSpellInfo(36917)] = true,	-- 0.50, -- Magma-Thrower's Curse (Sulfuron Magma-Thrower - The Arcatraz)
	[GetSpellInfo(22859)] = true,	-- 0.50, -- Mortal Cleave (High Priestess Thekal - Zul'Gurub)
	[GetSpellInfo(12294)] = true,	-- 0.50, -- Mortal Strike
	[GetSpellInfo(28776)] = true,	-- 0.10, -- Necrotic Poison (Maexxna - Naxxramas)
	[GetSpellInfo(45885)] = true, -- 0.50, -- Shadow Spike (Kil'jaeden- Sunwell Plateau)
	[GetSpellInfo(35189)] = true,	-- 0.50, -- Solar Strike (Bloodwarder Slayer - The Mechanar)
	[GetSpellInfo(32315)] = true,	-- 0.50, -- Soul Strike (Ethereal Crypt Raider - Mana-Tombs)
	[GetSpellInfo(7068)]  = true,	-- 0.25, -- Veil of Shadow (Nefarian - Blackwing Lair)
	[GetSpellInfo(44534)] = true,	-- 0.50, -- Wretched Strike (Wretched Bruiser - Magister's Terrace)

	[GetSpellInfo(32858)] = true,	-- -345, -- Touch of the Forgotten (Auchenai Soulpriest - Auchenai Crypts)
--	[GetSpellInfo(32377)] = true,	-- -690, -- Touch of the Forgotten (Auchenai Soulpriest - Auchenai Crypts) -- DUPLICATE; heroic version of above

	[GetSpellInfo(45347)] = true,	-- 1 - (.04 * 25), -- Dark Touched (Lady Sacrolash - Sunwell Plateau)
	[GetSpellInfo(30423)] = true,	-- 1 - (.01 * 99), -- Nether Portal - Dominance (Netherspite - Karazhan)
	[GetSpellInfo(25646)] = true,	-- 1 - (.10 * 7),  -- Mortal Wound (Temporus - The Black Morass)
	[GetSpellInfo(13218)] = true,	-- 1 - (.10 * 5),  -- Wound Poison
--	[GetSpellInfo(39665)] = true, -- 1 - (.20 * 5),  -- Wound Poison (Hex Lord Malacrass - Zul'Aman) -- DUPLICATE; same name as rogue ability
}

local healingPreventionDebuffs = {
	[GetSpellInfo(41292)] = true, -- Aura of Suffering (Essence of Suffering - Black Temple)
	[GetSpellInfo(45996)] = true, -- Darkness (M'uru - Sunwell Plateau)
	[GetSpellInfo(30843)] = true, -- Enfeeble (Prince Malchezaar - Karazhan)
}

----------------------------------------------------------------

GridStatusHealingReduced = GridStatus:NewModule("GridStatusHealingReduced")

local GridStatusHealingReduced = GridStatusHealingReduced
local UnitDebuff = UnitDebuff
local UnitName = UnitName
local db

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
end

function GridStatusHealingReduced:OnEnable()
	self:RegisterEvent("UNIT_AURA")
end

local reduced, prevented, name, settings
function GridStatusHealingReduced:UNIT_AURA(unit)
	if not UnitInRaid(unit) or UnitInParty(unit) then return end

	prevented = false
	reduced = false

	for i = 1, 40 do
		name = UnitDebuff(unit, i)
		if not name then
			break
		end
		if healingPreventionDebuffs[name] then
			prevented = true
			break
		end
		if healingReductionDebuffs[name] then
			reduced = true
			break
		end
	end

	if prevented then
		settings = db.alert_healingPrevented
		self.core:SendStatusGained(UnitName(unit), "alert_healingPrevented", settings.priority, (settings.range and 40), settings.color, settings.text)
	else
		self.core:SendStatusLost(UnitName(unit), "alert_healingPrevented")
	end
	if reduced then
		settings = db.alert_healingReduced
		self.core:SendStatusGained(UnitName(unit), "alert_healingReduced", settings.priority, (settings.range and 40), settings.color, settings.text)
	else
		self.core:SendStatusLost(UnitName(unit), "alert_healingReduced")
	end
end
--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds statuses to Grid for debuffs which reduce or prevent healing received.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info7364-GridStatusHealingReduced.html
	See README for license terms and additional information.
----------------------------------------------------------------------]]

--[[--------------------------------------------------------------------
	To-Do:

	Add translations for esES, esMX, and frFR locales.

	Improve debuff scanning efficiency by only looking for debuffs that
	can be applied in the current zone. i.e. don't scan for Nefarian's
	Veil of Shadow debuff when the player is in Durotar.
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
	[GetSpellInfo(19434)] = true,		-- Aimed Shot, -50%
	[GetSpellInfo(40599)] = true,		-- Arcing Smash (Gurtogg Bloodboil - Black Temple), -50%
--	[GetSpellInfo(23230)] = true,		-- Blood Fury (Orc racial skill), -50%					-- REMOVED in WoW 3.0
	[GetSpellInfo(23169)] = true,		-- Brood Affliction: Green (Chromaggus - Blackwing Lair), -50%
	[GetSpellInfo(34073)] = true,		-- Curse of the Bleeding Hollow (Bleeding Hollow orcs - Hellfire Peninsula), -15%
	[GetSpellInfo(13583)] = true,		-- Curse of the Deadwood (Deadwood furbolgs - Felwood), -50%
	[GetSpellInfo(45347)] = true,		-- Dark Touched (Lady Sacrolash - Sunwell Plateau), -4% per stack, up to 25
	[GetSpellInfo(36023)] = true,		-- Deathblow (Shattered Hand Savage - Shattered Halls), -50%
--	[GetSpellInfo(36054)] = true,		-- Deathblow (Shattered Hand Savage - Shattered Halls), -50%
	[GetSpellInfo(34625)] = true,		-- Demolish (Negatron - Netherstorm), -75%
	[GetSpellInfo(34366)] = true,		-- Ebon Poison (Blackfang Tarantula - The Black Morass), -25%
	[GetSpellInfo(32378)] = true,		-- Filet (Spectral Chef - Karazhan), -50%
	[GetSpellInfo(19716)] = true,		-- Gehennas' Curse (Gehennas - Molten Core) - 75%
--	[GetSpellInfo(9035)]  = true,		-- Hex of Weakness, -20%								-- REMOVED in WoW 3.0
	[GetSpellInfo(36917)] = true,		-- Magma-Thrower's Curse (Sulfuron Magma-Thrower - The Arcatraz), -50%
	[GetSpellInfo(22859)] = true,		-- Mortal Cleave (High Priestess Thekal - Zul'Gurub), -50%
	[GetSpellInfo(12294)] = true,		-- Mortal Strike, -50%
	[GetSpellInfo(25646)] = true,		-- Mortal Wound (Temporus - The Black Morass), -10% per stack, up to 7
	[GetSpellInfo(28776)] = true,		-- Necrotic Poison (Maexxna - Naxxramas), -90%
	[GetSpellInfo(30423)] = true,		-- Nether Portal - Dominance (Netherspite - Karazhan), -1% per stack, up to 99
	[GetSpellInfo(45885)] = true,		-- Shadow Spike (Kil'jaeden - Sunwell Plateau), -50%
	[GetSpellInfo(35189)] = true,		-- Solar Strike (Bloodwarder Slayer - The Mechanar), -50%
	[GetSpellInfo(32315)] = true,		-- Soul Strike (Ethereal Crypt Raider - Mana-Tombs), -50%
	[GetSpellInfo(32858)] = true,		-- Touch of the Forgotten (Auchenai Soulpriest - Auchenai Crypts), -345
--	[GetSpellInfo(32377)] = true,		-- Touch of the Forgotten (Auchenai Soulpriest - Auchenai Crypts), -690 -- DUPLICATE; heroic version of above
	[GetSpellInfo(7068)]  = true,		-- Veil of Shadow (Nefarian - Blackwing Lair), -75%
	[GetSpellInfo(44534)] = true,		-- Wretched Strike (Wretched Bruiser - Magister's Terrace), -50%
	[GetSpellInfo(13218)] = true,		-- Wound Poison, -10% per stack, up to 5
}

local healingPreventionDebuffs = {
	[GetSpellInfo(41292)] = true,		-- Aura of Suffering (Essence of Suffering - Black Temple)
	[GetSpellInfo(45996)] = true,		-- Darkness (M'uru - Sunwell Plateau)
	[GetSpellInfo(30843)] = true,		-- Enfeeble (Prince Malchezaar - Karazhan)
}

----------------------------------------------------------------

GridStatusHealingReduced = GridStatus:NewModule("GridStatusHealingReduced")

local GridStatusHealingReduced = GridStatusHealingReduced
local UnitDebuff, UnitName, UnitInParty, UnitInRaid = UnitDebuff, UnitName, UnitInParty, UnitInRaid
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

local i, reduced, prevented, name, settings
function GridStatusHealingReduced:UNIT_AURA(unit)
	if not UnitInRaid(unit) or UnitInParty(unit) then return end

	prevented = false
	reduced = false

	i = 1
	while true do
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
		i = i + 1
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
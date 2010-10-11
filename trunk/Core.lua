--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Adds aggregate statuses to Grid for debuffs which reduce or prevent healing received.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Alyssa "Phanx" Kinley
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

local function GetSpellName(id)
	local name = GetSpellInfo(id)
	return name or ""
end

-- Debuffs which reduce healing received
local ReductionDebuffs = {
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
	[GetSpellName(70671)] = true, -- Leeching Rot -- 70710 Heroic
	[GetSpellName(36917)] = true, -- Magma-Thrower's Curse
	[GetSpellName(48301)] = true, -- Mind Trauma
	[GetSpellName(22859)] = true, -- Mortal Cleave
	[GetSpellName(12294)] = true, -- Mortal Strike (Warriors)
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
	[GetSpellName(13218)] = true, -- Wound Poison (Rogues)
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
local PreventionDebuffs = {
	[GetSpellName(41292)] = true, -- Aura of Suffering
	[GetSpellName(45996)] = true, -- Darkness
	[GetSpellName(59513)] = true, -- Embrace of the Vampyr
	[GetSpellName(30843)] = true, -- Enfeeble
	[GetSpellName(55593)] = true, -- Necrotic Aura
}

------------------------------------------------------------------------

local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID

local enabled = 0

local function debug(str)
	print("|cffff9933GridStatusHealingReduced:|r " .. str)
end

local valid = { player = true, pet = true, vehicle = true }
for i = 1, 5 do
	valid["party" .. i] = true
	valid["partypet" .. i] = true
end
for i = 1, 40 do
	valid["raid" .. i] = true
	valid["raidpet" .. i] = true
end

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

	self:RegisterStatus("alert_healingReduced", HEALING_REDUCED, nil, true)
	self:RegisterStatus("alert_healingPrevented", HEALING_PREVENTED, nil, true)
end

function GridStatusHealingReduced:OnEnable()
--	debug("OnEnable")
	self.super.OnEnable(self)
end

function GridStatusHealingReduced:OnStatusEnable(status)
--	debug("OnStatusEnable, " .. status)

	enabled = enabled + 1
	self:RegisterEvent("UNIT_AURA", "UpdateUnit")
	self:UpdateAllUnits()
end

function GridStatusHealingReduced:OnStatusDisable(status)
--	debug("OnStatusDisable, " .. status)

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

	local i = 1
	local prevented, reduced
	local settings, name, icon, count, duration, expirationTime, _
	while true do
		name, _, icon, count, _, duration, expirationTime = UnitDebuff(unit, i)
		if not name then
			break
		end
		if duration then
			if PreventionDebuffs[name] then
				prevented = true
				reduced = false
				break
			elseif not reduced and ReductionDebuffs[name] then
				reduced = true
			end
		end
		i = i + 1
	end

	if prevented then
	--	debug("SendStatusGained")
		settings = self.db.profile.alert_healingPrevented
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingPrevented", settings.priority, (settings.range and 40), settings.color, settings.text, nil, nil, icon, expirationTime and (expirationTime - duration), count)
	else
	--	debug("SendStatusLost")
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingPrevented")
	end

	if reduced then
	--	debug("SendStatusGained")
		settings = self.db.profile.alert_healingReduced
		self.core:SendStatusGained(UnitGUID(unit), "alert_healingReduced", settings.priority, (settings.range and 40), settings.color, settings.text, nil, nil, icon, expirationTime and (expirationTime - duration), count)
	else
	--	debug("SendStatusLost")
		self.core:SendStatusLost(UnitGUID(unit), "alert_healingReduced")
	end
end

------------------------------------------------------------------------
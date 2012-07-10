--[[--------------------------------------------------------------------
	GridStatusHealingReduced
	Grid plugin to show debuffs which reduce or prevent healing received.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info7364-GridStatusHealingReduced.html
	http://www.curse.com/addons/wow/gridstatushealingreduced
----------------------------------------------------------------------]]

local _, ns = ...

ns.ReductionDebuffs = {
	--[[ CLASSIC - RAID ]]
	23169,  -- Brood Affliction: Green (Chromaggus in Blackwing Lair)
	19716,  -- Gehennas' Curse (Gehennas in Molten Core)
	22687,  -- Veil of Shadow (Nefarian in Blackwing Lair)

	--[[ CLASSIC - PARTY ]]
	27580,  -- Mortal Strike (Theldren in Blackrock Depths)
	17820,  -- Veil of Shadow (Lord Alexei Barov in Scholomance)

	--[[ CLASSIC - SOLO ]]
	13583,  -- Curse of the Deadwood (Deadwood furbolgs in Felwood)
	83930,  -- Grog-soaked Blade (Fleet Master Firallon in The Cape of Stranglethorn)

	--[[ THE BURNING CRUSADE - RAID ]]
	40599,  -- Arcing Smash (Gurtogg Bloodboil in Black Temple)
	41478,  -- Dampen Magic (High Nethermancer Zerevor in Black Temple)
	45347,  -- Dark Touched (Lady Sacrolash in Sunwell Plateau)
	38572,  -- Mortal Cleave (Vashj'ir Honor Guard in Serpentshrine Cavern)
	29572,  -- Mortal Strike (Lord Robin Daris in Karazhan)
	46296,  -- Necrotic Poison (Cataclysm Hound in Sunwell Plateau)
	30423,  -- Nether Portal - Dominance (Netherspite in Karazhan)
	39665,  -- Wound Poison (Illidari Boneslicer; Shadowmoon Weapon Master in Black Temple)

	--[[ THE BURNING CRUSADE - PARTY ]]
	36023,  -- Deathblow (Shattered Hand Savage in The Shattered Halls)
	36054,  -- Deathblow (Shattered Hand Savage in The Shattered Halls)
	34366,  -- Ebon Poison (Blackfang Tarantula in The Black Morass)
	59513,  -- Embrace of the Vampyr (Prince Taldaram in Ahn'kahet: The Old Kingdom)
	36917,  -- Magma-Thrower's Curse (Sulfuron Magma-Thrower in The Arcatraz)
	31911,  -- Mortal Strike (Lieutenant Drake in Old Hillsbrad Foothills)
	37335,  -- Mortal Strike (Stolen Soul in Auchenai Crypts)
	44268,  -- Mortal Strike (Warlord Salaris in Magisters' Terrace)
	30641,  -- Mortal Wound (Watchkeeper Gargolmar in Hellfire Ramparts)
	36814,  -- Mortal Wound (Watchkeeper Gargolmar in Hellfire Ramparts)
	31464,  -- Mortal Wound (Temporus in The Black Morass)
	36693,  -- Necrotic Poison (Entropic Eye in The Arcatraz)
	35189,  -- Solar Strike (Bloodwarder Slayer in The Mechanar)
	32858,  -- Touch of the Forgotten (Auchenai Soulpriest in Auchenai Crypts)
	38377,  -- Touch of the Forgotten (Auchenai Soulpriest in Auchenai Crypts)
	44534,  -- Wretched Strike (Wretched Bruiser in Magisters' Terrace)

	--[[ THE BURNING CRUSADE - SOLO ]]
	34073,  -- Curse of the Bleeding Hollow (Bleeding Hollow Necrolyte in Hellfire Peninsula)
	34625,  -- Demolish (Negatron in Netherstorm)
	32378,  -- Filet (Warmaul Chef Bufferlo in Nagrand)
	30984,  -- Wound Poison (Chieftain Mummaki in Zangarmarsh)

	--[[ WRATH OF THE LICH KING - RAID ]]
	65883,  -- Aimed Shot (Alyssia Moonstalker; Ruj'kah in Trial of the Crusader)
	63038,  -- Dark Volley (Guardian of Yogg-Saron in Ulduar)
	70671,  -- Leeching Rot (Vampiric Fiend in Icecrown Citadel)
	70710,  -- Leeching Rot (Empowered Vampiric Fiend in Icecrown Citadel)
	65926,  -- Mortal Strike (Shocuul; Narrhok Steelbreaker in Trial of the Crusader)
	67542,  -- Mortal Strike (Marshal Jacob Alerius; Mokra the Skullcrusher in Trial of the Crusader)
	71552,  -- Mortal Strike (Captain Grondel in Icecrown Citadel)
	28467,  -- Mortal Wound (Unstoppable Abomination in Naxxramas)
	54378,  -- Mortal Wound (Gluth in Naxxramas)
	71127,  -- Mortal Wound (Precious; Stinky in Icecrown Citadel)
	69674,  -- Mutated Infection (Rotface in Icecrown Citadel)
	28776,  -- Necrotic Poison (Maexxna; Maexxna Spiderling in Naxxramas)
	54121,  -- Necrotic Poison (Maexxna; Maexxna Spiderling in Naxxramas)
	70588,  -- Suppression (Suppresser in Icecrown Citadel)
	53803,  -- Veil of Shadow (Dread Creeper in Naxxramas)
	28440,  -- Veil of Shadow (Dread Creeper in Naxxramas)
	65962,  -- Wound Poison (Irieth Shadowstep; Maz'dinah in Trial of the Crusader)
	69651,  -- Wounding Strike (Kor'kron Sergeant; Skybreaker Sergeant in Icecrown Citadel)

	--[[ WRATH OF THE LICH KING - PARTY ]]
	48871,  -- Aimed Shot (Ymirjar Flesh Hunter in Utgarde Pinnacle)
	59243,  -- Aimed Shot (Ymirjar Flesh Hunter in Utgarde Pinnacle)
	48291,  -- Fetid Rot (King Ymiron in Utgarde Pinnacle)
	59300,  -- Fetid Rot (King Ymiron in Utgarde Pinnacle)
	57789,  -- Mortal Strike (Twisted Visage in Ahn'kahet: The Old Kingdom)
	54716,  -- Mortal Strikes (Drakkari Colossus in Gundrak)
	59455,  -- Mortal Strikes (Drakkari Colossus in Gundrak)
	59265,  -- Mortal Wound (Frenzied Worgen in Utgarde Pinnacle)
	59525,  -- Ray of Pain (Moragg; Chaos Watcher in The Violet Hold)
	54525,  -- Shroud of Darkness (Zuramat the Obliterator in The Violet Hold)
	59746,  -- Shroud of Darkness (Zuramat the Obliterator; Void Lord in The Violet Hold)
	54074,  -- Wound Poison (Phantasmal Murloc in The Oculus)
	52771,  -- Wounding Strike (Chrono-Lord Epoch in The Culling of Stratholme)
	58830,  -- Wounding Strike (Chrono-Lord Epoch in The Culling of Stratholme)

	--[[ WRATH OF THE LICH KING - SOLO ]]
	54615,  -- Aimed Shot (Shandaral Hunter Spirit in Crystalsong Forest)
	60626,  -- Necrotic Strike (Undying Minion in Icecrown)

	--[[ CATACLYSM - RAID ]]
	100526, -- Blistering Wound (Flamewaker Subjugator in Firelands)
	83908,  -- Malevolent Strikes (Halfus Wyrmbreaker in The Bastion of Twilight)
	103002, -- Mortal Strike (Twilight Bruiser in Hour of Twilight)
	80390,  -- Mortal Strike (Drakonid Slayer in Blackwing Descent)
	43441,  -- Mortal Strike (Hex Lord Malacrass in Zul'Aman)
	99476,  -- The Widow's Kiss (Beth'tilac in Firelands)
	99506,  -- The Widow's Kiss (Beth'tilac in Firelands)
	43461,  -- Wound Poison (Hex Lord Malacrass in Zul'Aman)

	--[[ CATACLYSM PARTY ]]
	76189,  -- Crepuscular Veil (Shadow of Obsidius in Blackrock Caverns)
	93956,  -- Cursed Veil (Baron Silverlaine in Shadowfang Keep)
	91801,  -- Mortal Strike (Wailing Guardsman in Shadowfang Keep)
	93675,  -- Mortal Wound (Lord Godfrey in Shadowfang Keep)
	23224,  -- Veil of Shadow (Baron Silverlaine in Shadowfang Keep)
	83926,  -- Veil of Shadow (Vicious Mindlasher in Throne of the Tides)
	75571,  -- Wounding Strike (Rom'ogg Bonecrusher in Blackrock Caverns)

	--[[ CATACLYSM SOLO ]]
	86816,  -- Giant's Bane (Dragul Giantbutcher in Deepholm)

	--[[ PLAYERS ]]
	30213,  -- Legion Strike	Warlock Felguard)
	54680,  -- Monstrous Bite (Hunter Devilsaur)
	115625, -- Mortal Cleave (Warlock Wrathguard)
	115804, -- Mortal Wounds (Warrior)
	82654,  -- Widow Venom (Hunter)
	8680,   -- Wound Poison (Rogue)

	--[[ PVP NPCs ]]
	76727,  -- Mortal Strike (Twilight Armsmaster in Grim Batol)

	--[[ VARIOUS NPCS ]]
	78841,  -- Aimed Shot
	43410,  -- Chop
	44475,  -- Magic Dampening Field
	22859,  -- Mortal Cleave
	32736,  -- Mortal Strike
	13737,  -- Mortal Strike
	15708,  -- Mortal Strike
	16856,  -- Mortal Strike
	17547,  -- Mortal Strike
	19643,  -- Mortal Strike
	24573,  -- Mortal Strike
	35054,  -- Mortal Strike
	38770,  -- Mortal Wound
	48137,  -- Mortal Wound
	32315,  -- Soul Strike
	7068,   -- Veil of Shadow
	69633,  -- Veil of Shadow
	36974,  -- Wound Poison

	--[[ UNKNOWN ]]
	118228, -- Aimed Shot
	126195, -- Dirty Mouth
	129564, -- Fiery Strike
	39595,  -- Mortal Cleave
	61042,  -- Mortal Smash
	40220,  -- Mortal Strike
	120436, -- Mortal Strike
	112055, -- Orb of Power
	121164, -- Orb of Power
	121175, -- Orb of Power
	121176, -- Orb of Power
	121177, -- Orb of Power
	127959, -- Orb of Power
	97857,  -- Phoenix Flame
	125353, -- Rank Bite
	128964, -- Rune of Suffering
	121910, -- Scurvy
	45885,  -- Shadow Spike
	119354, -- Sik'thik Strike
	60084,  -- The Veil of Shadows
	115195, -- Toxic Shock
	123655, -- Traumatic Blow
	68881,  -- Unstable Water Nova
	24674,  -- Veil of Shadow
}

ns.PreventionDebuffs = {
	--[[ THE BURNING CRUSADE - RAID ]]
	41292,  -- Aura of Suffering (Essence of Suffering in Black Temple)
	30843,  -- Enfeeble (Prince Malchezaar in Karazhan)

	--[[ WRATH OF THE LICH KING - RAID ]]
	55593,  -- Necrotic Aura (Loatheb in Naxxramas)

	--[[ CATACLYSM - RAID ]]
	82170,  -- Corruption: Absolute (Cho'gall in The Bastion of Twilight)
	92787,  -- Engulfing Darkness (Maloriak in Blackwing Descent)
	82890,  -- Mortality (Chimaeron in Blackwing Descent
	85576,  -- Withering Winds (Anshal in Throne of the Four Winds)

	--[[ CATACLYSM - PARTY ]]
	76903,  -- Anti-Magic Prison (Void Seeker in Halls of Origination)

	--[[ CATACLYSM - SOLO ]]
	101497,  -- Aura of Deth'spair (Deth'tilac in Molten Front)
	101340,  -- Suffocating Prey (Kirix in Molten Front)

	--[[ UNKNOWN ]]
	114078,  -- HUGE, SHARP TEETH!
}
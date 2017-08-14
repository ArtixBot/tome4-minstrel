-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2017 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Particles = require "engine.Particles"
getBirthDescriptor("class", "Rogue").descriptor_choices.subclass["Minstrel"] = "allow"

newBirthDescriptor{
	type = "subclass",
	name = "Minstrel",
	desc = {
		"Armed with blade and wit, the Minstrel dances throughout the battlefield with daggers in hand while singing powerful ballads.",
		"Though lightly armored and armed, these versatile bards use the power of song to turn the tide of battle in their favor.",
		"Inspring tunes bolster one's vital stats, while harsh solos incapacitate foes and lower their resistances.",
		"A minstrel's greatest weapon is his or her voice; if silenced, minstrels possess few relatively little combat ability compared to other, more well-prepared classes.",
		"Their most important stats are: Cunning, Willpower, and Dexterity",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +2 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +3 Willpower, +2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -1"
	},
	power_source = {technique=true},
	stats = { dex=2, wil=3, cun=2 },
	talents_types = {
		-- Class Skills
		["technique/duelist"]={true, 0.3},
		["technique/musical-combat"]={true, 0.3},
		["technique/battle-ballads"]={true, 0.3},
		["technique/wit"]={true, 0.3},
		["technique/luck-of-the-draw"]={false, 0.3},
		["cunning/artifice"]={false, 0.3},
		
		-- Generic Skills
		["technique/combat-training"]={true, 0.3},
		["technique/performance-arts"]={true, 0},
		["technique/mobility"]={true, 0.3},
		["cunning/survival"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_KNIFE_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.equip{ id=true,
			{type="weapon", subtype="dagger", name = "iron dagger", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="dagger", name = "iron dagger", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.inventory{ id=true,
			{type="jewelry", subtype="amulet", name = "shattered songstone", autoreq=true, ego_chance=-1000, ego_chance=-1000},	
		},
	},
	copy_add = {
		life_rating = -1,
	},
}

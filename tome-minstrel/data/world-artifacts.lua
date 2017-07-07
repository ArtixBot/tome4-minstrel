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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

--- Load additional artifacts
for def, e in pairs(game.state:getWorldArtifacts()) do
	importEntity(e)
	print("Importing "..e.name.." into world artifacts")
end

-- This file describes artifacts not bound to a special location, they can be found anywhere

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Shattered Songstone", color = colors.WHITE, image = "object/artifact/feathersteel_amulet.png",
	unided_name = "shattered gray amulet",
	desc = [[Though seemingly broken beyond repair, this amulet still possesses remnants of its original power.]],
	level_range = {1, 5},
	rarity = 20,
	cost = 50,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 1 },
		talents_types_mastery = {
			["technique/performance-arts"] = 0.1,
		},
	},
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {technique=true},
	unique = true,
	name = "Dismas's Shameful Locket",		-- Totally not inspired by Darkest Dungeon's Crimson Court expansion.
	color = colors.GRAY, image = "object/artifact/shield_unsetting_sun.png",
	unided_name = "weathered locket",
	desc = [[A weathered locket held by the infamous highwayman Dismas, who fell into despair upon taking the life of an unnamed mother and child. As to why Dismas kept such a powerful reminder of his sins, one can only assume he sought some form of redemption.
	
"A reflex - I didn't mean to..."]],
	level_range = {28, 40},
	rarity = 200,
	cost = 350,
	material_level = 4,
	wielder = {
		inc_stats = {[Stats.STAT_DEX] = 5},
		combat_atk=20,
		combat_apr=20,
		combat_physcrit=10,
		combat_critical_power=20,
		combat_mentalresist=-25,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_PERFECT_STRIKE, level = 2, power = 20 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {technique=true},
	unique = true,
	name = "Jactator's Blowing Horn",
	color = colors.GRAY, image = "object/artifact/blightstopper.png",
	unided_name = "overgrown blowing horn",
	desc = [[Covered in plant matter from decades of idleness, this blowing horn was the prized possession of Jactator, the Ur'kul Mercenary Company's first (and only) standard bearer. Those unfortunate enough to serve with Jactator bemoaned his limitless capacity for chitter-chatter and gossip.]],
	level_range = {28, 40},
	rarity = 200,
	cost = 350,
	material_level = 4,
	wielder = {
		max_stamina = 100,
		stamina_regen = 5,
		fatigue = -10,
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_SECOND_WIND, level = 2, power = 25 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {technique=true},
	unique = true,
	name = "Bandolier of Cards",
	color = colors.GRAY, image = "object/artifact/pharao_ash.png",
	unided_name = "bandolier of cards",
	desc = [[This bandolier was said to have once been used by Nemelex Xobeh, the (in)famous trickster god. It holds multiple antiquated decks, none of which you are familiar with.]],
	level_range = {28, 40},
	rarity = 200,
	cost = 350,
	material_level = 4,
	wielder = {
		inc_stats = {[Stats.STAT_CUN] = 10},
		max_stamina = 100,
		stamina_regen = 5,
		fatigue = -10,
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_SECOND_WIND, level = 2, power = 25 },
}

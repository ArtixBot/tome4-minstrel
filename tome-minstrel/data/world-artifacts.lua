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

newEntity{ base = "BASE_KNIFE", define_as = "TRICK_LUTE",
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Victario's Trick Lute",
	color = colors.GRAY, image = "object/victario_trick_lute.png",
	unided_name = "strangely shaped lute",
	moddable_tile = "special/%s_victarios_trick_lute",
	moddable_tile_big = true,
	desc = [[Victario was a famed minstrel whose tales of adventure and heroism entertained thousands in Maj'Eyal. His blessed lute-smaller than most stringed devices-served another purpose as a self-defense weapon to strike down bandits and marauders.]],
	level_range = {28, 40},
	rarity = 200,
	require = { stat = { dex=24, wil=32, cun=32 }, },
	cost = 350,
	material_level = 4,
		combat = {
		dam = 32,
		apr = 8,
		physcrit = 10,
		dammod = {cun=0.35, str=0.20, dex=0.35},
		special_on_crit = {desc="plays a power chord, dazing the target", fct=function(combat, who, target)
			if target:canBe("stun") then
				local check = math.max(who:combatSpellpower(), who:combatMindpower(), who:combatAttack())
				target:setEffect(target.EFF_DAZED, 4, {src=who, apply_power=check})
			end
		end},
	},
	wielder = {
		inc_stats = {[Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4,},
		talents_types_mastery = {
			["technique/battle-ballads"] = 0.1,
			["technique/performance-arts"] = 0.1,
		},
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_STARSTRIKING_SOLO, level = 1, power = 50 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {nature = true},
	unique=true, rarity=240, image = "object/artifact/honeywood_chalice.png",
	type = "charm",
	name = "Victario's Tasting Chalice",
	unided_name = "tasting chalice",
	color = colors.BROWN,
	level_range = {28, 40},
	desc = [[In his early days, Victario served as a taster for a duke he considered "scummier than a ship's ratspawn." After one too many near-fatal poisonings by the duke himself, Victario murdered his employer and took the bronze chalice for himself.]],
	cost = 320,
	material_level = 4,
	wielder = {
		combat_physresist = 15,
		inc_stats = {[Stats.STAT_WIL] = 8,},
		inc_damage={[DamageType.POISON] = 18, [DamageType.ACID] = 18},
		resists={[DamageType.NATURE] = 20,},
		poison_immune = 0.35,
		
	},
}
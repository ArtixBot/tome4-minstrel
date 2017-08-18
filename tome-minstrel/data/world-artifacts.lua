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
	require = { stat = { dex=24, wil=28, cun=28 }, },
	cost = 350,
	material_level = 4,
		combat = {
		dam = 38,
		apr = 8,
		physcrit = 10,
		dammod = {cun=0.35, str=0.20, dex=0.35},
		special_on_crit = {desc="plays a power chord, dazing the target", fct=function(combat, who, target)
			if target:canBe("stun") then
				local check = math.max(who:combatSpellpower(), who:combatMindpower(), who:combatAttack())
				target:setEffect(target.EFF_DAZED, 6, {src=who, apply_power=check})
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
	set_list = { {"define_as","TASTING_CHALICE"} },
	set_desc = {
		lute = "'Stay a while, and listen to the grand tales of Victario, the Harbinger of Everlasting Story!'",
	},
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_stamina"}, 35)
		self:specialSetAdd({"wielder","confusion_immune"}, 0.25)
		self:specialSetAdd({"wielder","silence_immune"}, 0.25)
		game.logSeen(who, "#GOLD#You hear a faint laugh as Victario's belongings are united.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#GREY#The laugh fades away.")
	end,
}

newEntity{ base = "BASE_TOOL_MISC", define_as = "TASTING_CHALICE",
	power_source = {technique = true, nature = true},
	unique=true, rarity=240, image = "object/artifact/honeywood_chalice.png",
	name = "Victario's Tasting Chalice",
	unided_name = "tasting chalice",
	color = colors.BROWN,
	level_range = {28, 40},
	require = { stat = { dex=24, wil=28, cun=28 }, },
	desc = [[In his early days, Victario served as a taster for a duke he considered "scummier than a ship's ratspawn." After one too many near-fatal poisonings by the duke, Victario murdered his employer and took the bronze chalice for himself.]],
	cost = 320,
	material_level = 4,
	wielder = {
		combat_physresist = 15,
		inc_stats = {[Stats.STAT_WIL] = 8,},
		melee_project={[DamageType.POISON] = 18, [DamageType.ACID] = 18},
		on_melee_hit={[DamageType.POISON] = 24, [DamageType.ACID] = 24},
		resists={[DamageType.NATURE] = 20,},
		poison_immune = 0.35,	
	},
	set_list = { {"define_as","TRICK_LUTE"} },
	set_desc = {
		chalice = "'Stay awhile, and listen to the grand tales of Victario, the Harbinger of Everlasting Story!'",
	},
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","on_melee_hit"}, {[engine.DamageType.CORRUPTED_BLOOD]=24, [engine.DamageType.ACID_DISARM]=24})
		self:specialSetAdd({"wielder","melee_project"}, {[engine.DamageType.CORRUPTED_BLOOD]=18, [engine.DamageType.ACID_DISARM]=18})
	end,
	-- Currently bugged for some inexplicable reason involving 'T_GLOBAL_CD'; do not activate.
	--max_power = 1, power_regen = 0,
	--use_talent = { id = Talents.T_TEMPTING_GOBLET, level = 1, power = 1 },
}
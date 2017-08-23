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
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "FINALE_DEBUFF", image = "talents/finale.png",
	desc = "Exhausted",
	long_desc = function(self, eff) return ("Exhausted from performing a Finale! Global action speed reduced by 25%.") end,
	type = "other",
	subtype = { slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# is exhausted!", "+Exhausted" end,
	on_lose = function(self, err) return "#Target# is no longer exhausted.", "-Exhausted" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "INVULNERABLE", image = "talents/forcefield.png",
	desc = "Invulnerable",
	long_desc = function(self, eff) return "This target is unaffected by any source of damage." end,
	type = "other",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("invulnerable", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.tmpid)
	end,
}

newEffect{
	name = "ACE_OF_SPADES", image = "talents/ace_in_the_hole.png",
	desc = "Ace of Spades",
	long_desc = function(self, eff) return "Your next card invocation is significantly more powerful." end,
	type = "other",
	subtype = {arcane = true},
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") + 1.00)
	end,
	deactivate = function(self, eff)
		self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") - 1.00)
	end,
}

newEffect{
	name = "ACE_OF_CLUBS", image = "effects/ace_of_clubs.png",
	desc = "Ace of Clubs",
	long_desc = function(self, eff) return "Ace of Clubs drawn! +250 Luck." end,
	type = "other",
	subtype = {arcane = true},
	status = "beneficial",
	on_gain = function(self, err) return "#Target#'s becomes extraordinarily lucky!", "+Ace of Clubs" end,
	on_lose = function(self, err) return "#Target#'s luck returns to normal.", "-Ace of Clubs" end,
	parameters = {},
	activate = function(self, eff)
		eff.luk = self:addTemporaryValue("inc_stats", {[Stats.STAT_LCK] = 250,})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.luk)
	end,
}

newEffect{
	name = "NECROMUTATION", image = "talents/skeleton.png",
	desc = "Necromutation",
	long_desc = function(self, eff) return ("Temporarily mutated into a demilich, reducing global speed by 50%% and negating all healing. The following bonuses are conferred:\n\nDeath threshold: -%d\nCold and Darkness affinity: +%d%%\nArmor: +%d\nSaves and powers: +%d\nArmor hardiness set to 100%%. Poison, disease, and stun immunity."):format(eff.heroism, eff.affinity, eff.armor, eff.power) end,
	type = "other",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = { heroism = 10, affinity = 10, armor = 10, power = 10},
	on_gain = function(self, err) return "#Target# morphs into a demilich!", "+Necromutation" end,
	on_lose = function(self, err) return "#Target# reverts back to normal.", "-Necromutation" end,
	activate = function(self, eff)
		eff.spddown = self:addTemporaryValue("global_speed_add", -1)	-- Slow power is scaled down, so -100% global speed here equates to -50% global speed in-game.
		eff.healmod = self:addTemporaryValue("healing_factor", -999)
		
		eff.armorhard = self:addTemporaryValue("combat_armor_hardiness", 100)
		eff.threshold = self:effectTemporaryValue(eff, "die_at", -eff.heroism)
		self:effectTemporaryValue(eff, "stun_immune", 100)
		self:effectTemporaryValue(eff, "daze_immune", 100)
		self:effectTemporaryValue(eff, "disease_immune", 100)
		self:effectTemporaryValue(eff, "poison_immune", 100)
		self:effectTemporaryValue(eff, "combat_armor", eff.armor)
		self:effectTemporaryValue(eff, "combat_physresist", eff.power)
		self:effectTemporaryValue(eff, "combat_spellresist", eff.power)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.power)
		self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.COLD]=eff.affinity})
		self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.DARKNESS]=eff.affinity})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor_hardiness", eff.armorhard)
		self:removeTemporaryValue("global_speed_add", eff.spddown)
		self:removeTemporaryValue("healing_factor", eff.healmod)
	end,
}

newEffect{
	name = "BULWARK_OF_FAITH", image = "effects/bulwark_of_faith.png",
	desc = "Bulwark of Faith",
	long_desc = function(self, eff) return ("Resilience has been enhanced, increasing all resistances by 55% and affinity for physical damage by 25% but rooting you in place.") end,
	type = "other",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# becomes a bulwark of faith!", "+Bulwark of Faith" end,
	on_lose = function(self, err) return "#Target# is no longer resilient.", "-Bulwark of Faith" end,
	activate = function(self, eff)
		eff.resist = self:addTemporaryValue("resists", {all=55})
		self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.PHYSICAL]=25})
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resist)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "FORTUNES_GAMBIT", image = "talents/lucky_day.png",
	desc = "Fortune's Gambit",
	long_desc = function(self, eff) return ("Fortunes have been altered, impacting Luck by %d points."):format(eff.power) end,
	type = "other",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#'s luck changes!", "+Fortune's Gambit" end,
	on_lose = function(self, err) return "#Target#'s luck returns to normal.", "-Fortune's Gambit" end,
	activate = function(self, eff)
		eff.luk = self:addTemporaryValue("inc_stats", {[Stats.STAT_LCK] = math.floor(eff.power),})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.luk)
	end,
}
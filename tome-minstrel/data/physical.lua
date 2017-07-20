-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "GARKULS_WRATH", image = "talents/bloodbath.png",
	desc = "Garkul's Wrath",
	long_desc = function(self, eff) return ("Seized by unfathomable wrath! Maximum life increased by %d, all damage dealt increased by %d%%, attack speed increased by %d%%, and reduces all damage taken  by %d%%."):format(eff.hp, eff.power, eff.atkspd*100, eff.atkres) end,
	type = "physical",
	subtype = { morale=true },
	status = "beneficial",
	parameters = {hp = 10, power = 10, atkspd = 10, atkres = 10},
	on_gain = function(self, err) return "#Target# bellows a guttural, fell laughter!", "+Garkul's Wrath" end,
	on_lose = function(self, err) return "#Target# is no longer under malevolent possession.", "-Garkul's Wrath" end,
	activate = function(self, eff)
		eff.max_life = self:addTemporaryValue("max_life", eff.hp)
		eff.life = self:addTemporaryValue("life",eff.hp)
		
		eff.bonus_damage = self:addTemporaryValue("inc_damage", {all=eff.power})
		eff.speed = self:addTemporaryValue("combat_physspeed", eff.atkspd)
		eff.res = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.max_life)
		self:removeTemporaryValue("inc_damage", eff.bonus_damage)
		self:removeTemporaryValue("combat_physspeed", eff.speed)
		self:removeTemporaryValue("resists", eff.res)
	end,
}

newEffect{
	name = "INCIPIENT_HEROISM", image = "talents/dream_crusher.png",
	desc = "Incipient Heroism",
	long_desc = function(self, eff) return ("Infused with heroic spirit, boosting all stats by %d."):format(eff.power) end,
	type = "physical",
	subtype = { morale=true },
	status = "beneficial",
	parameters = {power = 10},
	on_gain = function(self, err) return "#Target# is rapidly infused with heroic spirit!", "+Incipient Heroism" end,
	on_lose = function(self, err) return "#Target# is no longer heroic.", "-Incipient Heroism" end,
	activate = function(self, eff)
		eff.boost = self:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_STR] = math.floor(eff.power),
			[Stats.STAT_DEX] = math.floor(eff.power),
			[Stats.STAT_MAG] = math.floor(eff.power),
			[Stats.STAT_WIL] = math.floor(eff.power),
			[Stats.STAT_CUN] = math.floor(eff.power),
			[Stats.STAT_CON] = math.floor(eff.power),
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.boost)
	end,
}

newEffect{
	name = "LUCKY_STAR", image = "talents/lucky_day.png",
	desc = "Lucky Star",
	long_desc = function(self, eff) return ("Blessed with incredible luck, gaining +%d luck, +%d%% critical hit chance, and %d flat damage reduction."):format(eff.power, eff.crit, eff.negate) end,
	type = "physical",
	subtype = { morale=true },
	status = "beneficial",
	parameters = {power = 10, crit = 10, negate = 10},
	on_gain = function(self, err) return "#Target# is blessed with incredible luck!", "+Lucky Star" end,
	on_lose = function(self, err) return "#Target# is no longer fortunate.", "-Lucky Star" end,
	activate = function(self, eff)
		eff.luk = self:addTemporaryValue("inc_stats", {[Stats.STAT_LCK] = math.floor(eff.power),})
		eff.critchance = self:addTemporaryValue("combat_generic_crit", eff.crit)
		eff.armor = self:addTemporaryValue("flat_damage_armor", {all = eff.negate})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.luk)
		self:removeTemporaryValue("combat_generic_crit", eff.critchance)
		self:removeTemporaryValue("flat_damage_armor", eff.armor)
	end,
}

newEffect{
	name = "TEMPO_DISRUPTION", image = "talents/symphonic_whirl.png",
	desc = "Tempo Disruption 1",
	long_desc = function(self, eff) return ("All damage dealt reduced by 20%. Effect will worsen over time.") end,
	type = "physical",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is disrupted!", "+Tempo 1" end,
	on_lose = function(self, err) return "#Target#'s disruption is exacerbated!", "+Tempo 2" end,
	activate = function(self, eff)
		eff.dam_penalty = self:addTemporaryValue("inc_damage", {all=-20})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_penalty)
		self:setEffect(self.EFF_TEMPO_DISRUPTION_II, 1, {})
	end,
}

newEffect{
	name = "TEMPO_DISRUPTION_II", image = "talents/symphonic_whirl.png",
	desc = "Tempo Disruption 2",
	long_desc = function(self, eff) return ("Confused (25% strength) and all damage dealt reduced by 40%. Effect will worsen over time.") end,
	type = "physical",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {},
	on_lose = function(self, err) return "#Target#'s disruption is further exacerbated!", "+Tempo 3" end,
	activate = function (self, eff)
		eff.dam_penalty = self:addTemporaryValue("inc_damage", {all=-40})
		eff.tmpid = self:addTemporaryValue("confused", 25)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_penalty)
		self:removeTemporaryValue("confused", eff.tmpid)
		self:setEffect(self.EFF_TEMPO_DISRUPTION_III, 1, {})
	end,
}

newEffect{
	name = "TEMPO_DISRUPTION_III", image = "talents/symphonic_whirl.png",
	desc = "Tempo Disruption 3",
	long_desc = function(self, eff) return ("Stunned, and all damage resistances reduced by 25%. While stunned, damage dealt is reduced by 60%, 3 random talents are put on cooldown, movement speed is reduced by 50% and talents do not cooldown.") end,
	type = "physical",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {},
	on_lose = function(self, err) return "#Target# is no longer disrupted.", "-Tempo 3" end,
	activate = function (self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)
		
		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
		end
		for i = 1, 3 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self:startTalentCooldown(t.id, 1) -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
		
		eff.res = self:addTemporaryValue("resists", {all=-25})
		
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
		self:removeTemporaryValue("resists", eff.res)
	end,
}

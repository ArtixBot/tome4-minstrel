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
	name = "SOLO_DEBUFF", image = "talents/solo.png",
	desc = "Unsteady",
	long_desc = function(self, eff) return ("This target has been knocked off balance, reducing Accuracy by %d."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target#'s thoughts have been derailed!", "+Unsteady" end,
	on_lose = function(self, err) return "#Target#'s is no longer unsteady.", "-Unsteady" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_atk", -eff.power)
	end,
}

newEffect{
	name = "MOXIE_BUFF", image = "talents/moxie.png",
	desc = "Unorthodox Solutions",
	long_desc = function(self, eff) return ("Prepared for anything! Defense increased by %d and all resists increased by %d%%."):format(eff.power, eff.res) end,
	type = "mental",
	subtype = { morale=true },
	status = "beneficial",
	parameters = {power=10, res=10},
	on_gain = function(self, err) return "#Target# is blessed with unnatural moxie!", "+Unorthodox Solutions" end,
	on_lose = function(self, err) return "#Target# is no longer moxious.", "-Unorthodox Solutions" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_def", eff.power)
		eff.resistsId = self:addTemporaryValue("resists", { all = eff.res })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsId)
	end,
}

newEffect{
	name = "CASTIGATED", image = "talents/diatribe_of_incapacitation.png",
	desc = "Castigated",
	long_desc = function(self, eff) return ("This target has been castigated, reducing all damage dealt by %d%%."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {power = 10},
	on_gain = function(self, err) return "#Target# is castigated, reducing combat prowess!", "+Castigated" end,
	on_lose = function(self, err) return "#Target#'s combat prowess is restored.", "-Catigated" end,
	activate = function(self, eff)
		eff.dam_pen = self:addTemporaryValue("inc_damage", {all=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_pen)
	end,
}

newEffect{
	name = "MENTAL_INSTABILITY", image = "talents/diatribe_of_incapacitation.png",
	desc = "Mental Instability",
	long_desc = function(self, eff) return ("Mentally unstable. Next Wit ability consumes this for additional effects.") end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "WIT_INFURIATED", image = "talents/mockery.png",
	desc = "Infuriated",
	long_desc = function(self, eff) return ("Infuriated! Damage dealt increased by %d%%. Accuracy and defense reduced by %d.\n\n#RED#Exploit#WHITE#: Cannot crit, and all resistances reduced by %d%%."):format(eff.power, eff.reduction, eff.resistdown) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = {power = 10, reduction = 10, exploit = false, resistdown = 10},
	on_gain = function(self, err) return "#Target# is infuriated!", "+Infuriated" end,
	on_lose = function(self, err) return "#Target# calms down.", "-Infuriated" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all=eff.power})
		self:effectTemporaryValue(eff, "combat_atk", -eff.reduction)
		self:effectTemporaryValue(eff, "combat_def", -eff.reduction)
		if eff.exploit then
			self:effectTemporaryValue(eff, "combat_generic_crit", -100)
			self:effectTemporaryValue(eff, "resists", {all = -eff.resistdown})
		end
	end,
	deactivate = function(self, eff)
	end,
}
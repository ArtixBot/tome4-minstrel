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

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
	rarity = 200,
	cost = 90,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 1 },
		talents_types_mastery = {
			["technique/performance-arts"] = 0.1,
		},
	},
}

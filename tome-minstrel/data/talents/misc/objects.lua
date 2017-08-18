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

--local oldTalent = newTalent
--local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end

newTalent{
	short_name = "TEMPTING_GOBLET", image = "talents/tempting-goblet.png",
	name = "Tempting Goblet",
	type = {"misc/objects", 1},
	points = 1,
	cooldown = 0,
	no_npc_use = true,
	action = function(self, t)
		game.logPlayer(who, "#00FFFF#Whether it be sheer stupidity or bravery, you gulp down the contents of the chalice. This was probably not a good idea...")
		game.logPlayer(who, "#00FFFF#Your physical save is reduced by 25, and your blight and nature resistances are reduced by 20%%!")
		game.logPlayer(who, "#00FFFF#Your heroic capacity is boosted: +2 stat points, +2 class points, and +1 generic point.")
		who.unused_stats = who.unused_stats + 2
		who.unused_talents = who.unused_talents + 2
		who.unused_generics = who.unused_generics + 1
		return true
	end,
	info = function(self, t)
		return ([[Drink from Victario's Tasting Chalice.
		The eldritch composition of the brew will deal XX blight and nature damage to you, and PERMANENTLY reduce your physical save by -25 and your blight and nature resistances by -20%%.
		Should you (somehow) survive, it is possible that you may be empowered for your sheer bravado...]])
	end,
}
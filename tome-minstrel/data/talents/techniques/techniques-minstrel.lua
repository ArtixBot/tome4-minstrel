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

-- Physical combat for Minstrel
newTalentType{ allow_random=true, type="technique/musical-combat", name = "musical combat", description = "Act in line with the melody of battle." }
newTalentType{ allow_random=true, type="technique/battle-ballads", name = "battle ballads", description = "Bolster combat prowess." }
newTalentType{ allow_random=true, type="technique/battle-ballads-battle-ballads", name = "battle ballads", generic = true, on_mastery_change = function(self, m, tt) if self:knowTalentType("technique/battle-ballads") ~= nil then self.talents_types_mastery[tt] = self.talents_types_mastery["technique/battle-ballads"] end end, description = "Bolster combat prowess." }
newTalentType{ allow_random=true, type="technique/wit", name = "wit", description = "Debuff and infuriate foes with castigating wit." }
newTalentType{ allow_random=true, type="technique/luck-of-the-draw", min_lev = 10, name = "card invocation", description = "Perform a variety of actions, all bound by one's luck of the draw..." }
newTalentType{ allow_random=true, type="technique/performance-arts", name = "performance arts", generic = true, description = "Prepare oneself for the performance of a lifetime!" }


-- Generic requires for techs based on talent level
-- Uses STR
techs_req1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_req2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_req3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_req4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_req5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end
dex_req_high1 = function(self, t) local stat = "dex"; return {
	stat = { [stat]=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
} end
dex_req_high2 = function(self, t) local stat = "dex"; return {
	stat = { [stat]=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
} end
dex_req_high3 = function(self, t) local stat = "dex"; return {
	stat = { [stat]=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
} end
dex_req_high4 = function(self, t) local stat = "dex"; return {
	stat = { [stat]=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
} end
dex_req_high5 = function(self, t) local stat = "dex"; return {
	stat = { [stat]=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
} end

-- Generic requires for techs_dex based on talent level
techs_dex_req1 = {
	stat = { dex=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_dex_req2 = {
	stat = { dex=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_dex_req3 = {
	stat = { dex=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_dex_req4 = {
	stat = { dex=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_dex_req5 = {
	stat = { dex=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- Generic rquires based either on str or dex
techs_strdex_req1 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_strdex_req2 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_strdex_req3 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_strdex_req4 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_strdex_req5 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end





-----------------------------

load("/data-minstrel/talents/techniques/musical-combat.lua")
load("/data-minstrel/talents/techniques/performance-arts.lua")
load("/data-minstrel/talents/techniques/luck-of-the-draw.lua")
load("/data-minstrel/talents/techniques/battle-ballads.lua")
load("/data-minstrel/talents/techniques/wit.lua")
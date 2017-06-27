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

-- Overall completion: 50%
	-- Showtime!: 0%
	-- Verbosity: 100%
	-- Moxie: 100%
	-- Encore: 0%

newTalent{
	--Provides bonuses as more enemies enter a specified area around the user.
	--STATUS: NOT FINISHED
	name = "Showtime!",
	type = {"technique/performance-arts", 1},
	points = 5,
	require = techs_dex_req1,
	cooldown = 15,
	mode = "sustained",
	sustain_stamina = 20,
	no_energy = true,
	requires_target = true,
	tactical = { ESCAPE=2, CLOSEIN=2 },
	getMax = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 10)) end,
	callbackOnAct = function(self, t, p)
		p = p or self:isTalentActive(t.id)
		local nb_foes = 0
		local act
		local sqdist
		local sqradius = self:getTalentRadius(t) ^ 2
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			sqdist = self.fov.actors and self.fov.actors and self.fov.actors[act] and self.fov.actors[act].sqdist
			if act and sqdist and self:reactionToward(act) < 0 and self:canSee(act) and sqdist <= sqradius then nb_foes = nb_foes + 1 end
		end
		if nb_foes ~= p.nb_foes then
			if p.tmpid then self:removeTemporaryValue("movement_speed", p.tmpid) p.tmpid = nil end
			if nb_foes > 0 then p.tmpid = self:addTemporaryValue("movement_speed", math.min(nb_foes, t.getMax(self, t)) * 0.2) end
		end
		p.nb_foes = nb_foes
	end,
	activate = function(self, t)
		local ret = { nb_foes=0 }
		t.callbackOnAct(self, t, ret)
		return ret
	end,
	deactivate = function(self, t, p)
		if p.tmpid then self:removeTemporaryValue("movement_speed", p.tmpid) end
		return true
	end,
	info = function(self, t)
		local p = self:isTalentActive(t.id)
		local cur = 0
		if p then cur = math.min(p.nb_foes, t.getMax(self, t)) * 20 end
		return ([[No performance is complete without an audience!
		For each foe in radius %d around you, you gain 20%% movement speed (up to %d%%).
		Current bonus: %d%%.]])
		:format(self:getTalentRadius(t), t.getMax(self, t) * 20, cur)
	end,
}

newTalent{
	--Increases silence and confusion immunity, and confers bonus mental save.
	name = "Verbosity",
	type = {"technique/performance-arts", 2},
	require = techs_dex_req2,
	points = 5,
	mode = "passive",
	getSImmune = function(self, t) return self:combatTalentLimit(t, 5, 0.2, 0.81) end,
	getCImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.35) end,
	getSave = function(self, t) return self:combatTalentScale(t, 12, 36, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "silence_immune", t.getSImmune(self, t))
		self:talentTemporaryValue(p, "confusion_immune", t.getCImmune(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
	end,
	info = function(self, t)
		return ([[A minstrel's job is surprisingly difficult, given the mental fortitude needed to learn and remember new songs.
		Years of singing and reciting verse have strengthened your mind and hardened your voice against external threats seeking to silence you.
		Increases silence immunity by %d%% and confusion immunity by %d%%. Also confers +%d mental save.]]):
		format(t.getSImmune(self, t) * 100, t.getCImmune(self, t) * 100, t.getSave(self, t))
	end,
}

newTalent{
	-- Resets the cooldown of a random amount of techniques.
	name = "Moxie",
	type = {"technique/performance-arts", 3},
	require = techs_dex_req3,
	points = 5,
	stamina = 20,
	cooldown = 50,
	tactical = { BUFF = 2 },
	fixed_cooldown = true,
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	getBonusDef = function(self, t) return math.floor(self:combatTalentMindDamage(t, 12, 60)) end,
	getBonusResist = function(self, t) return math.floor(self:combatTalentMindDamage(t, 10, 40)) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 6, 8) end,
	action = function(self, t)
		local nb = t.getTalentCount(self, t)
		local maxlev = t.getMaxLevel(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if not tt.fixed_cooldown then
				if tt.type[2] <= maxlev and tt.type[1]:find("^technique/") then
					tids[#tids+1] = tid
				end
			end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic2")
		self:setEffect(self.EFF_MOXIE_BUFF, t.getDuration(self, t), {power=t.getBonusDef(self, t), res=t.getBonusResist(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Any minstrel worth their salt possesses the quick thinking needed for unorthodox solutions to abnormal problems.
		Resets the cooldown of up to %d techniques of tier %d or less, and confers +%d defense and %d%% additional resistance to all damage for %d rounds.
		The defense and resistance bonuses will increase with your Mindpower.]]):
		format(t.getTalentCount(self, t), t.getMaxLevel(self, t), t.getBonusDef(self, t), t.getBonusResist(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	--Melee attack which cannot miss, is a critical hit, and has massive armor pentration. High cooldown.
	--STATUS: NOT FINISHED
	name = "Encore",
	type = {"technique/performance-arts", 4},
	require = techs_req4,
	points = 5,
	cooldown = 24,
	tactical = { MANA = 1, STAMINA = 1, BUFF = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 24, 3, 7)) end, -- Limit < 24
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_MARTIAL_MAGIC, t.getDuration(self, t), {power = 10})
		if self:getTalentLevel(t) >= 5 then
			local effs = {}
			-- Go through all spell effects
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "detrimental" then
					if e.subtype.silence then
						effs[#effs+1] = {"effect", eff_id}
					end
				end
			end
			local nb = 10000
			while #effs > 0 and nb > 0 do
				local eff = rng.tableRemove(effs)
				self:removeEffect(eff, silent, force)
				nb = nb - 1
				removed = removed + 1
			end
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[The user enters a mystical martial form for %0.2f turns which allows them to utilize their stamina as mana or their mana as stamina.  The user's mana and stamina sustains will not drop unless both their mana and stamina reach zero.
		At 5 points, activating this talent will remove all silence effects currently affecting the user.
		This talent will automatically trigger if the user's mana or stamina drops to zero as long as it is not cooling down.
		Using this talent does not take a turn.]]):
		format(duration)
	end,
}

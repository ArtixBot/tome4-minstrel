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

-- Overall completion: 100%
	-- Showtime: 100%
	-- Verbosity: 100%
	-- Moxie: 100%
	-- Encore: 100%

newTalent{
	-- While active: +damage, crit%, max stamina, and grants blind-fight, but rapidly drains stamina.
	name = "Showtime",
	type = {"technique/performance-arts", 1},
	require = techs_cun_req1,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 5,		-- This is here so that the talent auto-disables if stamina hits 0.
	tactical = { BUFF = 2 },
	getStam = function(self, t) return self:combatTalentLimit(t, 1, 105, 305) end,
	getStamDegen = function(self, t) return self:combatTalentLimit(t, 1, 12, 22) end,
	getDamUp = function(self, t) return self:combatTalentLimit(t, 1, 14, 24) end,
	getCritUp = function(self, t) return self:combatTalentLimit(t, 1, 8, 12) end,
	
	activate = function(self, t)
		return {
			stam = self:addTemporaryValue("max_stamina", t.getStam(self, t)),
			self:addTemporaryValue("stamina", t.getStam(self, t)),	-- Added stamina is no longer 'empty,' so bonus stamina can be used immediately.
			
			bonus_damage = self:addTemporaryValue("inc_damage", {all=t.getDamUp(self, t)}),
			degen = self:addTemporaryValue("stamina_regen", -t.getStamDegen(self, t)),
			b_fight = self:addTemporaryValue("blind_fight", 1),
			crit = self:addTemporaryValue("combat_generic_crit", t.getCritUp(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_stamina", p.stam)
		self:removeTemporaryValue("inc_damage", p.bonus_damage)
		self:removeTemporaryValue("stamina_regen", p.degen)
		self:removeTemporaryValue("blind_fight", p.b_fight)
		self:removeTemporaryValue("combat_generic_crit", p.crit)
		return true
	end,
	info = function(self, t)
		return ([[The toughest performances require intense, unrelenting concentration.
		While active, your maximum stamina is increased by %d, all damage you deal is increased by %d%%, and your critical hit chance is increased by %d%%. Additionaly, you suffer no penalty when attacking unseen enemies.
		This talent quickly consumes one's willpower, draining %d stamina per turn.]]):
		format( t.getStam(self, t), t.getDamUp(self, t), t.getCritUp(self, t), t.getStamDegen(self, t))
	end,
}

newTalent{
	--Increases silence and confusion immunity.
	name = "Verbosity",
	type = {"technique/performance-arts", 2},
	require = techs_cun_req2,
	points = 5,
	mode = "passive",
	getSImmune = function(self, t) return self:combatTalentLimit(t, 5, 0.2, 0.81) end,
	getCImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.35) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "silence_immune", t.getSImmune(self, t))
		self:talentTemporaryValue(p, "confusion_immune", t.getCImmune(self, t))
	end,
	info = function(self, t)
		return ([[A minstrel's job is surprisingly difficult, given the mental fortitude needed to learn and remember new songs.
		Years of singing and reciting verse have strengthened your mind and hardened your voice against external threats seeking to silence you.
		Increases silence immunity by %d%% and confusion immunity by %d%%.]]):
		format(t.getSImmune(self, t) * 100, t.getCImmune(self, t) * 100)
	end,
}

newTalent{
	-- Resets the cooldown of a random amount of techniques and confers bonus defense and resistance to all damage for a short duration.
	name = "Moxie",
	type = {"technique/performance-arts", 3},
	require = techs_cun_req3,
	points = 5,
	stamina = 20,
	cooldown = 50,
	tactical = { BUFF = 2 },
	fixed_cooldown = true,
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
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
		Resets the cooldown of up to %d technique(s) of tier %d or less, and confers +%d defense and %d%% additional resistance to all damage for %d rounds.
		The defense and resistance bonuses will increase with your Mindpower.]]):
		format(t.getTalentCount(self, t), t.getMaxLevel(self, t), t.getBonusDef(self, t), t.getBonusResist(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	-- +Global speed and stam regen. -Fatigue.
	name = "Virtuoso",
	type = {"technique/performance-arts", 4},
	require = techs_cun_req4,
	points = 5,
	mode = "passive",
	getSpd = function(self, t) return self:combatTalentScale(t, 0.08, 0.15, 0.75) end,
	getStamRecover = function(self, t) return self:combatTalentScale(t, 1.0, 5.0, 0.75) end,
	getFatigue = function(self, t) return self:combatTalentScale(t, 14, 30, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "global_speed_base", t.getSpd(self, t))
		self:recomputeGlobalSpeed()
		
		self:talentTemporaryValue(p, "stamina_regen", t.getStamRecover(self, t))
		self:talentTemporaryValue(p, "fatigue", -t.getFatigue(self, t))
	end,
	info = function(self, t)
		return ([[Your skill in the performance arts is unparalleled.
		Global speed is increased by %0.1f%%, stamina regen is increased by %d, and fatigue is permanently reduced by %d%%.]]):
		format(t.getSpd(self, t) * 100, t.getStamRecover(self, t), t.getFatigue(self, t))
	end,
}

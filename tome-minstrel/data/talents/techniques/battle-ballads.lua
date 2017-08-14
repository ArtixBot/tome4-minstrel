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

-- Overall completion: 75%
	-- Balladeer: 100%
	-- Armsbreaking Aria: 100%
	-- Galvanizing Tune: 100%
	-- Apocalyptic Aria: 0%

-- Balladeer Skills

newTalent{
	-- Increases accuracy, critical hit rate and critical damage.
	name = "Ballad of Precision",
	type = {"technique/battle-ballads-battle-ballads", 1},
	mode = "sustained",
	hide = true,
	require = techs_req1,
	points = 5,
	cooldown = 12,
	sustain_stamina = 20,
	tactical = { BUFF = 2 },
	range = 0,
	getAcc = function(self, t) return self:combatTalentScale(t, 13, 37) end,
	getCritCh = function(self, t) return self:combatTalentMindDamage(t, 9.2, 18.4) + 10 end,
	getCritDam = function(self, t) return self:combatTalentMindDamage(t, 13.5, 26.2) + 10 end,
	sustain_slots = 'balladeer_ballad',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")

		local ret = {}
		self:talentTemporaryValue(ret, "combat_atk", t.getAcc(self, t))
		self:talentTemporaryValue(ret, "combat_generic_crit", t.getCritCh(self, t))
		self:talentTemporaryValue(ret, "combat_critical_power", t.getCritDam(self, t))
		ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[You sing the Ballad of Precision, increasing your accuracy by %d, your critical hit rate by %0.1f%%, and your critical hit damage by %0.1f%%.
		You may only have one Ballad active at once.
		Effects increase with Mindpower.]]):
		format(t.getAcc(self, t), t.getCritCh(self, t), t.getCritDam(self, t))
	end,
}

newTalent{
	-- Increases healing mod and health regeneration. Confers chance to ignore critical damage.
	name = "Ballad of Revivification",
	type = {"technique/battle-ballads-battle-ballads", 1},
	mode = "sustained",
	hide = true,
	require = techs_req1,
	points = 5,
	cooldown = 12,
	sustain_stamina = 20,
	tactical = { BUFF = 2 },
	range = 0,
	getHealMod = function(self, t) return self:combatTalentMindDamage(t, 0.15, 0.36) end,
	getHpRegen = function(self, t) return self:combatTalentScale(t, 1.5, 4.0) end,
	getCritRed = function(self, t) return self:combatTalentScale(t, 9, 24, 0.75) end,
	sustain_slots = 'balladeer_ballad',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")

		local ret = {}
		self:talentTemporaryValue(ret, "healing_factor", t.getHealMod(self, t))
		self:talentTemporaryValue(ret, "life_regen", t.getHpRegen(self, t))
		self:talentTemporaryValue(ret, "ignore_direct_crits", t.getCritRed(self, t))
		ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[You sing the Ballad of Revivification, increasing your healing mod by %0.1f%%, health regeneration by %0.1f, and granting a %d%% chance to shrug off critical damage.
		You may only have one Ballad active at once.
		Effects increase with Mindpower.]]):
		format(t.getHealMod(self, t)*100, t.getHpRegen(self, t), t.getCritRed(self, t))
	end,
}

newTalent{
	-- Increases movement speed. Provides knockback and pin immunity.
	name = "Ballad of Celerity",
	type = {"technique/battle-ballads-battle-ballads", 1},
	mode = "sustained",
	hide = true,
	require = techs_req1,
	points = 5,
	cooldown = 12,
	sustain_stamina = 20,
	tactical = { BUFF = 2 },
	range = 0,
	getMovSpd = function(self, t) return self:combatTalentMindDamage(t, 0.35, 0.56) end,
	getImmune = function(self, t) return self:combatTalentMindDamage(t, 0.43, 0.71) end,
	sustain_slots = 'balladeer_ballad',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")

		local ret = {}
		self:talentTemporaryValue(ret, "movement_speed", t.getMovSpd(self, t))
		self:talentTemporaryValue(ret, "knockback_immune", t.getImmune(self, t))
		self:talentTemporaryValue(ret, "pin_immune", t.getImmune(self, t))
		ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[You sing the Ballad of Celerity, increasing your movement speed by %d%% and conferring %d%% knockback and pin immunity.
		You may only have one Ballad active at once.
		Effects increase with Mindpower.]]):
		format(t.getMovSpd(self, t)*100, t.getImmune(self, t)*100)
	end,
}

-- Battle Ballad Skills

newTalent{
	-- Gain access to three different battle ballads, each of which boosts different stats.
	name = "Balladeer",
	type = {"technique/battle-ballads", 1},
	require = techs_req1,
	points = 5,
	mode = "passive",
	passives = function(self, t)
		self:setTalentTypeMastery("technique/battle-ballads-battle-ballads", self:getTalentMastery(t))
	end,
	on_learn = function(self, t)
		self:learnTalent(self.T_BALLAD_OF_PRECISION, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_BALLAD_OF_REVIVIFICATION, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_BALLAD_OF_CELERITY, true, nil, {no_unlearn=true})
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_BALLAD_OF_PRECISION)
		self:unlearnTalent(self.T_BALLAD_OF_REVIVIFICATION)
		self:unlearnTalent(self.T_BALLAD_OF_CELERITY)
	end,
	info = function(self, t)
		local ret = ""
		local old1 = self.talents[self.T_BALLAD_OF_PRECISION]
		local old2 = self.talents[self.T_BALLAD_OF_REVIVIFICATION]
		local old3 = self.talents[self.T_BALLAD_OF_CELERITY]
		self.talents[self.T_BALLAD_OF_PRECISION] = (self.talents[t.id] or 0)
		self.talents[self.T_BALLAD_OF_REVIVIFICATION] = (self.talents[t.id] or 0)
		self.talents[self.T_BALLAD_OF_CELERITY] = (self.talents[t.id] or 0)
		pcall(function() -- Paranoia check (as according to DarkGod)
			local t1 = self:getTalentFromId(self.T_BALLAD_OF_PRECISION)
			local t2 = self:getTalentFromId(self.T_BALLAD_OF_REVIVIFICATION)
			local t3 = self:getTalentFromId(self.T_BALLAD_OF_CELERITY)
			ret = ([[As a minstrel, your skill in song performance manifests itself via three ballads.
			
			#ORANGE#Ballad of Precision:#WHITE# Increases your accuracy by %d, your critical hit rate by %0.1f%%, and critical damage by %0.1f%%.
			#PINK#Ballad of Revivification:#WHITE# Increases your healing modifier by %0.1f%%, life regen by %0.1f, and grants a %d%% chance to shrug off critical damage.
			#GOLD#Ballad of Celerity:#WHITE# Increases your movement speed by %d%% and grants %d%% knockback and pin immunity.
			Only one Ballad can be active at a time. Other skills gain additional effects based on your currently active Ballad.]]):
			format(t1.getAcc(self, t), t1.getCritCh(self, t1), t1.getCritDam(self, t1), t2.getHealMod(self, t2)*100, t2.getHpRegen(self, t2), t2.getCritRed(self, t), t3.getMovSpd(self, t3)*100, t3.getImmune(self, t3)*100)
		end)
		self.talents[self.T_BALLAD_OF_PRECISION] = old1
		self.talents[self.T_BALLAD_OF_REVIVIFICATION] = old2
		self.talents[self.T_BALLAD_OF_CELERITY] = old3
		return ret
	end,
}

newTalent{
	-- Conal attack that deals physical damage and attempts to disarm. Gains variable effects based on current active Ballad.
	-- Precision boost: Chance to daze targets (reduced chance).
	-- Revivification boost: Applies a debuff which reduces healing factor.
	-- Celerity boost: Slow targets (same chance as disarm).
	name = "Armsbreaking Aria",
	type = {"technique/battle-ballads", 2},
	require = techs_req_high1,
	points = 5,
	cooldown = 7,
	stamina = 20,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	getDam = function(self,t) return self:combatTalentMindDamage(t, 112, 460) end,
	getDisarmDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 3.5)) end,
	getDazeMult = function(self, t) return self:combatTalentScale(t, 0.45, 0.65, 0.75) end,
	getHealDown = function(self, t) return self:combatTalentScale(t, 0.52, 0.75, 0.75) end,
	getSlowPow = function(self, t) return self:combatTalentScale(t, 0.20, 0.33, 0.75) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		self:project(tg, x, y, DamageType.PHYSICAL, t.getDam(self, t))
		
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_DISARMED, t.getDisarmDur(self, t), {apply_power=self:combatMindpower()})
		end)
		
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=12, size=5, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		
		if self:isTalentActive(self.T_BALLAD_OF_PRECISION) then
			self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_DAZED, t.getDisarmDur(self, t), {apply_power= t.getDazeMult(self, t) * self:combatMindpower()})
			end)
		end
		if self:isTalentActive(self.T_BALLAD_OF_REVIVIFICATION) then
			self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_ARIA_HEALDOWN, t.getDisarmDur(self, t), {power = t.getHealDown(self, t), apply_power= 99999})
			end)
		end
		if self:isTalentActive(self.T_BALLAD_OF_CELERITY) then
			self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_SLOW, t.getDisarmDur(self, t), {power = t.getSlowPow(self, t), apply_power= self:combatMindpower()})
			end)
		end
		
		return true
	end,
	info = function(self, t)
		return ([[A striking solo shatters the thoughts of all foes within a radius %d cone in front of you, dealing %d physical damage and disarming hit targets for %d turns.
		Damage and chance to disarm increases with Mindpower.
		
		#ORANGE#Precision:#WHITE# Armsbreaking Aria may daze hit targets. Chance to daze is %d%% (multiplicative) lower than chance to disarm.
		#PINK#Revivification:#WHITE# Targets have their healing mod reduced by %d%%.
		#GOLD#Celerity:#WHITE# Slow hit targets (strength %d%%, application chance is based on Mindpower).
		The duration of all these debuffs is equal to this ability's disarm duration.]]):
		format(t.radius(self, t), t.getDam(self, t), t.getDisarmDur(self, t), 100 - t.getDazeMult(self, t)*100, t.getHealDown(self, t) * 100, t.getSlowPow(self, t)*100)
	end,
}

newTalent{
	-- Self-buff. Clears negative mental effects and boosts health and stamina regen.
	-- Precision boost: Boosts APR (armor piercing).
	-- Revivification boost: Also clears negative physical effects.
	-- Celerity boost: Ability is instant.
	name = "Galvanizing Tune",
	type = {"technique/battle-ballads", 3},
	require = techs_req3,
	cooldown = 11,
	points = 5,
	no_energy = function(self, t) return self:isTalentActive(self.T_BALLAD_OF_CELERITY) end,
	tactical = { BUFF = 2 },
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
	getHpUp = function(self, t) return self:combatTalentScale(t, 11.0, 20.0, 0.75) end,
	getStamUp = function(self, t) return self:combatTalentScale(t, 6.0, 12.0, 0.75) end,
	getDur = function(self, t) return self:combatTalentScale(t, 2, 4) end,
	getApr = function(self, t) return self:combatTalentScale(t, 26, 42, 0.75) end,
	action = function(self, t)
		local effs = {}
		local count = t.getRemoveCount(self, t)

		-- Go through all mental effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "mental" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				count = count - 1
			end
		end
		
		self:setEffect(self.EFF_GALVANIZING_TUNE, t.getDur(self, t), {hp = t.getHpUp(self, t), stam = t.getStamUp(self, t)})
		
		-- Add additional effects if a Ballad is active.
		if self:isTalentActive(self.T_BALLAD_OF_PRECISION) then
			self:setEffect(self.EFF_GALVANIZING_PRECISION, t.getDur(self, t), {apr = t.getApr(self, t)})
		end
		if self:isTalentActive(self.T_BALLAD_OF_REVIVIFICATION) then
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "physical" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, t.getRemoveCount(self, t) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					self:removeEffect(eff[2])
					count = count - 1
				end
			end
		end
		if self:isTalentActive(self.T_BALLAD_OF_CELERITY) then
			no_energy = true
		end
		
		return true
	end,
	info = function(self, t)
		local power = self:getTalentLevel(t) * 2.5
		return ([[Galvanize yourself with an upbeat tune, clearing up to %d negative mental effect(s) and increasing health and stamina regen by %0.1f and %0.1f, respectively, for %d turns.
		
		#ORANGE#Precision:#WHITE# While active, confers +%d armor penetration.
		#PINK#Revivification:#WHITE# Galvanizing Tune additionally clears up to %d negative physical effect(s).
		#GOLD#Celerity:#WHITE# This ability is instant.]]):format(t.getRemoveCount(self, t), t.getHpUp(self, t), t.getStamUp(self, t), t.getDur(self, t), t.getApr(self, t),
		t.getRemoveCount(self, t))
	end,
}

newTalent{
	name = "Starstriking Solo",
	type = {"technique/battle-ballads", 4},
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
		return ([[An awe-inspiring solo temporarily stuns all enemies within a radius of XX for XX turns, and knocks them back XX tiles.
		If you have a Ballad active, then you are infused with a powerful buff for XX turns. Effects depend on currently active Ballad.
		
		#ORANGE#Precision:#WHITE# Attacks have a XX increased chance to critically hit and penetrate all armor.
		#PINK#Revivification:#WHITE# Confers XX resistance to all damage, +XX flat damage reduction, and immunity to bleed, poisons, and diseases.
		#GOLD#Celerity:#WHITE# Gain XX defense, XX global speed, and immunity to stuns, slows, and pins.]])
	end,
}

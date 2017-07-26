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

-- Overall completion: 0%
	-- Balladeer: 0%
		-- Core: 50%
		-- Ballad of Precision: 100%
		-- Ballad of Revivification: 100%
		-- Ballad of Celerity: 100%
	-- Curative Canticle: 0%
	-- Expression of Endurance: 0%
	-- Apocalyptic Aria: 0%

-- Balladeer Skills

newTalent{
	-- Increases critical hit rate and critical damage.
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
	getCritCh = function(self, t) return self:combatTalentMindDamage(t, 9.2, 18.4) end,
	getCritDam = function(self, t) return self:combatTalentMindDamage(t, 13.5, 26.2) end,
	sustain_slots = 'balladeer_ballad',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")

		local ret = {}
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
		return ([[You sing the Ballad of Precision, increasing your critical hit rate by %0.1f%% and your critical hit damage by %0.1f%%.
		You may only have one Ballad active at once.
		Effects increase with Mindpower.]]):
		format(t.getCritCh(self, t), t.getCritDam(self, t))
	end,
}

newTalent{
	-- Increases healing mod and health regeneration.
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
	getHpRegen = function(self, t) return self:combatTalentMindDamage(t, 1.5, 4.0) end,
	sustain_slots = 'balladeer_ballad',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")

		local ret = {}
		self:talentTemporaryValue(ret, "healing_factor", t.getHealMod(self, t))
		self:talentTemporaryValue(ret, "life_regen", t.getHpRegen(self, t))
		ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[You sing the Ballad of Revivification, increasing your healing mod by %0.1f%% and health regeneration by %0.1f.
		You may only have one Ballad active at once.
		Effects increase with Mindpower.]]):
		format(t.getHealMod(self, t)*100, t.getHpRegen(self, t))
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
	-- Activating a battle ballad will confer a Song Booster which is consumed to empower subsequent ballads (encourages switching).
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
		pcall(function() -- Be very paranoid, even if some addon or whatever manage to make that crash, we still restore values
			local t1 = self:getTalentFromId(self.T_BALLAD_OF_PRECISION)
			local t2 = self:getTalentFromId(self.T_BALLAD_OF_REVIVIFICATION)
			local t3 = self:getTalentFromId(self.T_BALLAD_OF_CELERITY)
			ret = ([[As a minstrel, your knowledge of inspiring songs grants you access to three ballads.
			Ballad of Precision: Increases your critical hit rate by %0.1f%% and critical damage by %0.1f%%.
			Ballad of Revivification: Increases your healing modifier by %0.1f%% and life regen by %0.1f.
			Ballad of Celerity: Increases your movement speed by %d%% and grants %d%% knockback and pin immunity.
			Only one Ballad can be active at a time.]]):
			format(t1.getCritCh(self, t1), t1.getCritDam(self, t1), t2.getHealMod(self, t2)*100, t2.getHpRegen(self, t2), t3.getMovSpd(self, t3)*100, t3.getImmune(self, t3)*100)
		end)
		self.talents[self.T_BALLAD_OF_PRECISION] = old1
		self.talents[self.T_BALLAD_OF_REVIVIFICATION] = old2
		self.talents[self.T_BALLAD_OF_CELERITY] = old3
		return ret
	end,
}

newTalent{
	-- Conal attack that deals physical damage and disarms hit targets.
	-- Empowered: Applies a negative physical effect which slows and confuses while active, and deals significant damage when effect expires.
	name = "Armsbreaking Aria",
	type = {"technique/battle-ballads", 2},
	require = techs_req2,
	no_energy = true,
	sustain_mana = 20,
	mode = "sustained",
	tactical = { BUFF = 2, Stamina = 1 },
	points = 5,
	cooldown = 5,
	getStaminaMultiplier = function(self,t) return self:combatTalentScale(t, 0.1, 0.5, 0.75) end,
	get_stamina_regen = function(self,t)
		local sustain_count = 0

		for tid, act in pairs(self.sustain_talents) do
			sustain_count = sustain_count + 1
		end
		return (sustain_count * t.getStaminaMultiplier(self,t))
	end,
	activate = function(self, t)
		local sustain_count = 1

		for tid, act in pairs(self.sustain_talents) do
			sustain_count = sustain_count + 1
		end
		self.stamina_regen = self.stamina_regen + (sustain_count  * t.getStaminaMultiplier(self,t))
		return {
			stam = self:addTemporaryValue("arcane_stamina_mult", t.getStaminaMultiplier(self,t))
		}
	end,
	deactivate = function(self, t, p)
		local sustain_count = 0

		for tid, act in pairs(self.sustain_talents) do
			sustain_count = sustain_count + 1
		end
		self.stamina_regen = self.stamina_regen - (sustain_count * self:attr("arcane_stamina_mult"))
		self:removeTemporaryValue("arcane_stamina_mult", p.stam)
		return true
	end,
	info = function(self, t)
		return ([[A striking solo shatters the thoughts of foes, dealing XX physical damage and disarming hit targets for XX turns. Damage scales with Mindpower.
		
		#YELLOW#Empowered:#WHITE# Targets hit will be slowed and confused (XX strength) for XX turns. When this effect wears off, they then take XX additional physical damage.]])
	end,
}

newTalent{
	-- Reduces armor of all enemies within a radius of the user, and gain armor.
	-- Empowered: Also boosts HP regen, heal mod, and crit reduction.
	name = "Sonata of Regression",
	type = {"technique/battle-ballads", 3},
	require = techs_req3,
	mode = "sustained",
	sustain_mana = 30,
	no_energy = true,
	cooldown = 5,
	points = 5,
	tactical = { BUFF = 2 },
	getDamageReduction = function(self,t) return self:combatTalentSpellDamage(t, 2, 40) end,
	getManaRatio = function(self,t) return 0.05 + self:combatTalentLimit(t, 1, 0.01, 0.05) end,  --Limit less than 1.0 ratio
	activate = function(self, t)
		local power = self:getTalentLevel(t) * 2.5
		return {
			fatigue = self:addTemporaryValue("fatigue", -power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("fatigue",p.fatigue)
		return true
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
	    if self:knowTalent(self.T_ARCANE_ARMOR) and self:isTalentActive(self.T_ARCANE_ARMOR) then
		    if dam <= t.getDamageReduction(self,t)  then
		        self:incMana(dam*t.getManaRatio(self,t))
			    dam = 0
		    else
		        self:incMana(t.getDamageReduction(self,t)*t.getManaRatio(self,t))
		    	dam = dam - t.getDamageReduction(self,t)
		    end
		end
        return {dam=dam}
	end,
	info = function(self, t)
		local power = self:getTalentLevel(t) * 2.5
		return ([[who knows]])
	end,
}

newTalent{
	name = "Apocalyptic Aria", -- no cost; it's main purpose is to give the player an alternative means of using mana/stamina based talents
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
		return ([[The user enters a mystical martial form for %0.2f turns which allows them to utilize their stamina as mana or their mana as stamina.  The user's mana and stamina sustains will not drop unless both their mana and stamina reach zero.
		At 5 points, activating this talent will remove all silence effects currently affecting the user.
		This talent will automatically trigger if the user's mana or stamina drops to zero as long as it is not cooling down.
		Using this talent does not take a turn.]]):
		format(duration)
	end,
}

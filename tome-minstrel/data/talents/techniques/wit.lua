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

-- Overall completion: 0%
	-- Diatribe of Incapacitation: 0%
	-- Mockery: 0%
	-- Enraging Slight: 0%
	-- Exploit Instability: 0%
	
newTalent{
	-- Drastically reduces all damage dealt by enemies in a area around the user for a short period of time. Cannot be resisted or removed.
	-- Inflicts a Mental Instability debuff. Wit abilities exploit mental instability, gaining power.
	name = "Diatribe of Incapacitation",
	type = {"technique/wit", 1},
	require = techs_dex_req1,
	points = 5,
	stamina = 25,
	cooldown = 12,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3.5, 5.5)) end,
	tactical = { DISABLE = 3 },
	getDamRed = function (self, t) return self:combatTalentScale(t, 43, 81) end,
	getDur = function (self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CASTIGATED, t.getDur(self, t), {power = t.getDamRed(self, t), apply_power=self:combatMindpower()})
			target:setEffect(target.EFF_MENTAL_INSTABILITY, t.getDur(self, t) - 2, {apply_power=self:combatMindpower()})
		end)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=0.6, radius=self:getTalentRadius(t), life=30, nb_circles=4, rm=0.6, rM=0.6, gm=0.6, gM=0.6, bm=1, bM=1, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Castigate foes within a radius of %d tiles. Affected units deal %d%% less damage for %d turns. Application chance scales with Mindpower.
		This ability applies #RED#Mental Instability#WHITE# for %d turns. Wit abilities exploit Mental Instability, consuming the effect to gain increased power.]]):
		format(radius, t.getDamRed(self, t), t.getDur(self, t), t.getDur(self, t) - 2)
	end,
}

newTalent{
	-- For a short period of time, targets deal bonus damage but have lowered defense and accuracy.
	-- Affects all units in a radius around the user.
	-- Empowered: Mockery lasts longer, and affected units cannot perform critical attacks and take additional damage from all sources.
	name = "Mockery",
	type = {"technique/wit", 2},
	require = techs_dex_req2,
	points = 5,
	stamina = 25,
	cooldown = 12,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3.5, 5.5)) end,
	tactical = { DISABLE = 3 },
	getDamBon = function (self, t) return 15 end,
	getDebuff = function (self, t) return self:combatTalentScale(t, 14, 38) end,
	getResDeb = function(self, t) return self:combatTalentScale(t, 20, 30) end,
	getDur = function (self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:hasEffect(target.EFF_MENTAL_INSTABILITY) then
				game.logSeen(self, "#STEEL_BLUE#%s exploits the target's mental instability!#LAST#", self.name:capitalize())
				target:removeEffect(target.EFF_MENTAL_INSTABILITY)
				target:setEffect(target.EFF_WIT_INFURIATED, t.getDur(self, t)+3, {power = t.getDamBon(self, t), reduction = t.getDebuff(self, t), exploit = true, resistdown = t.getResDeb(self, t), apply_power=self:combatMindpower()})
			else
				target:setEffect(target.EFF_WIT_INFURIATED, t.getDur(self, t), {power = t.getDamBon(self, t), reduction = t.getDebuff(self, t), resistdown = t.getResDeb(self, t), apply_power=self:combatMindpower()})
			end
		end)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=0.6, radius=self:getTalentRadius(t), life=30, nb_circles=4, rm=0.6, rM=0.6, gm=0.6, gM=0.6, bm=1, bM=1, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Make a mockery of nearby enemies in radius %d, applying Infuriated for %d turns.
		Infuriated targets deal 15%% more damage with all attacks, but have %d reduced accuracy and defense.
		The chance to infuriate targets increases with Mindpower.
		
		#RED#Exploit:#WHITE# Infuriated's duration is increased by 3 turns. Infuriated targets cannot critically hit and have all resistances reduced by %d%%.]]):
		format(radius, t.getDur(self, t), t.getDebuff(self, t), t.getResDeb(self, t))
	end,
}

newTalent{
	-- Single-target ranged ability which enrages a target, forcing the target in your direction and forcing it to attack you in melee range for a few turns.
	-- Target takes significantly increased damage from all sources.
	-- Empowered: Applies empowered Infuration, and forces random talents onto cooldown.
	name = "Enraging Slight",
	type = {"technique/wit", 3},
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
		return ([[Perform an exceedingly vulgar and taunting manuever against a target, forcing it in your direction and forcing it to attack you for XX turns.
		While active, the target takes XX increased damage from all sources. Success chance increases with Mindpower.
		
		#RED#Exploit:#WHITE# Enraging Slight also applies an empowered Infuriated effect for XX turns and sets XX of the target's talents on cooldown for XX turns.]])
	end,
}

newTalent{
	-- Has little to no effect on enemies not marked by Mental Instability. May brainlock targets with bonus chance to apply.
	-- Empowered: Inflict physical damage, and apply stun, pin, silence, and confusion.
	name = "Exploit Instability",
	type = {"technique/wit", 4},
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
		return ([[Exploit the mental state of enemies within XX tiles with a disconcerting cry.
		Enemies caught in the area of effect may be Brainlocked. Chance to apply is dependent on Mindpower.
		
		#RED#Exploit:#WHITE# Targets take XX physical damage, and are stunned, confused, silenced, and pinned for XX turns.]])
	end,
}

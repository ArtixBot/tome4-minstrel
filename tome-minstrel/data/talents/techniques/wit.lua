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

-- Overall completion: 100% :D
	-- Diatribe of Incapacitation: 100%
	-- Mockery: 100%
	-- Enraging Slight: 100%
	-- Exploit Instability: 100%
	
newTalent{
	-- Drastically reduces all damage dealt by enemies in a area around the user for a short period of time. Cannot be resisted or removed.
	-- Inflicts a Mental Instability debuff. Wit abilities exploit mental instability, gaining power.
	name = "Diatribe of Incapacitation",
	type = {"technique/wit", 1},
	require = techs_wil_req1,
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
		
		game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=1, radius=self:getTalentRadius(t), life=40, nb_circles=2, rm=0.6, rM=0.6, gm=0.6, gM=0.6, bm=1, bM=1, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Castigate foes within a radius of %d tiles. Affected units deal %d%% less damage for %d turns. Application chance scales with Mindpower.
		Hit enemies suffer from #RED#Mental Instability#WHITE# for %d turns. Wit abilities exploit Mental Instability, consuming the effect to gain increased power.]]):
		format(radius, t.getDamRed(self, t), t.getDur(self, t), t.getDur(self, t) - 2)
	end,
}

newTalent{
	-- For a short period of time, targets deal bonus damage but have lowered defense and accuracy.
	-- Affects all units in a radius around the user.
	-- Empowered: Mockery lasts longer, and affected units cannot perform critical attacks and have reduced resistances.
	name = "Mockery",
	type = {"technique/wit", 2},
	require = techs_wil_req2,
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
	-- Single-target ranged ability which forces target to melee range (if possible) and causing next melee attack to deal 200% damage.
	-- Empowered: Applies empowered Infuration, and forces random talents onto cooldown.
	name = "Enraging Slight",
	type = {"technique/wit", 3},
	require = techs_wil_req3,
	points = 5,
	cooldown = 10,
	stamina = 12,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5.5, 8.5)) end,
	tactical = { DISABLE = 2 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	requires_target = true,
	getDur = function (self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	getTalentCount = function(self, t)	return 3 + math.floor(self:combatTalentLimit(t, 4, 1, 3)) end,
	getCooldown = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "Target out of range!")
			return
		end
		target:pull(self.x, self.y, tg.range)
		target:setEffect(target.EFF_COUNTERSTRIKE, 1, {power = 0, nb = 1})
		-- Exploit effect.
		if target:hasEffect(target.EFF_MENTAL_INSTABILITY) then
			game.logSeen(self, "#STEEL_BLUE#%s exploits the target's mental instability!#LAST#", self.name:capitalize())
			target:removeEffect(target.EFF_MENTAL_INSTABILITY)
			target:setEffect(target.EFF_WIT_INFURIATED, t.getDur(self, t), {power = 10, reduction = 75, exploit = true, resistdown = 50, apply_power=self:combatMindpower()})
			
			local tids = {}
			for tid, lev in pairs(target.talents) do
				local t = target:getTalentFromId(tid)
				if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
			end

			local cdr = t.getCooldown(self, t)

			for i = 1, t.getTalentCount(self, t) do
				local t = rng.tableRemove(tids)
				if not t then break end
				target.talents_cd[t.id] = cdr
				game.logSeen(target, "%s's %s is disrupted by Enraging Slight!", target.name:capitalize(), t.name)
			end
		end
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "flamebeam", {tx=x-self.x, ty=y-self.y}, {type="lightning"})
		game:playSoundNear(self, "talents/fire")	-- imagine that you're playing your mixtape or something
		return true
	end,

	info = function(self, t)
		local power = self:getTalentLevel(t) * 2.5
		return ([[Perform an exceedingly vulgar manuever against a target, forcing it into melee range if possible and causing the next melee attack against the target to deal 200%% damage.
		
		#RED#Exploit:#WHITE# Enraging Slight applies a special Infuriated effect for %d turns and sets %d of the target's talents on cooldown for %d turns.
		This Infuriated effect only increases damage dealt by 10%%, reduces defense and accuracy by 75, and cuts all resistances by 50%%.]]):
		format(t.getDur(self, t), t.getTalentCount(self, t), t.getCooldown(self, t))
	end,
}

newTalent{
	-- Has no effect against enemies unaffected by Mental Instability.
	-- Empowered: Inflict physical damage. Apply stun, pin, silence, and confusion (possibly more effects?).
	name = "Exploit Instability",
	type = {"technique/wit", 4},
	require = techs_wil_req4,
	points = 5,
	stamina = 25,
	cooldown = 12,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
	tactical = { DISABLE = 3 },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 267, 500) + 50 end,
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
				DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, t.getDam(self, t))
				target:removeEffect(target.EFF_MENTAL_INSTABILITY)
				target:setEffect(target.EFF_STUNNED, t.getDur(self, t), {})
				target:setEffect(target.EFF_CONFUSED, t.getDur(self, t), {power = 25})
				target:setEffect(target.EFF_SILENCED, t.getDur(self, t), {})
				target:setEffect(target.EFF_PINNED, t.getDur(self, t), {})
			end
		end)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=0.6, radius=self:getTalentRadius(t), life=30, nb_circles=4, rm=0.6, rM=0.6, gm=0.6, gM=0.6, bm=1, bM=1, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Unleash a harsh, piercing cry which affects all foes within radius %d of the user.
		No effect against enemies unaffected by Mental Instability.
		
		#RED#Exploit:#WHITE# Targets are dealt %d physical damage, and are stunned, confused (power 25%%), silenced, and pinned for %d turns. Damage scales with Mindpower.]]):
		format(radius, t.getDam(self, t), t.getDur(self, t))
	end,
}

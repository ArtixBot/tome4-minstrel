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
	-- Deck of Malevolence: 100%
	-- Deck of Benevolence: 100%
	-- Deck of Oddities: 100%
	-- Ace in the Hole: 100%
	
newTalent{
	-- Draws 1 of 6 random damaging abilities. Ability power is slightly less compared to Deck of Benevolence (due to reliability concerns).
	-- 12.5% to deal massive AoE elemental damage.
	name = "Deck of Malevolence",
	type = {"cunning/luck-of-the-draw", 1},
	require = cuns_req_high1,
	points = 5,
	cooldown = 20,
	fixed_cooldown = true,
	no_npc_use = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5, 0.75)) end,
	-- Repulsion Blast Scaling
	getRepulseDam = function(self, t) return self:combatTalentScale(t, 204, 308, 0.75) end,
	getRepulseDis = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, 0.75)) end,
	-- Degrade Scaling
	getDegenDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.5, 5.5, 0.75)) end,
	getDegenDam = function(self, t) return self:combatTalentScale(t, 24, 42, 0.75) end,
	getDegenSpd = function(self, t) return self:combatTalentScale(t, 0.14, 0.24, 0.75) end,
	getDegenRes = function(self, t) return self:combatTalentScale(t, 19, 34, 0.75) end,
	-- Terra Lances Scaling
	getTerraDam = function(self, t) return self:combatTalentScale(t, 51, 84, 0.75) end,
	getTerraDur = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5, 0.75)) end,
	-- Arcane Negation Nova Scaling
	getNegatDur = function(self, t) return math.floor(self:combatTalentScale(t, 5.5, 8.5, 0.75)) end,
	-- Temporal Rip Scaling
	getTempoDam = function(self, t) return self:combatTalentScale(t, 174, 241, 0.75) end,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
	-- Mass Confusion Scaling
	getConfPow = function(self, t) return self:combatTalentScale(t, 19, 37, 0.75) end,
	getConfDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.5, 5.5, 0.75))end,
	-- Ace of Diamonds Scaling
	getDiamDam = function(self, t) return self:combatTalentScale(t, 211, 342, 0.75) end,
	tactical = { DISABLE = 3 },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		
		-- Check for Ace of Diamonds.
		randJoker = math.random(1, 8)
		
		if randJoker == 1 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes the Ace of Diamonds!#LAST#", self.name:capitalize())
			self:project(tg, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				DamageType:get(DamageType.FIRE).projector(self, px, py, DamageType.FIRE, t.getDiamDam(self, t))
				DamageType:get(DamageType.COLD).projector(self, px, py, DamageType.COLD, t.getDiamDam(self, t))
				DamageType:get(DamageType.LIGHTNING).projector(self, px, py, DamageType.LIGHTNING, t.getDiamDam(self, t))
			end)
		elseif randJoker ~= 1 then
			-- If not drawn, then...
			randCard = math.random(1, 6)
			-- This is a 'temp' fix to prevent the log from playing these messages multiple times when multiple targets are hit.
			if randCard == 1 then
				game.logSeen(self, "#STEEL_BLUE#%s invokes Repulsion Blast!#LAST#", self.name:capitalize())
			elseif randCard == 2 then
				game.logSeen(self, "#STEEL_BLUE#%s invokes Degrade!#LAST#", self.name:capitalize())
			elseif randCard == 3 then
				game.logSeen(self, "#STEEL_BLUE#%s invokes Terra Lances!#LAST#", self.name:capitalize())
			elseif randCard == 4 then
				game.logSeen(self, "#STEEL_BLUE#%s invokes Arcane Negation Nova!#LAST#", self.name:capitalize())
			elseif randCard == 5 then
				game.logSeen(self, "#STEEL_BLUE#%s invokes Temporal Rip!#LAST#", self.name:capitalize())
			elseif randCard == 6 then
				game.logSeen(self, "#STEEL_BLUE#%s invokes Mass Confusion!#LAST#", self.name:capitalize())
			end
		end
		
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if randCard == 1 then
				DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, t.getRepulseDam(self, t))
				target:knockback(self.x, self.y, t.getRepulseDis(self, t))
			elseif randCard == 2 then
				target:setEffect(target.EFF_DECK_DEGENERATION, t.getDegenDur(self, t), {power = t.getDegenDam(self, t), spd = t.getDegenSpd(self, t), res = t.getDegenRes(self, t)})
				
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "circle", {appear_size=2, empty_start=8, oversize=1, a=80, appear=11, limit_life=8, speed=5, img="green_demon_fire_circle", radius=tg.radius})
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "circle", {appear_size=2, oversize=1, a=80, appear=8, limit_life=11, speed=5, img="demon_fire_circle", radius=tg.radius})
			elseif randCard == 3 then
				target:setEffect(target.EFF_DECK_TERRA, t.getTerraDur(self, t), {power = t.getTerraDam(self, t)})
			elseif randCard == 4 then
				target:setEffect(target.EFF_SILENCED, t.getNegatDur(self, t), {})
				target:setEffect(target.EFF_BRAINLOCKED, t.getNegatDur(self, t), {})
			elseif randCard == 5 then
				DamageType:get(DamageType.TEMPORAL).projector(self, px, py, DamageType.TEMPORAL, t.getTempoDam(self, t))
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
			elseif randCard == 6 then
				target:setEffect(target.EFF_CONFUSED, t.getConfDur(self, t), {power = t.getConfPow(self, t)})
			end
		end)
		
	
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Invoke a card from the Deck of Malevolence, triggering one of six possible effects. These effects propagate in a %d-tile radius around the user.
		#YELLOW#Repulsion Blast#WHITE#
		Deal %d physical damage to all enemies and knock them back %d tiles.
		#YELLOW#Degrade#WHITE#
		Rapidly degenerate all enemies, reducing their damage by %d%%, global speed by %d%%, and resistance to all damage by %d%% for %d turns.
		#YELLOW#Terra Lances#WHITE#
		Earthen spikes pin all enemies to the ground and cause them to bleed for %d physical damage for %d turns.
		#YELLOW#Arcane Negation Nova#WHITE#
		All enemies are silenced and brainlocked for %d turns.
		#YELLOW#Temporal Rip#WHITE#
		Deals %d temporal damage to all enemies. Reset the cooldown of %d random technique(s) of tier %d or less.
		#YELLOW#Mass Confusion#WHITE#
		Confuse (power %d%%) all enemies for %d turns.
		
		There is a 12.5%% (separate roll) chance to draw the #RED#Ace of Diamonds#WHITE#, which deals %d fire, cold, and lightning damage to all enemies.]]):
		format(radius, t.getRepulseDam(self, t), t.getRepulseDis(self, t), t.getDegenDam(self, t), t.getDegenSpd(self, t) * 100, t.getDegenRes(self, t), t.getDegenDur(self, t),
		t.getTerraDam(self, t)*t.getTerraDur(self, t), t.getTerraDur(self, t), t.getNegatDur(self, t), t.getTempoDam(self, t), t.getTalentCount(self, t), t.getMaxLevel(self, t),
		t.getConfPow(self, t), t.getConfDur(self, t), t.getDiamDam(self, t))
	end,
}

newTalent{
	-- Draws 1 of 6 random beneficial effects. Each effect is very powerful due to the random nature of this talent (as this is more of a defensive talent,
	-- it's more useful when at low health, but randomness is not the best solution out of a low-health problem). 12.5% chance to be more OP then it deserves to be.
	name = "Deck of Benevolence",
	type = {"cunning/luck-of-the-draw", 1},
	message = "@Source@ draws from the Deck of Benevolence!",
	points = 5,
	cooldown = 20,
	require = cuns_req_high1,
	tactical = { BUFF = 2 },
	fixed_cooldown = true,
	
	-- Incipient Heroism scaling
	getPurge = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
	getStatBoost = function(self, t) return self:combatTalentScale(t, 4, 17, 0.75) + 10 end,	--At least +10 to all stats.
	getStatDur = function(self, t) return self:combatTalentScale(t, 5, 8, 0.75) end,
	-- Rapid Recomposition scaling
	getHeal = function(self, t) return self:combatTalentMindDamage(t, 25, 300) end,
	getRegen = function(self, t) return self:combatTalentMindDamage(t, 50, 200) end,
	-- Garkul's Wrath scaling
	getBonHp = function(self, t) return 100 + self:combatTalentMindDamage(t, 0, 150) end,
	getBonDam = function(self, t) return self:combatTalentLimit(t, 1, 16, 26) end,
	getBonSpd = function(self, t) return self:combatTalentLimit(t, 1, 0.24, 0.42) end,
	getBonRes = function(self, t) return self:combatTalentLimit(t, 1, 10, 20) end,
	getGarDur = function(self, t) return self:combatTalentLimit(t, 1, 5, 7) end,
	-- Lucky Star scaling
	getLuk = function(self, t) return self:combatTalentMindDamage(t, 35, 60) end,
	getBonCrt = function(self, t) return self:combatTalentScale(t, 12, 24, 0.75) end,
	getDamRed = function(self, t) return self:combatTalentMindDamage(t, 25, 50) end,
	getLukDur = function(self, t) return self:combatTalentScale(t, 3, 5, 0.75) end,
	-- Emergency Phasing scaling
	getShield = function(self, t) return 25 + self:combatTalentMindDamage(t, 50, 150) end,
	getShieldDur = function(self, t) return self:combatTalentScale(t, 5, 7, 0.75) end,
	-- Invulnerability scaling
	getInvDur = function(self, t) return self:combatTalentScale(t, 2, 4, 0.75) end,
	
	action = function(self, t)
		randJoker = math.random(1, 8)	-- Check to see if we draw the Ace of Hearts. 12.5% chance.
		
		-- Ace of Hearts is drawn!
		if randJoker == 1 then
			local effs = {}
			local count = t.getPurge(self, t)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type ~= "other" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
			for i = 1, t.getPurge(self, t) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					self:removeEffect(eff[2])
					count = count - 1
				end
			end
			
			-- TODO: there has to be a better way than this...
			game.logSeen(self, "#STEEL_BLUE#%s invokes the Ace of Hearts, triggering all six effects!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_INCIPIENT_HEROISM, t.getStatDur(self, t), {power=t.getStatBoost(self, t)})
			self:heal(t.getHeal(self, t), self)
			self:setEffect(self.EFF_REGENERATION, 4, {power = t.getRegen(self, t)})
			self:setEffect(self.EFF_GARKULS_WRATH, t.getGarDur(self, t), {hp = t.getBonHp(self, t), power = t.getBonDam(self, t), atkspd = t.getBonSpd(self, t), atkres = t.getBonRes(self, t)})
			self:setEffect(self.EFF_LUCKY_STAR, t.getLukDur(self, t), {power = t.getLuk(self, t), crit = t.getBonCrt(self, t), negate = t.getDamRed(self, t)})
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			self:teleportRandom(self.x, self.y, 15, 8)
			self:setEffect(self.EFF_DAMAGE_SHIELD, t.getShieldDur(self, t), {power=t.getShield(self, t)})
			self:setEffect(self.EFF_INVULNERABLE, t.getInvDur(self, t), {})
			

		else
			-- Ace of Hearts not drawn.
			randCard = math.random(1, 6)
		end
		
		if randCard == 1 then
			local effs = {}
			local count = t.getPurge(self, t)
			
			game.logSeen(self, "#STEEL_BLUE#%s invokes Incipient Heroism and is cleansed!#LAST#", self.name:capitalize())
			-- Go through ALL effects (not including 'other' category)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type ~= "other" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, t.getPurge(self, t) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					self:removeEffect(eff[2])
					count = count - 1
				end
			end
			self:setEffect(self.EFF_INCIPIENT_HEROISM, t.getStatDur(self, t), {power=t.getStatBoost(self, t)})
			
		elseif randCard == 2 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Rapid Recomposition, fixing wounds!#LAST#", self.name:capitalize())
			self:heal(t.getHeal(self, t), self)
			self:setEffect(self.EFF_REGENERATION, 4, {power = t.getRegen(self, t)})
		elseif randCard == 3 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Garkul's Wrath and is seized by otherworldy rage!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_GARKULS_WRATH, t.getGarDur(self, t), {hp = t.getBonHp(self, t), power = t.getBonDam(self, t), atkspd = t.getBonSpd(self, t), atkres = t.getBonRes(self, t)})
		elseif randCard == 4 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Lucky Star, becoming unnaturally lucky!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_LUCKY_STAR, t.getLukDur(self, t), {power = t.getLuk(self, t), crit = t.getBonCrt(self, t), negate = t.getDamRed(self, t)})
		elseif randCard == 5 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Emergency Phasing and teleports!#LAST#", self.name:capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			self:teleportRandom(self.x, self.y, 15, 8)
			self:setEffect(self.EFF_DAMAGE_SHIELD, t.getShieldDur(self, t), {power=t.getShield(self, t)})
		else
			game.logSeen(self, "#STEEL_BLUE#%s invokes Invulnerability!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_INVULNERABLE, t.getInvDur(self, t), {})
		end
		
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		return ([[Invoke a card from the Deck of Benevolence, triggering one of six possible effects.
		#YELLOW#Incipient Heroism#WHITE#
		Clear up to %d debuffs (physical, magical, or mental) and increase all stats by %d for %d turns.
		#YELLOW#Rapid Recomposition#WHITE#
		Restore %d life and then regenerate %d health over 4 turns.
		#YELLOW#Garkul's Wrath#WHITE#
		For %d turns, gain +%d maximum health, +%d%% attack speed, and +%d%% to all damage dealt while reducing all damage taken by %d%%.
		#YELLOW#Lucky Star#WHITE#
		Confers +%d luck, +%d%% critical hit chance, and %d flat damage reduction for %d turns.
		#YELLOW#Emergency Phasing#WHITE#
		Teleport to a random area within 8-15 tiles and gain a damage shield that absorbs up to %d points of damage for %d turns.
		#YELLOW#Invulnerability#WHITE#
		Negate all damage taken for %d turns.
		
		There is a 12.5%% (separate roll) chance to draw the #RED#Ace of Hearts#WHITE#, which simultaneously triggers all six effects.
		Effects scale with Mindpower.]]):format(t.getPurge(self, t), t.getStatBoost(self, t), t.getStatDur(self, t), t.getHeal(self, t), t.getRegen(self, t) * 4,
		t.getGarDur(self, t), t.getBonHp(self, t), t.getBonSpd(self, t)*100, t.getBonDam(self, t), t.getBonRes(self, t),
		t.getLuk(self, t), t.getBonCrt(self, t), t.getDamRed(self, t), t.getLukDur(self, t), t.getShield(self, t), t.getShieldDur(self, t), t.getInvDur(self, t))
	end,
}

newTalent{
	-- Draws one of six cards, all extremely powerful but incredibly variate in what their effects.
	-- Lots of utility (and some stranger) effects.
	name = "Deck of Oddities",
	type = {"cunning/luck-of-the-draw", 1},
	message = "@Source@ draws from the Deck of Oddities!",
	points = 5,
	cooldown = 20,
	require = cuns_req_high1,
	tactical = { BUFF = 2 },
	fixed_cooldown = true,
	no_npc_use = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5, 0.75)) end,	
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	-- Bulwark of Faith scaling
	getBulwkDur = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 7.5, 0.75)) end,
	getIntimPwr = function(self, t) return self:combatTalentScale(t, 29, 41, 0.75) end,
	-- Lunar Cloak scaling
	getInvisPwr = function(self, t) return self:combatTalentScale(t, 216, 342, 0.75) end,
	getInvisDur = function(self, t) return self:combatTalentScale(t, 12, 18, 0.75) end,
	-- The Jester scaling
	getBlindDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.5, 5.5, 0.75)) end,
	getAvoidBuf = function(self, t) return self:combatTalentScale(t, 12, 31, 0.75) end,
	-- Necromutation scaling
	getNecroDur = function(self, t) return self:combatTalentScale(t, 15, 20, 0.75) end,
	getDieAt = function(self, t) return self:combatTalentScale(t, 650, 2150, 0.75) end,
	getAffinity = function(self, t) return self:combatTalentScale(t, 30, 60, 0.75) end,
	getArmor = function(self, t) return self:combatTalentScale(t, 44, 81, 0.75) end,
	getPwr = function(self, t) return self:combatTalentScale(t, 21, 50, 0.75) end,
	-- Fortune's Gambit scaling
	getFortBuf = function(self, t) return self:combatTalentScale(t, 21, 5, 0.75) end,	-- If unlucky, enemies may end up GAINING luck. Less likely as skill upgrades.
	getFortNrf = function(self, t) return self:combatTalentScale(t, 41, 89, 0.75) end,
	getFortDur = function(self, t) return math.floor(self:combatTalentScale(t, 5.5, 8.5, 0.75)) end,
	-- Za Warudo scaling
	getBonTurn = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, 0.75)) end,
	
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		
		randJoker = math.random(1, 8)
		if randJoker == 1 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes the Ace of Clubs, drastically boosting Luck and drawing another card!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_ACE_OF_CLUBS, 3, {})
		end
		
		randCard = math.random(1, 6)
		
		if randCard == 1 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Bulwark of Faith!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_BULWARK_OF_FAITH, t.getBulwkDur(self, t), {})
			self:project(tg, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_INTIMIDATED, t.getBulwkDur(self, t), {power = t.getIntimPwr(self, t)})
			end)
		elseif randCard == 2 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Lunar Cloak and becomes invisible!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_INVISIBILITY, t.getInvisDur(self, t), {power = t.getInvisPwr(self, t), penalty = 0, false})
		elseif randCard == 3 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes The Jester and is promptly enveloped in a flash of light!#LAST#", self.name:capitalize())
			self:project(tg, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_BLINDED, t.getBlindDur(self, t), {})
				target:setEffect(target.EFF_STUNNED, t.getBlindDur(self, t), {})
			end)
			self:setEffect(self.EFF_DECK_JESTER, t.getBlindDur(self, t) + 2, {power = t.getAvoidBuf(self, t)})	-- Makes the buff last a tad bit longer than the blind.
		elseif randCard == 4 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Necromutation and morphs into a demilich!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_NECROMUTATION, t.getInvisDur(self, t), {heroism = t.getDieAt(self, t), affinity = t.getAffinity(self, t), armor = t.getArmor(self, t), power = t.getPwr(self, t)})	-- Placeholder values!
		elseif randCard == 5 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Fortune's Gambit, drastically affecting luck!#LAST#", self.name:capitalize())
			self:project(tg, self.x, self.y, function(px, py)
				randLuk = math.random(t.getFortNrf(self, t) * -1, t.getFortBuf(self, t))
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_FORTUNES_GAMBIT, t.getFortDur(self, t), {power = randLuk})
			end)
		else
			game.logSeen(self, "#STEEL_BLUE#%s invokes The World, stopping time!#LAST#", self.name:capitalize())
			game:onTickEnd(function()
			self.energy.value = self.energy.value + (t.getBonTurn(self, t) * 1000)
			self:setEffect(self.EFF_TIME_STOP, 1, {power=0})

			game:playSoundNear(self, "talents/heal")
			end)
		end
		
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Invoke a card from the Deck of Oddities, triggering one of six possible effects.
		#YELLOW#Bulwark of Faith#WHITE#
		Gain 40%% resistance to all damage and 25%% physical damage affinity for %d turns, and intimidate all foes within %d tiles of the user for the same duration.
		Intimidated foes suffer a -%d penalty to attack, spell, and mindpower. While Bulwark of Faith is active, you are rooted in place. This effect cannot be dispelled or removed early.
		#YELLOW#Lunar Cloak#WHITE#
		Become invisible (power %d) for %d turns. This effect does not confer a damage penalty and allows health regeneration.
		#YELLOW#The Jester#WHITE#
		A sudden flash of light blinds and stuns enemies in a %d-tile radius around you for %d turns. Confers a %d-turn buff which grants you a %d%% chance to avoid incoming damage.
		#YELLOW#Necromutation#WHITE#
		For %d turns, global speed is reduced by 50%%, and your healing mod is set to zero. Gain listed bonuses:
		- Die only when reaching -%d health.
		- Gain %d%% cold and darkness damage affinity.
		- Immunity to poison, diseases, and stuns.
		- Armor hardiness set to 100%%, and armor increased by %d.
		- All saves, Physical Power, Spellpower, and Mindpower increased by %d.
		This effect cannot be dispelled or removed early.
		#YELLOW#Fortune's Gambit#WHITE#
		Drastically affects the luck of all enemies within %d tiles of the user for %d turns.
		Each target has its luck change anywhere from +%d to %d points (most characters have 50 base Luck).
		#YELLOW#The World#WHITE#
		Gain %d turns. Damage is not reduced while time is stopped.
		
		There is a 12.5%% (separate roll) chance to draw the #GREY#Ace of Clubs#WHITE#, which boosts Luck by +250 points for 3 turns in addition to drawing a card.]]):format(t.getBulwkDur(self, t), radius, t.getIntimPwr(self, t),
		t.getInvisPwr(self, t), t.getInvisDur(self, t), radius, t.getBlindDur(self, t), t.getBlindDur(self, t) + 2, t.getAvoidBuf(self, t), t.getNecroDur(self, t),
		t.getDieAt(self, t), t.getAffinity(self, t), t.getArmor(self, t), t.getPwr(self, t), radius, t.getFortDur(self, t), t.getFortBuf(self, t), t.getFortNrf(self, t) * -1, t.getBonTurn(self, t))
	end,
}

newTalent{
	-- While active, mastery of card invocation talents increased. Deactivate to further increase mastery levels for one turn.
	-- NOTE: Causes some values to overflow and become negative; check and rebalance those values.
	name = "Ace in the Hole",
	type = {"cunning/luck-of-the-draw", 4},
	require = cuns_req_high2,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 20,
	tactical = { BUFF = 2 },

	getMasteryA = function(self, t) return 0.25 end,
	getMasteryB = function(self, t) return 0.40 end,
	getMasteryC = function(self, t) return 0.50 end,
	
	b = false,
	c = false,
	
	activate = function(self, t)
		local ret = {}

		if self:getTalentLevelRaw(t) >= 5 then
			self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") + t.getMasteryC(self, t))
			c = true
		elseif self:getTalentLevelRaw(t) >= 3 then
			self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") + t.getMasteryB(self, t))
			b = true
		else
			self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") + t.getMasteryA(self, t))
		end
		
		game:playSoundNear(self, "talents/spell_generic2")
		return ret
	end,
	deactivate = function(self, t, p)
		if c then
			self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") - t.getMasteryC(self, t))
			c = false
		elseif b then
			self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") - t.getMasteryB(self, t))
			b = false
		else
			self:setTalentTypeMastery("cunning/luck-of-the-draw", self:getTalentTypeMastery("cunning/luck-of-the-draw") - t.getMasteryA(self, t))
		end
		game.logSeen(self, "#STEEL_BLUE#%s draws the Ace of Spades, greatly increasing the power of the next card drawn!#LAST#", self.name:capitalize())
		self:setEffect(self.EFF_ACE_OF_SPADES, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[While active, your mastery of Technique / Card invocation skills is increased by +0.25.
		At raw talent level 3 this bonus is increased to +0.40.
		At raw talent level 5 this bonus is increased to +0.50.
		
		Deactivate this ability to draw the #GREY#Ace of Spades#WHITE#, which boosts your mastery of Technique / Card invocation skills by +1.00 for 1 turn.]])
	end,
}


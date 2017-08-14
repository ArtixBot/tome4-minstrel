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

-- Overall completion: 35%
	-- Deck of Malevolence: 0%
	-- Deck of Benevolence: 99% (there exists this mystical thing called 'balance,' but given its mystical nature, I don't know what 'balance' means.)
		-- TODO: Add message when Ace of Hearts is drawn.
	-- Deck of Oddities: 40%
	-- Ace in the Hole: 20%
	
newTalent{
	-- Draws 1 of 6 random damaging abilities. Ability power is slightly less compared to Deck of Benevolence (due to reliability concerns).
	-- 5% chance to draw the deck's joker, dealing massive AoE elemental damage.
	-- STATUS: Borked up beyond belief, like holy crap; fix this stuff.
	name = "Deck of Malevolence",
	type = {"technique/luck-of-the-draw", 1},
	message = "testmessage",
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	stamina = 22,
	getCardDraw = function(self, t) return math.random(1, 6) end,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 6, 4)) end,
	tactical = { ATTACK = { weapon = 1}, CLOSEIN = 3 },
	requires_target = true,
	is_melee = true,
	getSpeed = function(self, t) return self:combatTalentLimit(t, 1, 0.10, 0.28) end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), nolock=true, nowarning=true, requires_knowledge=false, stop__block=true} end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not self:canProject(tg, x, y) then return nil end
		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local linestep = self:lineFOV(x, y, block_actor)

		local tx, ty, lx, ly, is_corner_blocked
		repeat  -- make sure each tile is passable
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = linestep:step()
		until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
		if not tx or core.fov.distance(self.x, self.y, tx, ty) < 1 then
			game.logPlayer(self, "Target enemy is too close to strike!")
			return
		end
		if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then return nil end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
				
		-- Performs actual attack.
		if target and core.fov.distance(self.x, self.y, target.x, target.y) <= 1 then
		
			if self:attackTarget(target, nil, 1.25, true) then
				-- On hit, boosts global speed for a short period of time.
				self:setEffect(self.EFF_SPEED, 2, {power=t.getSpeed(self, t)})
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Invoke a card from the Deck of Malevolence, triggering one of six possible effects.
		#YELLOW#Repulsion Blast#WHITE#
		#YELLOW#Degrade#WHITE#
		#YELLOW#Gravity Spike#WHITE#
		#YELLOW#Arcane Negation Field#WHITE#
		#YELLOW#Spellblaze Storm#WHITE#
		#YELLOW#Mass Confusion#WHITE#
		
		There is a 10%% chance to draw the #RED#Ace of Diamonds#WHITE#, which deals massive, multi-elemental damage in an area around the user.]])
	end,
}

newTalent{
	-- Draws 1 of 6 random beneficial effects. Each effect is very powerful due to the random nature of this talent (as this is more of a defensive talent,
	-- it's more useful when at low health, but randomness is not the best solution out of a low-health problem). 12.5% chance to be really OP.
	name = "Deck of Benevolence",
	type = {"technique/luck-of-the-draw", 2},
	message = "@Source@ draws from the Deck of Benevolence!",
	points = 5,
	cooldown = 20,
	require = techs_dex_req2,
	tactical = { BUFF = 2 },
	fixed_cooldown = true,
	no_energy = true,
	no_npc_use = true,
	
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
		randJoker = math.random(1, 8)	-- Check to see if we draw the Ace of Hearts.
		
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
	name = "Deck of Oddities",
	type = {"technique/luck-of-the-draw", 2},
	message = "@Source@ draws from the Deck of Oddities!",
	points = 5,
	cooldown = 0,
	require = techs_dex_req2,
	tactical = { BUFF = 2 },
	no_energy = true,
	no_npc_use = true,
	
	-- Lunar Cloak scaling
	getInvisPwr = function(self, t) return self:combatTalentScale(t, 216, 342, 0.75) end,
	getInvisDur = function(self, t) return self:combatTalentScale(t, 12, 18, 0.75) end,
	-- Necromutation scaling
	getNecroDur = function(self, t) return self:combatTalentScale(t, 15, 20, 0.75) end,
	getDieAt = function(self, t) return self:combatTalentScale(t, 650, 2150, 0.75) end,
	getAffinity = function(self, t) return self:combatTalentScale(t, 30, 60, 0.75) end,
	getArmor = function(self, t) return self:combatTalentScale(t, 44, 81, 0.75) end,
	getPwr = function(self, t) return self:combatTalentScale(t, 21, 50, 0.75) end,
	-- Za Warudo scaling
	getBonTurn = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, 0.75)) end,
	
	action = function(self, t)
		randCard = math.random(1, 6)
		
		if randCard == 1 then
			self:setEffect(self.EFF_INVULNERABLE, 1, {})
		elseif randCard == 2 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Lunar Cloak and becomes invisible!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_INVISIBILITY, t.getInvisDur(self, t), {power = t.getInvisPwr(self, t), penalty = 0, false})
		elseif randCard == 4 then
			game.logSeen(self, "#STEEL_BLUE#%s invokes Necromutation and morphs into a demilich!#LAST#", self.name:capitalize())
			self:setEffect(self.EFF_NECROMUTATION, t.getInvisDur(self, t), {heroism = t.getDieAt(self, t), affinity = t.getAffinity(self, t), armor = t.getArmor(self, t), power = t.getPwr(self, t)})	-- Placeholder values!
		else
			game.logSeen(self, "#STEEL_BLUE#%s invokes The World, stopping time!#LAST#", self.name:capitalize())
			game:onTickEnd(function()
			self.energy.value = self.energy.value + (t.getBonTurn(self, t) * 1000)
			self:setEffect(self.EFF_TIME_STOP, 1, {power=0})

			game:playSoundNear(self, "talents/heal")
			end)
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Invoke a card from the Deck of Oddities, triggering one of six possible effects.
		#YELLOW#Connate Summoning#WHITE#
		
		#YELLOW#Lunar Cloak#WHITE#
		Become invisible (power %d) for %d turns. This effect does not confer a damage penalty and allows health regeneration.
		#YELLOW#Mass Psychoportation#WHITE#
		#YELLOW#Necromutation#WHITE#
		For %d turns, global speed is reduced by 50%%, and your healing mod is set to zero. Gain listed bonuses:
		- Die only when reaching -%d health.
		- Gain %d%% cold and darkness damage affinity.
		- Immunity to poison, diseases, and stuns.
		- Armor hardiness increases to 100%%, and armor increased by %d.
		- All saves, Physical Power, Spellpower, and Mindpower increased by %d.
		This effect cannot be dispelled or removed early.
		#YELLOW#Circle of Conflagration#WHITE#
		Creates a circle of radius X-XX at your feet which lasts XX turns; targets in the circle take XX Sundering Fire damage per turn, reducing Armor by XX.
		#YELLOW#The World#WHITE#
		Gain %d turns. Damage is not reduced while time is stopped.
		
		There is a 10%% chance to draw the #GREY#Ace of Clubs#WHITE#, which will trigger three random effects from the Deck of Oddities.]]):format(
		t.getInvisPwr(self, t), t.getInvisDur(self, t), t.getNecroDur(self, t), t.getDieAt(self, t), t.getAffinity(self, t), t.getArmor(self, t), t.getPwr(self, t),
		t.getBonTurn(self, t))
	end,
}

newTalent{
	-- While active, mastery of card invocation talents increased. Deactivate to further increase mastery levels for one turn.
	-- NOTE: Causes some values to overflow and become negative; check and rebalance those values.
	name = "Ace in the Hole",
	type = {"technique/luck-of-the-draw", 4},
	require = techs_dexreq4,
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
			self:setTalentTypeMastery("technique/luck-of-the-draw", self:getTalentTypeMastery("technique/luck-of-the-draw") + t.getMasteryC(self, t))
			c = true
		elseif self:getTalentLevelRaw(t) >= 3 then
			self:setTalentTypeMastery("technique/luck-of-the-draw", self:getTalentTypeMastery("technique/luck-of-the-draw") + t.getMasteryB(self, t))
			b = true
		else
			self:setTalentTypeMastery("technique/luck-of-the-draw", self:getTalentTypeMastery("technique/luck-of-the-draw") + t.getMasteryA(self, t))
		end
		
		return ret
	end,
	deactivate = function(self, t, p)
		if c then
			self:setTalentTypeMastery("technique/luck-of-the-draw", self:getTalentTypeMastery("technique/luck-of-the-draw") - t.getMasteryC(self, t))
			c = false
		elseif b then
			self:setTalentTypeMastery("technique/luck-of-the-draw", self:getTalentTypeMastery("technique/luck-of-the-draw") - t.getMasteryB(self, t))
			b = false
		else
			self:setTalentTypeMastery("technique/luck-of-the-draw", self:getTalentTypeMastery("technique/luck-of-the-draw") - t.getMasteryA(self, t))
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


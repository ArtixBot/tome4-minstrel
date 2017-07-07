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

-- Overall completion: 5%
	-- Deck of Malevolence: 0%
	-- Deck of Benevolence: 45% (there exists this mystical thing called 'balance,' but given its mystical nature, I don't know what 'balance' means.)
	-- Deck of Oddities: 0%
	-- Ace in the Hole: 0%
	
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
	-- it's obviously more useful when at low health, but randomness is not the best solution out of a low-health problem). 10% chance to be really OP.
	-- dear god please do not smite me for this code i think there is an easier way to do this but i don't know it yet
	name = "Deck of Benevolence",
	type = {"technique/luck-of-the-draw", 2},
	message = "@Source@ draws from the Deck of Benevolence!",
	points = 5,
	cooldown = 0,
	require = techs_dex_req2,
	tactical = { BUFF = 2 },
	-- Incipient Heroism scaling
	
	-- Rapid Recomposition scaling
	getHeal = function(self, t) return self:combatTalentMindDamage(t, 25, 300) end,
	getRegen = function(self, t) return self:combatTalentMindDamage(t, 50, 200) end,
	-- Garkul's Wrath scaling
	getBonHp = function(self, t) return 100 + self:combatTalentMindDamage(t, 0, 150) end,
	getBonDam = function(self, t) return self:combatTalentLimit(t, 1, 16, 26) end,
	getBonSpd = function(self, t) return self:combatTalentLimit(t, 1, 0.24, 0.42) end,
	getBonRes = function(self, t) return self:combatTalentLimit(t, 1, 10, 20) end,
	getGarDur = function(self, t) return self:combatTalentLimit(t, 1, 5, 7) end,
	-- Invulnerability scaling
	getInvDur = function(self, t) return self:combatTalentLimit(t, 1, 2, 4) end,	-- Why does it jump to 13 at talent level 6.5??
	
	action = function(self, t)
		randJoker = math.random(1, 10)
		randCard = math.random(1, 6)
		
		if randCard == 2 then
			self:heal(t.getHeal(self, t), self)
			self:setEffect(self.EFF_REGENERATION, 4, {power = t.getRegen(self, t)})
		elseif randCard == 3 then
			self:setEffect(self.EFF_GARKULS_WRATH, t.getGarDur(self, t), {hp = t.getBonHp(self, t), power = t.getBonDam(self, t), atkspd = t.getBonSpd(self, t), atkres = t.getBonRes(self, t)})
		else
			self:setEffect(self.EFF_INVULNERABLE, t.getInvDur(self, t), {})
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Invoke a card from the Deck of Benevolence, triggering one of six possible effects.
		#YELLOW#Incipient Heroism#WHITE#
		Clear up to XX physical, magical, or mental debuffs and gain XX to all stats for XX turns.
		#YELLOW#Rapid Recomposition#WHITE#
		Heal yourself for %d life, and gain a regeneration effect which restores %d health over 4 turns.
		#YELLOW#Garkul's Wrath#WHITE#
		For %d rounds, gain +%d maximum health, +%d%% attack speed, and +%d%% to all damage dealt while reducing all damage taken by %d%%.
		#YELLOW#Parallel Assistance#WHITE#
		Conjure 3 allies (level XX) to your side for XX turns.
		#YELLOW#Emergency Phasing#WHITE#
		Teleport to a random area within range XX, and become out of phase for XX turns.
		#YELLOW#Invulnerability#WHITE#
		Negate all damage taken for %d turns.
		
		There is a 10%% chance to draw the #RED#Ace of Hearts#WHITE#, which simultaneously triggers all six effects.
		Effects scale with Mindpower.]]):format(t.getHeal(self, t), t.getRegen(self, t) * 4, 
		t.getGarDur(self, t), t.getBonHp(self, t), t.getBonSpd(self, t)*100, t.getBonDam(self, t), t.getBonRes(self, t), t.getInvDur(self, t))
	end,
}

newTalent{
	-- Draws one of six cards, all extremely powerful but incredibly variate in what they actually do. One-in-six chance to backfire. Very badly.
	name = "Deck of Oddities",
	type = {"technique/luck-of-the-draw", 3},
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
		return ([[Enchants the user's armor, making it lighter and capable of absorbing damage and converting it to mana.  Reduces fatigue by %d%% and reduces all sources of damage by %d. Restores %d%% of the damage absorbed as mana.
		Turning this talent on does not take a turn.]]):format(power,t.getDamageReduction(self,t),t.getManaRatio(self,t)*100)
	end,
}

newTalent{
	-- Passively boosts mastery levels of all three Decks. Activate to dramatically increase this boost for one turn (at the cost of temporarily reducing
	-- mastery levels of decks afterwards).
	name = "Ace in the Hole", -- no cost; it's main purpose is to give the player an alternative means of using mana/stamina based talents
	type = {"technique/luck-of-the-draw", 4},
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

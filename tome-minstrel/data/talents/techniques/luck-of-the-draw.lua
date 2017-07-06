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

newTalent{
	-- Draws 1 of 6 random damaging abilities.
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
		return ([[Dash to a target tile with blinding speed.
		Targeting an enemy with this ability will deliver a strike that deals 125%% weapon damage. A successful hit conserves your momentum, temporarily granting +%d%% global speed for 2 turns.
		To build up momentum, the target tile must be at least 2 tiles away from the user.]]):format(100*t.getSpeed(self, t))
	end,
}

newTalent{
	-- Draws 1 of 6 random beneficial effects.
	-- STATUS: My god, the base code works. TODO: implement actual effects.
	name = "Deck of Benevolence",
	type = {"technique/luck-of-the-draw", 2},
	message = "@Source@ draws from the Deck of Benevolence!",
	points = 5,
	cooldown = 20,
	require = techs_dex_req2,
	tactical = { BUFF = 2 },
	getHeal = function(self, t) return 100 + self:combatTalentMindDamage(t, 0, 350) end,
	getInvDur = function(self, t) return self:combatTalentLimit(t, 1, 3, 5) end,
	action = function(self, t)
		randCard = math.random(1, 6)
		
		if randCard == 1 then
			self:heal(t.getHeal(self, t), self)
		else
			self:setEffect(self.EFF_INVULNERABLE, t.getInvDur(self, t), {})
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Invoke a card from the Deck of Benevolence, triggering one of six possible effects.
		#YELLOW#Incipient Heroism#WHITE#
		#YELLOW#Rapid Recomposition#WHITE#
		Heal your body for %d life. Effects scale with Mindpower.
		#YELLOW#Garkul's Wrath#WHITE#
		Infuse yourself with the limitless wrath of Garkul the Devourer, temporarily increasing maximum health, attack speed, and damage dealt while reducing all damage taken.
		#YELLOW#Parallel Assistance#WHITE#
		#YELLOW#Emergency Phasing#WHITE#
		#YELLOW#Invulnerability#WHITE#
		Become invulnerable to all damage for %d rounds.]]):format(t.getHeal(self, t), t.getInvDur(self, t))
	end,
}

newTalent{
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
	name = "Trump Card", -- no cost; it's main purpose is to give the player an alternative means of using mana/stamina based talents
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

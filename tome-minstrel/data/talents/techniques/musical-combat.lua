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
	-- Charge manuever which buffs user speed for a short period of time.
	-- STATUS: Implemented, working!. Todo: set so opening sweep only works when a target is selected (instead of allowing dash to tile)
	name = "Opening Sweep",
	type = {"technique/musical-combat", 1},
	message = "@Source@ dashes with alarming speed!",
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	stamina = 22,
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
	-- AoE cone ability which debuffs accuracy of all units caught in the area and boosts caster speed based on number of enemies hit.
	-- STATUS: Targeting works, and -acc debuff applies correctly; need to implement +spd buff.
	name = "Solo",
	type = {"technique/musical-combat", 2},
	require = techs_dex_req2,
	points = 5,
	cooldown = 30,
	stamina = 40,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 7)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { DISABLE = 2 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_SOLO_DEBUFF, t.getDuration(self, t), {power=7 * self:getTalentLevel(t)})
		end)
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=12, size=5, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		return ([[Your battle cry shatters the will of your foes within a radius of %d, lowering their Accuracy by %d for %d turns, making them easier to hit.]]):
		format(self:getTalentRadius(t), 7 * self:getTalentLevel(t), t.getDuration(self, t))
	end,
}

newTalent{
	--High-damage attack that may disarm and confuse.
	--STATUS: Implemented, working! Need to see if enemies can save against it, though.
	name = "Cadenza",
	type = {"technique/musical-combat", 3},
	require = techs_req3,
	points = 5,
	cooldown = 12,
	stamina = 18,
	requires_target = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.26, 1.61), true)

		-- Attempts to disarm.
		if hit then
			if target:canBe("disarmed") then
				target:setEffect(target.EFF_DISARMED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s is not disarmed!", target.name:capitalize())
			end
		end
		
		-- Attempts to confuse.
		if hit then
			if target:canBe("confused") then
				target:setEffect(target.EFF_CONFUSED, t.getDuration(self, t), {power=25})
			else
				game.logSeen(target, "%s resisted the confusion!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Perform a sudden, violent strike that deals %d%% damage.
		The unexpected power of this attack may disarm and confuse (25%% strength) hit targets for %d turns.
		Your chance to disarm and confuse the target improves with Physical Power.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.26, 1.61), t.getDuration(self, t))
	end,
}

newTalent{
	--Incredibly powerful strike, but high cooldown and slows user.
	--STATUS: Fully implemented! Slow seems to apply at -24.9% instead of -35% as intended, though.
	name = "Finale",
	type = {"technique/musical-combat", 4},
	require = techs_req4,
	points = 5,
	cooldown = 20,
	stamina = 40,
	requires_target = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 4.00, 6.00), true)
		self:setEffect(self.EFF_FINALE_DEBUFF, 3, {power=0.35, apply_power=10000, no_ct_effect=true})
		
		return true
	end,
	info = function(self, t)
		return ([[Finish off your opponent with a singular strike, inflicting %d%% weapon damage.
		Beware; the sheer power of this attack will temporarily leave you exhausted, slowing down your global speed by 35%% for the next 3 turns.
		This slow CANNOT be resisted or purged in any way.]]):
		format(100 * self:combatTalentWeaponDamage(t, 4.00, 6.00))
	end,
}

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

-- Overall completion: 100% + polish done!
	-- Opening Sweep: 100%
	-- Symphonic Whirl: 100%
	-- Cadenza: 100%
	-- Finale: 100%

newTalent{
	-- Charge manuever which buffs user speed for a short period of time.
	name = "Opening Sweep",
	type = {"technique/musical-combat", 1},
	message = "@Source@ dashes with alarming speed!",
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	stamina = 22,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 8, 6)) end,
	tactical = { ATTACK = { weapon = 1}, CLOSEIN = 3 },
	requires_target = true,
	is_melee = true,
	getSpeed = function(self, t) return self:combatTalentLimit(t, 1, 0.10, 0.28) end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), nolock=true, nowarning=true, requires_knowledge=false, stop__block=true} end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "Opening Sweep can only be used while dual wielding.")
			return nil
		end
		
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
		To build up momentum, the target tile must be at least 2 tiles away from the user.
		Can only be used while dual wielding.]]):format(100*t.getSpeed(self, t))
	end,
}

newTalent{
	-- Strike all adjacent enemies and inflict a debuff which gets more intense over time.
	name = "Symphonic Whirl",
	type = {"technique/musical-combat", 2},
	require = techs_dex_req2,
	points = 5,
	cooldown = 30,
	stamina = 40,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 7)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=1}
	end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	tactical = { ATTACKAREA = 3 },
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "Symphonic Whirl can only be used while dual wielding.")
			return nil
		end
		
		local tg = self:getTalentTarget(t)
		
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.47, 1.00), true)
				target:setEffect(target.EFF_TEMPO_DISRUPTION, 2, {})
			end
		end)

		self:addParticles(Particles.new("meleestorm", 1, {}))
		return true
	end,
	info = function(self, t)
		return ([[Disrupt the tempo of adjacent enemies with your blades, dealing %d%% weapon damage and inflicting Tempo Disruption on hit targets.
		An enemy afflicted by Tempo Disruption will be impaired over three stages, each of which lasts 2 turns.
		Stage 1: All damage dealt is reduced by 20%%.
		Stage 2: Confused (25%% strength) and all damage dealt reduced by 40%%.
		Stage 3: All resistances reduced by 25%% and stunned.
		Can only be used while dual wielding.]]):format(100 * self:combatTalentWeaponDamage(t, 0.47, 1.00))
	end,
}

newTalent{
	--High-damage attack that may disarm and confuse.
	name = "Cadenza",
	type = {"technique/musical-combat", 3},
	require = techs_dex_req3,
	points = 5,
	cooldown = 12,
	stamina = 18,
	requires_target = true,
	is_melee = true,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "Cadenza can only be used while dual wielding.")
			return nil
		end
		
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
		game.level.map:particleEmitter(target.x, target.y, 1, "stalked_start")
		return true
	end,
	info = function(self, t)
		return ([[Perform a sudden, violent strike that deals %d%% damage.
		The unexpected power of this attack may disarm and confuse (25%% strength) hit targets for %d turns.
		Your chance to disarm and confuse the target improves with Physical Power.
		Can only be used while dual wielding.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.26, 1.61), t.getDuration(self, t))
	end,
}

newTalent{
	--Incredibly powerful strike. Fixed cooldown, slows user.
	name = "Finale",
	type = {"technique/musical-combat", 4},
	require = techs_dex_req4,
	points = 5,
	cooldown = 20,
	stamina = 50,
	fixed_cooldown = true,
	requires_target = true,
	is_melee = true,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "Finale can only be used while dual wielding.")
			return nil
		end
		
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 4.00, 6.35), true)
		self:setEffect(self.EFF_FINALE_DEBUFF, 4, {power=0.35, apply_power=10000, no_ct_effect=true})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Finish off your opponent with a singular dual strike, inflicting %d%% weapon damage.
		Beware; the sheer power of this attack will temporarily leave you exhausted, slowing down your global speed by 25%% for the next 4 turns.
		This slow CANNOT be resisted or purged in any way.
		Can only be used while dual wielding.]]):
		format(100 * self:combatTalentWeaponDamage(t, 4.00, 6.35))
	end,
}

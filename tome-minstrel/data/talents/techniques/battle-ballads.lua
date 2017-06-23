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
	name = "Symphony of Superiority",
	type = {"technique/battle-ballads", 1},
	require = techs_req1,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	getStatIncrease = function(self, t) return math.floor(self:combatTalentSpellDamage(t, 2, 10)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = t.getStatIncrease(self, t)
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = power,
				[self.STAT_DEX] = power,
				[self.STAT_MAG] = power,
				[self.STAT_WIL] = power,
				[self.STAT_CUN] = power,
				[self.STAT_CON] = power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local statinc = t.getStatIncrease(self, t)
		return ([[You concentrate on your inner self, increasing all your stats by %d.
		The stat increase will improve with your Spellpower.]]):
		format(statinc)
	end,
}

newTalent{
	name = "Curative Canticle",
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
		return ([[The user magically taps into their sustained powers, siphoning off a portion of the energy to restore the user's stamina.
		Increases stamina regen by %0.2f per active sustain. Turning this talent on does not take a turn.]]):format(t.getStaminaMultiplier(self,t))
	end,
}

newTalent{
	name = "Expression of Endurance",
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
		return ([[Enchants the user's armor, making it lighter and capable of absorbing damage and converting it to mana.  Reduces fatigue by %d%% and reduces all sources of damage by %d. Restores %d%% of the damage absorbed as mana.
		Turning this talent on does not take a turn.]]):format(power,t.getDamageReduction(self,t),t.getManaRatio(self,t)*100)
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

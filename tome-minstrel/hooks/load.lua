local DamageType = require "engine.DamageType"
local class = require "engine.class"
local Birther = require "engine.Birther"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"

class:bindHook("ToME:load", function(self, data)
	ActorTalents:loadDefinition("/data-minstrel/talents/techniques/techniques-minstrel.lua")
	ActorTalents:loadDefinition("/data-minstrel/talents/cunning/cunning.lua")
	-- ActorTalents:loadDefinition("/data-minstrel/talents/misc/misc.lua")		Bugged with "T_GLOBAL_CD" for some inexplicable reason, so commented out for now.
	ActorTemporaryEffects:loadDefinition("/data-minstrel/mental.lua")
	ActorTemporaryEffects:loadDefinition("/data-minstrel/other.lua")
	ActorTemporaryEffects:loadDefinition("/data-minstrel/physical.lua")
	Birther:loadDefinition("/data-minstrel/birth/classes/minstrelclass.lua")
end)

class:bindHook("Entity:loadList", function(self, data)
	if data.file == "/data/general/objects/world-artifacts.lua" then
	self:loadList("/data-minstrel/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
    end
end)
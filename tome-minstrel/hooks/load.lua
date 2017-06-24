local DamageType = require "engine.DamageType"
local class = require "engine.class"
local Birther = require "engine.Birther"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"

class:bindHook("ToME:load", function(self, data)
	ActorTalents:loadDefinition("/data-minstrel/talents/techniques/techniques-minstrel.lua")
	ActorTemporaryEffects:loadDefinition("/data-minstrel/mental.lua")
	Birther:loadDefinition("/data-minstrel/birth/classes/minstrelclass.lua")
end)

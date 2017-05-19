local ActorTalents = require "engine.interface.ActorTalents"
local class = require "engine.class"
local Birther = require "engine.Birther"

class:bindHook("ToME:load", function(self, data)
	ActorTalents:loadDefinition("/data-minstrel/talents/techniques/techniques-minstrel.lua")
	Birther:loadDefinition("/data-minstrel/birth/classes/minstrelclass.lua")
end)

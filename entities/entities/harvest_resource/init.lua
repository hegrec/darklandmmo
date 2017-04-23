AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:KeyValue(key,value)




end

function ENT:Initialize()
	self.Entity:SetModel(self.Resource.Table.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
 
	self:SetUseType(SIMPLE_USE)

end
function ENT:Use(activator, caller)

end
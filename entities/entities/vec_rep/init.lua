--AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	self:SetUseType(SIMPLE_USE)
	self:SetMaterial("models/debug/debugwhite")
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	
end 

function ENT:SetTable(t)
	self.Tbl = t	
end
function ENT:SetIndex(ind)
	self.Index = ind
end
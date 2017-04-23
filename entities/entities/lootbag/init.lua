--AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()

	self:SetModel("models/darkland/rpg/misc/moneybag.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
 
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	
	self:SetUseType(SIMPLE_USE)
	self.Loot = {}
	local e = EffectData()
	e:SetEntity(self)
	e:SetOrigin(self:GetPos())
	util.Effect("lootbagGlow",e)
end 

function ENT:AddLoot(item)
	
	table.insert(self.Loot,item)
	
end
function ENT:Use(activator, caller)

end
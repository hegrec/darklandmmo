--AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



function ENT:Initialize()
	self.Entity:SetModel("models/Gibs/HGIBS.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
 
	self:SetUseType(SIMPLE_USE)
	
	self.PhysObj = self.Entity:GetPhysicsObject()
    if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity( false )
		self.PhysObj:EnableDrag( false ) 
		self.PhysObj:SetMass(30)
        self.PhysObj:Wake()
    end
	
	if self.effect then
		local e = EffectData()
		e:SetEntity(self)
		e:SetOrigin(self:GetPos())
		util.Effect(self.effect,e)
	end
	self.startPos = self:GetPos()
end


function ENT:PhysicsUpdate(phy) 

	phy:SetVelocity(self.moveAng*2000)
	if self:GetPos():Distance(self.startPos) > self.flyDist then self:Remove() end

end


function ENT:PhysicsCollide(data,phys)

	self:Remove()
	local ent = data.HitEntity
	if !ent:IsWorld() then
		ent:TakeDamage(self.baseDamage,self:GetOwner(),self:GetOwner())
	end
end
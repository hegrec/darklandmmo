--AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



function ENT:Initialize()
	self.Entity:SetModel("models/crossbow_bolt.mdl")
	self.Entity:PhysicsInit(SOLID_BBOX)
	self.Entity:SetMoveType(MOVETYPE_FLYGRAVITY)
	self.Entity:SetSolid(SOLID_BBOX)
	self.Entity:PhysicsInitBox(Vector(-0.3,-0.3,-0.3), Vector(0.3,0.3,0.3))
 
	self:SetUseType(SIMPLE_USE)
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	self:SetGravity(0.05)
    if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity( true )
		self.PhysObj:EnableDrag( true ) 
		self.PhysObj:SetMass(30)
        self.PhysObj:Wake()
    end
	self.startPos = self:GetPos()
	self:SetAngles(self.moveAng:Angle())
	self.Projectile = true
	self.PhysObj:SetVelocity(self.moveAng*2500)
end


function ENT:PhysicsUpdate(phy) 

	
	if self:GetPos():Distance(self.startPos) > self.flyDist then self:Remove() end

end


function ENT:PhysicsCollide(data,phys)
	
	self:Remove()
	local ent = data.HitEntity
	if !ent:IsWorld() then
		ent:TakeDamage(self.baseDamage,self:GetOwner(),self:GetOwner())
	end
end
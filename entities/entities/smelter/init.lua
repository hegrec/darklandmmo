



AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetModel("models/props_wasteland/laundry_dryer002.mdl")
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	self:SetUseType(SIMPLE_USE)
	
	
end 

function ENT:Use(activator, caller)

end
function ENT:OnSmelt(pl)
	
	for i,v in pairs(pl.Inventory) do
		local t = items.Get(i)
		if t.MineDelay then
			local refinedOre = string.Trim("Refined "..string.sub(i,1,string.find(i," ")))
			local num = math.floor(v * t.SmeltRate)
			pl:AddItem(refinedOre,num)
			pl:TakeItem(i,v)
		end
	end
end
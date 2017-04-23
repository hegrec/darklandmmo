--AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:KeyValue(key,value)

	if key == "ore" then
		self:SetResource(value)
	end


end

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
 
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end	
	
	self:SetUseType(SIMPLE_USE)
	
	
end 

function ENT:SetResource(index)
	local tbl = items.Get(index)
	self:SetModel(tbl.HolderModel)
	self.OreIndex = index
	--self:SetMaterial("models/debug/debugwhite")
	local col = tbl.HolderModel
	self:SetColor(col.r,col.g,col.b,255)	
end
function ENT:Use(activator, caller)

end
function ENT:IsMined(pl)
	local num = math.random(1,3)
	pl:AddItem(self.OreIndex,num)
end

function ENT:GetResource()

	return self.OreIndex
	
end
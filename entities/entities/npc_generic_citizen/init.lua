AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include('shared.lua') 


function ENT:SetupNPC()
	local race = self.Properties.Race
	local gender = self.Properties.Gender
	local raceTBL = Races[race]
	if gender == "Male" then
		self:SetModel(raceTBL.MaleModel)
	else
		self:SetModel(raceTBL.FemaleModel)
	end
	self:SetTargetPos(self:GetPos())
	self.WalkSpeed = 200
	self.RunSpeed = 300
	self:SetAction(ACTION_WANDER)


end



 ENT.Base = "base_entity" 
 ENT.Type = "anim"
 ENT.AutomaticFrameAdvance = false
 
 
 
ACTION_IDLE = 1
ACTION_WANDER = 2
ACTION_CHASE = 3
ACTION_ATTACK = 4



function ENT:SetupDataTables()

	self:DTVar( "Vector", 0, "TargetPosition" );
	self:DTVar( "Int", 0, "CurrentAction" );

end

function ENT:GetTargetPos()
	return self.dt.TargetPosition
end

function ENT:GetAction()
	return self.dt.CurrentAction
end
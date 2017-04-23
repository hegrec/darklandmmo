local meta = FindMetaTable("Player")

function meta:LevelSkill(skill,lvls)
	lvls = lvls or 1
	if !self.Skills[skill] then return end
	
	local leftOverXP = self.Skills[skill].XP - self:XPNeeded(skill)
	
	self.Skills[skill].Level = self.Skills[skill].Level + 1
	self.Skills[skill].XP = leftOverXP
	if self.Skills[skill].XP >= self:XPNeeded(skill) then self:LevelProfession(skill,lvls+1) return end --recursive level up
	umsg.Start("LevelSkill",self)
		umsg.String(skill)
		umsg.Char(lvls)
		umsg.Long(leftOverXP)
	umsg.End()
	
	hook.Call("SkillLeveled",GAMEMODE,self,skill)
end

function meta:SkillXP(skill,amt)
	self.Skills[skill].XP = self.Skills[skill].XP + amt
	if self.Skills[skill].XP >= self:XPNeeded(skill) then
		self:Skills(skill)
	else
		umsg.Start("skillsChanged",self)
			umsg.String(skill)
			umsg.Char(self.Skills[skill].Level)
			umsg.Long(self.Skills[skill].XP)
		umsg.End()
	end
end

function meta:GetSkillLevel(skill)
	return self.Skills[skill].Level
end

function meta:XPNeeded(skill)
	return self:GetSkillLevel(skill) * 100
end


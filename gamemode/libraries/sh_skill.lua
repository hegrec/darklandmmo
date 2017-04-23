

local skillList = {}

skills = {}
skills.__index = skills

function skills.RegisterClass(name)
	local skill = {}
	skillList[name] = skill
	skillList[name].Name = name
	setmetatable(skill,skills)
	return skillList[name]
end

function skills.Get(name)
	return skillList[name]
end

function skills.GetAll()
	return skillList
end


function skills:__tostring()

	return "[Skill - "..self.Name.."]"
	
	

end

function skills:GetName()

	return self.Name

end

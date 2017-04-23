local ITEM = skills.RegisterClass("Power Strike")
ITEM.Activate = function(ply,vec)
	local e = EffectData()
	e:SetOrigin(vec)
	e:SetEntity(ply)
	util.Effect("death_spike",e)
end  
ITEM.ManaCost = 1
ITEM.UseDelay = 0.5
ITEM.LearningClass = "Fighter"
ITEM.Icon = "darkland/rpg/abilities/Fighter/Power_Strike"
ITEM.Resources = {"models/darkland/rpg/enviroment/spike.mdl"}
ITEM.Mandala = "darkland/rpg/mandalas/fire"
ITEM.Type = "Magic"
ITEM.Description = [[
	Rupture the earth with a deadly spike.
	
	Effects - 
		30 Blunt Damage
		
	Cooldown - 
		13 Seconds
]]

local ITEM = skills.RegisterClass("Power Thrust")
ITEM.Activate = function(ply,vec)
	local e = EffectData()
	e:SetOrigin(vec)
	e:SetEntity(ply)
	util.Effect("death_spike",e)
end
ITEM.ManaCost = 1
ITEM.UseDelay = 0.5
ITEM.LearningClass = "Fighter"
ITEM.Icon = "darkland/rpg/abilities/Fighter/Power_Thrust"
ITEM.Resources = {"models/darkland/rpg/enviroment/spike.mdl"}
ITEM.Mandala = "darkland/rpg/mandalas/fire"
ITEM.Type = "Magic"
ITEM.Description = [[
	Rupture the earth with a deadly spike.
	
	Effects - 
		30 Blunt Damage
		
	Cooldown - 
		13 Seconds
]]


local ITEM = skills.RegisterClass("Power Shot")
ITEM.Activate = function(ply,vec)
	local e = EffectData()
	e:SetOrigin(vec)
	e:SetEntity(ply)
	util.Effect("death_spike",e)
end
ITEM.ManaCost = 1
ITEM.UseDelay = 0.5
ITEM.LearningClass = "Fighter"
ITEM.Icon = "darkland/rpg/abilities/Fighter/Power_Shot"
ITEM.Resources = {"models/darkland/rpg/enviroment/spike.mdl"}
ITEM.Mandala = "darkland/rpg/mandalas/fire"
ITEM.Type = "Magic"
ITEM.Description = [[
	Rupture the earth with a deadly spike.
	
	Effects - 
		30 Blunt Damage
		
	Cooldown - 
		13 Seconds
]]

local ITEM = skills.RegisterClass("Armor Mastery")
ITEM.Activate = function(ply,vec)
	local e = EffectData()
	e:SetOrigin(vec)
	e:SetEntity(ply)
	util.Effect("death_spike",e)
end
ITEM.ManaCost = 1
ITEM.UseDelay = 0.5
ITEM.LearningClass = "Fighter"
ITEM.Icon = "darkland/rpg/abilities/Fighter/Armor_Mastery"
ITEM.Resources = {"models/darkland/rpg/enviroment/spike.mdl"}
ITEM.Mandala = "darkland/rpg/mandalas/fire"
ITEM.Type = "Magic"
ITEM.Description = [[
	Rupture the earth with a deadly spike.
	
	Effects - 
		30 Blunt Damage
		
	Cooldown - 
		13 Seconds
]]


local ITEM = skills.RegisterClass("Weapon Mastery")
ITEM.Activate = function(ply,vec)
	local e = EffectData()
	e:SetOrigin(vec)
	e:SetEntity(ply)
	util.Effect("death_spike",e)
end
ITEM.ManaCost = 1
ITEM.UseDelay = 0.5
ITEM.LearningClass = "Fighter"
ITEM.Icon = "darkland/rpg/abilities/Fighter/Weapon_Mastery"
ITEM.Resources = {"models/darkland/rpg/enviroment/spike.mdl"}
ITEM.Mandala = "darkland/rpg/mandalas/fire"
ITEM.Type = "Magic"
ITEM.Description = [[
	Rupture the earth with a deadly spike.
	
	Effects - 
		30 Blunt Damage
		
	Cooldown - 
		13 Seconds
]]
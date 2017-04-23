local ITEM = skills.RegisterClass("Death Spike")
ITEM.Activate = function(ply,vec)
	local e = EffectData()
	e:SetOrigin(vec)
	e:SetEntity(ply)
	util.Effect("death_spike",e)
end
ITEM.ManaCost = 1
ITEM.UseDelay = 0.5
ITEM.Icon = "darkland/rpg/abilities/fighter/Power_Strike"
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




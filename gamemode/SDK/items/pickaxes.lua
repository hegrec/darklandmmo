

local ITEM = items.RegisterClass("Rusty Pickaxe")
ITEM.OnUse = function(ply,item)
	
end
ITEM.Icon = "darkland/rpg/items/rustypickaxe"
ITEM.Weight = 3.5
ITEM.Description = "An old used pickaxe that has seen better days"
ITEM.Category = "Weapon"
ITEM.EquipAt = "Weapon"
ITEM.WeaponModel = "models/darkland/rpg/weapons/melee/armingsword.mdl"
ITEM.Range = 70
ITEM.CustomAttack = function(pl,wep) 

	local tr = pl:GetEyeTrace()
	if tr.Entity:IsValid() && tr.Entity:GetClass() == "harvest_resource" && tr.Entity.IsMiningRock then
		if tr.Entity:Distance(pl:GetPos()) < 70 then
			tr.Entity:OnHarvested(pl,wep)
		end
	end

end



local ITEM = items.RegisterClass("Heavy Broadsword")
ITEM.UseDelay = 0.3
ITEM.Icon = "darkland/rpg/items/sword"
ITEM.Range = 70
ITEM.BaseDamage = {3,5}
ITEM.WeaponType = WEAPON_BLADE
ITEM.Effect = "SwordFlame" --TODO
ITEM.WeaponModel = "models/darkland/rpg/weapons/melee/spatha.mdl"
ITEM.Category = "Weapon"
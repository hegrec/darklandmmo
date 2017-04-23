


local ITEM = items.RegisterClass("Blood Meal")
ITEM.OnUse = function(ply,item)
	
	ply:PotionHeal(10)

end
ITEM.Icon = "darkland/rpg/items/bloodmeal"
ITEM.Weight = 0.2
ITEM.Description = "A sampling of blood from a corpse"
ITEM.Category = "Raw Materials"
local ITEM = items.RegisterClass("Lesser Healing Potion")
ITEM.OnUse = function(ply,item)
	
	ply:PotionHeal(25)

end
ITEM.Icon = "darkland/rpg/items/healthpot"
ITEM.Weight = 0.2
ITEM.Description = "A concauction of different herbal substances used for healing small wounds"
ITEM.Category = "Potions"
local ITEM = items.RegisterClass("Greater Healing Potion")
ITEM.OnUse = function(ply,item)
	
	ply:PotionHeal(70)

end
ITEM.Icon = "darkland/rpg/items/healthpot"
ITEM.Weight = 0.2
ITEM.Description = "A concauction of different herbal substances used for healing small wounds"
ITEM.Category = "Potions"

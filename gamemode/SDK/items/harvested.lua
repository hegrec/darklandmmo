
local ITEM = items.RegisterClass("Medicor Leaves")
ITEM.OnUse = function(ply,item)
	pl:HealPotion(5)
end
ITEM.Icon = "darkland/rpg/items/medicor"
ITEM.GatherTime = 15
ITEM.HolderModel = "models/darkland/rpg/enviroment/plants/plant_weed.mdl"
ITEM.Weight = 0.1
ITEM.HerbProperties = {HERB_RESTORE}
ITEM.Category = "Raw Materials"
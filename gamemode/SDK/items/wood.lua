

local ITEM = items.RegisterClass("Wood")
ITEM.OnUse = function(ply,item)
	
	

end
ITEM.Icon = "darkland/rpg/items/wood"
ITEM.Weight = 1
ITEM.Description = "Good ole' logs from a tree"
ITEM.Category = "Misc"
ITEM.OnHarvest = function(ply,ent) ent:SetModel("models/props_foliage/tree_stump01.mdl") end


local res = harvest.DefineResource("Evergreen Tree")
res.Model = "models/props_foliage/tree_pine04.mdl"
res.OnHarvest = function(pl,resource) end
res.ModelOffset = Vector(0,0,-20)
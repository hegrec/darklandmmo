--[[Currently Supported Table Vars for resources:

Name = "Redwood Tree" --defining name for this resource
OnHarvest = function(pl,resource) end --what happens when you harvest this resource (add your items and change models or colors and stuff in here
Model = "models/props_foliage/tree_pine_01.mdl" --default model for the resource, can be changed per resource once they are instantiated as a harvestable object (the vector based object)

]]


GRID_SIZE = 64 --amount of chunks
GRID_LEN = math.sqrt(GRID_SIZE)
CHUNK_LEN = -1 --default


local resourceList = {}
local resourceNames = {}
harvest = {}
harvest.__index = harvest

function harvest.DefineResource(name)
	local t = {Name = name}
	local id = table.insert(resourceList,t)
	local tbl = resourceList[id]
	t.Index = id
	resourceNames[name] = tbl
	return tbl
end

function harvest:__tostring()

	return "[Resource - "..self.Table.Name.."]"
	
	

end

function harvest.GetResourceTable(id)

	return resourceList[id]

end

function harvest.GetResourceTableByName(name)

	return resourceNames[name]

end

function harvest.GetResourceList()
	return resourceList
end


local function CacheModelInfo()

	for i,v in pairs(resourceList) do
		if v.Model then
			local ent = ents.Create("prop_physics")
			ent:SetModel(v.Model)
			ent:Spawn()
			
			resourceList[i].OBBMax = ent:OBBMaxs()
			resourceList[i].OBBMin = ent:OBBMins()
			ent:Remove()
		end
	end


end
hook.Add("InitPostEntity","CacheModelInfo",CacheModelInfo)
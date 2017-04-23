spawnedDungeons = {}
dungeon = {}
local dungeonList = {}
function dungeon.CreateItem(scenarioName)
	dungeonList[scenarioName] = dungeonList[scenarioName] or {} --holds items
	
	local id = table.insert(dungeonList[scenarioName],{})
	return dungeonList[scenarioName][id]
end
function dungeon.GetDungeons()
	return dungeonList
end
function dungeon.GetCaveSetup(name)
	for i,v in pairs(dungeonList) do
		if i == name then
			return v
		end
	end
end
function dungeon.IsSpawnedForPlayer(name,area,inst)
	if !spawnedDungeons[name] then return false end
	if !spawnedDungeons[name][area] then return false end
	if spawnedDungeons[name][area][inst] then return true end
	
	return false

end

function dungeon.Clear(name,area,inst)
	
	for i,v in pairs(spawnedDungeons[name][area][inst]) do
		if ValidEntity(v) then
			v:Remove()
		end
	end
	spawnedDungeons[name][area][inst] = {}
end

function dungeon.GetAIMap(areaID)
	return area.GetAIMap(areaID)
end
function dungeon.LoadDungeon(pl,name)
	local t = dungeon.GetCaveSetup(name)
	--if !t || dungeon.IsSpawnedForPlayer(name,pl:GetInstanceName(),pl:GetInstance()) then return end
	for i,v in pairs(t) do
		if Areas[v.Properties.AreaID] && Areas[v.Properties.AreaID].Name == pl:GetInstanceName() then
			
			spawnedDungeons[name] = spawnedDungeons[name] or {}
			spawnedDungeons[name][pl:GetInstanceName()] = spawnedDungeons[name][pl:GetInstanceName()] or {}
			spawnedDungeons[name][pl:GetInstanceName()][pl:GetInstance()] = spawnedDungeons[name][pl:GetInstanceName()][pl:GetInstance()] or {}
			dungeon.LoadDungeonItem(v,name,pl)
		end
	end
end
function dungeon.LoadDungeonItem(t,name,pl)
	local item = ents.Create(t.Properties.ClassName)
	item.Properties = t.Properties
	local ang = pl:GetAngles()
	item:SetPos(t.Properties.Pos)
	item:SetAngles(t.Properties.Ang)
	item:Spawn()
	item:SetInstance(pl:GetInstance(),pl:GetInstanceName())
	table.insert(spawnedDungeons[name][pl:GetInstanceName()][pl:GetInstance()],item)
	
end
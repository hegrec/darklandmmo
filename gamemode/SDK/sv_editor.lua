require("datastream")
AddCSLuaFile("cl_editor.lua")
AddCSLuaFile("cl_animeditor.lua")
tmysql.query([[CREATE TABLE IF NOT EXISTS rpg_nodegraphs (
ID int(10) auto_increment PRIMARY KEY NOT NULL,
StartVector varchar(40) default '0 0 0',
MapName varchar(40) default '',
GridSize smallint(3) default 256,
MaxDistance smallint(5) default -1,
AreaID smallint(5) default 0)]])



function GenerateAIMaps(tbl)

	for i,v in pairs(tbl) do
		local vec = string.Explode(" ",v.StartVector)
		vec = Vector(vec[1],vec[2],vec[3])
		PrintTable(v)
		BuildAIMap(nil,nil,{v.AreaID,v.GridSize,v.MaxDistance,vec},true)
	end

end
hook.Add("InitPostEntity","LoadAIMaps",function()
tmysql.query("SELECT StartVector,AreaID,GridSize,MaxDistance FROM rpg_nodegraphs WHERE MapName='"..tmysql.escape(game.GetMap()).."'",function(res,stat,err) print(err) GenerateAIMaps(res) end,1)
end)








local DoorPropertyList = {}
function SetDoorProperties(pl,cmd,args)
	
	if !pl.IsEditing then return end
	
	local ent = ents.GetByIndex(args[1])
	if !ent then return end
	local name = args[2]
	ent:SetName(name)
	local goesto = args[3]
	local targetAreaID = tonumber(args[4])
	local areaID = tonumber(args[5])
	if goesto == "None (Use for instanced doors)" then
		ent:SetProperty("GoesTo",nil)
	else
		ent:SetProperty("GoesTo",goesto)
		
	end
	ent:SetNWString("GoesTo",ent:GetProperty("GoesTo"))
	if Areas[targetAreaID] then
		ent:SetTargetArea(targetAreaID)
		ent:SetProperty("TargetArea",targetAreaID)
	end
	if Areas[areaID] then
		ent:SetArea(areaID)
		ent:SetProperty("Area",areaID)
	end

	ent.SaveEntity = true
	SaveMap()
	
	
end
concommand.Add("setdoorproperties",SetDoorProperties)



playerLoadedSetupEnts = {}

function LoadDungeonSetup(pl,cmd,args)
	if !pl.IsEditing then return end
	local setupName = args[1]
	local t = dungeon.GetCaveSetup(setupName)
	if !t then return end
	playerLoadedSetupEnts[pl:SteamID()] = playerLoadedSetupEnts[pl:SteamID()] or {}
	
	for i,v in pairs(playerLoadedSetupEnts[pl:SteamID()]) do
		if type(v) != "table" && ValidEntity(v) then
			v:Remove()
		end 
	end
	
	
	
	for i,v in pairs(t) do
		if v.Properties then
			local ent = ents.Create(v.Properties["ClassName"])
			ent.Properties = v.Properties
			ent:SetPos(v.Properties["Pos"]+Vector(0,0,10))
			ent:SetAngles(v.Properties["Ang"])
			ent:Spawn()
			table.insert(playerLoadedSetupEnts,ent)
		end
	end
	
	
end
concommand.Add("loaddungeonsetup",LoadDungeonSetup)



function PlaceItem(pl,handler,id,encoded,decoded)
	if !pl.IsEditing then return end
	local itemInfo = decoded
	
	
	
	
	itemInfo.Spawner = pl
	
	
	
	local pos = itemInfo.Pos
	local areaID = itemInfo.AreaID
	itemInfo.Properties.AreaID = areaID
	local id = itemInfo.itemClassID
	local tbl = PlaceableEntities[id]
	
	
	if !Areas[areaID] then return end
	if !tbl then return end
		
	if itemInfo.Properties.IsArea then
		area.AddItem(nil,PlaceableEntities[itemInfo.itemClassID].ClassName,itemInfo.Properties,nil,pos,pl:GetAngles(),false,pl)
	else
		itemInfo.Properties.ScenarioName = string.gsub(itemInfo.ScenarioName or "","`","")
		if string.len(itemInfo.ScenarioName) < 3 then return end
		
		if !dungeon.ScenarioExists(itemInfo.ScenarioName) then
			dungeon.CreateScenario(itemInfo.ScenarioName)
		end
		
		
		dungeon.AddItem(itemInfo)
	
		local ent = ents.Create(tbl.ClassName)
		ent.Properties = itemInfo.Properties
		ent:SetPos(pos)
		ent:SetAngles(pl:GetAngles())
		ent:SetNWBool("deletable",true)
		ent:Spawn()
		if ent:IsNPC() then
			ent:SetPos(pos+Vector(0,0,10))
		end
		playerLoadedSetupEnts[pl:SteamID()] = playerLoadedSetupEnts[pl:SteamID()] or {}
		table.insert(playerLoadedSetupEnts,ent)
	end

end
datastream.Hook("itemplace",PlaceItem)



function GenForest(pl,cmd,args)

	local num = tonumber(args[1]) or 100
	harvest.ForestBuilder(pl,num)


end
concommand.Add("genforest",GenForest)

function PaintResource(pl,cmd,args)
	if !pl.IsEditing then return end
	local resType = args[1]
	local vec = Vector(args[2],args[3],args[4])
	harvest.Create({ResType = resType},vec,false,nosave)
end
concommand.Add("painttree",PaintResource)


function DeleteItem(pl,cmd,args)
	if !pl.IsEditing then return end
	local ent = ents.GetByIndex(args[1])
	
	if ent.Object then --deleting a vector representor
	
		local obj = ent.Object
		local id = obj.DatabaseID or -1
		if obj.IsEmitter then
			obj:Remove() --make a remove function for any vector based objects
		elseif obj.IsDoorExit then
			doorExits[obj.Name][obj.ID] = nil
		end
		tmysql.query("DELETE FROM rpg_mapsetup WHERE ID="..id)
		ent:Remove()
		return
	end
	SaveMap()
	
end
concommand.Add("deleteitem",DeleteItem)

local editors = {}
local SpawnedEnts = false

function ToggleEditor(pl,cmd,args)
	if pl.IsEditing then
		pl.IsEditing = false
		pl:SetMoveType(MOVETYPE_WALK)
		table.remove(editors,pl.EditorIndex)
		hook.Call("PlayerLeftEditor",GAMEMODE,pl,table.getn(editors))
	else
		pl:SetMoveType(MOVETYPE_NOCLIP) --noclip edit
		pl.IsEditing = true
		pl.EditorIndex = table.insert(editors,pl)
		ToggleRepresentors(true)
		hook.Call("PlayerEnteredEditor",GAMEMODE,pl,table.getn(editors))
	end
	
	umsg.Start("editorToggled",pl)
		umsg.Bool(pl.IsEditing)
	umsg.End()


end
concommand.Add("rpg_editor",ToggleEditor)


local repList = {}
function ToggleRepresentors(b)

	if b then
		hook.Call("PlayerEnteredEditor",GAMEMODE)
	else
		for i,v in pairs(repList) do
			if v:IsValid() then
				v:Remove()
			end
		end
		repList = {}
	end
	SpawnedEnts = true
end

function UpdateRepresentors(obj,vec,name)
	if table.getn(editors) == 0 then
		return
	end
	local ent = ents.Create("vec_rep")
	ent:SetPos(vec)
	ent:SetName(name)
	ent.Object = obj
	ent:Spawn()
	table.insert(repList,ent)
end

tmysql.query([[CREATE TABLE IF NOT EXISTS rpg_mapsetup (
ID int(10) auto_increment primary key not null,
ClassName varchar(40),
MapName varchar(30),
Properties text,
MapIndex smallint(5) default -1,
Location varchar(30) default '0000.0000 0000.0000 0000.0000',
Angles varchar(30) default '0000.0000 0000.0000 0000.0000')
]])


--[[
Class - Can start with "~" to specify a non entity based entity "~resource", or without ~ will load as a single entity
]]
function SaveObjectToMap(class,properties,pos,ang,obj)
	local databaseID = obj.DatabaseID
	local str = SaveProperties(properties)
	pos = math.Round(pos.x).." "..math.Round(pos.y).." "..math.Round(pos.z)
	ang = math.Round(ang.pitch).." "..math.Round(ang.yaw).." "..math.Round(ang.roll)
	local safeID = ""
	local includeText = ""
	if getmetatable(obj) == FindMetaTable("Entity") && obj.HammerID then
		safeID = ",MapIndex="..SaveGoodIndex(ent)
		includeText = ",MapIndex"
	end
	if databaseID then
		tmysql.query("UPDATE rpg_mapsetup SET ClassName='"..tmysql.escape(class).."',MapName='"..tmysql.escape(game.GetMap()).."',Properties='"..tmysql.escape(str).."',Location='"..pos.."',Angles='"..ang.."'"..safeID.." WHERE ID="..databaseID)
	else
		if string.len(safeID) > 0 then
			safeID = ","..SaveGoodIndex(ent)
		end
		tmysql.query("INSERT INTO rpg_mapsetup (ClassName,MapName,Properties,Location,Angles"..includeText..") VALUES ('"..tmysql.escape(class).."','"..tmysql.escape(game.GetMap()).."','"..tmysql.escape(str).."','"..pos.."','"..ang.."'"..safeID..")",function(res,stat,lastid) obj.DatabaseID = lastid end,2)
	end

end

local mapLoadHooks = {}
function AddMapLoadHook(class,func)
	mapLoadHooks[class] = func
end




local function loadMapCallback(tbl,stat,err)
	for i,v in pairs(tbl) do
		local vec = string.Explode(" ",v.Location)
		vec = Vector(vec[1],vec[2],vec[3])
		local ang = string.Explode(" ",v.Angles)
		ang = Angle(ang[1],ang[2],ang[3])
		if string.find(v.ClassName,"~") == 1 && mapLoadHooks[v.ClassName] then 
			timer.Simple(0.005*i,function() mapLoadHooks[v.ClassName](v.ID,LoadProperties(v.Properties),vec,ang) end)
		else
			local vec = string.Explode(" ",v.Location)
			vec = Vector(vec[1],vec[2],vec[3])
			local ang = string.Explode(" ",v.Angles)
			ang = Angle(ang[1],ang[2],ang[3])
			area.AddItem(v.ID,v.ClassName,LoadProperties(v.Properties),v.MapIndex,vec,ang,true)
			--[[
			local ent = ents.Create(v.ClassName)
			ent.Properties = LoadProperties(v.Properties)
			ent:SetPos(vec)
			ent:SetAngles(ang)
			--ent:SetNWBool("deletable",true)
			ent:Spawn()
			if ent:IsNPC() then
				ent:SetPos(pos+Vector(0,0,10))
			end]]
		end
	end

end



function BeginLoadMap()


	tmysql.query("SELECT ID,ClassName,Properties,MapIndex,Location,Angles FROM rpg_mapsetup WHERE MapName='"..tmysql.escape(game.GetMap()).."'",loadMapCallback,1)

end
hook.Add("InitPostEntity","LoadTheMap",BeginLoadMap)




function SaveProperties(tbl)
	if type(tbl) != "table" || table.Count(tbl) == 0 then
		return ""
	end
	local vars = {}
	for i,v in pairs(tbl) do
		local varType = type(v)
		local str
		if varType == "number" then
			str = VAR_NUMBER
			str = str .. ":"..i..":"..tostring(v)
		elseif varType == "string" then
			str = VAR_STRING
			str = str .. ":"..i..":"..tostring(v)
		elseif varType == "boolean" then
			str = VAR_BOOL
			str = str .. ":"..i..":"..tostring(v)
		elseif varType == "Vector" then
			str = VAR_VECTOR
			str = str .. ":"..i..":"..math.Round(v.x).." "..math.Round(v.y).." "..math.Round(v.z)
		elseif varType == "Angle" then
			str = VAR_ANGLE
			str = str .. ":"..i..":"..math.Round(v.pitch).." "..math.Round(v.yaw).." "..math.Round(v.roll)
		end
		
		table.insert(vars,str)
	end
	return table.concat(vars,"|")
	
end


function SaveGoodIndex(ent)
	return ent:EntIndex() - MaxPlayers()
end
function LoadGoodIndex(int)
	return ents.GetByIndex(tonumber(int)+MaxPlayers())
end
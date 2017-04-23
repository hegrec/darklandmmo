tmysql.query([[CREATE TABLE IF NOT EXISTS rpg_characters (
ID int(10) auto_increment PRIMARY KEY NOT NULL,
SteamID varchar(30) default "STEAM_ID_NULL",
Name varchar(30) default "Unnamed",
CharID tinyint(4) default 1,
Skills text,
Disposition text,
Attributes text,
Quests text,
XP int(10) default 0,
Level tinyint(3) default 1,
Class varchar(40) default '',
ClassTree varchar(40) default '',
Money int(10) default 0,
Gender tinyint(1),
Race varchar(40)
GuildID int(10) default -1,
GuildRank tinyint(2) default 0,
GuildJoinDate int(10) default 0,
Equipped text,
AttributePoints smallint(3) default 0,
SpawnPos varchar(40))]])

tmysql.query([[CREATE TABLE IF NOT EXISTS rpg_items (
ID int(10) auto_increment PRIMARY KEY NOT NULL,
OwnerID int(10) default -1,
ItemName varchar(200) default '',
ItemVars text)]])

function CreateCharacter(pl,cmd,args)

	if !pl.CharsPrecached then return end
	
	if pl.NumChars >= MAX_CHARACTERS || pl.AlreadyLoaded then return end

	local tree		= args[1]
	local name		= args[2]
	local gender	= tonumber(args[3]) or -1
	local race 	= args[4]
	
	if Races[race] == nil then filex.Append("hackingAttempts.txt",pl:GetName().." - "..pl:SteamID().." - Sent invalid race\n") return end
	if gender != 1 && gender != 0 then filex.Append("hackingAttempts.txt",pl:GetName().." - "..pl:SteamID().." - Sent invalid gender\n") return end
	if !ClassTrees[tree] then filex.Append("hackingAttempts.txt",pl:GetName().." - "..pl:SteamID().." - Sent invalid classtree\n") return end
	if !table.HasValue(Races[race].ClassTrees,tree) then filex.Append("hackingAttempts.txt",pl:GetName().." - "..pl:SteamID().." - Sent non race appropriate class tree\n") return end
	
	
	pl.NumChars 	= pl.NumChars + 1
	pl.ClassTree	= tree
	pl.Class		= tree --the first class you get IS the name of the class tree
	pl.CharName 	= name
	pl.Gender		= gender
	pl.Race			= race
	pl.SpawnPos 	= STARTSPAWN


	
	--Class Adds
	
	local t = ClassTrees[pl.ClassTree][pl.Class]
	for i,v in pairs(t.AttributeIncrease) do
		pl.Attributes[i] = pl.Attributes[i] + v
	end

	
	local t = {}
	for i,v in pairs(pl.Skills) do
		table.insert(t,i..":"..v)
	end
	local strSkill = tmysql.escape(table.concat(t,"|"))
	local atts = table.DoSaveConvert(pl.Attributes)




	tmysql.query("INSERT INTO rpg_characters (SteamID,Name,CharID,Quests,Skills,ClassTree,Class,Attributes,Gender,Race,Equipped) VALUES ('"..pl:SteamID().."','"..tmysql.escape(name).."','"..pl.NumChars.."','','"..tmysql.escape(strSkill).."','"..pl.ClassTree.."','"..pl.ClassTree.."','"..atts.."','"..gender.."','"..race.."','')",function(res,stat,lastid) FinishUpChar(pl,lastid) end,2)
end
concommand.Add("~np",CreateCharacter)

--[[
Character was just created or we selected one of 3 characters to load
]]
function FinishUpChar(pl,oldTable,tbl)
	local id
	if type(oldTable) == "number" then
		pl.CharacterIndex = oldTable
		oldTable = {}
	else
		pl.CharacterIndex = oldTable.ID
	end
	
	
	--this only updates the finished npc kills as the items are already on the client by shared quests and the inventory
	for i,v in pairs(pl.Quests) do
		umsg.Start("getQuest",pl)
		umsg.String(i)
		umsg.Char(v.CurrentPart)
		for i,v in pairs(v.Parts) do
			if v.Kills then
				for i,v in pairs(v.Kills) do
					umsg.Char(v)
				end
			end
			if v.Items then
				for i,v in pairs(v.Items) do
					umsg.Char(v)
				end
			end
		end
		umsg.End()
	end

	for i,v in pairs(pl.Skills) do
		umsg.Start("addSkill",pl)
			umsg.String(i)
		umsg.End()
	end
	
	
	if tbl then
		for i,v in pairs(tbl) do
			local item = items.Create(v.ItemName,v.ItemVars,v.ID,true)
			pl:LoadItem(item)
		end
	end
	
	
	local t2 = string.Explode("|",oldTable.Equipped or "")
	if table.Count(t2) > 0 then
		for i,v in pairs(t2) do
			local t 		= string.Explode(":",v)
			local spot		= t[1]
			local item		= pl.Inventory[tonumber(t[2])]
			if !item then break end
			pl:EquipItem(spot,item)
		end
	end
		
	pl:SetNWString("CharName",pl.CharName)
	pl:SyncAttributes()
	
	
	umsg.Start("getBasics",pl)
		umsg.String(pl.ClassTree)
		umsg.String(pl.Class)
		umsg.Long(pl.XP)
		umsg.Char(pl.Level)
		umsg.Short(pl.MaxStamina)
		umsg.Long(pl.Money)
		umsg.String(pl.CharName)
		umsg.Short(pl.AttributePoints)
		umsg.Char(id)
	umsg.End()

	
	pl:Freeze(false)
	pl:Spawn()
	pl.TempChars = nil
	hook.Call("PlayerProfileLoaded",GAMEMODE,pl)
end

--[[
Preload Characters (all 3 if applicable)
]]
function needCharacter(pl,cmd,args)

	if pl.AlreadyLoaded then return end
	
	
	pl.Skills	 		= {} --Holds skills seperate from items
	pl.MiscVars			= {}
	pl.Inventory 		= {} --Holds items
	pl.skillCharges 	= {} --Stores the times you used an skill (magic or melee) so you can't use it without the charge time going down first
	pl.NumChars 		= 0  --This is a number of characters
	pl.TempChars		= {} --This will hold preloaded characters if any and be deleted after you load a character
	pl.Quests			= {}
	pl:Freeze(true)			 --No moving when you spawn until after you load a character
	pl.Level			= 1
	pl.XP				= 0
	pl.Money			= 10
	pl.InitMoney		= 10
	pl:SetMana(100)
	pl:SetMaxMana(100)
	pl.Stamina			= 100
	pl.MaxStamina		= 100
	pl.Weight			= 0
	--pl.Skills			= {} --This holds stats like Blade, Mining
	--pl.MajorSkills		= {} -- holds your major skills :D
	pl.NPCDisposition	= {} --not done but holds disposition
	pl.Equipped			= {} --hold names of equipped items
	pl.EquippedEnts		= {} --holds the actual entities that are equipped
	pl.HookedStats		= {} --hold hooks for buffs/debuffs
	pl.InstancedExit	= {}
	pl.AttributePoints	= 0
	--[[
	for i,v in pairs(SkillList) do
		pl.Skills[i] = {}
		pl.Skills[i].Level = 1
		pl.Skills[i].XP = 0
	end]]
	
	pl.Attributes		= {} --Intelligence,...
	for i,v in pairs(Attributes) do
		pl.Attributes[i] = ATTRIBUTE_START
	end	
	
	tmysql.query("SELECT * FROM rpg_characters as C WHERE C.SteamID='"..pl:SteamID().."'",function(tbl,stat,err) PreLoadCharacters(pl,tbl) end,1)

end
concommand.Add("needCharacter",needCharacter)

--Preloading callback
function PreLoadCharacters(pl,tbl)
	if #tbl == 0 then --you have no characters!
		umsg.Start("noCharacters",pl)
		umsg.End()
	end

	--Create a table indexed by character ids
	for i,v in pairs(tbl) do
		pl.TempChars[tonumber(v.CharID)] = v
	end

	--send all characters to the menu
	for i,v in pairs(tbl) do

	local tbl = tbl[i]
	
	

	
		umsg.Start("getCharacter",pl)
			umsg.Char(i)
			umsg.Char(tonumber(tbl.Gender))
			umsg.String(tbl.Name)
			umsg.String(tbl.Class)
			umsg.Short(tbl.Level)
			umsg.String(tbl.Race)
			umsg.Long(tonumber(tbl.CharID))
		umsg.End()
		pl.NumChars = pl.NumChars + 1
	end


	pl.CharsPrecached = true
end

--[[
Load one of X existing characters
]]
function LoadCharacter(pl,cmd,args)


	if !pl.TempChars then return end --already loaded
	
	
	local id 			= tonumber(args[1])
	local t 			= pl.TempChars[id]

	if !t then return end
	pl.CharName			= t.Name
	pl.CharacterIndex	= tonumber(t.ID)
	
	
	local t2 			= string.Explode("|",t.Skills or "")
	if t2[1] == "" then t2 = {} end
	
	
	for i,v in pairs(t2) do
		local t = string.Explode(":",v)
		if skills.Get(t[1]) then
			pl.Skills[t[1]] = tonumber(t[2])
		end
	end

	local attributes 		= table.DoLoadConvert(t.Attributes)
	
	for i,v in pairs(attributes) do
		pl.Attributes[i] = tonumber(v)
		pl:SetNWInt(i,tonumber(v))
	end

	local questString 	= t.Quests
	local quests = glon.decode(questString)
	pl.Quests = quests || {}
	
	pl.XP = tonumber(t.XP) or 0
	pl.Level = tonumber(t.Level) or 0
	
	pl.ClassTree 		= t.ClassTree
	pl.Class			= t.Class
	pl.Gender			= tonumber(t.Gender)
	pl.Race				= t.Race
	pl.Money			= tonumber(t.Money)
	pl.InitMoney		= pl.Money
	pl.AttributePoints 	= tonumber(t.AttributePoints)
	
	if t.SpawnPos != '' then
		local sPos = string.Explode("|",t.SpawnPos)
		
		pl.SpawnPos = {Vector(sPos[1],sPos[2],sPos[3]),Angle(sPos[4],sPos[5],sPos[6])}
	else
		pl.SpawnPos = STARTSPAWN
	end
	
	--[[
	local mSkill = string.Explode(":",t.MajorSkills)
	for i,v in pairs(mSkill) do
		table.insert(pl.MajorSkills,v)
	end]]
	
	
	
	local gID = tonumber(t.GuildID)
	if gID != -1 then
		pl:SetNWInt("GuildID",gID)
	end
	pl:SetNWInt("GuildRank",tonumber(t.GuildRank))
	



	tmysql.query("SELECT * FROM rpg_items WHERE OwnerID="..pl.CharacterIndex,function(tbl,stat,err) FinishUpChar(pl,t,tbl) end,1)

end
concommand.Add("loadCharacter",LoadCharacter)






function SaveSkills(pl) --POSSIBLE PROBLEMS - Old query finishes after a new one. Is that possible? - LAG??? Threaded so it really shouldn't

	--save skills here
	local t = {}
	for i,v in pairs(pl.Skills) do
		table.insert(t,i..":"..v)
	end
	local str = tmysql.escape(table.concat(t,"|"))
	tmysql.query("UPDATE rpg_characters SET Skills='"..str.."' WHERE ID="..pl.CharacterIndex)

end
hook.Add("LearnedSkill","LearnSave",SaveSkills)


function SaveXP(pl)

	tmysql.query("UPDATE rpg_characters SET XP='"..pl.XP.."' WHERE ID="..pl.CharacterIndex)
	
end
hook.Add("PlayerXPAdded","SaveXP",SaveXP)

function SaveLevel(pl)

	tmysql.query("UPDATE rpg_characters SET Level='"..pl.Level.."' WHERE ID="..pl.CharacterIndex)
	
end
hook.Add("PlayerLeveledUp","SaveLevel",SaveLevel)

function SaveEquips(pl)
	local str = table.DoSaveConvert(pl.Equipped)
	tmysql.query("UPDATE rpg_characters SET Equipped='"..tmysql.escape(str).."' WHERE ID="..pl.CharacterIndex)
	
end
hook.Add("PlayerEquippedItem","SaveEquips",SaveEquips)

function SaveClass(pl)
	local str = table.DoSaveConvert(pl.Class)
	tmysql.query("UPDATE rpg_characters SET Class='"..tmysql.escape(str).."' WHERE ID="..pl.CharacterIndex)
	
end


function SaveAttributes(pl)
	local str = table.DoSaveConvert(pl.Attributes)
	tmysql.query("UPDATE rpg_characters SET Attributes='"..tmysql.escape(str).."',AttributePoints="..pl.AttributePoints.." WHERE ID="..pl.CharacterIndex)
	
end
hook.Add("PlayerChoseClass","SaveAttributesClassChoose",SaveAttributes)
hook.Add("PlayerIncreasedAttributes","SaveAttributesIncrease",SaveAttributes)


function AddAttributePoints(pl)
	tmysql.query("UPDATE rpg_characters SET AttributePoints="..pl.AttributePoints.." WHERE ID="..pl.CharacterIndex)
	
end
hook.Add("PlayerLeveledUp","AddAttributePoints",AddAttributePoints)


function DeleteCharacter(pl,cmd,args)
	
	if !pl.TempChars then return end
	local id 			= tonumber(args[1])
	local t 			= pl.TempChars[id]
	if !t then return end
	tmysql.query("DELETE FROM rpg_characters WHERE ID="..tonumber(t.ID))
	pl.NumChars = pl.NumChars - 1
	

end
concommand.Add("deletecharacter",DeleteCharacter)
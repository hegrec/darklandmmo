AddCSLuaFile("cl_guilds.lua")

local activeGuilds = {}

local function _cacheGuild(ID,tbl)

	activeGuilds[ID] = tbl

end
function CacheGuild(ID)
	ID = tonumber(ID)
	if !ID then return end
	tmysql.query("SELECT * FROM rpg_guilds WHERE ID="..ID,function(res,stat,err) _cacheGuild(ID,res) end)
end

function CreateGuild(pl,cmd,args)


	if pl:HasGuild() then 
		pl:ChatPrint("First you need to leave your guild")
		return 
	end
	local name = args[1] or ""
	if string.len(name) < 3 then return end
	local guildName = tmysql.escape(name)
	
	tmysql.query("SELECT ID FROM rpg_guilds WHERE Name='"..guildName.."')",function(res,stat,err)
		PrintTable(res)
		if res[1] then return end
		tmysql.query("INSERT INTO rpg_guilds (OwnerID,MemberCount,Name) VALUES("..pl.CharacterIndex..",1,'"..guildName.."')",function(res,stat,lastID) pl:SetGuild(lastID,true) end,2)
	end)
end
concommand.Add("createguild",CreateGuild)



local meta = FindMetaTable("Player")
function meta:SetGuild(guildID,leader)

	local leadText = ""
	if leader then
		leadText = ",GuildRank="..GUILD_OWNER
		self:SetNWInt("GuildRank",GUILD_OWNER)
	end

	guildID = tonumber(guildID)
	if !guildID then return end
	tmysql.query("UPDATE rpg_characters SET GuildID="..guildID..leadText.." WHERE ID="..self.CharacterIndex)
	self:SetNWInt("GuildID",guildID)
	
	
	
end



function GuildNewsUpdate(pl,cmd,args)

	if !pl:IsGuildOfficer() then return end
	
		local gid = pl:GetGuildID()
		local text = tmysql.escape(args[1])
		
		tmysql.query("INSERT INTO rpg_guildnews (GuildID,Message,TimePosted) VALUES ("..gid..",'"..text.."',"..os.time()..")")
	
	
end
concommand.Add("~gnu",GuildNewsUpdate)
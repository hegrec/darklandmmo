require("datastream")



tmysql.query([[CREATE TABLE IF NOT EXISTS rpg_animations (
ID smallint(5) primary key not null auto_increment,
OwnerSteamID varchar(30) default 'Unknown',
AnimationName varchar(40) default 'DefaultAnimationName',
AnimationData text
)]])

AddCSLuaFile("cl_animation.lua")
include("boneanimlib/boneanimlib.lua")

--resource.AddFile("darkland/rpg/Animations.txt")	


animationCache = {}
local playerAnimationCache = {}
function GetNewAnimation(pl,handler,id,encoded,decoded)
	if !pl.IsEditing then return end
	local animExists = false
	for i,v in pairs(animationCache) do
		if v.Name == decoded.Name then
			animExists = i
			break
		end
	end
	
	if animExists then
		playerAnimationCache[pl] = {animExists,decoded}
		umsg.Start("confirmOverwriteAnimation",pl)
		umsg.End()
		return
	end	
	
	
	
	tmysql.query("INSERT INTO rpg_animations (OwnerSteamID,AnimationName,AnimationData) VALUES('"..pl:SteamID().."','"..tmysql.escape(string.gsub(decoded.Name,"\0","") or "DefaultAnimationName").."','"..tmysql.escape(glon.encode(decoded.Table) or "").."')",function(res,stat,lastid) print(lastid) animationCache[lastid] = {Name = string.gsub(decoded.Name,"\0",""),Table = decoded.Table} umsg.Start("downloadAnimation") umsg.Short(lastid) umsg.End() end,2)
	


end
datastream.Hook("animationset",GetNewAnimation)

local function OverwriteAnim(pl,cmd,args)
	if !pl.IsEditing then return end
	if !playerAnimationCache[pl] then return end
	
	local t = playerAnimationCache[pl]
	animationCache[t[1]] = {Name = t[2].Name,Table = t[2].Table}
	tmysql.query("UPDATE rpg_animations SET AnimationData='"..tmysql.escape(glon.encode(t[2].Table) or "").."' WHERE ID="..t[1],function(res,stat,lastid) umsg.Start("downloadAnimation") umsg.Short(t[1]) umsg.End() end)

end
concommand.Add("overwriteAnim",OverwriteAnim)



function LoadLuaAnimations(tblAnims)
	for i,v in pairs(tblAnims) do
		animationCache[tonumber(v.ID)] = {Name = v.AnimationName,Table = glon.decode(v.AnimationData)}
	end

end
hook.Add("Initialize","LoadLuaAnimations",function() tmysql.query("SELECT ID,AnimationName,AnimationData FROM rpg_animations",function(res,stat,err) LoadLuaAnimations(res) end,1) end)


local meta = _R["Entity"]
function meta:ResetLuaAnimation(sAnimation)
	umsg.Start("resetluaanim")
		umsg.Entity(self)
		umsg.String(sAnimation)
	umsg.End()
end

function meta:SetLuaAnimation(sAnimation)
	umsg.Start("setluaanim")
		umsg.Entity(self)
		umsg.String(sAnimation)
	umsg.End()
end

function meta:StopLuaAnimation(sAnimation)
	umsg.Start("stopluaanim")
		umsg.Entity(self)
		umsg.String(sAnimation)
	umsg.End()
end

function meta:StopLuaAnimationGroup(sAnimation)
	umsg.Start("stopluaanimgp")
		umsg.Entity(self)
		umsg.String(sAnimation)
	umsg.End()
end

function meta:StopAllLuaAnimations()
	umsg.Start("stopallluaanim")
		umsg.Entity(self)
	umsg.End()
end
meta = nil

function animationTest(pl,cmd,args)
	pl:SetLuaAnimation(args[1])	
end
concommand.Add("animtest",animationTest)

include("shared.lua")
include("sv_editor.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("client.lua")







local folders = file.Find("../"..GM.Folder.."/gamemode/SDK/npc_content/*")
for i,name in pairs(folders) do
	--grab all folders of each npc(is this laggy?)
	local files = file.Find("../"..GM.Folder.."/gamemode/SDK/npc_content/"..name.."/*.lua")
	
	--create a holding table cause i like it looking like that more
	local t = {}
	for i,v in pairs(files) do
		t[v] = true
	end
	
	--add files
	if t["server.lua"] then if SERVER then include("npc_content/"..name.."/server.lua") end end
	if t["shared.lua"] then AddCSLuaFile("npc_content/"..name.."/shared.lua") include("npc_content/"..name.."/shared.lua") end
	if t["client.lua"] then AddCSLuaFile("npc_content/"..name.."/client.lua") end
end

local files = file.Find("../"..GM.Folder.."/gamemode/SDK/items/*")
for i,v in pairs(files) do
	AddCSLuaFile("items/"..v)
	include("items/"..v)
end
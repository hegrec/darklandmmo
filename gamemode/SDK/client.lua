include("shared.lua")
function IncludeContent(dir)
	local Files = file.FindInLua(dir.."*")
	
	for k,v in pairs(Files)do
		if(v != "." and v != "..")then
			if(string.GetExtensionFromFilename("../lua/"..dir..v) == "")then
				IncludeContent(dir .. v .. "/")
			elseif v != "server.lua" then
				include(dir..v)
			end			
		end
	end
end
IncludeContent("darklandmmo/gamemode/SDK/npc_content/") --load last
IncludeContent("darklandmmo/gamemode/SDK/items/") --load last


include("cl_editor.lua")


require("datastream")
include("boneanimlib/cl_boneanimlib.lua")

local function DownloadAnimation(um)


	http.Get("http://www.darklandservers.com/animationlist.php?id="..um:ReadShort(),"",function(content,size)
		if string.len(content) < 5 then return end
		local t = string.Explode(" ",string.Trim(content))
		
		
		
			local newName = ""
			for i,v in pairs(string.Explode("",base64_decode(t[2]))) do
				if string.byte(v) != 0 then
					newName = newName .. v
				end
			end
		RegisterLuaAnimation(newName,glon.decode(base64_decode(t[3])))
	end)
end
usermessage.Hook("downloadAnimation",DownloadAnimation)



local function ConfirmAnimationOverwrite()

	Derma_Query( "An animation with that name exists! Overwrite it?", "Warning!",
						"Overwrite", 	function() RunConsoleCommand("overwriteAnim") end, 
						"Cancel", 	function() end
			)

end
usermessage.Hook("confirmOverwriteAnimation",ConfirmAnimationOverwrite)


local function LoadAnimations()

	http.Get("http://www.darklandservers.com/animationlist.php","",function(content,size)
		if string.len(content) < 5 then return end
		local t = string.Explode(" ",string.Trim(content))
		for i=1,table.getn(t),3 do
			local name = base64_decode(t[i+1])
			local tbl = glon.decode(base64_decode(t[i+2]))
			
			local newName = "" --fail ass glon adding \0 to the end of animation names...
			for i,v in pairs(string.Explode("",name)) do
				if string.byte(v) != 0 then
					newName = newName .. v
				end
			end
			RegisterLuaAnimation(newName,tbl)
		end
	end)


end
hook.Add("InitPostEntity","LoadAnimations",LoadAnimations)
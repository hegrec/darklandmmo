

resource.AddFile("materials/darkland/rpg/hud/charcreate/CharacterCreation.vtf")
resource.AddFile("materials/darkland/rpg/hud/charcreate/CharacterCreation.vmt")
resource.AddFile("materials/darkland/rpg/hud/charcreate/RadioButtonSingle16x16.vtf")
resource.AddFile("materials/darkland/rpg/hud/charcreate/RadioButtonSingle16x16.vmt")

resource.AddFile("materials/darkland/rpg/hud/chatbox/ChatBoxLarge2.vtf")
resource.AddFile("materials/darkland/rpg/hud/chatbox/ChatBoxLarge2.vmt")
resource.AddFile("materials/darkland/rpg/hud/chatbox/ChatBoxLargeTalk2.vtf")
resource.AddFile("materials/darkland/rpg/hud/chatbox/ChatBoxLargeTalk2.vmt")

resource.AddFile("materials/darkland/rpg/hud/tradeconf.vtf")
resource.AddFile("materials/darkland/rpg/hud/tradeconf.vmt")

resource.AddFile("materials/darkland/rpg/hud/gosign.vtf")
resource.AddFile("materials/darkland/rpg/hud/gosign.vmt")

resource.AddFile("materials/darkland/rpg/hud/trademenu.vtf")
resource.AddFile("materials/darkland/rpg/hud/trademenu.vmt")

resource.AddFile("materials/darkland/rpg/hud/main.vtf")
resource.AddFile("materials/darkland/rpg/hud/main.vmt")

resource.AddFile("sound/darkland/rpg/actions/drink.mp3")
resource.AddFile("sound/darkland/rpg/actions/levelup.mp3")
resource.AddFile("sound/darkland/rpg/actions/death.mp3")
resource.AddFile("sound/darkland/rpg/music/CharScreen.mp3")


for i,v in pairs(MusicList) do
	for i,_ in pairs(v) do
		resource.AddFile("sound/".._)
	end
end


function IncludeContent(dir)
	local Files = file.Find(dir.."*")
	
	for k,v in pairs(Files)do
		if(string.GetExtensionFromFilename("../sound/"..dir..v) == "")then
			IncludeContent(dir .. v .. "/")
		else
			resource.AddFile(string.sub(dir..v,4))
		end			

	end
end
IncludeContent("../sound/darkland/rpg/npc/")



function IncludeContent(dir)
	local Files = file.Find(dir.."*")
	
	for k,v in pairs(Files)do
		if(string.GetExtensionFromFilename("../materials/"..dir..v) == "")then
			IncludeContent(dir .. v .. "/")
		else
			resource.AddFile(string.sub(dir..v,4))
		end			

	end
end
IncludeContent("../materials/models/darkland/")
IncludeContent("../materials/darkland/rpg/")

IncludeContent("../materials/models/mmorpg/")
IncludeContent("../materials/dwarf/")

function IncludeContent(dir)
	local Files = file.Find(dir.."*")
	
	for k,v in pairs(Files)do
		if(string.GetExtensionFromFilename("../models/"..dir..v) == "")then
			IncludeContent(dir .. v .. "/")
		else
			resource.AddFile(string.sub(dir..v,4))
		end			

	end
end
IncludeContent("../models/darkland/")
IncludeContent("../models/mmorpg/")


resource.AddFile("resource/fonts/nyala.ttf")



resource.AddFile("materials/darkland/rpg/skills/icon_acrobatics.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_alchemy.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_archery.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_blade.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_blunt.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_cooking.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_crafting.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_defence.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_divinity.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_elementalism.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_herbalism.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_looting.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_mining.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_mysticism.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_refining.vtf")
resource.AddFile("materials/darkland/rpg/skills/icon_woodcutting.vtf")


resource.AddFile("materials/darkland/rpg/skills/icon_acrobatics.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_alchemy.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_archery.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_blade.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_blunt.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_cooking.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_crafting.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_defence.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_divinity.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_elementalism.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_herbalism.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_looting.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_mining.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_mysticism.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_refining.vmt")
resource.AddFile("materials/darkland/rpg/skills/icon_woodcutting.vmt")

resource.AddFile("materials/darkland/rpg/particles/lesser_heal_pot.vmt")


resource.AddFile("materials/darkland/rpg/mandala/fire.vtf")
resource.AddFile("materials/darkland/rpg/mandala/fire.vmt")



for i,v in pairs(items.GetAll()) do
	if v.WeaponModel then
		local path = string.sub(v.WeaponModel,1,-5)
		resource.AddFile(path..".mdl")
		resource.AddFile(path..".sw.vtx")
		resource.AddFile(path..".dx90.vtx")
		resource.AddFile(path..".dx80.vtx")
		resource.AddFile(path..".vvd")
	end
	if v.Resources then
		for i,v in ipairs(v.Resources) do
			resource.AddFile(v)
		end
	end
	if v.WeaponMat then

		local path = v.WeaponMat
		
		if type(path) == "table" then
			for i,v in pairs(path) do
				resource.AddFile(v..".vtf")
				resource.AddFile(v..".vmt")
			end
		else
			resource.AddFile(path..".vtf")
			resource.AddFile(path..".vmt")
		end
		
	end
	if v.Icon then
		resource.AddFile("materials/"..v.Icon..".vtf")
		resource.AddFile("materials/"..v.Icon..".vmt")
	end
	if v.Mandala then
		resource.AddFile("materials/"..v.Mandala..".vtf")
		resource.AddFile("materials/"..v.Mandala..".vmt")
	end
end

for i,v in pairs(Attributes) do
	resource.AddFile("materials/"..v.Icon..".vtf")
	resource.AddFile("materials/"..v.Icon..".vmt")
end
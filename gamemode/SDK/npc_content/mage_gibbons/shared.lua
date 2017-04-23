AddNPC("Mage Gibbons","models/gman.mdl")

ClickMenus["Mage Gibbons"] = function (menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Talk To",function() RunConsoleCommand("talkto",ent:EntIndex()) end)
	end
end





Dialog["Mage Gibbons"] = {}
Dialog["Mage Gibbons"].StartingPoint = function(pl)

	if pl:GetDisposition("Blaine Conrad") > 0 then
		return 2
	end
end

Dialog["Mage Gibbons"][1] = {
	Text 		= "Hey, stranger!  I've got all spells in the game! Want em?",
	Replies 	= {1,2}
}
Dialog["Mage Gibbons"][2] = {
	Text 		= "Hey, buddy!  Back for more of my great merchandise eh?",
	Replies 	= {1,2}
}
Dialog["Mage Gibbons"][3] = {
	Text 		= "If you ever change yer' mind, come to me.",
	Replies 	= {3}
}
Dialog["Mage Gibbons"][4] = {
	Text 		= "I didn't wanna teach you anythin' anyways!",
	Replies 	= {3}
}
Dialog["Mage Gibbons"][5] = {
	Text 		= "Well I'm always here, teaching things.",
	Replies 	= {3}
}

Replies["Mage Gibbons"] = {}

Replies["Mage Gibbons"][1] = {
	Text = "Yea",
	OnUse = function(pl,ent) for i,v in pairs(skills.GetAll()) do pl:LearnSkill(i) end end
}
Replies["Mage Gibbons"][2] = {
	Text = "Nah",
	OnUse = function(pl) return math.random(3,5) end
}
Replies["Mage Gibbons"][3] = {
	Text = "[Leave...]",
	OnUse = function(pl) end
}
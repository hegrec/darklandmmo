AddNPC("Blaine Conrad","models/gman.mdl")

ClickMenus["Blaine Conrad"] = function (menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Talk To",function() RunConsoleCommand("talkto",ent:EntIndex()) end)
	end
end





Dialog["Blaine Conrad"] = {}
Dialog["Blaine Conrad"].StartingPoint = function(pl)

	if pl:GetDisposition("Blaine Conrad") > 0 then
		return 2
	end
end

Dialog["Blaine Conrad"][1] = {
	Text 		= "Hey, stranger!  Lookin' for some fine wares are ya?",
	Replies 	= {1,2}
}
Dialog["Blaine Conrad"][2] = {
	Text 		= "Hey, buddy!  Back for more of my great merchandise eh?",
	Replies 	= {1,2}
}
Dialog["Blaine Conrad"][3] = {
	Text 		= "If you ever change yer' mind, come to me.",
	Replies 	= {3}
}
Dialog["Blaine Conrad"][4] = {
	Text 		= "I didn't wanna sell you anythin' anyways!",
	Replies 	= {3}
}
Dialog["Blaine Conrad"][5] = {
	Text 		= "Well I'm always here, selling things.",
	Replies 	= {3}
}

Replies["Blaine Conrad"] = {}

Replies["Blaine Conrad"][1] = {
	Text = "Yea, what do ya have?",
	OnUse = function(pl,ent) pl:OpenStore("Blaine Conrad's General Store",ent) end
}
Replies["Blaine Conrad"][2] = {
	Text = "Nah, I've got what I need",
	OnUse = function(pl) return math.random(3,5) end
}
Replies["Blaine Conrad"][3] = {
	Text = "[Leave...]",
	OnUse = function(pl) end
}
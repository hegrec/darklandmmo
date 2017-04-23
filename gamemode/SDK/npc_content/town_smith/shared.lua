AddNPC("Smith Olnir","models/barney.mdl")

ClickMenus["Smith Olnir"] = function (menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Talk To",function() RunConsoleCommand("talkto",ent:EntIndex()) end)
	end
end


Dialog["Smith Olnir"] = {}
Dialog["Smith Olnir"].StartingPoint = function(pl)

	if pl:ActiveQuest(quest.GetByName("Meeting the Captain")) then
		return 1
	end
	return 5

end

Dialog["Smith Olnir"][1] = {
	Text 		= "Oh, there you are! I've been looking for you a while now",
	Replies 	= {1,2}
}
Dialog["Smith Olnir"][2] = {
	Text 		= "I've just crafted a new weapon, but I've got no one to test it out, and I can't do it myself, getting old you see...",
	Replies 	= {3,4}
}
Dialog["Smith Olnir"][3] = {
	Text 		= "Calm down, you didn't even let me finish! I need you to test out this new weapon I made.",
	Replies 	= {3,4}
}
Dialog["Smith Olnir"][4] = {
	Text 		= "Head over to the Captain, I'm sure he'll learn you a couple of moves!",
	Replies 	= {5}
}
Dialog["Smith Olnir"][5] = {
	Text 		= "Hey, I'm not selling anything right now, come back later",
	Replies 	= {5}
}

Replies["Smith Olnir"] = {}
 
Replies["Smith Olnir"][1] = {
	Text		= "Oh, really? What's going on then?",
	OnUse		= function(pl) return 2 end
}
Replies["Smith Olnir"][2] = {
	Text		= "Why? Whatever it was, it wasn't me!!",
	OnUse		= function(pl) return 3 end
}
Replies["Smith Olnir"][3] = {
	Text		= "A weapon? I've never fought before...", 
	OnUse		= function(pl) return 4 end 
}
Replies["Smith Olnir"][4] = {
	Text		= "Sure, I'd love to try out a new toy!", 
	OnUse		= function(pl) pl:AcquireQuest(Quest) return end
}
Replies["Smith Olnir"][5] = {
	Text		= "[End the conversation]", 
	OnUse		= function(pl) pl:AcquireQuest(Quest) return end
}
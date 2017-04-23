AddNPC("Millard Alexander","models/eli.mdl")

ClickMenus["Millard Alexander"] = function (menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Talk To",function() RunConsoleCommand("talkto",ent:EntIndex()) end)
	end
end

--Create a quest like this
local sickmaid = quest.new("The Sick Maiden")

local t = {}
t.Description = [[Millard's wife Esther has fallen ill to the deadly infection Mortagio. It can be cured with the right amount of Medicor Leaves. Help Mr. Alexander save his wife.

	Bring Mr. Alexander 10 Medicor Leaves
]]

t.Items = {}
t.Items["Medicor Leaves"] = 10
sickmaid:AddPart(t)

sickmaid.Rewards = {}
sickmaid.Rewards["$"] = 100


Dialog["Millard Alexander"] = {}
Dialog["Millard Alexander"].StartingPoint = function(pl)

	if (pl:ActiveQuest(sickmaid)) then
		return 6
	end
	if (pl:CompletedQuest(sickmaid)) then
		if (pl:CanReceiveReward(sickmaid)) then
			return 8
		else
			return 10
		end
	end
end

Dialog["Millard Alexander"][1] = {
	Text 		= "Hey, stranger!  Do you think you could help me with something?",
	Replies 	= {1}
}
Dialog["Millard Alexander"][2] = {
	Text 		= "My wife Esther has become infected with Mortagio!  I need you to retrieve 10 medicor leaves.  Please you must help!", --there's something wrong with esther
	Replies 	= {2,3,4,5}
}
Dialog["Millard Alexander"][3] = {
	Text 		= "Nobody seems to know.  Mortagio is an ancient disease, said to have been eradicated generations ago along with the necromancers who first created it",
	Replies 	= {2,3,5,6}
}
Dialog["Millard Alexander"][4] = {
	Text 		= "The necromancers are an ancient, evil race.  Legend tells of how the mighty warriors of the old-age fought to destroy these malevolent beings, abolish their black magic, & vanquish their evil creatures.",
	Replies 	= {2,3,4,5}
}
Dialog["Millard Alexander"][5] = {
	Text 		= "I am a powerful, rich, and very smart man, but retrieving medicor leaves is beyond my skills.  Besides, my wife needs me in a time like this.",
	Replies 	= {2,3,4}
}
Dialog["Millard Alexander"][6] = {
	Text 		= "Please, hurry!  Do you have the medicor leaves?",
	Replies 	= {8,13}
}
Dialog["Millard Alexander"][7] = {
	Text 		= "Do you think this is a joke?  Please hurry, go get those leaves!",
	Replies 	= {11}
}
Dialog["Millard Alexander"][8] = {
	Text 		= "Thank you so much for helping me get those leaves, would you like your reward now?",
	Replies 	= function(pl) if (pl:CanReceiveReward(sickmaid)) then return {9,10} else return {12} end end
}
Dialog["Millard Alexander"][9] = {
	Text 		= "Thank you so much for helping me, come back when you get the leaves.",
	Replies 	= {14}
}
Dialog["Millard Alexander"][10] = {
	Text 		= "Thank you so much for helping me, my wife thanks you greatly.",
	Replies 	= {14}
}

Replies["Millard Alexander"] = {}
 
Replies["Millard Alexander"][1] = {
	Text		= "What is it?",
	OnUse		= function(pl) return 2 end
}
Replies["Millard Alexander"][2] = {
	Text		= "No sorry, I am very busy",
	OnUse		= function(pl) end
}
Replies["Millard Alexander"][3] = {
	Text		= "I would be glad to help!",
	OnUse		= function(pl) pl:AcquireQuest(sickmaid) return 9 end
}
Replies["Millard Alexander"][4] = {
	Text		= "How did she become ill?",
	OnUse		= function(pl) return 3 end
}
Replies["Millard Alexander"][5] = {
	Text		= "Why don't you get them yourself?",
	OnUse		= function(pl) return 5 end
}
Replies["Millard Alexander"][6] = {
	Text		= "Who are the necromancers?",
	OnUse		= function(pl) return 4 end
}
Replies["Millard Alexander"][7] = {
	Text		= "You too, but I don't have time to talk.  Have a nice day!",
	OnUse		= function(pl) return end
}
Replies["Millard Alexander"][8] = {
	Text		= "Yes, I've got them.",
	OnUse		= function(pl) if (pl:CanCompleteQuest(sickmaid)) then return 8 else return 7 end end
}
Replies["Millard Alexander"][9] = {
	Text		= "Yes, please.",
	OnUse		= function(pl) if (pl:CanReceiveReward(sickmaid)) then pl:ReceiveReward(sickmaid) end end
}
Replies["Millard Alexander"][10] = {
	Text		= "No, hold on to it for me, I'll get it later.",
	OnUse		= function(pl) end
}
Replies["Millard Alexander"][11] = {
	Text		= "Sorry, I'm going to get them now.",
	OnUse		= function(pl) end
}
Replies["Millard Alexander"][12] = {
	Text		= "No, my inventory is full, I'll get it later.",
	OnUse		= function(pl) end
}
Replies["Millard Alexander"][13] = {
	Text		= "No, I'm working on getting them.",
	OnUse		= function(pl) end
}
Replies["Millard Alexander"][14] = {
	Text		= "No problem.",
	OnUse		= function(pl) end
}
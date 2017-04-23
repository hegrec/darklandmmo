AddNPC("Combat Test Guy","models/player.mdl") --add to rpg editorClickMenus["Combat Test Guy"] = function (menu,pl,ent) --right click menu	if pl:CanReach(ent) then		menu:AddOption("Talk To",function() RunConsoleCommand("talkto",ent:EntIndex()) end)	endend--Create a quest like thislocal combat = quest.new("Combat Test") --start a new questlocal t = {}t.Description = [[Go kill 5 Spiders]]t.Kills = {}t.Kills[NPC_SPIDER] = 5t.KillCount = function(pl,npc) return npc:GetDungeon() == "dungeon_combat_test" endcombat:AddPart(t)combat:AddDungeon("dungeon_combat_test")combat.Rewards = {}Dialog["Combat Test Guy"] = {}Dialog["Combat Test Guy"].StartingPoint = function(pl)endDialog["Combat Test Guy"][1] = {	Text 		= "This is a test of the combat system. Proceed into the door to the left and eliminate all enemies. You can do this with or without a party",	Replies 	= {1,2}}Replies["Combat Test Guy"] = {} Replies["Combat Test Guy"][1] = {	Text		= "Accept Quest",	OnUse		= function(pl,ent) pl:AcquireQuest(combat) end}Replies["Combat Test Guy"][2] = {	Text		= "Exit",	OnUse		= function(pl) end}
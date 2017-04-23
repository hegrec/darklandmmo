--backend stuff here, use hooks so its unaffected here
local function __emitsound(um)
	local ent = um:ReadEntity()
	if !ent:IsValid() then return end

	local snd = um:ReadString()
	local pitch = um:ReadFloat()
	local sndlvl = um:ReadFloat()
	if pitch == 0 then
		pitch = nil
	end
	if sndlvl == 0 then
		sndlvl = nil
	end
	ent:EmitSound(snd,pitch,sndlvl)
end
usermessage.Hook("__emitsound",__emitsound)

local function doFade()
	
	hook.Call("FadeBegin",GAMEMODE)

end
usermessage.Hook("fadeSeq",doFade)

local function AddSkill( um )
	local skill = um:ReadString()
	mySkills[skill] = true;
	hook.Call("SkillAdded",GAMEMODE,skill)

end
usermessage.Hook("addSkill",AddSkill)

local function getBasics(um)
	ClassTree = um:ReadString()
	Class = um:ReadString()
	XP = um:ReadLong()
	Level = um:ReadChar()
	MaxStamina = um:ReadShort()
	Money = um:ReadLong()
	CharacterName = um:ReadString()
	AttributePoints = um:ReadShort()
	CharID = um:ReadChar()
	
	
	SetAccountLoaded(true)
	hook.Call("CharacterLoaded",GAMEMODE)
end
usermessage.Hook("getBasics",getBasics)


local function UsedSkill( um )

	local skillname = um:ReadString()
	local skill = skills.Get(skillname)
	
	local nextUse = skill.UseDelay or skill.Length
	
	if nextUse then
		skillCharges[skillname] = RealTime() + nextUse
	end
	hook.Call("SkillUsed",GAMEMODE,skillname)

end
usermessage.Hook("usedSkill",UsedSkill)

local function UsedWeapon( um )
	local id = um:ReadLong()
	local weapon = Inventory[id]
	if items.Get(weapon.BaseType).StamCost then
		Stamina = Stamina - items.Get(weapon).StamCost
	end
	hook.Call("WeaponUsed",GAMEMODE,weapon)

end
usermessage.Hook("usedWeapon",UsedWeapon)

local function NewInventoryItem( um )

	local item = items.BufferGrab(um:ReadLong())
	Inventory[item.ID] = item
	
	hook.Call("RefreshInventory",GAMEMODE,Inventory[item.ID],true)

end
usermessage.Hook("newInvItem",NewInventoryItem)

local function TakeInventoryItem( um )

	local id = um:ReadLong()
	local oldItem = Inventory[id]
	Inventory[id] = nil
	hook.Call("RefreshInventory",GAMEMODE,oldItem,false)

end
usermessage.Hook("takeInvItem",TakeInventoryItem)

local function updateItemVar(um)

		local item = Inventory[um:ReadLong()]
		local index = um:ReadShort()
	

		local vType = um:ReadString()
		local func = "Read"..vType
		local value = um[func](um)
		
		item.Variables[index] = value
	
end




--get and set correct starting node
local function beginChatting( um )
	local ent = ents.GetByIndex(um:ReadShort())
	if !ValidEntity(ent) then return end
	ChattingNPC			 	= ent
	CurrentChat				= um:ReadShort()
	local id = um:ReadShort()
	local replies = {}
	while (id != 0) do
		table.insert(replies,id)
		id = um:ReadShort()
	end
	hook.Call("BeginChatting",GAMEMODE,replies)
end
usermessage.Hook("beginChatting",beginChatting)

--run a getnodebyid and set the new current node
local function npcResponse( um )

	CurrentChat = um:ReadShort()
	
	local id = um:ReadShort()
	local replies = {}
	while (id != 0) do
		table.insert(replies,id)
		id = um:ReadShort()
	end
	
	hook.Call("UpdateChatNode",GAMEMODE,replies)
	
	
end
usermessage.Hook("NPCRespond",npcResponse)
local function endChat()
	hook.Call("StopChatting",GAMEMODE)
end
usermessage.Hook("endChat",endChat)



--player has gotten a new quest
local function NewQuest( um )
	local str = um:ReadString()
	local q = quest.GetByName(str)
	
	
	Quests[str] = {Name = str,Parts = table.Copy(q.Parts),CurrentPart = 1}
	
	for i,v in pairs(Quests[str].Parts) do
		Quests[str].Parts[i].Description = nil
	end
	
	--Zero all numbers
	for partIndex,v in pairs(Quests[str].Parts) do
		if v.Kills then
			for i,v in pairs(v.Kills) do
				Quests[str].Parts[partIndex].Kills[i] = 0
			end
		end
		if v.Items then
			for i,v in pairs(v.Items) do
				Quests[str].Parts[partIndex].Items[i] = 0
			end
		end
	end
	hook.Call("NewQuestAdded",GAMEMODE)
	hook.Call("QuestAdded",GAMEMODE)
	
end
usermessage.Hook("newQuest",NewQuest)

local function GetQuest( um )
	local str = um:ReadString()
	local q = quest.GetByName(str)
	
	
	Quests[str] = {Name = str,Parts = table.Copy(q.Parts),CurrentPart = um:ReadChar()}
	
	for i,v in pairs(Quests[str].Parts) do
		Quests[str].Parts[i].Description = nil
	end
	
	--Zero all numbers
	for partIndex,v in pairs(Quests[str].Parts) do
		if v.Kills then
			for i,v in pairs(v.Kills) do
				Quests[str].Parts[partIndex].Kills[i] = um:ReadChar()
			end
		end
		if v.Items then
			for i,v in pairs(v.Items) do
				Quests[str].Parts[partIndex].Items[i] = um:ReadChar()
			end
		end
	end
	hook.Call("QuestAdded",GAMEMODE)
end
usermessage.Hook("getQuest",GetQuest)

local function npcKilled(um)
	hook.Call("OnNPCKilledClient",GAMEMODE,um:ReadString())
end
usermessage.Hook("NPCKill",npcKilled)




local function getStamina(um)
	Stamina = um:ReadShort()
end
usermessage.Hook("getStamina",getStamina)

local function getMaxStamina(um)
	MaxStamina = um:ReadShort()
	Stamina = MaxStamina
end
usermessage.Hook("getMaxStamina",getMaxStamina)

local function getXP(um)
	XP = um:ReadLong()
end
usermessage.Hook("getXP",getXP)

local function getLevel(um)
	Level = um:ReadShort()
end
usermessage.Hook("getLevel",getLevel)

local function levelUp(um)
	Level = um:ReadShort()
	AttributePoints = um:ReadShort()
	hook.Call("OnLevelUp",GAMEMODE)
end
usermessage.Hook("levelUp",levelUp)

local function getTree(um)
	ClassTree = um:ReadString()
end
usermessage.Hook("getTree",getTree)

local function getClass(um)
	Class = um:ReadString()
end
usermessage.Hook("getClass",getClass)

local function chooseSubClass(um)
	hook.Call("ChooseSubClass",GAMEMODE,um:ReadString(),um:ReadChar())
end
usermessage.Hook("chooseSubClass",chooseSubClass)

local function getCharName(um)
	CharacterName = um:ReadString()
end
usermessage.Hook("getCharName",getCharName)

local function tradeNPC(um)
	local inv = {}
	
	local storeName = um:ReadString()
	
	
	
	local item
	local amt
	local price

	while true do
		local id = um:ReadShort()
		if id == 0 then break end
		item = items.BufferGrab(id)
		amt = um:ReadShort()
		price = um:ReadLong()
		inv[item.ID] = {amt,price,item}
	end
		
	hook.Call("OnTradeNPC",GAMEMODE,storeName,inv)
end
usermessage.Hook("tradeNPC",tradeNPC)

local function boughtFromNPC(um)
	hook.Call("OnBoughtFromNPC",GAMEMODE,um:ReadChar())
end
usermessage.Hook("boughtFromNPC",boughtFromNPC)

local function showLootBody(um)
	local inv = {}
	
	
	local id = um:ReadLong()
	
	while (id != 0) do
		inv[id] = items.BufferGrab(id)
		id = um:ReadLong()
	end
	hook.Call("StartLootBody",GAMEMODE,inv)
end
usermessage.Hook("showLootBody",showLootBody)

local function lootedNPC(um)
	hook.Call("OnLootedItem",GAMEMODE,um:ReadLong())
end
usermessage.Hook("lootedNPC",lootedNPC)

local function updateMoney(um)	
	Money = um:ReadLong()
	hook.Call("MoneyChanged",GAMEMODE)
end
usermessage.Hook("updateMoney",updateMoney)

local function getProgressInfo(um)
	local len = um:ReadShort()
	InProgress = true
	hook.Call("OnProgressStarted",GAMEMODE,len)
end
usermessage.Hook("getProgressInfo",getProgressInfo)

local function stopDrawingProgress()
	InProgress = false
	hook.Call("OnProgressStopped",GAMEMODE)
end
usermessage.Hook("stopDrawingProgress",stopDrawingProgress)

local function getEquip(um)
	
	local itemID = um:ReadLong()
	local spot = um:ReadString()
	myEquipped[spot] = Inventory[itemID]
end
usermessage.Hook("getEquip",getEquip)


local function useDoor(um)
	GAMEMODE:FadeBegin()
	local musicType = um:ReadString()
	ChangeMusicTo(musicType)
end
usermessage.Hook("useDoor",useDoor)


local function makeRagdoll(um)
	
	
	local ragdoll = ents.Create( "class C_ClientRagdoll" )
	ragdoll:SetModel( um:ReadString() )
	ragdoll:SetPos( um:ReadVector() )
	ragdoll:SetAngles( um:ReadAngle() )
	ragdoll:Spawn()
	
end
usermessage.Hook("makeRagdoll",makeRagdoll)

local function plyDidDamage( um )
	local ent = um:ReadEntity()
	local amt = um:ReadShort()
	hook.Call("PlayerDamagedEntity",GAMEMODE,ent,amt)
end
usermessage.Hook("plyDidDamage",plyDidDamage)

local function clientDeath()

	hook.Call("PlayerDeath",GAMEMODE,Me)
end
usermessage.Hook("clientDeath",clientDeath)

local function clientSpawn()

	hook.Call("PlayerSpawn",GAMEMODE,Me)
end
usermessage.Hook("playerSpawn",clientSpawn)

local function getAttributes(um)
	local att = um:ReadString()
	while (att != "") do
		myAttributes[att] = um:ReadChar()
		att = um:ReadString()
	end
	hook.Call("AttributesChanged",GAMEMODE)
	
end
usermessage.Hook("syncAttributes",getAttributes)


local function getAttributePoints(um)
	AttributePoints = um:ReadShort()
	hook.Call("OnAttributePointsChanged",GAMEMODE)
end
usermessage.Hook("getAttributePoints",getAttributePoints)

local function resourceAdded(um)
	hook.Call("OnResourceAdded",GAMEMODE,LoadProperties(um:ReadString()),um:ReadVector())
end
usermessage.Hook("newResourceAdded",resourceAdded)

local function forestGen(um)
	hook.Call("OnGenerateForest",GAMEMODE)
end
usermessage.Hook("forestGen",forestGen)
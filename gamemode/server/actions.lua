

function UseSkill(pl,cmd,args)
	local skillname = args[1]
	if !pl:Alive() || !pl.Skills[skillname] || (pl.skillCharges[skillname] && pl.skillCharges[skillname] > CurTime()) then return end --make sure you can use the skill
	local skill = skills.Get(skillname)
	if !skill then return end
	if skill.CanUse && !skill.CanUse(pl) then return end --let the skill have custom params
	
	
	
	if skill.ManaCost && pl:GetMana() < skill.ManaCost then return end
	
	local vec = Vector(0,0,0)
	
	if skill.Mandala then
		local tr = {}
		tr.start = pl:GetPos()+pl:GetAimVector() * -200 + Vector(0,0,100)
		tr.endpos = tr.start + pl:GetAimVector() * 8192 
		tr = util.TraceLine(tr)
		
		vec 	= tr.HitPos
	
	
	local dist = tr.HitPos:Distance(pl:GetPos())
	
		--just for visual effect
		if dist > 500 then		
			
			local normed = (vec - pl:GetPos()):Normalize()  
			vec =  pl:GetPos() + (normed * 500)
			local t = {}
			t.start = vec + Vector(0,0,1000)
			t.endpos = vec - Vector(0,0,1000)
			t = util.TraceLine(t)
			vec = t.HitPos
			
		end
	end
	
	
	
	skill.Activate(pl,vec)

	
	if skill.ManaCost then
		pl:SetMana(pl:GetMana() - skill.ManaCost)
	end
	
	local nextUse = skill.UseDelay or skill.Length
	if skill.Deactivate then
		timer.Simple(skill.Length,function() if !ValidEntity(pl) then return end skill.Deactivate(pl) end)
	end
	if nextUse then
		pl.skillCharges[skillname] = CurTime() + nextUse
	end
	
	umsg.Start("usedSkill",pl)
		umsg.String(skillname)
	umsg.End()

end
concommand.Add("useSkill",UseSkill)

function UseWeapon(pl,cmd,args)

	local weapon = pl.Equipped["Weapon"] --weapons must be equipped to use them
	if !weapon then return end
	local wep = items.Get(weapon.BaseType)
	
	if !wep || !wep.Range then return end
	if !pl:Alive() || (pl.skillCharges[pl.Equipped["Weapon"].BaseType] && pl.skillCharges[pl.Equipped["Weapon"].BaseType] > CurTime()) then return end --make sure you can use the weapon
	
	
	pl:EmitSound("npc/vort/claw_swing2.wav")

	local act = "ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE"
	
	if pl:HoldingTwoHandWeapon() then
		act = act .. "2"
	end
	

	
	local damage = GetMeleeDamageAmount(pl)
	
	if wep.CustomAttack then
		wep.CustomAttack(pl,weapon)	
	elseif wep.WeaponType == WEAPON_BOW then
		act = "ACT_BOW_PULLBACK"
		local arrow = ents.Create("base_arrow")
		arrow:SetOwner(pl)
		arrow:SetPos(pl:GetShootPos()+pl:GetForward()*20)
		arrow.moveAng = pl:GetAimVector()
		arrow.flyDist = wep.Range
		arrow.baseDamage = GetBowDamageAmount(pl)
		arrow:Spawn()
	
	else
		
		local ent = pl:TraceHullAttack( pl:GetPos()+Vector(0,0,40), pl:GetPos()+Vector(0,0,40) + pl:GetForward() * wep.Range, Vector(-16,-16,-16), Vector(36,36,36), damage, DMG_SLASH, 45, true )
		if ValidEntity(ent) then
				pl:EmitSound("physics/flesh/flesh_impact_bullet5.wav")
		end
				
	end
	
	
	if pl.MiscVars.LastSwing && pl.MiscVars.LastSwing > CurTime() - 5 then --you swung within the last X seconds
		if math.random(0,pl:GetSkillLevel(WeaponTranslate[wep.WeaponType])) == 0 then
			weapon:SetVar(VAR_DEGRADE,math.max(0,weapon:GetVar(VAR_DEGRADE,100)-1))
		end
	end
		
		
	act = _G[act]
	
	pl:RestartGesture(act)		
		
		
	umsg.Start("usedWeapon",pl)
		umsg.Long(pl.Equipped["Weapon"].ID)
	umsg.End()
	
	
	if wep.UseDelay then
		pl.skillCharges[pl.Equipped["Weapon"].BaseType] = CurTime() + wep.UseDelay
	end
end
concommand.Add("useWeapon",UseWeapon)


function useItem(pl,cmd,args)
	if !pl:Alive() then return end
	local item = pl.Inventory[tonumber(args[1])]
	
	if !item || items.Get(item.BaseType).NoBar then return end
	
	items.Get(item.BaseType).OnUse(pl,item)
	pl:TakeItem(item)

end
concommand.Add("useItem",useItem)



function TalkToNPC(pl,cmd,args)

	local ent 		= ents.GetByIndex(args[1])
	local response 	= tonumber(args[2])
	if !ValidEntity(ent) || !pl:CanReach(ent) then return end

	if !ent:CanChat() then return end --This NPC can't chat

	if !response && !pl.TalkingTo then

		
		local yaw = (pl:GetPos()-ent:GetPos()):Angle().yaw + 180
		pl:SetEyeAngles(Angle(0,yaw,0)) --and look at ent as well don't be rude

		pl:Freeze(true) --freeze them in place while they are talking
		pl.TalkingTo 	= ent:GetName()
		pl.lastTalkEnt	= ent
		pl.ChatNum	= Dialog[pl.TalkingTo].StartingPoint(pl) or 1
		ent:SetHook("OnPlayerStartChat")

		
		umsg.Start("beginChatting",pl)
			umsg.Short(ent:EntIndex())
			umsg.Short(pl.ChatNum)
				local t = Dialog[pl.TalkingTo][pl.ChatNum].Replies
				
				if type(t) == "function" then t = t(pl) end

				for i,v in pairs(t) do
					umsg.Short(v)
				end
		umsg.End()

		--now that you've talked to him...
		pl:SetDisposition(ent:GetName(),1)
		ent:OnTalkedTo(pl)


	elseif response && pl.TalkingTo then --you are responding to the npc
		local t = Dialog[pl.TalkingTo][pl.ChatNum].Replies
		if type(t) == "function" then t = t(pl) end
		for i,v in pairs(t) do
			if v == response then --the reply is a valid reply to your current position in the dialog (so you cant accept a quest right after you say hello)
				
				local newNum = Replies[pl.TalkingTo][response].OnUse(pl,ent)
				if !newNum then StopChatting(pl,ent) return end
				pl.ChatNum = newNum
				umsg.Start("NPCRespond",pl)
					umsg.Short(newNum) --send the new position you should be at
					local t = Dialog[pl.TalkingTo][pl.ChatNum].Replies
					
					if type(t) == "function" then t = t(pl) end

					for i,v in pairs(t) do
						umsg.Short(v)
					end
				umsg.End()
				return
			end
		end
		return

	end



end
concommand.Add("talkto",TalkToNPC)

function StopChatting(pl,ent)
	ent:SetHook("OnPlayerEndChat")
	pl.TalkingTo = nil
	pl.ChatNum = nil
	umsg.Start("endChat",pl)
	umsg.End()
	pl:Freeze(false)
	ent:EndTalkTo(pl)
end

function ChooseSubClass(pl,cmd,args)
	local tier = pl.ChoosingClass
	if !tier then return end
	local subClass = args[1]
	if tier == 2 then
		
		
		if !table.HasValue(ClassTrees[pl.ClassTree][pl.ClassTree].LowClasses,subClass) then return end
		
		pl.Class = subClass
	elseif tier == 3 then
		
	end
	
	for i,v in pairs(ClassTrees[pl.ClassTree][pl.Class].AttributeIncrease) do
		pl.Attributes[i] = pl.Attributes[i] + v
	end
	pl:SyncAttributes()
	--[[for i,v in pairs(ClassTrees[pl.ClassTree][pl.Class].StatIncrease) do
		pl.Skills[i].Level = pl.Skills[i].Level + v
	end]]
	--pl:SyncSkills()
	pl.ChoosingClass = nil
	hook.Call("PlayerChoseClass",GAMEMODE,pl)
end
concommand.Add("chooseSubClass",ChooseSubClass)



function ChooseClass(pl,cmd,args)
	--if !pl:IsDarkspider() then return end
	pl.Class = args[1]
end
concommand.Add("chooseclass",ChooseClass)
	
	

function ShowLoot(pl,cmd,args)
	local bag = ents.GetByIndex(args[1])
	if !ValidEntity(bag) || !pl:CanReach(bag) || bag:GetClass() != "lootbag" then return end
	
	if bag:GetNWInt("OwnerUserID") != 0 && bag:GetNWInt("OwnerUserID") != pl:UserID() then
		pl:ChatPrint("That does not belong to you") 
		return
	end
	
	pl:Freeze(true)
	
	local ids = {}
	for i,v in pairs(bag.Loot) do
			table.insert(ids,v:Send(pl))
	end
	
	umsg.Start("showLootBody",pl)
		for i,v in pairs(ids) do
			umsg.Long(v)
		end
	umsg.End()
	pl.Looting = bag
	
end
concommand.Add("viewLoot",ShowLoot)

function LootItem(pl,cmd,args)
	local bag = pl.Looting
	
	local itemID = tonumber(args[1])
	
	if !ValidEntity(bag) || !bag.Loot[itemID] then return end
	
	local item = bag.Loot[itemID]
	
	bag.Loot[itemID] = nil
	if table.Count(bag.Loot) < 1 then bag:Remove() pl.Looting = nil pl:Freeze(false) end
	
	
	umsg.Start("lootedNPC",pl)
		umsg.Long(itemID)
	umsg.End()
	pl:AddItem(item)	
	
	
	
end
concommand.Add("lootItem",LootItem)

function StopLooting(pl,cmd,args)

	pl.Looting = nil
	pl:Freeze(false)
	
end
concommand.Add("stopLooting",StopLooting)

function HarvestBush(pl,cmd,args)

	local bush = ents.GetByIndex(args[1])
	if !ValidEntity(bush) || !pl:CanReach(bush) || bush:GetClass() != "harvest_plant" then return end
	pl:BeginProgress(5,function() bush:IsHarvested(pl) end)
end
concommand.Add("harvestBush",HarvestBush)

function SmeltOre(pl,cmd,args)

	local smelter = ents.GetByIndex(args[1])
	if !ValidEntity(smelter) || !pl:CanReach(smelter) then return end
	pl:BeginProgress(5,function() smelter:OnSmelt(pl) end)
end
concommand.Add("smeltOre",SmeltOre)


	
	
	
local PartyInvites = {}


function InviteParty(pl,cmd,args)
	local otherPlayer = ents.GetByIndex(args[1])
	if otherPlayer == pl then return end
	if !ValidEntity(otherPlayer) || !otherPlayer:IsPlayer() then return end
	if otherPlayer:HasParty() then return end
	
	if !pl:HasParty() then --if you are not in a party, you are creating one so you are the party leader
	 	pl:SetParty(pl:UserID())
		umsg.Start("joinedParty",pl)
		umsg.End()
	end
	local id = pl:GetParty()
	
	
	PartyInvites[id] = PartyInvites[id] or {}
	table.insert(PartyInvites[id],otherPlayer)
	

	
	umsg.Start("partyAsk",otherPlayer)
		umsg.Entity(pl)
		umsg.Long(id)
	umsg.End()
	
end
concommand.Add("invitePlayerToParty",InviteParty)

AddChatCommand("invite",function(pl,args)

	local name = table.concat(args," ")
	
	local otherPlayer = FindNameMatch(name)
	
	if !ValidEntity(otherPlayer) then return end
	if otherPlayer:HasParty() then return end
	
	if !pl:HasParty() then --if you are not in a party, you are creating one so you are the party leader
		pl:SetParty(pl:UserID())
	end
	
	
	PartyInvites[pl:GetParty()] = PartyInvites[pl:GetParty()] or {}
	table.insert(PartyInvites[pl:GetParty()],otherPlayer)
	
	umsg.Start("partyAsk",otherPlayer)
		umsg.Entity(pl)
		umsg.Long(pl:GetParty())
	umsg.End()


end)

AddChatCommand("expel",function(pl,args)
	if !pl:IsPartyLeader() then return end
	local name = table.concat(args," ")
	
	local otherPlayer = FindNameMatch(name)
	
	if !ValidEntity(otherPlayer) then return end
	if otherPlayer:GetParty() != pl:GetParty() then return end
	if otherPlayer == pl then return end --dont kick yourself from the party!
	
	
	otherPlayer:SetParty(0)
	
	umsg.Start("partyKicked",otherPlayer)
		umsg.Entity(pl)
		umsg.Long(pl:GetParty())
	umsg.End()


end)

AddChatCommand("disband",function(pl,args)
	if !pl:IsPartyLeader() then return end
	
	local t = GetPartyMembers(pl:GetParty())
	
	for i,v in pairs(t) do
		v:SetParty(0)
	end


end)

AddChatCommand("leader",function(pl,args)
	if pl:IsPartyLeader() then
			
		local name = table.concat(args," ")
		
		local otherPlayer = FindNameMatch(name)
		
		if !ValidEntity(otherPlayer) || otherPlayer:GetParty() != pl:GetParty() then return end
		local newParty = otherPlayer:UserID()
		
		local rf = RecipientFilter()
		for i,v in pairs(GetPartyMembers(pl:GetParty())) do
			rf:AddPlayer(v)
			v:SetParty(newParty)
		end
		
		umsg.Start("partyRebuild",rf)
		umsg.End()
		
	else
	
		for i,v in pairs(player.GetAll()) do
			if v:IsPartyLeader() && v:GetParty() == pl:GetParty() then
				pl:ChatPrint("The party leader is "..v:Name())
				break
			end
		end
	end
	
	
	
	



end)

AddChatCommand("leave",function(pl,args)
	if pl:IsPartyLeader() then
		pl:ChatPrint("First /disband or /leader")
		return
	end
	
	if !pl:HasParty() then return end
	
	pl:SetParty(0)


end)



function PartyAccept(pl,cmd,args)

	local id = tonumber(args[1])
	if !PartyInvites[id] then return end
	local removeID = -1
	for i,v in pairs(PartyInvites[id]) do
		if v == pl then
			removeID = i
			break
		end
	end
	if removeID == -1 then return end --you were not invited to this
	table.remove(PartyInvites[id],removeID)
	
	
	
	pl:SetParty(id)
	
	umsg.Start("joinedParty",pl)
		umsg.Long(id)
	umsg.End()

	
end
concommand.Add("partyAccept",PartyAccept)


function BlockAttacks(pl,cmd,args)
	if pl.skillCharges["BlockAttacks"] && pl.skillCharges["BlockAttacks"] > CurTime() then return end --make sure you can use the skill
	pl.Blocking = true
	pl:RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE) --looks like a block anim
	timer.Simple(BLOCK_TIME,function() if !ValidEntity(pl) then return end pl.Blocking = false end)
	pl.skillCharges["BlockAttacks"] = CurTime() + BLOCK_COOLDOWN
end
concommand.Add("blockattacks",BlockAttacks)


function IncreaseAttribute(pl,cmd,args)
	if pl.AttributePoints < 1 then return end
	local att = args[1]
	if !Attributes[att] then return end
	
	pl.Attributes[att] = pl.Attributes[att] + 1
	
	pl.AttributePoints = pl.AttributePoints - 1
	umsg.Start("getAttributePoints",pl)
		umsg.Short(pl.AttributePoints)
	umsg.End()
	
	pl:SyncAttributes()
	hook.Call("PlayerIncreasedAttributes",GAMEMODE,pl)
	
end
concommand.Add("increaseAttribute",IncreaseAttribute)

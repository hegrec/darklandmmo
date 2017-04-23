require("instance")
require("glon")

include("shared.lua")
include("server/chatcommands.lua")
include("server/database.lua")
include("server/actions.lua")
--include("server/environment.lua")



include("meta/player.lua")


include("libraries/init.lua")


function Material(str)
	return str
end



AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_classes.lua")
AddCSLuaFile("cl_init.lua")

AddCSLuaFile("client/cl_camera.lua")
AddCSLuaFile("client/cl_hud.lua")
AddCSLuaFile("client/cl_startscreen.lua")
AddCSLuaFile("client/cl_usermessages.lua")

AddCSLuaFile("menus/cl_inventory.lua")
AddCSLuaFile("menus/cl_chathud.lua")
AddCSLuaFile("menus/cl_bindbar.lua")
AddCSLuaFile("menus/cl_skillbook.lua")
AddCSLuaFile("menus/cl_questhud.lua")
AddCSLuaFile("menus/cl_character.lua")
AddCSLuaFile("menus/cl_npcstore.lua")
AddCSLuaFile("menus/cl_party.lua")
AddCSLuaFile("menus/cl_playerinfo.lua")
AddCSLuaFile("menus/cl_progressbar.lua")
AddCSLuaFile("menus/cl_lootscreen.lua")
AddCSLuaFile("menus/cl_chatbox.lua")
AddCSLuaFile("menus/cl_classmenu.lua")

AddCSLuaFile("vgui/DraggableIcon.lua")
AddCSLuaFile("vgui/elements/DRadioButton.lua")
--AddCSLuaFile("cl_environment.lua")


function GM:EntityKeyValue(ent,key,value)

		if key == "targetname" then
			ent:SetName(value)
		elseif key == "IsDoor" then
			ent:SetNWInt("Type",INTERACTABLE_DOOR)
		end
	if key == "hammerid" then
		ent.HammerID = value
	end
end

function GM:InitPostEntity()
	g_TargetEnt = ents.Create("info_target")
	g_TargetEnt:Spawn()
end

function GM:PlayerProfileLoaded( pl ) --equip initial equipment here!!

	
	pl:SetInstance(0)
	--pl:SetPos(pl.SpawnPos[1])
	--pl:SetAngles(pl.SpawnPos[2])
end

function GM_SameInstance(ply,ent)
	ply = ents.GetByIndex(ply)
	ent = ents.GetByIndex(ent)
	return (ply:GetInstance() == ent:GetInstance() && !ent.HammerID) or nil
end
hook.Add("SameInstance","GM_SameInstance",GM_SameInstance)




function GM:PlayerSpawn( pl )
	
	
	if !pl.CharacterIndex then
		pl:SetColor(255,255,255,0)
		pl:Freeze(true)
		pl:SetSolid(false) --double check this...
		return
	end
	pl:SetColor(255,255,255,255)
	pl:SetModel(pl:GrabModel())
	
	
	table.Empty(pl.HookedStats) --clear all old buffs/debuffs
	
	pl:ResetSpeed() --reset speed
	
	pl:SetMaxHealth(pl:GetEndurance()*50)
	
	umsg.Start("playerSpawn",pl)
	umsg.End()
	
	pl:RecalculateEquipmentPosition()
	
	
end

function GM:PlayerLeveledUp(pl)
	if pl.Level >= CHOOSE_CLASS && pl.Class == pl.ClassTree then
		pl.ChoosingClass = 2
		umsg.Start("chooseSubClass",pl)
			umsg.String(pl.Class)
			umsg.Char(2)
		umsg.End()
		--evolve to tier 2
	elseif pl.Level >= CLASS_UP && ClassTrees[pl.ClassTree][pl.Class].EvolvesTo then
		--Evolve to tier 3
		pl.ChoosingClass = 3
	end
	
end

function GM:PlayerEnteredInstance(pl)
	for i,v in pairs(pl.Quests) do
		for i,v in pairs(quest.GetByName(i).ActiveDungeons) do
			dungeon.LoadDungeon(pl,i)
		end
	end
end

function GM:PlayerLeftInstance(pl,oldInst,oldInstName)
	for i,v in pairs(pl.Quests) do
		if quest.GetByName(i) then
			for i,v in pairs(quest.GetByName(i).ActiveDungeons) do
				if dungeon.IsSpawnedForPlayer(i,oldInstName,oldInst) then
					dungeon.Clear(i,oldInstName,oldInst)
				end
			end
		end
	end
end
local lastRegen = 0
function GM:Tick()
	if lastRegen < CurTime() then
		for i,v in pairs(player.GetAll()) do
			if v.Attributes then
				hook.Call("StatRegen",GAMEMODE,v)
			end
		end
		lastRegen = CurTime() + STAT_REFRESH
	end
end

function GM:StatRegen(pl)
	
	if pl:Health() < pl:GetMaxHealth() then
		pl:RegenHealth()
	end
	if pl:GetMana() < pl:GetMaxMana() then
		pl:RegenMana()
	end
	pl:RegenStamina()

end

function GM:PlayerUse(pl,ent)

	local func
	if ent:IsNPC() && string.len(ent:GetName()) > 1 then
		func = UseFuncs["~chattingnpc"]
	elseif ent:IsPlayer() then
		func = UseFuncs["~player"]
	else
		func = UseFuncs[ent:GetClass()]
	end
	if !func then return end
	func(pl,ent)

end

function GM:PlayerDeath(pl,killer,wep)
	pl:Freeze(false)
	umsg.Start("clientDeath",pl)
	umsg.End()
	pl.NextSpawn = CurTime() + DEATH_TIME
end

function GM:PlayerDeathThink( pl )
	
end

local function tryRespawn(pl,cmd,args)
	if pl:Alive() || pl.NextSpawn > CurTime() then return end
	pl.NextSpawn = nil
	pl:Spawn()

end
concommand.Add("respawnCharacter",tryRespawn)

function GM:PlayerNoClip(pl)
	return false
end


function GM:EntityTakeDamage(ent,inflictor,attacker,amt,dmgInfo)
	if !ent:IsMonster() && !ent:IsPlayer() || dmgInfo:GetDamageType() == DMG_CRUSH then dmgInfo:SetDamage(0) return true end
	if dmgInfo:GetDamage() > 0 then
		umsg.Start("plyDidDamage")
			umsg.Entity(ent)
			umsg.Short(amt)
		umsg.End()
	end
	
end

local meta = FindMetaTable("NPC")

function meta:SetName(str)
	self:SetNWString("Name",str)
end

local meta = FindMetaTable("Entity")

function meta:SetInstance(int,area)
	if int == 0 then area = "" end --to prevent me from making mistakes :p
	local oldInst = self:GetInstance()
	local oldName = self:GetInstanceName()
	if self:IsPlayer() then
		for i,v in pairs(self.EquippedEnts) do
			v:SetInstance(int,area)
		end
	end
	
	self:SetNWInt("Instance",int)
	self:SetNWInt("InstanceName",area)
	
	if self:IsPlayer() && int == 0 then
		hook.Call("PlayerLeftInstance",GAMEMODE,self,oldInst,oldName)
	elseif self:IsPlayer() then
		hook.Call("PlayerEnteredInstance",GAMEMODE,self)
	end
end
function meta:SetTargetArea(areaID)
	self:SetDTInt(0,areaID)
end
function meta:SetArea(areaID)
	self:SetDTInt(1,areaID)
end
--[[
function meta:EmitSound(str,sndlvl,pitch)
	local list = GetPlayersInInstance(self:GetInstance())
	local rf = RecipientFilter()
	for i,v in pairs(list) do
		rf:AddPlayer(v)
	end
	umsg.Start("__emitsound",rf)
		umsg.Entity(self)
		umsg.String(str)
		umsg.Float(sndlvl)
		umsg.Float(pitch)
	umsg.End()
end]]
function meta:SetName(str)
	self:SetNWString("Name",str)
end
function meta:SetProperty(ind,val)
	self.Properties = self.Properties or {}
	self.Properties[ind] = val
end
function meta:GetProperty(ind)
	if !self.Properties then return end
	return self.Properties[ind]
end
function meta:UpdateProperties()

	if self:IsDoor() then
		self:SetTargetArea(self.Properties.TargetArea)
		self:SetArea(self.Properties.Area)
	end
end
local AnimTranslateTable = {}
AnimTranslateTable[ PLAYER_RELOAD ] 	= ACT_HL2MP_GESTURE_RELOAD
AnimTranslateTable[ PLAYER_JUMP ] 		= ACT_HL2MP_JUMP
AnimTranslateTable[ PLAYER_ATTACK1 ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK


local animIndex = 1
local lastAnimTime = 0
function GM:SetPlayerAnimation( pl, anim )
	local act = "ACT_HL2MP_IDLE"
	
	local Speed = pl:GetVelocity():Length()
	local OnGround = pl:OnGround()
	
	-- If it's in the translate table then just straight translate it
	if ( AnimTranslateTable[ anim ] != nil ) then
		act = AnimTranslateTable[ anim ]
	else
		-- Crawling on the ground
		if ( OnGround && pl:Crouching() ) then
			act = "ACT_HL2MP_IDLE_CROUCH"
			if ( Speed > 0 ) then
				act = "ACT_HL2MP_WALK_CROUCH"
			end
		elseif (Speed > 190) then
			act = "ACT_HL2MP_RUN"
		-- Player is running on ground
		elseif (Speed > 0) then
			act = "ACT_HL2MP_WALK"
		end
	end

	-- Always play the jump anim if we're in the air
	if ( !OnGround ) then
		act = "ACT_HL2MP_JUMP"
	end
	
	-- Ask the weapon to translate the animation and get the sequence
	-- ( ACT_HL2MP_JUMP becomes ACT_HL2MP_JUMP_AR2 for example)
	
	if pl:HasWeapon() then
		act = act .. "_MELEE"
		
	end
	if pl:HoldingTwoHandWeapon() then
		act = act .. "2"
	end
	act = _G[act]
	
	local seq = pl:SelectWeightedSequence( pl:Weapon_TranslateActivity( act ) )
	
	-- If the weapon didn't return a translated sequence just set 
	--	the activity directly.
	if (seq == -1) then 
		-- Hack.. If we don't have a weapon and we're jumping we
		-- use the SLAM animation (prevents the reference anim from showing)
		if (act == ACT_HL2MP_JUMP) then
			act = ACT_HL2MP_JUMP_SLAM
		end
		seq = pl:SelectWeightedSequence( act )
	end
	

	
	-- Don't keep switching sequences if we're already playing the one we want.
	if (pl:GetSequence() == seq) then return end
	

	
	-- Set and reset the sequence
	pl:SetPlaybackRate( 1.0 )
	pl:ResetSequence( seq )
	pl:SetCycle( 0 )

	
end



function GM:PlayerShouldTakeDamage(victim,attacker)
	return true
end


function GM:OnNPCKilled(npc,pl,weapon)
	--if !pl:IsPlayer() then pl = pl:GetOwner() end
	local xpAmt = npc:GetLevel() * 5
	pl:AddXP(xpAmt) --the higher the level and longer the npc has been alive, the more XP you get? can be changed later
	
	if pl:HasParty() then --shared XP
		local t = GetPartyMembers(pl:GetParty())
		for i,v in pairs(t) do
			if v != pl then
				pl:AddXP(xpAmt*0.03,true) --add 3% of the earned XP to all party members TODO: Fix so xp only goes to players in the same vicinity as the killer
			end
		end
	end
		


end


function GM:PlayerEnteredDungeon(pl,door,targetDoor,tblArea)
	local inst = 0
	if tblArea.Instanced then
		inst = pl:UserID()
	end
	if pl:HasParty() then
		inst = pl:GetParty()
	end
	pl.InstancedExit[targetDoor] = door
	return inst

end

function GM:PlayerDeathSound()

	return true

end



function CreateLoot(deadEnt)
	local loot = ents.Create("lootbag")
	loot:SetPos(deadEnt:GetPos())
	loot:SetNWInt("OwnerUserID",deadEnt.Killer:UserID())
	loot:Spawn()
	timer.Simple(LOOT_GRACE,function() if !ValidEntity(loot) then return end loot:SetNWInt("OwnerUserID",0) end)
	timer.Simple(LOOT_GRACE*2,function() if !ValidEntity(loot) then return end loot:Remove() end)

	loot:AddLoot(items.Create("Heavy Broadsword"))
	/*
	local t = {}
	local lookupT = {}
	local difficulty = corpse:GetLevel()
	local types = math.random(0,3)
	for i,v in pairs(items.GetAll()) do
		if v.LowestFind && v.LowestFind <= difficulty then
			t[i] = v
			table.insert(lookupT,i)
		end		
	end
	
	for i=1,types do 
		local randomInd = math.random(1,table.getn(lookupT))
		local t2 = t[lookupT[randomInd]]
		local maxFound = t2.MaxFoundInLoot or 1
		corpse.Loot[lookupT[randomInd]] = math.random(1,maxFound)
		table.remove(t,randomInd)
	end
	*/
		
end

StoreList = {}
function CreateStore(name)
	StoreList[name] = {}
	return StoreList[name]
end

function AddStock(store,name,amt,price)
	local t = {}
	t.Amount = amt
	t.Price = price
	
	local id = table.insert(store,t)
	t.Item = items.Create(name,nil,id)
end

function GetStore(name)
	return StoreList[name]
end









function umsg.FindValue(val)
	if tonumber(val) then
		umsg.String("Long")
		umsg.Long(tonumber(val))
	elseif val == "true" then
		umsg.String("Bool")
		umsg.Bool(true)
	elseif val == "false" then
		umsg.String("Bool")
		umsg.Bool(false)
	else
		umsg.String("String")
		umsg.String(val)
	end
end

function ClientsideRagdoll(ent)

	umsg.Start("makeRagdoll",pl)
		umsg.String(ent:GetModel())
		umsg.Vector(ent:GetPos())
		umsg.Angle(ent:GetAngles())
	umsg.End()
	
end

function GetMeleeDamageAmount(pl)

	local t = items.Get(pl.Equipped["Weapon"].BaseType)
	local amt
	if t then
		amt = table.Copy(t.BaseDamage)
	end
	
	amt[1] = amt[1] * (pl:GetStrength()*0.5)
	amt[2] = amt[2] * (pl:GetStrength()*0.5)
	
	if DamageLookup[t.WeaponType] then
		amt[1] = amt[1] * math.max(1,DamageLookup[t.WeaponType](pl)*0.2)
		amt[2] = amt[2] * math.max(1,DamageLookup[t.WeaponType](pl)*0.2)
	end
	
	
	return math.random(amt[1],amt[2])

end

function GetBowDamageAmount(pl)

	local t = items.Get(pl.Equipped["Weapon"].BaseType)
	local amt
	if t then
		amt = table.Copy(t.BaseDamage)
	end
	
	amt[1] = amt[1] * (pl:GetAgility()*0.5)
	amt[2] = amt[2] * (pl:GetAgility()*0.5)
	
	if DamageLookup[t.WeaponType] then
		amt[1] = amt[1] * math.max(1,DamageLookup[t.WeaponType](pl)*0.2)
		amt[2] = amt[2] * math.max(1,DamageLookup[t.WeaponType](pl)*0.2)
	end
	
	
	return math.random(amt[1],amt[2])

end



--After "engine" is loaded, load all the content (npcs and npc given quests, etc)
include("SDK/init.lua")
include("server/resource.lua") --include this last
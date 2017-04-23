local meta = FindMetaTable("Player")

function meta:LearnSkill(skill)
	print(skill)
	if self.Skills[skill] then return end
	local t = skills.Get(skill)
	if !t then return end
	print(t.LearningClass,self.Class)
	if t.LearningClass && t.LearningClass != self.Class then return end --only warrior can learn warrior skills etc etc
	if t.MinimumLevel && t.MinimumLevel > pl.Level then return end --you can't learn powerful skills at level 1
	self.Skills[skill] = 1
	umsg.Start("addSkill",self)
		umsg.String(skill)
	umsg.End()
	

	
	
	
	
	
	hook.Call("LearnedSkill",GAMEMODE,self,skill)
end


function meta:LoadItem(item)
	if !item.ID then error("ERROR: Non item attempted to be added") return end	

	
	item.Owner = self
	self.Inventory[item.ID] = item

	local id = item:Send(self)
	
	
	
	umsg.Start("newInvItem",self)
		umsg.Long(id)
	umsg.End()
	hook.Call("ItemAdded",GAMEMODE,self)
	self:RecalculateWeight()
end

function meta:AddItem(item)
	if !item || !item.BaseType then error("ERROR: Non item attempted to be added") return end
	
	
	tmysql.query("INSERT INTO rpg_items (OwnerID,ItemName,ItemVars) VALUES ("..self.CharacterIndex..",'"..item.BaseType.."','"..glon.encode(item.Variables).."')",function(tbl,stat,lastid) 
	

		item.ID = lastid
		item.Owner = self
		self.Inventory[item.ID] = item

		local id = item:Send(self)

		umsg.Start("newInvItem",self)
			umsg.Long(id)
		umsg.End()
		hook.Call("ItemAdded",GAMEMODE,self)
		self:RecalculateWeight()
	
	end,2)
	
end

function meta:TakeItem(item)

	if !self:HasItem(item) then return end
	local id = item.ID
	tmysql.query("DELETE FROM rpg_items WHERE ID="..id,function()   
	
	self.Inventory[id] = nil
	
	self:RecalculateWeight()
	umsg.Start("takeInvItem",self)
		umsg.Long(item.ID)
	umsg.End()
	hook.Call("ItemTaken",GAMEMODE,self)
	
	
	end)
	
	
end

function meta:UpdateItemVariable(item,varIndex)

	umsg.Start("updateItem",self)
		umsg.Long(item.ID)
		umsg.Short(varIndex)
		umsg.FindValue(v)
	umsg.End()
	
	
end

function meta:RecalculateWeight()
	self.Weight = 0
	for i,v in pairs(self.Inventory) do
		self.Weight = self.Weight + (items.Get(v.BaseType).Weight or 0)
	end
	hook.Call("PlayerWeightSet",GAMEMODE,self)
end





function meta:EquipItem(spot,item)
	

	
	local t = items.Get(item.BaseType)
		
	if !EquipSpots[spot] || !t || t.EquipAt != spot then return end --make sure they can equip this item at this spot (helmets cant go on feet)
	
	--if spot == "Weapon" && !ClassTrees[self.ClassTree][self.Class].AllowedWeapons[t.WeaponType] then return end
	--if spot != "Weapon" && !ClassTrees[self.ClassTree][self.Class].AllowedArmor[t.ArmorType] then return end
	
	
	self.Equipped[spot] = item
	
	
	local ent = self.EquippedEnts[spot]
	
	if !ValidEntity(ent) then
		self.EquippedEnts[spot] = ents.Create("visual_"..string.lower(spot))
	end
	

	self.EquippedEnts[spot]:SetModel(t.WeaponModel)
	
	self:RecalculateEquipmentPosition()
	
	umsg.Start("getEquip",self)
		umsg.Long(item.ID)
		umsg.String(spot)
	umsg.End()
	
	local t = {}
	for i,v in pairs(self.Equipped) do
		table.insert(t,i..":"..v.ID)
	end
	tmysql.query("UPDATE rpg_characters SET Equipped=\'"..tmysql.escape(table.concat(t,"|")).."\' WHERE ID="..self.CharacterIndex)
	

end
concommand.Add("equipItem",function(pl,cmd,args) pl:EquipItem(args[1],pl.Inventory[tonumber(args[2])]) end)


function meta:RecalculateEquipmentPosition()

	if self.EquippedEnts["Weapon"] then
		local t = self:GetAttachment(self:LookupAttachment("anim_attachment_RH"))

		
		if t then
			self.EquippedEnts["Weapon"]:SetPos(t.Pos)
			self.EquippedEnts["Weapon"]:SetAngles(t.Ang)
			self.EquippedEnts["Weapon"]:SetParent( self )
			self.EquippedEnts["Weapon"]:SetOwner(self)
			self.EquippedEnts["Weapon"]:Fire( "setparentattachmentmaintainoffset ","anim_attachment_RH", 0.01 );
		end
	end
	
end

function meta:HasItem(item)

	return self.Inventory[item.ID] 

end


function meta:GetWeight()
	return self.Weight
end

function meta:GetMaxWeight()
	return 50
end
function meta:HasSkill(skill)

	return self.Skills[skill.Name]

end


function meta:SetMaxHealth(int)

	self:SetNWInt("maxHP",int)

end

function meta:GetSkills()

	return self.Skills
	
end

function meta:SendLoad()

	umsg.Start("accountLoaded",self)
	umsg.End()

end

function meta:SyncAttributes()

	umsg.Start("syncAttributes",self)
		for i,v in pairs(self.Attributes) do
			umsg.String(i)
			umsg.Char(v)
		end
	umsg.End()

end
--[[
function meta:SyncSkills()
	umsg.Start("syncSkills",self)
		for i,v in pairs(self.Skills) do
			umsg.String(i)
			umsg.Long(v.XP)
			umsg.Char(v.Level)
		end
	umsg.End()

end]]

function meta:AddXP(amt,shared)
	amt = math.floor(amt)
	self.XP = self.XP + amt
	umsg.Start("getXP",self)
		umsg.Long(self.XP)
		umsg.Bool(shared)
	umsg.End()
	hook.Call("PlayerXPAdded",GAMEMODE,self,amt,shared)
	self:CheckXP()
end

function meta:CheckXP(prevLeveled)

	if self.XP < TotalXPAtLevel[self.Level] then return false end
	self.Level = self.Level + 1
	self.AttributePoints = self.AttributePoints + 3
	SaveLevel(self)
	
	if self.XP >= TotalXPAtLevel[self.Level] then self:CheckXP(true) end  --recursive level adding
	
	if !prevLeveled then
		umsg.Start("levelUp",self)
			umsg.Short(self.Level)
			umsg.Short(self.AttributePoints)
		umsg.End()
		hook.Call("PlayerLeveledUp",GAMEMODE,self) --make sure this is only called once, and after all recursion is done
	end
	
	


end

function meta:CanAfford(amt)
	return self.Money >= amt
end
function meta:AddMoney(amt)
	self.Money = self.Money + amt
	umsg.Start("updateMoney",self)
		umsg.Long(self.Money)
	umsg.End()
	tmysql.query("UPDATE rpg_characters SET Money=Money+"..(self.Money-self.InitMoney))
	self.InitMoney = self.Money
end
function meta:TakeMoney(amt)
	self.Money = self.Money - amt
	umsg.Start("updateMoney",self)
		umsg.Long(self.Money)
	umsg.End()
	tmysql.query("UPDATE rpg_characters SET Money=Money+"..(self.Money-self.InitMoney))
	self.InitMoney = self.Money
end
function meta:GetMoney()
	return self.Money
end

function meta:OpenStore(name,ent)
	local t = GetStore(name)
	
	if !t then return end
	self.TradingWith = ent
	ent.Selling = true
	
	local ids = {}
	for i,v in pairs(t) do
		ids[i] = v.Item:Send(self)
	end	

	umsg.Start("tradeNPC",self)
		umsg.String(name)
		

		
		for i,v in pairs(t) do
			umsg.Short(ids[i])
			umsg.Short(v.Amount)
			umsg.Long(v.Price)
		end
	umsg.End()
end

function meta:BuyFromNPC(itemID,store)
	local ent = self.TradingWith
	local store = GetStore(store)
	

	
	if !(ValidEntity(ent) && self:CanReach(ent)) then return end
	if  !(store[itemID] && store[itemID].Amount > 0 && self:CanAfford(store[itemID].Price)) then return end
	
	self:TakeMoney(store[itemID].Price)
	
	store[itemID].Amount = store[itemID].Amount - 1
	
	
	self:AddItem(store[itemID].Item)
	umsg.Start("boughtFromNPC",self)
		umsg.Char(itemID)
	umsg.End()
	
	if store[itemID].Amount < 1 then store[itemID] = nil end
end
concommand.Add("buyNPC",function(pl,cmd,args) pl:BuyFromNPC(tonumber(args[1]),args[2]) end)

function meta:StopTrade()
	self.TradingWith = nil
end
concommand.Add("stopTradingNPC",function(pl) pl:StopTrade() end)

function meta:GetEquip(spot)

	return self.Equipped[spot]
	
end

function meta:GetWeaponType()
	local weapon = self:GetEquip("Weapon")
	if !weapon || !items.Get(weapon.BaseType) then return WEAPON_NONE end
	return items.Get(weapon.BaseType).WeaponType 
end


		
function meta:BeginProgress(len,callback)
	if self.InProgress then return end
	umsg.Start("getProgressInfo",self)
		umsg.Short(len)
	umsg.End()
	self:Freeze(true)
	self.InProgress = true
	timer.Create(self:SteamID().."_progress",len,1,function() if !self:IsValid() then return end umsg.Start("stopDrawingProgress",self) umsg.End() self:Freeze(false) self.InProgress = false callback(self) end)
end

function meta:CancelProgress()
	if !self.InProgress then return end
	self.InProgress = false
	self:Freeze(false)
	timer.Destroy(self:SteamID().."_progress")
	umsg.Start("stopDrawingProgress",self) umsg.End()
end
concommand.Add("cancelProgress",function(pl) pl:CancelProgress() end)


function meta:SetDisposition(name,int)
	self.NPCDisposition[name] = int
end
function meta:GetDisposition(name)
	return self.NPCDisposition[name] or 0
end

function meta:AcquireQuest(quest)
	if !quest then error("No Quest Passed to Acquire Quest on player"..self:CharacterName()) return end
	if self.Quests[quest:GetName()] then return end
	self.Quests[quest:GetName()] = {Parts = table.Copy(quest.Parts),CurrentPart = 1,Completed = false,ActiveDungeons = table.Copy(quest.ActiveDungeons)}
	for i,v in pairs(self.Quests[quest:GetName()].Parts) do
		self.Quests[quest:GetName()].Parts[i].Description = nil
	end
	--Zero all numbers
	for partIndex,v in pairs(self.Quests[quest:GetName()].Parts) do
		
		if v.Kills then
			for i,v in pairs(v.Kills) do
				self.Quests[quest:GetName()].Parts[partIndex].Kills[i] = 0
			end
		end
		if v.Items then
			for i,v in pairs(v.Items) do
				self.Quests[quest:GetName()].Parts[partIndex].Items[i] = 0
			end
		end
		for i,v in pairs(v) do
			if type(v) == "function" then
				self.Quests[quest:GetName()].Parts[partIndex][i] = nil
			end
		end
	end
	
	umsg.Start("newQuest",self)
		umsg.String(quest:GetName())
	umsg.End()
	local str = tmysql.escape(glon.encode(self.Quests))
	tmysql.query("UPDATE rpg_characters SET Quests='"..str.."' WHERE ID="..self.CharacterIndex)
		
end

function meta:ActiveQuest(quest) --you have an uncompleted quest

	return self.Quests[quest.Name] && !self.Quests[quest.Name].Completed
		
end


function meta:CompletedQuest(quest)

	return self.Quests[quest.Name] && self.Quests[quest.Name].Completed || self:CompleteQuest(quest)

end

function meta:CompletedQuestPart(quest,num)

	return self.Quests[quest.Name] && self.Quests[quest.Name].CurrentPart > num

end


function meta:CompleteQuest(quest) --first checks if you can complete the quest and then will complete it
	if !self.Quests[quest:GetName()] then return false end -- they do not yet even have the quest
	local partID = self.Quests[quest:GetName()].CurrentPart
	local part = quest.Parts[partID]
	if !part then return false end
	
	
	if part.Kills then
		for i,v in pairs(part.Kills) do
			if self.Quests[quest:GetName()].Parts[partID].Kills[i] < v then return false end
		end
	end
	if part.Items then
		for name,amount in pairs(part.Items) do
			for key,item in pairs(self.Inventory) do
				if item.BaseType == name then
					self:TakeItem(item)
					part.Items[name] = part.Items[name] + 1
				end
			end
			if part.Items[name] < amount then return false end
		end
	end

	if quest.Rewards["$"] then
		self:AddMoney(quest.Rewards["$"])
		quest.Rewards["$"] = nil
	end
	for i,v in pairs(quest.Rewards) do
		self:AddItem(items.Create(i))
	end
	
	self.Quests[quest:GetName()].Completed = true
	local str = tmysql.escape(glon.encode(self.Quests))
	tmysql.query("UPDATE rpg_characters SET Quests='"..str.."' WHERE ID="..self.CharacterIndex)
	return true
end

function meta:AddHealth(amt)

	local num = self:Health()+amt
	num = math.min(self:GetMaxHealth(),num)
	self:SetHealth(num)

end

function meta:AddMana(amt)

	local num = self:GetMana()+amt
	num = math.min(self:GetMaxMana(),num)
	self:SetMana(num)

end

function meta:SetMana(num)
	self:SetDTInt(1,num)
end
function meta:SetMaxMana(amt)
	self:SetNWInt("MaxMana",amt)
end

function meta:PotionHeal(amt)

	self:AddHealth(amt)
	
	local effectdata = EffectData()
	effectdata:SetEntity(self)
	effectdata:SetMagnitude(amt)
	effectdata:SetOrigin(self:GetPos())
	util.Effect("PotionHeal",effectdata)
	
end





function meta:GetStrength()

	return self.Attributes["Strength"]
end

function meta:GetAgility()

	return self.Attributes["Agility"]
	
end

function meta:GetEndurance()

	return self.Attributes["Endurance"]
	
end

function meta:GetIntelligence()

	return self.Attributes["Intelligence"]
	
end


function meta:SetParty(int)
	self:SetDTInt(0,int)
end

function meta:HasWeapon()
	
	return self.Equipped && self.Equipped["Weapon"] or false
end

function meta:HoldingTwoHandWeapon()
	if !(self.Equipped && self.Equipped["Weapon"]) then return false end
	return items.Get(self.Equipped["Weapon"].BaseType).TwoHanded
end

function meta:IsBlocking()
	return self.Blocking
end



function meta:RegenHealth()

	local BaseHealth = (self.Level*0.01) + (self:GetEndurance()*0.1)
	if self.HookedStats.Health then
		for i,v in pairs(self.HookedStats.Health) do
			BaseHealth = BaseHealth * v(BaseHealth)
		end
	end
	BaseHealth = BaseHealth * STAT_REFRESH
	self:AddHealth(BaseHealth)

end

function meta:RegenMana()

	local amt = (self.Level*0.01) + (self:GetIntelligence()*0.1)
	amt = amt * STAT_REFRESH
	self:AddMana(amt)	

end

function meta:ResetSpeed()
	
	local BaseSpeed = 100
	if self.HookedStats.Speed then
		for i,v in pairs(self.HookedStats.Speed) do
			BaseSpeed = BaseSpeed * v(BaseSpeed)
		end
	end
	self:SetWalkSpeed(BaseSpeed)
	self:SetRunSpeed(BaseSpeed*2)


end

function meta:RegenStamina()


end



function meta:AddHealthHook(type,func)
	
		self.HookedStats.Health = self.HookedStats.Health or {}
		self.HookedStats.Health[type] = func
		
end

function meta:AddSpeedHook(type,func)
	
		self.HookedStats.Speed = self.HookedStats.Speed or {}
		self.HookedStats.Speed[type] = func
		self:ResetSpeed()
		
end

function meta:AddManaHook(type,func)
	
		self.HookedStats.Mana = self.HookedStats.Mana or {}
		self.HookedStats.Mana[type] = func
		
end

function meta:AddFatigueHook(type,func)
	
		self.HookedStats.Fatigue = self.HookedStats.Fatigue or {}
		self.HookedStats.Fatigue[type] = func
		
end

function meta:ClearModifiers(type)
	for i,v in pairs(self.HookedStats) do
		v[type] = nil
	end
	self:ResetSpeed()
end

function meta:ShootProjectile(dir,dmgType,effect,baseDamage,flyDist)

	local projectile = ents.Create("base_projectile")
	projectile:SetInstance(self:GetInstance(),self:GetInstanceName())
	projectile:SetPos(self:GetShootPos()+(self:GetForward()*20))
	projectile:SetOwner(self)
	projectile.moveAng = dir
	projectile.dmgType = dmgType
	projectile.effect = effect
	projectile.baseDamage = baseDamage
	projectile.flyDist = flyDist
	projectile:Spawn()

end


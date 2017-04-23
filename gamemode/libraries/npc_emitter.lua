

local list = {}
npce = {}
npce.__index = npce
function npce.new()
	local obj 		= {}
	obj.Properties  = {}
	obj.ents = {}
	obj.IsEmitter = true
	obj.InstancedEnts = {} --list of players so it can check if they need an npc and also put that npc into the right instance
	obj.InstancedRuns = {} --list of runs for that particular instance
	setmetatable(obj,npce)
	obj:SetMax(5)
	obj:SetPos(vector_origin)
	obj:SetDelay(10)
	obj:SetInstanceName("None")
	obj:SetMaxRuns(0)
	obj.Types = {}
	obj.TableIndex = table.insert(list,obj)
	timer.Simple(obj:GetDelay(),function()obj:Run()end)
	return obj
end
function npce.GetAll()
	return list
end
function npce:__tostring()

	return "NPC Emitter"

end
function npce:SetPos(vec)
	self.pos = vec
end
function npce:SetMax(num)
	self:SetProperty("MaxNPC",tonumber(num))
end
function npce:SetDelay(num)
	self:SetProperty("SpawnDelay",tonumber(num))
end
function npce:SetMaxRuns(runs)
	self:SetProperty("MaxRuns",tonumber(runs))
	self.TempRuns = runs
end
function npce:GetMaxRuns()
	return self:GetProperty("MaxRuns")
end
function npce:GetPos()
	return self.pos
end
function npce:GetMax()
	return self:GetProperty("MaxNPC")
end
function npce:GetDelay()
	return self:GetProperty("SpawnDelay")
end
function npce:SetProperty(ind,val)
	self.Properties = self.Properties or {}
	self.Properties[ind] = val
end
function npce:GetProperty(ind)
	return self.Properties[ind]
end
function npce:SetInstanceName(name)
	self:SetProperty("InstName",name)
end
function npce:GetInstanceName()
	return self:GetProperty("InstName")
end
function npce:AddType(tabIndex)

	table.insert(self.Types,tonumber(tabIndex))
	
end
function npce:LoadTypes()
	if self:GetProperty("~types") then
		local t = string.Explode("+",self:GetProperty("~types"))
		for i,v in pairs(t) do
			self:AddType(tonumber(v))
		end
	end
end

function npce:Remove()

	table.remove(list,self.TableIndex)
	self = nil
	
	

end

function npce:GetTypes()
	return self.Types
end

function npce:RunForPlayer(ply)
	--remove dead old ents
	
	if self.Dead || ply:GetInstance() == 0 then return end
	self.InstancedEnts[ply:GetInstance()] = self.InstancedEnts[ply:GetInstance()] or {}
	self.InstancedRuns[ply:GetInstance()] = self.InstancedRuns[ply:GetInstance()] or self:GetMaxRuns()
	local runsLeft = self.InstancedRuns[ply:GetInstance()]
	if self:GetMaxRuns() > 0 && runsLeft < 1 then return end
	
	
	for i,v in pairs(self.InstancedEnts[ply:GetInstance()]) do
		if !ValidEntity(v) then table.remove(self.InstancedEnts[ply:GetInstance()],i) end
	end
	local count = table.Count(self.InstancedEnts[ply:GetInstance()])

	local num = #self:GetTypes()
	if num > 0 && count < self:GetMax() then
	
		local t = NPCMonsters[self:GetTypes()[math.random(1,num)]]
		local class = t.BaseClass or "npc_base_monster"
		local npc = ents.Create(class)
		npc.Spawner = self
		npc:SetReference(t)
		npc:SetInstance(ply:GetInstance())
		npc:SetPos(self.pos+Vector(0,0,5))
		npc:Spawn()
		table.insert(self.InstancedEnts[ply:GetInstance()],npc)
		
	end
	runsLeft = runsLeft - 1
	timer.Simple(self:GetDelay(),self.RunForPlayer,self,ply)
end
function npce:PlayerLeftInstance(pl,oldInst)
	
	if !self.InstancedEnts[oldInst] then return end
	
	if pl:HasParty() then
		local t = GetPartyMembers(pl:GetParty())
		for i,v in pairs(t) do 
			if v:GetInstance() == oldInst then --there is a member of pl's party still inside the instance, don't remove all the npcs!!!!
				return
			end
		end
	end
	
	for i,v in pairs(self.InstancedEnts[oldInst]) do
		v:Remove()
	end
	self.InstancedEnts[oldInst] = {}

end

--internal
function npce:Run()
	--remove dead old ents.
	if self:GetInstanceName() != "None" then return end
	if self:GetMaxRuns() > 0 && self.TempRuns < 1 then return end
	for i,v in pairs(self.ents) do
		if !ValidEntity(v) then table.remove(self.ents,i) end
	end
	local count = table.Count(self.ents)
	local num = #self:GetTypes()
	if num > 0 && count < self:GetMax() then
		local ind = self:GetTypes()[math.random(1,num)]
		local t = NPCMonsters[ind]
		local class = t.BaseClass or "npc_base_monster"
		local npc = ents.Create(class)
		npc.Spawner = self
		npc:SetReference(t)
		npc:SetPos(self.pos+Vector(0,0,5))
		npc:Spawn()
		table.insert(self.ents,npc)
		
	end
	self.TempRuns = self.TempRuns - 1
	timer.Simple(self:GetDelay(),self.Run,self)
end


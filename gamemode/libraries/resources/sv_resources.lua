AddCSLuaFile("sh_resources.lua")
AddCSLuaFile("cl_resources.lua")
include("sh_resources.lua")

local uniqueID = 0
local chunks = {}
local resources = {}
local currentChunk = {}
local resources = {}

chunkData = {}
WorldMaxVector = Vector(0,0,0)
WorldMinVector = Vector(0,0,0)
hook.Add("EntityKeyValue","SetWorldMaxMin",function(ent,key,val)
	if key == "world_maxs" then
		local t = string.Explode(" ",val)
		WorldMaxVector = Vector(t[1],t[2],t[3])
	elseif key == "world_mins" then
		local t = string.Explode(" ",val)
		WorldMinVector = Vector(t[1],t[2],t[3])	
	end

end)

local function RequestWorldVectors(pl,cmd,args)
	if pl.RequestedBounds then return end --only one request per join
	umsg.Start("getWorldbounds",pl)
		umsg.Vector(WorldMaxVector)
		umsg.Vector(WorldMinVector)
	umsg.End()
	pl.RequestedBounds = true
end
concommand.Add("RequestWorldVectors",RequestWorldVectors)


for i=1,GRID_SIZE do chunkData[i] = {} end
local function GenerateChunks()
	CHUNK_LEN = math.Dist(WorldMaxVector.x,WorldMaxVector.y,WorldMaxVector.x,WorldMinVector.y) / GRID_LEN
	local num = 1
	for i=0,GRID_LEN-1 do
		
		for ii=0,GRID_LEN-1 do
			local chunk = {}
			chunk.MinVector = {X = WorldMinVector.x+(ii*CHUNK_LEN),Y = WorldMinVector.y+(i*CHUNK_LEN)}
			chunk.MaxVector = {X = WorldMinVector.x+((ii+1)*CHUNK_LEN),Y = WorldMinVector.y+((i+1)*CHUNK_LEN)}
			chunks[num] = chunk
			num = num + 1
		end
	end
	timer.Create("g_ResourcePhysicalizer",0.1,0,ResourcePhysicalizer)
end
hook.Add("InitPostEntity","GenerateChunks",GenerateChunks)

function harvest.Create(PropertiesTable,pos,nosave,nosend)
	local tblName = PropertiesTable.ResType
	local tbl = harvest.GetResourceTableByName(tblName)
	if !tbl then return end
	local resource = {}	
	resource.Table = tbl
	resource.TableID = resource.Table.Index
	resource.Position = pos
	resource.Properties = PropertiesTable
	local chunk = -1
	for i=1,GRID_SIZE do
		local b = IsInChunk(i,{pos.x,pos.y})
		if b then
			chunk = i
			break
		end
	end
	if chunk == -1 then return end
	resource.ChunkID = chunk
	resource.ChunkTableIndex = table.insert(chunkData[chunk],resource)
	resource.AdjacentChunks = harvest.GetAdjacentChunks(chunk)
	if !nosend then
		umsg.Start("newResourceAdded")
			umsg.String(SaveProperties(PropertiesTable))
			umsg.Vector(pos)
		umsg.End()
	end
	setmetatable(resource,harvest)
	table.insert(resources,resource)
	if !nosave then
		SaveResources(resource,notext)
	end
	return resource


end


function harvest.GetAll()
	return resources
end

function harvest:SetThinkFunction(func,...)
	self.thinkFunc = func
	self.args = {...}
end

function harvest:MakePhysical(uID)
	if ValidEntity(self.Ent) then return end --already changed this instance
	local ent = ents.Create("harvest_resource")
	local vec = self.Table.ModelOffset or Vector(0,0,0)
	ent:SetPos(self.Position+vec)
	ent.Resource = self
	ent:Spawn()
	self.Ent = ent
end

function harvest:FreePhysical(uID)
	if !ValidEntity(self.Ent) then return end --already changed this instance
	self.Ent:Remove()
	self.Ent = nil
end







function IsInChunk(chunkID,pt)
	local chunk = chunks[chunkID]
	if !chunk then return false end
	if chunk.MaxVector.X < pt[1] then return false end
	if chunk.MaxVector.Y < pt[2] then return false end
	if chunk.MinVector.X > pt[1] then return false end
	if chunk.MinVector.Y > pt[2] then return false end
	return true
end





function harvest.GetPlayerChunk(pl)
	local pos = pl:GetPos()
	if currentChunk[pl] && IsInChunk(currentChunk[pl],{pos.x,pos.y}) then return currentChunk[pl] end
	local c = -1
	for i=1,GRID_SIZE do
		local b = IsInChunk(i,{pos.x,pos.y})
		if b then
			c = i
			break
		end
	end
	currentChunk[pl] = c
	return c
end
function harvest.GetAdjacentChunks(chunk)
	local left = chunk + GRID_LEN
	local right = chunk - GRID_LEN
	local front = chunk + 1
	local back = chunk - 1
	local leftback = back + GRID_LEN
	local rightback = back - GRID_LEN
	local leftfront = front + GRID_LEN
	local rightfront = front - GRID_LEN

	
	local backEq = (back)%GRID_LEN != 0
	local frontEq = (front-1)%GRID_LEN != 0
	local t = {}
	if left <= GRID_SIZE then
		t[left] = true
		if backEq then
			t[leftback] = true
		end
		if frontEq then
			t[leftfront] = true
		end
	end
	if right > 0 then
		t[right] = true
		if backEq then
			t[rightback] = true
		end
		if frontEq then
			t[rightfront] = true
		end
	end
	if frontEq then
		t[front] = true
	end
	if backEq then

		t[back] = true
	end
	t[chunk] = true
	return t
end
function ChunkTracker() 
	local pos = {}
	
	for i=1,GRID_SIZE do
		local b = IsInChunk(i,{pos.x,pos.y})
		if b then
			hook.Call("OnEnteredNewChunk",GAMEMODE,i,currentChunk)
			currentChunk = i
			break
		end
	end
end

local num = 0
function ResourcePhysicalizer() --tracks which chunks have active players in them (TODO: Don't count players gone AFK in the wild)
	local activeChunks = {}
	for i,v in pairs(player.GetAll()) do
		local pos = v:GetPos()
		
		local chunk = harvest.GetPlayerChunk(v)
		activeChunks[chunk] = {}
		table.insert(activeChunks[chunk],v:GetPos())
	end
	for chunkID,chunkPositions in pairs(activeChunks) do --loop each active chunk
		for resID,resource in pairs(chunkData[chunkID]) do --loop each tree
			local nearPlayers = table.getn(chunkPositions)
			for posID,vec in ipairs(chunkPositions) do --loop each player within chunk I
				if resource.Position:Distance(vec) < 250 then
					resource:MakePhysical()
				else
					nearPlayers = nearPlayers - 1
				end
				num = num + 1
			end
			if nearPlayers < 1 then
				resource:FreePhysical()
			end
		end
	end
	if DEBUG then	
		print(num)
	end
	num = 0
end



function GM:OnEnteredNewChunk(newChunk,oldChunk)


end
function GM:OnResourceAdded(pos,tblID)

end



function GetSuitablePos(z,num)
	local pos = Vector(math.random(-20000,20000),math.random(-20000,20000),z)
	local t = {}
	t.start = pos
	t.endpos = t.start - Vector(0,0,8196)
	t.mask = MASK_SOLID | MASK_WATER
	t = util.TraceLine(t)
	local mat = t.MatType
	local dot = vector_up:Dot(t.HitNormal)
	local trys = 0
	while (mat != MAT_DIRT ) do
		if trys > 1000 then return end
		trys = trys + 1
		pos = Vector(math.random(-20000,20000),math.random(-20000,20000),z)
		t = {}
		t.start = pos
		t.endpos = t.start - Vector(0,0,8196)
		t.mask = MASK_SOLID | MASK_WATER
		t = util.TraceLine(t)
		mat = t.MatType
		dot = vector_up:Dot(t.HitNormal)
	end
	
	pos = t.HitPos
	pos.z = pos.z - 10
		
	return pos
	
end

function SaveResources(resource)
	SaveObjectToMap("~resource",resource.Properties,resource.Position,Angle(0,0,0),resource)


end



local function LoadResources(ID,Properties,Pos,Ang)
	local resource = harvest.Create(Properties,Pos,true)
end
AddMapLoadHook("~resource",LoadResources)
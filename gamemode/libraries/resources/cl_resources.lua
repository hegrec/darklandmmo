include("sh_resources.lua")






local chunks = {}
chunkData = {}
for i=1,GRID_SIZE do chunkData[i] = {} end
local function GenerateChunks()
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
	g_ResourceEmitter = ParticleEmitter(Me:GetPos())
end





local function drawDevMarkers()
	
	for i,v in pairs(chunks) do
		local a = Vector(v.MinVector.X,v.MinVector.Y,1000):ToScreen()
		local b = Vector(v.MaxVector.X,v.MinVector.Y,1000):ToScreen()
		local c = Vector(v.MinVector.X,v.MaxVector.Y,1000):ToScreen()
		local center = Vector(v.MinVector.X+CHUNK_LEN/2,v.MinVector.Y+CHUNK_LEN/2,1000):ToScreen()
		
		
		surface.SetDrawColor(255,255,255,255)
		surface.DrawLine(a.x,a.y,b.x,b.y)
		surface.DrawLine(a.x,a.y,c.x,c.y)
		draw.SimpleText(i,"Default",center.x,center.y,Color(255,0,0,255),1,1)
	end
		


end
--hook.Add("HUDPaint","drawDevMarkers",drawDevMarkers)

local resources = {}
local resourcePosMap = {}
local resourceTable = {}
local num = 1
function harvest.Create(PropertiesTable,pos)
	
	local resource = {}
	resource.ID = num
	
	resource.Table = harvest.GetResourceTableByName(PropertiesTable.ResType)
	
	resource.TableID = resource.Table.Index
	resource.Position = pos
	resourcePosMap[pos] = resource
	local chunk = -1
	for i=1,GRID_SIZE do
		local b = IsInChunk(i,{pos.x,pos.y})
		if b then
			chunk = i
			break
		end
	end
	resource.ChunkID = chunk
	resource.ChunkTableIndex = table.insert(chunkData[chunk],resource)
	resource.AdjacentChunks = harvest.GetAdjacentChunks(chunk)
	setmetatable(resource,harvest)
	
	resource:StartVisualizer()
	resource:SetChunkChange(function() if resource.AdjacentChunks[harvest.GetCurrentChunk()] then ParticleToModel(resource) else ModelToParticle(resource) end end)
	table.insert(resourceTable,resource)
	num = num + 1
	return resource


end

function harvest:SetChunkChange(func)
	self.thinkFunc = func
end

function harvest:Remove()

	table.remove(chunkData[self.ChunkID],self.ChunkTableIndex)
	if self.Particle then self.Particle:SetDieTime(0) self.Particle = nil end
	if ValidEntity(self.Model) then self.Model:Remove() end
	self = nil
	
end

function harvest.IsResourceAtPos(vec)
	return resourcePosMap[vec]
end


local size = 400
function harvest:StartVisualizer()
	--g_ResourceEmitter:SetPos(self.Position)
	if !self.AdjacentChunks[harvest.GetCurrentChunk()] then
		local pos = self.Position
		local part = g_ResourceEmitter:Add("darkland/rpg/foliage/tree",pos+Vector(0,0,size/1.25))
		part:SetColor(255,255,255,255)
		part:SetDieTime(99999)
		part:SetStartAlpha(255)
		part:SetEndAlpha(255)
		part:SetStartSize(size)
		part:SetEndSize(size)
		self.Particle = part
	else
		local ent = ClientsideModel("models/props_foliage/tree_pine04.mdl",RENDERGROUP_OPAQUE)
		if !ValidEntity(ent) then return end
		local vec = self.Table.ModelOffset or Vector(0,0,0)
		ent:SetPos(self.Position+vec)
		ent:Spawn()
		self.Model = ent
	end
	

end



local currentChunk = 1
function IsInChunk(chunkID,pt)
	
	local chunk = chunks[chunkID]
	if chunk.MaxVector.X < pt[1] then return false end
	if chunk.MaxVector.Y < pt[2] then return false end
	if chunk.MinVector.X > pt[1] then return false end
	if chunk.MinVector.Y > pt[2] then return false end
	return true
end





function harvest.GetCurrentChunk()
	return currentChunk
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

local NewParticlePositions = {}
local check = {}
function harvest.GetNewParticlePositions()
	return NewParticlePositions
end
function harvest.ClearParticlePositions()
	NewParticlePositions = {}
	check = {}
end
function ChunkTracker()

	local pos = Me:GetPos()
	if !IsInChunk(currentChunk,{pos.x,pos.y}) then
		for i=1,GRID_SIZE do
			local b = IsInChunk(i,{pos.x,pos.y})
			if b then
				
				local tempCur = currentChunk
				currentChunk = i
				hook.Call("OnEnteredNewChunk",GAMEMODE,i,tempCur)
				
				break
			end
		end
	end
end

function GM:OnEnteredNewChunk(newChunk,oldChunk)
	local pos = Me:GetPos()
	local num = 0
	for i,v in pairs(harvest.GetAdjacentChunks(oldChunk)) do
		for i,v in ipairs(chunkData[i]) do
			if v.thinkFunc then v.thinkFunc() end
			num = num + 1
		end
	end
	for i,v in pairs(harvest.GetAdjacentChunks(newChunk)) do
		for i,v in ipairs(chunkData[i]) do
			if v.thinkFunc then v.thinkFunc() end
			num = num + 1
		end
	end
	if table.getn(NewParticlePositions) < 1 then return end
	



end
function GM:OnResourceAdded(PropertiesTable,Pos)
	local res = harvest.Create(PropertiesTable,Pos)
end









function ParticleToModel(res)

	if res.Particle then res.Particle:SetDieTime(0) res.Particle = nil end
	if ValidEntity(res.Model) then return end
	local ent = ClientsideModel("models/props_foliage/tree_pine04.mdl",RENDERGROUP_OPAQUE)
	if !ValidEntity(ent) then return end
	if !res.Table then
		PrintTable(res)
	end
	local vec = res.Table.ModelOffset or Vector(0,0,0)
	ent:SetPos(res.Position+vec)
	ent:Spawn()
	res.Model = ent
end

function ModelToParticle(res)
	if ValidEntity(res.Model) then res.Model:Remove() end
	if res.Particle then return end
	local pos = res.Position
	local part = g_ResourceEmitter:Add("darkland/rpg/foliage/tree",pos+Vector(0,0,size/1.25))
	part:SetColor(255,255,255,255)
	part:SetDieTime(99999)
	part:SetStartAlpha(255)
	part:SetEndAlpha(255)
	part:SetStartSize(size)
	part:SetEndSize(size)
	res.Particle = part

end




local function GetWorldBounds(um)
	WorldMaxVector = um:ReadVector()
	WorldMinVector = um:ReadVector()
	CHUNK_LEN = math.Dist(WorldMaxVector.x,WorldMaxVector.y,WorldMaxVector.x,WorldMinVector.y) / GRID_LEN
	local str = WorldMaxVector.x.." "..WorldMaxVector.y.." "..WorldMaxVector.z.." "..WorldMinVector.x.." "..WorldMinVector.y.." "..WorldMinVector.z
	file.Write("darkland/rpg/worldbounds/"..game.GetMap()..".txt",str)
	GenerateChunks()
	http.Get("http://www.darklandservers.com/resources.php?map="..game.GetMap(),"",function(contents,size)
		if !string.find(contents,":") then return end
		local t = string.Explode(" ",contents)
		for i,v in pairs(t) do
			local t2 = string.Explode(":",v)
			
			local pos = string.Explode(" ",base64_decode(t2[2]))
			pos = Vector(pos[1],pos[2],pos[3])
			harvest.Create(LoadProperties(base64_decode(t2[1])),pos)
		end
		timer.Create("g_ChunkTracker",0.2,0,ChunkTracker)
	end)
end
usermessage.Hook("getWorldbounds",GetWorldBounds)

function LoadWorldBounds()

	local str = file.Read("darkland/rpg/worldbounds/"..game.GetMap()..".txt")
	if !str then RunConsoleCommand("RequestWorldVectors") return end
	local t = string.Explode(" ",str)
	WorldMaxVector = Vector(t[1],t[2],t[3])
	WorldMinVector = Vector(t[4],t[5],t[6])
	CHUNK_LEN = math.Dist(WorldMaxVector.x,WorldMaxVector.y,WorldMaxVector.x,WorldMinVector.y) / GRID_LEN
	GenerateChunks()
	http.Get("http://www.darklandservers.com/resources.php?map="..game.GetMap(),"",function(contents,size)
		if !string.find(contents,":") then return end
		local t = string.Explode(":",contents)
		for i,v in pairs(t) do
			timer.Simple(0.01,function()
			local t2 = string.Explode(" ",v)
			
			local pos = string.Explode(" ",base64_decode(t2[2]))
			pos = Vector(pos[1],pos[2],pos[3])
			harvest.Create(LoadProperties(base64_decode(t2[1])),pos)
			end)
		end
		timer.Create("g_ChunkTracker",0.2,0,ChunkTracker)
	end)
end
hook.Add("InitPostEntity","LoadWorldBounds",LoadWorldBounds)







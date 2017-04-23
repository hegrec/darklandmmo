AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include('shared.lua') 





--Be within targetLeniency units of target and you are considered at the target
local targetLeniency = 32
--Default the values here so derived NPCs don't ever break
function ENT:Initialize()
	
	self:LoadAIMap()
	--Quick fix for NPCs always falling through the ground :/
	self:SetPos(self:GetPos()+Vector(0,0,10))
	
	self:SetupNPC() --set model and the vars above here
	
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)
	self:SetSolid(SOLID_BBOX)
	
	--this is just to store what node we are trying to get to
	self.Destination = self:GetPos()
	
	

	
end

function ENT:SetupNPC()
	print("WARNING: Initializing NPC as npc_basenpc ID #"..self:EntIndex())
	self:SetModel("models/player.mdl")
	
	self:SetTargetPos(self:GetPos())
	self.WalkSpeed = 200
	self.RunSpeed = 300
	self:SetAction(ACTION_IDLE)
	


end


function ENT:LoadAIMap()
	nav2.SetGridSize(128)
	
	local Mesh = nav2.CreateMesh()
	
	Mesh:Start(self:GetPos(),1024)



	
	while(Mesh:Step()) do
	
	end
	

	local object = ai_node.CreateMap()
	for k,v in pairs(Mesh.Nodes) do object:AddNode(v:GetPosition()) end
	object:SetEstimate(1)
	object:SetHeuristic(HEURISTIC_EUCLIDEAN)
	
	local done = 0
	local numNodes = table.Count(object.nodes)
	for k,v in pairs(object.nodes) do
		
		local h_a, h_b, h_c = debug.gethook()
		debug.sethook(function() end, "", 0)

		for k2,v2 in pairs(object.nodes) do
			if(k != k2) then
				for Dir = nav2.NORTH, nav2.NUM_DIRECTIONS do 
					local node = Mesh.Nodes[nav2.GetPosStr(k2)]
					
					local dirNode = Mesh.Nodes[nav2.GetPosStr(k)]:GetConnection(Dir)
					if(node == dirNode) then
						object:LinkNode(k, k2)
					end
				end
			end
		end
		debug.sethook(function() end, h_b, h_c)
		done = done + 1
		
	end
	print("Total Nodes: "..numNodes)
	self.AIMap = object
end

function ENT:SetAIMap(index)

	
	self.AIMap = AIMaps.GetMap(index)

end

function ENT:SetAction(action)

	self.dt.CurrentAction = action
end

function ENT:Think()
	self:SetPos(self:GetPos()+self:GetForward()*16)
	self:NextThink(CurTime()+0.1)
end

function ENT:SetTargetPos(vec)
	
	self.dt.TargetPosition = vec
	
	
end

function ENT:SetDestination(vec)
	
	self.Destination = vec
	
end



function ENT:Think()

	if self:GetAction() == ACTION_IDLE then
		
		return
		
	elseif self:GetAction() == ACTION_WANDER then
	
		if self:ReachedDestination() then
			self:SelectRandomNode()
		else
			self:HandleNavigation()
		end
	end

	self:NextThink(CurTime()+0.2)
	return true
end

function ENT:HandleNavigation()

	local pos = self:GetPos()
	local dir = (self:GetTargetPos()-pos):Normalize()
	self:SetPos(pos+dir*16)
	
	
	--we reached our current target node
	if self:ReachedTarget() then
		--print("Reached Target Node")
		if self:ReachedDestination() then
			--print("Reached Destination Node")
			return
		else
			self.CurrentPathNodeIndex = self.CurrentPathNodeIndex+1
			local nextNode = self.CurrentPath[self.CurrentPathNodeIndex]
			self:SetTargetPos(nextNode)
			return
		end
		
	end
end


function ENT:SelectRandomNode(dist)
	dist = dist or 300
	local t = {}
	local npcPos = self:GetPos()
	for i,v in pairs(self.AIMap.nodes) do
		if i:Distance(npcPos) < dist then
			table.insert(t,i)
		end
	end
	table.sort(t,function(a,b) return a:Distance(npcPos) < b:Distance(npcPos) end)
	
	self.AIMap:SetStart(t[1])
	self.AIMap:SetEnd(t[table.getn(t)])

	local Found, Path = self.AIMap:FindPath()
	
	if(Found) then
		self.CurrentPath = Path
		self.CurrentPathNodeIndex = 1
		self:SetTargetPos(Path[1])
		self:SetDestination(Path[table.getn(Path)])
		return true
	end
	return false
end


function ENT:ReachedDestination()

	return self.Destination:Distance(self:GetPos()) < targetLeniency

end
function ENT:ReachedTarget()

	return self:GetTargetPos():Distance(self:GetPos()) < targetLeniency

end
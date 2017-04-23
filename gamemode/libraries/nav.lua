module("nav2", package.seeall)

--[[
My logic works like this:
1. build the grid and add the nodes to the queue
2. once the entire mesh is created go back and fill in any connections
	the mesh should auto optimize but we will visually see as we test
	]]
	
GRID_SIZE = 128
STEP_SIZE = 300

--north is +y
--east is +x
NORTH = 1
SOUTH = 2
EAST = 3
WEST = 4

NUM_DIRECTIONS = 4

MAX_CONNECTIONS = 4

TRACE_MASK = SOLID_BRUSHONLY

--hl2 limits
--player model height
MIN_HEIGHT = 73
--max stair height
MAX_Z_OFFSET = 18
--width of player
-- 33 / 2 rounded up
MIN_WIDTH = 17

PLAYER_OBB_MAXS = Vector(16, 16, 72)
PLAYER_OBB_MINS = Vector(-16, -16, 0)

TRACE_HULL_UP = Vector(0,0,MIN_HEIGHT)
TRACE_HULL_NORTH = Vector(0,MIN_WIDTH)
TRACE_HULL_SOUTH = Vector(0,-MIN_WIDTH)
TRACE_HULL_EAST = Vector(MIN_WIDTH,0)
TRACE_HULL_WEST = Vector(-MIN_WIDTH,0)
TRACE_HULL_STAIR = Vector(0,0,-MAX_Z_OFFSET)

TRACE_UP = Vector(0,0, GRID_SIZE)
TRACE_DOWN = Vector(0,0,-8192)
TRACE_NORTH = Vector(0,GRID_SIZE)
TRACE_SOUTH = Vector(0,-GRID_SIZE)
TRACE_EAST = Vector(GRID_SIZE,0)
TRACE_WEST = Vector(-GRID_SIZE,0)

TRACE_STAIR = Vector(0,0,MAX_Z_OFFSET)

PHASE_BUILDING_MESH = 1
PHASE_OPTIMIAZATION = 2
PHASE_DONE = 3

--does this actually improve memory usage and speed?
local tr

function SnapToGrid(pos)
	if type(pos) == "Vector" then
		--not worth the memory for the constructor of Vector
		--return Vector(SnapToGrid(pos.x), SnapToGrid(pos.y), pos.z)
		pos.x = SnapToGrid(pos.x)
		pos.y = SnapToGrid(pos.y)
		return pos
	end
	return math.floor(pos / GRID_SIZE) * GRID_SIZE
end

function OppositeDir(dir)
	if dir == NORTH then
		return SOUTH
	elseif dir == SOUTH then
		return NORTH
	elseif dir == WEST then
		return EAST
	elseif dir == EAST then
		return WEST
	else 
		return nil
	end
end

function SetGridSize(size)
	GRID_SIZE = size
	TRACE_UP = Vector(0,0, GRID_SIZE)
	TRACE_DOWN = Vector(0,0,-8192)
	TRACE_NORTH = Vector(0,GRID_SIZE)
	TRACE_SOUTH = Vector(0,-GRID_SIZE)
	TRACE_EAST = Vector(GRID_SIZE,0)
	TRACE_WEST = Vector(-GRID_SIZE,0)
end

function TraceUp(pos)
	tr = {
		start = pos,
		endpos = pos + TRACE_UP,
		mask = TRACE_MASK
	}
	
	tr = util.TraceLine(tr)
	return tr.HitWorld, tr.HitPos, tr.HitNormal, tr.HitSky
end

function TraceDown(pos)
	tr = {
		start = pos,
		endpos = pos + TRACE_DOWN,
		mask = TRACE_MASK
	}
	
	tr = util.TraceLine(tr)
	return tr.HitWorld, tr.HitPos, tr.HitNormal, tr.HitSky, tr.HitTexture
end

function TraceSide(pos, dir)
	local ending
	if dir == NORTH then
		ending = pos + TRACE_NORTH
	elseif dir == SOUTH then
		ending = pos + TRACE_SOUTH
	elseif dir == EAST then
		ending = pos + TRACE_EAST
	else
		ending = pos + TRACE_WEST
	end
	
	tr = {
		start = pos,
		endpos = ending,
		mask = TRACE_MASK
		}
		
	tr = util.TraceLine(tr)
	return tr.HitWorld, tr.HitPos, tr.HitNormal, tr.HitSky
end

function TracePointToPoint(pos1, pos2)
	tr = {
		start = pos1 + Vector(0,0, 15),
		endpos = pos2 + Vector(0,0,1),
		mask = TRACE_MASK
	}
	tr = util.TraceLine(tr)
	return tr.Fraction == 1
end

function HullTrace(pos)
	print(pos)
	tr = {
		start = pos,
		endpos = pos,
		mask = TRACE_MASK,
		mins = PLAYER_OBB_MINS,
		maxs = PLAYER_OBB_MAX
	}
	
	tr = util.TraceHull(tr)
	PrintTable(tr)
	return tr.Fraction == 1
end

--can a player stand here?
function HullTraceUp(pos)
	tr = {
		start = pos,
		endpos = pos + TRACE_HULL_UP,
		mask = TRACE_MASK
	}
	
	tr = util.TraceLine(tr)
	return tr.Fraction == 1
end

--can a player fit on this node
--Note: Both North and South have to fit or E and W
function HullTraceSide(pos, dir)
	local ending
	if dir == NORTH then
		ending = pos + TRACE_HULL_NORTH
	elseif dir == SOUTH then
		ending = pos + TRACE_HULL_SOUTH
	elseif dir == EAST then
		ending = pos + TRACE_HULL_EAST
	else
		ending = pos + TRACE_HULL_WEST
	end
	
	tr = {
		start = pos,
		endpos = ending,
		mask = TRACE_MASK
		}
		
	tr = util.TraceLine(tr)
	return tr.Fraction == 1
end

function TraceForStairs(pos1, pos2)
	local midpoint = ((pos1 + pos2) / 2)
	--print(midpoint)
	--print(midpoint + TRACE_HULL_STAIR)
	tr = {
		start = midpoint,
		endpos = midpoint + TRACE_HULL_STAIR,
		mask = TRACE_MASK
		}
	tr = util.TraceLine(tr)
	--PrintTable(tr)
	return tr.Fraction < 1 or tr.FractionLeftSolid == 1
end


function ValidStairs(startPos,endPos)
	local startingPoint
	local endingPoint
	local zZeroedStart
	local zZeroedEnd
	local dir
	if startPos.z < endPos.z then
		startingPoint = startPos
		endingPoint = endPos
		zZeroedStart = Vector(startingPoint.x,startingPoint.y,0)
		zZeroedEnd = Vector(endPos.x,endPos.y,0)
	else
		startingPoint = endPos
		endingPoint = startPos
		zZeroedEnd = Vector(startingPoint.x,startingPoint.y,0)
		zZeroedStart = Vector(endPos.x,endPos.y,0)
	end
	
	
	local dir = (zZeroedStart-zZeroedEnd):Normalize()
	while true do
		local t = {}
		t.start = startingPoint
		if startingPoint.z > endingPoint.z then return true end --made it all the way up the stairs
		t.endpos = t.start+dir*30 --30 units of stair depth should be enough, can increase later
		t.mask = TRACE_MASK
		local backTrace = util.TraceLine(t)
		if !backTrace.Hit then return false end
		t = {}
		t.start = backTrace.HitPos+dir*2+Vector(0,0,30)
		t.endpos = t.start-Vector(0,0,50)
		t.mask = TRACE_MASK
		local downTrace = util.TraceLine(t)
		if math.abs(downTrace.HitPos.z-backTrace.HitPos.z) > MAX_Z_OFFSET || !downTrace.Hit then return false end --stairs are too high!
		startingPoint = downTrace.HitPos
	end
		
end

function CanPlyFitHere(pos)
	pos = pos + Vector(0,0,1)
	if !HullTraceUp(pos) then
		return false
	elseif !HullTraceSide(pos, NORTH) or !HullTraceSide(pos, SOUTH) then
		return false
	elseif !HullTraceSide(pos, EAST) or !HullTraceSide(pos, WEST) then
		return false
	else
		return true
	end
end

function ValidPos(hitpos, normal)
	--make sure normal is up and within 45 degrees
	local ang = normal:Angle()
	if ang.p <= 315 and ang.r <= 315 and util.PointContents(hitpos) != (CONTENTS_SOLID | CONTENTS_WATER | CONTENTS_TRANSLUCENT) then
		return true
	end
	return false
end

function ValidTexture(texture)
	if texture == "TOOLS/TOOLSNODRAW" then
		return false
	end
	return true
end

function AngleBetween(pos1, pos2)
	pos1 = pos1:GetNormalized()
	pos2 = pos2:GetNormalized()
	return math.acos(pos1:Dot(pos2))
end

function ValidConnection(pos1, pos2)
	local ang = AngleBetween(pos1,pos2)
	if(ang <= 315 and TracePointToPoint(pos1,pos2))then
		return true
	end
	return false
end

--hack: you can have two vectors that are the same as keys
function GetPosStr(pos)
	return pos.x .. " " .. pos.y .. " " .. pos.z
end

local NodeMeta = {}
local NodeMethods = {}
NodeMeta.__index = NodeMethods

function CreateNode(Pos, Normal)
	local Node = {}
	Node.Pos = Pos
	Node.LinkDir = {}
	Node.Visited = {}
	Node.Normal = Normal
	setmetatable(Node, NodeMeta)
	return Node
end

function NodeMethods:GetX()
	return self.Pos.x
end

function NodeMethods:GetY()
	return self.Pos.y
end

function NodeMethods:GetZ()
	return self.Pos.z
end

function NodeMethods:GetNormal()
	return self.Normal
end

function NodeMethods:GetParent()
	return self.Parent
end

function NodeMethods:GetPosition()
	return self.Pos
end

function NodeMethods:HasVisited(Dir)
	return self.Visited[Dir]
end

function NodeMethods:MarkAsVisited(Dir)
	self.Visited[Dir] = true
end

function NodeMethods:UnMarkAsVisited(Dir)
	self.Visited[Dir] = nil
end

function NodeMethods:ConnectTo(Node, Dir)
	self.LinkDir[Dir] = Node
end

function NodeMethods:DisconnectFrom(Dir)
	self.LinkDir[Dir] = nil
end

function NodeMethods:GetConnection(Dir)
	return self.LinkDir[Dir]
end

function NodeMethods:GetAllConnections()
	local Table = {}
	for Dir = NORTH, NUM_DIRECTIONS do
		local Connected = self:GetConnection(Dir)
		if(Connected) then
			table.insert(Table, Connected)
		end
	end
	return Table
end

function NodeMethods:ConnectedToAll()
	for Dir = NORTH, NUM_DIRECTIONS do
		if(!self:GetConnection(Dir)) then
			return false
		end
	end
	return true
end

function NodeMethods:IsBiLinked(Dir)
	if(self:GetConnection(Dir) and self:GetConnection(Dir):GetConnection(OppositeDir(Dir)) == self) then
		return true
	end
	return false
end

function NodeMethods:HasConnections()
	for Dir = NORTH,NUM_DIRECTIONS do
		if self:GetConnection(Dir) then
			return true
		end
	end
	return false
end

function NodeMethods:GetPosString()
	return GetPosStr(self.Pos)
end

local MeshMeta = {}
local MeshMethods = {}
MeshMeta.__index = MeshMethods

function CreateMesh()
	local Mesh = {}
	Mesh.Mesh = {}
	Mesh.Nodes = {}
	Mesh.NextNodes = {}
	Mesh.Queue = {}
	Mesh.CurrentNode = nil
	setmetatable(Mesh, MeshMeta)
	return Mesh
end
local startTime
function MeshMethods:Start(pos,radius)
	startTime = CurTime()
	if type(pos) != "Vector" then
		error("Position vector expected!")
	end
	
	self.Radius = radius or math.huge
	
	local HitWorld, HitPos, Normal = TraceDown(SnapToGrid(pos))
	self.Origin = HitPos
	self.CurrentNode = CreateNode(HitPos, Normal)
	self.Nodes[self.CurrentNode:GetPosString()] = self.CurrentNode
	self:AddAjacentNodesToQueue(HitPos)
	self.CurrentPhase = PHASE_BUILDING_MESH
end

function MeshMethods:AddAjacentNodesToQueue(pos)
	for i=NORTH,NUM_DIRECTIONS do
		if !self.CurrentNode:HasVisited(i) then
			self.CurrentNode:MarkAsVisited(i)
			
			local UpHitWorld, UpHitPos, UpHitNormal = TraceUp(pos)
		
			local ending
			if i == NORTH then
				ending = UpHitPos + TRACE_NORTH
			elseif i == SOUTH then
				ending = UpHitPos + TRACE_SOUTH
			elseif i == EAST then
				ending = UpHitPos + TRACE_EAST
			else
				ending = UpHitPos + TRACE_WEST
			end
			
			local DownHitWorld, DownHitPos, DownHitNormal, DownHitSky, DownTexture = TraceDown(ending)
			if self.Origin:Distance(DownHitPos) <= self.Radius then
			
				if !self.Nodes[GetPosStr(DownHitPos)] then
					if DownHitWorld and !DownHitSky and ValidPos(DownHitPos,DownHitNormal) and ValidTexture(DownTexture) and (TracePointToPoint(DownHitPos, self.CurrentNode:GetPosition()) or ValidStairs(pos,DownHitPos)) then
						local NewNode = CreateNode(DownHitPos, DownHitNormal)
						local str = NewNode:GetPosString()
						self.Nodes[str] = NewNode
						self.Queue[str] = NewNode
						
						NewNode:MarkAsVisited(OppositeDir(i))
						
						NewNode:ConnectTo(self.CurrentNode, i)
						self.CurrentNode:ConnectTo(NewNode, OppositeDir(i))
					end
					
				else
				
					local OldNode = self.Nodes[GetPosStr(DownHitPos)]
					if TracePointToPoint(OldNode:GetPosition(), self.CurrentNode:GetPosition()) then
						OldNode:MarkAsVisited(OppositeDir(i))
						
						OldNode:ConnectTo(self.CurrentNode, i)
						self.CurrentNode:ConnectTo(OldNode, OppositeDir(i))
					end
					
				end
			
			end
		end
	end
end

function MeshMethods:RemoveNode(node)
	for Dir = NORTH,NUM_DIRECTIONS do
		if node:GetConnection(Dir) then
			node:GetConnection(Dir):DisconnectFrom(OppositeDir(Dir))
			if !node:GetConnection(Dir):HasConnections() then
				self:RemoveNode(node:GetConnection(Dir))
			end
		end
	end
	local str = node:GetPosString()
	self.Nodes[str] = nil
end

function MeshMethods:Optimize()
	--need a good hull trace method
	local Node = self.CurrentNode
	for Dir = NORTH,NUM_DIRECTIONS do
		local OtherNode = Node:GetConnection(Dir)
		if(OtherNode)then
			Node:MarkAsVisited(Dir)
			OtherNode:MarkAsVisited(OppositeDir(Dir))
			
			--[[local pos1 = Node:GetPosition()
			local pos2 = OtherNode:GetPosition()
			if math.abs(pos1.z - pos2.z) > MAX_Z_OFFSET then --the distance between the nodes is bigger than a stair
				if !ValidStairs(pos1,pos2) then --needs work, breaks stairs but everything else works lol
					OtherNode:DisconnectFrom(OppositeDir(Dir))
					Node:DisconnectFrom(Dir)
					self.Nodes[Node:GetPosString()] = Node --commit the changes
					self.Nodes[OtherNode:GetPosString()] = OtherNode
				end
			end]]
			
			local stop = false
			if !Node:HasConnections() then
				self.Nodes[Node:GetPosString()] = nil
				stop = true
			end
					
			if !OtherNode:HasConnections() then
				self.Nodes[OtherNode:GetPosString()] = nil
				stop = true
			end
			
			if stop then
				return
			end
		end
	end
	
	if #Node:GetAllConnections() == 1 then --these nodes only connect to eachother
		for Dir = NORTH,NUM_DIRECTIONS do
			local OtherNode = Node:GetConnection(Dir)
			if OtherNode and #OtherNode:GetAllConnections() == 1 then
				self.Nodes[Node:GetPosString()] = nil
				self.Nodes[OtherNode:GetPosString()] = nil
				return
			end
		end
	end
end

local starttime = nil
function MeshMethods:Step()
	if self.CurrentPhase == PHASE_DONE then
		return false
	end
	
	for i=1,STEP_SIZE do
		if self.CurrentPhase == PHASE_BUILDING_MESH then
		
			if table.Count(self.Queue) == 0 then
				print("Phase Mesh Building Complete: ".. CurTime() - startTime .. "secs")
				startTime = CurTime()
				self.CurrentPhase = PHASE_OPTIMIAZATION
				self.Queue = table.Copy(self.Nodes) --optimize the whole damn thing...lol
				for k,v in pairs(self.Nodes)do
					v.Visited = {} --reset visted for optimiazation
				end	
				return true
			end
			
			local key = table.GetFirstKey(self.Queue)
			
			self.CurrentNode = self.Queue[key]
			self.Queue[key] = nil
			self:AddAjacentNodesToQueue(self.CurrentNode:GetPosition())
			
		elseif self.CurrentPhase == PHASE_OPTIMIAZATION then
			if table.Count(self.Queue) == 0 then
				print("Phase Optimiazation Complete: ".. CurTime() - startTime .. "secs")
				self.CurrentPhase = PHASE_DONE
				return false
			end		

			local key = table.GetFirstKey(self.Queue)
			
			self.CurrentNode = self.Queue[key]
			self.Queue[key] = nil

			self:Optimize()		
		end
	end
	return true
end
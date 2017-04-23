----------------------
-- AI Node Module
-- By Spacetech
-- AKA A*
-- But not really
-- This is way -->
-- COOLER
----------------------

HEURISTIC_MANHATTAN	= 1
HEURISTIC_EUCLIDEAN	= 2
HEURISTIC_DISTANCE	= 3

module("ai_node", package.seeall)

/*
Example
function PlayerAI.CalculatePath(Start, End)
	local map = ai_node.CreateMap()
	
	for k,v in pairs(PlayerAI.Nodes) do
		map:AddNode(v)
	end
	
	map:SetStart(Start) -- start this has to be in the node table
	map:SetEnd(End) -- end this has to be in the node table
	
	map:SetEstimate(1)
	map:SetHeuristic(ai_node.HEURISTIC_MANHATTAN)
	
	--map:AutoLinkNodes(72)
	map:LinkNodes(function(node1, node2)
		local nodeTable1 = PlayerAI.LinkedNodes[node1]
		local nodeTable2 = PlayerAI.LinkedNodes[node2]
		if(nodeTable1) then
			if(table.HasValue(nodeTable1, node2)) then
				return true
			end
		elseif(nodeTable2) then
			if(table.HasValue(nodeTable2, node1)) then
				return true
			end
		elseif(node1:Distance(node2) <= 128) then
			if(PlayerAI.SeeNode(node1 + Vector(0, 0, 5), node2)) then
				return true
			end
		end
		return false
	end)
	
	local found, path = map:FindPath()
	print("Found", found)
	
	return path
end

or
THIS EXAMPLE IS NEWER
function TBS.Units:CalculatePath(Start, End, Ent)
	local Map = ai_node.CreateMap()
	
	local Taken = {}
	for k,v in pairs(ents.FindByClass("tbs_unit")) do
		if(v != Ent) then
			table.insert(Taken, v:GetGridPos())
		end
	end
	
	for x,v in pairs(TBS.Grid.Points) do
		for y,v2 in pairs(v) do
			if(!table.HasValue(Taken, Grid(x, y))) then
				Map:AddNode(v2.Pos)
			end
		end
	end
	
	Map:SetStart(Start)
	Map:SetEnd(End)
	Map:SetEstimate(1)
	Map:SetHeuristic(HEURISTIC_EUCLIDEAN) -- I don't even know HEURISTIC_MANHATTAN
	Map:AutoLinkNodes(TBS.Grid.Size * 2.3)
	
	self.Nodes = Map:GetNodes()
	
	local Found, Path = Map:FindPath()
	
	if(Found) then
		return Path
	end
	
	return false
end

*/

local mt = {}
local methods = {}
mt.__index = methods

function CreateMap()
	local map = {}
	map.nodes = {}
	setmetatable(map, mt)
	return map
end

function methods:AddNode(node)
	self.nodes[node] = {}
end

function methods:SetNodeTable(tNodes)
	self.nodes = table.Copy(tNodes)
end

function methods:GetNodes()
	return self.nodes
end

function methods:GetStart()
	return self.nodeStart
end

function methods:SetStart(node)
	self.nodeStart = node
end

function methods:SetEnd(node)
	self.nodeEnd = node
end

function methods:GetEnd()
	return self.nodeEnd
end

function methods:GetEstimate()
	return self.estimate
end

function methods:SetEstimate(estimate)
	self.estimate = estimate
end

function methods:GetLinks(node)
	return self.nodes[node]
end

function methods:LinkNode(node1, node2)
	table.insert(self.nodes[node1], node2)
end

function methods:LinkNodes(func)
	for k,v in pairs(self.nodes) do
		for k2,v2 in pairs(self.nodes) do
			if(k != k2) then
				if(func(k, k2)) then
					self:LinkNode(k, k2)
				end
			end
		end
	end
end

function methods:AutoLinkNodes(distance)
	for k,v in pairs(self.nodes) do
		for k2,v2 in pairs(self.nodes) do
			if(k != k2 and k:Distance(k2) <= distance) then
				self:LinkNode(k, k2)
			end
		end
	end
	NODES = self.nodes
end

function methods:GetHeuristic(heuristic)
	return self.heuristic
end

function methods:SetHeuristic(heuristic)
	self.heuristic = heuristic
end

function methods:ManhattanDistance(nodeStart, nodeEnd)
	return (math.abs(nodeEnd.x - nodeStart.x) + math.abs(nodeEnd.y - nodeStart.y) + math.abs(nodeEnd.z - nodeStart.z)) * self:GetEstimate()
end

function methods:EuclideanDistance(nodeStart, nodeEnd)
	return math.sqrt(((nodeEnd.x - nodeStart.x) ^ 2) + ((nodeEnd.y - nodeStart.y) ^ 2) + ((nodeEnd.z - nodeStart.z) ^ 2)) * self:GetEstimate()
end

function methods:HeuristicDistance(nodeStart, nodeEnd)
	local nodeEnd = nodeEnd or self:GetEnd()
	local heuristic = self:GetHeuristic()
	if(heuristic == HEURISTIC_MANHATTAN) then
		return self:ManhattanDistance(nodeStart, nodeEnd)
	elseif(heuristic == HEURISTIC_EUCLIDEAN) then
		return self:EuclideanDistance(nodeStart, nodeEnd)
	elseif(heuristic == HEURISTIC_DISTANCE) then
		return nodeStart:Distance(nodeEnd)
	elseif(type(heuristic) == "function") then
		return heuristic(nodeStart, nodeEnd)
	end
	Error("ai_node: Invalid Heuristic: ", heuristic)
	return 0
end

function methods:CalcPath(nodeCurrent)
	local countPath = 1
	local tNewPath = {}
	local tPath = {nodeCurrent}
	local nodeParent = nodeCurrent
	while(tPath[countPath]) do
		countPath = countPath + 1
		nodeParent = self.nodeStatus[nodeParent].parent
		tPath[countPath] = nodeParent
	end
	local difference = false
	local countPath = table.Count(tPath)
	for k,v in pairs(tPath) do
		difference = countPath - k
		if(difference > 0) then
			tNewPath[difference] = v
		end
	end
	return tNewPath
end

function methods:SetupNodeStatus(node, open, parent, scoreF, scoreG, scoreH)
	self.nodeStatus[node] = {
		open = open,
		parent = parent,
		scoreF = scoreF,
		scoreG = scoreG,
		scoreH = scoreH
	}
	return self.nodeStatus[node]
end

function methods:FindPath()
	self.nodeStatus = {}
	self.nodeStart = self:GetStart()
	self.nodeEnd = self:GetEnd()
	local lastNode = self.nodeStart
	
	-- 1) Add the starting square (or node) to the open list.
	self:SetupNodeStatus(self.nodeStart, true, false, 0, 0, self:HeuristicDistance(self.nodeStart))
	
	-- 2) Repeat the following.
	while(self.nodeCurrent != self.nodeEnd) do
		local scoreF = false
		local nodeCurrent = false
		local nodeCurrentStatus = false
		local nodeScoreF = false
		local nodeScoreG = false
		
		-- a) Look for the lowest F cost square on the open list.
		for k,v in pairs(self.nodeStatus) do
			if(v.open) then
				scoreF = v.scoreF
				if(!nodeScoreF or scoreF < nodeScoreF) then
					nodeCurrent = k
					nodeCurrentStatus = v
					nodeScoreF = scoreF
					nodeScoreG = v.scoreG
				end
			end
		end
		
		if(nodeCurrent == self.nodeEnd) then
			return true, self:CalcPath(nodeCurrent)
		elseif(nodeCurrent) then
			lastNode = nodeCurrent
			
			-- b) Switch it to the closed list.
			nodeCurrentStatus.open = false
			-- c) For each of the nodes linked to this node...
			for k,v in pairs(self:GetLinks(nodeCurrent)) do
				local status = self.nodeStatus[v]
				-- If it isn’t on the open list, add it to the open list. Make the current square the parent of this square. Record the F, G, and H costs of the square. 
				if(!status) then
					local scoreG = nodeScoreG + self:HeuristicDistance(nodeCurrent, v)
					local scoreH = self:HeuristicDistance(nodeCurrent)
					local scoreF = scoreG + scoreH
					status = self:SetupNodeStatus(v, true, nodeCurrent, scoreF, scoreG, scoreH)
				end
				-- If it is not walkable or if it is on the closed list, ignore it. Otherwise do the following.
				if(status.open) then
					-- Check to see if this path to that square is better, using G cost as the measure.
					if(nodeScoreG > status.scoreG) then
						-- If so, change the parent of the square to the current square, and recalculate the G and F scores of the square.
						status.parent = nodeCurrent
						--status.scoreG = nodeScoreG + self:HeuristicDistance(nodeCurrent, v)
						--status.scoreF = status.scoreG + status.scoreH
					end
				end
			end
		else
			return false, self:CalcPath(lastNode)
		end
	end
end
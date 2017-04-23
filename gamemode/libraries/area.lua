area = {}
local areaList = {}
for i,v in pairs(Areas) do
	areaList[i] = {}
end
function area.GetItems(id)
	return areaList[id]
end
function area.AddItem(databaseID,classname,properties,mapindex,pos,ang,nosave,pSpawner)
	local areaID = properties.AreaID
	areaList[areaID] = areaList[areaID] or {}
	local object = nil
	local alreadyHandled = false
	local tID = -1
	
		if classname == "harvest_resource" then
			
			object = harvest.Create(properties,pos,false,nosave) --let resource manager manage this resource, as it is not always an entity.
			return
		elseif classname == "door_exit_spawn" then
			object = door.CreateExit(properties,pos,ang)
			return
		elseif classname == "npc_important" then
			local ent = ents.FindByClass("npc_important")
			local found = NULL
			for i,v in pairs(ent) do
				if v:GetName() == properties.StoredName then
					object = v
					break
				end
			end
			if ValidEntity(object) then
				object:SetPos(pos)
				object:SetAngles(ang)
				alreadyHandled = true
			end
		elseif classname == "npc_nodegraph" then
			print(properties.GridWidth)
			nav2.SetGridSize(properties.GridWidth or 256)
			local radius = properties.MaxDistance
			
			local Mesh = nav2.CreateMesh()
			
			Mesh:Start(pos,tonumber(radius) != -1 and tonumber(radius) or math.huge)

			
			
			hook.Add("Think", "BuildGraph_", function()

				
				local Running = Mesh:Step()
				
				if !Running then
				
					hook.Remove("Think","BuildGraph_")
					if pSpawner then
						print("Sending "..table.Count(Mesh.Nodes).." nodes to "..pSpawner:CharacterName())
						local t = table.Copy(Mesh.Nodes)
						for i,v in pairs(t) do
							v.Visited = nil
						end
						local h_a, h_b, h_c = debug.gethook()
						debug.sethook(function() end, "", 0)
							datastream.StreamToClients(pSpawner,"GetNodeGraph",t)
						debug.sethook(function() end, h_b, h_c)
					end
					--[[
					object = ai_node.CreateMap()
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
									for Dir = nav.NORTH, nav.NUM_DIRECTIONS do 
										local node = Mesh:GetNodePosMap(k2)
										
										local dirNode = Mesh:GetNodePosMap(k):GetConnection(Dir)
										if(node == dirNode) then
											object:LinkNode(k, k2)
										end
									end
								end
							end
							debug.sethook(function() end, h_b, h_c)
							done = done + 1
							print("Done node: "..done.."/"..numNodes)
					end]]
					
				end
			
			
			
			end)
			alreadyHandled = true
		end
		
		
		
		if !alreadyHandled then
			object = ents.Create(classname)
			object.Properties = properties
			object:SetPos(pos)
			object:SetAngles(Angle(0,math.random(359),0))
			object:SetNWBool("deletable",true)
			object:Spawn()
			if object:IsNPC() then
				object:SetPos(pos+Vector(0,0,10))
			end
			tID = table.insert(areaList[areaID],{DatabaseID = -1,Entity = object})
		end

	
	if nosave || !object then return end
	SaveObjectToMap(classname,properties,pos,ang,object)
end






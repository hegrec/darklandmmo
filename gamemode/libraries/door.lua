door = {}


local doorExits = {}
function door.CreateExit(PropertiesTable,Pos,Ang,nosave)
	if !ents.FindByName("linkedDoor") then return end

	local doorExit = {}
	doorExit.Position = Pos
	doorExit.Angles = Ang
	doorExit.Properties = PropertiesTable
	
	table.insert(doorExits,doorExit)
	if !nosave then
		SaveDoorExits(doorExit)
	end
	return doorExit

end

function SaveDoorExits(dExit)

	SaveObjectToMap("~doorexit",dExit.Properties,dExit.Position,dExit.Angles,dExit)


end



local function LoadDoorExit(ID,Properties,Pos,Ang)
	local dExit = door.CreateExit(Properties,Pos,Ang,true)
end
AddMapLoadHook("~doorexit",LoadDoorExit)












local function UseDoor(pl,cmd,args)

	local door = ents.GetByIndex(args[1])
	if !ValidEntity(door) then return end
	local canUseDoor = hook.Call("CanPlayerUseDoor",GAMEMODE,pl,door)
	
	
	if (canUseDoor == false || !pl:CanReach(door)) && !pl.LastDoor then pl:ChatPrint("That door is locked!") return end
	
	
	local targetName = door:GetProperty("GoesTo")
	
	local targetArea
	local doorName = door:GetName()
	local doorArea = door:GetArea()
	
	if !targetName && pl:GetInstance() == 0 then filex.Append("brokenthings.txt",doorName.."\n") return end
	
	local targetDoor
	if pl.InstancedExit[door] then
		targetName = pl.InstancedExit[door]:GetName()
		targetDoor = pl.InstancedExit[door]
		targetArea = Areas[targetDoor:GetArea()]
	else
		targetDoor = ents.FindByName(targetName)[1]
		targetArea = Areas[door:GetTargetArea()]
	end	
	
	
	
	
	local inst = 0
	local exitPos = GetRandomDoorExit(targetName)
	
	if !exitPos || !targetArea || !targetName then return end
	
	
		
		umsg.Start("useDoor",pl)
		if targetArea.Type == AREA_PUBLIC then
			umsg.String("Explore")
		elseif targetArea.Type == AREA_TOWN then
			umsg.String("Town")
		elseif targetArea.Type == AREA_DUNGEON then
			umsg.String("Dungeon")
			inst = hook.Call("PlayerEnteredDungeon",GAMEMODE,pl,door,targetDoor,targetArea) -- let this decide if you are to go into a public or private dungeon
		end
		umsg.End()
	
		timer.Simple(0.7,function() 
			if !ValidEntity(pl) then return end	
			pl:SetPos(exitPos.Vector) 
			pl:SetAngles(exitPos.Angles)
				

				pl:SetInstance(inst,targetArea.Name)
		end)
	
end
concommand.Add("useDoor",UseDoor)




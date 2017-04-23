require("glon")

QUEST_HIDDEN = 0
QUEST_ACTIVE = 1
QUEST_PENDING = 2
QUEST_COMPLETED = 3
QUEST_COMPLETEDREWARDED = 4

local questHash = {}
local questList = {}

quest = {}
quest.__index = quest
function quest.new(name)
	local obj 			= {}
	obj.Name 			= name or "Unnamed Quest"
	obj.Parts			= {}
	obj.Status			= QUEST_HIDDEN
	obj.Rewarded		= false
	obj.ActiveDungeons  = {}
	setmetatable(obj,quest)
	obj.questID = table.insert(questList,obj)
	questHash[name] = obj.questID
	return obj
end
function quest.GetAll()
	return table.Copy(questList)
end
function quest:__tostring()

	return "Quest: "..self.Name

end
function quest.GetByName(name)
	return quest.Get(questHash[name])
end
function quest.Get(id)
	return questList[id]
end

	
function quest:SetName(name)
	self.Name = name
end
function quest:AddDungeon(dungeonName)

	self.ActiveDungeons[dungeonName] = true

end
--[[t should be a table structured as follows:
Kills or Items are optional but you should have at least one or the quest will be completed as soon as you get it pretty much.
local t = {
		Kills = {
			npc_zombie = 5,
			npc_ogre = 10
			}
		Items = {
			Wooden Stick = 4
			}
		}
	}



]]
function quest:AddPart(t)
	
	return table.insert(self.Parts,t)
end
function quest:GetName()
	return self.Name
end

--[[This table is too deep...

Player.Quests
	Test Quest
		Name - String
		Parts:
			1:
			Kills:
				npc_class - int
				npc_class - int
			Items:
				name - int
				
	LolQuest
		Name
		Parts
		
		
		
		
		
]]



function quest:GetPartsAmount()
	return table.Count(self.Parts)
end

function quest:GetPart(pl)

	if SERVER then
		return pl.Quests[self:GetName()].CurrentPart or 1
	else
		return Quests[self:GetName()].CurrentPart
	end
end


local function UpdateQuestKills(npc,pl,weapon)
	if !pl:IsPlayer() then return end
	
	--add kills to valid quests
	for _,quest in pairs(pl.Quests) do
		if quest.Status == QUEST_ACTIVE then
			local partID = quest.CurrentPart
			if quest.Parts[partID].Kills && quest.Parts[partID].Kills[npc:GetClassID()] && quest.Parts[partID].KillCount(pl,npc) then
				quest.Parts[partID].Kills[npc:GetClassID()] = quest.Parts[partID].Kills[npc:GetClassID()] + 1
				break
			end
		end
	end
	umsg.Start("NPCKill",pl)
		umsg.String(npc:GetClass())
	umsg.End()
	--save here?
end	
hook.Add("OnNPCKilled","PlayerQuestUpdateKills",UpdateQuestKills)
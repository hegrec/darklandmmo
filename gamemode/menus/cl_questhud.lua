local PANEL = {}

function PANEL:Init()
	self:SetSize(200,400)
	self:SetDeleteOnClose(false)
	self.List = vgui.Create("DPanelList",self)
	self.List:EnableVerticalScrollbar()
	self.List:StretchToParent(5,100,5,5)
	for i,v in pairs(Quests) do 
		self:NewQuest(i,v)
	end
	self:SetTitle("Quests")
end

function PANEL:NewQuest(name,tbl)

	local quest 		= quest.GetByName(name)
	local p 			= vgui.Create("DPanel")
	p:SetTall(18)
	p.Paint = function()
		draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(10,10,10,255))
		draw.SimpleText(name,"Default",5,7,Color(255,255,0,255),0,1)
		--draw.SimpleText(quest:GetPart(Me).."/"..quest:GetPartsAmount(),"Default",self:GetWide()-15,5,Color(255,0,0,255),2,1)
	end
	p.OnMousePressed = function() ShowQuestInfo(quest) end
	self.List:AddItem(p)
end
vgui.Register("QuestMenu",PANEL,"DFrame")

local questHUD;
function ShowQuests()

	if !questHUD then
		questHUD = vgui.Create("QuestMenu")
	end
	questHUD:SetVisible(true)
end
function HideQuests()
	questHUD:SetVisible(false)
end

hook.Add("QuestAdded","AddQuestToHUD",function()
	if !questHUD then return end
	--empty items
	questHUD.List:Clear()
	--add new ones
	for i,v in pairs(Quests) do
		
		questHUD:NewQuest(i,v)
	end
end)
local PANEL = {}

function PANEL:Init()
	self:SetSize(400,600)
	self:SetDeleteOnClose(false)
	self:SetTitle("Character Info")
	self.BaseInfo = vgui.Create("BaseInfo",self)
	self.BaseInfo:SetPos(0,20)
	self.BaseInfo:SetSize(self:GetWide(),110)
	
	self.laList = vgui.Create("DPanelList",self)
	self.laList:SetPos(20,130)
	self.laList:SetSize(self:GetWide()*0.5-40,160)
	self.laList:EnableVerticalScrollbar()
	self.laList:SetAutoSize(true)

	
	for i,v in pairs(myAttributes) do
	
		local p = vgui.Create("AttributePanel")
		if AttributePoints < 1 then p:Disable() else p:Enable() end
		p:SetAttribute(i)
		self.laList:AddItem(p)
	end
	
	self.raList = vgui.Create("DPanelList",self)
	self.raList:SetPos(self:GetWide()*0.5+20,130)
	self.raList:SetSize(self:GetWide()*0.5-40,self.laList:GetTall()-32)
	self.raList:EnableVerticalScrollbar()
	
	--[[for i,v in pairs(mySkills) do
	
		local p = vgui.Create("SkillPanel")
		p:SetTall(16)
		p:SetSkill(i)
		self.raList:AddItem(p)
	end]]
	
	self.plModel = vgui.Create("DModelPanel",self)
	self.plModel:SetPos(75,self:GetTall()-300)
	self.plModel:SetSize(250,250)
	self.plModel:SetModel(Me:GetModel())
	self.plModel.Entity:ResetSequence( -1 )
	self.plModel:SetCamPos( Vector( 80, 0, 50 ) )
	self.plModel.LayoutEntity = function(slf,Ent)  end
	
	self.list = vgui.Create("DPanelList",self.plModel)
	self.list:SetSize(32,self.plModel:GetTall())
	self.list.Paint = function() end
	self.list:SetSpacing(1)
	
	self.spotList = {}
	for i,v in pairs(EquipSpots) do
		self.spotList[i] = vgui.Create("Panel")
		self.spotList[i]:SetSize(32,32)
		self.spotList[i].Paint = function() draw.RoundedBox(0,0,0,self.spotList[i]:GetWide(),self.spotList[i]:GetTall(),Color(0,0,0,200)) end
		self.spotList[i]:SetToolTip(i)
		self.spotList[i].OnMouseReleased = function(slf,mc) if !dragIconInfo.Dragging || mc != MOUSE_LEFT then return end
			RunConsoleCommand("equipItem",i,dragIconInfo.item.ID)
		
		
		end
		self.list:AddItem(self.spotList[i])
	end
	
	self.lblAtts = vgui.Create("DLabel",self)
	self.lblAtts:SetPos(20,140+self.raList:GetTall())
	
	
	
	self:Center()
end
vgui.Register("CharacterInfo",PANEL,"DFrame")




local character;

function ShowCharacter()

	if !character then
		character = vgui.Create("CharacterInfo")
	end
	
	
	character.lblAtts:SetText("Attribute Points: "..AttributePoints)
	character.lblAtts:SizeToContents()

	
	character:SetVisible(true)
end
hook.Add("OnAttributePointsChanged",function()
	character.lblAtts:SetText("Attribute Points: "..AttributePoints)
end)

function HideCharacter()
	character:SetVisible(false)
end




local PANEL = {}


function PANEL:Paint()
	draw.SimpleText(CharacterName,"Default",20,30,Color(255,255,255,255),0)
	draw.SimpleText("Guild: "..GuildName,"Default",20,45,Color(255,255,255,255),0)
	
	surface.SetDrawColor(255,255,255,255)
	surface.DrawLine(self:GetWide()*0.5,50,self:GetWide()*0.5,50)
	
	draw.SimpleText(Class,"Default",self:GetWide()-20,30,Color(255,255,255,255),2)
	draw.SimpleText("Level: "..Level,"Default",self:GetWide()-20,45,Color(255,255,255,255),2)
	draw.SimpleText("Total Exp: "..XP,"Default",self:GetWide()-20,60,Color(255,255,255,255),2)
	draw.SimpleText("Skill Level: 69","Default",self:GetWide()-20,75,Color(255,255,255,255),2)
	
	draw.RoundedBox(2,50,self:GetTall()-20,self:GetWide()-100,12,Color(0,0,0,255))
	
	local gotten = XP-TotalXPAtLevel[Level-1]
	local needed = XPPerLevel(Level)
	
	draw.RoundedBox(2,52,self:GetTall()-18,gotten/needed*(self:GetWide()-96),8,Color(255,255,0,255))
end
vgui.Register("BaseInfo",PANEL,"Panel")



local PANEL = {}


function PANEL:Init()
	self:SetTall(32)
	self.btnAdd = vgui.Create("DSysButton",self)
	self.btnAdd:SetType("right")
	self.btnAdd:SetSize(20,20)
	self.btnAdd.DoClick = function() RunConsoleCommand("increaseAttribute",self.Attribute) end

end

function PANEL:PerformLayout()
	self.btnAdd:SetPos(self:GetWide()-self.btnAdd:GetWide())
	self.btnAdd:CenterVertical()
end

function PANEL:Enable()
	self.btnAdd:SetDisabled(false)
end
function PANEL:Disable()
	self.btnAdd:SetDisabled(true)
end

function PANEL:SetAttribute(str)

	self.Attribute = str
	self.lblName = Label(self.Attribute.."("..myAttributes[self.Attribute]..")",self)
	self.lblName:SetPos(self:GetTall()+2,0)
	self.lblName:SizeToContents()
	self.img = vgui.Create("DImage",self)
	
	self.img:SetImage(Attributes[self.Attribute].Icon)
	self.img:SetSize(self:GetTall(),self:GetTall())
end
vgui.Register("AttributePanel",PANEL,"Panel")


local PANEL = {}

function PANEL:SetSkill(str)

	self.Skill = str
	self.lblName = Label(self.Skill.."("..mySkills[self.Skill].Level..")",self)
	self.lblName:SetPos(self:GetTall()+2,0)
	self.lblName:SizeToContents()
	self.img = vgui.Create("DImage",self)
	
	self.img:SetImage(SkillList[self.Skill].Icon)
	self.img:SetSize(self:GetTall(),self:GetTall())

end


vgui.Register("SkillPanel",PANEL,"Panel")


local function AttributeLeveled(skill)
	if !ValidPanel(character) then return end
	character.laList:Clear()
	for i,v in pairs(myAttributes) do
	
		local p = vgui.Create("AttributePanel")
		if AttributePoints < 1 then p:Disable() else p:Enable() end
		p:SetAttribute(i)
		character.laList:AddItem(p)
	end

	
end
hook.Add("AttributesChanged","updateCharSheetAtts",AttributeLeveled)

local function SkillLeveled(skill)
	if !ValidPanel(character) then return end
	character.raList:Clear()
	for i,v in pairs(mySkills) do
	
		local p = vgui.Create("SkillPanel")
		p:SetTall(16)
		p:SetSkill(i)
		character.raList:AddItem(p)
	end
	
	
end
hook.Add("SkillsChanged","updateCharSheetSkills",SkillLeveled)

local function MainLevelUp()
	ShowCharacter()
	for i,v in pairs(character.laList:GetItems()) do
		if AttributePoints < 1 then
			v:Disable()
		else
			v:Enable()
		end
	end
	

end
hook.Add("OnLevelUp","showCharMenu",MainLevelUp)
local PANEL = {}

function PANEL:Init()
	self:SetSize(500,400)
	self:SetDeleteOnClose(false)
	self.ListTypes = {}
	for i,v in pairs(SkillTypes) do
		self.ListTypes[v] = vgui.Create("DPanelList",self)
		self.ListTypes[v]:EnableVerticalScrollbar()
		self.ListTypes[v]:StretchToParent(5,25,self:GetWide()-250,50)
		self.ListTypes[v]:SetVisible(false)
		self.ListTypes[v].Type = v
	end
	
	self.allList = vgui.Create("DPanelList",self)
	self.allList:EnableVerticalScrollbar()
	self.allList:StretchToParent(5,25,self:GetWide()-250,50)
	self.activeList = self.allList
	for i,v in pairs(mySkills) do 
		self:NewSkill(i)
	end
	self:SetTitle("Skill Book")
	
	self.buttList = vgui.Create("DPanelList",self)
	self.buttList:StretchToParent(5,self:GetTall()-45)
	self.buttList:SetTall(32)
	self.buttList:SetWide(32*(table.Count(self.ListTypes)+1))
	self.buttList:EnableHorizontal(true)
	
	local butt = vgui.Create("DButton")
	butt:SetSize(32,32)
	butt:SetText("")
	butt:SetToolTip("All")
	butt.DoClick = function()
		for _,q in pairs(self.ListTypes) do
				q:SetVisible(false)
		end
		self.allList:SetVisible(true)
		self.activeList = self.allList
		self.allList:Clear()
		
		for i,v in pairs(mySkills) do
				self:NewSkill(i)
		end
		
		
		
	end
	self.buttList:AddItem(butt)	
	
	
	for i,v in pairs(self.ListTypes) do
		local butt = vgui.Create("DButton")
		butt:SetSize(32,32)
		butt:SetText("")
		butt:SetToolTip(i)
		butt.DoClick = function()
			for _,q in pairs(self.ListTypes) do
				if _ != i then
					q:SetVisible(false)
				else
					q:SetVisible(true)
					self.activeList = q
					q:Clear()
					for i,v in pairs(mySkills) do
						if skills.Get(i).Type == self.activeList.Type then
							self:NewSkill(i)
						end
					end
				end
			end
			self.allList:SetVisible(false)
			
			
		end
		self.buttList:AddItem(butt)		
	end
end



function PANEL:NewSkill(skillName)
	local t = skills.Get(skillName)
	local p = vgui.Create("DPanel")
	p:SetTall(42)
	p.Paint = function()
		local bool = true
		for i,v in pairs(skillColorUse) do
			local ans = v(skillName)
			if !ans then
				bool = false
				break
			end
		end
		if bool then
			draw.RoundedBox(6,0,0,p:GetWide(),p:GetTall(),Color(0,200,0,200))
		else
			draw.RoundedBox(6,0,0,p:GetWide(),p:GetTall(),Color(200,0,0,200))
		end
	end
	local icon = vgui.Create("DImage",p)
	if t.Icon then
		icon:SetImage(t.Icon)
	end
	icon:SetPos(5,5)
	icon:SetSize(32,32)
		
	local lblName = Label(skillName,p)
	lblName:SizeToContents()
	lblName:SetPos(42,p:GetTall()*0.5-(lblName:GetTall()*0.5))
	
	p.OnMousePressed = function()
		
		dragIconInfo.item = skillName
		dragIconInfo.texID = surface.GetTextureID(t.Icon)
		dragIconInfo.lastPan = self
	end
	p.OnCursorExited = function()
		if !input.IsMouseDown(MOUSE_LEFT) || dragIconInfo.lastPan != self then return end
		dragIconInfo.Dragging = true
	end
	self.activeList:AddItem(p)
end

function PANEL:ClickedItem(name)

	local t = items.Get(name)
	
	if !self.mdlPan then
		self.mdlPan = vgui.Create("DImage",self)
		self.mdlPan:SetSize(64,64)
		self.mdlPan:SetPos(5,25)
	end
	self.mdlPan:SetImage(t.Icon)
end
vgui.Register("SkillBook",PANEL,"DFrame")

local skillBook;
function ShowSkillBook()

	if !skillBook then
		skillBook = vgui.Create("SkillBook")
	end
	skillBook:SetVisible(true)
end
function HideSkillBook()
	skillBook:SetVisible(false)
end

hook.Add("SkillAdded","RemakeSkillBook",function()
	if !skillBook then return end
	--empty items
	skillBook.activeList:Clear()
	--add new ones
	for i,v in pairs(mySkills) do
		
		if skills.Get(i).Type == skillBook.activeList.Type || skillBook.activeList == skillBook.allList then
			skillBook:NewSkill(i)
		end
	end
end)
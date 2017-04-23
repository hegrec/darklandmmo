local PANEL = {}
local oldClass
local tier
function PANEL:Init()
	self:SetSize(400,300)
	self:Center()
	self.SelectedClass = "None"
	
	
	if tier == 2 then
		local btnWide = 70
		local list = vgui.Create("DPanelList",self)
		list:SetWide(btnWide)
		list:SetTall(20*table.Count(ClassTrees[ClassTree][Class].LowClasses))
		list:SetPos(self:GetWide()-110,30)
		
		local selectButton = vgui.Create("DButton",self)
		selectButton:SetText("Choose Class")
		selectButton:SetSize(70,20)
		selectButton:SetPos(self:GetWide()-110,self:GetTall()-30)
		selectButton:SetDisabled(true)
		selectButton.DoClick = function() if !ClassTrees[ClassTree][self.SelectedClass] then return end RunConsoleCommand("chooseSubClass",self.SelectedClass) self:Remove() end
		
		
		
		for i,v in pairs(ClassTrees[ClassTree][Class].LowClasses) do
			local btn = vgui.Create("DButton")
			btn:SetSize(70,20)
			btn:SetText(v)
			btn.DoClick = function() self.SelectedClass = v selectButton:SetDisabled(false) end
			list:AddItem(btn)
		end
		
	end
end

local id = surface.GetTextureID("darkland/rpg/hud/blank_parchment")
surface.CreateFont("Nyala", 36, 1200, true, false, "ClassMenuHeading") 
surface.CreateFont("Nyala", 24, 1200, true, false, "ClassMenuSub")
function PANEL:Paint()
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(id)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
	draw.SimpleText("Advance Class!","ClassMenuHeading",35,30,Color(0,0,0,255),0,1)
	local txt = util.WordWrap(ClassTrees[ClassTree][oldClass].EvolveText,"ChatBoxTextFont",250)
	draw.DrawText(txt,"ChatBoxTextFont",35,50,Color(0,0,0,255),0)
	surface.SetFont("ChatBoxTextFont")
	local w,h = surface.GetTextSize(txt)
	
	local t = ClassTrees[ClassTree][self.SelectedClass]
	if t then
		draw.SimpleTextOutlined(self.SelectedClass,"ClassMenuSub",35,60+h,Color(226,204,55,255),0,1,1,Color(156,139,57,255))

		local txt = util.WordWrap(t.Description,"ChatBoxTextFont",275)
		draw.DrawText(txt,"ChatBoxTextFont",35,70+h,Color(0,0,0,255),0)
	end
		

end
vgui.Register("ClassLevelMenu",PANEL,"DPanel")

local classmenu

hook.Add("ChooseSubClass","showClassMenu",function(oc,lvl)
	oldClass = oc
	tier = lvl
	if !classmenu then
		classmenu = vgui.Create("ClassLevelMenu")
	end
	classmenu:SetVisible(true)
	
end)
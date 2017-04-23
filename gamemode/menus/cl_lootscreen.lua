local localizedInv
local PANEL = {}

function PANEL:Init()
	self:SetSize(300,500)
	self:SetDeleteOnClose(false)
	self.List = vgui.Create("DPanelList",self)
	self.List:EnableVerticalScrollbar()
	self.List:StretchToParent(5,100,5,5)
	self:Center()
end
function PANEL:Close()
	RunConsoleCommand("stopLooting")
	self:SetVisible(false)
end

function PANEL:NewItem(item)

	local p 			= vgui.Create("DPanel")
	p.Item = item
	p:SetTall(52)
	local t = items.Get(item.BaseType)
	if t.Icon then
		self.texID = surface.GetTextureID(t.Icon)
	end
	
	
	p.Paint = function()

		draw.RoundedBox(2,0,0,self:GetWide(),self:GetTall(),Color(10,10,10,255))

		
		
		if t.Icon then
			surface.SetDrawColor(255,255,255,255)
			surface.SetTexture(self.texID)
			surface.DrawTexturedRect(10,10,p:GetTall()-20,p:GetTall()-20)
		end
		
		draw.SimpleText(item.BaseType,"Default",p:GetTall(),5,Color(255,255,0,255),0,1)
	end
	p.OnMousePressed = function() RunConsoleCommand("lootItem",item.ID) end
	self.List:AddItem(p)
end
vgui.Register("LootGUI",PANEL,"DFrame")

local lootmenu;



hook.Add("StartLootBody","showLootingMenu",function(inv)
	if !lootmenu then 
		lootmenu = vgui.Create("LootGUI")
	else
		lootmenu.List:Clear()
	end
	localizedInv = inv
	--add new ones
	for i,v in pairs(localizedInv) do
		lootmenu:NewItem(v)
	end
	lootmenu:SetVisible(true)
	lootmenu:SetTitle("Looting Corpse")
end)

hook.Add("OnLootedItem","LootedFromNPC",function(id)
	

	for i,v in pairs(lootmenu.List:GetItems()) do
		if v.Item.ID == id then lootmenu.List:RemoveItem(v) break end
	end
	
	localizedInv[id] = nil

	
end)
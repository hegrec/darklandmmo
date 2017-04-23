local PANEL = {}

function PANEL:Init()
	self:SetSize(200,400)
	self:SetDeleteOnClose(false)
	
	
	local buttonList = vgui.Create("DPanelList",self)
	buttonList:SetPos(5,25)
	buttonList.Paint = function() end
	buttonList:EnableHorizontal(true)
	buttonList:SetSize(self:GetWide()-10,55)
	buttonList:SetSpacing(0)
	buttonList:SetPadding(0)
	
	
	
	local itemTypes = {}
	for i,v in pairs(items.GetAll()) do
		itemTypes[v.Category] = 1
	end
	local btnWide = buttonList:GetWide()/(table.Count(itemTypes)-2)
		local b = vgui.Create("DButton")
		b:SetText("All")
		b.DoClick = function()
			for q,w in pairs(self.Lists) do
				
				if q == "All" then
					w:SetVisible(true)
				else
					w:SetVisible(false)
				end
			end
		end
		b:SetSize(btnWide,25)
		buttonList:AddItem(b)	

	for i,v in pairs(itemTypes) do
		local b = vgui.Create("DButton")
		b:SetText(i)
		b.DoClick = function()
			for q,w in pairs(self.Lists) do
				
				if q == i then
					w:SetVisible(true)
				else
					w:SetVisible(false)
				end
			end
		end
		b:SetSize(btnWide,25)
		buttonList:AddItem(b)
	end
	
	self.Lists = {}
	self.ActiveList = "All"
	
	self.Lists["All"] = vgui.Create("DPanelList",self)
	self.Lists["All"]:EnableVerticalScrollbar()
	self.Lists["All"]:StretchToParent(5,75,5,5)

	for i,v in pairs(itemTypes) do
		self.Lists[i] = vgui.Create("DPanelList",self)
		self.Lists[i]:EnableVerticalScrollbar()
		self.Lists[i]:StretchToParent(5,75,5,5)
		self.Lists[i]:SetVisible(false)
	end

	self.Lists["Misc"] = vgui.Create("DPanelList",self)
	self.Lists["Misc"]:EnableVerticalScrollbar()
	self.Lists["Misc"]:StretchToParent(5,75,5,5)
	self.Lists["Misc"]:SetVisible(false)
	
	
	for i,v in pairs(Inventory) do 
		self:NewItem(v)
	end
	self:SetTitle("Items")
end

function PANEL:NewItem(item)
	local iType = items.Get(item.BaseType).Category
	local p = vgui.Create("ItemPanel")
	p:SetItem(item)
	self.Lists[iType]:AddItem(p)
	
	p = vgui.Create("ItemPanel")
	p:SetItem(item)
	self.Lists["All"]:AddItem(p)
end
vgui.Register("Inventory",PANEL,"DFrame")

local inventory;
function ShowInventory()

	if !inventory then
		inventory = vgui.Create("Inventory")
	end
	inventory:SetVisible(true)
end
function HideInventory()
	inventory:SetVisible(false)
end

hook.Add("RefreshInventory","RemakeInventory",function()
	if !inventory then return end
	--empty items
	for i,v in pairs(inventory.Lists) do
		v:Clear()
	end
	--add new ones
	for i,v in pairs(Inventory) do
		inventory:NewItem(v)
	end
end)

local PANEL = {}
function PANEL:Init()
	self:SetTall(42)
end
function PANEL:SetItem(item)
	local t = items.Get(item.BaseType)
	self.item = item
	local icon = vgui.Create("DPanel",self)
	if t.Icon then
		local id = surface.GetTextureID(t.Icon)
		icon.Paint = function(s)
			if id == nil then id = surface.GetTextureID(t.Icon) end
			surface.SetDrawColor(255,255,255,255)
			surface.SetTexture(id)
			surface.DrawTexturedRect(0,0,s:GetWide(),s:GetTall())
		end
	end
	icon:SetPos(5,5)
	icon:SetSize(32,32)
		
	local lblName = Label(item.BaseType,self)
	lblName:SizeToContents()
	lblName:SetPos(42,self:GetTall()*0.5-(lblName:GetTall()*0.5))
end
function PANEL:OnMousePressed(mc)
	local t = items.Get(self.item.BaseType)

	if mc == MOUSE_RIGHT then
		hook.Call("RightClickedIcon",GAMEMODE,self)
	elseif mc == MOUSE_LEFT then
		dragIconInfo.item = self.item
		dragIconInfo.texID = surface.GetTextureID(t.Icon)
		dragIconInfo.lastPan = self
	end
	
end
function PANEL:OnCursorExited()
	if !input.IsMouseDown(MOUSE_LEFT) || dragIconInfo.lastPan != self then return end
	dragIconInfo.Dragging = true
end
vgui.Register("ItemPanel",PANEL,"DPanel")
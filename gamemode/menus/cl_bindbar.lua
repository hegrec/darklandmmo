
local PANEL = {}
function PANEL:Init()
	self:SetSize(30,30)
	self.slot = 0
end
function PANEL:SetItem(item)
	if !item then return end
	self.itemRef = item
	if type(item) == "string" then
		self.itemTab = skills.Get(self.itemRef)
		self.IsSkill = true
	else
		self.itemTab = items.Get(self.itemRef.BaseType)
	end
	
	if self.itemTab && self.itemTab.NoBar then self.itemRef = nil return end
	


	SaveBindSettings()

		
end
function PANEL:Paint()

	
	if self.itemRef && self.itemTab then
		
		if self.itemTab.Icon then
			local texID = surface.GetTextureID(self.itemTab.Icon)
			draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
			surface.SetTexture(texID)
			surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
		else
			draw.RoundedBox(0,0,self:GetTall()-12,12,12,Color(255,255,255,200))
		end
	

		if skillCharges[self.itemRef] && skillCharges[self.itemRef] > RealTime() then
			local nextUse = self.itemTab.UseDelay or self.itemTab.Length
			local start = (RealTime()-(skillCharges[self.itemRef]-nextUse))/nextUse
			draw.RoundedBox(0,0,start*self:GetTall(),self:GetWide(),self:GetTall(),Color(255,255,255,100)) --really this just slides off the bottom
		end
	
		if self.IsSkill then
			local bool = true
			for i,v in pairs(skillColorUse) do
				local ans = v(self.itemRef)
				if !ans then
					bool = false
					break
				end
			end
			if !bool then
				draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(200,0,0,200))
			end
		end
	end


	draw.RoundedBox(0,0,self:GetTall()-12,12,12,Color(255,255,255,200))
	draw.SimpleText(self.slot or 0,"DefaultSmall",6,self:GetTall()-6,Color(0,0,0,255),1,1)
	

end

PANEL.downKeys = {}
function PANEL:Think()

		if input.IsKeyDown(self.slot+1) && !self.downKeys[self.slot+1] then
			self.downKeys[self.slot+1] = true
			self:OnUsed()
		elseif !input.IsKeyDown(self.slot+1) then
			self.downKeys[self.slot+1] = false

		end	
	
end
function PANEL:OnUsed()
	if !self.itemRef then return end
	if self.IsSkill then
		if self.itemTab.Mandala then --target skill
			ActivateSkill(self.itemRef)
		else
			RunConsoleCommand("useSkill",self.itemRef) --self skill
		end
	else
		RunConsoleCommand("useItem",self.itemRef.ID)
	end

end



function PANEL:MouseEntered()
	NewContainer = self
end

function PANEL:MouseExited()
	if NewContainer == self then NewContainer = NULL end
end
function PANEL:OnMouseReleased(mc)
	if !dragIconInfo.Dragging || mc != MOUSE_LEFT then return end
	
	self:SetItem(dragIconInfo.item)
end

function PANEL:OnMousePressed(mc)
	if !self.itemRef then return end
	
	if mc == MOUSE_RIGHT then
		local menu = DermaMenu()
		menu:AddOption("Unbind",function() self.itemRef = nil self.itemID = nil self.IsSkill = nil SaveBindSettings() end)
		menu:Open()
	end
end
vgui.Register("BindSlot",PANEL,"DPanel")



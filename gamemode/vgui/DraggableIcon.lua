

local PANEL = {}
function PANEL:Init()
	self:SetSize(32,32)
end





function PANEL:SetItem(item)
	self.item = item
	local t = items.Get(self.item.BaseType)
	if t && t.Icon then
		if !self.texID then
			self.texID = surface.GetTextureID(t.Icon)
		end
	end
end

function PANEL:Paint()
	
	if self.texID then
		draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
		surface.SetTexture(self.texID)
		surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
	end
end

function PANEL:OnMousePressed(mc)

	if mc == MOUSE_LEFT then
		dragIconInfo.item = self.item
		dragIconInfo.texID = self.texID
		dragIconInfo.lastPan = self
	elseif mc == MOUSE_RIGHT then
		hook.Call("RightClickedIcon",GAMEMODE,self)
	end
		
	
	
end

function PANEL:OnCursorExited()
	
	if !input.IsMouseDown(MOUSE_LEFT) || dragIconInfo.lastPan != self then return end
	dragIconInfo.Dragging = true
end

vgui.Register("DraggableIcon",PANEL,"DPanel")


local function drawDragIcon()

	if dragIconInfo.Dragging then 
	
			surface.SetDrawColor(255,255,255,200)
			surface.SetTexture(dragIconInfo.texID)
			surface.DrawTexturedRect(gui.MouseX(),gui.MouseY(),32,32)
			
	end

end
hook.Add("PostRenderVGUI","drawDragIcon",drawDragIcon)
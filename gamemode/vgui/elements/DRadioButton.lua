local PANEL = {}

AccessorFunc( PANEL, "m_bChecked", 		"Checked", 		FORCE_BOOL )

Derma_Install_Convar_Functions(PANEL)

/*---------------------------------------------------------
	
---------------------------------------------------------*/
function PANEL:Init()
	self:SetSize(13, 13)
	self:SetType("none")
end

/*---------------------------------------------------------
   Name: SetValue
---------------------------------------------------------*/
function PANEL:SetValue( val )
	val = tobool(val)

	self:SetChecked( val )

	self.m_bValue = val
	
	self:OnChange( val )
	
	if(val)then val = "1" self.tex = "darkland/rpg/hud/charcreate/radiobuttonsingle16x16" else val = "0" self.tex = nil end	
	self:ConVarChanged( val )
end

function PANEL:SetTexture(name)
	self.tex = name
end

function PANEL:DoClick()
	self:Toggle()
end

function PANEL:Toggle()
	if(self:GetChecked() == nil || !self:GetChecked())then
		self:SetValue(true)
	else
		self:SetValue(false)
	end
end

function PANEL:OnChange(bVal)
	// For override
end

function PANEL:Think()
	self:ConVarStringThink()
end

function PANEL:Paint()
	if(self.tex)then
		surface.SetTexture(surface.GetTextureID(self.tex))
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(-2,-2,16,16)
	end
end
derma.DefineControl("DRadioButton", "Simple Checkbox", PANEL, "DSysButton")
local localizedInv
local PANEL = {}

function PANEL:Init()
	self:SetSize(300,500)
	self:SetDeleteOnClose(false)
	self.List = vgui.Create("DPanelList",self)
	self.List:EnableVerticalScrollbar()
	self.List:StretchToParent(5,100,5,5)
	self:MakePopup()
	self:Center()
end

function PANEL:NewItem(storename,tbl)

	local p 			= vgui.Create("DPanel")
	
	
	p.Amt = tbl[1]
	p.Price = tbl[2]
	
	p.Item = tbl[3]
	p:SetTall(52)

	local name = p.Item.BaseType
	local t = items.Get(name)
	p.Paint = function()


		draw.RoundedBox(2,0,0,self:GetWide(),self:GetTall(),Color(10,10,10,255))

		
		
		if t && t.Icon then
			surface.SetDrawColor(255,255,255,255)
			surface.SetTexture(surface.GetTextureID(t.Icon))
			surface.DrawTexturedRect(10,10,p:GetTall()-20,p:GetTall()-20)
		end
		
		draw.SimpleText(name,"Default",p:GetTall(),5,Color(255,255,0,255),0,1)
		draw.SimpleText("$"..p.Price,"Default",p:GetWide()-15,5,Color(255,0,0,255),2,1)
		draw.SimpleText("Amount Left - "..p.Amt,"Default",p:GetWide()-15,p:GetTall()-15,Color(255,0,0,255),2,1)
	end
	p.OnMousePressed = function() RunConsoleCommand("buyNPC",p.Item.ID,storename) end
	self.List:AddItem(p)
end
local trademenu
function PANEL:Close()
	RunConsoleCommand("stopTradingNPC")
	self:Remove()
	trademenu = nil
end

vgui.Register("NPCTrade",PANEL,"DFrame")





hook.Add("OnTradeNPC","NPCTrade",function(name,inv)
	if !trademenu then 
		trademenu = vgui.Create("NPCTrade")
	else
		trademenu.List:Clear()
	end
	localizedInv = inv
	--add new ones
	for i,v in pairs(localizedInv) do
		trademenu:NewItem(name,v)
	end
	trademenu:SetVisible(true)
	trademenu:SetTitle(name)
end)

hook.Add("OnBoughtFromNPC","BoughtFromNPC",function(itemID)
	localizedInv[itemID][1] = localizedInv[itemID][1] - 1


		for i,v in pairs(trademenu.List:GetItems()) do
			if v.Item.ID == itemID then
				if localizedInv[itemID][1] < 1 then
					trademenu.List:RemoveItem(v)
				else
					v.Amt = localizedInv[itemID][1]
				end
			 break
			end
		end
	
end)



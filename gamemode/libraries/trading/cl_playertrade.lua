local tradingEntity = NULL
local tradeMenu

local PANEL = {}

function PANEL:Init()
	self:SetSize(600,300)
	self:Center()

	
	self.MyList = vgui.Create("DPanelList",self)
	self.MyList:SetPos(50,40)
	self.MyList:SetSize(190,190)
	self.MyList:EnableHorizontal(true)
	self.MyList.OnMouseReleased = function(slf,mc) 
	
		if !dragIconInfo.Dragging || mc != MOUSE_LEFT then return end
			RunConsoleCommand("addTradeItem",dragIconInfo.item.ID)
		
		
		end
	
	self.MyCash = vgui.Create("DTextEntry",self)
	self.MyCash:SetPos(100,235)
	self.MyCash:SetEditable(false)
	self.MyCash:SetWide(140)
	
	self.MyCashButton = vgui.Create("DButton",self)
	self.MyCashButton:SetSize(25,25)
	self.MyCashButton:SetPos(65,230)
	self.MyCashButton.Paint = function() draw.RoundedBox(0,0,0,self.MyCashButton:GetWide(),self.MyCashButton:GetTall(),Color(0,0,0,255)) end
	self.MyCashButton:SetText("+")
	self.MyCashButton.DoClick = function() 
		Derma_StringRequest( "Amount?", 
					"How much money do you want to trade?", 
					"50", 
					function( strTextOut ) RunConsoleCommand("tradeSetMoney",tonumber(strTextOut)) end,
					function( strTextOut ) end,
					"Okey Dokey", 
					"Cancel" )
	
	
	end
	
	
	

	
	self.HisList = vgui.Create("DPanelList",self)
	self.HisList:SetPos(360,40)
	self.HisList:SetSize(190,190)
	self.HisList:EnableHorizontal(true)
	
	self.HisCash = vgui.Create("DTextEntry",self)
	self.HisCash:SetPos(365,235)
	self.HisCash:SetEditable(false)
	self.HisCash:SetWide(160)
	
	
	
	
	self.Trade = vgui.Create("DButton",self)
	self.Trade:SetWide(60)
	self.Trade:SetText("Trade")
	self.Trade:SetPos(self:GetWide()*0.5-30,65)
	self.Trade.DoClick = function() RunConsoleCommand("acceptTrade") end
	
	self.Cancel = vgui.Create("DButton",self)
	self.Cancel:SetWide(80)
	self.Cancel:SetText("Cancel")
	self.Cancel:SetPos(self:GetWide()*0.5-40,180)
	self.Cancel.DoClick = function() RunConsoleCommand("cancelTrade") self:Remove() tradingEntity = NULL end
	
	self:MakePopup()
	
end

local id = surface.GetTextureID("darkland/rpg/hud/trademenu")
function PANEL:Paint()
	surface.SetTexture(id)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
end
vgui.Register("PlayerTrade",PANEL,"DPanel")

local function tradeAsk( um )
	tradingEntity = um:ReadEntity()

	local tradeRequest = vgui.Create("TradeRequest")
	tradeRequest:SetPos(ScrW()-205,ScrH()-300)
	gui.EnableScreenClicker(true)
end
usermessage.Hook("tradeAsk",tradeAsk)

local function setTradeEntity( um )
	tradingEntity = um:ReadEntity()
end
usermessage.Hook("setTradeEnt",setTradeEntity)

local function beginTrade()

	if tradeMenu then tradeMenu:Remove() end
	tradeMenu = vgui.Create("PlayerTrade")

end
usermessage.Hook("beginTrade",beginTrade)

local function IAddedItem(um)

	local item = items.BufferGrab(um:ReadLong())
	
	local p = vgui.Create("DPanel")
	p.ItemType = item
	p:SetSize(32,32)
	local tbl = items.Get(item.BaseType)
	
	local id = surface.GetTextureID(tbl.Icon)
	p.Paint = function() 
		surface.SetDrawColor(255,255,255,255)
		surface.SetTexture(id) 
		surface.DrawTexturedRect(0,0,p:GetWide(),p:GetWide()) 
	end
	p:SetToolTip(i)
	p.OnMousePressed = function(s,mc) 
		if mc == MOUSE_RIGHT then 	
			local menu = DermaMenu()
			menu:AddOption("Remove From Trade",function() RunConsoleCommand("removeTradeItem",item.ID) end)
			menu:Open()
		end
	end
	tradeMenu.MyList:AddItem(p)
end
usermessage.Hook("IAddedItem",IAddedItem)

local function HeAddedItem(um)

	local item = items.BufferGrab(um:ReadLong())
	
	
	local p = vgui.Create("DPanel")
	p.Item = item
	p:SetSize(32,32)
	local tbl = items.Get(item.BaseType)
	local id = surface.GetTextureID(tbl.Icon)
	p.Paint = function() 
		surface.SetDrawColor(255,255,255,255)
		surface.SetTexture(id) 
		surface.DrawTexturedRect(0,0,p:GetWide(),p:GetWide()) 
	end
	p:SetToolTip(i)
	tradeMenu.HisList:AddItem(p)
end
usermessage.Hook("HeAddedItem",HeAddedItem)

local function IRemovedItem(um)

	local itemID = um:ReadLong()
	
	for i,v in pairs(tradeMenu.MyList:GetItems()) do
		if v.ID == itemID then
			tradeMenu.MyList:RemoveItem(v)
			break
		end
	end	
end
usermessage.Hook("IRemovedItem",IRemovedItem)

local function HeRemovedItem(um)

	local itemID = um:ReadLong()
	
	for i,v in pairs(tradeMenu.HisList:GetItems()) do
		if v.ID == itemID then
			tradeMenu.HisList:RemoveItem(v)
			break
		end
	end	
end
usermessage.Hook("HeRemovedItem",HeRemovedItem)


local function ISetMoney(um)
	local amt = um:ReadLong()
	tradeMenu.MyCash:SetValue(amt)
end
usermessage.Hook("ISetMoney",ISetMoney)

local function HeSetMoney(um)
	local amt = um:ReadLong()
	tradeMenu.HisCash:SetValue(amt)
end
usermessage.Hook("HeSetMoney",HeSetMoney)


local function PlayerAcceptedTrade()

	tradeMenu.acceptedLbl = Label(tradingEntity:Name().." has accepted this trade",tradeMenu)
	tradeMenu.acceptedLbl:SetFont("ScoreboardSub")
	tradeMenu.acceptedLbl:SetColor(Color(200,0,0,255))
	tradeMenu.acceptedLbl:SizeToContents()
	tradeMenu.acceptedLbl:SetPos(tradeMenu:GetWide()-tradeMenu.acceptedLbl:GetWide()-50,tradeMenu:GetTall()-tradeMenu.acceptedLbl:GetTall()-20)
	
end
usermessage.Hook("plyAcceptedTrade",PlayerAcceptedTrade)

local PANEL = {}

function PANEL:Init()
	self:SetSize(200,100)
	self:SetTitle("")
	self:ShowCloseButton(false)
	self.lbl = Label(tradingEntity:Name().." would like to trade",self)
	self.lbl:SetPos(25,35)
	self.lbl:SetWide(150)
	self.lbl:SetContentAlignment(5)

	
	self.no = vgui.Create("DButton",self)
	self.no:SetPos(8,60)
	self.no:SetText("")
	self.no:SetSize(85,30)
	self.no.DoClick = function() RunConsoleCommand("tradeAsk","no") self:Remove() end
	self.no.Paint = function() end
	
	self.yes = vgui.Create("DButton",self)
	self.yes:SetPos(95,60)
	self.yes:SetText("")
	self.yes:SetSize(85,30)
	self.yes.DoClick = function() RunConsoleCommand("tradeAsk","yes") self:Remove() end
	self.yes.Paint = function() end
end
local id = surface.GetTextureID("darkland/rpg/hud/tradeconf")
function PANEL:Paint()
	surface.SetTexture(id)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
end
vgui.Register("TradeRequest",PANEL,"DFrame")


function IsTrading()

	return ValidEntity(tradingEntity)

end


local function canceledTrade()

	tradeMenu:Remove()
	tradingEntity = NULL
	
end
usermessage.Hook("canceledTrade",canceledTrade)
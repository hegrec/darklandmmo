
local PANEL = {}
local askingPlayer = NULL
local pID = 0
function PANEL:Init()
	self:SetSize(150,75)
	self:SetTitle("Party Request")
	self:ShowCloseButton(false)
	self.lbl = Label(askingPlayer:Name().." invites you to his/her party",self)
	self.lbl:SetPos(5,30)
	self.lbl:SizeToContents()
	self.yes = vgui.Create("DButton",self)
	self.yes:SetPos(5,self:GetTall()-25)
	self.yes:SetText("Accept")
	self.yes:SetWide(70)
	local id = pID
	self.yes.DoClick = function() RunConsoleCommand("partyAccept",id) self:Remove() end
	
	self.no = vgui.Create("DButton",self)
	self.no:SetPos(self:GetWide()*0.5,self:GetTall()-25)
	self.no:SetText("Decline")
	self.no:SetWide(70)
	self.no.DoClick = function() RunConsoleCommand("partyDecline",id) self:Remove() end
	self:SetWide(self.lbl:GetWide()+10)
end

vgui.Register("PartyRequest",PANEL,"DFrame")


local partyRequest
usermessage.Hook("partyAsk",function(um)
	askingPlayer = um:ReadEntity()
	pID = um:ReadLong()
	if !ValidEntity(askingPlayer) then return end
	partyRequest = vgui.Create("PartyRequest")	
	
	partyRequest:SetPos(ScrW()-205,ScrH()-300)
	gui.EnableScreenClicker(true)
end)

local partyList

local PANEL = {}
function PANEL:Init()

	self:SetAutoSize(true)
	self:SetWide(150)
	for i,v in pairs(GetPartyMembers(Me:GetParty())) do
		self:AddPlayer(v)
	end

end
function PANEL:Paint()

end

function PANEL:AddPlayer(pl)
	
	local pnl = vgui.Create("DPanel")
	pnl.Player = pl
	pnl.Paint = function()
		local leader = pl:IsPartyLeader() 
		draw.SimpleText(pl:CharacterName(),"ScoreboardSub",50,5,Color(255,255,255,255)) 
		if leader then 
			draw.SimpleText("Leader","Default",50,25,Color(255,255,255,255)) 
		end
		
		draw.RoundedBox(2,5,50,pl:Health()/pl:GetMaxHealth()*140,8,Color(200,0,0,255))
		
		draw.RoundedBox(2,5,60,pl:GetMana()/pl:GetMaxMana()*140,8,Color(50,200,50,255))
		
		draw.RoundedBox(2,5,70,pl:GetMana()/pl:GetMaxMana()*140,8,Color(50,50,255,255))
	end
	pnl:SetSize(150,96)
	pnl.model = vgui.Create("DModelPanel",pnl)
	pnl.model.LayoutEntity = function(s,ent) end
	pnl.model:SetSize(45,45)
	pnl.model:SetModel(pl:GetModel())
	local BoneIndx = pnl.model.Entity:LookupBone("ValveBiped.Bip01_Head1")
    local BonePos , BoneAng = pnl.model.Entity:GetBonePosition( BoneIndx )
	pnl.model:SetLookAt(BonePos)
	pnl.model:SetCamPos(Vector(BonePos.x+15,BonePos.y-5,BonePos.z+2))
	self:AddItem(pnl)
end

function PANEL:Think()

	if !Me:HasParty() then self:Remove() end
	for i,v in pairs(self:GetItems()) do
		if !ValidEntity(v.Player) || v.Player:GetParty() != Me:GetParty() then
			self:RemoveItem(v)
		end
	end

end
vgui.Register("PartyList",PANEL,"DPanelList")

local function partyRefresh()
	local t = {}
	for i,v in pairs(partyList:GetItems()) do
		if v.Player then
			t[v.Player] = 1
		end
	end
	
	for i,v in pairs(GetPartyMembers(Me:GetParty())) do --add your new party members to the party list
		if !t[v] then
			partyList:AddPlayer(v)
		end
	end
	if Me:GetParty() == 0 then partyList:Remove() return end
	timer.Simple(1,partyRefresh)
end


usermessage.Hook("joinedParty",function(um)
	partyList = vgui.Create("PartyList")
	timer.Simple(2,partyRefresh)
end)

function partyRebuild()
	partyList:Remove()
	partyList = vgui.Create("PartyList")
end
usermessage.Hook("partyRebuild",partyRebuild)
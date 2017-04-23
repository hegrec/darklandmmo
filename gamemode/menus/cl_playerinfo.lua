local name = ""
local class = ""
local level = 0
local pvpRank = 0
local pvpTrophy = 0
local maxHP = 1
local hp = 1
local maxMana = 1
local mana = 1
local maxFatigue = 1
local fatigue = 1


local PANEL = {}

function PANEL:Init()
	self:SetSize(300,150)
	self:ShowCloseButton(false)
	self.head = vgui.Create("SpawnIcon",self)
	self.head:SetPos(5,25)
	self.head:SetSize(64)
	
	
	
end
function PANEL:Paint()
	draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,255))
end

vgui.Register("PlayerInfo",PANEL,"DPanel")

local playerInfo

local function ShowPlayerInfo(um)

	name = um:ReadString()
	class = um:ReadString()
	level = um:ReadChar()
	pvpRank = um:ReadChar()
	pvpTrophy = um:ReadShort()
	maxHP = um:ReadLong()
	hp = um:ReadLong()
	maxMana = um:ReadLong()
	mana = um:ReadLong()
	maxFatigue = um:ReadLong()
	fatigue = um:ReadLong()
	local model = um:ReadString()

	if playerInfo then playerInfo:Remove() end

end
usermessage.Hook("getPlayerInfo",ShowPlayerInfo)
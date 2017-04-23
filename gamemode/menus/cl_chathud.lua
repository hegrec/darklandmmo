local PANEL = {}

function PANEL:Init()

	self:SetSize(ScrW(),ScrH())
	self.FullText	= ""
	self.NPCSays 	= ""
	self.CurrLen	= 0
	self.NextUpdate = 0
	

	
	
	self.Replies = {}
end

function PANEL:Think()
	if self.CurrLen-1 < self.FullLen && self.NextUpdate < RealTime() then
		self.NPCSays = string.sub(self.FullText,1,self.CurrLen)
		self.CurrLen = self.CurrLen + 1
		self.NextUpdate = RealTime() + 0.01
	end
end
function PANEL:Paint()

	--movie bars
	draw.RoundedBox(0,0,0,self:GetWide(),150,Color(0,0,0,255))
	draw.RoundedBox(0,0,self:GetTall()-150,self:GetWide(),150,Color(0,0,0,255))
	
	
	draw.DrawText(util.WordWrap(self.NPCSays,"ScoreboardSub",self:GetWide()-10),"ScoreboardSub",5,5,Color(255,255,255,255),0)
	
	
end
function PANEL:SetNPCText(str)
	self.FullText 	= str
	self.FullLen 	= string.len(str)
	self.CurrLen 	= 1
	self.NPCSays = ""
end

function PANEL:BuildReplies(tbl)

	local num 		= #tbl --usually around 3-4
	
	for i,v in pairs(self.Replies) do
		v:Remove()
	end
	
	self.Replies = {}
	
	for i,v in pairs(tbl) do

		
		local p = vgui.Create("Button",self)
		p:SetSize(self:GetWide(),22)
		p:SetText("")
		p:SetPos(5,self:GetTall()-145 + (24*(i-1)))
		p.Paint = function() local col = Color(200,200,100,255) if self.Armed then col = Color(150,150,255,255) end draw.SimpleText(Replies[ChattingNPC:GetName()][v].Text,"ScoreboardSub",0,0,col,0) end
		p.OnMousePressed = function(self,mc) RunConsoleCommand("talkto",ChattingNPC:EntIndex(),v) end
		table.insert(self.Replies,p)
		
	end
	
	
	
end
vgui.Register("NPCChat",PANEL,"DPanel")

local chatHUD
local function ShowNPCChatHUD(replies)

	chatHUD = vgui.Create("NPCChat")
	chatHUD:SetNPCText(Dialog[ChattingNPC:GetName()][CurrentChat].Text)
	chatHUD:BuildReplies(replies)
	
end
hook.Add("BeginChatting","ShowNPCChatHUD",ShowNPCChatHUD)

local function UpdateChatHUD(replies)
	chatHUD:SetNPCText(Dialog[ChattingNPC:GetName()][CurrentChat].Text)
	chatHUD:BuildReplies(replies)
end
hook.Add("UpdateChatNode","UpdateChatHUD",UpdateChatHUD)

local function HideHUD()
	chatHUD:Remove()
end
hook.Add("StopChatting","EndChat",HideHUD)
function NPCChatView()


	if ChattingNPC:IsValid() then
		return {Vector(-10,-30,70),ChattingNPC:GetPos()+Vector(0,0,65),ChattingNPC}
	end
	
	
end
hook.Add("DoCameraPos","TalkingView",NPCChatView)



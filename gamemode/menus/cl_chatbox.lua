ChatBox = {}
ChatBox.Chat = {}

ChatBox.MaxLines = 10
ChatBox.XOrigin = 0
ChatBox.YOrigin = ScrH() - 350

ChatBox.IsChatting = false

ChatBox.NormalBG = surface.GetTextureID("darkland/rpg/hud/chatbox/ChatBoxLarge2")
ChatBox.TalkingBG = surface.GetTextureID("darkland/rpg/hud/chatbox/ChatBoxLargeTalk2")

ChatBox.NormalAlpha = 0
ChatBox.TalkingAlpha = 255

ChatBox.Alpha = ChatBox.NormalAlpha

ChatBox.Mode = ChatBox.NormalBG

surface.CreateFont("Nyala", 16, 1200, true, false, "ChatBoxTextFont") 

local PANEL = {}

function PANEL:Init()
	self:SetPos(ChatBox.XOrigin,ChatBox.YOrigin)
	self:SetSize(350,212)

	self.ChatHistory = vgui.Create("DPanelList",self)
	self.ChatHistory:SetPos(2,41)
	self.ChatHistory:SetSpacing(0)
    self.ChatHistory:SetPadding(0)
	self.ChatHistory:SetSize(300,126)
	--self.ChatHistory:SetBottomUp(true)
	self.ChatHistory:SetDrawBackground(false)
	self.ChatHistory:EnableVerticalScrollbar()
	self.ChatHistory.VBar.Paint = function(pnl)
        surface.SetDrawColor(122, 108, 93, ChatBox.Alpha)
        surface.DrawRect(0, 0, pnl:GetWide(), pnl:GetTall())
	end
	
	self.ChatHistory.VBar.btnGrip.Paint = function(pnl)
        surface.SetDrawColor(76, 69, 49, ChatBox.Alpha)
        surface.DrawRect(0, 0, pnl:GetWide(), pnl:GetTall())

		surface.SetDrawColor(56, 45, 33, ChatBox.Alpha)
        surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
	end
	
	self.ChatHistory.VBar.btnUp.Paint = function(pnl)
		surface.SetDrawColor(76, 69, 49, ChatBox.Alpha)
        surface.DrawRect(0, 0, pnl:GetWide(), pnl:GetTall())

		surface.SetDrawColor(56, 45, 33, ChatBox.Alpha)
        surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
	end
	
	self.ChatHistory.VBar.btnDown.Paint = self.ChatHistory.VBar.btnUp.Paint
	
	self.Editable = vgui.Create("DTextEntry",self)
	self.Editable:SetPos(8,175)
	self.Editable:SetSize(235,14)
	self.Editable:SetDrawBorder(false)
	self.Editable:SetDrawBackground(false)
	
	self.Editable:SetVisible(false)
	
	self.Editable.Paint = function(TextEntry)
		TextEntry:DrawTextEntryText(Color(109,91,72,255),Color(146,164,183,255),Color(109,91,72,255))
	end
	
	self.Editable.OnKeyCodeTyped = function(TextEntry, Code)
		local Text = TextEntry:GetValue()
		if(Code == KEY_ENTER) then
			if(Text and Text != "") then
				RunConsoleCommand("say", Text)
			end
			self:EnableChat(false)
		elseif(Code == KEY_BACKSPACE) then
			if(TextEntry:GetCaretPos() == 0) then
				TextEntry:OnTextChanged()
			end
		elseif(Code == KEY_TAB) then
			TextEntry:SetCaretPos(TextEntry:GetCaretPos())
			return true
		end
	end
	
	self.Send = vgui.Create("DButton",self)
	self.Send:SetPos(250,172)
	self.Send:SetSize(50,20)
	
	self.Send:SetDrawBorder(false)
    self.Send:SetDrawBackground(false)
	self.Send:SetDisabled(true)
	self.Send:SetText("")
	
	self.Send.DoClick = function()
		self.Editable:OnKeyCodeTyped(KEY_ENTER)
	end
end

function PANEL:Paint()
	surface.SetTexture(ChatBox.Mode)
	surface.SetDrawColor(255,255,255,ChatBox.Alpha)
	surface.DrawTexturedRect(0,0,350,212)
end

function PANEL:AddChat(pnl)
	self.ChatHistory:AddItem(pnl)
	--self.ChatHistory:InvalidateLayout()
	timer.Simple(0.001,function()self.ChatHistory.VBar:SetScroll(math.huge)end) --fails if in the same 'thread'(dunno if that was the right word) as AddChat
	
	
end

function PANEL:EnableChat(bool)
	if(ChatBox.IsChatting == bool)then
		return 
	end
	ChatBox.IsChatting = bool
	self.Editable:SetVisible(bool)

	self:SetKeyboardInputEnabled(bool)
	self:SetMouseInputEnabled(bool)
	self.Send:SetDisabled(!bool)
	
	if(bool)then
		ChatBox.Mode = ChatBox.TalkingBG
		ChatBox.Alpha = ChatBox.TalkingAlpha
		self:MakePopup()
		self:SetFocusTopLevel(true)
		self.Editable:RequestFocus()
	else
		ChatBox.Mode = ChatBox.NormalBG
		ChatBox.Alpha = ChatBox.NormalAlpha
		self.Editable:SetText("")
	end	
end
vgui.Register("ChatBox",PANEL,"EditablePanel")

function ChatBox:AddText(ply,text)
	if(string.Trim(text) == "") then
		return
	end
	
	if(!ChatBox.Panel)then
		return 
	end
	
	if(ply and ValidEntity(ply))then
		local panel = vgui.Create("DPanel")
		panel.name = ply:Name()..": "
		panel.nameCol = Color(40,30,20)
		panel.textCol = Vector(255,255,255)
		panel.name = string.gsub(panel.name," "," ") --replace spaces with alt+255
		panel.lines = ChatBox:SplitLines(panel.name .. text,"ChatBoxTextFont",ChatBox.Panel.ChatHistory:GetWide()-23)
		panel.name = string.gsub(panel.name," "," ") --replace alt+255
		panel.lines[1] = string.gsub(panel.lines[1]," "," ") --replace alt+255
		panel.lines[1] = string.sub(panel.lines[1],string.len(panel.name))
		panel.TextHeight = TH(panel.lines[1],"ChatBoxTextFont") - 2
		panel:SetTall(panel.TextHeight * table.getn(panel.lines))
		
		panel.Paint = function(pnl)
			draw.SimpleText(pnl.name,"ChatBoxTextFont",2,0,Color(pnl.nameCol.r,pnl.nameCol.g,pnl.nameCol.b,255),0,3)
			draw.SimpleText(pnl.lines[1],"ChatBoxTextFont",2+TW(pnl.name,"ChatBoxTextFont"),0,Color(pnl.textCol.x,pnl.textCol.y,pnl.textCol.z,255),0,3)
			for i=2,table.getn(pnl.lines)do
				draw.SimpleText(pnl.lines[i],"ChatBoxTextFont",2,pnl.TextHeight * (i-1),Color(pnl.textCol.x,pnl.textCol.y,pnl.textCol.z,255),0,3)
			end
		end
		chat.AddText(Color(panel.nameCol.x,panel.nameCol.y,panel.nameCol.z,255),panel.name,Color(panel.textCol.x,panel.textCol.y,panel.textCol.z,255),text)
		ChatBox.Panel:AddChat(panel)
	else
		local panel = vgui.Create("DPanel")
		panel.textCol = Vector(255,0,0)
		panel.lines = ChatBox:SplitLines(text,"ChatBoxTextFont",ChatBox.Panel.ChatHistory:GetWide()-23)
		panel.TextHeight = TH(panel.lines[1],"ChatBoxTextFont") - 2
		panel:SetTall(panel.TextHeight * table.getn(panel.lines))
		
		panel.Paint = function(pnl)
			for i=1,table.getn(pnl.lines)do
				draw.SimpleText(pnl.lines[i],"ChatBoxTextFont",2,pnl.TextHeight * (i-1),Color(pnl.textCol.x,pnl.textCol.y,pnl.textCol.z,255),0,3)
			end
		end
		chat.AddText(Color(panel.textCol.x,panel.textCol.y,panel.textCol.z,255),text)
		ChatBox.Panel:AddChat(panel)
	end
end

function ChatBox:SplitLines(text,font,width)
	local lines = {}
	if(TW(text,font) <= width)then
		table.insert(lines,text)
		return lines
	end
	
	local tbl = string.Explode(" ",string.Trim(text))
	if !tbl[3] && TW(tbl[1],font) > width then --one loooooooooooooooooooong word
		tbl = string.ToTable(string.Trim(text))
		local str = ""
		for i=1,table.getn(tbl)do
			str = str .. tbl[i]
			if(TW(str,font) >= width)then
				table.insert(lines,str)
				str = ""
			end
		end
		table.insert(lines,str)
		return lines
	end
	
	
	local str = ""
	local lastSize = 0
	for i,v in ipairs(tbl) do
		lastSize = string.len(tbl[i])
		local space = ""
		if i != 1 && i != table.getn(tbl)-1 then --dont add a space at the end or start
			space = " "
		end
		
		str = str .. space .. tbl[i]
		if(TW(str,font) >= width)then
			
			table.insert(lines,string.sub(str,1,-lastSize-1)) --add the line minus that last word
			str = string.sub(str,-lastSize)
		end
	end
	
	table.insert(lines,str)
	return lines
end

function ChatBox:PlayerBindPress(ply, bind, pressed)
	if(string.find(bind, "messagemode")) then
		ChatBox.Panel:EnableChat(true)
		return true
	end
end
hook.Add("PlayerBindPress", "ChatBox.PlayerBindPress", function(ply, bind, pressed) return ChatBox:PlayerBindPress(ply, bind, pressed) end)

ChatBox.Panel = vgui.Create("ChatBox")
ChatBox.Panel:SetVisible(false)

hook.Add("CharacterLoaded","MakeChat",function() ChatBox.Panel:SetVisible(true) end)
--[[function ChatBox:LoadChat()
	ChatBox.Panel = vgui.Create("ChatBox")
end
hook.Add("InitPostEntity","loadchatbox",ChatBox.LoadChat)]]

function GM:StartChat()
	return true
end

function GM:OnPlayerChat(ply, text, bTeamOnly, bPlayerIsDead)
	ChatBox:AddText(ply, text)
	return true
end

function GM:ChatText(index, name, text, filter)
	if(tonumber(index) == 0) then
		ChatBox:AddText(false, text)
	end
	return true
end

usermessage.Hook("ChatBox.AddChat", function(um)
	local ply = um:ReadEntity()
	local Text = um:ReadString()
	local Col = um:ReadVector()
	local NameColor = team.GetColor(ply:Team())
	local TextColor = Color(Col.x, Col.y, Col.z, 255)
	
	--not implemented
	
	chat.AddText(TextColor, ply:Nick()..": ",TextCoText)
end)

usermessage.Hook("ChatBox.AddCustomChat", function(um)
	local Name = um:ReadString()
	local Text = um:ReadString()
	local NameColor = um:ReadVector()
	local TextColor = um:ReadVector()
	
	--not implemented
	
	chat.AddText(TextColor, Name..": "..Text)
end)

usermessage.Hook("ChatBox.ConsoleMessage", function(um)
	local Text = um:ReadString()
	local Col = um:ReadVector()
	chat.AddText(Color(Col.x, Col.y, Col.z, 255), Text)
end)

function TW(s,f)
	surface.SetFont(f)
	local w = surface.GetTextSize(s)
	return w
end

function TH(s,f)
	surface.SetFont(f)
	local w,h = surface.GetTextSize(s)
	return h
end
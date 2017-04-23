local myGuild = {}

local guildPanel
local PANEL = {}
function PANEL:Init()

	self:SetTitle("Guild Info")
	self:SetSize(640,480)
	self:Center()
	self.nameLbl = Label(myGuild.Name,self)
	self.nameLbl:SetPos(5,25)
	self.nameLbl:SetFont("ScoreboardSub")
	
	self.bList = {"Announcements","Members","Trophy Hall","Ranking","Manage"}
	
	self.buttons = {}
	self.contPans = {}
	local size = self:GetWide()/table.getn(self.bList)
	for i,v in pairs(self.bList) do
		self.buttons[i] = vgui.Create("DButton",self)
		self.buttons[i]:SetText(v)
		self.buttons[i]:SetPos((i-1)*size,50)
		self.buttons[i]:SetWide(size)
		self.buttons[i].DoClick = function() 
			for _,q in pairs(self.bList) do
			
				self.contPans[q]:SetVisible(false)
			
			
			end
				self.contPans[v]:SetVisible(true)
			
		end
		self.contPans[v] = vgui.Create("DPanel",self)
		self.contPans[v]:StretchToParent(5,80,5,5)
	end

	
	self.newestNews = vgui.Create("DPanel",self.contPans["Announcements"])
	self.newestNews:StretchToParent(10,10,10,10)
	self.newestNews:SetTall(64)
	
	local newsText = myGuild.News[1][2] or "No news at this time..."
	local timeText = myGuild.News[1][1] or ""
	
	self.newestLbl = Label(newsText,self.newestNews)
	self.newestLbl:StretchToParent(5,5,100,5)
	self.newestLbl:SetWrap(true)
	
	self.newTimeLbl = Label(timeText,self.newestNews)
	self.newTimeLbl:StretchToParent(self.newestNews:GetWide()-100,5,5,5)
	self.newTimeLbl:SetWrap(true)
	
	self.newsHist = vgui.Create("DPanelList",self.contPans["Announcements"])
	self.newsHist:StretchToParent(10,80,10,35)
	self.newsHist:EnableVerticalScrollbar()
	
	for i,v in pairs(myGuild.News) do
	
	
		local p = vgui.Create("DPanel")
		p:SetTall(64)
		
		p.lblText = Label(v[2],p)
		p.lblText:SetSize(300,50)
		p.lblText:SetPos(5,5)
		p.lblText:SetWrap(true)
		
		p.lblTime = Label(v[1],p)
		p.lblTime:SetSize(100,50)
		p.lblTime:SetPos(505,5)
		p.lblTime:SetWrap(true)
		self.newsHist:AddItem(p)
	end
	
	if Me:IsGuildOfficer() then
		self.newNews = vgui.Create("DButton",self.contPans["Announcements"])
		self.newNews:SetText("+ New Announcement")
		self.newNews:SetPos(25,self.contPans["Announcements"]:GetTall()-40)
		self.newNews:SetWide(100)
		self.newNews.DoClick = function()
		
		Derma_StringRequest( "Guild News", 
			"What news do you need to share? (250 Char max)", 
			"", 
			function( strTextOut ) RunConsoleCommand("~gnu",string.sub(strTextOut,1,250)) end,
			function( strTextOut ) end,
			"Send", 
			"Cancel" )
		end
	end
	
	
	
	
	
	
	
	self.membList = vgui.Create("DListView",self.contPans["Members"])
	self.membList:StretchToParent(10,10,10,10)
	
	local Col1 = self.membList:AddColumn( "Name" )
	local Col2 = self.membList:AddColumn( "Rank" )
	local Col3 = self.membList:AddColumn( "Joined" )
	
	for i,v in pairs(myGuild.Members) do
	
		self.membList:AddLine( v[2], v[3], v[1] )
		
	end
	
	
	
	for _,q in pairs(self.bList) do
		self.contPans[q]:SetVisible(false)
	end
	self.contPans["Announcements"]:SetVisible(true)
end
vgui.Register("GuildInfo",PANEL,"DFrame")


function ShowGuild()

	if Me:HasGuild() then
		http.Get("http://www.darklandservers.com/guildinfo.php?id="..Me:GetGuildID(),"",function(contents,size)
	
			local partSplit = string.Explode("]",contents)
			
			local id = tonumber(partSplit[1])
			local name = partSplit[2]
			local news = partSplit[3]
			
			if string.len(news) > 0 then
				myGuild.News = {}
				local nTable = string.Explode("^",news)
				
				local num = 1
				while (nTable[2]) do
				
					myGuild.News[num] = {base64_decode(nTable[1]),base64_decode(nTable[2])}
					num = num + 1
					table.remove(nTable,1) --remove time
					table.remove(nTable,1) --remove message
					
					
				end
			end
			
			local members = partSplit[4];
			
				myGuild.Members = {}
				local mTable = string.Explode("^",members)
				
				local num = 1
				while (mTable[3]) do
				
					myGuild.Members[num] = {base64_decode(mTable[1]),base64_decode(mTable[2]),mTable[3]}
					num = num + 1
					table.remove(mTable,1) --remove time
					table.remove(mTable,1) --remove name
					table.remove(mTable,1) --remove rank
					
					
				end
			
			myGuild.ID = id
			myGuild.Name = base64_decode(name)
		
			guildPanel = vgui.Create("GuildInfo")
		
		end)
	end
	
	

end
		
		

NewContainer = NULL;


local badHUD = {
"CHudHealth",
"CHudAmmo",
"CHudBattery",
"CHudWeaponSelection",
"CHudCrosshair",
"CHudChat",
"CHudDamageIndicator"
}
local foundEle = {}
function GM:HUDShouldDraw(name)
	return !table.HasValue(badHUD,name)
end

local BOTTOM_SIDES 		= 150
local BOTTOM_CENTER 	= 400
local NUM_SLOTS				= 9

local PANEL = {}

function PANEL:Init()

	self:SetSize(680,125)
	self:CenterHorizontal()
	local x = self:GetPos()
	self:SetPos(x,ScrH()-self:GetTall())
	
	self.SkillBook = vgui.Create("DButton",self)
	self.SkillBook:SetPos(self:GetWide()-170,30)
	self.SkillBook:SetText("S")
	self.SkillBook:SetSize(16,16)
	self.SkillBook.DoClick = ShowSkillBook
	
	self.Items = vgui.Create("DButton",self)
	self.Items:SetPos(self:GetWide()-150,30)
	self.Items:SetText("I")
	self.Items:SetSize(16,16)
	self.Items.DoClick = ShowInventory
	
	self.Guild = vgui.Create("DButton",self)
	self.Guild:SetPos(self:GetWide()-130,30)
	self.Guild:SetText("G")
	self.Guild:SetSize(16,16)
	self.Guild.DoClick = ShowGuild
	
	self.Quests = vgui.Create("DButton",self)
	self.Quests:SetPos(self:GetWide()-110,30)
	self.Quests:SetText("Q")
	self.Quests:SetSize(16,16)
	self.Quests.DoClick = ShowQuests
	
	self.Character = vgui.Create("DButton",self)
	self.Character:SetPos(self:GetWide()-90,30)
	self.Character:SetText("C")
	self.Character:SetSize(16,16)
	self.Character.DoClick = ShowCharacter
	
	
	self.slots = {}
	for i=1,NUM_SLOTS do
		self.slots[i] = vgui.Create("BindSlot",self)
		self.slots[i].slot = i
		self.slots[i]:SetPos(88+(i-1)*33,46)
		
	end


	
end

local id = surface.GetTextureID("darkland/rpg/hud/main")
function PANEL:Paint()
	surface.SetTexture(id)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
	

	--draw.RoundedBox(2,5,60,self:GetWide()*0.5-60,12,Color(0,0,0,255))
	draw.RoundedBox(2,63,88,Me:Health()/Me:GetMaxHealth()*175,12,Color(200,0,0,255))
	draw.SimpleTextOutlined(Me:Health().."/"..Me:GetMaxHealth(),"ChatBoxTextFont",63+175*0.5,93,Color(0,0,0,255),1,1,1,Color(255,255,255,255))
	
	draw.RoundedBox(2,255,88,Me:GetMana()/Me:GetMaxMana()*175,12,Color(50,200,50,255))
	draw.SimpleTextOutlined(Me:GetMana().."/"..Me:GetMaxMana(),"ChatBoxTextFont",255+175*0.5,93,Color(0,0,0,255),1,1,1,Color(255,255,255,255))
	
	--draw.RoundedBox(2,self:GetWide()*0.5+55,60,self:GetWide()*0.5-60,12,Color(0,0,0,255))
	draw.RoundedBox(2,450,88,Me:GetMana()/Me:GetMaxMana()*175,12,Color(50,50,255,255))
	draw.SimpleTextOutlined(Me:GetMana().."/"..Me:GetMaxMana(),"ChatBoxTextFont",450+175*0.5,93,Color(0,0,0,255),1,1,1,Color(255,255,255,255))
	
	--draw.RoundedBox(2,5,self:GetTall()-17,self:GetWide()-10,12,Color(0,0,0,255))
	local gotten = XP-TotalXPAtLevel[Level-1]
	local needed = XPPerLevel(Level)
	
	draw.RoundedBox(2,100,self:GetTall()-14,gotten/needed*(self:GetWide()-200),12,Color(200,200,0,255))
	draw.SimpleTextOutlined(math.floor(gotten).."/"..math.floor(needed),"ChatBoxTextFont",self:GetWide()*0.5,self:GetTall()-10,Color(0,0,0,255),1,1,1,Color(255,255,255,255))
	
	draw.SimpleTextOutlined("Gold: "..Money,"ChatBoxTextFont",500,70,Color(226,204,55,255),0,1,1,Color(156,139,57,255))
	
end

vgui.Register("BottomMain",PANEL,"DPanel")


local bottomHUD;



HUDElements = {}
function MakeHUD()
	bottomHUD 			= vgui.Create("BottomMain")
	table.insert(HUDElements,bottomHUD)
	
	--load old binds
	local str = file.Read("darkland/rpg/bindbar"..CharID..".txt")
	if !str || string.len(str) < 3 then return end


	local t = string.Explode("|",str)
	for i,v in pairs(t) do
		local t2 = string.Explode(":",v)
		
		local itemID = tonumber(t2[2])
		local item
		if !itemID then
			item = t2[2]
		else
			item = Inventory[itemID]
		end
		
		bottomHUD.slots[tonumber(t2[1])]:SetItem(item) --just load it out of the inventory or don't use it cause they don't have it
	end
	
end
hook.Add("CharacterLoaded","MakeBottom",MakeHUD)


function SaveBindSettings()
	local t = {}
	for i,v in pairs(bottomHUD.slots) do
		if v.IsSkill then
			t[i] = v.itemRef
		elseif v.itemRef then
			t[i] = v.itemRef.ID
		end
	end
	
	local str = ""
	local t2 = {}
	for i,v in pairs(t) do
		table.insert(t2,i..":"..v)
	end

	file.Write("darkland/rpg/bindbar"..CharID..".txt",table.concat(t2,"|"))
	
end

function HideHUD()
	bottomHUD:SetVisible(false)
end
hook.Add("BeginChatting","HideHUD",HideHUD)

function ShowHUD()

	if bottomHUD then 
		bottomHUD:SetVisible(true)
	end
	
end
hook.Add("StopChatting","ShowHUD",ShowHUD)


local lastFadeStart = 0
local fadeOutStart = 0
local fadeEnd = 0
local fadeOn = false
function GM:FadeBegin()

	lastFadeStart = RealTime()
	fadeOutStart = RealTime()+0.7
	fadeEnd = RealTime()+1.4
	fadeOn = true

end

local dmgNotes = {}
function GM:AddDamageNotifier(ent,amt)
	if !ValidEntity(ent) then return end
	local t = {}
	t.Start = RealTime()
	t.Damage = amt
	t.Ent = ent
	t.lastPos = (Vector(0,0,40) + ent:GetRight() * 30 + ent:GetPos()):ToScreen()
	t.End = RealTime() + DAMAGE_DISP_LEN
	t.Alpha = 255
	t.FontSize = 24
	table.insert(dmgNotes,t)
end


for i=SMALLEST_DAMAGE_FONT,LARGEST_DAMAGE_FONT do
	surface.CreateFont("Nyala", i, 1200, true, false, "DamageNote"..i) 
end

function GM:HUDPaint()
	if fadeOn then 
		local alpha = ((RealTime()-lastFadeStart)/(fadeOutStart-lastFadeStart))*255
		if alpha > 255 then
			alpha = 255 - ((RealTime()-fadeOutStart)/(fadeEnd-fadeOutStart))*255
		end
		if alpha < 0 then fadeOn = false return end
		draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0,alpha))
	end
	
	for i,v in pairs(dmgNotes) do
		if ValidEntity(v.Ent) then
			v.lastPos = (Vector(0,0,40) + v.Ent:GetRight() * 30 + v.Ent:GetPos()):ToScreen()
		end
		
		local frac = DAMAGE_DISP_LEN*FrameTime()
		
		v.Alpha = math.Approach(v.Alpha,0,255/DAMAGE_DISP_LEN*FrameTime())
		v.FontSize = math.Round(math.Approach(v.FontSize,LARGEST_DAMAGE_FONT,(LARGEST_DAMAGE_FONT-SMALLEST_DAMAGE_FONT)/DAMAGE_DISP_LEN*FrameTime()))
		if v.Alpha == 0 then
			table.remove(dmgNotes,i)
		else
			draw.SimpleTextOutlined(v.Damage,"DamageNote"..v.FontSize,v.lastPos.x,v.lastPos.y,Color(0,200,0,v.Alpha),1,1,2,Color(0,0,0,v.Alpha))
		end
	end
	
	for i,v in pairs(ents.FindInSphere(Me:GetPos(),500)) do
		if HudEntList[v:GetClass()] && v != Me then
			HudEntList[v:GetClass()](v:GetPos():Distance(Me:GetPos()),v)
		end
	end
	

end




local function _validateItems(item,added)
	if added then return end
	
	local replacement
	for i,v in pairs(Inventory) do
		if v.BaseType == item.BaseType && table.Compare(item.Variables,v.Variables) then replacement = v break end
	end
	
	if !bottomHUD then return end --this will get called when you spawn and you get your inventory
	for i,v in pairs(bottomHUD.slots) do
		if v.itemRef && !v.IsSkill && !Inventory[v.itemRef.ID] then
			if replacement then
				v.itemRef = replacement
			else
				v.itemRef = nil
			end
		elseif v.IsSkill && !mySkills[v.itemRef] then
			v.itemRef = nil
			v.IsSkill = nil
		end
	end
end
hook.Add("RefreshInventory","ClearOldItems",_validateItems)



function drawNewQuest()

	local img = vgui.Create("DImage")
	img:SetSize(256,128)
	img:Center()
	img:SetZPos(999)
	img:SetImage("darkland/rpg/hud/newquest")
	local x,y = bottomHUD:GetPos()
	local x1,y1 = bottomHUD.Quests:GetPos()
	
	img:MoveTo(x+x1,y+y1,0.5,1.5,0.1)
	img:SizeTo(16,16,0.4,1.5,0.1)
	img:SetTerm(2)

end
hook.Add("NewQuestAdded","ShowQuestAdded",drawNewQuest)
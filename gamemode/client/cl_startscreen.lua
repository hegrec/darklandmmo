local charGender 	= 1; --1 male, 0 female
local charName 		= ""
local charTree		= ""
local charRace		= "Human"
local snd

local cEnt = NULL

local charInfo = {}
local selectedChar = 1

local pos = Vector(-6819.5625,9662.53125,704) 


local ang = Angle(0,128,0)




local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self:SetSize(465,351)
	self.btnClose:SetVisible(false)
	self.lblTitle:SetVisible(false)
	self:SetDraggable(false)
	
	self.lblError = Label("",self)
	self.lblError:SetPos(114,210)
	self.lblError:SetTextColor(Color(255,0,0,255))
	
	self.Name = vgui.Create("DTextEntry",self)
	self.Name:SetPos(170,101)
	self.Name:SetSize(250,25)
	self.Name:CenterHorizontal()
	self.Name:SetText(Me:Name())
	self.Name:RequestFocus()
	self.Name:SelectAllText()
	
	self.Male = vgui.Create("DRadioButton",self)
	self.Male:SetPos(52,164)
	self.Male.DoClick = function() self:GenderChosen(1) self.Male:SetValue(true) self.Female:SetValue(false) end
	self.Male:SetValue(true)
	
	self.Female = vgui.Create("DRadioButton",self)
	self.Female:SetPos(52,185)
	self.Female.DoClick = function() self:GenderChosen(0) self.Male:SetValue(false) self.Female:SetValue(true) end
	
	
	
	self.Race = vgui.Create("DMultiChoice",self)
	self.Race:SetPos(170,164)
	self.Race:SetWide(100)
	self.Race:SetEditable(false)
	for i,v in pairs(Races) do
		self.Race:AddChoice(i)
	end
	self.Race.OnSelect = function(slf,ind,val,data)
		self.Class:Clear()
		for i,v in pairs(ClassTrees) do
			if table.HasValue(Races[val].ClassTrees,i) then
				self.Class:AddChoice(i)
			end
		end


		self:RaceChosen(val) 
	
	end
	
	self.Class = vgui.Create("DMultiChoice",self)
	self.Class:SetPos(52,234)
	self.Class:SetWide(100)
	self.Class:SetEditable(false)
	for i,v in pairs(ClassTrees) do
		self.Class:AddChoice(i)
	end
	self.Class.OnSelect = function(slf,ind,val,data) self:TreeChosen(val) end
	

	
	self.Go = vgui.Create("DButton",self)
	self.Go:SetPos(330,156)
	self.Go:SetSize(130,40)
	self.Go.DoClick = function()
		charName = self.Name:GetValue()
		SendPlayerData()
	end
	self.Go.Paint = function() end --invisible button
	self.Go:SetText("")
	
end
local id = surface.GetTextureID("darkland/rpg/hud/charcreate/CharacterCreation")
function PANEL:Paint()
	surface.SetTexture(id)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
end


function PANEL:RaceChosen(race)

	charRace = race
	local seq = Races[race].MaleIdle
	local model = Races[race].MaleModel
	if charGender == 0 then
		model = Races[race].FemaleModel
		seq = Races[race].FemaleIdle
	end
	model = string.gsub(model,"/player/","/")
	cEnt:SetModel(model)
	
	local iSeq = cEnt:LookupSequence( seq );
	if (iSeq > 0) then cEnt:ResetSequence( iSeq ) end
end
function PANEL:GenderChosen(gender)
	charGender = gender
	
	local seq = Races[charRace].MaleIdle
	local model = Races[charRace].MaleModel
	if charGender == 0 then
		model = Races[charRace].FemaleModel
		seq = Races[charRace].FemaleIdle
	end
	
	model = string.gsub(model,"/player/","/")
	cEnt:SetModel(model)
	
	local iSeq = cEnt:LookupSequence( seq );
	if (iSeq > 0) then cEnt:ResetSequence( iSeq ) end
end
function PANEL:TreeChosen(tree)

	charTree = tree

end
vgui.Register("CharCreateMenu",PANEL,"DFrame")

local PANEL = {}
function PANEL:Init()
	self:SetSize(300,200)
	self.lblName = Label("",self)
	self.nextLeft = vgui.Create("DButton",self)
	self.nextLeft:SetSize(60,30)
	self.nextLeft:SetText("")
	self.nextLeft:SetPos(115,95)
	self.nextLeft.DoClick = function() RotateCharacters(true) end
	self.nextLeft.Paint = function() end
	
	self.nextRight = vgui.Create("DButton",self)
	self.nextRight:SetSize(50,30)
	self.nextRight:SetText("")
	self.nextRight:SetPos(self:GetWide()-80,90)
	self.nextRight.DoClick = function() RotateCharacters(false) end
	self.nextRight.Paint = function() end
	
	self.Go = vgui.Create("DButton",self)
	self.Go:SetText("")
	self.Go:SetSize(64,32)
	self.Go:SetPos(165,65)
	self.Go.DoClick = LoadCharacter
	self.Go.Paint = function() end
	
	self.Delete = vgui.Create("DButton",self)
	self.Delete:SetText("")
	self.Delete:SetSize(130,40)
	self.Delete:SetPos(5,self:GetTall()-self.Delete:GetTall())
	self.Delete.DoClick = DeleteCharacter
	self.Delete.Paint = function() end
	
end
function PANEL:SetName(n)
	self.lblName:SetText(n)
	self.lblName:SetContentAlignment( 5 )
	self.lblName:SetWide(100)
	self.lblName:SetPos(150,35)
end
local id = surface.GetTextureID("darkland/rpg/hud/gosign")
function PANEL:Paint()
	surface.SetTexture(id)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())

end
vgui.Register("CharSelectMenu",PANEL,"DPanel")



local charMenu;
local charSelect;


local function getStartScreenCamPos()


	local t = {}
	t.origin = Vector(-6940.6313476563,9813.0869140625,779.85394287109) 

	t.angles = Angle(0,-50,0) 

	return t

end
local function ShowCharSelect()
	RunConsoleCommand("needCharacter")
	hook.Add("CalcView","NewCharCalc",getStartScreenCamPos)
	
		for i,v in pairs(HUDElements) do
			v:SetVisible(false)
		end
		

end
hook.Add("InitPostEntity","ShowChar",ShowCharSelect)

local soundPlayed = false
local function getCharacter( um )
	if !soundPlayed then
		surface.PlaySound("darkland/rpg/music/charscreen.mp3")
	end
	local num = um:ReadChar()
	local gender = um:ReadChar()
	local name = um:ReadString()
	local class = um:ReadString()
	local level = um:ReadShort()
	local race = um:ReadString()
	local charID = um:ReadLong()

	local seq = Races[race].MaleIdle
	local model = Races[race].MaleModel
	if gender == 0 then
		model = Races[race].FemaleModel
		seq = Races[race].FemaleIdle
	end
	model = string.gsub(model,"/player/","/")
	if !cEnt:IsValid() then
		cEnt = ClientsideModel(model,RENDERGROUP_OPAQUE)
		selectedChar = num
	end
	
	charInfo[num] = {
	Name = name,
	Gender = gender,
	Class = class,
	Level = level,
	Race = race,
	Num = num,
	CharID = charID,
	Model = model,
	IdleSeq = seq}
	
	cEnt:SetPos(pos)
	cEnt:SetAngles(ang)
	if num != 1 then
		cEnt:SetColor(255,255,255,0)
	end
	local iSeq = cEnt:LookupSequence( seq );
	if (iSeq > 0) then cEnt:ResetSequence( iSeq ) end
	
	if !charSelect then
	charSelect = vgui.Create("CharSelectMenu")
	charSelect:CenterHorizontal()
	
	local x,y = charSelect:GetPos()
	charSelect:SetPos(x,ScrH()-charSelect:GetTall())
	
	charSelect:SetName(name)
	end
	 
end
usermessage.Hook("getCharacter",getCharacter)

local oldThink = 0
hook.Add("Think","AnimateHim",function()


		if ValidEntity(cEnt) then
			cEnt:FrameAdvance( (RealTime()-oldThink) * 0.5 )
		end
	oldThink = RealTime()
end)

local function noCharacters()
	
	local model = Races[charRace].MaleModel --default to a human male apprentice
	model = string.gsub(model,"/player/","/")
	cEnt = ClientsideModel(model,RENDERGROUP_OPAQUE)
	cEnt:SetPos(pos)
	cEnt:SetAngles(ang)
	local iSeq = cEnt:LookupSequence( "LineIdle01" );
	if (iSeq > 0) then cEnt:ResetSequence( iSeq ) end
	
	charMenu = vgui.Create("CharCreateMenu")
	
	local lbl = Label("Welcome to "..GAMEMODE.Name.."!",charMenu)
	lbl:SizeToContents()
	lbl:SetPos(ScrW()-lbl:GetWide()-5,5)
	IntroScene() --lol epic shiz
	surface.PlaySound("darkland/rpg/music/charscreen.mp3")
	

end
usermessage.Hook("noCharacters",noCharacters)

hook.Add("CharacterLoaded","ClearStartScreen",function()

	if charMenu then 
		charMenu:Remove()
	end
	if charSelect then 
		charSelect:Remove()
	end
		for i,v in pairs(HUDElements) do
			v:SetVisible(true)
		end
	
	hook.Remove("CalcView","NewCharCalc")
	RunConsoleCommand("stopsounds")
	cEnt:Remove()
end)

function SendPlayerData()
	

	
	
	if string.len(charName) < 3 then
		charMenu.lblError:SetText("Please pick a name with at least 3 characters")
		charMenu.lblError:SizeToContents()
		return
	elseif !ClassTrees[charTree] then
		charMenu.lblError:SetText("Please select a class tree")
		charMenu.lblError:SizeToContents()
		return
	elseif !table.HasValue(Races[charRace].ClassTrees,charTree) then
		charMenu.lblError:SetText("Selected class tree is not available for your selected race!")
		charMenu.lblError:SizeToContents()
		return
	end
	

		
	RunConsoleCommand("~np",charTree,charName,charGender,charRace)


end


function IntroScene()


end




function RotateCharacters(left)

	if left then
		selectedChar = selectedChar + 1
	else
		selectedChar = selectedChar - 1
	end
	
	if selectedChar > MAX_CHARACTERS then 
		selectedChar = 1
	elseif selectedChar < 1 then
		selectedChar = MAX_CHARACTERS
	end
	
	if !charInfo[selectedChar] then
				
		charGender 	= 1; --set up default
		charName 		= ""
		charTree		= ""
		charRace		= "Human"
			
			
		if !charMenu then
			charMenu = vgui.Create("CharCreateMenu")
		end
		
		local model = Races[charRace].MaleModel --default to a human male apprentice
		
		if !cEnt:IsValid() then
			cEnt = ClientsideModel(model,RENDERGROUP_OPAQUE)
		end
		
		cEnt:SetPos(pos)
		cEnt:SetAngles(ang)
		local iSeq = cEnt:LookupSequence( "LineIdle01" )
		if (iSeq > 0) then cEnt:ResetSequence( iSeq ) end
		
		charSelect:SetName("")
	else
		if charMenu then
			charMenu:Remove()
			charMenu = nil
		end
		
		
		cEnt:SetModel(charInfo[selectedChar].Model)
		local iSeq = cEnt:LookupSequence( charInfo[selectedChar].IdleSeq );
		if (iSeq > 0) then cEnt:ResetSequence( iSeq ) end
			
			charSelect:SetName(charInfo[selectedChar].Name)
			
		end

end

function LoadCharacter()
	if !charInfo[selectedChar] then return end
	RunConsoleCommand("loadCharacter",charInfo[selectedChar].CharID)

end

function DeleteCharacter()
	if !charInfo[selectedChar] then return end
	Derma_Query( "Are you absolutely sure you want to delete this character?\nIt will be lost forever", "Question!",
						"Delete", 	function() RunConsoleCommand("deleteCharacter",charInfo[selectedChar].CharID)  RotateCharacters(true) end, 
						"Cancel", 	function() end)

	
	

end
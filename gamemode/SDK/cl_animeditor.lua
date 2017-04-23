local boneList = {
	"ValveBiped.Bip01_Pelvis",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_Neck1",
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_R_Toe0",
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_L_Toe0"
}



local animationData = {}
function animprint()
	PrintTable(animationData)
end
concommand.Add("animprint",animprint)


local animName
local animType
--local selectedFrame
--local selectedBone

local function PaintTopBar()
	local wide = ScrW()
	draw.RoundedBox(0,0,0,wide,26,Color(0,0,0,255))
	draw.RoundedBox(0,1,1,wide-2,24,Color(50,50,50,255))
	draw.SimpleText("Lua Animation Editor (API by JetBoom)","ScoreboardSub",wide*0.5,13,Color(255,255,255,255),1,1)
	
	
	if selectedBone && selectedBone != "" then
			
			local boneID = Me:LookupBone(selectedBone)
		
			if boneID then
				local vec,ang = Me:GetBonePosition(boneID)
				local up = ang:Up()*20
				local right = ang:Right()*20
				local forward = ang:Forward()*20
				
				local origin = vec:ToScreen()
				
				surface.SetDrawColor(255,0,0,255)
				local p1 = (vec+right):ToScreen()
				surface.DrawLine(origin.x,origin.y,p1.x,p1.y)
				
				surface.SetDrawColor(0,255,0,255)
				local p2 = (vec+forward):ToScreen()
				surface.DrawLine(origin.x,origin.y,p2.x,p2.y)
				
				surface.SetDrawColor(0,0,255,255)
				local p3 = (vec+up):ToScreen()
				surface.DrawLine(origin.x,origin.y,p3.x,p3.y)
			end
	end
	
end









local animEditorPanels = {}



function NewAnimation()
	local frame = vgui.Create("DFrame")
	
	form = vgui.Create("DForm",frame)
	form:SetPos(5,25)
	form:SetWide(300)
	form:SetName("Animation Properties")
	local entry = form:TextEntry("Animation Name")
	
	local info = form:Help([[Gestures are keyframed animations that use the current position and angles of the bones. They play once and then stop automatically.
	
	Postures are static animations that use the current position and angles of the bones. They stay that way until manually stopped. Use TimeToArrive if you want to have a posture lerp.
	
	Stances are keyframed animations that use the current position and angles of the bones. They play forever until manually stopped. Use RestartFrame to specify a frame to go to if the animation ends (instead of frame 1).
	
	Sequences are keyframed animations that use the origin and angles of the entity. They play forever until manually stopped. Use RestartFrame to specify a frame to go to if the animation ends (instead of frame 1).
	You can also use StartFrame to specify a starting frame for the first loop.]])
	local type = form:ComboBox("Animation Type")
	type:SetTall(100)
	
	type:AddItem("TYPE_GESTURE").Num = TYPE_GESTURE
	type:AddItem("TYPE_POSTURE").Num = TYPE_POSTURE
	type:AddItem("TYPE_STANCE").Num = TYPE_STANCE
	type:AddItem("TYPE_SEQUENCE").Num = TYPE_SEQUENCE
	local help = form:Help("Select your options")
	local begin = form:Button("Begin")
	begin.DoClick = function()
	
	
		animName = entry:GetValue()
		animType = type:GetSelected().Num
		
		if animName == "" then help:SetText("Write a name for this animation") return end
		if !animType then help:SetText("Select a valid animation type!") return end
		frame:Remove()
		AnimationStarted()
		
	end
	frame:MakePopup()
	timer.Simple(0.01,function()frame:SetSize(form:GetWide()+10,form:GetTall()+30) frame:Center() end)
end

function LoadAnimation()

	local frame = vgui.Create("DFrame")
	frame:SetSize(300,300)
	frame:SetTitle("Load Animation")
	local box = vgui.Create("DComboBox",frame)
	box:StretchToParent(5,25,5,35)
	for i,v in pairs(GetLuaAnimations()) do
		if i != "editortest" then
			box:AddItem(i)
		end
	end
	
	local button = vgui.Create("DButton",frame)
	button:SetWide(frame:GetWide()-10)
	button:SetPos(5,frame:GetTall()-25)
	button:SetText("Load Animation")
	button.DoClick = function()
	
		animName = box:GetSelected():GetValue()
		animationData = GetLuaAnimations()[animName]
		animType = animationData.Type
		frame:Remove()
		AnimationStarted(true)
		
	end
	frame:Center()
end

function SaveAnimation()


			Derma_StringRequest( "Question", 
					"Save as...", 
					animName or "", 
					function( strTextOut ) 	
						local t = {}
						t.Table = animationData
						t.Name = strTextOut
						datastream.StreamToServer("animationset",t) end,
					function( strTextOut ) end,
					"Save To Server", 
					"Cancel" )






end

function AnimationStarted(bLoaded)
	if !bLoaded then
		animationData = {}
		animationData.FrameData = {}
		animationData.Type = animType

		for i,v in pairs(animEditorPanels) do
			if v.OnNewAnimation then
				v:OnNewAnimation()
			end
		end
	else

		for i,v in pairs(animEditorPanels) do
			if v.OnLoadAnimation then
				v:OnLoadAnimation()
			end
		end
	end

end
	
local timeLine
local mainSettings
local sliders
function AnimationEditorOn()
	
	for i,v in pairs(animEditorPanels) do 
		v:Remove()
	end
	
	
	local close = vgui.Create("DSysButton")
	close:SetType("close")
	close.DoClick = function(slf) AnimationEditorOff() end
	close:SetSize(16,16)
	close:SetPos(ScrW()-20,4)
	table.insert(animEditorPanels,close)
	
	timeLine = vgui.Create("TimeLine")
	table.insert(animEditorPanels,timeLine)
	
	mainSettings = vgui.Create("MainSettings")
	table.insert(animEditorPanels,mainSettings)
	
	sliders = vgui.Create("Sliders")
	table.insert(animEditorPanels,sliders)
	
	hook.Add("HUDPaint","PaintTopBar",PaintTopBar)
	hook.Add("DoCameraPos","AnimationEditor",AnimationEditorView)
	
end
concommand.Add("animate",AnimationEditorOn)


function AnimationEditorOff()
	
	for i,v in pairs(animEditorPanels) do 
		v:Remove()
	end
	hook.Remove("HUDPaint","PaintTopBar")
	hook.Remove("DoCameraPos","AnimationEditor")
	Me:StopAllLuaAnimations()
end


function AnimationEditorView()

	return {Vector(200,0,50),Me:GetPos()+Vector(0,0,65),Me}
	
end



local secondDistance = 200 --100px per second on timeline



local MAIN = {}
function MAIN:Init()

	self:SetName("Main Settings")
	self:SetSize(200,350)
	
	
	local newanim = self:Button("New Animation")
	newanim.DoClick = NewAnimation
	
	
	local loadanim = self:Button("Load Animation")
	loadanim.DoClick = LoadAnimation

	local saveanim = self:Button("Save Animation To Server")
	saveanim.DoClick = SaveAnimation
	
	
	local bones = self:ComboBox("Selected Bone")
	bones:SetTall(200)
	bones:SetMultiple(false)
	for i,v in pairs(boneList) do
		bones:AddItem(v).DoClick = function(s) selectedBone = s:GetValue() sliders:SetFrameData() end
	end
		
	
	
	timer.Simple(0.01,function() self:SetPos(ScrW()-200,ScrH()-self:GetTall()-100) end)

end
vgui.Register("MainSettings",MAIN,"DForm")

local TIMELINE = {}
function TIMELINE:Init()

	self:SetTitle("Timeline")
	self:ShowCloseButton(false)
	self:SetSize(ScrW(),100)
	self:SetPos(0,ScrH()-100)
	self:SetDraggable(false)
	
	local timeLine = vgui.Create("DHorizontalScroller",self)
	timeLine:SetPos(5,45)
	timeLine:SetSize(self:GetWide()-self:GetTall()-30,50)
	self.timeLine = timeLine
	local timeLineTop = vgui.Create("DPanel",self)
	timeLineTop:SetPos(5,25)
	timeLineTop:SetSize(self:GetWide()-self:GetTall(),20)
	timeLineTop.Paint = function(s)
	
	
	
		local XPos = timeLine.OffsetX
		
		draw.RoundedBox(0,0,0,self:GetWide(),16,Color(200,200,200,255))
		
		
		local previousSecond = XPos-(XPos%secondDistance)
		for i=previousSecond,previousSecond+s:GetWide(),secondDistance/4 do
			if i-XPos > 0 && i-XPos < ScrW() then
				local sec = i/secondDistance
				draw.SimpleText(sec,"DefaultSmall",i-XPos,6,Color(0,0,0,255),1,1)
			end
		end
	
	end
	
	
	
	local addKeyButton = vgui.Create("DButton",self)
	addKeyButton:SetText("Add KeyFrame")
	addKeyButton.DoClick = function() self:AddKeyFrame() end
	addKeyButton:SetSize(self:GetTall()-20,self:GetTall()-60)
	addKeyButton:SetPos(self:GetWide()-self:GetTall()+10,30)
	self.addKeyButton = addKeyButton
	addKeyButton:SetDisabled(true)
	
	self.isPlaying = false
	local play = vgui.Create("DButton",self)
	play:SetPos(self:GetWide()-self:GetTall()+10,self:GetTall()-25)
	play:SetWide(self:GetTall()-60)
	play:SetText("Play")
	play.DoClick = function(bOverride)
		self.isPlaying = !self.isPlaying
		if self.isPlaying then
			RegisterLuaAnimation("editortest",animationData) --why not
			Me:StopAllLuaAnimations()
			Me:SetLuaAnimation("editortest")
			play:SetText("Stop")
		else
			Me:StopAllLuaAnimations()
			play:SetText("Play")			
		end
		
	end
	self.play = play
	self.play:SetDisabled(true)
	
end
function TIMELINE:UpdatePlayButton(bPlaying)
		self.isPlaying = bPlaying
		if bPlaying then
			self.play:SetText("Stop")
		else
			self.play:SetText("Play")			
		end


end
function TIMELINE:OnNewAnimation()
	for i,v in pairs(self.timeLine.Panels) do
		v:Remove()
		self.timeLine.Panels[i] = nil
	end
	self.addKeyButton:SetDisabled(false)
	self.play:SetDisabled(false)
	self:AddKeyFrame() --helper add first frame
end
local addFrame = true
function TIMELINE:OnLoadAnimation()
	for i,v in pairs(self.timeLine.Panels) do
		v:Remove()
		self.timeLine.Panels[i] = nil
	end
	self.addKeyButton:SetDisabled(false)
	self.play:SetDisabled(false)
	
	
	addFrame = false
	for i,v in pairs(animationData.FrameData) do
		
		local keyframe = self:AddKeyFrame() --helper add first frame
		keyframe:SetFrameData(i,v)
		
	end
	addFrame = true
		
end

function TIMELINE:GetAnimationTime()


end
	
local flippedBool = false
function TIMELINE:AddKeyFrame()
	flippedBool = !flippedBool
	local keyframe = vgui.Create("KeyFrame")
	keyframe:SetWide(secondDistance) --default to 1 second animations
	
	keyframe.Alternate = flippedBool
	
	
	if keyframe:GetAnimationIndex() && keyframe:GetAnimationIndex() > 1 then
		keyframe:CopyPreviousKey()
	end
	
	self.timeLine:AddPanel(keyframe)
	self.timeLine:InvalidateLayout()
	
	
	
	if animType == TYPE_POSTURE then self.addKeyButton:SetDisabled(true) end --postures have only one keyframe

	return keyframe

end
vgui.Register("TimeLine",TIMELINE,"DFrame")

local KEYFRAME = {}

function KEYFRAME:Init()
	self:SetWide(secondDistance)
	if addFrame then
		self.AnimationKeyIndex = table.insert(animationData.FrameData,{FrameRate = 1,BoneInfo = {}})
		self.DataTable = animationData.FrameData[self.AnimationKeyIndex]
	end
	selectedFrame = self
end
function KEYFRAME:GetData()
	return self.DataTable
end
function KEYFRAME:SetFrameData(index,tbl)
	self.DataTable = tbl
	self.AnimationKeyIndex = index
	self:SetWide(1/self:GetData().FrameRate*secondDistance)
	self:GetParent():GetParent():InvalidateLayout() --rebuild the timeline
	if animationData.RestartFrame == index then
		self.RestartPos = true
	end
end
function KEYFRAME:CopyPreviousKey()
	local iKeyIndex = self:GetAnimationIndex()-1
	local tFrameData = animationData.FrameData[iKeyIndex]
	if !tFrameData then return end
	
	
	
end
function KEYFRAME:GetAnimationIndex()
	return self.AnimationKeyIndex
end
function KEYFRAME:Paint()
	local col = Color(150,150,150,255)
	if self.Alternate then
		col = Color(200,200,200,255)
	end
	draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),col)
	if selectedFrame == self then
		surface.SetDrawColor(255,0,0,255)
		surface.DrawOutlinedRect(1,1,self:GetWide()-2,self:GetTall()-2)
	end
	draw.SimpleText(self:GetAnimationIndex(),"DefaultSmall",10,10,Color(0,0,0,255),0,3)
	if self.RestartPos then
		draw.SimpleText("Restart Here","DefaultSmall",10,20,Color(0,0,0,255),0,3)
	end
end
function KEYFRAME:OnMousePressed(mc)
	if mc == MOUSE_LEFT then
		selectedFrame = self
		sliders:SetFrameData()
	elseif mc == MOUSE_RIGHT then
		local menu = DermaMenu()
		menu:AddOption("Change Frame Length",function() 	
			Derma_StringRequest( "Question", 
					"How long should this frame be (seconds)?", 
					"1.0", 
					function( strTextOut ) self:SetLength(tonumber(strTextOut)) end,
					function( strTextOut ) end,
					"Set Length", 
					"Cancel" )
			end)
		menu:AddOption("Change Frame Rate",function() 	
			Derma_StringRequest( "Question", 
					"Set frame "..self:GetAnimationIndex().."'s framerate", 
					"1.0", 
					function( strTextOut ) self:SetLength(1/tonumber(strTextOut)) end,
					function( strTextOut ) end,
					"Set Frame Rate", 
					"Cancel" )
			end)
		menu:AddOption("Set Restart Pos",function() 
			
			for i,v in pairs(timeLine.timeLine.Panels) do
				if v.RestartPos then v.RestartPos = nil end
			end
			self.RestartPos = true 
			animationData.RestartFrame = self:GetAnimationIndex()
		end)
		
		if self:GetAnimationIndex() > 1 then
			menu:AddOption("Reverse Previous Frame",function()
				local tbl = animationData.FrameData[self:GetAnimationIndex()-1].BoneInfo
				for i,v in pairs(tbl) do
					self:GetData().BoneInfo[i] = self:GetData().BoneInfo[i] or {}
					self:GetData().BoneInfo[i].MU = v.MU * -1
					self:GetData().BoneInfo[i].MR = v.MR * -1
					self:GetData().BoneInfo[i].MF = v.MF * -1
					self:GetData().BoneInfo[i].RU = v.RU * -1
					self:GetData().BoneInfo[i].RR = v.RR * -1
					self:GetData().BoneInfo[i].RF = v.RF * -1
				end
				sliders:SetFrameData()
			end)
		end
		
		menu:AddOption("Duplicate Frame To End",function()
			local tbl = animationData.FrameData
			local keyframe = timeLine:AddKeyFrame()
			for iBoneID, tBoneInfo in pairs(self:GetData().BoneInfo) do
				
				keyframe:GetData().BoneInfo[iBoneID] = self:GetData().BoneInfo[i] or {}
				keyframe:GetData().BoneInfo[iBoneID].MU = 0
				keyframe:GetData().BoneInfo[iBoneID].MR = 0
				keyframe:GetData().BoneInfo[iBoneID].MF = 0
				keyframe:GetData().BoneInfo[iBoneID].RU = 0
				keyframe:GetData().BoneInfo[iBoneID].RR = 0
				keyframe:GetData().BoneInfo[iBoneID].RF = 0
				
			end
			selectedFrame = keyframe
			sliders:SetFrameData()
		end)
				
			
		menu:AddOption("Remove Frame",function() 
			local frameNum = self:GetAnimationIndex()
			if frameNum == 1 and !animationData.FrameData[2] then return end --can't delete the frame when it's the only one
			table.remove(animationData.FrameData,frameNum)
			RegisterLuaAnimation("editortest",animationData) --update animation without discarded frame
			Me:StopAllLuaAnimations()
			timeLine:UpdatePlayButton(false)
			for i,v in pairs(timeLine.timeLine.Panels) do
				if v == self then
					timeLine.timeLine.Panels[i] = nil
				elseif v:GetAnimationIndex() > frameNum then
					v.AnimationKeyIndex = v.AnimationKeyIndex - 1
					v.Alternate = !v.Alternate
				end
			end
		
			timeLine.timeLine:InvalidateLayout()
			self:Remove()
			
		end)
					
		menu:Open()
		
	end
end
function KEYFRAME:SetLength(int)
	if !int then return end
	self:SetWide(secondDistance*int)
	self:GetParent():GetParent():InvalidateLayout() --rebuild the timeline
	self:GetData().FrameRate = 1/int --set animation frame rate
end
vgui.Register("KeyFrame",KEYFRAME,"DPanel")


local SLIDERS = {}
function SLIDERS:Init()
	self:SetName("Modify Bone")
	self:SetWide(200)
	self.Sliders = {}
	
	self.Sliders.MU = self:NumSlider("Translate UP", nil, -100, 100, 0 )
	self.Sliders.MU.OnValueChanged = function(s,v) self:OnSliderChanged("MU",v) end
	self.Sliders.MU.Label:SetTextColor(Color(0,0,255,255))
	
	self.Sliders.MR = self:NumSlider("Translate RIGHT", nil, -100, 100, 0 )
	self.Sliders.MR.OnValueChanged = function(s,v) self:OnSliderChanged("MR",v) end
	self.Sliders.MR.Label:SetTextColor(Color(255,0,0,255))
	
	self.Sliders.MF = self:NumSlider("Translate FORWARD", nil, -100, 100, 0 )
	self.Sliders.MF.OnValueChanged = function(s,v) self:OnSliderChanged("MF",v) end
	self.Sliders.MF.Label:SetTextColor(Color(0,255,0,255))
		
	self.Sliders.RU = self:NumSlider("Rotate UP", nil, -360, 360, 0 )
	self.Sliders.RU.OnValueChanged = function(s,v) self:OnSliderChanged("RU",v) end
	self.Sliders.RU.Label:SetTextColor(Color(0,0,255,255))
	
	self.Sliders.RR = self:NumSlider("Rotate RIGHT", nil, -360, 360, 0 )
	self.Sliders.RR.OnValueChanged = function(s,v) self:OnSliderChanged("RR",v) end
	self.Sliders.RR.Label:SetTextColor(Color(255,0,0,255))
	
	self.Sliders.RF = self:NumSlider("Rotate FORWARD", nil, -360, 360, 0 )
	self.Sliders.RF.OnValueChanged = function(s,v) self:OnSliderChanged("RF",v) end
	self.Sliders.RF.Label:SetTextColor(Color(0,255,0,255))
	
	
	timer.Simple(0.01,function() self:SetPos(ScrW()-self:GetWide(),ScrH()-100-self:GetTall()-mainSettings:GetTall()) end)	
end

function SLIDERS:SetFrameData()
	if !selectedFrame || !selectedBone || !selectedFrame:GetData().BoneInfo[selectedBone] then 
	
		for i,v in pairs(self.Sliders) do
			v:SetValue(0)
		end
	
	return end
	for i,v in pairs(self.Sliders) do
		v:SetValue(selectedFrame:GetData().BoneInfo[selectedBone][i] or 0)
	end

end

function SLIDERS:OnSliderChanged(moveType,value)
	if !ValidPanel(selectedFrame) || !table.HasValue(boneList,selectedBone) then return end --no keyframe/bone selected
	if (tonumber(value) == 0 && selectedFrame:GetData().BoneInfo[selectedBone] == nil) then return end
	
	--[[if selectedFrame:GetAnimationIndex() > 1 then
		local prevBoneData = animationData.FrameData[self:GetAnimationIndex()-1][selectedBone]
		if prevBoneData then]]
			
	
	selectedFrame:GetData().BoneInfo = selectedFrame:GetData().BoneInfo or {}
	selectedFrame:GetData().BoneInfo[selectedBone] = selectedFrame:GetData().BoneInfo[selectedBone] or {}
	selectedFrame:GetData().BoneInfo[selectedBone][moveType] = tonumber(value)
	RegisterLuaAnimation("editortest",animationData)
	Me:StopAllLuaAnimations()
	Me:SetLuaAnimation("editortest")
	timeLine:UpdatePlayButton(true)


end
vgui.Register("Sliders",SLIDERS,"DForm")
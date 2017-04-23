require("datastream")

include("cl_animeditor.lua")

local ItemPanel
local NPCPanel
local IsDeleting = false
local CommandFunc = function() end

function EditorPress(t,menu)
	if IsDeleting && t.Entity:IsValid() then
		RunConsoleCommand("deleteitem",t.Entity:EntIndex())
		return
	end
	if t.Entity:IsValid() && menu then
		menu:AddOption("Edit "..t.Entity:GetClass(),function() EditEntityProperties(t.Entity) end)
	end
	if !CommandFunc then return end
	CommandFunc(t)
end

local function PromptNPCEmitter(vec)
	local parent = vgui.Create("DFrame")
	local form = vgui.Create("DForm",parent)
	
	local ctrl = form:MultiChoice( "Choose an NPC Type" )
	for i,v in pairs(NPCMonsters) do
		ctrl:AddChoice( v.Name,i )
	end
	ctrl:SetEditable(false)
	local nList = {}
	local viewList = {}
	local lbl = form:Help("Choose an NPC Type above")
	ctrl.OnSelect = function(s,ind,val,data) if !table.HasValue(nList,data) then table.insert(nList,data) table.insert(viewList,val) lbl:SetText(table.concat(viewList,",")) form:InvalidateLayout() end end
	
	

	local inst_name = form:MultiChoice("Instance")
	inst_name:SetEditable(false)
	local tbl = {}
	for i,v in pairs(ents.GetAll()) do
		if v:IsDoor() && v:GetNWString("GoesTo") == "" then
			table.insert(tbl,v:GetName())
		end
	end
	inst_name:AddChoice("None")
	table.sort(tbl,function(a,b) return a > b end)
	for i,v in pairs(tbl) do
		inst_name:AddChoice(v)
	end
		

	
	local numMax = form:NumSlider("Max NPCs",nil,1,10,0)
	local numDelay = form:NumSlider("Spawn Delay",nil,1,60,0)
	local runs = form:NumSlider("Max Runs(0=Infinite)",nil,0,100,0)
	local GoButton = form:Button("Finish Emitter")
	GoButton.DoClick = function() RunConsoleCommand("placeNPCEmitter",vec.x,vec.y,vec.z+5,table.concat(nList,";"),numMax:GetValue(),numDelay:GetValue().." "..runs:GetValue(),inst_name.TextEntry:GetValue()) parent:Remove() end
	form:SetName("NPC Emitter Details")
	parent:SetSize(400,400)
	form:StretchToParent(5,25,5,5)
	parent:Center()
	parent:MakePopup()
	parent:SetTitle("NPC Emitter Options")
	


end




local dungeonForm
local areaForm
local function DungeonEdit()
	if dungeonForm then return end
	dungeonForm = vgui.Create("DungeonSetup")
end
local function AreaEdit()
	if areaForm then return end
	areaForm = vgui.Create("AreaSetup")
end


local TreePainting = false
local treeForm
local function BeginTreePaint()
	
	treeForm = vgui.Create("TreePaintOptions")
end

local seg = 128
local paintRad = 256
local radsperseg = math.rad( 360 / seg )


local matFire = Material( "cable/physbeam" )
local circlePos
local function DrawTreePaintCircle()
	if TreePainting then
		local t 	= {}
		t.start 	= CameraPos
		t.endpos 	= t.start + Me:GetCursorAimVector() * 30000


		t = util.TraceLine(t)

		
		local t2 = {}
		
		t2.start = t.HitPos + Vector(0,0,1)
		if t.HitSky then 
			t2.start = t2.start - t.HitNormal*Vector(0,0,2) 
		end
		t2.endpos = t2.start + Vector(0,0,20000)
		
		t2 = util.TraceLine(t2)
		
		circlePos = t2.HitPos - Vector(0,0,1)
		render.SetMaterial( matFire );
		 
		render.StartBeam( seg+1 );

		local startPoint
		for i = seg, 1, -1 do 
			local r = radsperseg * i - 1 
			
			
			local point = Vector(circlePos.x+(math.cos( r ) * paintRad),circlePos.y+(math.sin( r ) * paintRad),circlePos.z)
			
			local t 	= {}
			t.start 	= point
			t.endpos 	= t.start - Vector(0,0,20000)

			t = util.TraceLine(t)
			if i == seg then startPoint = t.HitPos+Vector(0,0,10) end
			local tcoord = CurTime() + ( 1 / (seg+1) ) * i;
		 

			render.AddBeam(
				t.HitPos+Vector(0,0,10),
				64,
				tcoord,
				Color( 64, 255, 64, 255 )
			);
			
		end
		
			render.AddBeam(
				startPoint,
				64,
				CurTime(),
				Color( 64, 255, 64, 255 )
			);

		render.EndBeam();
	end

end
hook.Add("PostPlayerDraw","DrawTreePaintCircle",DrawTreePaintCircle)


local function GetResourceWithinCircle()

	local randomVec = circlePos
	local r = radsperseg * math.random(0,seg)-1
	
	local dist = math.random(3,paintRad)
	local point = Vector(circlePos.x+(math.cos( r ) * dist),circlePos.y+(math.sin( r ) * dist),circlePos.z)
	
	local t 	= {}
	t.start 	= point
	t.endpos 	= t.start - Vector(0,0,20000)

	t = util.TraceLine(t)
	
	return t.HitPos

end

function PainterTick()

	if leftDown then
		local resPos = GetResourceWithinCircle()
		if resPos then
			RunConsoleCommand("painttree",treeForm:GetTreeType(),resPos.x,resPos.y,resPos.z)
		end
	end


end


function PlaceItem(vec,isArea)
	local info = {}

	if isArea then
		if !areaForm then CommandFunc = nil return end
		info.itemClassID = areaForm.itemClassID
		info.AreaID = areaForm.areaID
		
		info.Properties = areaForm:GrabItemInfo()
		info.Properties.IsArea = true 
	else
		if !dungeonForm then CommandFunc = nil return end
		
		info.ScenarioName = dungeonForm.setupName.TextEntry:GetValue()
		info.itemClassID = dungeonForm.itemClassID
		info.AreaID = dungeonForm.areaID
		info.Properties = dungeonForm:GrabItemInfo()
	end
	
	info.Pos = vec
	info.Ang = Me:GetAngles()
	
	
	
	
	datastream.StreamToServer("itemplace",info)
end

local function EditorOn()
	SetEditing(true)
	
	for i,v in pairs(HUDElements) do
		v:SetVisible(false)
	end
	
	ItemPanel = vgui.Create("DPanelList")
	ItemPanel:SetSize(150,200)
	ItemPanel:SetAutoSize(true)
	ItemPanel:EnableVerticalScrollbar()
		
	local dungeonBtn = vgui.Create("DButton")
	dungeonBtn.DoClick = function() IsDeleting = false DungeonEdit() CommandFunc = function(t) PlaceItem(t.HitPos,false) end  end
	dungeonBtn:SetText("Dungeon Master")
	ItemPanel:AddItem(dungeonBtn)
	
	local aeBtn = vgui.Create("DButton")
	aeBtn.DoClick = function() IsDeleting = false AreaEdit() CommandFunc = function(t) PlaceItem(t.HitPos,true) end  end
	aeBtn:SetText("Area Editor")
	ItemPanel:AddItem(aeBtn)
	
	--[[local aeBtn = vgui.Create("DButton")
	aeBtn.DoClick = function() IsDeleting = false Derma_StringRequest("How Many Trees?", "How Many Trees should the generator create?", "100", function(text) RunConsoleCommand("genforest", text) end)  end
	aeBtn:SetText("Random Forest Generator")
	ItemPanel:AddItem(aeBtn)]]
	
	local treePainter = vgui.Create("DButton")
	treePainter.DoClick = function() IsDeleting = false BeginTreePaint()  end
	treePainter:SetText("Tree Painter")
	ItemPanel:AddItem(treePainter)
	
	local aeBtn = vgui.Create("DButton")
	aeBtn.DoClick = function() IsDeleting = false AnimationEditorOn() end
	aeBtn:SetText("Animation Editor")
	ItemPanel:AddItem(aeBtn)
	
	hook.Add("HUDPaint","DrawEntityNames",DrawEntityNames)
	
end

local function EditorOff()
	SetEditing(false)
	for i,v in pairs(HUDElements) do
		v:SetVisible(true)
	end
	ItemPanel:Remove()
	hook.Remove("HUDPaint","DrawEntityNames")
	hook.Remove("RenderScreenspaceEffects", "NavRenderScreenspaceEffects")
	hook.Call("EditorOff",GAMEMODE)
end




local function editorToggled(um)
	
	if um:ReadBool() then
		EditorOn()
	else
		EditorOff()
	end
end
usermessage.Hook("editorToggled",editorToggled)



local propertiesEditor
local editingEnt
function EditEntityProperties(ent)
	editingEnt = ent
	propertiesEditor = vgui.Create("PropertiesEditor")
	
	
end
local PANEL = {}

function PANEL:Init()
	self:SetSize(400,400)
	self:Center()
	self:SetTitle("Editing - "..editingEnt:GetClass())
	self.form = vgui.Create("DForm",self)
	self.form:SetWide(390)
	self.form:SetPos(5,25)
	self:MakePopup()
end
vgui.Register("PropertiesEditor",PANEL,"DFrame")

function DrawEntityNames()
	for i,v in pairs(ents.FindInSphere(Me:GetPos(),6000)) do
		local pos = v:GetPos():ToScreen()
		local custStr = ""
		if v:IsDoor() && v:GetNWString("GoesTo") != "" then
			custStr = custStr .. " -> "..v:GetNWString("GoesTo")
			if v:GetNWBool("TownDoor") then
				custStr = custStr .. "; Town = true"
			end
			if v:GetTargetArea() > 0 then
				custStr = custStr .. "; TargetArea = "..Areas[v:GetTargetArea()].Name
			end
			if v:GetArea() > 0 then
				custStr = custStr .. "; Area = "..Areas[v:GetArea()].Name
			end
			if v:GetTargetArea() > 0 then
				custStr = custStr .. "; Instanced = "..tostring(Areas[v:GetTargetArea()].Instanced == true)
			end
		end
		local str = v:GetName()..custStr
		if string.len(str) > 1 then
			draw.SimpleText(str,"Default",pos.x,pos.y,Color(255,255,255,255))
		end
	end
end

local PANEL = {} 
function PANEL:Init()
	self:SetSize(260,200)
	self:SetTitle("Dungeon Master")
	self:ShowCloseButton(false)
	self.form = vgui.Create("DForm",self)
	self.form:SetName("Dungeon Master")
	self.form:SetPos(5,25)
	self.form:SetWide(250)
	self.setupName = self.form:MultiChoice("Scenario Name")
	self.setupName:SetEditable(false)
	local t = {}
	for i,v in pairs(quest.GetAll()) do
		for i,v in pairs(v.ActiveDungeons) do
			if !t[i] then
				t[i] = true
				self.setupName:AddChoice(i)
			end
		end
	end
	local loadTestCaveButton = self.form:Button("Load Selected Dungeon Setup")
	loadTestCaveButton.DoClick = function()
	
		RunConsoleCommand("loaddungeonsetup",self.setupName.TextEntry:GetValue())
	end
	
	self.areaID = 0
	self.ctrl = self.form:MultiChoice( "Attach Dungeon to Area" )
	self.ctrl:SetEditable(false)
	local dist = math.huge
	local closestDoor
	for i,v in pairs(Areas) do
		if v.Type == AREA_DUNGEON then
			self.ctrl:AddChoice( v.Name, i)
		end
	end
	self.ctrl.OnSelect = function(slf,ind,val,data) self.areaID = data end
	self.classType = self.form:MultiChoice("Item Class") 
	self.classType:SetEditable(false)
	for i,v in pairs(PlaceableEntities) do
		if !v.NoDungeon then
			self.classType:AddChoice(v.Name,i)
		end
	end
	self.classType.OnSelect = function(slf,ind,val,data)
		self.itemClassID = data
		self:SetItemType(data)
	end
	local placing = false
	local lbl = self.form:Help("Click anywhere to place this item")
	local Close = self.form:Button("Close Dungeon Master")
	Close.DoClick = function() self:Close() end

	timer.Simple(0.1,function()

		self:SetTall(self.form:GetTall()+30)
		self:SetPos(ScrW()-self:GetWide(),0)
	end)
end
function PANEL:Close()
	if CommandFunc == DungeonClick then CommandFunc = nil end
	dungeonForm = nil
	self:Remove() 
end
function PANEL:GrabItemInfo()
	local t = {}
	if self.GrabFunc then
		t = self.GrabFunc()
	end
	return t
	
	
end
function PANEL:SetItemType(id)
	for i,v in pairs(self.form.Items) do
		if v.Right && v.Right.ShouldRemove || v.Left && v.Left.ShouldRemove then
			if v.Left && v.Left.ShouldRemove then
				self.form.Items[i].Left:Remove()
				
				if v.Right then
					self.form.Items[i].Right:Remove()
				end
				self.form.Items[i] = nil
			end
			if v.Right && v.Right.ShouldRemove then
				self.form.Items[i].Right:Remove()
				
				if v.Left then
					self.form.Items[i].Left:Remove()
				end
				self.form.Items[i] = nil
			end
		end
		
	end
	
	local tbl = PlaceableEntities[id]
	local propertyList = {}
	for i,v in pairs(tbl.Properties) do
		propertyList[v.VarName] = {v.VarMenu(self.form),i}
	end
	

	
	
	self.form:PerformLayout()
	self.GrabFunc = function() local t = {} for i,v in pairs(propertyList) do t[i] = tbl.Properties[v[2]].VarRetrieve(v[1]) end return t end

	timer.Simple(0.1,function()
		
		self:SetTall(self.form:GetTall()+30)
		self:SetPos(ScrW()-self:GetWide(),0)
	end)
end
vgui.Register("DungeonSetup",PANEL,"DFrame")


local PANEL = {} 
function PANEL:Init()
	self:SetSize(260,200)
	self:SetTitle("Area Editor")
	self:ShowCloseButton(false)
	self.form = vgui.Create("DForm",self)
	self.form:SetName("Area Editor")
	self.form:SetPos(5,25)
	self.form:SetWide(250)
	self.setupName = self.form:MultiChoice("Area Name")
	self.setupName:SetEditable(false)
	for i,v in pairs(Areas) do
		self.setupName:AddChoice(v.Name,i)
	end	
	self.areaID = 0
	self.setupName.OnSelect = function(slf,ind,val,data) self.areaID = data end
	
	self.itemClassID = -1
	self.classType = self.form:MultiChoice("Item Class") 
	self.classType:SetEditable(false)
	for i,v in pairs(PlaceableEntities) do
		if !v.NoArea then
			self.classType:AddChoice(v.Name,i)
		end
	end
	self.classType.OnSelect = function(slf,ind,val,data)
		self.itemClassID = data
		self:SetItemType(data)
	end
	local placing = false
	local lbl = self.form:Help("Click anywhere to place this item")
	local Close = self.form:Button("Close Area Editor")
	Close.DoClick = function() self:Close() end

	timer.Simple(0.1,function()

		self:SetTall(self.form:GetTall()+30)
		self:SetPos(ScrW()-self:GetWide(),0)
	end)
end
function PANEL:Close()
	if CommandFunc == DungeonClick then CommandFunc = nil end
	areaForm = nil
	self:Remove() 
end
function PANEL:GrabItemInfo()
	local t = {}
	if self.GrabFunc then
		t = self.GrabFunc()
	end
	return t
	
	
end

function PANEL:SetItemType(id)
	for i,v in pairs(self.form.Items) do
		if v.Right && v.Right.ShouldRemove || v.Left && v.Left.ShouldRemove then
			if v.Left && v.Left.ShouldRemove then
				self.form.Items[i].Left:Remove()
				
				if v.Right then
					self.form.Items[i].Right:Remove()
				end
				self.form.Items[i] = nil
			end
			if v.Right && v.Right.ShouldRemove then
				self.form.Items[i].Right:Remove()
				
				if v.Left then
					self.form.Items[i].Left:Remove()
				end
				self.form.Items[i] = nil
			end
		end
		
	end
	
	local tbl = PlaceableEntities[id]
	local propertyList = {}
	for i,v in pairs(tbl.Properties) do
		propertyList[v.VarName] = {v.VarMenu(self.form),i}
	end


	
	
	self.form:PerformLayout()
	self.GrabFunc = function() local t = {} for i,v in pairs(propertyList) do t[i] = tbl.Properties[v[2]].VarRetrieve(v[1]) end return t end
	timer.Simple(0.1,function()

		self:SetTall(self.form:GetTall()+30)
		self:SetPos(ScrW()-self:GetWide(),0)
	end)
end
vgui.Register("AreaSetup",PANEL,"DFrame")



local PANEL = {} 
function PANEL:Init()
	self:SetSize(260,200)
	self:SetTitle("Painter Options")
	self:ShowCloseButton(false)
	self.form = vgui.Create("DForm",self)
	self.form:SetName("Painter Options")
	self.form:SetPos(5,25)
	self.form:SetWide(250)
	self.setupName = self.form:MultiChoice("Area Name")
	self.setupName:SetEditable(false)
	for i,v in pairs(Areas) do
		self.setupName:AddChoice(v.Name,i)
	end	
	self.areaID = 0
	self.setupName.OnSelect = function(slf,ind,val,data) self.areaID = data end
	
	local hp = self.form:MultiChoice( "Resource Type" )
	hp:SetEditable(false)
	for i,v in pairs(harvest.GetResourceList()) do
		hp:AddChoice(v.Name,v.ResourceID)
	end
	hp.OnSelect = function(s,ind,val) self.SelectedResource = val end
	local hp = self.form:NumSlider( "Brush Size", nil, 64, 1024, 0 )
	hp.OnValueChanged = function(slf,val) paintRad = val end
	
	
	local hp = self.form:NumSlider( "Flow Rate", nil, 1, 10, 0 )
	hp.OnValueChanged = function(slf,val) timer.Create("g_TreeFlow",1/val,0,PainterTick) end
	
	local lbl = self.form:Help("Click and drag to paint resources onto the map.")
	local Close = self.form:Button("Close Area Editor")
	Close.DoClick = function() self:Close() end

	timer.Simple(0.1,function()

		self:SetTall(self.form:GetTall()+30)
		self:SetPos(ScrW()-self:GetWide(),0)
		TreePainting = true
	end)
	
end
function PANEL:GetTreeType()
	return self.SelectedResource
	
end
function PANEL:Close()
	treeForm = nil
	self:Remove()
	TreePainting = false	
end
vgui.Register("TreePaintOptions",PANEL,"DFrame")

local Nodes = {}

local Alpha = 250
local ColNORMAL = Color(255, 255, 255, Alpha)
local ColNORTH = Color(255, 255, 0, Alpha)
local ColSOUTH = Color(255, 0, 0, Alpha)
local ColEAST = Color(0, 255, 0, Alpha)
local ColWEST = Color(0, 0, 255, Alpha)
NORTH = 1
SOUTH = 2
EAST = 3
WEST = 4

local function DrawNodeLines(Table)
	for k,v in pairs(Table) do
		if(v) then
			for k2,v2 in pairs(v.LinkDir) do
				local Col
				if(k2 == NORTH) then
					Col = ColNORTH
				elseif(k2 == SOUTH) then
					Col = ColSOUTH
				elseif(k2 == EAST) then
					Col = ColEAST
				elseif(k2 == WEST) then
					Col = ColWEST
				end
				render.DrawBeam(v.Pos, v.Pos + (v2.Pos - v.Pos) * 0.3, 4, 0.25, 0.75, Col)
			end
			render.DrawBeam(v.Pos, v.Pos + (v.Normal * 13), 4, 0.25, 0.75, ColNORMAL)
		end
	end
end

local Mat = Material("effects/laser_tracer")



function LoadNodeGraph( handler, id, encoded, decoded )
	
	Nodes = decoded
	hook.Add("RenderScreenspaceEffects", "NavRenderScreenspaceEffects", function()
		
		render.SetMaterial(Mat)
		cam.Start3D(EyePos(), EyeAngles())
			DrawNodeLines(Nodes)
		cam.End3D()
	end)
end
datastream.Hook("GetNodeGraph",LoadNodeGraph)

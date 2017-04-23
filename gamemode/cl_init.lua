


include("shared.lua")

include("libraries/client.lua")


include("client/cl_startscreen.lua")
include("client/cl_usermessages.lua")
include("client/cl_camera.lua")
--include("client/cl_environment.lua")

include("menus/cl_character.lua")
include("menus/cl_inventory.lua")
include("menus/cl_chathud.lua")
include("menus/cl_npcstore.lua")
include("menus/cl_party.lua")
include("menus/cl_playerinfo.lua")
include("menus/cl_progressbar.lua")
include("menus/cl_lootscreen.lua")
include("menus/cl_chatbox.lua")
include("menus/cl_bindbar.lua")
include("menus/cl_skillbook.lua")
include("menus/cl_classmenu.lua")
include("client/cl_hud.lua")

include("vgui/DraggableIcon.lua")
include("vgui/elements/DRadioButton.lua")





hook.Add("InitPostEntity","GetLocal",
	function()
		if ValidEntity(LocalPlayer()) then
			Me = LocalPlayer()
			hook.Call("FullyLoaded",GAMEMODE)
		end
	end
)

skillColorUse = {}
skillColorUse[1] = function(skillName) if skills.Get(skillName).ManaCost && Me:GetMana() < skills.Get(skillName).ManaCost then return false end return true end
skillColorUse[2] = function(skillName) if !skills.Get(skillName).CanUse then return true end return skills.Get(skillName).CanUse(Me) end
skillColorUse[3] = function(skillName) if !skillCharges[skillName] then return true end return skillCharges[skillName] < RealTime() end

CharID				= -1
LockMouse 			= false

skillCharges 		= {}
Inventory 			= {}
mySkills			= {}
myAttributes		= {}
myEquipped			= {}
dragIconInfo		= {} 

Stamina				= 1
MaxStamina			= 1
XP					= 0
Level				= 1
Money				= 10
LastDeathTime		= 0
InProgress			= false

Quests				= {}
AttributePoints		= 0

CurrentChat			= 0
ChattingNPC 		= NULL

leftDown 			= false
rightDown 			= false

mandala				= ""
activeSlot 			= ""

FightingStance		= false

ClassTree 			= "None"
Class 				= "None"

GuildName			= "N/A"
CharacterName		= "Loading..."
CurrentMusicType	= "Explore"







function GM:Initialize()

	self.BaseClass:Initialize()
	gui.EnableScreenClicker(true)
end


function ChangeSong(last)
	local rand = table.Random(MusicList[CurrentMusicType])
	local num = 1
	if table.getn(MusicList[CurrentMusicType]) > 1 then
		while (rand == last && num < 100) do --find a new song within 100 tries (should do it in like 3 or 4)
			rand = table.Random(MusicList[CurrentMusicType])
			num = num + 1
		end
	end
	timer.Simple(0.1,function()
		timer.Create("_songChange",SoundDuration(rand),1,ChangeSong,rand)
	end)
	MusicObject = CreateSound(Me,rand)
	MusicObject:PlayEx(0.1,100)
end

function ChangeMusicTo(musicType)
	CurrentMusicType = musicType
	timer.Destroy("_songChange")
	local rand = table.Random(MusicList[CurrentMusicType])
	timer.Simple(0.1,function()
			timer.Create("_songChange",SoundDuration(rand),1,ChangeSong,rand)
		end)
	MusicObject = CreateSound(Me,rand)
	MusicObject:PlayEx(0.1,100)
end

function GM:OnEntityCreated(ent)


	if ValidEntity(ent) && ent:GetClass() == "class C_ClientRagdoll" then
		
		timer.Simple(5, function() if ent:IsValid() then ent:Remove() end end)
	end
	
end

function GM:CharacterLoaded()
	timer.Simple(0.1,function()
		local rand = table.Random(MusicList[CurrentMusicType])
		timer.Create("_songChange",SoundDuration(rand),1,ChangeSong,rand)
		MusicObject = CreateSound(Me,rand)
		MusicObject:PlayEx(0.1,100)
	end)
end


function ActivateSkill(skill)
	--if !FightingStance then return end
	if skillCharges[item] and skillCharges[item] > RealTime() then return end
	mandala = skills.Get(skill).Mandala or ""
	activeSlot = skill
	
end


local function DeactivateSkill()
	mandala = nil
	activeSlot = ""
end



function SwitchStance(pl,bind,pressed)
	if string.find(bind,"+menu") && !rightDown then
		FightingStance = !FightingStance
		gui.EnableScreenClicker(!FightingStance) --turn off mouse in combat
		if !FightingStance then DeactivateSkill() end
	end
end
hook.Add("PlayerBindPress","SwitchStance",SwitchStance)

function GM:PlayerDamagedEntity(damaged,amt)

	self:AddDamageNotifier(damaged,amt)

end
function GM:PostPlayerDraw() --Called in an ENT.Draw

	if mandala && string.len(mandala) > 2 then

		local t 	= {}
		t.start 	= CameraPos
		t.endpos 	= t.start + Me:GetAimVector() * 8192


		t 			= util.TraceLine(t)
		local vec 	= t.HitPos
		
		local dist = t.HitPos:Distance(Me:GetPos())
		
		--just for visual effect
		if dist > 500 then		
			
			local normed = (vec - Me:GetPos()):Normalize()
			vec =  Me:GetPos() + (normed * 500)
			t = {}
			t.start = vec + Vector(0,0,1000)
			t.endpos = vec - Vector(0,0,2000)
			t = util.TraceLine(t)
			vec = t.HitPos
			
		end
		
		
		cam.Start3D2D(vec+t.HitNormal*5, t.HitNormal:Angle() + Angle(90,0,0),0.5)
			surface.SetDrawColor(255,255,255,255)
			surface.SetTexture(surface.GetTextureID(mandala))
			surface.DrawTexturedRect(-128,-128,256,256)
		cam.End3D2D()
	
		
	 --[[TODO: Learn meshes and make the mandala fit snug to the terrain
	
		local mat = Matrix();
		local scale = 64
		local centerPos = vec+t.HitNormal*Vector(0,0,-5)
		mat:Translate( centerPos );
		

		
		mat:Rotate( t.Normal:Angle() + Angle(0,0,0) );
		mat:Scale( Vector( 1, 1, 1 ) * scale );

	 
		render.SetMaterial( mandala );
		

		cam.PushModelMatrix( mat );
	 
			mesh.Begin( MATERIAL_QUADS, 25 );
			--mesh.Begin( MATERIAL_LINE_LOOP, 3 );
				local t  = {}
				t.start = centerPos
				t.endpos = t.start + Vector(0,0,2000)
				t = util.TraceLine(t)
				local topCenter = t.HitPos
	 
				for x = -2,2 do
					for y=-2,2 do
						
						local t = {}
						t.start = topCenter+Vector(x*scale,y*scale,0)
						t.endpos = t.start - Vector(0,0,4000)
						t = util.TraceLine(t)
						local localVec = WorldToLocal(t.HitPos,Angle(0,0,0),centerPos,Angle(0,0,0))/scale
						mesh.Position( localVec );
						mesh.Normal( t.Normal );
						mesh.TexCoord( 0, 0, 0 );
						mesh.Color( 255, 0, 0, 255 );
						mesh.AdvanceVertex();
						
						local t = {}
						t.start = topCenter+Vector(x*scale,y*scale+1,0)
						t.endpos = t.start - Vector(0,0,4000)
						t = util.TraceLine(t)
						local localVec = WorldToLocal(t.HitPos,Angle(0,0,0),centerPos,Angle(0,0,0))/scale
						mesh.Position( localVec );
						mesh.Normal( t.HitNormal );
						mesh.TexCoord( 0, 0, 0 );
						mesh.Color( 255, 0, 0, 255 );
						mesh.AdvanceVertex();
						
						local t = {}
						t.start = topCenter+Vector(x*scale+1,y*scale+1,0)
						t.endpos = t.start - Vector(0,0,4000)
						t = util.TraceLine(t)
						local localVec = WorldToLocal(t.HitPos,Angle(0,0,0),centerPos,Angle(0,0,0))/scale
						mesh.Position( localVec );
						mesh.Normal( t.HitNormal );
						mesh.TexCoord( 0, 0, 0 );
						mesh.Color( 255, 0, 0, 255 );
						mesh.AdvanceVertex();
						
						local t = {}
						t.start = topCenter+Vector(x*scale+1,y*scale,0)
						t.endpos = t.start - Vector(0,0,4000)
						t = util.TraceLine(t)
						local localVec = WorldToLocal(t.HitPos,Angle(0,0,0),centerPos,Angle(0,0,0))/scale
						mesh.Position( localVec );
						mesh.Normal( t.HitNormal );
						mesh.TexCoord( 0, 0, 0 );
						mesh.Color( 255, 0, 0, 255 );
						if x != 2 && y != 2 then
							mesh.AdvanceVertex();
						end
			 
					end
				end
	 
			mesh.End();
	 
		cam.PopModelMatrix();]]
	end
end


local tryIt = false
local lastAimVec = Vector(0,0,0)
local testEnt
function GM:Think() --should this be done here?
	local tempLeftDown = input.IsMouseDown(MOUSE_LEFT)
	--do this here cause its really the only place it can be done and needs to use the function rather than GM.GUIMouseReleased
	if !input.IsMouseDown(MOUSE_RIGHT) && rightDown then
		rightDown = false
		if !FightingStance then
			gui.EnableScreenClicker(true)
			RestoreCursorPosition()
			if lastAimVec != Me:GetAimVector() && !rightDown then --you moved the view around, no right click funcs
				tryIt = false
			end
			if tryIt then
				
				hook.Call("NewClickedEntity",GAMEMODE,MOUSE_RIGHT,tryIt)
			end
		end
		
	elseif !tempLeftDown && dragIconInfo.lastPan then
		table.Empty(dragIconInfo)
	end
	if !tempLeftDown && leftDown then
		leftDown = false
	end

end

function GM:NewClickedEntity( mc,t )
	if !t || t.Entity == Me || !ValidEntity(t.Entity) && t.HitNonWorld then return end
	if !t.Hit then return end
	
	local func = GetClickFunction(t)
	
	
	if mc == MOUSE_RIGHT && func then
		local menu = DermaMenu()
		func(menu,Me,t.Entity)
		EditorPress(t,menu)
		menu:Open()
	elseif mc == MOUSE_LEFT then
		EditorPress(t,nil)
	end
	
	return true 

end


function GM:GUIMousePressed( mc )
	if !GetAccountLoaded() then return end
	local t 	= {}
	t.start 	= CameraPos
	t.endpos 	= t.start + Me:GetCursorAimVector() * 30000


	tryIt = util.TraceLine(t)
	


	if mc == MOUSE_LEFT then

		leftDown = true
	elseif mc == MOUSE_RIGHT then

		
		rightDown = true
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
		lastAimVec = Me:GetAimVector()
	end

end




function GM:GUIMouseReleased( mc )

	if mc == MOUSE_LEFT then
		if tryIt then
			hook.Call("NewClickedEntity",GAMEMODE,MOUSE_LEFT,tryIt)
		end
	end
end

function GM:PlayerBindPress(ply,bind,pressed)
	
	if string.find(bind, "+attack2") then --this takes precedence over +attack because +attack is always found in +attack2
	
			RunConsoleCommand("blockattacks")
			
	elseif string.find(bind, "+attack") then
		if activeSlot != "" then
			RunConsoleCommand("useSkill",activeSlot)
			DeactivateSkill()
		else
			RunConsoleCommand("useWeapon")
		end

	elseif string.find(bind, "+jump") && InProgress then
		
		RunConsoleCommand("cancelProgress")

	end
end

function GM:PlayerDeath(pl)
	--MusicObject:Stop()
	surface.PlaySound("darkland/rpg/actions/death.mp3")
	HideHUD()
	timer.Simple(DEATH_TIME,function()
	DeathButton = vgui.Create("DButton")
	DeathButton:SetSize(400,100)
	DeathButton:SetText("Click here to respawn at the nearest Crystal of Life")
	DeathButton:SetPos(ScrW()*0.5-DeathButton:GetWide()*0.5,ScrH()-DeathButton:GetTall()-50)
	DeathButton.DoClick = function() RunConsoleCommand("respawnCharacter") end
	end)
end

function GM:PlayerSpawn()
	if ValidPanel(DeathButton) then
		DeathButton:Remove()
	end
	ShowHUD()

end

function GM:KeyRelease(ply,key)

end

function GM:OnLevelUp()

	surface.PlaySound("darkland/rpg/actions/levelup.mp3")

end


function GM:UpdateChatNode()

end

function GM:BeginChatting(ent)


end
function GM:StopChatting(ent)
	ChattingNPC = NULL
	CurrentChat = 0
	
end

--Called when right clicking a DraggableIcon
function GM:RightClickedIcon(p)
	local item = p.item
	local menu = DermaMenu()
	local iTab = items.Get(item.BaseType)
	if iTab.Menu then
		iTab.Menu(menu)
	end
	if IsTrading() then
		menu:AddOption("Add to Trade",function() RunConsoleCommand("addTradeItem",p.item.ID) end)
	end
	if iTab.EquipAt then
		menu:AddOption("Equip Item",function() RunConsoleCommand("equipItem",iTab.EquipAt,p.item.ID) end)
	end
	menu:Open()
end
	

function pme(pl)

	print("----------------------")
	print(" Vector("..pl:GetPos().x..","..pl:GetPos().y..","..pl:GetPos().z..") ")
	print(" Angle("..pl:GetAngles().pitch..","..pl:GetAngles().yaw..","..pl:GetAngles().roll..") ")
	print("cam Vector("..CameraPos.x..","..CameraPos.y..","..CameraPos.z..") ")
	
	print("----------------------")

end
concommand.Add("pme",pme)


function GetClickFunction(trace)
	local ent = trace.Entity
	if !ent:IsValid() then return end
	if ent:IsNPC() then
		return ClickMenus[ent:GetName()]
	elseif ent:IsPlayer() then
		return ClickMenus["~player"]
	elseif ent:IsDoor() then
		return ClickMenus["~door"]
	end
	return ClickMenus[ent:GetClass()] || ClickMenus["~other"]
end



local meta = FindMetaTable("Player")

function meta:HasItem(item)

	return Inventory[item.ID]

end

function meta:GetEquip(spot)

	return myEquipped[spot]
	
end

function meta:GetStrength()

	return myAttributes["Strength"]
end

function meta:GetAgility()

	return myAttributes["Agility"]
	
end

function meta:GetEquip(spot)

	return myEquipped[spot]
	
end

function meta:GetMoney()
	return Money
end


local AccountLoaded	= false
function SetAccountLoaded(b)
	AccountLoaded = b
	Me.RPGLoaded = b
end
function GetAccountLoaded()
	return Me.RPGLoaded
end
local IsEditing

function SetEditing(b)
	IsEditing = b
	Me.IsEditing = b
end
function GetIsEditing()
	return Me.IsEditing
end

function GetNeededXP(lvl)
	return 1600 * lvl
end




function GetLODDistance(LODLevel)

	return LODLevel * 4000


end

cachedTextures = {}
local oldSurf = surface.GetTextureID
function surface.GetTextureID(str)
	if !str then return -1 end
	if !cachedTextures[str] && oldSurf != surface.GetTextureID then
		cachedTextures[str] = oldSurf(str)
	end
	return cachedTextures[str]
end
	

















include("SDK/client.lua")
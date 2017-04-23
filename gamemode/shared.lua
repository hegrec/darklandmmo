GM.Name 	= "The Darklands"
GM.Author 	= "Darkspider"
GM.Email 	= "hegrec@gmail.com"
GM.Website 	= "www.darklandservers.com"



REACH_DIST 				= 150
MAX_CHARACTERS 			= 3
STAND_DIST 				= 50
MAX_LEVEL				= 40
CHOOSE_CLASS			= 10
CLASS_UP				= 30
MAX_SKILLS				= 5
SKILL_CHOOSE_BOOST 		= 5
ATTRIBUTE_START 		= 5
BLOCK_TIME 				= 0.5
BLOCK_COOLDOWN 			= 5
STAT_REFRESH			= 1
LOOT_GRACE				= 30
MAX_WANDER_DIST			= 512
BASE_MONSTER_CHASE      = 250
DEATH_TIME				= 10
LEVELUP_POINTS			= 3
MAX_PHYSICAL_RESOURCES = 1
MAX_DIST_RENDER = 1000

STARTSPAWN = {Vector(5180,-10004,1102) ,Angle(0,-87.819923400879,0)}


DAMAGE_DISP_LEN = 0.5
SMALLEST_DAMAGE_FONT = 94
LARGEST_DAMAGE_FONT = 100


MusicList = {}
MusicList["Explore"] = {"darkland/rpg/music/Explore/atmosphere_01.mp3","darkland/rpg/music/Explore/atmosphere_02.mp3",
"darkland/rpg/music/Explore/atmosphere_03.mp3","darkland/rpg/music/Explore/atmosphere_04.mp3",
"darkland/rpg/music/Explore/atmosphere_05.mp3"}


MusicList["Battle"] = {"darkland/rpg/music/Battle/battle_01.mp3","darkland/rpg/music/Battle/battle_02.mp3"}
MusicList["Dungeon"] = {"darkland/rpg/music/Dungeon/Dungeon_01_v2.mp3","darkland/rpg/music/Dungeon/dungeon_02.mp3"}

MusicList["Town"] = {"darkland/rpg/music/Public/Town_01.mp3","darkland/rpg/music/Public/Town_02.mp3",
"darkland/rpg/music/Public/Town_03.mp3","darkland/rpg/music/Public/Town_04.mp3",
"darkland/rpg/music/Public/Town_05.mp3"}



EquipSpots = {}
EquipSpots["Helmet"] = {}
EquipSpots["Cuirass"] = {}
EquipSpots["Weapon"] = {}
EquipSpots["Shield"] = {}
EquipSpots["Leggings"] = {}
EquipSpots["Boots"] = {}
EquipSpots["Amulet"] = {}
EquipSpots["Ring"] = {}



SkillTypes = {"Melee","Ranged","Magic","Enhancements","Misc"}

Attributes = {}
Attributes["Endurance"] = {
Icon = "darkland/rpg/attributes/strength"
}
Attributes["Strength"] = {
Icon = "darkland/rpg/attributes/strength"
}
Attributes["Intelligence"] = {
Icon = "darkland/rpg/attributes/strength"
}
Attributes["Agility"] = {
Icon = "darkland/rpg/attributes/strength"
}

--weapon types
WEAPON_NONE = 0
WEAPON_BLADE = 1
WEAPON_BLUNT = 2
WEAPON_BOW = 3
WEAPON_STAFF = 4


ARMOR_NONE = 0
ARMOR_LIGHT = 1
ARMOR_HEAVY = 2
ARMOR_ROBE = 3


WeaponTranslate = {}
WeaponTranslate[WEAPON_BLADE] = "Blade"
WeaponTranslate[WEAPON_BLUNT] = "Blunt"
WeaponTranslate[WEAPON_BOW] = "Archery"
WeaponTranslate[WEAPON_STAFF] = "Divinity"

--decide when an npc should attack
--BE_WHEN_ATTACKED = 1 --they should always go after you if you attack...
BE_NORMAL = 1 --doesn't really do anything, but always specify this or another one anyways
BE_LOWERLEVEL = 2
BE_ALWAYS = 3

DMG_BLADE 		= 1
DMG_BLUNT 		= 2
DMG_FIRE 		= 3
DMG_ICE 		= 4
DMG_HOLY		= 5
DMG_UNHOLY		= 6
DMG_ARROW		= 7
DMG_ELECTRIC	= 8



HERB_RESTORE = 1
HERB_MANA = 2
HERB_ENERGY = 3
HERB_STRENGTH = 4


INTERACTABLE_DOOR = 1



DamageLookup = {
WEAPON_BLADE = function(pl) return pl:GetSkillLevel("Blade") end,
WEAPON_BLUNT = function(pl) return pl:GetSkillLevel("Blunt") end,
WEAPON_BOW = function(pl) return pl:GetSkillLevel("Archery") end
}


AREA_TOWN = 1
AREA_DUNGEON = 2 
AREA_PUBLIC = 3

Areas = {
	{Name = "Glaetin Forest", Type = AREA_PUBLIC},
	{Name = "Glaetin", Type = AREA_TOWN},
	{Name = "West Haven", Type = AREA_TOWN},
	{Name = "Uruqart Caverns", Type = AREA_DUNGEON},
	{Name = "Cold Mine", Type = AREA_DUNGEON,Instanced = true}
}


VAR_NUMBER = "1"
VAR_STRING = "2"
VAR_BOOL = "3"
VAR_VECTOR = "4"
VAR_ANGLE = "5"

PlaceableEntities = {}
PlaceableEntities[1] = {
	Name = "Generic Monster",
	ClassName = "npc_base_monster",
	Properties = {
		{
			VarName = "Health",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				local hp = frm:NumSlider( "Health", nil, 20, 20000, 0 )
				hp.ShouldRemove = true
				return hp
			end,
			VarRetrieve = function(pnl)
				return pnl:GetValue()
			end
		},
		{
			VarName = "ClassID",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				
				local hp = frm:MultiChoice( "Monster Class" )
				hp.ShouldRemove = true
				hp:SetEditable(false)
				for i,v in pairs(NPCMonsters) do
					hp:AddChoice(v.Name,i)
				end
				hp.OnSelect = function(slf,ind,val,data) hp.classID = data end
				return hp
			end,
			VarRetrieve = function(pnl)
				return pnl.classID
			end
		}
	},
	NoArea = true
}
PlaceableEntities[2] = {
	Name = "Generic Resource",
	ClassName = "harvest_resource",
	Properties = {
		{
			VarName = "ResType",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				
				local hp = frm:MultiChoice( "Resource Type" )
				hp.ShouldRemove = true
				hp:SetEditable(false)
				for i,v in pairs(harvest.GetResourceList()) do
					hp:AddChoice(v.Name,i)
				end
				hp.OnSelect = function(s,ind,val,data) hp.SelectedResource = val end
				return hp
			end,
			VarRetrieve = function(pnl)
				return pnl.SelectedResource or nil
			end
		}
	}
}
PlaceableEntities[3] = {
	Name = "Door Exit",
	ClassName = "door_exit_spawn",
	Properties = {
		{
			VarName = "LinkedDoor",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				
				local ctrl = frm:MultiChoice( "Linked Door" )
				local dist = math.huge
				local closestDoor
				for i,v in pairs(ents.GetAll()) do
					if v:IsDoor() then
						if v:GetPos():Distance(Me:GetPos()) < dist then
							closestDoor = v:GetName()
							dist = v:GetPos():Distance(Me:GetPos())
						end
						ctrl:AddChoice( v:GetName() )
					end
				end
				if closestDoor then
					ctrl:ChooseOption(closestDoor)
				end
				ctrl.ShouldRemove = true
				return ctrl
			end,
			VarRetrieve = function(pnl)
				return pnl.TextEntry:GetValue()
			end
		}
	}
}
PlaceableEntities[4] = {
	Name = "Important NPC",
	ClassName = "npc_important",
	Properties = {
		{
			VarName = "StoredName",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				
				local ctrl = frm:MultiChoice( "Which NPC?" )
				for i,v in pairs(MainNPCList) do
					ctrl:AddChoice( i )
				end
				ctrl:SetEditable(false)
				ctrl.ShouldRemove = true
				return ctrl
			end,
			VarRetrieve = function(pnl)
				return pnl.TextEntry:GetValue()
			end
		}
	},
	NoDungeon = true
}
PlaceableEntities[5] = {
	Name = "AI Nodegraph",
	ClassName = "npc_nodegraph",
	Properties = {
		{
			VarName = "GridWidth",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				local hp = frm:NumSlider( "Grid Width (Higher=Faster)", nil, 32, 1024, 0 )
				hp.ShouldRemove = true
				return hp
			end,
			VarRetrieve = function(pnl)
				return pnl:GetValue()
			end
		},
		{
			VarName = "MaxDistance",
			VarType = VAR_NUMBER,
			VarMenu = function(frm)
				local hp = frm:NumSlider( "Max Distance", nil, -1, 8196, 0 )
				hp.ShouldRemove = true
				return hp
			end,
			VarRetrieve = function(pnl)
				return pnl:GetValue()
			end
		}
	}
}
PlaceableEntities[6] = {
	Name = "Generic Citizen NPC",
	ClassName = "npc_generic_citizen",
	Properties = {
		{
			VarName = "Race",
			VarType = VAR_STRING,
			VarMenu = function(frm)
				local ctrl = frm:MultiChoice( "Race" )
				for i,v in pairs(Races) do
					ctrl:AddChoice( i )
				end
				ctrl:SetEditable(false)
				ctrl.ShouldRemove = true
				return ctrl
			end,
			VarRetrieve = function(pnl)
				return pnl.TextEntry:GetValue()
			end
		},
		{
			VarName = "Gender",
			VarType = VAR_STRING,
			VarMenu = function(frm)
				local ctrl = frm:MultiChoice( "Gender" )
				ctrl:AddChoice( "Male" )
				ctrl:AddChoice( "Female" )
				ctrl:SetEditable(false)
				ctrl.ShouldRemove = true
				return ctrl
			end,
			VarRetrieve = function(pnl)
				return pnl.TextEntry:GetValue()
			end
		}
	}
}	



Dialog 			= {}
Replies 		= {}

NPCMonsters = {}
NPC_SPIDER = 1
NPCMonsters[NPC_SPIDER] = {
	Name = "Giant Spider",
	Model = "models/antlion.mdl",
	Behavior = BE_NORMAL,
	Description = "A spider that has evolved its size to be extremely large.",
	Level = {3,7}, --min,max of randomly chosen level
	ChaseDist = 650, --distance to where the npc will start chasing you
	BaseHealth = 50, 
	LeaveDist = 1500, --distance the NPC will stop chasing you
	AttackList = 
	{ --store all attacks in here

	--this first one could be say standard attack
		{
			Sequence = {"attack1","attack2","attack3","attack4","attack5","attack6"}, --schedule to do (animations and stuff)
			EffectFunc = nil,	--no custom effects if so, takes npc and ply
			Probability = function(npc) return 20 end, --90%
			BaseDamage = {3,5}, --low,high base damage amount
			DamageType = {DMG_BLADE} --damage type, can have multiple
		},
		--this one could pack more punch but happen less often
		{
			Sequence = {"attack1","attack2","attack3","attack4","attack5","attack6"}, --schedule to do (animations and stuff)
			EffectFunc = nil,
			Probability = function(npc) return npc:GetLevel() end, --as its level increases, it is more likely to do this attack
			BaseDamage = {9,13}, --low,high base damage amount
			DamageType = {DMG_FIRE} --damage type, can have multiple
		}
	}
}

NPCMonsters[2] = {						
	Name = "Black Rat",
	Model = "models/vortigaunt.mdl",
	Description = "A disgusting black rat. May carry diseases.",
	Level = {6,11}, --min,max of randomly chosen level
	ChaseDist = 450, --distance to where the npc will start chasing you
	BaseHealth = 50, 
	LeaveDist = 1500, --distance the NPC will stop chasing you
	AttackList = 
	{ --store all attacks in here

	--this first one could be say standard attack
		{
			Sequence = {"attack1","attack2","attack3","attack4","attack5","attack6"}, --schedule to do (animations and stuff)
			EffectFunc = nil,	--no custom effects if so, takes npc and ply
			Probability = function(npc) return 20 end, --90%
			BaseDamage = {3,5}, --low,high base damage amount
			DamageType = {DMG_BLADE} --damage type, can have multiple
		},
		--this one could pack more punch but happen less often
		{
			Sequence = {"attack1","attack2","attack3","attack4","attack5","attack6"}, --schedule to do (animations and stuff)
			EffectFunc = nil,
			Probability = function(npc) return npc:GetLevel() end, --as its level increases, it is more likely to do this attack
			BaseDamage = {9,13}, --low,high base damage amount
			DamageType = {DMG_FIRE} --damage type, can have multiple
		}
	}
}

GenericNPCModels = {
"models/humans/group01/Male_01.mdl",
"models/humans/group01/Male_02.mdl",
"models/humans/group01/Male_03.mdl",
"models/humans/group01/Male_04.mdl",
"models/humans/group01/Male_05.mdl",
"models/humans/group01/Male_06.mdl",
"models/humans/group01/Male_07.mdl",
"models/humans/group01/Female_01.mdl",
"models/humans/group01/Female_02.mdl",
"models/humans/group01/Female_03.mdl",
"models/humans/group01/Female_04.mdl",
"models/humans/group01/Female_06.mdl",
"models/humans/group01/Female_07.mdl"
}
	

ItemVarList = {}

VAR_DEGRADE = 1
ItemVarList[VAR_DEGRADE] = "Durability"



Races = {}

Races["Elf"] = {}
Races["Elf"].FemaleModel = "models/player/mossman.mdl";
Races["Elf"].FemaleIdle = "LineIdle01"
Races["Elf"].MaleModel = "models/player/breen.mdl";
Races["Elf"].MaleIdle = "LineIdle03"
Races["Elf"].ClassTrees = {"Fighter","Mystic"}

Races["Orc"] = {}
Races["Orc"].FemaleModel = "models/player/Combine_Soldier.mdl";
Races["Orc"].FemaleIdle = "Idle1"
Races["Orc"].MaleModel = "models/player/Combine_Super_Soldier.mdl";
Races["Orc"].MaleIdle = "Idle1"
Races["Orc"].ClassTrees = {"Fighter","Mystic"}


Races["Human"] = {}
Races["Human"].FemaleModel = "models/player/alyx.mdl";
Races["Human"].FemaleIdle = "LineIdle01"
Races["Human"].MaleModel = "models/player/kleiner.mdl";
Races["Human"].MaleIdle = "LineIdle01"
Races["Human"].ClassTrees = {"Fighter","Mystic"}


Races["Dwarf"] = {}
Races["Dwarf"].FemaleModel = "models/vortigaunt.mdl";
Races["Dwarf"].FemaleIdle = "Idle01"
Races["Dwarf"].MaleModel = "models/stalker.mdl";
Races["Dwarf"].MaleIdle = "idle01"
Races["Dwarf"].ClassTrees = {"Craftsman"}



--NPC funcs
local meta = FindMetaTable("NPC")


function meta:GetName()
	return self:GetNWString("Name")
end



--Entity Funcs

meta = FindMetaTable("Entity")
function meta:HasLoot()
	return self:GetNWBool("lootable")
end
function meta:GetInstance()
	return self:GetNWInt("Instance")
end
function meta:GetInstanceName()
	return self:GetNWInt("InstanceName")
end
function meta:IsMonster()
	return self:GetClass() == "npc_base_monster"
end
function meta:IsDoor()
	return self:GetNWInt("Type") == INTERACTABLE_DOOR
end
function meta:EditableNPC()
	return self:GetClass() == "npc_important" || self:GetClass() == "npc_generic"
end
function meta:CanEdit()
	return self:EditableNPC() || self:IsDoor() || self:GetNWBool("CaveSetup")
end
function meta:CanInteractThroughInstances()
	return self:IsDoor()
end
function meta:GetName()
	if self:GetNWString("Name") == "" then return "Unnamed Entity - "..self:GetClass() end
	return self:GetNWString("Name")
end
function meta:GetTargetArea()
	return self:GetDTInt(0)
end
function meta:GetArea()
	return self:GetDTInt(1)
end
--[[
Used based on item type:

if it is an NPC, indexed by name
if a regular item, indexed by class

]]
ClickMenus = {}

ClickMenus["~player"] = function(menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Info",function() RunConsoleCommand("playerGetInfo",ent:EntIndex()) end)
		menu:AddOption("Trade",function() RunConsoleCommand("tradePlayer",ent:EntIndex()) end)
		menu:AddOption("Invite Party",function() RunConsoleCommand("invitePlayerToParty",ent:EntIndex()) end)
		--menu:AddOption("Invite Guild",function() RunConsoleCommand("invitePlayerGuild",ent:EntIndex()) end)
	end
end
ClickMenus["lootbag"] = function(menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Grab Loot",function() RunConsoleCommand("viewLoot",ent:EntIndex()) end)
	end
end
ClickMenus["~other"] = function(menu,pl,ent)
	if pl:CanReach(ent) then
	end
end
ClickMenus["~door"] = function(menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Use Door",function()		
		
			RunConsoleCommand("useDoor",ent:EntIndex())
		
		end)
	end
end
ClickMenus["harvest_plant"] = function(menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Harvest Bush",function() RunConsoleCommand("harvestBush",ent:EntIndex()) end)
	end
end
ClickMenus["smelter"] = function(menu,pl,ent)
	if pl:CanReach(ent) then
		menu:AddOption("Smelt Ore",function() RunConsoleCommand("smeltOre",ent:EntIndex()) end)
	end
end

--[[
Used based on item type:

if it is an NPC, indexed by name
if a regular item, indexed by class
]]
UseFuncs = {} 

UseFuncs["~chattingnpc"] = function(pl,ent) pl:ConCommand("talkto "..ent:EntIndex()) end
UseFuncs["~player"] = function(pl,ent) pl:ConCommand("playerGetInfo "..ent:EntIndex()) end
UseFuncs["lootbag"] = function(pl,ent) pl:ConCommand("viewLoot "..ent:EntIndex()) end
UseFuncs["~door"] = function(pl,ent)	pl:ConCommand("useDoor "..ent:EntIndex()) end
UseFuncs["harvest_plant"] = function(pl,ent) pl:ConCommand("harvestBush "..ent:EntIndex()) end
UseFuncs["smelter"] = function(pl,ent) pl:ConCommand("smeltOre "..ent:EntIndex()) end


if CLIENT then
	surface.CreateFont("Nyala", 18, 1200, true, false, "HudNameFont") 
end
HudEntList = {}
HudEntList["player"] = function(dist,ent)
	local p = (Vector(0,0,70)+ent:GetPos()):ToScreen()
	draw.SimpleTextOutlined(ent:CharacterName(),"HudNameFont",p.x,p.y,Color(226,204,55,255),1,1,1,Color(156,139,57,255))
	draw.RoundedBox(0,p.x-50,p.y-20,100,7,Color(0,0,0,255))
	draw.RoundedBox(0,p.x-49,p.y-19,98,5,Color(200,0,0,255))
	draw.RoundedBox(0,p.x-49,p.y-19,math.max(0,ent:Health()/ent:GetNWInt("maxHP")*98),5,Color(0,200,0,255))
end


meta = FindMetaTable("Player")

function meta:CharacterName()
	return self:GetNWString("CharName")
end
function meta:GetWeaponType()
	local weapon = self:GetEquip("Weapon")
	if !weapon then return WEAPON_NONE end
	if !items.Get(self:GetEquip("Weapon").BaseType) then return WEAPON_NONE end
	return items.Get(self:GetEquip("Weapon").BaseType).WeaponType 
end
function meta:GrabModel()

	local model = Races[self.Race].MaleModel
	if self.Gender == 0 then
		model = Races[self.Race].FemaleModel
	end
	return model
end
function meta:HasParty() --NWInt Party should be party leader's UserID
	return self:GetDTInt(0) != 0
end
function meta:GetParty()
	return self:GetDTInt(0)
end
function meta:IsPartyLeader()
	return self:GetDTInt(0) == self:UserID()
end
function meta:GetMana()
	return self:GetDTInt(1)
end
function meta:GetMaxHealth()

	return self:GetNWInt("maxHP")


end
function meta:GetMaxMana()

	return self:GetNWInt("MaxMana")

end


function meta:CanReach(ent,int)
	if int then
		return ent:GetPos():Distance(self:GetPos()) <= int && (self:GetInstance() == ent:GetInstance() || ent:CanInteractThroughInstances())
	end
	return ent:GetPos():Distance(self:GetPos()) <= REACH_DIST && (self:GetInstance() == ent:GetInstance() || ent:CanInteractThroughInstances())
end

function meta:HasGuild()
	return self:GetNWInt("GuildID") != 0
end
function meta:GetGuildID()
	return self:GetNWInt("GuildID")
end

GUILD_MEMBER = 0
GUILD_OFFICER = 1
GUILD_OWNER = 2

function meta:IsGuildOfficer()
	return self:GetNWInt("GuildRank") >= GUILD_OFFICER
end
function meta:IsGuildOwner()
	return self:GetNWInt("GuildRank") == GUILD_OWNER
end



--[[
FUNCTION RETURNS A SAVABLE STRING BASED ON TABLES STRUCTURED LIKE THIS:
{Name = 3,Name2 = 43}

Returns Name:3|Name2:43



LIMITS:
Name must not contain ':'

Used to load: Skills,Attributes,Inventory
]]
function table.DoSaveConvert(tbl)
	local t = {}

	for i,v in pairs(tbl) do
		table.insert(t,i..":"..v)
	end

	return table.concat(t,"|")

end


--[[
FUNCTION RETURNS A TABLE FROM A SAVED STRING THAT WAS STRUCTURED LIKE THIS:
Name:3|Name2:43


Returns {Name = 3,Name2 = 43}


ERRORS AND OUTCOMES:
Index no longer exists	-	Item is simply discarded and not put into the table


]]
function table.DoLoadConvert(str)

	local t = string.Explode("|",str)
	local tbl = {}
	for i,v in pairs(t) do
		local t 		= string.Explode(":",v)
		local name		= t[1]
		local amt		= tonumber(t[2])

		tbl[name] = amt
	end
	return tbl
end

function table.SameAsTable(tbl1,tbl2)
	for i,v in pairs(tbl1) do
		if type(v) == "table" then
			if type(tbl2[i]) == "table" then
				if !table.Compare(v,tbl2[i]) then return false end
			end
		else
			if v != tbl2[i] then return false end
		end
	end
	
	for i,v in pairs(tbl2) do
		if type(v) == "table" then
			if type(tbl1[i]) == "table" then
				if !table.Compare(v,tbl1[i]) then return false end
			end
		else
			if v != tbl1[i] then return false end
		end
	end
	return true
end

function GetPartyMembers(id)
	local t = {}
	for i,v in pairs(player.GetAll()) do
		if v:GetParty() == id then
			table.insert(t,v)
		end
	end
	return t
end

function XPPerLevel(lvl)

	return 1600 * lvl
	
end

TotalXPAtLevel = {}
TotalXPAtLevel[0] = 0
for i=1,MAX_LEVEL do
	for ii=1,i do
		TotalXPAtLevel[i] = TotalXPAtLevel[i] or 0
		TotalXPAtLevel[i] = TotalXPAtLevel[i] + XPPerLevel(ii)
	end
end

function FindNameMatch(name) --returns a player if one match is found or nil if 2+ or none are found

	local t = player.GetAll()
	local pl
	for i,v in pairs(t) do
		if string.find(string.lower(v:CharacterName()),string.lower(name)) then
			if ValidEntity(pl) then 
				return
			else
				pl = v
			end
		end
	end
	return pl
		

end
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function base64_decode(data)
	if !data then return nil end
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '00' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
   end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)        
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function table.Compare(tbl1,tbl2)
	if type(tbl1) != "table" || type(tbl2) != "table" then return false end
	for i,v in pairs(tbl1) do
		if !tbl2[i] then return false end
		if type(v) == "table" then
			if type(tbl2[i]) == "table" then
				return table.Compare(v,tbl2[i])
			else
				return false
			end
		else
			if type(v) != type(tbl2[i]) then return false end
			if v != tbl2[i] then return false end
		end
	end
	return true
end

function LoadProperties(str)
	if !string.find(str,":") then return end -- no variables here
	local vars = string.Explode("|",str)
	local properties = {}
	for i,v in pairs(vars) do
		local var = string.Explode(":",v)
		local varType = var[1]
		local index = var[2]
		local value = var[3]
		if varType == VAR_NUMBER then
			properties[index] = tonumber(value)
		elseif varType == VAR_STRING then
			properties[index] = value
		elseif varType == VAR_BOOL then
			properties[index] = value == "true"
		elseif varType == VAR_VECTOR then
			local vec = string.Explode(" ",value)
			properties[index] = Vector(vec[1],vec[2],vec[3])
		elseif varType == VAR_ANGLE then
			local ang = string.Explode(" ",value)
			properties[index] = Angle(ang[1],ang[2],ang[3])
		end
	end
	return properties
end

MainNPCList = {}
function AddNPC(name,mdl)
	MainNPCList[name] = mdl
end


function GM:ShouldCollide(ent1,ent2)
	if ent1:IsWorld() || ent2:IsWorld() then return true end
	return ent1:GetInstance() == ent2:GetInstance()
end

function GetPlayersInInstance(inst)
	local t = {}
	for i,v in pairs(player.GetAll()) do
		if v:GetInstance() == inst then
			table.insert(t,v)
		end
	end
	return t
end


include("sh_classes.lua")
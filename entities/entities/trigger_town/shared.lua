 	
ENT.Type 		= "brush"

AddCSLuaFile( "shared.lua" )


function ENT:Initialize()


end

function ENT:StartTouch(pl)

	hook.Call("PlayerEnteredArea",GAMEMODE,pl,AREA_WILD)
end

function ENT:PassesTriggerFilters( entity )
	return entity:IsPlayer()
end
if CLIENT then
	SWEP.PrintName = "A Visual Weapon"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
else
	AddCSLuaFile("shared.lua")
end
function SWEP:Initialize()
	if( SERVER ) then
		self:SetWeaponHoldType( "normal" )
	end
end


SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" );

function SWEP:PrimaryAttack()

end
function SWEP:SecondaryAttack() 

end


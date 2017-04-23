include("shared.lua")


function ENT:Initialize()
	--self:DrawShadow(false)
	--self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 90))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if !ValidEntity(owner) then return end
	if owner:GetRagdollEntity() then
		owner = owner:GetRagdollEntity()
	end
		
	local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
	if attach then
		local ang = attach.Ang
		self:SetAngles(ang)
		local pos = attach.Pos
		self:SetPos(pos)
		self:DrawModel()
	end
end 

function EFFECT:Init( effectdata ) 
self.pos = effectdata:GetOrigin()
self.LootBag = effectdata:GetEntity()
self.Entity:SetPos(self.pos)
self.em = ParticleEmitter(self.pos)

end
EFFECT.nextThink = 0
function EFFECT:Think()
	if !self.LootBag:IsValid() then return end
	
	local iOwn = self.LootBag:GetNWInt("OwnerUserID") == 0 || self.LootBag:GetNWInt("OwnerUserID") == Me:UserID()
	
	
	
	local part = self.em:Add("particles/smokey",self.LootBag:GetPos()+Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)))
	
	if iOwn then
		if math.random(0,1) == 1 then
			part:SetColor(0,255,0,150)
		else
			part:SetColor(255,255,255,150)
		end
	else
		part:SetColor(255,0,0,150)
	end
	
	part:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)))
	part:SetRoll(math.random(1))
	part:SetRollDelta(math.random(1))
	part:SetDieTime(1)
	part:SetStartAlpha(150)
	part:SetEndAlpha(0)
	part:SetLifeTime(0)
	part:SetStartSize(0.75)
	part:SetEndSize(0)
	return self.LootBag:IsValid()
end

function EFFECT:Render()
end
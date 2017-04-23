
function EFFECT:Init( effectdata ) 
self.pos = Me:GetPos()
self.Wep = effectdata:GetEntity()
self.Entity:SetPos(self.pos)
self.TimeLeft = CurTime() + 0.3 --if magnitude given is 1, effect will last for 0.5seconds
self.em = ParticleEmitter(self.pos)
end
function EFFECT:Think()
	
		local part = self.em:Add("particles/smokey",self.Wep:GetPos()+self.Wep:OBBMaxs())
		part:SetColor(255,255,255,150)
		part:SetVelocity(Vector(0,0,100))
		part:SetGravity(Vector(0,0,0))
		part:SetRoll(math.random(1))
		part:SetRollDelta(math.random(1))
		part:SetDieTime(0.1)
		part:SetStartAlpha(50)
		part:SetAirResistance(200)
		part:SetEndAlpha(0)
		part:SetLifeTime(0)
		part:SetStartSize(10)
		part:SetEndSize(10)
	return self.TimeLeft > CurTime()
end

function EFFECT:Render()
end
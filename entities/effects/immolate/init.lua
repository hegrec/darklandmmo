
function EFFECT:Init( effectdata ) 
self.pos = effectdata:GetOrigin()
self.Entity:SetPos(self.pos)
self.radius = effectdata:GetRadius()
self.TimeLeft = CurTime() + effectdata:GetMagnitude()*0.1 --if magnitude given is 1, effect will last for 0.5seconds
self.em = ParticleEmitter(self.pos)
end
function EFFECT:Think()

	for i=1,10 do
		local part = self.em:Add("particles/fire1",self.pos)
		part:SetColor(math.random(255),20,20,math.random(255))
		part:SetVelocity(Vector(math.random(-9,9),math.random(-9,9),0):GetNormalized() * 500)
		part:SetAirResistance(200)
		part:SetRoll(math.random(10))
		part:SetDieTime(2)
		part:SetLifeTime(0)
		part:SetStartSize(40)
		part:SetEndSize(0)
		local Pos = Vector(math.random()*2 - 1,math.random()*2 - 1,0):GetNormal() * self.radius
		Pos.x = Pos.x * 0.4
		Pos.y = Pos.y * 0.4
		local vel = Pos * 10
	
		local part = self.em:Add("particles/smokey",self.pos)
		local num = math.random()*50+1
		part:SetColor(num,num,num,150)
		part:SetVelocity(vel)
		part:SetGravity(Vector(0,0,0))
		part:SetRoll(math.random(1))
		part:SetRollDelta(math.random(1))
		part:SetDieTime(2)
		part:SetStartAlpha(50)
		part:SetAirResistance(200)
		part:SetEndAlpha(0)
		part:SetLifeTime(0)
		part:SetStartSize(50)
		part:SetEndSize(100)
	end
	return self.TimeLeft > CurTime()
end

function EFFECT:Render()
end
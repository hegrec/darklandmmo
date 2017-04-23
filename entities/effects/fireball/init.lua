local flareTime = 0
		local seg = 50
		local radius = 20
		local radsperseg = math.rad( 360 / seg )
function EFFECT:Init( effectdata ) 

self.pos = effectdata:GetOrigin()
self.ent = effectdata:GetEntity()
self.Entity:SetPos(self.pos)
self.em = ParticleEmitter(self.pos)
flareTime = RealTime()+0.1
self.TimesPassed = 0
end

function EFFECT:Think()
	if !self.ent:IsValid() then return end
	
	local r,g,b,a = math.random(179,181),math.random(109,128),math.random(10,65),math.random(2)*3
	
	local dlight = DynamicLight( self.ent:EntIndex() )
	
	if ( dlight ) then
		dlight.Pos = self.ent:GetPos()
		dlight.r = r
		dlight.g = g
		dlight.b = b
		dlight.Brightness = a
		dlight.Decay = 256 * a
		dlight.Size = 256*a/2
		dlight.DieTime = CurTime() + 0.1
	end
	local sizefactor = 1
	for i=1,3 do
		local part = self.em:Add("particles/fire1",self.ent:GetPos()+Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
		part:SetColor(r,g,b,a)
		part:SetVelocity(self.ent:GetVelocity())
		part:SetGravity(Vector(0,0,50))
		part:SetRoll(math.random(10))
		part:SetDieTime(0.3)
		part:SetStartAlpha(math.random(220,255))
		part:SetEndAlpha(math.random(0,10))
		part:SetStartSize(15*sizefactor)
		part:SetEndSize(10*sizefactor)
	end
	for i=1,3 do
		local part = self.em:Add("particles/smokey",self.ent:GetPos()+Vector(math.random(-7,7),math.random(-7,7),math.random(-7,7))+self.ent:GetVelocity():Normalize()*-5)
		local num = math.random()*50+1
		part:SetColor(num,num,num,255)
		part:SetRoll(math.random(1,10))
		part:SetDieTime(0.5)
		
		part:SetStartAlpha(200)
		part:SetEndAlpha(10)
		part:SetStartSize(8*sizefactor)
		part:SetEndSize(6*sizefactor)
	end
	if flareTime<RealTime() then
		local ang = self.ent:GetVelocity():Angle()

		for i = seg, 1, -1 do 
			local r = radsperseg * i - 1 
			
			local vec = Vector((math.sin( r ) * radius),(math.cos( r ) * radius),0)
				
			vec:Rotate(ang+Angle(90,0,0))
				
			local pos = vec
			local part = self.em:Add("particles/fire1",self.ent:GetPos()+pos+self.ent:GetVelocity():Normalize()*-self.TimesPassed)
			local num = math.random()*50+1
			part:SetColor(num,num,num,255)
			part:SetVelocity(vec:Normalize()*200+Vector(math.random(-2,2),math.random(-2,2),math.random(-2,2)))
			part:SetAirResistance(255)
			part:SetRoll(math.random(1,100))
			part:SetDieTime(0.2)
			part:SetStartAlpha(200)
			part:SetEndAlpha(0)
			part:SetStartSize(15*sizefactor)
			part:SetEndSize(1*sizefactor)
			
		end
		self.TimesPassed = self.TimesPassed + 1

	end
	
	return self.ent:IsValid()
end

function EFFECT:Render()

end
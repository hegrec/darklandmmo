function EFFECT:Init( effectdata ) 
	self.mdlTable = {}
	self.pos = effectdata:GetOrigin()
	self.targetZ = self.pos.z
	self.ent = effectdata:GetEntity()
	self.Entity:SetPos(self.pos)
	self.currentZ = self.targetZ - 1000
	for i=1,math.random(2,5) do
		local ind = table.insert(self.mdlTable,ClientsideModel("models/darkland/rpg/enviroment/spike.mdl",RENDERGROUP_OPAQUE))
		self.mdlTable[ind]:SetPos(self.pos+Vector(math.random(-50,50),math.random(-50,50),-1000))
		self.mdlTable[ind]:SetAngles(Angle(math.random(-30,30),math.random(-30,30),math.random(-30,30)))
		self.mdlTable[ind]:SetMaterial("models/debug/debugwhite")
		self.mdlTable[ind]:SetColor(10,10,10,255)
	end
	self.dieTime = RealTime()+1
	self.em = ParticleEmitter(self.pos)
end

function EFFECT:Think()

	if self.currentZ < self.targetZ-30 then
		local amt = 2000*FrameTime()
		self.currentZ = math.Clamp(self.currentZ+amt,self.currentZ,self.targetZ-30)
		
		for i,v in pairs(self.mdlTable) do
			v:SetPos(v:GetPos()+Vector(0,0,amt))
		end
		if self.currentZ >= self.targetZ - 30 then
			self:BrokeGround()
		end
	end
	for i,v in pairs(self.mdlTable) do 
	v:SetModelScale(Vector(2,2,1.2))
	end
	if self.dieTime < RealTime() then
		for i,v in pairs(self.mdlTable) do
			v:Remove()
		end
		return false
	end
	
	return true
end

function EFFECT:BrokeGround()
	for i=1,math.random(table.getn(self.mdlTable)+100,table.getn(self.mdlTable)+400) do
	
		local randomRock = table.Random(self.mdlTable)
		
		local part = self.em:Add("particles/smokey",randomRock:GetPos())
		part:SetColor(255,255,255,150)
		part:SetVelocity(1000*Vector(0.7,0.7,0.3))
		part:SetGravity(Vector(0,0,-100))
		part:SetRoll(math.random(10))
		part:SetRollDelta(math.random(5))
		part:SetDieTime(0.5)
		part:SetStartAlpha(50)
		part:SetAirResistance(200)
		part:SetEndAlpha(0)
		part:SetLifeTime(0)
		part:SetStartSize(50)
		part:SetEndSize(50)
	end
end

function EFFECT:Render()

		


end
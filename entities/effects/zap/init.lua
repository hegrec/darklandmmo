
local seg = 50
local radius = 200
local radsperseg = math.rad( 360 / seg )
function EFFECT:Init( effectdata ) 

self.pos = effectdata:GetOrigin()
self.ent = effectdata:GetEntity()
self.Entity:SetPos(self.pos)
self.em = ParticleEmitter(self.pos)
end

function EFFECT:Think()

	if !self.ent:IsValid() then return end
	
	local r,g,b,a = math.random(38,101),math.random(85,144),math.random(195,218),math.random(2)*3
	local red = r
	local dlight = DynamicLight( self.ent:EntIndex() )
	
	local Vel = self.ent:GetVelocity()
	
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
		local part = self.em:Add("sprites/physg_glow2",self.ent:GetPos()+Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
		part:SetColor(r,g,b,a)
		part:SetVelocity(Vel)
		part:SetGravity(Vector(0,0,50))
		part:SetRoll(math.random(10))
		part:SetDieTime(0.3)
		part:SetStartAlpha(math.random(220,255))
		part:SetEndAlpha(math.random(0,10))
		part:SetStartSize(15*sizefactor)
		part:SetEndSize(10*sizefactor)
	end
	for i=1,3 do
		local part = self.em:Add("sprites/physbeama",self.ent:GetPos()+Vector(math.random(-4,4),math.random(-4,4),math.random(-4,4))+Vel:Normalize()*-5)
		part:SetColor(r,g,b,255)
		part:SetRoll(math.random(1,10))
		part:SetDieTime(0.5)
		part:SetStartAlpha(200)
		part:SetEndAlpha(10)
		part:SetStartSize(8*sizefactor)
		part:SetEndSize(6*sizefactor)
	end
	return self.ent:IsValid()
end


function EFFECT:Render()


end
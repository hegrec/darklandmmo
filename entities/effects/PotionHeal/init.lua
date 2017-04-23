
function EFFECT:Init( effectdata ) 
	self.ent = effectdata:GetEntity()
	if self.ent:GetInstance() != Me:GetInstance() then return end
	self.Entity:SetPos(self.ent:GetPos())
	self.radius = effectdata:GetRadius()

	self.TimeLeft = CurTime() + 2 --if magnitude given is 1, effect will last for 0.5seconds
	self.em = ParticleEmitter(self.Entity:GetPos())
	self.num = 70
	self.Entity:EmitSound("darkland/rpg/drink.mp3",100,100)
end
local function updatePos(part)
	part:SetPos(part.ent:GetPos()+part.offset)
	part:SetNextThink(RealTime()+0.2)
end
function EFFECT:Think()
	if self.ent:GetInstance() != Me:GetInstance() then return false end
	local offsetVec = Vector(math.sin( RealTime()*20 ) * 15,math.cos( RealTime()*20 ) * 15,self.num)
	self.pos = self.ent:GetPos() + offsetVec

	local part = self.em:Add("darkland/rpg/particles/lesser_heal_pot",self.pos)
	part.offset = offsetVec
	part.ent = self.ent
	part:SetColor(255,255,255,255)
	part:SetDieTime(3)
	part:SetStartAlpha(150)
	part:SetEndAlpha(0)
	part:SetLifeTime(0)
	part:SetStartSize(2)
	part:SetEndSize(0)
	part:SetThinkFunction(updatePos)
	part:SetNextThink(RealTime()+0.2)	
	
	self.num = self.num - FrameTime()*30
	
	return self.num > 1
end

function EFFECT:Render()
end 
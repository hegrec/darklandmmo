CameraPos = Vector(0,0,0)
CamAngle = Angle(0,0,0)
CamVecOff = Vector(0,0,0)
function GetCameraPos()
	return CameraPos
end
function LocalizeToCam(vec,ang)
	ang = ang or Angle(0,0,0)
	return WorldToLocal(vec,ang,CameraPos,CamAngle)
end

function GM:CalcView( pl, origin, angles, fov )

	if !Me then return end
	local tbl

	tbl = hook.Call("DoCameraPos",GAMEMODE)
	
	local vec 		= tbl[1]
	local target 	= tbl[2]
	
	
	
	local forwardOff = vec.x
	vec.x = 0
	
	
	
	local pos = pl:GetPos()+pl:GetAimVector() * forwardOff + vec
	local pos2 = target
	
	if !Me:Alive() then
		vec.x = forwardOff
		local me = Me:GetRagdollEntity()
		if me then
			pos = vec+me:EyePos()
		else
			pos = Me:GetPos()
		end
	end
	
	local t = {}
	t.start = pos2
	t.endpos = pos
	t.filter = tbl[3] or pl
	t.mask = MASK_SOLID_BRUSHONLY
	
	local tr = util.TraceLine(t)
	
	CameraPos = tr.HitPos
	CamVecOff = Me:WorldToLocal(CameraPos)
	
	if tr.Fraction < 1.0 then
		CameraPos = CameraPos + tr.HitNormal * 5
	end
	
	CamAngle = (target-CameraPos):Angle()
	
	local t2 = {}
	t2.origin = CameraPos
	
	t2.angles =  CamAngle

	t2.fov = fov

	
	return t2
	
end



function GM:DoCameraPos()
	
	local t = {}
	if Me:Alive() then
		t[1] = Vector(-120,0,80)
		t[2] = Me:GetPos()+Vector(0,0,60)
	else
		t[1] = Vector(math.sin(RealTime())*20,math.cos(RealTime())*20,100)
		local me = Me:GetRagdollEntity()
		if me then
			t[2] = me:EyePos()
		else
			t[2] = Me:GetPos()
		end
	end
	return t
	
end
function GM:ShouldDrawLocalPlayer(pl)
	return true
end
local length = 0
local startTime = 0
local wide = 100
local tall = 8
local col = Color(255,255,0,255)

local function ProgressBarDraw()
	if !InProgress then return end
	local tbl = (Vector(0,0,70) + Me:GetPos()):ToScreen()
	local x = tbl.x - (wide*0.5) 
	local y = tbl.y - (tall*0.5)
	
	draw.RoundedBox(0,x-2,y-2,wide+4,tall+4,Color(0,0,0,255))
	
	
	local timeElapsed = RealTime()-startTime
	draw.RoundedBox(0,x,y,timeElapsed/length*wide,tall,col)
	
end
hook.Add("HUDPaint","__progressDraw",ProgressBarDraw)




local function grabVars(len)
	length = len
	startTime = RealTime()
end
hook.Add("OnProgressStarted","_grabProgressVars",grabVars)
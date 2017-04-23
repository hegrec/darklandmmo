if SERVER then return end

include("sh_boneanimlib.lua")

usermessage.Hook("resetluaanim", function(um)
	local ent = um:ReadEntity()
	local anim = um:ReadString()
	if ent:IsValid() then
		ent:ResetLuaAnimation(anim)
	end
end)

usermessage.Hook("setluaanim", function(um)
	local ent = um:ReadEntity()
	local anim = um:ReadString()
	if ent:IsValid() then
		ent:SetLuaAnimation(anim)
	end
end)

usermessage.Hook("stopluaanim", function(um)
	local ent = um:ReadEntity()
	local anim = um:ReadString()
	if ent:IsValid() then
		ent:StopLuaAnimation(anim)
	end
end)

usermessage.Hook("stopluaanimgp", function(um)
	local ent = um:ReadEntity()
	local animgroup = um:ReadString()
	if ent:IsValid() then
		ent:StopLuaAnimationGroup(animgroup)
	end
end)

usermessage.Hook("stopallluaanim", function(um)
	local ent = um:ReadEntity()
	if ent:IsValid() then
		ent:StopAllLuaAnimations()
	end
end)

local TYPE_GESTURE = TYPE_GESTURE
local TYPE_POSTURE = TYPE_POSTURE
local TYPE_STANCE = TYPE_STANCE
local TYPE_SEQUENCE = TYPE_SEQUENCE

local Animations = GetLuaAnimations()

local function LuaBuildBonePositions(pl, iNumBones, iNumPhysBones)
	local tLuaAnimations = pl.LuaAnimations
	for sGestureName, tGestureTable in pairs(tLuaAnimations) do
		local iCurFrame = tGestureTable.Frame
		local tFrameData = tGestureTable.FrameData[iCurFrame]
		local fFrameDelta = tGestureTable.FrameDelta

		if tGestureTable.ShouldPlay and not tGestureTable.ShouldPlay(pl, sGestureName, tGestureTable, iCurFrame, tFrameData, fFrameDelta) then
			pl:StopLuaAnimation(sGestureName)
		elseif not tGestureTable.PreCallback or not tGestureTable.PreCallback(pl, sGestureName, tGestureTable, iCurFrame, tFrameData, fFrameDelta) then
			if tGestureTable.Type == TYPE_GESTURE then
				local tPrevFrameData = tGestureTable.PrevFrameData[iCurFrame]
				if tPrevFrameData then
					for iBoneID, tBoneInfo in pairs(tPrevFrameData.BoneInfo) do
						if type(iBoneID) ~= "number" then
							iBoneID = pl:LookupBone(iBoneID)
						end

						local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
						if vCurBonePos then
							local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
							if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
								local vUp = aCurBoneAng:Up()
								local vRight = aCurBoneAng:Right()
								local vForward = aCurBoneAng:Forward()
								--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR)
								aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU)
								aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF)
								pl:SetBonePosition(iBoneID, vCurBonePos + tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward, aCurBoneAng)]]
								mBoneMatrix:Translate(tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward)
								mBoneMatrix:Rotate(Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF))
								pl:SetBoneMatrix(iBoneID, mBoneMatrix)
							end
						end
					end
				end

				for iBoneID, tBoneInfo in pairs(tFrameData.BoneInfo) do
					if type(iBoneID) ~= "number" then
						iBoneID = pl:LookupBone(iBoneID)
					end

					local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
					if vCurBonePos then
						local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
						if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
							local vUp = aCurBoneAng:Up()
							local vRight = aCurBoneAng:Right()
							local vForward = aCurBoneAng:Forward()
							--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF * fFrameDelta)
							pl:SetBonePosition(iBoneID, vCurBonePos + tBoneInfo.MU * fFrameDelta * vUp + tBoneInfo.MR * fFrameDelta * vRight + tBoneInfo.MF * fFrameDelta * vForward, aCurBoneAng)]]
							mBoneMatrix:Translate(fFrameDelta * (tBoneInfo.MU * vUp * tBoneInfo.MR * vRight * tBoneInfo.MF * vForward))
							mBoneMatrix:Rotate(Angle(fFrameDelta * tBoneInfo.RR, fFrameDelta * tBoneInfo.RU, fFrameDelta * tBoneInfo.RF))
							pl:SetBoneMatrix(iBoneID, mBoneMatrix)
						end
					end
				end

				tGestureTable.FrameDelta = tGestureTable.FrameDelta + FrameTime() * tFrameData.FrameRate
				if tGestureTable.FrameDelta > 1 then
					tGestureTable.Frame = iCurFrame + 1
					tGestureTable.FrameDelta = 0
					if tGestureTable.Frame > #tGestureTable.FrameData then
						pl:StopLuaAnimation(sGestureName)
					end
				end
			elseif tGestureTable.Type == TYPE_POSTURE then
				if fFrameDelta < 1 and tGestureTable.TimeToArrive then
					fFrameDelta = math.min(1, fFrameDelta + FrameTime() * (1 / tGestureTable.TimeToArrive))
					tGestureTable.FrameDelta = fFrameDelta
				end

				for iBoneID, tBoneInfo in pairs(tFrameData.BoneInfo) do
					if type(iBoneID) ~= "number" then
						iBoneID = pl:LookupBone(iBoneID)
					end

					local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
					if vCurBonePos then
						local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
						if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
							local vUp = aCurBoneAng:Up()
							local vRight = aCurBoneAng:Right()
							local vForward = aCurBoneAng:Forward()
							--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF * fFrameDelta)
							pl:SetBonePosition(iBoneID, vCurBonePos + tBoneInfo.MU * fFrameDelta * vUp + tBoneInfo.MR * fFrameDelta * vRight + tBoneInfo.MF * fFrameDelta * vForward, aCurBoneAng)]]
							mBoneMatrix:Translate(fFrameDelta * (tBoneInfo.MU * vUp * tBoneInfo.MR * vRight * tBoneInfo.MF * vForward))
							mBoneMatrix:Rotate(Angle(fFrameDelta * tBoneInfo.RR, fFrameDelta * tBoneInfo.RU, fFrameDelta * tBoneInfo.RF))
							pl:SetBoneMatrix(iBoneID, mBoneMatrix)
						end
					end
				end
			elseif tGestureTable.Type == TYPE_STANCE then
				local tPrevFrameData = tGestureTable.PrevFrameData[iCurFrame]
				if tPrevFrameData then
					for iBoneID, tBoneInfo in pairs(tPrevFrameData.BoneInfo) do
						if type(iBoneID) ~= "number" then
							iBoneID = pl:LookupBone(iBoneID)
						end

						local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
						if vCurBonePos then
							local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
							if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
								local vUp = aCurBoneAng:Up()
								local vRight = aCurBoneAng:Right()
								local vForward = aCurBoneAng:Forward()
								--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR)
								aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU)
								aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF)
								pl:SetBonePosition(iBoneID, vCurBonePos + tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward, aCurBoneAng)]]
								mBoneMatrix:Translate(tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward)
								mBoneMatrix:Rotate(Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF))
								pl:SetBoneMatrix(iBoneID, mBoneMatrix)
							end
						end
					end
				end

				local fFrameDelta = tGestureTable.FrameDelta
				for iBoneID, tBoneInfo in pairs(tFrameData.BoneInfo) do
					if type(iBoneID) ~= "number" then
						iBoneID = pl:LookupBone(iBoneID)
					end

					local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
					if vCurBonePos then
						local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
						if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
							local vUp = aCurBoneAng:Up()
							local vRight = aCurBoneAng:Right()
							local vForward = aCurBoneAng:Forward()
							--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF * fFrameDelta)
							pl:SetBonePosition(iBoneID, vCurBonePos + tBoneInfo.MU * fFrameDelta * vUp + tBoneInfo.MR * fFrameDelta * vRight + tBoneInfo.MF * fFrameDelta * vForward, aCurBoneAng)]]
							mBoneMatrix:Translate(fFrameDelta * tBoneInfo.MU * vUp + fFrameDelta * tBoneInfo.MR * vRight + fFrameDelta * tBoneInfo.MF * vForward)
							mBoneMatrix:Rotate(Angle(fFrameDelta * tBoneInfo.RR, fFrameDelta * tBoneInfo.RU, fFrameDelta * tBoneInfo.RF))
							pl:SetBoneMatrix(iBoneID, mBoneMatrix)
						end
					end
				end

				tGestureTable.FrameDelta = tGestureTable.FrameDelta + FrameTime() * tFrameData.FrameRate
				if tGestureTable.FrameDelta > 1 then
					tGestureTable.Frame = iCurFrame + 1
					tGestureTable.FrameDelta = 0
					if tGestureTable.Frame > #tGestureTable.FrameData then
						tGestureTable.Frame = tGestureTable.RestartFrame or 1
					end
				end
			else
				local tPrevFrameData = tGestureTable.PrevFrameData[iCurFrame]
				if tPrevFrameData then
					for iBoneID, tBoneInfo in pairs(tPrevFrameData.BoneInfo) do
						if type(iBoneID) ~= "number" then
							iBoneID = pl:LookupBone(iBoneID)
						end

						local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
						if vCurBonePos then
							local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
							if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
								local vUp = aCurBoneAng:Up()
								local vRight = aCurBoneAng:Right()
								local vForward = aCurBoneAng:Forward()
								--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR)
								aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU)
								aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF)
								pl:SetBonePosition(iBoneID, vCurBonePos + tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward, aCurBoneAng)]]
								mBoneMatrix:Translate(tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward)
								mBoneMatrix:Rotate(Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF))
								pl:SetBoneMatrix(iBoneID, mBoneMatrix)
							end
						end
					end
				end

				local fFrameDelta = tGestureTable.FrameDelta
				for iBoneID, tBoneInfo in pairs(tFrameData.BoneInfo) do
					if type(iBoneID) ~= "number" then
						iBoneID = pl:LookupBone(iBoneID)
					end

					local vCurBonePos, aCurBoneAng = pl:GetBonePosition(iBoneID)
					if vCurBonePos then
						local mBoneMatrix = pl:GetBoneMatrix(iBoneID)
						if not tBoneInfo.Callback or not tBoneInfo.Callback(pl, iNumBones, iNumPhysBones, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta) then
							local vUp = aCurBoneAng:Up()
							local vRight = aCurBoneAng:Right()
							local vForward = aCurBoneAng:Forward()
							--[[aCurBoneAng:RotateAroundAxis(vRight, tBoneInfo.RR * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vUp, tBoneInfo.RU * fFrameDelta)
							aCurBoneAng:RotateAroundAxis(vForward, tBoneInfo.RF * fFrameDelta)
							pl:SetBonePosition(iBoneID, tBoneInfo.MU * fFrameDelta * vUp + tBoneInfo.MR * fFrameDelta * vRight + tBoneInfo.MF * fFrameDelta * vForward, aCurBoneAng)]]
							mBoneMatrix:Translate(fFrameDelta * tBoneInfo.MU * vUp + fFrameDelta * tBoneInfo.MR * vRight + fFrameDelta * tBoneInfo.MF * vForward)
							mBoneMatrix:Rotate(Angle(fFrameDelta * tBoneInfo.RR, fFrameDelta * tBoneInfo.RU, fFrameDelta * tBoneInfo.RF))
							pl:SetBoneMatrix(iBoneID, mBoneMatrix)
						end
					end
				end

				tGestureTable.FrameDelta = tGestureTable.FrameDelta + FrameTime() * tFrameData.FrameRate
				if tGestureTable.FrameDelta > 1 then
					tGestureTable.Frame = iCurFrame + 1
					tGestureTable.FrameDelta = 0
					if tGestureTable.Frame > #tGestureTable.FrameData then
						tGestureTable.Frame = tGestureTable.RestartFrame or 1
					end
				end
			end

			if tGestureTable.Callback then
				tGestureTable.Callback(pl, sGestureName, tGestureTable, iCurFrame, tFrameData, fFrameDelta)
			end
		end
	end
end

hook.Add("UpdateAnimation", "LuaAnimationSequenceReset", function(pl)
	if pl.InSequence then
		pl:SetSequence("reference")
	end
end)

local meta = _R["Entity"]
function meta:ResetLuaAnimation(sAnimation)
	local animtable = Animations[sAnimation]
	if animtable then
		self.LuaAnimations = self.LuaAnimations or {}
		local desgroup = animtable.Group
		if desgroup then
			for animname, tab in pairs(self.LuaAnimations) do
				if tab.Group == desgroup then
					self.LuaAnimations[animname] = nil
				end
			end
		end

		local framedelta = 0
		if animtable.Type == TYPE_POSTURE and not animtable.TimeToArrive then
			framedelta = 1
		end

		if animtable.Type == TYPE_SEQUENCE then
			self.InSequence = true
		end

		self.LuaAnimations[sAnimation] = {Frame = animtable.StartFrame or 1, FrameDelta = framedelta, FrameData = animtable.FrameData, PrevFrameData = animtable.PrevFrameData, Type = animtable.Type, RestartFrame = animtable.RestartFrame, TimeToArrive = animtable.TimeToArrive, Callback = animtable.Callback, ShouldPlay = animtable.ShouldPlay, PreCallback = animtable.PreCallback}
		self.BuildBonePositions = LuaBuildBonePositions
	end
end

function meta:SetLuaAnimation(sAnimation)
	if self.LuaAnimations and self.LuaAnimations[sAnimation] then return end

	self:ResetLuaAnimation(sAnimation)
end

function meta:StopLuaAnimation(sAnimation)
	local anims = self.LuaAnimations
	if anims and anims[sAnimation] then
		if anims[sAnimation].Type == TYPE_SEQUENCE then
			local count = 0
			for _, tab in pairs(anims) do
				if tab.Type == TYPE_SEQUENCE then
					count = count + 1
				end
			end
			if count <= 1 then
				self.InSequence = nil
			end
		end

		anims[sAnimation] = nil
		if table.Count(anims) <= 0 then
			self.LuaAnimations = nil
			self.BuildBonePositions = nil
		end
	end
end

function meta:StopLuaAnimationGroup(sGroup)
	local tAnims = self.LuaAnimations
	if tAnims then
		for animname, animtable in pairs(tAnims) do
			if animtable.Group == sGroup then
				self:StopLuaAnimation(animname)
			end
		end
	end
end

function meta:StopAllLuaAnimations()
	if self.LuaAnimations then
		for name in pairs(self.LuaAnimations) do
			self:StopLuaAnimation(name)
		end
	end
end
meta = nil

function OpenpAnimationEditor()
	if pAnimationEditor then
		pAnimationEditor:SetVisible(true)
		pAnimationEditor:MakePopup()
		return
	end

	local wid, hei = math.min(w - 32, 1280), math.min(h - 32, 900)

	local Window = vgui.Create("DFrame")
	Window:SetDeleteOnClose(false)
	Window:SetTitle("Lua Animation Editor")
	Window:SetSize(wid, hei)
	Window:Center()
	Window:SetVisible(true)
	Window:MakePopup()
	pAnimationEditor = Window

	local FreeViewPort = vgui.Create("DPanel", Window)
	FreeViewPort:SetSize(wid * 0.5 - 64, hei * 0.5 - 64)
	FreeViewPort:SetPos(24, 64)
	local mdlpanel = vgui.Create("DModelPanel", FreeViewPort)
	mdlpanel:SetSize(FreeViewPort:GetSize())
	mdlpanel:SetModel("models/breen.mdl")
	mdlpanel:SetCamPos(Vector(0, -128, 36))
	mdlpanel:SetLookAt(Vector(0, 0, 36))
	TESTENTITY = mdlpanel.Entity
end
concommand.Add("openanimationeditor", OpenpAnimationEditor)

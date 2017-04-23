--[[

Bone Animations Library
Created by William "JetBoom" Moodhe (jetboom@yahoo.com / www.noxiousnet.com)
Because I wanted custom, dynamic animations.
Give credit or reference if used in your creations.

]]

TYPE_GESTURE = 0 -- Gestures are keyframed animations that use the current position and angles of the bones. They play once and then stop automatically.
TYPE_POSTURE = 1 -- Postures are static animations that use the current position and angles of the bones. They stay that way until manually stopped. Use TimeToArrive if you want to have a posture lerp.
TYPE_STANCE = 2 -- Stances are keyframed animations that use the current position and angles of the bones. They play forever until manually stopped. Use RestartFrame to specify a frame to go to if the animation ends (instead of frame 1).
TYPE_SEQUENCE = 3 -- Sequences are keyframed animations that use the origin and angles of the entity. They play forever until manually stopped. Use RestartFrame to specify a frame to go to if the animation ends (instead of frame 1).
-- You can also use StartFrame to specify a starting frame for the first loop.

local Animations = {}

function GetLuaAnimations()
	return Animations
end

function RegisterLuaAnimation(sName, tInfo)
	if tInfo.FrameData then
		for iFrame, tFrame in ipairs(tInfo.FrameData) do
			for iBoneID, tBoneTable in pairs(tFrame.BoneInfo) do
				tBoneTable.MU = tBoneTable.MU or 0
				tBoneTable.MF = tBoneTable.MF or 0
				tBoneTable.MR = tBoneTable.MR or 0
				tBoneTable.RU = tBoneTable.RU or 0
				tBoneTable.RF = tBoneTable.RF or 0
				tBoneTable.RR = tBoneTable.RR or 0
			end
		end

		local tTemp = {}

		if tInfo.Type ~= TYPE_POSTURE then
			local tPrevFrameData = {}

			for iFrame, tFrame in ipairs(tInfo.FrameData) do
				tPrevFrameData[iFrame] = {BoneInfo = {}}
				for iBoneID, tBoneTable in pairs(tFrame.BoneInfo) do
					if not tTemp[iBoneID] then
						tTemp[iBoneID] = {MU = 0, MR = 0, MF = 0, RU = 0, RF = 0, RR = 0}
					end
					local tPrev = tTemp[iBoneID]

					tPrevFrameData[iFrame].BoneInfo[iBoneID] = {MU = tPrev.MU, MR = tPrev.MR, MF = tPrev.MF, RU = tPrev.RU, RF = tPrev.RF, RR = tPrev.RR}

					tPrev.MU = tPrev.MU + tBoneTable.MU
					tPrev.MR = tPrev.MR + tBoneTable.MR
					tPrev.MF = tPrev.MF + tBoneTable.MF
					tPrev.RU = tPrev.RU + tBoneTable.RU
					tPrev.RR = tPrev.RR + tBoneTable.RR
					tPrev.RF = tPrev.RF + tBoneTable.RF
				end
			end

			tInfo.PrevFrameData = tPrevFrameData
		end
	end
	Animations[sName] = tInfo
end

-- If your animation is only used on one model, use numbers instead of bone names (cache the lookup).
-- If it's being used on a wide array of models (including default player models) then you should use bone names.
-- You can use Callback as a function instead of MU, RR, etc. which will allow you to do some interesting things.
-- See cl_boneanimlib.lua for the full format.
/*
--[[
STANCE: stancetest
A simple looping stance that stretches the model's spine up and down until stopped.
]]
RegisterLuaAnimation("stancetest", {
	FrameData = {
		{
			BoneInfo = {
				["ValveBiped.Bip01_Spine"] = {
					MU = 64
				}
			},
			FrameRate = 0.25
		},
		{
			BoneInfo = {
				["ValveBiped.Bip01_Spine"] = {
					MU = -32
				}
			},
			FrameRate = 1.5
		},
		{
			BoneInfo = {
				["ValveBiped.Bip01_Spine"] = {
					MU = 32
				}
			},
			FrameRate = 4
		}
	},
	RestartFrame = 2,
	Type = TYPE_STANCE
})

--[[
STANCE: staffholdspell
To be used with the ACT_HL2MP_IDLE_MELEE2 animation.
Player holds the staff so that their left hand is over the top of it.
]]
RegisterLuaAnimation("staffholdspell", {
	FrameData = {
		{
			BoneInfo = {
				["ValveBiped.Bip01_R_Forearm"] = {
					RU = 40,
					RF = -40
				},
				["ValveBiped.Bip01_R_Upperarm"] = {
					RU = 40
				},
				["ValveBiped.Bip01_R_Hand"] = {
					RU = -40
				},
				["ValveBiped.Bip01_L_Forearm"] = {
					RU = 40
				},
				["ValveBiped.Bip01_L_Hand"] = {
					RU = -40
				}
			},
			FrameRate = 6
		},
		{
			BoneInfo = {
				["ValveBiped.Bip01_R_Forearm"] = {
					RU = 2,
				},
				["ValveBiped.Bip01_R_Upperarm"] = {
					RU = 1
				},
				["ValveBiped.Bip01_R_Hand"] = {
					RU = -10
				},
				["ValveBiped.Bip01_L_Forearm"] = {
					RU = 8
				},
				["ValveBiped.Bip01_L_Hand"] = {
					RU = -12
				}
			},
			FrameRate = 0.4
		},
		{
			BoneInfo = {
				["ValveBiped.Bip01_R_Forearm"] = {
					RU = -2,
				},
				["ValveBiped.Bip01_R_Upperarm"] = {
					RU = -1
				},
				["ValveBiped.Bip01_R_Hand"] = {
					RU = 10
				},
				["ValveBiped.Bip01_L_Forearm"] = {
					RU = -8
				},
				["ValveBiped.Bip01_L_Hand"] = {
					RU = 12
				}
			},
			FrameRate = 0.1
		}
	},
	RestartFrame = 2,
	Type = TYPE_STANCE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		local wepstatus = pl.WeaponStatus
		return wepstatus and wepstatus:IsValid() and wepstatus:GetSkin() == 1 and wepstatus.IsStaff
	end
})
*/
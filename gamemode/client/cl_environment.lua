local SUNRISE = {}

hook.Add("Initialize", "SUNRISE:Init",
		function()
			SUNRISE.NextTimeThink = 0
			SUNRISE.LastColor = nil
		end
	)

hook.Add("Think", "SUNRISE:Think",
		function()
			
			if ( SUNRISE.NextTimeThink > CurTime( ) ) then return; end

			SUNRISE.NextTimeThink = CurTime( ) + 0.1;
			
			
			if (SUNRISE.Materials == nil) then
				local skyname = GetConVarString("sv_skyname")
			
				SUNRISE.Materials = {}
				SUNRISE.Materials[1] = Material("skybox/" .. skyname .. "up")
				SUNRISE.Materials[2] = Material("skybox/" .. skyname .. "dn")
				SUNRISE.Materials[3] = Material("skybox/" .. skyname .. "lf")
				SUNRISE.Materials[4] = Material("skybox/" .. skyname .. "rt")
				SUNRISE.Materials[5] = Material("skybox/" .. skyname .. "bk")
				SUNRISE.Materials[6] = Material("skybox/" .. skyname .. "ft")
				
			end
			
			local skyColor = GetGlobalVector("SUNRISE:SkyMod");
			if (skyColor != SUNRISE.LastColor) then
				for k,v in pairs(SUNRISE.Materials) do
					v:SetMaterialVector("$color", skyColor)
				end
				SUNRISE.LastColor = skyColor
			end
		
		end
	)

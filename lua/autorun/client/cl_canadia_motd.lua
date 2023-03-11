local settings = {
    ["gm_novenka"] = {
		pos = Vector(1200, 7776, -312),
		ang = Angle(0,45,90),
		dir = Vector(1,-1,0),
		size = Vector(128,96),
		scale = 0.25,
		dist = 1000,
	},
    ["gm_bluehills_test3"] = {
		pos = Vector(1154, -672, 340),
		ang = Angle(0,270,90),
		dir = Vector(-1,0,0),
		size = Vector(224,86),
		scale = 0.25,
		dist = 1000,
	},
	["gm_carcon_ext"] = {
		pos = Vector(0, -3070,-14386),
		ang = Angle(0,180,90),
		dir = Vector(0,1,0),
		size = Vector(350, 180),
		scale = 0.5,
		dist = 1000,
	}
}
if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]


local margin = 16 / setting.scale
setting.size  = setting.size / setting.scale
setting.dist = setting.dist * setting.dist

hook.Add("PostDrawTranslucentRenderables", "Canadia_WorkshopLink", function()
	local viewingDiff  = setting.pos - EyePos()
	local viewingAngle = viewingDiff:Dot(setting.dir)

	if viewingAngle > 0 then return end

    cam.Start3D2D( setting.pos, setting.ang, setting.scale)

	x = -setting.size.x/2
	y = -setting.size.y/2

    draw.RoundedBoxEx(margin, x, y, setting.size.x, margin*2, Color(209, 70, 70), true, true, false, false)
    draw.RoundedBoxEx(margin, x, y + margin*2, setting.size.x, setting.size.y - margin*2, Color(215,215,215), false, false, true, true)

    if EyePos():DistToSqr(setting.pos) > setting.dist then
        cam.End3D2D()
        return 
    end
    
	draw.SimpleText("Welcome to Canadia", "WeatherMD", 0, y+margin, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	x = x + margin
	y = y + margin*2.5
	draw.DrawText("Rules:", "WeatherSM", x, y, Color(90,90,90))
	y = y + margin
	draw.DrawText("1. Do not disturb builders and coders!\n2. Spamming props is an instant perma ban\n3. Unwarranted PvP can get you banned", "WeatherSM", x, y, Color(90,90,90))

	y = y + margin*3.5
	draw.DrawText("No, this server is not in Canada", "WeatherSM", x, y, Color(90,90,90))
	y = y + margin
	draw.DrawText("Seeing errors? Use the button below", "WeatherSM", x, y, Color(90,90,90))

	
	local buttonWidth = setting.size.x * 0.6
	x = - buttonWidth/2
	y = y + margin*1.25

	local aimPos = util.IntersectRayWithPlane(EyePos(), EyeVector(), setting.pos, setting.dir)
	local btnColor = Color(215,215,215)
	local txtColor = Color(90,90,90)

	if aimPos ~= nil then
		local localPos = aimPos - setting.pos
		local cursorPos = Vector(-localPos.y, -localPos.z) / setting.scale
		
		//surface.DrawCircle(cursorPos.x, cursorPos.y, 15, 0, 0, 0, 255)

		if math.abs(cursorPos.x) < buttonWidth/2 and cursorPos.y > y and cursorPos.y < y+margin then
			btnColor = Color(80,80,80)
			txtColor = Color(215,215,215)

			if LocalPlayer():KeyPressed( IN_USE ) then
				gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=371410947")
			end
		end
	end
	
	draw.RoundedBox(margin/2, x, y, buttonWidth, margin, btnColor)
	draw.SimpleText("Workshop Link!", "WeatherSM", 0, y+margin/2, txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    cam.End3D2D()
end)


print("[Canadia] Loaded MOTD Screen")

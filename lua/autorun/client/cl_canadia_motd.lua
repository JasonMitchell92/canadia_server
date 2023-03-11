local settings = {
    ["gm_novenka"] = {
		pos = Vector(1200, 7776, -312),
		ang = Angle(0,45,90),
		dir = Vector(1,-1,0),
		size = Vector(128,96) },
    ["gm_bluehills_test3"] = {
		pos = Vector(1154, -672, 340),
		ang = Angle(0,270,90),
		dir = Vector(-1,0,0),
		size = Vector(224,86)},
}

if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]


local motdScreenSize  = setting.size
local motdScreenScale = 0.25
local margin = 8 / motdScreenScale
local renderDist = 1000


motdScreenSize = motdScreenSize / motdScreenScale
renderDist = renderDist * renderDist

hook.Add("PostDrawTranslucentRenderables", "Canadia_WorkshopLink", function()
	local viewingDiff  = setting.pos - EyePos()
	local viewingAngle = viewingDiff:Dot(setting.dir)

	if viewingAngle > 0 then return end



	
	

    //if EyePos().y < setting.pos.y then return end
	if viewingAngle > 90 then return end

    cam.Start3D2D( setting.pos, setting.ang, motdScreenScale)

	x = -motdScreenSize.x/2
	y = -motdScreenSize.y/2

    draw.RoundedBoxEx(margin, x, y, motdScreenSize.x, margin*2, Color(209, 70, 70), true, true, false, false)
    draw.RoundedBoxEx(margin, x, y + margin*2, motdScreenSize.x, motdScreenSize.y - margin*2, Color(215,215,215), false, false, true, true)

    if EyePos():DistToSqr(setting.pos) > renderDist then
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

	
	local buttonWidth = motdScreenSize.x * 0.6
	x = - buttonWidth/2
	y = y + margin*1.25

	local aimPos = util.IntersectRayWithPlane(EyePos(), EyeVector(), setting.pos, setting.dir)
	local btnColor = Color(215,215,215)
	local txtColor = Color(90,90,90)

	if aimPos ~= nil then
		local localPos = aimPos - setting.pos
		local cursorPos = Vector(-localPos.y, -localPos.z) / motdScreenScale
		
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
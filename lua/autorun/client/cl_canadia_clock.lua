
surface.CreateFont( "Courier_256", {
	font = "Courier", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 256,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Courier_70", {
	font = "Courier", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 70,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

setup3D2D("Spawn_Clock", Vector(1405, 7826, -65), Angle(0,225, 90), 8000, 0.275, function()
    surface.SetDrawColor(Color(50,50,50))

    local time = os.date('%H:%M')
    for i=1, 5 do
        local x = (i-3) * 135
        surface.DrawRect(x-64,-112,128,224)

        //if i==3 and CurTime()%2 < 1 then continue end

        draw.SimpleText(time[i], "Courier_256", x, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    surface.DrawRect(-334,118,668,100)
    draw.SimpleText(os.date('%A, %b %d'), "Courier_70", 0, 168, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

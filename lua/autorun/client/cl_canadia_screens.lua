function setup3D2D( id, pos, ang, renderDist, scale, func)
    renderDist = renderDist ^ 2

    hook.Add( "PostDrawOpaqueRenderables", "Canadia_" .. id, function()
        if EyePos():DistToSqr( pos ) > renderDist then return end

        cam.Start3D2D( pos, ang, scale)
            func()
        cam.End3D2D()
    end)

    print("[Canadia] Set up 3D2D for " .. id)
end

/*
setup3D2D("Atmos_Control", Vector(-2470, 7135, -60), Angle(0, 0, 90), 500, 0.25, function()
    draw.DrawText(os.date('%H:%M %p') , "DermaLarge", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER)
end)
*/

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

setup3D2D("MemberArea_Barrier", Vector(11330, -13824, -512), Angle(0,90,90), 3000, 1, function()
	
	if LocalPlayer():HasPrivilege("memberarea") then
		surface.SetDrawColor( Color(80,255,80,15) )
	else
		surface.SetDrawColor( Color(255,80,80,15) )
	end

	surface.DrawRect(-129, -65, 260, 130)

	draw.SimpleText("Ranked Area", "DermaLarge", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

local shieldMat = Material("effects/combineshield/comshieldwall")
setup3D2D("Jail_Screen", Vector(14848, -8064, -328), Angle(0,180,90), 800, 1, function()
	surface.SetMaterial(shieldMat)
	surface.DrawTexturedRect(-64, -56, 128, 112)
end)
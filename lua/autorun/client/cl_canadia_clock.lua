surface.CreateFont( "Courier_256", { font = "Courier",  size = 256 } )
surface.CreateFont( "Courier_70", {font = "Courier", size = 70 } )

local settings = {
    ["gm_novenka"] = {
		pos = Vector(1405, 7826, -65),
		ang = Angle(0,225, 90),
		scale = 0.275,
		dist = 8000,
	},
	["gm_carcon_ext"] = {
		pos = Vector(0, -2047,-14300),
		ang = Angle(0,180,90),
		scale = 0.275,
		dist = 4000,
	}
}
if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]

setting.dist = setting.dist * setting.dist

hook.Add( "PostDrawOpaqueRenderables", "Canadia_Spawn_Clock", function()
    if EyePos():DistToSqr( setting.pos ) > setting.dist then return end

    cam.Start3D2D(setting.pos, setting.ang, setting.scale)

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

    cam.End3D2D()
end)

print("[Canadia] Loaded Clock Screen")

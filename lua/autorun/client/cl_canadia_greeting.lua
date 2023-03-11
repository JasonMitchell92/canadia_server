local settings = {
    ["gm_novenka"] = {
		pos = Vector(384, 10560, 300),
        scale = 1,
	},
    ["gm_bluehills_test3"] = {
        pos = Vector( -446, -630, 2000),
        scale = 0.75,
	},
}

if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]


function setup3D2DText(pos, scale, renderDist)
    renderDist = renderDist^2

    surface.CreateFont( "RobotoHuge", {
        font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = 96,
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
    })

    local leaf = Material("canadia/maple_leaf.png")
    
    leafClr = Color(209, 70, 70)

    hook.Add( "PostDrawOpaqueRenderables", "Canadia_Greeting_Render", function()
        --if the client is more than 5000 units from the screen, cancel
        if EyePos():DistToSqr( pos ) > renderDist then return end
        
        --start at negative half size and draw down from negative y
        local yaw = RealTime() * 6

        cam.Start3D2D( pos , Angle(0, yaw, 90), scale)
            surface.SetDrawColor(leafClr)
            surface.SetMaterial(leaf)
            surface.DrawTexturedRect(-128, -128, 256, 256)
            
            draw.DrawText("Canadia", "RobotoHuge", 0, 128, leafClr, TEXT_ALIGN_CENTER)
            
            draw.DrawText("(Pronounced Cuh-Nay-Dee-Uh)", "Default", 0, 220, leafClr, TEXT_ALIGN_CENTER)
        cam.End3D2D()

        cam.Start3D2D( pos , Angle(0, yaw + 180, 90), scale)
            surface.SetDrawColor(leafClr)
            surface.SetMaterial(leaf)
            surface.DrawTexturedRect(-128, -128, 256, 256)

            draw.DrawText("Canadia", "RobotoHuge", 0, 128, leafClr, TEXT_ALIGN_CENTER)

            draw.DrawText("(Pronounced Cuh-Nay-Dee-Uh)", "Default", 0, 220, leafClr, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end)
end

setup3D2DText(setting.pos, setting.scale, 15000)


print("[Canadia] Loaded Greeting")

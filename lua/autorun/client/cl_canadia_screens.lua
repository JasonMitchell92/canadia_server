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

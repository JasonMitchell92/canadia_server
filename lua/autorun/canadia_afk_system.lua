local CanadiaStrPrefix = "CanadiaAFK_"
local TimeToAFK = 60
 
if SERVER then --------------------------------------------------- SERVER STUFF -------------------------------------------------------
    util.AddNetworkString(CanadiaStrPrefix .. "Net")
 
    local function setStatus(ply, isAway)
        ply.isAway = isAway

        --ply:ChatPrint("afk status: " .. tostring(isAway))
        ply:SetNWFloat(CanadiaStrPrefix .. "timeAway", ply.timeAway)
    end
 
    timer.Create(CanadiaStrPrefix .. "Timer_Check", 1, 0, function()
        if #player.GetAll() then
            for _, ply in pairs(player.GetAll()) do
                if !IsValid(ply) then continue end

                if ply.isAway == nil then
                    ply.timeAway = 0
                    setStatus(ply, true)
                end
                
                ply.timeAway = ply.timeAway + 1

                ply:SetNWFloat(CanadiaStrPrefix .. "timeAway", ply.timeAway)
 
                if ply.isAway == false and ply.timeAway > TimeToAFK then
                    setStatus(ply, true)
                end
            end
        end
    end)
 
    hook.Add( "PlayerButtonDown", CanadiaStrPrefix .. "PlyButton", function( ply )
        setStatus(ply, false)
        ply.timeAway = 0
    end)
 
    net.Receive(CanadiaStrPrefix .. "Net", function(len, ply)
        local state = net.ReadBool()
        setStatus(ply, state)
    end)
else --------------------------------------------------- CLIENT STUFF -------------------------------------------------------
    local thisPly = LocalPlayer()
    local playersAway = {}
    local gameInFocus = true

    thisPly.isAway = false

    local circleImage = Material("canadia/circle_outline.png")
 
    local function netPlayerAway(value) -- client cannot setnw, not even shared

        if thisPly.isAway ~= value then
            thisPly.isAway = value

            net.Start(CanadiaStrPrefix .. "Net")
                net.WriteBool(value)
            net.SendToServer()
        end
    end
 
    hook.Add("Think", "Canadia_AFK_Focus", function()
        local focus = system.HasFocus()
        if focus ~= gameInFocus then
            gameInFocus = focus
            if gameInFocus == false then
                netPlayerAway(true)
                --thisPly:ChatPrint("You alt tabbed, you are now away!")
            end
        end
    end)
 
    timer.Create(CanadiaStrPrefix .. "Timer_Read", 1, 0, function()
        local thisTime = CurTime()
        
        playersAway = {}

        if #player.GetAll() then
            for _, ply in pairs(player.GetAll()) do

                ply.timeAway = ply:GetNWFloat(CanadiaStrPrefix .. "timeAway")
                
                if ply.timeAway > TimeToAFK then 
                    if ply==thisPly then thisPly.isAway = true end
                    
                    table.insert(playersAway, ply)
                end
            end
        end
    end)

    hook.Add("PostDrawOpaqueRenderables", "Canadia_AFK_Display", function()
        local rotateOffset = math.rad(RealTime() * 6)

        for _,ply in pairs( playersAway ) do
            if not IsValid(ply) then continue end

            local drawPos = ply:GetPos() + Vector(0,0,1)

            cam.Start3D2D( drawPos, Angle(), 0.5)

            surface.SetDrawColor(Color(0,0,0,200))
            surface.SetMaterial(circleImage)
            surface.DrawTexturedRect(-128, -128, 256, 256)

            cam.End3D2D()


            local str = "Away for " .. string.NiceTime( ply.timeAway )
            local len = string.len(str)

            for i = 1, len do
                local char = string.sub(str, i, i)
                local theta = rotateOffset + ((math.pi / 26) * i)

                cam.Start3D2D(drawPos + Vector(math.cos(theta), math.sin(theta), 0) * 43,  Angle(0, math.deg(theta) + 90, 0), 0.14)

                draw.DrawText(char, "Courier_70", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER)

                cam.End3D2D()
            end
        end
    end)
end
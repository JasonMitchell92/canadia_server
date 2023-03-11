/*
local playerList = {}
local groupOffset = 0

-- function to add a player to the player list
function addToPlayerList(ply)
    
    local plyName = ply:Nick()
    if string.len(plyName) > 20 then
        plyName = string.sub(plyName, 0, 20) .. "..."
    end

    local groupid = groupOffset + ply:Team()

    if not playerList[ groupid ] then playerList[ groupid ] = {} end

    playerList[ groupid ][ ply ] = {
        name = plyName,
        ping = ply:Ping(),
        time = string.NiceTime(ply:GetNWInt("ranktime")),
        kills = ply:Frags(),
        deaths = ply:Deaths(),
    }
end

function buildPlayerList()
    playerList = {}
    
    for _, ply in pairs( player.GetAll() ) do
        addToPlayerList(ply)
    end
end

function setup3D2DScoreboard(pos, ang, renderDist, screenSizeX, screenSizeY, scale)
    local sizeRow = 32

    renderDist = renderDist^2

    hook.Add( "PostDrawOpaqueRenderables", "Canadia_Scoreboard_Render", function()
        if EyePos():DistToSqr( pos ) > renderDist then return end
        
        --start at negative half size and draw down from negative y
        local x = -screenSizeX / 2
        local y = 0
    
        cam.Start3D2D( pos , ang, scale)
            surface.SetDrawColor(Color(50,50,50,200))
            surface.DrawRect(x,y,screenSizeX, screenSizeY)
            draw.DrawText(GetHostName(), "ScoreboardDefaultTitle", 0, y + sizeRow/2, Color(255,255,255), TEXT_ALIGN_CENTER)
    
            y = y + sizeRow*2 --new row
            surface.SetDrawColor( Color(255,255,255) )
            surface.DrawLine( x + 10, y, x + screenSizeX - 10, y)
    
            draw.DrawText("Rank/Name", "ScoreboardDefault", x + 20, y+5, Color(255,255,255))
            draw.DrawText("Time", "ScoreboardDefault", x + screenSizeX * 0.6, y+5, Color(255,255,255), TEXT_ALIGN_CENTER)
            draw.DrawText("Kills", "ScoreboardDefault", x + screenSizeX * 0.7, y+5, Color(255,255,255), TEXT_ALIGN_CENTER)
            draw.DrawText("Deaths", "ScoreboardDefault", x + screenSizeX * 0.8, y+5, Color(255,255,255), TEXT_ALIGN_CENTER)
            draw.DrawText("Ping", "ScoreboardDefault", x + screenSizeX * 0.9, y+5, Color(255,255,255), TEXT_ALIGN_CENTER)
    
            y = y + sizeRow --new row
            surface.DrawLine( x + 10, y, x + screenSizeX - 10, y )
    
            surface.SetDrawColor( Color(120,120,120) )
    
            for groupID, playerGroup in pairs( playerList ) do
                local teamColor = team.GetColor( groupID - groupOffset )
                

                draw.DrawText(team.GetName( groupID - groupOffset ), "ScoreboardDefault", x + 20, y, teamColor)
                y = y + sizeRow * 0.75
    
                for ply, info in pairs( playerGroup ) do
    
                    draw.DrawText(info.name, "DermaLarge", x + 40, y, teamColor)
                    
                    draw.DrawText(info.time, "DermaLarge", x + screenSizeX * 0.6, y, Color(255,255,255), TEXT_ALIGN_CENTER)
                    draw.DrawText(info.kills, "DermaLarge", x + screenSizeX * 0.7, y, Color(255,255,255), TEXT_ALIGN_CENTER)
                    draw.DrawText(info.deaths, "DermaLarge", x + screenSizeX * 0.8, y, Color(255,255,255), TEXT_ALIGN_CENTER)
                    draw.DrawText(info.ping, "DermaLarge", x + screenSizeX * 0.9, y, Color(255,255,255), TEXT_ALIGN_CENTER)
    
                    y = y + sizeRow
                end
                
                surface.DrawLine(x + 10, y, x + screenSizeX - 10, y)
            end
        cam.End3D2D()
    end)
end
--
timer.Create("Canadia_Scoreboard_Update", 1, 0, buildPlayerList)

buildPlayerList()

setup3D2DScoreboard(Vector(130, 5885, -140), Angle(0, 90, 90), 2000, 1000, 750, 0.3)

print("[Canadia] Loaded Scoreboard")
*/
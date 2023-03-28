if SERVER then
    local settings = {
        ["gm_novenka"] = {pos = Vector(2368, 6400, -152), size = 66},
        ["gm_bluehills_test3"] = {pos = Vector(168, -224, 350), size = 128},
        ["gm_flatgrass_classic"] = {pos = Vector(1034, 815, 164), size = 128},
        ["gm_carcon_ext"] = {pos = Vector(9, -2368, -13850), size = 128},
    }
    

    if settings[ game.GetMap() ] then
    
        local setting = settings[ game.GetMap() ]

        earthEnt = earthEnt or nil
        markerEnts = markerEnts or {}

        local function getCartesian(lat, lon)
            --lua uses radians, stupid i know
            lat = -math.rad(lat)
            lon =  math.rad(lon)

            local x = math.cos(lat) * math.cos(lon)
            local y = math.cos(lat) * math.sin(lon)
            local z = math.sin(lat)

            return Vector(x,y,z)
        end

        local function createEarth()
            if IsValid(earthEnt) then return end

            earthEnt = ents.Create("prop_physics")
            earthEnt:SetModel("models/earth/earth.mdl")
            earthEnt:SetMaterial("")
            earthEnt:SetPos( setting.pos )
            earthEnt:SetBodygroup(1, 1)
            earthEnt:SetModelScale( setting.size / 10.125 )
        end

        local function removeMarker(userid)
            if markerEnts[userid] then
                markerEnts[userid]:Remove()
                table.remove(markerEnts, userid)
            end
        end

        local function createMarker(userid, lat, lon)
            local worldPos = earthEnt:LocalToWorld( getCartesian(-lat, lon) * setting.size * 1.005 )
            local worldAng = earthEnt:LocalToWorldAngles( Angle(-lat - 90, lon, 0) )

            --remove a previous marker if it is already there
            removeMarker(userid)

            local markerEnt = ents.Create("prop_physics")
            markerEnt:SetModel("models/props_junk/trafficcone001a.mdl")
            markerEnt:SetMaterial("debug/debugdrawflat")
            markerEnt:SetColor(Color(215, 50, 50) )
            markerEnt:SetPos( worldPos )
            markerEnt:SetAngles( worldAng )
            markerEnt:SetModelScale( setting.size / 1000 )
            markerEnt:SetParent(earthEnt)

            markerEnts[userid] = markerEnt
        end

        --create a hook to use later when a player joins and ip info has been obtained
        hook.Add("EarthAddMarker", "Canadia_EarthAddMarker",  createMarker)

        
        --Create the earth after entities can be created
        hook.Add("InitPostEntity", "Canadia_GlobeInitPostEntity", function()
            createEarth()
        end)

        --Make earth spin
        hook.Add("Think", "Canadia_GlobeThink", function()
            if earthEnt == nil then createEarth() end --create the earth if run post InitPostEntity

            earthEnt:SetAngles(Angle(0, CurTime() % 360, 0))
        end)

        gameevent.Listen( "player_disconnect" )
        hook.Add( "player_disconnect", "Canadia_Globe_Disconnect", function( data )
            if markerEnts[data.userid] then
                removeMarker(data.userid)
            else
                print("No marker found for " .. data.userid .. " to remove")
            end
        end)
    end


    local function establishLocationData(ply)
        local apiToken = "4b6fdaceeb7334"
        local ip = string.Explode( ":", ply:IPAddress(), false )[1]
        local url = "https://ipinfo.io/" .. ip .. "?token=" .. apiToken

        http.Fetch( url, function(body, size, headers, code)
            local json = util.JSONToTable(body)
            
            if json.status == 404 then 
                print(json.error.title, json.error.message)
                return
            end

            local lat, lon = unpack( string.Explode(',', json.loc) )
            
            lat = math.Round(lat, 1)
            lon = math.Round(lon, 1)

            ply:SetNW2String("CC", json.country)

            hook.Call("EarthAddMarker", {}, ply:UserID(), lat, lon)
            
        end, function(error)
            print("Unable to fetch ip info for " .. ply:Nick() .. ". Reason: "..error)
        end)
    end
    

    for _,ply in pairs( player.GetAll() ) do
        if IsValid(ply) then
            establishLocationData(ply)
        end
    end

    hook.Add("PlayerInitialSpawn", "Canadia_PlyInitSpawn", function(ply)
        establishLocationData(ply)
    end)
end

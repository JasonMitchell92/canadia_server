local settings = {
    ["gm_novenka"] = {pos = Vector(2368, 6400, -152), size = 66},
    ["gm_bluehills_test3"] = {pos = Vector(168, -224, 350), size = 128},
    ["gm_flatgrass_classic"] = {pos = Vector(1034, 815, 164), size = 128},
    ["gm_carcon_ext"] = {pos = Vector(9, -2368, -13850), size = 128},
}

if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]

local globeRadius = setting.size
local modelRadius = 20.25 / 2



if SERVER then
    util.AddNetworkString("Canadia_GlobePlayerDataRequest")
    earthEnt = earthEnt or nil

    function createEarth()
        if IsValid(earthEnt) then return end

        earthEnt = ents.Create("prop_physics")
        earthEnt:SetModel("models/earth/earth.mdl")
        earthEnt:SetMaterial("")
        earthEnt:SetPos( setting.pos )
        earthEnt:SetBodygroup(1, 1)
        earthEnt:SetModelScale( globeRadius / modelRadius )
    end

    
    hook.Add("InitPostEntity", "Canadia_GlobeInitPostEntity", function()
        createEarth()
    end)

    hook.Add("Think", "Canadia_GlobeThink", function()
        if earthEnt==nil then createEarth() end

        earthEnt:SetAngles(Angle(0, CurTime()%360, 0))
    end)
end

if CLIENT then
    local renderDistance = 1000

    //local earthMat = CreateMaterial("canadia/8k_earth_specular_map.jpg")

    renderDistance = renderDistance * renderDistance
    playerData = {}
    
    local function requestData()
        net.Start("Canadia_GlobePlayerDataRequest")
        net.SendToServer()
    end
    requestData()

    net.Receive("Canadia_GlobePlayerDataRequest", function()
        playerData = net.ReadTable()
    end)

    net.Receive("Client_Initialized", "")

    local function getCartesian(lat, lon)
        --lua uses radians, stupid i know
        lat = -math.rad(lat)
        lon =  math.rad(lon)

        local x = math.cos(lat) * math.cos(lon)
        local y = math.cos(lat) * math.sin(lon)
        local z = math.sin(lat)
        
        return Vector(x,y,z)
    end

    hook.Add("PostDrawTranslucentRenderables", "Canadia_Globe", function()
        if EyePos():DistToSqr(setting.pos) > renderDistance then return end
        cam.Start3D2D( setting.pos, Angle(0, CurTime() % 360, 180), 1)

        for k,v in pairs( playerData ) do
            local coord = getCartesian(v.lat, v.lon) * globeRadius

            render.DrawLine(coord*0.95, coord*1.05, Color(255,0,0), true)
        end

        cam.End3D2D()
    end)

    timer.Create("PlayerCoordinateUpdater", 10, 0, function()
        requestData()
    end)
end

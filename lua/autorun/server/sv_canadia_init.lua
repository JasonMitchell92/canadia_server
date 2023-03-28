resource.AddFile("materials/canadia/maple_leaf_white.png")
resource.AddFile("materials/canadia/circle_outline.png")

resource.AddFile("materials/weapons/headhunter.jpg")
resource.AddFile("materials/weapons/enforcer.jpg")


--Workshop Client Requirements
resource.AddWorkshop("2512558788") --[ACE] - Armored Combat Ext  1261 MB
resource.AddWorkshop("1131455085") --Gredwitch' Base             727 MB
resource.AddWorkshop("2912826012") --[LVS] - Planes              282 MB
resource.AddWorkshop("173482196")  --SProps Workshop Edition     160 MB
resource.AddWorkshop("771487490")  --[simfphys] - Classic        139 MB
resource.AddWorkshop("2891252709") --ACF Unofficial Extras       139 MB
resource.AddWorkshop("2912816023") --[LVS] - Framework           15 MB
resource.AddWorkshop("2922255746") --[LVS] - Helicopters         13 MB
resource.AddWorkshop("2891252709") --half-life 2 props extended  10 MB
resource.AddWorkshop("545874448")  --earth and moon models       5 MB
resource.AddWorkshop("2893718679") --crazy coupe simfphys        2 MB

resource.AddWorkshop("826673827")  --TDM/LW Car Pack             14 MB
resource.AddWorkshop("112606459")  --TDMCars - Base Pack         29 MB
resource.AddWorkshop("113118541")  --TDMCars - BMW               48 MB
resource.AddWorkshop("120766823")  --TDMCars - GMC               11 MB
resource.AddWorkshop("494665724")  --TDMCars - Lexus             6 MB
resource.AddWorkshop("266504181")  --TDMCars - Subaru            12 MB
resource.AddWorkshop("286998866")  --TDMCars - Volvo             20 MB
resource.AddWorkshop("123455885")  --TDMCars - Nissan            24 MB
resource.AddWorkshop("266579667")  --[LW] Shared Textures        75 MB
resource.AddWorkshop("497652801")  --[LW] GMC Pack               23 MB
resource.AddWorkshop("307458805")  --[LW] Ford SVT Cobra R       15 MB
resource.AddWorkshop("218584660")  --[LW] Subaru Impreza 22B     17 MB
resource.AddWorkshop("218869210")  --SGM Shared Textures         18 MB
resource.AddWorkshop("490329940")  --2002 Dodge Neon SE          6 MB
resource.AddWorkshop("739636780")  --Roy's Cars - Shared FIles   139 MB
resource.AddWorkshop("2495777274") --Nissan Skyline GT-R R34     6 MB

resource.AddWorkshop("700820606")  --Biggies Bong                1 MB
resource.AddWorkshop("245762582")  --dice models                 < 1 MB
resource.AddWorkshop("471435979")  --Race Seats                  < 1 MB




--require the map
local function RequireMapFromWorkshop(name)
    local workshopIDs = {
        ["gm_novenka"]         = "2049617805", --133 MB
        ["gm_carcon_ext"]      = "2290839694", --185 MB
        ["gm_bluehills_test3"] = "243902601", --25 MB
    }
    
    if workshopIDs[ name ] then
        resource.AddWorkshop( workshopIDs[ name ] )
    else
        print("[Canadia] No Workshop file specified for map "..name)
    end
end

RequireMapFromWorkshop( game.GetMap() )




Canadia = {}

hook.Add("PlayerShouldTakeDamage", "Canadia_PlayerDamage", function(victim, attacker)
    --if the attacker is godded
    if attacker:IsValid() and attacker:IsPlayer() and attacker:HasGodMode() and !victim:HasGodMode() then
        
        attacker:GodDisable()
        attacker:SetNWBool("Godmode", false)

        Mercury.Util.SendMessage(attacker, {Mercury.Config.Colors.Server,"Disabled Godmode for attacking a player while Godded."})
        return false
    end
end)

local settings = {
    ["gm_novenka"] = {
        admin = {
            min = Vector(3072, -2816, -2319),
            max = Vector(4096, 1792, -1039),
        },
        member = {
            min = Vector(4544, -14864, -768),
            max = Vector(11328, -12784, -264),
        },
        jail = {
            min = Vector(14720, -8063, -384),
            max = Vector(15104,-7296,-260),
        }
    },
    ["gm_bluehills_test3"] = {
        jail = {
            min = Vector(-7856, 11216, 112),
            max = Vector(-7312, 11568, 251),
        }
    },
    ["gm_carcon_ext"] = {
        jail = {
            min = Vector(-3360, 4096,-14584),
            max = Vector(-2784, 5212,-14296),
        }
    }
}

local setting = settings[ game.GetMap() ]

hook.Add("InitPostEntity", "zone_init", function()

    if setting == nil then return end

    if setting.admin then
        Mercury.Commands.AddPrivilege("adminarea")

        AdminArea = ents.Create("trigger_zone_admin")
        AdminArea:Spawn()
        AdminArea:CreateTrigger(setting.admin.min, setting.admin.max)
    end
    
    if setting.member then
        Mercury.Commands.AddPrivilege("memberarea")

        MemberArea = ents.Create("trigger_zone_member")
        MemberArea:Spawn()
        MemberArea:CreateTrigger(setting.member.min, setting.member.max)
    end
    
    if setting.jail then
        JailArea = ents.Create("trigger_zone_jail")
        JailArea:Spawn()
        JailArea:CreateTrigger(setting.jail.min, setting.jail.max)

        Canadia.JailZone = JailArea
    end
end)

hook.Add("PlayerSpawn", "Mercury:JailedPlayerSpawn", function(ply)
    if ply.isJailed then
        if Canadia.JailZone then
            Canadia.JailZone:SpawnPlayer(ply)
        end

        ply:StripAmmo()
        ply:StripWeapons()
    end
end)

hook.Add("PlayerNoClip", "Mercury:JailedPlayerNoclip", function( ply, desiredNoClipState )
    if ply.IsJailed and desiredNoClipState then
        return false
    else
        return true
    end
end)

hook.Add("ShowSpare2", "NutButton", function(ply)

    if ply.soundCounter == nil then
        ply.soundCounter = 0
    end

    local pitch = -ply:EyeAngles().x + 120

    sound.Play("nut_generic.ogg", ply:GetPos(), 75, math.Clamp(pitch, 30, 300))

    ply.soundCounter = ply.soundCounter + 1

    if ply.soundCounter >= 7 then
        if ply:Alive() then
            game.ConsoleCommand("hg rocket " .. ply:GetName() .. "\n")
        end
        ply.soundCounter = 0
    end

    if ply.soundCounter == 1 then
        timer.Simple(3, function()
            ply.soundCounter = 0
        end)
    end

end)

hook.Add("PlayerSpawnObject", "Canadia_JailSpawnObject", function(ply)
    if ply.IsJailed then return false end
end)

hook.Add("PlayerSpawnNPC", "Canadia_JailSpawnNPC", function(ply)
    if ply.IsJailed then return false end
end)

hook.Add("PlayerSpawnSENT", "Canadia_JailSpawnSENT", function(ply)
    if ply.IsJailed then return false end
end)

hook.Add("PlayerSpawnSWEP", "Canadia_JailSpawnSWEP", function(ply)
    if ply.IsJailed then return false end
end)

hook.Add("PlayerSpawnVehicle", "Canadia_JailSpawnVehicle", function(ply)
    if ply.IsJailed then return false end
end)


print("{Canadia] Loaded Server Init")

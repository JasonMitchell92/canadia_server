resource.AddFile("materials/canadia/maple_leaf.png")
resource.AddFile("materials/canadia/circle_outline.png")

resource.AddFile("materials/weapons/headhunter.jpg")
resource.AddFile("materials/weapons/enforcer.jpg")
--resource.AddFile("materials/weapons/warmonger.jpg")


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
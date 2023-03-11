SWEP.Category 				= "Canadia"
SWEP.PrintName				= "The Enforcer"
SWEP.Instructions			= ""
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.Sound			= Sound( "weapons/shotgun/shotgun_fire6.wav" )
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Delay			= 0.2
SWEP.Primary.Damage			= 10

SWEP.Secondary.Sound		= Sound( "weapons/shotgun/shotgun_dbl_fire.wav" )
SWEP.Secondary.ClipSize		= 18
SWEP.Secondary.DefaultClip	= 18
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "buckshot"
SWEP.Secondary.Delay		= 0.6

SWEP.Weight					= 3
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.Slot					= 2
SWEP.SlotPos				= 4
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.ViewModel				= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel				= "models/weapons/w_shotgun.mdl"
SWEP.Reloading				= false
SWEP.IconOverride           = "weapons/enforcer.jpg"

function SWEP:Initialize()

	self:SetWeaponHoldType( "shotgun" )

end

function SWEP:PrimaryAttack()
	-- Make sure we can shoot first
	if (  !self:CanPrimaryAttack() ) then return end

	local theta = 2
    local bullet = {}
    bullet.Num          = 80
    bullet.Src          = self.Owner:GetShootPos()
    bullet.Dir          = self.Owner:GetAimVector()
    bullet.Spread       = Vector(0.5,0.5)
    bullet.Tracer       = 1
    bullet.TracerName   = "HelicopterTracer"
    bullet.Damage       = self.Primary.Damage
    bullet.AmmoType     = self.Primary.Ammo
    bullet.Force        = 100
	bullet.Distance		= 500


	-- Play shoot sound
	self.Weapon:EmitSound(self.Primary.Sound)
	
    self.Weapon:FireBullets( bullet )

	-- Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	-- Punch the player's view
	self.Owner:ViewPunch( Angle( -9, 0, 0 ) )
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end
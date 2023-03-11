SWEP.Category 				= "Canadia"
SWEP.PrintName				= "Headhunter"
SWEP.Instructions			= ""
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "crossbow"
SWEP.Primary.Delay			= 0.5
SWEP.Primary.Damage			= 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


SWEP.Weight					= 3
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.Slot					= 2
SWEP.SlotPos				= 4
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.ViewModel				= "models/weapons/c_irifle.mdl"
SWEP.WorldModel				= "models/weapons/w_irifle.mdl"
SWEP.HoldType               = "ar2"
SWEP.Reloading				= false
SWEP.IconOverride           = "weapons/headhunter.jpg"
SWEP.Zoom                   = 0
SWEP.ZoomInSound            = Sound("weapons/sniper/sniper_zoomin.wav")
SWEP.ZoomOutSound           = Sound("weapons/sniper/sniper_zoomout.wav")

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end


function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "InZoom")
	self:NetworkVar("Bool", 1, "InReload")
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
    self.Owner:SetFOV(0, 0.25)
    self.Zoom = 0
end

function SWEP:Holster()
    self.Owner:SetFOV(0, 0)
	return true
end
function SWEP:Remove()
    if IsValid(self:GetOwner()) then
        self.Owner:SetFOV(0, 0)
    end
	return true
end

function SWEP:GetAimTrace()
	local ply = self.Owner

	return util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 32768,
		filter = {ply, self},
		mask = MASK_SHOT
	})
end

function SWEP:PrimaryAttack()
	-- Make sure we can shoot first
	if self.IsReloading or !self:CanPrimaryAttack() then return end
    
	-- Play shoot sound
	self:EmitSound("NPC_Sniper.FireBullet")
	
    self.Weapon:ShootBullet( 55, 1, 0, self.Primary.Ammo, 100)

	-- Remove 1 bullet from our clip
	//self:TakePrimaryAmmo( 1 )
    
	local kick = Angle(-0.5, math.Rand(-0.3, 0.3), 0)

	self.Owner:SetEyeAngles(self.Owner:EyeAngles() + kick)
	self.Owner:ViewPunch(kick)


	local trace = self:GetAimTrace()

	if trace.PhysicsBone == 10 then --headshot
		
		local effectdata = EffectData()
		effectdata:SetOrigin( trace.HitPos )
		effectdata:SetNormal( trace.HitNormal )
		effectdata:SetEntity( trace.Entity )
		effectdata:SetMagnitude( 100 )
		effectdata:SetAttachment( trace.PhysicsBone )
		util.Effect( "balloon_pop", effectdata )
	end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
    
    if self.Zoom == 0 then
        self.Owner:SetFOV(15, 0.25)
        self.Zoom = 1
        self.Weapon:EmitSound(self.ZoomInSound)
    elseif self.Zoom == 1 then
        self.Owner:SetFOV(3, 0.25)
        self.Zoom = 2
        self.Weapon:EmitSound(self.ZoomInSound)
    else
        self.Owner:SetFOV(54, 0.25)
        self.Zoom = 0 
        self.Weapon:EmitSound(self.ZoomOutSound)
    end
        
end

function SWEP:Reload()
	if self.IsReloading or self:Clip1() == self.Primary.ClipSize then
		return
	end

	if self.Owner:IsPlayer() then
		local ammo = self.Owner:GetAmmoCount(self.Primary.Ammo)

		if ammo <= 0 then
			return
		end
	end

	self.Owner:SetAnimation(PLAYER_RELOAD)

	self:EmitSound("NPC_Sniper.Reload")

    self.IsReloading = true
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:Think()
	local ply = self.Owner

	if self.IsReloading and CurTime() > self:GetNextPrimaryFire() then
		self.IsReloading = false

		local amt = math.min(ply:GetAmmoCount(self.Primary.Ammo), self.Primary.ClipSize)

		self:SetClip1(amt)
	end
end


local hexMult = math.sqrt(3)/2
local function drawHexagon(x, y, size)

    /*
    surface.DrawLine( x + size/2, y - hexMult * size, x + size, y) --right top
    surface.DrawLine( x + size/2, y + hexMult * size, x + size, y) --right bottom
    
    surface.DrawLine( x - size/2, y - hexMult * size, x - size, y) --right top
    surface.DrawLine( x - size/2, y + hexMult * size, x - size, y) --right bottom
    */

    
    surface.DrawLine( x - size/2, y - hexMult * size, x + size/2, y - hexMult * size) --top
    surface.DrawLine( x - size, y, x - size/2, y + hexMult * size) --bottom left
    surface.DrawLine( x + size, y, x + size/2, y + hexMult * size) --bottom right

    --surface.SetDrawColor( Color( 3, 209, 252))
    surface.DrawLine( x + size/2, y + hexMult * size, x + size, y + hexMult * size * 2) --right top
    surface.DrawLine( x + size/2, y - hexMult * size, x + size, y - hexMult * size * 2) --right top

    surface.DrawLine( x - size/2, y + hexMult * size, x - size, y + hexMult * size * 2) --right top
    surface.DrawLine( x - size/2, y - hexMult * size, x - size, y - hexMult * size * 2) --right top

    surface.DrawLine( x + size, y, x + size * 2, y) --right top
    surface.DrawLine( x - size, y, x - size * 2, y) --right top
end

function SWEP:GetFOVRatio()
    return self.Owner:GetFOV() / self.Owner:GetInfoNum("fov_desired", 75)
end

function SWEP:DoDrawCrosshair( x, y )

	surface.SetDrawColor( 245, 169, 3, 255 ) -- Sets the color of the lines we're drawing
    
	local gap = 20 + self:GetFOVRatio()*20
	local length = gap + 20

    --surface.DrawCircle(x, y, gap)
    drawHexagon(x, y, gap)
    draw.SimpleText(math.ceil(1/self:GetFOVRatio()) .. "x", "DermaLarge", x + 80, y + 80, Color(0,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	return true
end

function SWEP:DrawHUD()


	for _, ply in pairs( player.GetAll() ) do
		if ply == self.Owner then continue end

		local head = ply:GetAttachment( 1 )

		if head==nil then continue end

		local screenData = head.Pos:ToScreen()
		if not screenData.visible then continue end

		surface.SetDrawColor(Color(0,255,255))
		surface.DrawCircle(screenData.x, screenData.y, 10)
	end
end

function SWEP:AdjustMouseSensitivity()
	if self.Zoom then
		return self.Owner:GetFOV() / self.Owner:GetInfoNum("fov_desired", 75)
	end
end
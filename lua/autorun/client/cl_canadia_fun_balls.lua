
local settings = {
    ["gm_novenka"] = {
		pos = Vector(2368, 6400, -152),
		ang = Angle(0, 270, 90),
        dir = Vector(1,0,0),
		size = Vector(400, 120),
	},
    ["gm_bluehills_test3"] = {
        pos = Vector(473, -1108, 176),
        ang = Angle(0,90,90),
        dir = Vector(1,0,0),
		size = Vector(552, 160),
	},
}

if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]

local ballScreenScale = 0.5
local ballRadius      = 8
local renderDistance  = 1000

local FPS = 60

local balls = {}
local ballMats = {
	[1] = Material("icon16/emoticon_evilgrin.png"),
	[2] = Material("icon16/emoticon_grin.png"),
	[3] = Material("icon16/emoticon_happy.png"),
	[4] = Material("icon16/emoticon_smile.png"),
	[5] = Material("icon16/emoticon_surprised.png"),
	[6] = Material("icon16/emoticon_tongue.png"),
	[7] = Material("icon16/emoticon_unhappy.png"),
	[8] = Material("icon16/emoticon_waii.png"),
	[9] = Material("icon16/emoticon_wink.png"),
}

--initialize the balls :)

setting.size = setting.size / ballScreenScale
renderDistance = renderDistance * renderDistance



for i=1, 200 do 
    local angle = math.rad(math.Rand(0,360))

	table.insert(balls, {
		pos = Vector( math.Rand(-setting.size.x/2 + ballRadius, setting.size.x/2 - ballRadius), math.Rand(-setting.size.y/2 + ballRadius, setting.size.y/2 - ballRadius)),
		vel = Vector( math.cos(angle), math.sin(angle) ),
		matIdx = math.floor(math.random(1, #ballMats)),
	})
end

local next_frame = 0
function updateSimulation()
    local now = RealTime()
    if next_frame > now then return end
    next_frame = now + (1/FPS)

	local dt = RealFrameTime()

	for _, ball in pairs(balls) do

		local thisPos = ball.pos
		local thisVel = ball.vel
		
		local nextPos = thisPos + thisVel
		
		--bounceX
		if nextPos.x < -setting.size.x/2 + ballRadius or nextPos.x > setting.size.x/2 - ballRadius then
			nextPos.x = nextPos.x - (thisVel.x * 2 * dt)
			thisVel.x = -thisVel.x
		end
		
		--bounceY
		if nextPos.y < -setting.size.y/2 + ballRadius or nextPos.y > setting.size.y/2 - ballRadius then
			nextPos.y = nextPos.y - (thisVel.y * 2 * dt)
			thisVel.y = -thisVel.y
		end

		ball.pos = nextPos
		ball.vel = thisVel
	end
end


hook.Add( "PostDrawOpaqueRenderables", "Canadia_Fun_Balls", function()
-- Render stuff here
	local viewingDiff  = setting.pos - EyePos()
	local viewingAngle = viewingDiff:Dot(setting.dir)

	if viewingAngle > 0 then return end

	cam.Start3D2D( setting.pos, setting.ang, ballScreenScale)

		if EyePos():DistToSqr( setting.pos ) > renderDistance then 
			draw.SimpleText("< Wall Art Here >", "DermaLarge", 0, 0, Color(255,255,255,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
			return
		end

		updateSimulation()

		surface.SetDrawColor(Color(255,255,255))

		for _, ball in pairs(balls) do
			render.PushFilterMag( TEXFILTER.NONE )
			render.PushFilterMin( TEXFILTER.NONE )

			surface.SetMaterial(ballMats[ball.matIdx])
			surface.DrawTexturedRect(math.Round( ball.pos.x-ballRadius ), math.Round( ball.pos.y-ballRadius ), ballRadius*2, ballRadius*2)

			render.PopFilterMag()
			render.PopFilterMin()
		end

	cam.End3D2D()
end)

print("[Canadia] Set up 3D2D for Fun Balls")
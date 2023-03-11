/*
	Center Pos: 2768 8868 -168
	Min Pos: 2464.03125 8192.03125 -263.96875
	Max Pos: 3071.96875 9543.96875 -72.03125
	Box Size: -607.9375 -1351.9375 -191.9375
*/
/*

	Center Pos: 511.99993896484 10752 -1740.5469970703
	Min Pos: -0.3228759765625 10239.677734375 -2047.96875
	Max Pos: 1024.3227539063 11264.322265625 -1433.1252441406
	Box Size: -1024.6456298828 -1024.64453125 -614.84350585938

	
*/
local settings = {
    ["gm_novenka"] = {
		pos = Vector(512, 10752, -2047),
		size = Vector(1024, 1024, 0),
	},
    ["gm_bluehills_test3"] = {
        pos = Vector(-2202, -5032, -1087),
		size = Vector(768, 768, 0),
	},
}
if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]


local RippleScreen = {}
RippleScreen.pos = setting.pos
RippleScreen.size = setting.size
RippleScreen.fps = 85/60
RippleScreen.tileSize = 64
RippleScreen.mapSize = RippleScreen.size / RippleScreen.tileSize

local tileColors = {}
local prevColors = {}

for yi=1, RippleScreen.mapSize.y do
	table.insert(tileColors, {})

	for xi=1, RippleScreen.mapSize.x do
		table.insert(tileColors, Color(0,0,0,0))
	end
end


local next_frame = 0
function updateRippleSimulation()
    local now = RealTime()
    if next_frame > now then return end
    next_frame = now + (1/RippleScreen.fps)

	for yi=1, RippleScreen.mapSize.y do

		for xi=1, RippleScreen.mapSize.x do

			tileColors[yi][xi] = ColorAlpha(HSVToColor( math.Rand(0, 360), 0.8, 0.9), 150)
		end
	end
end

hook.Add( "PostDrawOpaqueRenderables", "Canadia_Ripple", function()
	local pos = EyePos() - RippleScreen.pos
	local gridPosX = math.floor(pos.x / RippleScreen.tileSize) * RippleScreen.tileSize
	local gridPosY = math.floor(-pos.Y / RippleScreen.tileSize) * RippleScreen.tileSize
	local dt = RealFrameTime()

	updateRippleSimulation()

	cam.Start3D2D(RippleScreen.pos, Angle(), 1)

	for yi=0, RippleScreen.mapSize.y-1 do
		for xi=0, RippleScreen.mapSize.x-1 do
			local worldX = (xi - RippleScreen.mapSize.x/2) * RippleScreen.tileSize
			local worldY = (yi - RippleScreen.mapSize.y/2) * RippleScreen.tileSize

			if worldX==gridPosX and worldY==gridPosY then
				tileColors[yi+1][xi+1] = Color(255,255,255,200)
			end
			
			surface.SetDrawColor(tileColors[yi+1][xi+1])
			surface.DrawRect(worldX, worldY, RippleScreen.tileSize, RippleScreen.tileSize)
		end
	end
	cam.End3D2D()
end)
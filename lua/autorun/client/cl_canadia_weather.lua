local settings = {
    ["gm_novenka"] = {
        pos = Vector(1314, 7890, -312),
        ang = Angle(0, 45, 90),
        dir = Vector(1,-1,0)},
    ["gm_bluehills_test3"] = {
        pos = Vector(800, -1108, 348),
        ang = Angle(0,90,90),
        dir = Vector(1,0,0)},
}

if settings[ game.GetMap() ] == nil then return end

local setting = settings[ game.GetMap() ]


local weatherScreenSize  = Vector(160, 96)
local weatherScreenScale = 0.25

local renderDistance  = 1500
local refreshRate = 15 * 60 -- 15 minutes

weatherScreenSize = weatherScreenSize / weatherScreenScale
renderDistance = renderDistance * renderDistance

surface.CreateFont( "WeatherLG", { font = "Roboto", size = 16 / weatherScreenScale} )
surface.CreateFont( "WeatherMD", { font = "Roboto", size = 10 / weatherScreenScale} )
surface.CreateFont( "WeatherSM", { font = "Roboto", size =  7 / weatherScreenScale} )
surface.CreateFont( "WeatherXS", { font = "Roboto", size =  4 / weatherScreenScale} )


local weatherMats = {
    ["01d"] = Material("weather/01d.png"),
    ["02d"] = Material("weather/02d.png"),
    ["03d"] = Material("weather/03d.png"),
    ["04d"] = Material("weather/04d.png"),
    ["09d"] = Material("weather/09d.png"),
    ["10d"] = Material("weather/10d.png"),
    ["11d"] = Material("weather/11d.png"),
    ["13d"] = Material("weather/13d.png"),
    ["50d"] = Material("weather/50d.png"),
}

--if global weatherdata exists, use it
weatherData = weatherData or {} 
weatherDataLastUpdated = weatherDataLastUpdated or 0

local function obtainWeatherData()
    net.Start("Canadia_WeatherData")
    net.SendToServer()
end

net.Receive("Canadia_WeatherData", function(len)
    local data = net.ReadTable()

    if data.valid == true then
        weatherData = data
        weatherDataLastUpdated = SysTime()
        weatherData.timestamp  = os.date("Last Updated %X")

        print("[Canadia] Weather Data Obtained ("..len.." bits)")
        
    else
        timer.Remove("Canadia_GetWeather")
    end
end)

timer.Create("Canadia_GetWeather", 1, 0, function()
    if not IsValid(LocalPlayer()) then return end

    if SysTime() - weatherDataLastUpdated > 900 or table.Count(weatherData) == 0 then
        obtainWeatherData()
    else
        timer.Adjust("Canadia_GetWeather", 900, 0, obtainWeatherData)
    end
end)

local margin = 8 / weatherScreenScale
local gridX = weatherScreenSize.x / 7

hook.Add( "PostDrawTranslucentRenderables", "Canadia_Weather_Screen", function()
	local viewingDiff  = setting.pos - EyePos()
	local viewingAngle = viewingDiff:Dot(setting.dir)

	if viewingAngle > 0 then return end

    //if EyePos().y < setting.pos.y then return end

    cam.Start3D2D( setting.pos, setting.ang, weatherScreenScale)

    --start at the top left
    x = -weatherScreenSize.x / 2
    y = -weatherScreenSize.y / 2


    draw.RoundedBoxEx(margin, x, y, weatherScreenSize.x, margin*2, Color(88,176,98,220), true, true, false, false)
    draw.RoundedBoxEx(margin, x, y + margin*2, weatherScreenSize.x, weatherScreenSize.y - margin*2, Color(97,130,176,220), false, false, true, true)
    
    if EyePos():DistToSqr(setting.pos) > renderDistance then
        draw.SimpleText("Come Closer...", "WeatherLG", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
        return
    end

    if weatherData.valid == nil or weatherData.valid == false then
        draw.SimpleText("Loading...", "WeatherLG", 0, margin/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
        return
    end
    
    draw.SimpleText(weatherData.location, "WeatherMD", x + margin, y + margin, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    y = y + margin * 2
    surface.SetMaterial( weatherMats[ weatherData.icon ] )
    surface.SetDrawColor(Color(255,255,255))
    surface.DrawTexturedRect(-36/weatherScreenScale, y, 36/weatherScreenScale, 36/weatherScreenScale)

    y = y + 22 / weatherScreenScale
    x = 0//x + 96 / weatherScreenScale + margin*2
    draw.SimpleText(weatherData.temperature, "WeatherLG", x, y, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(weatherData.description, "WeatherSM", x, y, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)


    surface.SetDrawColor(Color(255,255,255))
    y = weatherScreenSize.y / 2 - 36 / weatherScreenScale
    x = -weatherScreenSize.x / 2 - gridX/2
    for i, datum in ipairs( weatherData.forecast ) do
        x = x + gridX
        draw.SimpleText(datum.time, "WeatherSM", x, y, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(datum.tmax, "WeatherXS", x, y + margin/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetMaterial( weatherMats[ datum.icon ] )
        surface.DrawTexturedRect(x - margin*1.5, y + margin*0.25, margin*3, margin*3)
        //draw.SimpleText(datum.desc, "WeatherXS", x, y + margin*2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(datum.tmin, "WeatherXS", x, y + margin*3, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if i ~= #weatherData.forecast then
            surface.DrawLine(x + gridX/2, y - margin/2, x + gridX/2, y + margin*3.5)
        end
    end
    

    draw.DrawText("Weather data is based on IP geolocation, which may vary from your actual location.", "DermaDefault", -weatherScreenSize.x/2 + margin, weatherScreenSize.y/2 - 16, Color(255,255,255), TEXT_ALIGN_LEFT)
    draw.DrawText(weatherData.timestamp, "DermaDefault", weatherScreenSize.x/2 - margin, weatherScreenSize.y/2 - 16, Color(255,255,255), TEXT_ALIGN_RIGHT)
    cam.End3D2D()
end)

print("[Canadia] Weather Panel Loaded")
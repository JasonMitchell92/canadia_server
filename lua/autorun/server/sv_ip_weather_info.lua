resource.AddFile("materials/weather/01d.png")
resource.AddFile("materials/weather/02d.png")
resource.AddFile("materials/weather/03d.png")
resource.AddFile("materials/weather/04d.png")
resource.AddFile("materials/weather/09d.png")
resource.AddFile("materials/weather/10d.png")
resource.AddFile("materials/weather/11d.png")
resource.AddFile("materials/weather/13d.png")
resource.AddFile("materials/weather/50d.png")

util.AddNetworkString("Canadia_WeatherData")

playerData = playerData or {}

local function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end
local function celtofar(num)
    return tostring(math.Round((num * 1.8) + 32)) .. "°F"
end
local weatherCodes = {
    [0]  = "Clear Sky",
    
    [1]  = "Mainly Clear",
    [2]  = "Partly Cloudy",
    [3]  = "Overcast",
    
    [45] = "Fog",
    [48] = "Depositing Rime Fog",
    
    [51] = "Light Drizzle",
    [53] = "Moderate Drizzle",
    [55] = "Heavy Drizzle",
    
    [56] = "Light Freezing Drizzle",
    [57] = "Heavy Freezing Drizzle",

    [61] = "Slight Rain",
    [63] = "Moderate Rain",
    [65] = "Heavy Rain",

    [66] = "Light Freezing Rain",
    [67] = "Heavy Freezing Rain",

    [71] = "Slight Snowfall",
    [73] = "Moderate Snowfall",
    [75] = "Heavy Snowfall",

    [77] = "Snow Grains",

    [80] = "Slight Rain Showers",
    [81] = "Moderate Rain Showers",
    [82] = "Violent Rain Showers",

    [85] = "Slight Snow Showers",
    [86] = "Heavy Snow Showers",

    [95] = "Thunderstorm",
    [96] = "Thunderstorm and Slight Hail",
    [96] = "Thunderstorm and Heavy Hail"
}

local weatherIcons = {
    [0]  = "01",
    [1]  = "02",
    [2]  = "03",
    [3]  = "04",
    
    [45] = "50",
    [48] = "50",
    
    [51] = "10",
    [53] = "10",
    [55] = "10",
    
    [56] = "10",
    [57] = "10",

    [61] = "09",
    [63] = "09",
    [65] = "09",

    [66] = "09",
    [67] = "09",

    [71] = "13",
    [73] = "13",
    [75] = "13",

    [77] = "13",

    [80] = "09",
    [81] = "09",
    [82] = "09",

    [85] = "13",
    [86] = "13",

    [95] = "11",
    [96] = "11",
    [96] = "11"
}

local function returnWeatherData(ply, data)
    print("[Canadia] Sending Weather Data to "..ply:Nick())
    
    net.Start("Canadia_WeatherData")
    net.WriteTable(data)
    net.Send(ply)
end


local function obtainWeatherData(ply)
    if not IsValid(ply) or not ply:IsPlayer() then 
        return
    end

    local plyData = playerData[ ply:SteamID64() ]

    if not plyData then
        establishLocationData( ply )
        return 
    end
    
    local url = "https://api.open-meteo.com/v1/forecast?latitude=" .. plyData.lat .. "&longitude=" .. plyData.lon .. "&current_weather=true&daily=weathercode,temperature_2m_max,temperature_2m_min&timeformat=unixtime&timezone=GMT"
        
    local weatherData = {
        location = plyData.city .. ", " .. plyData.region,
        valid    = false,
    }

    print(url)

    http.Fetch(url, function(body, size, headers, code)
        
        json = util.JSONToTable(body)

        if tobool(json.error) then
            print('HTTP Fetch error: '..json.reason)

            returnWeatherData(ply, weatherData)
            return
        end

        local tempC = tonumber( json.current_weather.temperature )

        weatherData.description = weatherCodes[ json.current_weather.weathercode ] or "Unknown"
        weatherData.temperature = celtofar( tempC ) .. "/" .. tostring( math.Round(tempC) ) .. "°C"
        weatherData.icon = weatherIcons[ json.current_weather.weathercode ] .. "d"

        weatherData.forecast = {}
        for i=1, 7 do
            table.insert(weatherData.forecast, {
                time = os.date("%a %d", tonumber(json.daily.time[i])),
                icon = weatherIcons[ json.daily.weathercode[i] ] .. "d",
                tmax = celtofar( json.daily.temperature_2m_max[i] ) .. "/" .. tostring( math.Round( json.daily.temperature_2m_max[i] ) ) .. "°C",
                tmin = celtofar( json.daily.temperature_2m_min[i] ) .. "/" .. tostring( math.Round( json.daily.temperature_2m_min[i] ) ) .. "°C",
            })
        end

        weatherData.valid = true 

        returnWeatherData(ply, weatherData)

    end, function(err)
        print("Error retrieving weather data for "..ply:Nick().." : "..err)
        print("URL: "..url)

        returnWeatherData(ply, weatherData)
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

        playerData[ ply:SteamID64() ] = {
            country = json.country,
            region  = json.region,
            city    = json.city,
            lat     = lat,
            lon     = lon,
        }

        ply:SetPData("Country", json.country)

        obtainWeatherData(ply) --first time send

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

net.Receive("Canadia_WeatherData", function(len, ply)
    obtainWeatherData(ply)
end)

net.Receive("Canadia_GlobePlayerDataRequest", function(len, ply)
    local data = {}

    for steamid64, datum in pairs(playerData) do
        table.insert(data, {
            lat = datum.lat,
            lon = datum.lon,
        })
    end

    net.Start("Canadia_GlobePlayerDataRequest")
    net.WriteTable(data)
    net.Send(ply)
end)
/*

local COLORS = {
    text      = Color(46, 49, 75), //Color(76, 79, 105), --primary text
    subtext1  = Color(92, 95, 119), --secondary text
    subtext0  = Color(108, 111, 133), 

    overlay2  = Color(124, 127, 147),
    overlay1  = Color(140, 143, 161),
    overlay0  = Color(156, 160, 176), --toast

    surface2  = Color(172, 176, 190),
    surface1  = Color(188, 192, 204),
    surface0  = Color(204, 208, 218), --disabled text

    base      = Color(239, 241, 245), --dividers
    mantle    = Color(230, 233, 239, 70), --primary background
    crust     = Color(220, 224, 232), --sidebar background
    
    rosewater = Color(220, 138, 120),
    flamingo  = Color(221, 120, 120),
    pink      = Color(234, 118, 203),
    mauve     = Color(136, 57, 239),
    red       = Color(210, 15, 57), --error / off
    maroon    = Color(230, 69, 83),
    peach     = Color(254, 100, 11),
    yellow    = Color(223, 142, 29), --warning
    green     = Color(64, 160, 43), --success / on
    teal      = Color(23, 146, 153),
    sky       = Color(4, 165, 229), --accent
    sapphire  = Color(32, 159, 181),
    blue      = Color(30, 102, 245), --info
    lavender  = Color(114, 135, 253),
    white     = Color(255,255,255),
}
*/
local COLORS = {
    text      = Color(255, 255, 255), //Color(76, 79, 105), --primary text
    subtext1  = Color(92, 95, 119), --secondary text
    subtext0  = Color(108, 111, 133), 

    overlay2  = Color(147, 153, 178),
    overlay1  = Color(127, 132, 156),
    overlay0  = Color(108, 112, 134), --toast

    surface2  = Color(88, 91, 112),
    surface1  = Color(69, 71, 90),
    surface0  = Color(49, 50, 68), --disabled text

    base      = Color(30, 30, 46), --dividers
    mantle    = Color(24, 24, 37, 250), --primary background
    crust     = Color(17, 17, 27), --sidebar background
    
    rosewater = Color(220, 138, 120),
    flamingo  = Color(221, 120, 120),
    pink      = Color(234, 118, 203),
    mauve     = Color(136, 57, 239),
    red       = Color(210, 15, 57), --error / off
    maroon    = Color(230, 69, 83),
    peach     = Color(254, 100, 11),
    yellow    = Color(223, 142, 29), --warning
    green     = Color(166, 227, 161), --success / on
    teal      = Color(23, 146, 153),
    sky       = Color(4, 165, 229), --accent
    sapphire  = Color(32, 159, 181),
    blue      = Color(30, 102, 245), --info
    lavender  = Color(114, 135, 253),
    white     = Color(255,255,255),
}

local rowHeight = 24

surface.CreateFont("CanadiaHUD_Main", {font = "Roboto Mono", size = rowHeight*1.1})

local ICONS = {
    heart = Material("canadia_hud/heart.png", "noclamp smooth"),
    armor = Material("canadia_hud/armor.png"),
    money = Material("canadia_hud/money.png"),
}
local ply = nil

local function prettyMoneyString(number)
    local formatted = string.format("%d", number)
    local k = string.reverse(formatted)
    local out = ""
    for i = 1, string.len(k) do
        out = out .. string.sub(k, i, i)
        if i % 3 == 0 and i ~= string.len(k) then
            out = out .. ","
        end
    end
    return string.reverse(out)
end


local function drawFilledBar(x, y, w, h, fillColor, value, text)
    
    draw.RoundedBox(6, x, y, w, h, COLORS.surface0)
    draw.RoundedBox(6, x, y, w * value, h, fillColor)

    if text then
        draw.SimpleText(text, "CanadiaHUD_Main", x + w/2, y + h/2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function drawImage(x, y, w, h, mat, clr)
    surface.SetMaterial(mat)
    surface.SetDrawColor(clr)
    surface.DrawTexturedRect(x, y, w, h)
end

local function DrawPlayerAvatar( x, y )
    
	plyImage = vgui.Create("AvatarImage")
	plyImage:SetPos(x, y)
	plyImage:SetSize(64, 64)
	plyImage:SetPlayer(ply, 64)
    plyImage:ParentToHUD()

    print("Player Avatar finished")
end

local HudPaintUsed = false

hook.Add("HUDPaintBackground", "CanadiaHUD_Render", function()
    if not ply then
        ply = LocalPlayer()
        if not ply then return end
    end
    
    HudPaintUsed = true

    local scrMargin = 20
    
    local boxSizeX = 340
    local boxSizeY = 184
    local boxMargin = 16
    local boxCornerRadius = 12
    
    local barWidth = boxSizeX - (boxMargin * 2) - (rowHeight * 1.5)

    local x = scrMargin
    local y = ScrH() - scrMargin - boxSizeY

    --draw the box
    draw.RoundedBox(6, x, y, boxSizeX, boxSizeY, COLORS.mantle)

    y = y + boxMargin
    /*

    if not plyImage then 
        DrawPlayerAvatar(scrMargin + boxMargin, ScrH() - scrMargin - boxSizeY + boxMargin)
    end
*/

    -- Draw the Player Name
    x = scrMargin + boxMargin*2 + rowHeight
    draw.SimpleText( ply:Nick(), "CanadiaHUD_Main", x, y + rowHeight*0.5, COLORS.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- Draw the Money Row
    x = scrMargin + boxMargin
    y = y + rowHeight + boxMargin
    drawImage(x, y, rowHeight, rowHeight, ICONS.money, COLORS.white)
    
    x = x + rowHeight + boxMargin
    local money = prettyMoneyString(util.JSONToTable( ply:GetNW2String(BitNet.NetVar.ClientTable)).money or 0)
    draw.SimpleText( "$" .. money, "CanadiaHUD_Main", x, y + rowHeight*0.5, COLORS.green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


    -- Draw the Health Row
    x = scrMargin + boxMargin
    y = y + rowHeight + boxMargin
    drawImage(x, y, rowHeight, rowHeight, ICONS.heart, COLORS.white)

    if ply:GetNWBool("Godmode") then
        drawFilledBar(x + rowHeight * 1.5, y, barWidth, rowHeight, COLORS.yellow, 1, "Godmode ON")
    else
        drawFilledBar(x + rowHeight * 1.5, y, barWidth, rowHeight, COLORS.maroon, math.min(ply:Health() / ply:GetMaxHealth(), 1), ply:Health() .. '/' .. ply:GetMaxHealth())
    end
    
    -- Draw the Armor Row
    y = y + rowHeight + boxMargin
    drawImage(x, y, rowHeight, rowHeight, ICONS.armor, COLORS.white)
    drawFilledBar(x + rowHeight * 1.5, y, barWidth, rowHeight, COLORS.teal, math.min(ply:Armor() / ply:GetMaxArmor(), 1), ply:Armor() .. '/' .. ply:GetMaxArmor())

end)

-- hide the normal hud below
local hide_hud = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
}
hook.Add("HUDShouldDraw", "CanadiaHUD_RemoveDefault", function(str)
    
    if hide_hud[str] then 
        return false
    end
end)

print("[Canadia] Loaded HUD")
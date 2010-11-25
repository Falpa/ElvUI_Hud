TukuiHudCF = {
  enabled = true,
  powerhud = true, -- show the power bar in the hud
  pethud = true, -- show the pet hud
  showthreat = true, -- show a threat bar next to the players hud
  showvalues = true, -- show text values
  unicolor = true, -- use a unicolor them
  showsmooth = true, -- show smooth bars
  hideooc = true, -- hide the hud out of combat
  height = 150, -- height of the HUD
  width = 15, -- width of the HUD
  offset = 125, -- offset from the center in pixels
  font = TukuiCF["media"].font,
  fontsize = 12,
  alpha = 1, -- alpha value of the HUD when fully visible
  oocalpha = 0, -- alpha value of the HUD when hidden out of combat if hideooc is true
}

if TukuiDB.myname == "Norinael" then
  TukuiHudCF.enabled = false
end

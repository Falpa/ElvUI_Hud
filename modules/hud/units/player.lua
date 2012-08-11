local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

function H:ConstructPlayerFrame(frame,unit)
	frame.unit = unit
	frame.Health = self:ConstructHealth(frame)

	frame.Power = self:ConstructPower(frame)

	frame.Castbar = self:ConstructCastbar(frame)

	frame.Name = self:ConstructName(frame)
		
	if E.db.hud.names then
		frame.Name:Show()
	else
		frame.Name:Hide()
	end

	if E.db.hud.classBars then
		if E.myclass == "DRUID" then
			frame.EclipseBar = self:ConstructEclipseBar(frame)
		end

		if E.myclass == "WARLOCK" then
			frame.WarlockSpecBars = self:ConstructWarlockSpecBars(frame)
		end

		if E.myclass == "PALADIN" then
			frame.HolyPower = self:ConstructHolyPower(frame)
		end

		if E.myclass == "DEATHKNIGHT" then
			frame.Runes = self:ConstructRunes(frame)
		end

		if E.myclass == "SHAMAN" then
			frame.Totems = self:ConstructTotems(frame)
		end

		if E.myclass == "MONK" then
			frame.HarmonyBar = self:ConstructHarmonyBar(frame)
		end

		if E.myclass == "PRIEST" then
			frame.ShadowOrbsBar = self:ConstructShadowOrbBar(frame)
		end

		if E.myclass == "MAGE" then
			frame.ArcaneChargeBar = self:ConstructArcaneBar(frame)
		end
	end

	if E.db.hud.showThreat then
		frame.Threat = self:ConstructThreat(frame)
	end
end

function H:UpdatePlayerAnchors(frame,unit)
	frame.Health:SetPoint("LEFT")
	frame.Health.value:SetPoint("TOPRIGHT", frame.Health, "TOPLEFT", E:Scale(-20), E:Scale(-15))
	frame.PowerFrame:SetPoint("LEFT", frame.Health, "RIGHT", E:Scale(4), 0)
	frame.Power.value:SetPoint("TOPLEFT", frame.Power, "TOPRIGHT", E:Scale(10), E:Scale(-15))
	if not E.db.hud.horizCastbar then
		frame.Castbar:SetPoint("BOTTOM", frame.PowerFrame, "BOTTOM")
	else
		frame.Castbar:SetPoint("CENTER", UIParent, "CENTER", 0, E:Scale(-75))
	end
	frame.Name:SetPoint("BOTTOM", frame.Health, "TOP", 0, E:Scale(15))

	if E.db.hud.classBars then
		if E.myclass == "DRUID" then
			frame.EclipseBar:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end

		if E.myclass == "WARLOCK" then
			frame.WarlockSpecBars:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
			frame.WarlockSpecBars.value:SetPoint("BOTTOMRIGHT", frame.WarlockSpecBars, "BOTTOMLEFT", E:Scale(-4), E:Scale(15))
		end

		if E.myclass == "PALADIN" then
			frame.HolyPower:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end

		if E.myclass == "DEATHKNIGHT" then
			frame.Runes:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end

		if E.myclass == "SHAMAN" then
			frame.Totems:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end

		if E.myclass == "MONK" then
			frame.HarmonyBar:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end

		if E.myclass == "PRIEST" then
			frame.ShadowOrbsBar:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end

		if E.myclass == "MAGE" then
			frame.ArcaneChargeBar:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", E:Scale(-6), 0)
		end
	end

	if E.db.hud.showThreat then
		frame.ThreatFrame:SetPoint("BOTTOMLEFT", frame.PowerFrame, "BOTTOMRIGHT", E:Scale(2), 0)
	end
end

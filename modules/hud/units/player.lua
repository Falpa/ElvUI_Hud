local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local UF = E:GetModule('UnitFrames');

function H:ConstructPlayerFrame(frame,unit)
	frame.unit = unit
	frame.Health = self:ConstructHealth(frame)

	frame.Power = self:ConstructPower(frame)

	frame.Castbar = self:ConstructCastbar(frame)

	frame.Name = self:ConstructName(frame)
		
	frame.AuraBars = self:ConstructAuraBarHeader(frame)
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

	frame.elements = { 'health', 'power', 'castbar', 'name', 'classbars', 'threat', 'aurabars' }

	frame:SetAlpha(E.db.hud.alpha)

    H:HideOOC(frame)
    frame:Point("RIGHT", E.UIParent, "CENTER", -275, 0) --Set to default position 
    E:CreateMover(frame, frame:GetName()..'Mover', 'Player Hud Frame', nil, nil, nil, 'ALL,SOLO')
end


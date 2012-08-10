local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

function H:ConstructTargetFrame(frame,unit)
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
        if E.myclass == "DRUID" or E.myclass == "ROGUE" then
            frame.CPoints = self:ConstructComboPoints(frame)
        end
    end
end

function H:UpdateTargetAnchors(frame,unit)
    frame.Health:SetPoint("RIGHT")
    frame.Health.value:SetPoint("LEFT", frame.Health, "RIGHT", E:Scale(20), 0)
    frame.PowerFrame:SetPoint("RIGHT", frame.Health, "LEFT", E:Scale(-4), 0)
    frame.Power.value:SetPoint("RIGHT", frame.Power, "LEFT", E:Scale(-4), 0)
    if not E.db.hud.horizCastbar then
        frame.Castbar:SetPoint("BOTTOM", self.PowerFrame, "BOTTOM")
    else
        frame.Castbar:SetPoint("TOP", oUF_Elv_player_Hud.Castbar, "BOTTOM", 0, E:Scale(-4))
    end
    frame.Name:SetPoint("BOTTOM", frame.Health, "TOP", 0, E:Scale(15))

    if E.db.hud.classBars then
        if E.myclass == "DRUID" or E.myclass == "ROGUE" then
            frame.CPoints:SetPoint("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", E:Scale(6), 0)
        end
    end
end

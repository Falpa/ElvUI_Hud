local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

function H:ConstructPetFrame(frame,unit)
    frame.unit = unit
    frame.Health = self:ConstructHealth(frame)

    frame.Power = self:ConstructPower(frame)

    frame.Castbar = self:ConstructCastbar(frame)
end

function H:UpdatePetAnchors(frame,unit)
    frame.Health:SetPoint("LEFT")
    frame.Health.value:SetPoint("RIGHT", frame.Health, "LEFT", E:Scale(-4), 0)
    frame.PowerFrame:SetPoint("LEFT", frame.Health, "RIGHT", E:Scale(4), 0)
    frame.Power.value:SetPoint("LEFT", frame.Power, "RIGHT", E:Scale(4), 0)
    frame.Castbar:SetPoint("BOTTOM", frame.PowerFrame, "BOTTOM")
end

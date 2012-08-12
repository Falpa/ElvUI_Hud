local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

function H:ConstructPetFrame(frame,unit)
    frame.unit = unit
    frame.Health = self:ConstructHealth(frame)

    frame.Name = self:ConstructName(frame)

    frame.Power = self:ConstructPower(frame)

    frame.Castbar = self:ConstructCastbar(frame)

    frame.elements = { 'health', 'power', 'castbar', 'name' }

    frame:SetAlpha(E.db.hud.alpha)
    frame:Size(P.hud.layout[frame.unit].width,P.hud.layout[frame.unit].height)
    H:HideOOC(frame)
    frame:Point("RIGHT", UIParent, "CENTER", -360, 0) --Set to default position 
    E:CreateMover(frame, frame:GetName()..'Mover', 'Target Hud Frame', nil, nil, nil, 'ALL,SOLO')
end


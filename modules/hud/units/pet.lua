local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

function H:ConstructPetFrame(frame,unit)
    frame.unit = unit
    frame.Health = self:ConstructHealth(frame)

    frame.Name = self:ConstructName(frame)

    frame.Power = self:ConstructPower(frame)

    frame.Castbar = self:ConstructCastbar(frame)
    frame.Castbar.SafeZone = nil
    frame.RaidIcon = self:ConstructRaidIcon(frame)
    
    frame:SetAlpha(E.db.hud.alpha)
    H:HideOOC(frame)
    frame:Point("BOTTOMRIGHT", ElvUF_PlayerHud, "BOTTOMLEFT", -80, 0)
    E:CreateMover(frame, frame:GetName()..'Mover', 'Pet Hud Frame', nil, nil, nil, 'ALL,SOLO')
end


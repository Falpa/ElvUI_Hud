local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local UF = E:GetModule('UnitFrames');

function H:ConstructTargetFrame(frame,unit)
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

    -- if E.db.hud.targetauras then
        frame.Buffs = self:ConstructBuffs(frame)
        frame.Debuffs = self:ConstructDebuffs(frame)
    -- end
    if E.db.hud.classBars then
        if E.myclass == "DRUID" or E.myclass == "ROGUE" then
            frame.CPoints = self:ConstructComboPoints(frame)
        end
    end

    frame.elements = { 'health', 'power', 'castbar', 'name', 'cpoints', 'aurabars' }
end

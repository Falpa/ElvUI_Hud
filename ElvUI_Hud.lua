
local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD')

function H:Initialize()
    H:Construct_Hud()
end

E:RegisterModule(H:GetName())


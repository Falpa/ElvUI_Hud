local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local function r(f) H:RegisterFrame(f) end;

function H:Construct_Health(frame)
	-- Health Bar
    local health = CreateFrame('StatusBar', nil, frame)
    health:SetWidth(H.width - 4)
    health:SetHeight(H.height - 4)
    health:SetStatusBarTexture(H.normTex)
    health:SetOrientation("VERTICAL")
    health:SetFrameLevel(frame:GetFrameLevel() + 5)

    -- Health Frame Border
    local HealthFrame = CreateFrame("Frame", nil, frame)
    HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", E:Scale(-2), E:Scale(2))
    HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    HealthFrame:SetFrameLevel(frame:GetFrameLevel() + 4)

    HealthFrame:SetTemplate("Default")
    HealthFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
    frame.FrameBorder = HealthFrame
    frame.FrameBorder:CreateShadow("Default")

    -- Health Bar Background
    local healthBG = health:CreateTexture(nil, 'BORDER')
    healthBG:SetAllPoints()
    healthBG:SetTexture(.1, .1, .1)
    healthBG:SetAlpha(.2)

	if E.db.hud.showValues then
		health.value = health:CreateFontString(nil, "THINOUTLINE") 			
        health.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
	end

	health.PostUpdate = H.PostUpdateHealth
    health.frequentUpdates = true

    -- Smooth Bar Animation
    if E.db.hud.smooth == true then
		health.Smooth = UF.db.smoothbars
		health.colorSmooth = true
	end

    -- Setup Colors
    if E.db.hud.unicolor ~= false then
        health.colorTapping = false
        health.colorClass = false
        health:SetStatusBarColor(unpack({ 0.05, 0.05, 0.05 }))
        health.colorDisconnected = false
    else
        health.colorTapping = true	
        health.colorClass = true
        health.colorReaction = true
        health.colorDisconnected = true		
    end
    
    r(health)
    return health, healthBG
end
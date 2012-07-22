local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local db = E.db.hud or P.hud

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local hud_height = E:Scale(db.height)
local hud_width = E:Scale(db.width)
local hud_power_width = E:Scale((hud_width/3)*2)

local normTex = LSM:Fetch("statusbar",db.texture)

function Construct_PetHealth(self,unit)
	-- Health Bar
    local health = CreateFrame('StatusBar', nil, self)
    health:SetWidth(hud_width - 4)
    health:SetHeight((hud_height * .75) - 4)
    health:SetPoint("LEFT", self, "LEFT")
    health:SetStatusBarTexture(normTex)
    health:SetOrientation("VERTICAL")
    health:SetFrameLevel(self:GetFrameLevel() + 5)
    self.health = health

    -- Health Frame Border
    local HealthFrame = CreateFrame("Frame", nil, self)
    HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", E:Scale(-2), E:Scale(2))
    HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

    HealthFrame:SetTemplate("Default")
    HealthFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
    self.FrameBorder = HealthFrame
    self.FrameBorder:CreateShadow("Default")

    -- Health Bar Background
    local healthBG = health:CreateTexture(nil, 'BORDER')
    healthBG:SetAllPoints()
    healthBG:SetTexture(.1, .1, .1)
    healthBG:SetAlpha(.1)
	if db.showValues then
		health.value = health:CreateFontString(nil, "THINOUTLINE") 			
        health.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "LEFT", E:Scale(-4), E:Scale(0))
	end
    health.PostUpdate = H.PostUpdateHealthHud
    self.Health = health
    self.Health.bg = healthBG
    health.frequentUpdates = true

    -- Smooth Bar Animation
    if db.smooth == true then
		health.Smooth = UF.db.smoothbars
		health.colorSmooth = true
	end

    -- Setup Colors
    if db.unicolor ~= false then
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
end

function Construct_PetPower(self,unit)
	-- Power Frame Border
    local PowerFrame = CreateFrame("Frame", nil, self)
    PowerFrame:SetHeight(hud_height * .75)
    PowerFrame:SetWidth(hud_power_width)
    PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
    PowerFrame:SetPoint("LEFT", self.Health, "RIGHT", E:Scale(4), 0)

    PowerFrame:SetTemplate("Default")
    PowerFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
    self.PowerFrame = PowerFrame
    self.PowerFrame:CreateShadow("Default")

    -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
    local power = CreateFrame('StatusBar', nil, self)
    power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", E.mult*2, -E.mult*2)
    power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -E.mult*2, E.mult*2)
    power:SetStatusBarTexture(normTex)
    power:SetOrientation("VERTICAL")
    power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

    -- Power Background
    local powerBG = power:CreateTexture(nil, 'BORDER')
    powerBG:SetAllPoints(power)
    powerBG:SetTexture(normTex)
    powerBG.multiplier = 0.3
	if db.showValues then
		power.value = power:CreateFontString(nil, "THINOUTLINE") 				
        power.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
		power.value:SetPoint("LEFT", power, "RIGHT", E:Scale(4), 0)
	end
    power.PreUpdate = H.PreUpdatePowerHud
    power.PostUpdate = H.PostUpdatePowerHud

    self.Power = power
    self.Power.bg = powerBG

    -- Update the Power bar Frequently
    power.frequentUpdates = true

    -- Setup Colors
	power.colorTapping = true	
	power.colorPower = true
	power.colorReaction = true
	power.colorDisconnected = true		
	
    -- Smooth Animation
    if db.smooth == true then
        power.Smooth = true
    end
end

local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local function r(f) H:RegisterFrame(f) end;

function Construct_TargetHealth(self,unit)
    local hud_height = E:Scale(E.db.hud.height)
    local hud_width = E:Scale(E.db.hud.width)
    local hud_power_width = E:Scale((hud_width/3)*2)

    local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	-- Health Bar
    local health = CreateFrame('StatusBar', nil, self)
    health:SetWidth(hud_width - 4)
    health:SetHeight(hud_height - 4)
    health:SetPoint("RIGHT", self, "RIGHT")
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
    healthBG:SetAlpha(.2)
	if E.db.hud.showValues then
		health.value = health:CreateFontString(nil, "THINOUTLINE") 			
        health.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		health.value:SetPoint("LEFT", health, "RIGHT", E:Scale(20), 0)
	end
    health.PostUpdate = H.PostUpdateHealth
    self.Health = health
    self.Health.bg = healthBG
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
 end

 function Construct_TargetPower(self,unit)
    local hud_height = E:Scale(E.db.hud.height)
    local hud_width = E:Scale(E.db.hud.width)
    local hud_power_width = E:Scale((hud_width/3)*2)

    local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

 	-- Power Frame Border
    local PowerFrame = CreateFrame("Frame", nil, self)
    PowerFrame:SetHeight(hud_height)
    PowerFrame:SetWidth(hud_power_width)
    PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
    PowerFrame:SetPoint("RIGHT", self.Health, "LEFT", E:Scale(-4), 0)

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
	if E.db.hud.showValues then
		power.value = power:CreateFontString(nil, "THINOUTLINE") 				
        power.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		power.value:SetPoint("RIGHT", power, "LEFT", E:Scale(-4), 0)
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
    if E.db.hud.smooth == true then
        power.Smooth = true
    end

    r(power)
 end

function Construct_TargetCastbar(self)
    local hud_width = E:Scale(E.db.hud.width)
    local hud_power_width = E:Scale((hud_width/3)*2)
    local hud_height = E:Scale(E.db.hud.height)

    local normTex = LSM:Fetch("statusbar",E.db.hud.texture)
    local castbar = CreateFrame("StatusBar", nil, self)

    castbar:SetWidth(hud_width - 4)
    castbar:SetHeight(hud_height - 4)
    castbar:SetPoint("BOTTOM", self.PowerFrame, "BOTTOM")
    castbar:SetStatusBarTexture(normTex)
    castbar:SetStatusBarColor(E.db.unitframe.units.player.castbar.color)
    castbar.PostCastStart = H.PostCastStart
    castbar.PostChannelStart = H.PostCastStart
    castbar.OnUpdate = H.CastbarUpdate
    --castbar.PostCastInterruptible = H.PostCastInterruptible
    --castbar.PostCastNotInterruptible = H.PostCastNotInterruptible
    castbar:SetOrientation("VERTICAL")
    castbar:SetFrameLevel(self:GetFrameLevel() + 9)
    castbar:SetClampedToScreen(true)
    castbar:CreateBackdrop('Default')
    
    castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
    castbar.Time:FontTemplate(LSM:Fetch("font",E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
    castbar.Time:Point("BOTTOM", castbar, "TOP", 0, 4)
    castbar.Time:SetTextColor(0.84, 0.75, 0.65)
    castbar.Time:SetJustifyH("RIGHT")
    
    castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
    castbar.Text:FontTemplate(LSM:Fetch("font",E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
    castbar.Text:SetPoint("TOP", castbar, "BOTTOM", 0, -4)
    castbar.Text:SetTextColor(0.84, 0.75, 0.65)
    
    castbar.Spark = castbar:CreateTexture(nil, 'OVERLAY')
    castbar.Spark:SetBlendMode('ADD')
    castbar.Spark:SetVertexColor(1, 1, 1)

    --Set to castbar.SafeZone
    castbar.LatencyTexture = castbar:CreateTexture(nil, "OVERLAY")
    castbar.LatencyTexture:SetTexture(normTex)
    castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)   

    local button = CreateFrame("Frame", nil, castbar)
    button:SetTemplate("Default")
    
    button:Point("BOTTOM", castbar, "BOTTOM", 0, 0)
    
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:Point("TOPLEFT", button, 2, -2)
    icon:Point("BOTTOMRIGHT", button, -2, 2)
    icon:SetTexCoord(0.08, 0.92, 0.08, .92)
    icon.bg = button
    
    --Set to castbar.Icon
    castbar.ButtonIcon = icon

    self.Castbar = castbar
end

 function Construct_ComboPoints(self,unit)
    local hud_height = E:Scale(E.db.hud.height)
    local hud_width = E:Scale(E.db.hud.width)
    local hud_power_width = E:Scale((hud_width/3)*2)

    local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

 	-- Setup combo points
	local bars = CreateFrame("Frame", nil, self)
	bars:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", E:Scale(6), 0)
	bars:SetWidth(hud_width-8)
	bars:SetHeight(hud_height-4)
	bars:SetTemplate("Default")
	bars:SetBackdropBorderColor(0,0,0,0)
	bars:SetBackdropColor(0,0,0,0)
	
	for i = 1, 5 do					
		bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, self)
		bars[i]:SetHeight((E:Scale(hud_height - 4) - 4)/5)					
		bars[i]:SetStatusBarTexture(normTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
						
		if i == 1 then
			bars[i]:SetPoint("BOTTOM", bars)
		else
			bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
		end
		bars[i]:SetAlpha(0.15)
		bars[i]:SetWidth(hud_width-8)
		bars[i]:SetOrientation('VERTICAL')
        r(bars[i])
	end
	
	bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
	bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
	bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
	bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
	bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
	

	self.CPoints = bars
	self.CPoints.Override = H.ComboDisplay
	
	bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
	bars.FrameBackdrop:SetTemplate("Default")
	bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", E:Scale(-2), E:Scale(2))
	bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
	bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
	self:RegisterEvent("UNIT_DISPLAYPOWER", H.ComboDisplay)
end


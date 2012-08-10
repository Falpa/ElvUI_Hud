local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local function r(f) H:RegisterFrame(f) end;

function Construct_PlayerHealth(self, unit)
    local hud_width = E:Scale(E.db.hud.width)
    local hud_power_width = E:Scale((hud_width/3)*2)
    local hud_height = E:Scale(E.db.hud.height)

    local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	-- Health Bar
    local health = CreateFrame('StatusBar', nil, self)
    health:SetWidth(hud_width - 4)
    health:SetHeight(hud_height - 4)
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
    healthBG:SetAlpha(.2)

	if E.db.hud.showValues then
		health.value = health:CreateFontString(nil, "THINOUTLINE") 			
        health.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		health.value:SetPoint("TOPRIGHT", health, "TOPLEFT", E:Scale(-20), E:Scale(-15))
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

function Construct_PlayerCastbar(self)
	local hud_width = E:Scale(E.db.hud.width)
    local hud_power_width = E:Scale((hud_width/3)*2)
    local hud_height = E:Scale(E.db.hud.height)

    local normTex = LSM:Fetch("statusbar",E.db.hud.texture)
	local castbar = CreateFrame("StatusBar", nil, self)

	if not E.db.hud.horizCastbar then
		castbar:SetWidth(hud_width - 4)
	    castbar:SetHeight(hud_height - 4)
	    castbar:SetPoint("BOTTOM", self.PowerFrame, "BOTTOM")
	    castbar:SetStatusBarTexture(normTex)
	    castbar:SetStatusBarColor(E.db.unitframe.units.player.castbar.color)
	    castbar.PostCastStart = H.PostCastStart
		castbar.PostChannelStart = H.PostChannelStart
		castbar.OnUpdate = H.CastbarUpdate
		--castbar.PostCastInterruptible = H.PostCastInterruptible
		--castbar.PostCastNotInterruptible = H.PostCastNotInterruptible
	    castbar:SetOrientation("VERTICAL")
	    castbar:SetFrameStrata(self.Power:GetFrameStrata())
		castbar:SetFrameLevel(self.Power:GetFrameLevel()+2)
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
		castbar.SafeZone = castbar.LatencyTexture
		castbar.LatencyTexture:Show()

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
		castbar:HookScript("OnShow", function(self) if E.db.hud.hideOOC and not InCombatLockdown() then H:Hide(self:GetParent(),"PLAYER_REGEN_DISABLED") end end)
		castbar:HookScript("OnHide", function(self) if E.db.hud.hideOOC and not InCombatLockdown() then H:Hide(self:GetParent(),"PLAYER_REGEN_ENABLED") end end)
		self.Castbar = castbar
	else
		-- castbar of player and target
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetWidth(E:Scale(hud_height * 2))
	    castbar:SetHeight(26)
		castbar:SetFrameLevel(6)
	    castbar:SetPoint("CENTER", UIParent, "CENTER", 0, E:Scale(-75))

		castbar:CreateBackdrop('Default')
		
		castbar.CustomTimeText = H.CustomCastTimeText
		castbar.CustomDelayText = H.CustomCastDelayText
		castbar.PostCastStart = H.CheckCast
		castbar.PostChannelStart = H.CheckCast

		castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
		castbar.Time:FontTemplate(LSM:Fetch("font",E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		castbar.Time:SetPoint("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		castbar.Time:SetJustifyH("RIGHT")
		
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Size(26)
		castbar.button:SetTemplate("Default")
		castbar.button:CreateShadow("Default")

		castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
		castbar.Text:FontTemplate(LSM:Fetch("font",E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		castbar.Text:SetPoint("LEFT", castbar.button, "RIGHT", 4, 0)

		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
	
		castbar.button:SetPoint("LEFT")
	
		-- cast bar latency on player
		castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
		castbar.safezone:SetTexture(normTex)
		castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		castbar.SafeZone = castbar.safezone
				
		self.Castbar = castbar
		self.Castbar.Icon = castbar.icon
	end
end

function Construct_PlayerPower(self, unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)
	
	-- Power Frame Border
    local PowerFrame = CreateFrame("Frame", nil, self)
    PowerFrame:SetHeight(hud_height)
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
    powerBG:SetTexture(.1,.1,.1)
    powerBG.multiplier = 0.3
	if E.db.hud.showValues then
		power.value = power:CreateFontString(nil, "THINOUTLINE") 				
        power.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		power.value:SetPoint("TOPLEFT", power, "TOPRIGHT", E:Scale(10), E:Scale(-15))
	end
    power.PreUpdate = H.PreUpdatePowerHud
    power.PostUpdate = H.PostUpdatePowerHud

    self.Power = power
    self.Power.bg = powerBG

    -- Update the Power bar Frequently
    power.frequentUpdates = true

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

function Construct_Name(self,unit)
	local name = self:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
	name:SetPoint("BOTTOM", self.Health, "TOP", 0, E:Scale(15))
	if unit == 'player' then
		self:Tag(name, '[level] [shortclassification] [Elv:getnamecolor][Elv:namelong] [Elv:diffcolor]')
	elseif unit == 'target' then
		self:Tag(name, '[Elv:getnamecolor][Elv:namelong] [Elv:diffcolor][level] [shortclassification]')
	else
		self:Tag(name, '[Elv:getnamecolor][Elv:namemedium]')
	end
	self.Name = name
end

function Construct_EclipseBar(self,unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	local eclipseBar = CreateFrame('Frame', nil, self)
	eclipseBar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", E:Scale(-6), 0)
	eclipseBar:SetSize(hud_width-8, hud_height-4)
	eclipseBar:SetFrameStrata("MEDIUM")
	eclipseBar:SetFrameLevel(8)
	eclipseBar:SetTemplate("Default")
	eclipseBar:SetBackdropBorderColor(0,0,0,0)
					
	local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
	lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
	lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
	lunarBar:SetStatusBarTexture(normTex)
	lunarBar:SetStatusBarColor(.30, .52, .90)
	lunarBar:SetOrientation('VERTICAL')
	eclipseBar.LunarBar = lunarBar

	local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
	solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
	solarBar:SetStatusBarTexture(normTex)
	solarBar:SetStatusBarColor(.80, .82,  .60)
	solarBar:SetOrientation('VERTICAL')
	eclipseBar.SolarBar = solarBar
	
	local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
	eclipseBarText:SetPoint("LEFT", eclipseBar, "RIGHT", E:Scale(10), 0)
	eclipseBarText:FontTemplate(LSM:Fetch("font",E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
	
	eclipseBar.PostUpdatePower = H.EclipseDirection
	self.EclipseBar = eclipseBar
	self.EclipseBar.Text = eclipseBarText
	
	eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
	eclipseBar.FrameBackdrop:SetTemplate("Default")
	eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", E:Scale(-2), E:Scale(2))
	eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)

	r(eclipseBar)
end

function Construct_Shards(self,unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	local bars = CreateFrame("Frame", nil, self)
	bars:SetHeight(hud_height-4)
	bars:SetWidth(hud_width-8)
	bars:SetFrameLevel(self:GetFrameLevel() + 5)
	bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", E:Scale(-6), 0)
	bars:SetTemplate("Default")
	bars:SetBackdropBorderColor(0,0,0,0)
	
	for i = 1, 3 do					
		bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
		bars[i]:SetWidth(hud_width-8)			
		bars[i]:SetStatusBarTexture(normTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)

		bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
		
		bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
		bars[i].bg:SetTexture(148/255, 130/255, 201/255)
		
		if i == 1 then
			bars[i]:SetPoint("BOTTOM", bars)
		else
			bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
		end
		
		bars[i]:SetOrientation('VERTICAL')
		bars[i].bg:SetAllPoints(bars[i])
		bars[i]:SetHeight(E:Scale(((hud_height - 4) - 2)/3))
		
		bars[i].bg:SetTexture(normTex)					
		bars[i].bg:SetAlpha(.15)
		r(bars[i])
	end
	
	bars.Override = H.UpdateShards				
	self.SoulShards = bars

	bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
	bars.FrameBackdrop:SetTemplate("Default")
	bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
	bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
end

function Construct_HolyPower(self,unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	local bars = CreateFrame("Frame", nil, self)
	bars:SetHeight(hud_height-4)
	bars:SetWidth(hud_width-8)
	bars:SetFrameLevel(self:GetFrameLevel() + 5)
	bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", E:Scale(-6), 0)
	bars:SetTemplate("Default")
	bars:SetBackdropBorderColor(0,0,0,0)
	
	for i = 1, 3 do					
		bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
		bars[i]:SetWidth(hud_width-8)			
		bars[i]:SetStatusBarTexture(normTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)

		bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
		
		bars[i]:SetStatusBarColor(228/255,225/255,16/255)
		bars[i].bg:SetTexture(228/255,225/255,16/255)
		
		if i == 1 then
			bars[i]:SetPoint("BOTTOM", bars)
		else
			bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
		end
		
		bars[i]:SetOrientation('VERTICAL')
		bars[i].bg:SetAllPoints(bars[i])
		bars[i]:SetHeight(E:Scale(((hud_height - 4) - 2)/3))
		
		bars[i].bg:SetTexture(normTex)					
		bars[i].bg:SetAlpha(.15)
		r(bars[i])
	end
	
	bars.Override = H.UpdateHoly
	self.HolyPower = bars

	bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
	bars.FrameBackdrop:SetTemplate("Default")
	bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
	bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
end

function Construct_Runes(self,unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	local Runes = CreateFrame("Frame", nil, self)
	Runes:SetHeight(hud_height-4)
	Runes:SetWidth(hud_width-8)
	Runes:SetFrameLevel(self:GetFrameLevel() + 5)
	Runes:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", E:Scale(-6), 0)
	Runes:SetTemplate("Default")
	Runes:SetBackdropBorderColor(0,0,0,0)

	for i = 1, 6 do
		Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
		Runes[i]:SetHeight(((hud_height - 4) - 5)/6)
		Runes[i]:SetWidth(hud_width-8)
		Runes[i]:SetFrameLevel(Runes:GetFrameLevel() + 1)

		if (i == 1) then
			Runes[i]:SetPoint("BOTTOM", Runes)
		else
			Runes[i]:SetPoint("BOTTOM", Runes[i-1], "TOP", 0, E:Scale(1))
		end
		Runes[i]:SetStatusBarTexture(normTex)
		Runes[i]:GetStatusBarTexture():SetHorizTile(false)
		Runes[i]:SetOrientation('VERTICAL')
		r(Runes[i])
	end
	
	Runes.FrameBackdrop = CreateFrame("Frame", nil, Runes)
	Runes.FrameBackdrop:SetTemplate("Default")
	Runes.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
	Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	Runes.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
	Runes.FrameBackdrop:CreateShadow("Default")
	self.Runes = Runes
end

function Construct_Totems(self,unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	local TotemBar = CreateFrame("Frame", nil, self)
	TotemBar.Destroy = true
	TotemBar:SetHeight(hud_height-4)
	TotemBar:SetWidth(hud_width-8)
	TotemBar:SetFrameLevel(self:GetFrameLevel() + 5)
	TotemBar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", E:Scale(-6), 0)

	TotemBar:SetBackdrop(backdrop)
	TotemBar:SetBackdropColor(0, 0, 0)

	for i = 1, 4 do
		TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
		TotemBar[i]:SetHeight(((hud_height - 4) - 3)/4)
		TotemBar[i]:SetWidth(hud_width - 8)
		TotemBar[i]:SetFrameLevel(TotemBar:GetFrameLevel()+1)

		if (i == 1) then
			TotemBar[i]:SetPoint("BOTTOM",TotemBar)
		else
			TotemBar[i]:SetPoint("BOTTOM", TotemBar[i-1], "TOP", 0, E:Scale(1))
		end
		TotemBar[i]:SetStatusBarTexture(normTex)
		TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
		TotemBar[i]:SetOrientation('VERTICAL')
		TotemBar[i]:SetBackdrop(backdrop)
		TotemBar[i]:SetBackdropColor(0, 0, 0)
		TotemBar[i]:SetMinMaxValues(0, 1)

		
		TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
		TotemBar[i].bg:SetAllPoints(TotemBar[i])
		TotemBar[i].bg:SetTexture(normTex)
		TotemBar[i].bg.multiplier = 0.3
		r(TotemBar[i])
	end


	TotemBar.FrameBackdrop = CreateFrame("Frame", nil, TotemBar)
	TotemBar.FrameBackdrop:SetTemplate("Default")
	TotemBar.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
	TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
	self.TotemBar = TotemBar
end

function Construct_Threat(self,unit)
	local hud_height = E:Scale(E.db.hud.height)
	local hud_width = E:Scale(E.db.hud.width)
	local hud_power_width = E:Scale((hud_width/3)*2)

	local normTex = LSM:Fetch("statusbar",E.db.hud.texture)

	-- Threat Bar Border
	local ThreatFrame = CreateFrame("Frame", nil, self)
	ThreatFrame:SetHeight(hud_height * .75)
	ThreatFrame:SetWidth(hud_power_width)
	ThreatFrame:SetFrameLevel(self:GetFrameLevel() + 4)
	ThreatFrame:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMRIGHT", E:Scale(2), 0)
	
	ThreatFrame:SetTemplate("Default")
    ThreatFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
    self.ThreatFrame = ThreatFrame
    self.ThreatFrame:CreateShadow("Default")
	local ThreatBar = CreateFrame("StatusBar", nil, self)
	
	ThreatBar:SetFrameLevel(ThreatFrame:GetFrameLevel() + 1)
	ThreatBar:SetPoint("TOPLEFT", ThreatFrame, E:Scale(2), E:Scale(-2))
	ThreatBar:SetPoint("BOTTOMRIGHT", ThreatFrame, E:Scale(-2), E:Scale(2))

	ThreatBar:SetOrientation("VERTICAL")
	ThreatBar:SetStatusBarTexture(normTex)
	ThreatBar:SetBackdrop(backdrop)
	ThreatBar:SetBackdropColor(0, 0, 0, 0)

	if E.db.hud.showValues then
		ThreatBar.Text = ThreatBar:CreateFontString(nil, "THINOUTLINE") 				
        ThreatBar.Text:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
		ThreatBar.Text:SetPoint("LEFT", ThreatBar, "RIGHT", E:Scale(10), 0)
	end

	ThreatBar.bg = ThreatBar:CreateTexture(nil, 'BORDER')
	ThreatBar.bg:SetAllPoints(ThreatBar)
	ThreatBar.bg:SetTexture(0.1,0.1,0.1)

	ThreatBar.useRawThreat = false
	self.ThreatBar = ThreatBar
	r(ThreatBar)
end

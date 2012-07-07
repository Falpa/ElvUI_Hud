if not ElvUIHudCF.enabled == true then return end

local E, L, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local db = ElvUIHudCF
local normTex = [[Interface\AddOns\ElvUI_Hud\normTexVert]]

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local hud_height = E:Scale(ElvUIHudCF.height)
local hud_width = E:Scale(ElvUIHudCF.width)
local hud_power_width = E:Scale((hud_width/3)*2)

-- Hud layout function (Simple Layout)
-- Simple layout health bar
local function SimpleHealth(self, unit)
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
	healthBG:SetAlpha(.1)
	if db.showvalues then
		health.value = health:CreateFontString(nil, "THINOUTLINE")
        health.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
		health.value:SetPoint("BOTTOMRIGHT", health, "BOTTOMLEFT", E:Scale(-5), E:Scale(5))
	end
	health.PostUpdate = ElvUIHud.PostUpdateHealthHud
	self.Health = health
	self.Health.bg = healthBG
	health.frequentUpdates = true

	-- Smooth Bar Animation
	if db.showsmooth == true then
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
	
	if ElvUIHudCF.classspecificbars and unit == "player" then
		if E.myclass == "DRUID" then
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
			eclipseBarText:SetFont(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
			
			eclipseBar.PostUpdatePower = ElvUIHud.EclipseDirection
			self.EclipseBar = eclipseBar
			self.EclipseBar.Text = eclipseBarText
			
			eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
            eclipseBar.FrameBackdrop:SetTemplate("Default")
			eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", E:Scale(-2), E:Scale(2))
			eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
			eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)

		end
		
		-- set holy power bar or shard bar
		if (E.myclass == "WARLOCK" or E.myclass == "PALADIN") then
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
				
				if E.myclass == "WARLOCK" then
					bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
					bars[i].bg:SetTexture(148/255, 130/255, 201/255)
				elseif E.myclass == "PALADIN" then
					bars[i]:SetStatusBarColor(228/255,225/255,16/255)
					bars[i].bg:SetTexture(228/255,225/255,16/255)
				end
				
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
			end
			
			if E.myclass == "WARLOCK" then
				bars.Override = UF.UpdateShards				
				self.SoulShards = bars
			elseif E.myclass == "PALADIN" then
				bars.Override = UF.UpdateHoly
				self.HolyPower = bars
			end
			bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
			bars.FrameBackdrop:SetTemplate("Default")
			bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
			bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
			bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		end
		
		-- deathknight runes
		if E.myclass == "DEATHKNIGHT" then
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
			
		-- shaman totem bar
		if E.myclass == "SHAMAN" then
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
				TotemBar[i]:SetOrientation('ORIENTATION')
				TotemBar[i]:SetBackdrop(backdrop)
				TotemBar[i]:SetBackdropColor(0, 0, 0)
				TotemBar[i]:SetMinMaxValues(0, 1)

				
				TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
				TotemBar[i].bg:SetAllPoints(TotemBar[i])
				TotemBar[i].bg:SetTexture(normTex)
				TotemBar[i].bg.multiplier = 0.3
			end


			TotemBar.FrameBackdrop = CreateFrame("Frame", nil, TotemBar)
			TotemBar.FrameBackdrop:SetTemplate("Default")
			TotemBar.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
			TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
			TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
			self.TotemBar = TotemBar
		end
		
		if E.myclass == "DRUID" or E.myclass == "ROGUE" then
			-- Setup combo points
			local bars = CreateFrame("Frame", nil, self)
			bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", E:Scale(-6), 0)
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
			end
			
			bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
			bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
			bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
			bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
			bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
			

			self.CPoints = bars
			self.CPoints.Override = ElvUIHud.ComboDisplay
			
			bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
			bars.FrameBackdrop:SetTemplate("Default")
			bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", E:Scale(-2), E:Scale(2))
			bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
			bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
			bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
			self:RegisterEvent("UNIT_DISPLAYPOWER", ElvUIHud.ComboDisplay)
		end
	end
end

-- Simple layout power bar
local function SimplePower(self, unit)
	-- Power Bar
	local power = CreateFrame('StatusBar', nil, self)
	power:SetWidth(hud_width - 4)
	power:SetHeight(hud_height - 4)
	power:SetPoint("LEFT", self, "LEFT")
	power:SetStatusBarTexture(normTex)
	power:SetOrientation("VERTICAL")
	power:SetFrameLevel(self:GetFrameLevel() + 5)
	self.power = power

	-- Power Frame Border
	local PowerFrame = CreateFrame("Frame", nil, self)
	PowerFrame:SetPoint("TOPLEFT", power, "TOPLEFT", E:Scale(-2), E:Scale(2))
	PowerFrame:SetPoint("BOTTOMRIGHT", power, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
	PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)

	PowerFrame:SetTemplate("Default")
	PowerFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
	self.FrameBorder = PowerFrame
	self.FrameBorder:CreateShadow("Default")

	-- Power Background
	local powerBG = power:CreateTexture(nil, 'BORDER')
	powerBG:SetAllPoints(power)
	powerBG:SetTexture(normTex)
	powerBG.multiplier = 0.3
	if ElvUIHudCF.showvalues then
		power.value = power:CreateFontString(nil, "THINOUTLINE") 		
        power.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
		power.value:SetPoint("BOTTOMLEFT", power, "BOTTOMRIGHT", E:Scale(5), E:Scale(5))
	end
	power.PreUpdate = ElvUIHud.PreUpdatePowerHud
	power.PostUpdate = ElvUIHud.PostUpdatePowerHud

	self.Power = power
	self.Power.bg = powerBG

	-- Update the Power bar Frequently
	power.frequentUpdates = true

	power.colorTapping = true	
	power.colorPower = true
	power.colorReaction = true
	power.colorDisconnected = true		
	
	-- Smooth Animation
	if db.showsmooth == true then
		power.Smooth = true
	end
end

-- Hud layout function (Normal Layout)
local function Hud(self, unit)
    -- Set Colors
    self.colors = ElvUF["colors"]

    -- Update all elements on show
    self:HookScript("OnShow", ElvUIHud.updateAllElements)
	self:EnableMouse(false) -- HUD should be click-through

    -- For Testing..
    --[[self:SetBackdrop(backdrop)
    self:SetBackdropColor(0, 0, 0)]]

    -- Border for non Player/Target frames
   
    ------------------------------------------------------------------------
    --	Player
    ------------------------------------------------------------------------
    if unit == "player" then
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
        healthBG:SetAlpha(.1)
		if db.showvalues then
			health.value = health:CreateFontString(nil, "THINOUTLINE") 			
            health.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
			health.value:SetPoint("TOPRIGHT", health, "TOPLEFT", E:Scale(-20), E:Scale(-15))
		end
        health.PostUpdate = ElvUIHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
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

        if ElvUIHudCF.powerhud then
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
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if ElvUIHudCF.showvalues then
				power.value = power:CreateFontString(nil, "THINOUTLINE") 				
                power.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
				power.value:SetPoint("TOPLEFT", power, "TOPRIGHT", E:Scale(10), E:Scale(-15))
			end
            power.PreUpdate = ElvUIHud.PreUpdatePowerHud
            power.PostUpdate = ElvUIHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

			power.colorTapping = true	
			power.colorPower = true
			power.colorReaction = true
			power.colorDisconnected = true		
			
            -- Smooth Animation
            if db.showsmooth == true then
                power.Smooth = true
            end
        end
		
		if ElvUIHudCF.classspecificbars then
			if E.myclass == "DRUID" then
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
				eclipseBarText:FontTemplate(LSM:Fetch("font",db.font), db.fontsize, "THINOUTLINE")
				
				eclipseBar.PostUpdatePower = ElvUIHud.EclipseDirection
				self.EclipseBar = eclipseBar
				self.EclipseBar.Text = eclipseBarText
				
				eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
				eclipseBar.FrameBackdrop:SetTemplate("Default")
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", E:Scale(-2), E:Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
				eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)

			end
			
			-- set holy power bar or shard bar
			if (E.myclass == "WARLOCK" or E.myclass == "PALADIN") then
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
					
					if E.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
						bars[i].bg:SetTexture(148/255, 130/255, 201/255)
					elseif E.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
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
				end
				
				if E.myclass == "WARLOCK" then
					bars.Override = UF.UpdateShards				
					self.SoulShards = bars
				elseif E.myclass == "PALADIN" then
					bars.Override = UF.UpdateHoly
					self.HolyPower = bars
				end
				bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
				bars.FrameBackdrop:SetTemplate("Default")
				bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
			end
			
			-- deathknight runes
			if E.myclass == "DEATHKNIGHT" then
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
				
			-- shaman totem bar
			if E.myclass == "SHAMAN" then
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
				end


				TotemBar.FrameBackdrop = CreateFrame("Frame", nil, TotemBar)
				TotemBar.FrameBackdrop:SetTemplate("Default")
				TotemBar.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
				TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
				TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
				self.TotemBar = TotemBar
			end
		end
		
		if ElvUIHudCF.showthreat then
			-- Threat Bar Border
			local ThreatFrame = CreateFrame("Frame", nil, self)
			ThreatFrame:SetHeight(hud_height * .75)
			ThreatFrame:SetWidth(hud_power_width)
			ThreatFrame:SetFrameLevel(self:GetFrameLevel() + 4)
			if ElvUIHudCF.powerhud then
				ThreatFrame:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMRIGHT", E:Scale(2), 0)
			else
				ThreatFrame:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", E:Scale(4), 0)
			end
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
		
			if ElvUIHudCF.showvalues then
				ThreatBar.Text = ThreatBar:CreateFontString(nil, "THINOUTLINE") 				
                ThreatBar.Text:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
				ThreatBar.Text:SetPoint("LEFT", ThreatBar, "RIGHT", E:Scale(10), 0)
			end

			ThreatBar.bg = ThreatBar:CreateTexture(nil, 'BORDER')
			ThreatBar.bg:SetAllPoints(ThreatBar)
			ThreatBar.bg:SetTexture(0.1,0.1,0.1)

			ThreatBar.useRawThreat = false
			self.ThreatBar = ThreatBar
		end
    elseif unit == "target" then
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
		if ElvUIHudCF.showvalues then
			health.value = health:CreateFontString(nil, "THINOUTLINE") 			
            health.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
			health.value:SetPoint("LEFT", health, "RIGHT", E:Scale(20), 0)
		end
        health.PostUpdate = ElvUIHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
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
		end
		
		bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		

		self.CPoints = bars
		self.CPoints.Override = ElvUIHud.ComboDisplay
		
		bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
		bars.FrameBackdrop:SetTemplate("Default")
		bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", E:Scale(-2), E:Scale(2))
		bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
		bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
		self:RegisterEvent("UNIT_DISPLAYPOWER", ElvUIHud.ComboDisplay)

        if ElvUIHudCF.powerhud then
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
			if ElvUIHudCF.showvalues then
				power.value = power:CreateFontString(nil, "THINOUTLINE") 				
                power.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
				power.value:SetPoint("RIGHT", power, "LEFT", E:Scale(-4), 0)
			end
            power.PreUpdate = ElvUIHud.PreUpdatePowerHud
            power.PostUpdate = ElvUIHud.PostUpdatePowerHud

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
            if db.showsmooth == true then
                power.Smooth = true
            end
        end
    else
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
		if ElvUIHudCF.showvalues then
			health.value = health:CreateFontString(nil, "THINOUTLINE") 			
            health.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
			health.value:SetPoint("RIGHT", health, "LEFT", E:Scale(-4), E:Scale(0))
		end
        health.PostUpdate = ElvUIHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
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

        if ElvUIHudCF.powerhud then
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
			if ElvUIHudCF.showvalues then
				power.value = power:CreateFontString(nil, "THINOUTLINE") 				
                power.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
				power.value:SetPoint("LEFT", power, "RIGHT", E:Scale(4), 0)
			end
            power.PreUpdate = ElvUIHud.PreUpdatePowerHud
            power.PostUpdate = ElvUIHud.PostUpdatePowerHud

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
            if db.showsmooth == true then
                power.Smooth = true
            end
		end
		
		if unit == "pet" then
			self:RegisterEvent("UNIT_PET", ElvUIHud.updateAllElements)
		end
	end
end

ElvUF:RegisterStyle('ElvHud',Hud)
ElvUF:RegisterStyle('ElvHudSimpleHealth',SimpleHealth)
ElvUF:RegisterStyle('ElvHudSimplePower',SimplePower)
ElvUF:SetActiveStyle('ElvHud')

if ElvUIHudCF.warningText then
	ElvUIHud.CreateWarningFrame()
end

if ElvUIHudCF.simpleLayout then	
	local alpha = ElvUIHudCF.alpha
	
	ElvUF:SetActiveStyle('ElvHudSimpleHealth')
	local player_health = ElvUF:Spawn('player', "oUF_Elv_player_HudHealth")
	player_health:SetPoint("RIGHT", UIParent, "CENTER", E:Scale(-ElvUIHudCF.offset), 0)
	player_health:SetSize(hud_width, hud_height)
	player_health:SetAlpha(alpha)

	ElvUIHud.HideOOC(player_health)
	
	if ElvUIHudCF.simpleTarget then
		local target_health = ElvUF:Spawn('target', "oUF_Elv_target_HudHealth")
		target_health:SetPoint("LEFT", player_health, "RIGHT", E:Scale(15) + hud_width, 0)
		target_health:SetSize(hud_width, hud_height)
		target_health:SetAlpha(alpha)
		
		ElvUIHud.HideOOC(target_health)
	end
	
	ElvUF:SetActiveStyle('ElvHudSimplePower')
	local player_power = ElvUF:Spawn('player', "oUF_Elv_player_HudPower")
	player_power:SetPoint("LEFT", UIParent, "CENTER", E:Scale(ElvUIHudCF.offset), 0)
	player_power:SetSize(hud_width, hud_height)
	player_power:SetAlpha(alpha)
	
	ElvUIHud.HideOOC(player_power)
	
	if ElvUIHudCF.simpleTarget then
		local target_power = ElvUF:Spawn('target', "oUF_Elv_target_HudPower")
		target_power:SetPoint("RIGHT", player_power, "LEFT", E:Scale(-15) - hud_width, 0)
		target_power:SetSize(hud_width, hud_height)
		target_power:SetAlpha(alpha)
		
		ElvUIHud.HideOOC(target_power)
	end
else
	local width = hud_width
	if ElvUIHudCF.powerhud then
		width = width + hud_power_width + 2
	end

	if ElvUIHudCF.showthreat then
		width = width + hud_power_width + 2
	end

	local alpha = ElvUIHudCF.alpha

	local player_hud = ElvUF:Spawn('player', "oUF_Elv_player_Hud")
	player_hud:SetPoint("RIGHT", UIParent, "CENTER", E:Scale(-ElvUIHudCF.offset), 0)
	player_hud:SetSize(width, hud_height)
	player_hud:SetAlpha(alpha)

	ElvUIHud.HideOOC(player_hud)

	width = hud_width
	if ElvUIHudCF.powerhud then
		width = width + hud_power_width + 2
	end

	local target_hud = ElvUF:Spawn('target', "oUF_Elv_target_Hud")
	target_hud:SetPoint("LEFT", UIParent, "CENTER", E:Scale(ElvUIHudCF.offset), 0)
	target_hud:SetSize(width, hud_height)
	target_hud:SetAlpha(alpha)

	ElvUIHud.HideOOC(target_hud)

	if ElvUIHudCF.pethud then
		width = hud_width
		if ElvUIHudCF.powerhud then
			width = width + hud_power_width + 2
		end

		local pet_hud = ElvUF:Spawn('pet', "oUF_Elv_pet_Hud")
		pet_hud:SetPoint("BOTTOMRIGHT", oUF_Elv_player_Hud, "BOTTOMLEFT", -E:Scale(80), 0)
		pet_hud:SetSize(width, hud_height * .75)
		pet_hud:SetAlpha(alpha)
		
		ElvUIHud.HideOOC(pet_hud)
	end
	
	if ElvUIHudCF.tothud then
		width = hud_width
		if ElvUIHudCF.powerhud then
			width = width + hud_power_width + 2
		end

		local tot_hud = ElvUF:Spawn('targettarget', "oUF_Elv_targettarget_Hud")
		tot_hud:SetPoint("BOTTOMLEFT", oUF_Elv_target_Hud, "BOTTOMRIGHT", E:Scale(80), 0)
		tot_hud:SetSize(width, hud_height * .75)
		tot_hud:SetAlpha(alpha)
		
		ElvUIHud.HideOOC(tot_hud)
	end
	
	if ElvUIHudCF.focushud then
		width = hud_width
		if ElvUIHudCF.powerhud then
			width = width + hud_power_width + 2
		end
		
		local frame = oUF_Elv_player_Hud
		if ElvUIHudCF.pethud then
			frame = oUF_Elv_pet_Hud
		end
		
		local focus_hud = ElvUF:Spawn('focus', "oUF_Elv_focus_Hud")
		focus_hud:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -E:Scale(80), 0)
		focus_hud:SetSize(width, hud_height * .75)
		focus_hud:SetAlpha(alpha)
		
		ElvUIHud.HideOOC(focus_hud)
	end
end

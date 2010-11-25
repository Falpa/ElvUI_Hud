if not TukuiHudCF.enabled == true then return end

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local db = TukuiHudCF
local normTex = TukuiCF["media"].normTex
local glowTex = TukuiCF["media"].glowTex
local bubbleTex = TukuiCF["media"].bubbleTex

local backdrop = {
	bgFile = TukuiCF["media"].blank,
	insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult},
}

local hud_height = TukuiDB.Scale(TukuiHudCF.height)
local hud_width = TukuiDB.Scale(TukuiHudCF.width)
local hud_power_width = TukuiDB.Scale((hud_width/3)*2)

-- Hud bars
local function Hud(self, unit)
    -- Set Colors
    self.colors = TukuiDB.oUF_colors

    -- Update all elements on show
    self:HookScript("OnShow", TukuiHud.updateAllElements)
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
        HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
        HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
        HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

        TukuiDB.SetTemplate(HealthFrame)
        HealthFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
        self.FrameBorder = HealthFrame
        TukuiDB.CreateShadow(self.FrameBorder)

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.1)
		if db.showvalues then
			health.value = TukuiDB.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
			if db.classpecificbars and (TukuiDB.myclass == "DRUID" or 
				TukuiDB.myclass == "PALADIN" or TukuiDB.myclass == "WARLOCK" or 
				TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "DEATHKNIGHT") then
				health.value:SetPoint("BOTTOM", health, "TOP", 0, TukuiDB.Scale(4))
			else
				health.value:SetPoint("RIGHT", health, "LEFT", TukuiDB.Scale(-4), TukuiDB.Scale(0))
			end
		end
        health.PostUpdate = TukuiHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
            health.Smooth = true
        end

        -- Setup Colors
        if db.unicolor ~= false then
            health.colorTapping = false
            health.colorClass = false
            health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor or { 0.05, 0.05, 0.05 }))
            health.colorDisconnected = false
        else
            health.colorTapping = true	
            health.colorClass = true
            health.colorReaction = true
            health.colorDisconnected = true		
        end

        if TukuiHudCF.powerhud then
            -- Power Frame Border
            local PowerFrame = CreateFrame("Frame", nil, self)
            PowerFrame:SetHeight(hud_height)
            PowerFrame:SetWidth(hud_power_width)
            PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
            PowerFrame:SetPoint("LEFT", self.Health, "RIGHT", TukuiDB.Scale(4), 0)

            TukuiDB.SetTemplate(PowerFrame)
            PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
            self.PowerFrame = PowerFrame
            TukuiDB.CreateShadow(self.PowerFrame)

            -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
            local power = CreateFrame('StatusBar', nil, self)
            power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
            power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
            power:SetStatusBarTexture(normTex)
            power:SetOrientation("VERTICAL")
            power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

            -- Power Background
            local powerBG = power:CreateTexture(nil, 'BORDER')
            powerBG:SetAllPoints(power)
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if TukuiHudCF.showvalues then
				power.value = TukuiDB.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
				if TukuiHudCF.showthreat then
					power.value:SetPoint("TOPLEFT", power, "TOPRIGHT", TukuiDB.Scale(10), TukuiDB.Scale(-15))
				else
					power.value:SetPoint("LEFT", power, "RIGHT", TukuiDB.Scale(10), 0)
				end
			end
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

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
		
		if TukuiHudCF.classspecificbars then
			if TukuiDB.myclass == "DRUID" then
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", TukuiDB.Scale(-6), 0)
				eclipseBar:SetSize(hud_width-8, hud_height-4)
				eclipseBar:SetFrameStrata("MEDIUM")
				eclipseBar:SetFrameLevel(8)
				TukuiDB.SetTemplate(eclipseBar)
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
				eclipseBarText:SetPoint("LEFT", eclipseBar, "RIGHT", TukuiDB.Scale(10), 0)
				eclipseBarText:SetFont(db.font, db.fontsize, "THINOUTLINE")
				
				eclipseBar.PostUpdatePower = TukuiHud.EclipseDirection
				self.EclipseBar = eclipseBar
				self.EclipseBar.Text = eclipseBarText
				
				eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
				TukuiDB.SetTemplate(eclipseBar.FrameBackdrop)
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)

			end
			
			-- set holy power bar or shard bar
			if (TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "PALADIN") then
				local bars = CreateFrame("Frame", nil, self)
				bars:SetHeight(hud_height-4)
				bars:SetWidth(hud_width-8)
				bars:SetFrameLevel(self:GetFrameLevel() + 5)
				bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", TukuiDB.Scale(-6), 0)
				TukuiDB.SetTemplate(bars)
				bars:SetBackdropBorderColor(0,0,0,0)
				
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
					bars[i]:SetWidth(hud_width-8)			
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)
					bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					
					if TukuiDB.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
						bars[i].bg:SetTexture(148/255, 130/255, 201/255)
					elseif TukuiDB.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("BOTTOM", bars)
					else
						bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, TukuiDB.Scale(1))
					end
					
					bars[i]:SetOrientation('VERTICAL')
					bars[i].bg:SetAllPoints(bars[i])
					bars[i]:SetHeight(TukuiDB.Scale(((hud_height - 4) - 2)/3))
					
					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.15)
				end
				
				if TukuiDB.myclass == "WARLOCK" then
					bars.Override = TukuiDB.UpdateShards				
					self.SoulShards = bars
				elseif TukuiDB.myclass == "PALADIN" then
					bars.Override = TukuiDB.UpdateHoly
					self.HolyPower = bars
				end
				bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
				TukuiDB.SetTemplate(bars.FrameBackdrop)
				bars.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
			end
			
			-- deathknight runes
			if TukuiDB.myclass == "DEATHKNIGHT" then
				local Runes = CreateFrame("Frame", nil, self)
				Runes:SetHeight(hud_height-4)
				Runes:SetWidth(hud_width-8)
				Runes:SetFrameLevel(self:GetFrameLevel() + 5)
				Runes:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", TukuiDB.Scale(-6), 0)
				TukuiDB.SetTemplate(Runes)
				Runes:SetBackdropBorderColor(0,0,0,0)

				for i = 1, 6 do
					Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
					Runes[i]:SetHeight(((hud_height - 4) - 5)/6)
					Runes[i]:SetWidth(hud_width-8)
					Runes[i]:SetFrameLevel(Runes:GetFrameLevel() + 1)

					if (i == 1) then
						Runes[i]:SetPoint("BOTTOM", Runes)
					else
						Runes[i]:SetPoint("BOTTOM", Runes[i-1], "TOP", 0, TukuiDB.Scale(1))
					end
					Runes[i]:SetStatusBarTexture(normTex)
					Runes[i]:GetStatusBarTexture():SetHorizTile(false)
					Runes[i]:SetOrientation('VERTICAL')
				end
				
				Runes.FrameBackdrop = CreateFrame("Frame", nil, Runes)
				TukuiDB.SetTemplate(Runes.FrameBackdrop)
				Runes.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				Runes.FrameBackdrop:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))
				Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
				TukuiDB.CreateShadow(Runes.FrameBackdrop)
				self.Runes = Runes
			end
				
			-- shaman totem bar
			if TukuiDB.myclass == "SHAMAN" then
				local TotemBar = CreateFrame("Frame", nil, self)
				TotemBar.Destroy = true
				TotemBar:SetHeight(hud_height-4)
				TotemBar:SetWidth(hud_width-8)
				TotemBar:SetFrameLevel(self:GetFrameLevel() + 5)
				TotemBar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", TukuiDB.Scale(-6), 0)

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
						TotemBar[i]:SetPoint("BOTTOM", TotemBar[i-1], "TOP", 0, TukuiDB.Scale(1))
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
				TukuiDB.SetTemplate(TotemBar.FrameBackdrop)
				TotemBar.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))
				TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
				self.TotemBar = TotemBar
			end
		end
		
		if TukuiHudCF.showthreat then
			-- Threat Bar Border
			local ThreatFrame = CreateFrame("Frame", nil, self)
			ThreatFrame:SetHeight(hud_height * .75)
			ThreatFrame:SetWidth(hud_power_width)
			ThreatFrame:SetFrameLevel(self:GetFrameLevel() + 4)
			if TukuiHudCF.powerhud then
				ThreatFrame:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMRIGHT", TukuiDB.Scale(2), 0)
			else
				ThreatFrame:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", TukuiDB.Scale(4), 0)
			end
			TukuiDB.SetTemplate(ThreatFrame)
            ThreatFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
            self.ThreatFrame = ThreatFrame
            TukuiDB.CreateShadow(self.ThreatFrame)
			local ThreatBar = CreateFrame("StatusBar", nil, self)
			
			ThreatBar:SetFrameLevel(ThreatFrame:GetFrameLevel() + 1)
			ThreatBar:SetPoint("TOPLEFT", ThreatFrame, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			ThreatBar:SetPoint("BOTTOMRIGHT", ThreatFrame, TukuiDB.Scale(-2), TukuiDB.Scale(2))

			ThreatBar:SetOrientation("VERTICAL")
			ThreatBar:SetStatusBarTexture(normTex)
			ThreatBar:SetBackdrop(backdrop)
			ThreatBar:SetBackdropColor(0, 0, 0, 0)
		
			if TukuiHudCF.showvalues then
				ThreatBar.Text = TukuiDB.SetFontString(ThreatBar, db.font, db.fontsize)
				ThreatBar.Text:SetPoint("LEFT", ThreatBar, "RIGHT", TukuiDB.Scale(10), 0)
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
        HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
        HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
        HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

        TukuiDB.SetTemplate(HealthFrame)
        HealthFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
        self.FrameBorder = HealthFrame
        TukuiDB.CreateShadow(self.FrameBorder)

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.2)
		if TukuiHudCF.showvalues then
			health.value = TukuiDB.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
			health.value:SetPoint("LEFT", health, "RIGHT", TukuiDB.Scale(10), 0)
		end
        health.PostUpdate = TukuiHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
            health.Smooth = true
        end

        -- Setup Colors
        if db.unicolor ~= false then
            health.colorTapping = false
            health.colorClass = false
            health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor or { 0.05, 0.05, 0.05 }))
            health.colorDisconnected = false
        else
            health.colorTapping = true	
            health.colorClass = true
            health.colorReaction = true
            health.colorDisconnected = true		
        end
		
		-- Setup combo points
		local bars = CreateFrame("Frame", nil, self)
		bars:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", TukuiDB.Scale(6), 0)
		bars:SetWidth(hud_width-4)
		bars:SetHeight(hud_height-4)
		TukuiDB.SetTemplate(bars)
		bars:SetBackdropBorderColor(0,0,0,0)
		bars:SetBackdropColor(0,0,0,0)
		
		for i = 1, 5 do					
			bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, self)
			bars[i]:SetHeight(TukuiDB.Scale(hud_height - 4)/5)					
			bars[i]:SetStatusBarTexture(normTex)
			bars[i]:GetStatusBarTexture():SetHorizTile(false)
							
			if i == 1 then
				bars[i]:SetPoint("BOTTOM", bars)
			else
				bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, TukuiDB.Scale(1))
			end
			bars[i]:SetAlpha(0.15)
			bars[i]:SetWidth(hud_width-4)
			bars[i]:SetOrientation('VERTICAL')
		end
		
		bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		

		self.CPoints = bars
		self.CPoints.Override = TukuiHud.ComboDisplay
		
		bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
		TukuiDB.SetTemplate(bars.FrameBackdrop)
		bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		bars.FrameBackdrop:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
		self:RegisterEvent("UNIT_DISPLAYPOWER", TukuiDB.ComboDisplay)

        if TukuiHudCF.powerhud then
            -- Power Frame Border
            local PowerFrame = CreateFrame("Frame", nil, self)
            PowerFrame:SetHeight(hud_height)
            PowerFrame:SetWidth(hud_power_width)
            PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
            PowerFrame:SetPoint("RIGHT", self.Health, "LEFT", TukuiDB.Scale(-4), 0)

            TukuiDB.SetTemplate(PowerFrame)
            PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
            self.PowerFrame = PowerFrame
            TukuiDB.CreateShadow(self.PowerFrame)

            -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
            local power = CreateFrame('StatusBar', nil, self)
            power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
            power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
            power:SetStatusBarTexture(normTex)
            power:SetOrientation("VERTICAL")
            power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

            -- Power Background
            local powerBG = power:CreateTexture(nil, 'BORDER')
            powerBG:SetAllPoints(power)
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if TukuiHudCF.showvalues then
				power.value = TukuiDB.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
				power.value:SetPoint("RIGHT", power, "LEFT", TukuiDB.Scale(-4), 0)
			end
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

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
        HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
        HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
        HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

        TukuiDB.SetTemplate(HealthFrame)
        HealthFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
        self.FrameBorder = HealthFrame
        TukuiDB.CreateShadow(self.FrameBorder)

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.1)
		if TukuiHudCF.showvalues then
			health.value = TukuiDB.SetFontString(health, db.font, db.fontsize , "THINOUTLINE")
			health.value:SetPoint("RIGHT", health, "LEFT", TukuiDB.Scale(-4), TukuiDB.Scale(0))
		end
        health.PostUpdate = TukuiHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
            health.Smooth = true
        end

        -- Setup Colors
        if db.unicolor ~= false then
            health.colorTapping = false
            health.colorClass = false
            health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor or { 0.05, 0.05, 0.05 }))
            health.colorDisconnected = false
        else
            health.colorTapping = true	
            health.colorClass = true
            health.colorReaction = true
            health.colorDisconnected = true		
        end

        if TukuiHudCF.powerhud then
            -- Power Frame Border
            local PowerFrame = CreateFrame("Frame", nil, self)
            PowerFrame:SetHeight(hud_height * .75)
            PowerFrame:SetWidth(hud_power_width)
            PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
            PowerFrame:SetPoint("LEFT", self.Health, "RIGHT", TukuiDB.Scale(4), 0)

            TukuiDB.SetTemplate(PowerFrame)
            PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor or TukuiCF["media"].bordercolor))	
            self.PowerFrame = PowerFrame
            TukuiDB.CreateShadow(self.PowerFrame)

            -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
            local power = CreateFrame('StatusBar', nil, self)
            power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
            power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
            power:SetStatusBarTexture(normTex)
            power:SetOrientation("VERTICAL")
            power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

            -- Power Background
            local powerBG = power:CreateTexture(nil, 'BORDER')
            powerBG:SetAllPoints(power)
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if TukuiHudCF.showvalues then
				power.value = TukuiDB.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
				power.value:SetPoint("LEFT", power, "RIGHT", TukuiDB.Scale(4), 0)
			end
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

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
		
		self:RegisterEvent("UNIT_PET", TukuiHud.updateAllElements)
	end
end

oUF:RegisterStyle('TukzHud',Hud)
oUF:SetActiveStyle('TukzHud')

local width = hud_width
if TukuiHudCF.powerhud then
	width = width + hud_power_width + 2
end

if TukuiHudCF.showthreat then
	width = width + hud_power_width + 2
end

local alpha = TukuiHudCF.alpha
local oocalpha = TukuiHudCF.oocalpha

local player_hud = oUF:Spawn('player', "oUF_Tukz_player_Hud")
player_hud:SetPoint("RIGHT", UIParent, "CENTER", TukuiDB.Scale(-TukuiHudCF.offset), 0)
player_hud:SetSize(width, hud_height)
player_hud:SetAlpha(alpha)

if TukuiHudCF.hideooc == true then
	local hud_hider = CreateFrame("Frame", nil, UIParent)
	hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
	hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
	hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
	hud_hider:SetScript("OnEvent", function(self, event)
		if (event == "PLAYER_REGEN_DISABLED") then
				UIFrameFadeIn(player_hud, 0.3 * (alpha - player_hud:GetAlpha()), player_hud:GetAlpha(), alpha)
		elseif (event == "PLAYER_REGEN_ENABLED") then
				UIFrameFadeOut(player_hud, 0.3 * (oocalpha + player_hud:GetAlpha()), player_hud:GetAlpha(), oocalpha)
		elseif (event == "PLAYER_ENTERING_WORLD") then
				if (not InCombatLockdown()) then
						player_hud:SetAlpha(oocalpha)
				end
		end
	end)
end


width = hud_width
if TukuiHudCF.powerhud then
	width = width + hud_power_width + 2
end

local target_hud = oUF:Spawn('target', "oUF_Tukz_target_Hud")
target_hud:SetPoint("LEFT", UIParent, "CENTER", TukuiDB.Scale(TukuiHudCF.offset), 0)
target_hud:SetSize(width, hud_height)
target_hud:SetAlpha(alpha)

if TukuiHudCF.hideooc == true then
	local hud_hider = CreateFrame("Frame", nil, UIParent)
	hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
	hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
	hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
	hud_hider:SetScript("OnEvent", function(self, event)
		if (event == "PLAYER_REGEN_DISABLED") then
				UIFrameFadeIn(target_hud, 0.3 * (alpha - target_hud:GetAlpha()), target_hud:GetAlpha(), alpha)
		elseif (event == "PLAYER_REGEN_ENABLED") then
				UIFrameFadeOut(target_hud, 0.3 * (oocalpha + target_hud:GetAlpha()), target_hud:GetAlpha(), oocalpha)
		elseif (event == "PLAYER_ENTERING_WORLD") then
				if (not InCombatLockdown()) then
						target_hud:SetAlpha(oocalpha)
				end
		end
	end)
end

if TukuiHudCF.pethud then
	width = hud_width
    if TukuiHudCF.powerhud then
        width = width + hud_power_width + 2
    end

    local pet_hud = oUF:Spawn('pet', "oUF_Tukz_pet_Hud")
    pet_hud:SetPoint("BOTTOMRIGHT", oUF_Tukz_player_Hud, "BOTTOMLEFT", TukuiDB.Scale(-width) - TukuiDB.Scale(15), 0)
    pet_hud:SetSize(width, hud_height * .75)
	pet_hud:SetAlpha(alpha)
	
	if TukuiHudCF.hideooc == true then
		local hud_hider = CreateFrame("Frame", nil, UIParent)
		hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
		hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
		hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
		hud_hider:SetScript("OnEvent", function(self, event)
			if (event == "PLAYER_REGEN_DISABLED") then
					UIFrameFadeIn(pet_hud, 0.3 * (alpha - pet_hud:GetAlpha()), pet_hud:GetAlpha(), alpha)
			elseif (event == "PLAYER_REGEN_ENABLED") then
					UIFrameFadeOut(pet_hud, 0.3 * (oocalpha + pet_hud:GetAlpha()), pet_hud:GetAlpha(), oocalpha)
			elseif (event == "PLAYER_ENTERING_WORLD") then
					if (not InCombatLockdown()) then
							pet_hud:SetAlpha(oocalpha)
					end
			end
		end)
	end
end

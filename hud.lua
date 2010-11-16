------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local db = TukuiHudCF
local font1 = TukuiCF["media"].uffont or TukuiCF["media"].font
local font2 = TukuiCF["media"].font
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
        HealthFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
        self.FrameBorder = HealthFrame
        TukuiDB.CreateShadow(self.FrameBorder)

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.1)
        health.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize , "THINOUTLINE")
        health.value:SetPoint("RIGHT", health, "LEFT", TukuiDB.Scale(-4), TukuiDB.Scale(0))
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
            health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))
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
            PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
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
            power.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
            power.value:SetPoint("LEFT", power, "RIGHT", TukuiDB.Scale(10), 0)
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

            -- Setup Colors
            if db.unicolor ~= false then
                power.colorTapping = true	
                power.colorClass = true
                power.colorReaction = true
                power.colorDisconnected = true		
            else
                power.colorDisconnected = true
                power.colorPower = true
                power.colorTapping = true
            end

            -- Smooth Animation
            if db.showsmooth == true then
                power.Smooth = true
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
            ThreatFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
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

			ThreatBar.Text = TukuiDB.SetFontString(ThreatBar, font2, 12)
			ThreatBar.Text:SetPoint("LEFT", ThreatBar, "RIGHT", TukuiDB.Scale(10), 0)

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
        HealthFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
        self.FrameBorder = HealthFrame
        TukuiDB.CreateShadow(self.FrameBorder)

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.2)
        health.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
        health.value:SetPoint("LEFT", health, "RIGHT", TukuiDB.Scale(10), 0)
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
            health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))
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
            PowerFrame:SetPoint("RIGHT", self.Health, "LEFT", TukuiDB.Scale(-4), 0)

            TukuiDB.SetTemplate(PowerFrame)
            PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
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
            power.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
            power.value:SetPoint("RIGHT", power, "LEFT", TukuiDB.Scale(-4), 0)
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

            -- Setup Colors
            if db.unicolor ~= false then
                power.colorTapping = true	
                power.colorClass = true
                power.colorReaction = true
                power.colorDisconnected = true		
            else
                power.colorDisconnected = true
                power.colorPower = true
                power.colorTapping = true
            end

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
        HealthFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
        self.FrameBorder = HealthFrame
        TukuiDB.CreateShadow(self.FrameBorder)

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.1)
        health.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize , "THINOUTLINE")
        health.value:SetPoint("RIGHT", health, "LEFT", TukuiDB.Scale(-4), TukuiDB.Scale(0))
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
            health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))
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
            PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
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
            power.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
            power.value:SetPoint("LEFT", power, "RIGHT", TukuiDB.Scale(4), 0)
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

            -- Setup Colors
            if db.unicolor ~= false then
                power.colorTapping = true	
                power.colorClass = true
                power.colorReaction = true
                power.colorDisconnected = true		
            else
                power.colorDisconnected = true
                power.colorPower = true
                power.colorTapping = true
            end

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

local player_hud = oUF:Spawn('player', "oUF_Tukz_player_Hud")
player_hud:SetPoint("CENTER", UIParent, "CENTER", TukuiDB.Scale(-100), 0)
player_hud:SetSize(width, hud_height)

if TukuiHudCF.hideooc == true then
	local hud_hider = CreateFrame("Frame", nil, UIParent)
	hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
	hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
	hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
	hud_hider:SetScript("OnEvent", function(self, event)
		if (event == "PLAYER_REGEN_DISABLED") then
				UIFrameFadeIn(player_hud, 0.3 * (1 - player_hud:GetAlpha()), player_hud:GetAlpha(), 1)
		elseif (event == "PLAYER_REGEN_ENABLED") then
				UIFrameFadeOut(player_hud, 0.3 * (0 + player_hud:GetAlpha()), player_hud:GetAlpha(), 0)
		elseif (event == "PLAYER_ENTERING_WORLD") then
				if (not InCombatLockdown()) then
						player_hud:SetAlpha(0)
				end
		end
	end)
end


width = hud_width
if TukuiHudCF.powerhud then
	width = width + hud_power_width + 2
end

local target_hud = oUF:Spawn('target', "oUF_Tukz_target_Hud")
target_hud:SetPoint("CENTER", UIParent, "CENTER", TukuiDB.Scale(100), 0)
target_hud:SetSize(width, hud_height)

if TukuiHudCF.hideooc == true then
	local hud_hider = CreateFrame("Frame", nil, UIParent)
	hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
	hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
	hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
	hud_hider:SetScript("OnEvent", function(self, event)
		if (event == "PLAYER_REGEN_DISABLED") then
				UIFrameFadeIn(target_hud, 0.3 * (1 - target_hud:GetAlpha()), target_hud:GetAlpha(), 1)
		elseif (event == "PLAYER_REGEN_ENABLED") then
				UIFrameFadeOut(target_hud, 0.3 * (0 + target_hud:GetAlpha()), target_hud:GetAlpha(), 0)
		elseif (event == "PLAYER_ENTERING_WORLD") then
				if (not InCombatLockdown()) then
						target_hud:SetAlpha(0)
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
	
	if TukuiHudCF.hideooc == true then
		local hud_hider = CreateFrame("Frame", nil, UIParent)
		hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
		hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
		hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
		hud_hider:SetScript("OnEvent", function(self, event)
			if (event == "PLAYER_REGEN_DISABLED") then
					UIFrameFadeIn(pet_hud, 0.3 * (1 - pet_hud:GetAlpha()), pet_hud:GetAlpha(), 1)
			elseif (event == "PLAYER_REGEN_ENABLED") then
					UIFrameFadeOut(pet_hud, 0.3 * (0 + pet_hud:GetAlpha()), pet_hud:GetAlpha(), 0)
			elseif (event == "PLAYER_ENTERING_WORLD") then
					if (not InCombatLockdown()) then
							pet_hud:SetAlpha(0)
					end
			end
		end)
	end
end

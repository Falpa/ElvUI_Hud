TukuiHud = { }

TukuiHud.updateAllElements = function(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
end

TukuiHud.PostUpdateHealthHud = function(health, unit, min, max)
    local r, g, b

    -- overwrite healthbar color for enemy player (a tukui option if enabled), target vehicle/pet too far away returning unitreaction nil and friend unit not a player. (mostly for overwrite tapped for friendly)
    -- I don't know if we really need to call TukuiCF["unitframes"].unicolor but anyway, it's safe this way.
    if (TukuiCF["unitframes"].unicolor ~= true and TukuiCF["unitframes"].enemyhcolor and unit == "target" and UnitIsEnemy(unit, "player")) or (TukuiCF["unitframes"].unicolor ~= true and unit == "target" and not UnitIsPlayer(unit) and UnitIsFriend(unit, "player")) then
        local c = TukuiDB.oUF_colors.reaction[UnitReaction(unit, "player")]
        if c then 
            r, g, b = c[1], c[2], c[3]
            health:SetStatusBarColor(r, g, b)
        else
            -- if "c" return nil it's because it's a vehicle or pet unit too far away, we force friendly color
            -- this should fix color not updating for vehicle/pet too far away from yourself.
            r, g, b = 75/255,  175/255, 76/255
            health:SetStatusBarColor(r, g, b)
        end					
    end

	if TukuiHudCF.showvalues then
		health.value:SetText(format("%.f", min / max * 100).." %")
	end
	
    -- Flash health below threshold %
	if (min / max * 100) < (TukuiHudCF.lowThreshold) then
		TukuiHud.Flash(health, 0.6)
	end
end

TukuiHud.PreUpdatePowerHud = function(power, unit)
    local _, pType = UnitPowerType(unit)

    local color = TukuiDB.oUF_colors.power[pType]
    if color then
        power:SetStatusBarColor(color[1], color[2], color[3])
    end
end

TukuiHud.PostUpdatePowerHud = function(power, unit, min, max)
    local self = power:GetParent()
    local pType, pToken = UnitPowerType(unit)
    local color = TukuiDB.oUF_colors.power[pToken]

    if color and TukuiHudCF.showvalues then
        power.value:SetTextColor(color[1], color[2], color[3])
    end

    power.value:SetText(format("%.f",min / max * 100).." %")
	
	-- Flash mana below threshold %
	local powerMana, _ = UnitPowerType(unit)
	if (min / max * 100) < (TukuiHudCF.lowThreshold) and (powerMana == SPELL_POWER_MANA) then
		TukuiHud.Flash(power, 0.4)
	end
end

TukuiHud.ComboDisplay = function(self, event, unit)
	if(unit == 'pet') then return end
	
	local cpoints = self.CPoints
	local cp
	if(UnitExists'vehicle') then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
		else
			cpoints[i]:SetAlpha(0.15)
		end
	end
	
	if cpoints[1]:GetAlpha() == 1 then
		for i=1, MAX_COMBO_POINTS do
			cpoints[i]:Show()
		end
	else
		for i=1, MAX_COMBO_POINTS do
			cpoints[i]:Hide()
		end
	end
end

-- The following functions are thanks to Hydra from the Tukui forums
TukuiHud.SetUpAnimGroup = function(self)
    self.anim = self:CreateAnimationGroup("Flash")
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(1)
    self.anim.fadein:SetOrder(2)

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-1)
    self.anim.fadeout:SetOrder(1)
end

TukuiHud.Flash = function(self, duration)
    if not self.anim then
        TukuiHud.SetUpAnimGroup(self)
    end

    self.anim.fadein:SetDuration(duration)
    self.anim.fadeout:SetDuration(duration)
    self.anim:Play()
end

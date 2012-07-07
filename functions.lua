local E, L, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local HUD = E:NewModule('HUD', 'AceTimer-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0");

local db = ElvUIHudCF

ElvUIHud = { }
ElvUIHudDB = {
	warningTextShown = false,
}
ElvUIHud.updateAllElements = function(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
end

ElvUIHud.PostUpdateHealthHud = function(health, unit, min, max)
    local r, g, b

    -- overwrite healthbar color for enemy player (a tukui option if enabled), target vehicle/pet too far away returning unitreaction nil and friend unit not a player. (mostly for overwrite tapped for friendly)
    -- I don't know if we really need to call ElvUICF["unitframes"].unicolor but anyway, it's safe this way.
    if (db.unicolor ~= true and unit == "target" and UnitIsEnemy(unit, "player")) or (db.unicolor ~= true and unit == "target" and not UnitIsPlayer(unit) and UnitIsFriend(unit, "player")) then
        local c = ElvUF["colors"].reaction[UnitReaction(unit, "player")]
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

	if ElvUIHudCF.showvalues then
		health.value:SetText(format("%.f", min / max * 100).." %")
	end
	
    -- Flash health below threshold %
	if (min / max * 100) < (ElvUIHudCF.lowThreshold) then
		ElvUIHud.Flash(health, 0.6)
		if not ElvUIHudDB.warningTextShown and unit == "player" then
			ElvUIHudWarning:AddMessage("|cffff0000LOW HEALTH")
			ElvUIHudDB.warningTextShown = true
		else
			ElvUIHudWarning:Clear()
			ElvUIHudDB.warningTextShown = false
		end
	end
end

ElvUIHud.PreUpdatePowerHud = function(power, unit)
    local _, pType = UnitPowerType(unit)

    local color = ElvUF["colors"].power[pType]
    if color then
        power:SetStatusBarColor(color[1], color[2], color[3])
    end
end

ElvUIHud.PostUpdatePowerHud = function(power, unit, min, max)
    local self = power:GetParent()
    local pType, pToken = UnitPowerType(unit)
    local color = ElvUF["colors"].power[pToken]

    if color and ElvUIHudCF.showvalues then
        power.value:SetTextColor(color[1], color[2], color[3])
		power.value:SetText(format("%.f",min / max * 100).." %")
    end
	
	-- Flash mana below threshold %
	local powerMana, _ = UnitPowerType(unit)
	if (min / max * 100) < (ElvUIHudCF.lowThreshold) and (powerMana == SPELL_POWER_MANA) and ElvUIHudCF.flash then
		ElvUIHud.Flash(power, 0.4)
		if ElvUIHudCF.warningText then
			if not ElvUIHudDB.warningTextShown and unit == "player" then
				ElvUIHudWarning:AddMessage("|cff00ffffLOW MANA")
				ElvUIHudDB.warningTextShown = true
			else
				ElvUIHudWarning:Clear()
				ElvUIHudDB.warningTextShown = false
			end
		end
	end
end

ElvUIHud.ComboDisplay = function(self, event, unit)
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

-- The following functions are thanks to Hydra from the ElvUI forums
ElvUIHud.SetUpAnimGroup = function(self)
    self.anim = self:CreateAnimationGroup("Flash")
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(1)
    self.anim.fadein:SetOrder(2)

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-1)
    self.anim.fadeout:SetOrder(1)
end

ElvUIHud.Flash = function(self, duration)
    if not self.anim then
        ElvUIHud.SetUpAnimGroup(self)
    end

    self.anim.fadein:SetDuration(duration)
    self.anim.fadeout:SetDuration(duration)
    self.anim:Play()
end

ElvUIHud.CreateWarningFrame = function()
	local f=CreateFrame("ScrollingMessageFrame","ElvUIHudWarning",UIParent)
	f:SetFont(LSM:Fetch("font", ElvUIHudCF.font),ElvUIHudCF.fontsize*2,"THINOUTLINE")
	f:SetShadowColor(0,0,0,0)
	f:SetFading(true)
	f:SetFadeDuration(0.5)
	f:SetTimeVisible(0.6)
	f:SetMaxLines(10)
	f:SetSpacing(2)
	f:SetWidth(128)
	f:SetHeight(128)
	f:SetPoint("CENTER",0,E:Scale(-100))
	f:SetMovable(false)
	f:SetResizable(false)
	--f:SetInsertMode("TOP") -- Bugged currently
end

ElvUIHud.ComboDisplay = function(self, event, unit)
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

local alpha = ElvUIHudCF.alpha
local oocalpha = ElvUIHudCF.oocalpha

local __Hide = function(frame,event)
	if (event == "PLAYER_REGEN_DISABLED") then
			UIFrameFadeIn(frame, 0.3 * (alpha - frame:GetAlpha()), frame:GetAlpha(), alpha)
	elseif (event == "PLAYER_REGEN_ENABLED") then
			UIFrameFadeOut(frame, 0.3 * (oocalpha + frame:GetAlpha()), frame:GetAlpha(), oocalpha)
	elseif (event == "PLAYER_ENTERING_WORLD") then
			if (not InCombatLockdown()) then
					frame:SetAlpha(oocalpha)
			end
	end
end

ElvUIHud.HideOOC = function(frame)
	if ElvUIHudCF.hideooc == true then
		local hud_hider = CreateFrame("Frame", nil, UIParent)
		hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
		hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
		hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
		hud_hider:SetScript("OnEvent", function(self,event) __Hide(frame,event) end)
		frame.hud_hider = hud_hider
	end
end

ElvUIHud.Enable = function(msg)
	if msg == "enable" then
		if ElvUIHudCF.simpleLayout then
			oUF_Elv_player_HudHealth:Show()
			oUF_Elv_player_HudPower:Show()
		else
			oUF_Elv_player_Hud:Show()
			oUF_Elv_target_Hud:Show()
			if oUF_Elv_pet_Hud then oUF_Elv_pet_Hud:Show() end
		end
		print('ElvUI_Hud: Hud is enabled.  /hud disable to disable.')
	elseif msg == "disable" then
		if ElvUIHudCF.simpleLayout then
			oUF_Elv_player_HudHealth:Hide()
			oUF_Elv_player_HudPower:Hide()
		else
			oUF_Elv_player_Hud:Hide()
			oUF_Elv_target_Hud:Hide()
			if oUF_Elv_pet_Hud then oUF_Elv_pet_Hud:Hide() end
		end
		print('ElvUI_Hud: Hud is disabled.  /hud enable or /rl to reenable.')
	else
		print('Usage: /hud {enable|disable}')
	end
end

SLASH_TUKUIHUD1 = '/hud'
SlashCmdList["ELVUIHUD"] = ElvUIHud.Enable
		

local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");

local warningTextShown = false;

function H.PostUpdateHealth(health, unit, min, max)
    local r, g, b

    -- overwrite healthbar color for enemy player (a tukui option if enabled), target vehicle/pet too far away returning unitreaction nil and friend unit not a player. (mostly for overwrite tapped for friendly)
    -- I don't know if we really need to call ElvUICF["unitframes"].unicolor but anyway, it's safe this way.
    if (E.db.hud.unicolor ~= true and unit == "target" and UnitIsEnemy(unit, "player")) or (E.db.hud.unicolor ~= true and unit == "target" and not UnitIsPlayer(unit) and UnitIsFriend(unit, "player")) then
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

	if E.db.hud.showValues then
		health.value:SetText(format("%.f", min / max * 100).." %")
	end
	
    -- Flash health below threshold %
	if (min / max * 100) < (E.db.hud.lowThreshold) then
		H.Flash(health, 0.6)
		if (not warningTextShown and unit == "player") and E.db.hud.warningText then
			ElvUIHudWarning:AddMessage("|cffff0000LOW HEALTH")
			warningTextShown = true
		else
			ElvUIHudWarning:Clear()
			warningTextShown = false
		end
	end
end

-- used to check if a spell is interruptable
function H:CheckInterrupt(unit)
	if unit == "vehicle" then unit = "player" end

	if self.interrupt and UnitCanAttack("player", unit) then
		self:SetStatusBarColor(E.db.unitframe.units.player.castbar.interruptcolor)	
	else
		self:SetStatusBarColor(E.db.unitframe.units.player.castbar.color)	
	end
end

-- check if we can interrupt on cast
function H:CheckCast(unit, name, rank, castid)
	H.CheckInterrupt(self,unit)
end

-- display casting time
function H:CustomCastTimeText(duration)
	self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
end

-- display delay in casting time
function H:CustomCastDelayText(duration)
	self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

function H.PreUpdatePowerHud(power, unit)
    local _, pType = UnitPowerType(unit)

    local color = ElvUF["colors"].power[pType]
    if color then
        power:SetStatusBarColor(color[1], color[2], color[3])
    end
end

function H.PostUpdatePowerHud(power, unit, min, max)
    local self = power:GetParent()
    local pType, pToken = UnitPowerType(unit)
    local color = ElvUF["colors"].power[pToken]

    if color and E.db.hud.showValues then
        power.value:SetTextColor(color[1], color[2], color[3])
		power.value:SetText(format("%.f",min / max * 100).." %")
    end
	
	-- Flash mana below threshold %
	local powerMana, _ = UnitPowerType(unit)
	if (min / max * 100) < (E.db.hud.lowThreshold) and (powerMana == SPELL_POWER_MANA) and E.db.hud.flash then
		H.Flash(power, 0.4)
		if E.db.hud.warningText then
			if not warningTextShown and unit == "player" then
				ElvUIHudWarning:AddMessage("|cff00ffffLOW MANA")
				warningTextShown = true
			else
				ElvUIHudWarning:Clear()
				warningTextShown = false
			end
		end
	end
end

function H:ComboDisplay(event, unit)
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

local updateSafeZone = function(self)
	local sz = self.SafeZone
	local height = self:GetHeight()
	local _, _, _, ms = GetNetStats()

	sz:ClearAllPoints()
	sz:SetPoint('TOP')
	sz:SetPoint('LEFT')
	sz:SetPoint('RIGHT')

	-- Guard against GetNetStats returning latencies of 0.
	if(ms ~= 0) then
		-- MADNESS!
		local safeZonePercent = (height / self.max) * (ms / 1e5)
		if(safeZonePercent > 1) then safeZonePercent = 1 end
		sz:SetWidth(height * safeZonePercent)
		sz:Show()
	else
		sz:Hide()
	end
end

function H:PostCastStart(unit, name, rank, castid)
	local sz = self.SafeZone
	if sz then
		updateSafeZone(self)
	end
end

function H:CastbarUpdate(elapsed)
	if(self.casting) then
		local duration = self.duration + elapsed
		if(duration >= self.max) then
			self.casting = nil
			self:Hide()

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "BOTTOM", 0, (duration / self.max) * self:GetHeight())
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed

		if(duration <= 0) then
			self.channeling = nil
			self:Hide()

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)
		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "BOTTOM", 0, (duration / self.max) * self:GetHeight())
		end
	else
		self.unitName = nil
		self.casting = nil
		self.castid = nil
		self.channeling = nil

		self:SetValue(1)
		self:Hide()
	end
end

function H:UpdateHoly(event,unit,powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
	local num = UnitPower(unit, SPELL_POWER_HOLY_POWER)
	for i = 1, MAX_HOLY_POWER do
		if(i <= num) then
			self.HolyPower[i]:SetAlpha(1)
		else
			self.HolyPower[i]:SetAlpha(.2)
		end
	end
end

function H:UpdateShards(event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'SOUL_SHARDS')) then return end
	local num = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
	for i = 1, SHARD_BAR_NUM_SHARDS do
		if(i <= num) then
			self.SoulShards[i]:SetAlpha(1)
		else
			self.SoulShards[i]:SetAlpha(.2)
		end
	end
end

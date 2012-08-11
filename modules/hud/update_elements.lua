local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local warningTextShown = false;

function H.PostUpdateHealth(health, unit, min, max)
    if E.db.hud.colorHealthByValue then
		local r, g, b = health:GetStatusBarColor()
		local newr, newg, newb = ElvUF.ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

		health:SetStatusBarColor(newr, newg, newb)
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

local updateSafeZone = function(self,c)
	local sz = self.SafeZone
	local height = self:GetHeight()
	local _, _, _, ms = GetNetStats()

	sz:ClearAllPoints()
	if c then sz:SetPoint('TOP') else sz:SetPoint('BOTTOM') end
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
		updateSafeZone(self,true)
	end
end

function H:PostChannelStart(unit, name, rank, castid)
	local sz = self.SafeZone
	if sz then
		updateSafeZone(self,false)
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

function H:PostUpdateAura(unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, button.filter)

	
	button.text:Show()
	
	if button.isDebuff then
		if(not UnitIsFriend("player", unit) and button.owner ~= "player" and button.owner ~= "vehicle") --[[and (not E.isDebuffWhiteList[name])]] then
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			if unit and not unit:find('arena%d') then
				button.icon:SetDesaturated(true)
			else
				button.icon:SetDesaturated(false)
			end
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (button.isStealable or ((E.myclass == "PRIEST" or E.myclass == "SHAMAN" or E.myclass == "MAGE") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))		
		end	
	end
	
	button.duration = duration
	button.timeLeft = expirationTime
	button.first = true	
	
	local size = button:GetParent().size
	if size then
		button:Size(size)
	end
	
	button:SetScript('OnUpdate', UF.UpdateAuraTimer)
end

local function CheckFilter(type, isFriend)
	if type == 'ALL' or (type == 'FRIENDLY' and isFriend) or (type == 'ENEMY' and not isFriend) then
		return true
	end
	
	return false
end

function H:AuraBarFilter(unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate)
	local db = ElvUF_Player.db.aurabar
	if not db then return; end
		
	local isPlayer, isFriend

	if unitCaster == 'player' or unitCaster == 'vehicle' then isPlayer = true end
	if UnitIsFriend('player', unit) then isFriend = true end

	if E.global['unitframe']['aurafilters']['Blacklist'].spells[name] and CheckFilter(db.useBlacklist, isFriend) then
		return false
	end	
	
	if E.global['unitframe']['aurafilters']['Whitelist'].spells[name] and CheckFilter(db.useWhitelist, isFriend) then
		return true
	end

	if (duration == 0 or not duration) and CheckFilter(db.noDuration, isFriend) then
		return false
	end	

	if shouldConsolidate == 1 and CheckFilter(db.noConsolidated, isFriend) then
		return false
	end	

	if not isPlayer and CheckFilter(db.playerOnly, isFriend) then
		return false
	end
	
	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells

		if type == 'Whitelist' then
			if spellList[name] and spellList[name].enable then
				return true
			else
				return false
			end		
		elseif type == 'Blacklist' then
			if spellList[name] and spellList[name].enable then
				return false
			else
				return true
			end				
		end
	end	
	
	return true
end
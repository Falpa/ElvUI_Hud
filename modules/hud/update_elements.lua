local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local warningTextShown = false;

function H.PostUpdateHealth(health, unit, min, max)
    if E.db.hud.colorHealthByValue then
		local dc = health.defaultColor or (E.db.hud.units.player.health.media.color)
		local r = dc.r
		local g = dc.g
		local b = dc.b
		local newr, newg, newb = ElvUF.ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

		health:SetStatusBarColor(newr, newg, newb)
	end

    -- Flash health below threshold %
    if max == 0 then return end
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

function UF:SetCastTicks(frame, numTicks, extraTickRatio)
	extraTickRatio = extraTickRatio or 0
	local color = E.db.hud.units.player['castbar']['tickcolor']
	UF:HideTicks()
	if numTicks and numTicks > 0 then
		local d = frame:GetWidth() / (numTicks + extraTickRatio)
		for i = 1, numTicks do
			if not ticks[i] then
				ticks[i] = frame:CreateTexture(nil, 'OVERLAY')
				ticks[i]:SetTexture(E["media"].normTex)
				ticks[i]:SetVertexColor(color.r, color.g, color.b)
				ticks[i]:SetWidth(1)
				ticks[i]:SetHeight(frame:GetHeight())
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("CENTER", frame, "LEFT", d * i, 0)
			ticks[i]:Show()
		end
	end
end

-- used to check if a spell is interruptable
function H:CheckInterrupt(unit)
	if unit == "vehicle" then unit = "player" end
	local config = E.db.hud.units[unit]['castbar']
	local media = config.media
	if self.interrupt and UnitCanAttack("player", unit) then
		self:SetStatusBarColor(config.interruptcolor)	
	else
		self:SetStatusBarColor(config.color)	
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
		sz:SetHeight(height * safeZonePercent)
		sz:Show()
	else
		sz:Hide()
	end
end

function H:PostCastStart(unit, name, rank, castid)
	H.CheckInterrupt(self,unit)
	local sz = self.SafeZone
	if sz then
		updateSafeZone(self,true)
	end
end

function H:PostChannelStart(unit, name, rank, castid)
	H.CheckInterrupt(self,unit)
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
	for i = 1, 5 do
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

local function FormatTime(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", ceil(s / day))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= minute / 12 then
		return floor(s)
	end
	return format("%.1f", s)
end

-- create a timer on a buff or debuff
local function CreateAuraTimer(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
				self.remaining:SetText(time)
				if self.timeLeft <= 5 then
					self.remaining:SetTextColor(0.99, 0.31, 0.31)
				else
					self.remaining:SetTextColor(1, 1, 1)
				end
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

-- create a skin for all unitframes buffs/debuffs
function H:PostCreateAura(button)
	button:SetTemplate("Default")
	
	button.remaining = button:CreateFontString(nil, "THINOUTLINE")
	-- Dummy font
	button.remaining:FontTemplate(LSM:Fetch("font", "ElvUI Font"), 12, "THINOUTLINE")
	button.remaining:Point("CENTER", 1, 0)
	
	button.cd.noOCC = true -- hide OmniCC CDs, because we  create our own cd with CreateAuraTimer()
	button.cd.noCooldownCount = true -- hide CDC CDs, because we create our own cd with CreateAuraTimer()
	
	button.cd:SetReverse()
	button.icon:Point("TOPLEFT", 2, -2)
	button.icon:Point("BOTTOMRIGHT", -2, 2)
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer('ARTWORK')
	
	button.count:Point("BOTTOMRIGHT", 3, 3)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(LSM:Fetch("font", "ElvUI Font"), 9, "THICKOUTLINE")
	button.count:SetTextColor(0.84, 0.75, 0.65)
	
	button.overlayFrame = CreateFrame("frame", nil, button, nil)
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:Point("TOPLEFT", button, "TOPLEFT", 2, -2)
	button.cd:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	   
	button.overlay:SetParent(button.overlayFrame)
	button.count:SetParent(button.overlayFrame)
	button.remaining:SetParent(button.overlayFrame)
			
	button.Glow = CreateFrame("Frame", nil, button)
	button.Glow:Point("TOPLEFT", button, "TOPLEFT", -3, 3)
	button.Glow:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	button.Glow:SetFrameStrata("BACKGROUND")	
	button.Glow:SetBackdrop{edgeFile = E["media"].blankTex, edgeSize = 3, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	button.Glow:SetBackdropColor(0, 0, 0, 0)
	button.Glow:SetBackdropBorderColor(0, 0, 0)
	
	local Animation = button:CreateAnimationGroup()
	Animation:SetLooping("BOUNCE")

	local FadeOut = Animation:CreateAnimation("Alpha")
	FadeOut:SetChange(-.9)
	FadeOut:SetDuration(.6)
	FadeOut:SetSmoothing("IN_OUT")

	button.Animation = Animation
end

-- update cd, border color, etc on buffs / debuffs
function H:PostUpdateAura(unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
	local _, _, _, _, dtype, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, icon.filter)
	if icon then
		if(icon.filter == "HARMFUL") then
			if(not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle") then
				icon.icon:SetDesaturated(true)
				icon:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
				icon.icon:SetDesaturated(false)
				icon:SetBackdropBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			end
		else
			if (isStealable or ((E.myclass == "MAGE" or E.myclass == "PRIEST" or E.myclass == "SHAMAN") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
				if not icon.Animation:IsPlaying() then
					icon.Animation:Play()
				end
			else
				if icon.Animation:IsPlaying() then
					icon.Animation:Stop()
				end
			end
		end
		
		if duration and duration > 0 then
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
	 
		icon.duration = duration
		icon.timeLeft = expirationTime
		icon.first = true
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end
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

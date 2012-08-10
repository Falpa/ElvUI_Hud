local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local function r(f) H:RegisterFrame(f) end;

-- Health for all units
function H:ConstructHealth(frame)
	-- Health Bar
    local health = CreateFrame('StatusBar', nil, frame)
    health:SetWidth(H.width - 4)
    health:SetHeight(H.height - 4)
    health:SetStatusBarTexture(H.normTex)
    health:SetOrientation("VERTICAL")
    health:SetFrameLevel(frame:GetFrameLevel() + 5)

    -- Health Frame Border
    local HealthFrame = CreateFrame("Frame", nil, frame)
    HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", E:Scale(-2), E:Scale(2))
    HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    HealthFrame:SetFrameLevel(frame:GetFrameLevel() + 4)

    HealthFrame:SetTemplate("Default")
    HealthFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
    frame.FrameBorder = HealthFrame
    frame.FrameBorder:CreateShadow("Default")

    -- Health Bar Background
    local healthBG = health:CreateTexture(nil, 'BORDER')
    healthBG:SetAllPoints()
    healthBG:SetTexture(.1, .1, .1)
    healthBG:SetAlpha(.2)

	if E.db.hud.showValues then
		health.value = health:CreateFontString(nil, "THINOUTLINE") 			
        health.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
	end

	health.PostUpdate = H.PostUpdateHealth
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
    
    frame.elements["health"] = { ['enabled'] = true }
    r(health)
    return health
end

-- Power for units it is enabled on
function H:ConstructPower(frame)
    local width = E:Scale((H.width/3)*2)
    
    -- Power Frame Border
    local PowerFrame = CreateFrame("Frame", nil, frame)
    PowerFrame:SetHeight(H.height)
    PowerFrame:SetWidth(width)
    PowerFrame:SetFrameLevel(frane:GetFrameLevel() + 4)

    PowerFrame:SetTemplate("Default")
    PowerFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))   
    frame.PowerFrame = PowerFrame
    frame.PowerFrame:CreateShadow("Default")

    -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
    local power = CreateFrame('StatusBar', nil, frame)
    power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", E.mult*2, -E.mult*2)
    power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -E.mult*2, E.mult*2)
    power:SetStatusBarTexture(H.normTex)
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
    end
    power.PreUpdate = H.PreUpdatePowerHud
    power.PostUpdate = H.PostUpdatePowerHud

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

    frame.elements["power"] = { ['enabled'] = true }
    r(power)
    return power
end 

-- Castbar for units it is enabled on
-- For player/target castbar can be (and defaults) to horizontal mode.
-- For pet/targettarget/pettarget castbar is always vertical overlaid on the power bar.
-- Note in this version the castbar is no longer anchored to the power bar, so each
-- element can be disabled indepdently
function H:ConstructCastbar(frame)
    local castbar = CreateFrame("StatusBar", nil, frame)

    if not E.db.hud.horizCastbar or (frame.unit ~= "player" and frame.unit ~= "target") then
        castbar:SetWidth(H.width - 4)
        castbar:SetHeight(H.height - 4)
        castbar:SetStatusBarTexture(H.normTex)
        castbar:SetStatusBarColor(E.db.unitframe.units.player.castbar.color)
        castbar.PostCastStart = H.PostCastStart
        castbar.PostChannelStart = H.PostChannelStart
        castbar.OnUpdate = H.CastbarUpdate
        --castbar.PostCastInterruptible = H.PostCastInterruptible
        --castbar.PostCastNotInterruptible = H.PostCastNotInterruptible
        castbar:SetOrientation("VERTICAL")
        castbar:SetFrameStrata(frame.Power:GetFrameStrata())
        castbar:SetFrameLevel(frame.Power:GetFrameLevel()+2)
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
        if frame.unit == "player" then
            castbar.LatencyTexture:Show()
        end

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
        castbar:HookScript("OnShow", function(self) if E.db.hud.hideOOC and not InCombatLockdown() then H:Hide(frame:GetParent(),"PLAYER_REGEN_DISABLED") end end)
        castbar:HookScript("OnHide", function(self) if E.db.hud.hideOOC and not InCombatLockdown() then H:Hide(frame:GetParent(),"PLAYER_REGEN_ENABLED") end end)
    else
        castbar:SetStatusBarTexture(H.normTex)
        castbar:SetWidth(E:Scale(H.height * 2))
        castbar:SetHeight(26)
        castbar:SetFrameLevel(6)

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

        castbar.Icon = castbar.button:CreateTexture(nil, "ARTWORK")
        castbar.Icon:Point("TOPLEFT", castbar.button, 2, -2)
        castbar.Icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
        castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, .92)
    
        castbar.button:SetPoint("LEFT")
    
        -- cast bar latency on player
        castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
        castbar.safezone:SetTexture(normTex)
        castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
        castbar.SafeZone = castbar.safezone
    end

    frame.elements["castbar"] = { ['enabled'] = true }
    r(castbar)
    return castbar
end

-- Name element
function H:ConstructName(frame)
    local name = frame:CreateFontString(nil, 'OVERLAY')
    name:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
    if frame.unit == 'player' then
        frame:Tag(name, '[level] [shortclassification] [Elv:getnamecolor][Elv:namelong] [Elv:diffcolor]')
    elseif frame.unit == 'target' then
        frame:Tag(name, '[Elv:getnamecolor][Elv:namelong] [Elv:diffcolor][level] [shortclassification]')
    else
        frame:Tag(name, '[Elv:getnamecolor][Elv:namemedium]')
    end
    frame.elements["name"] = { ['enabled'] = true }
    return name
end

-- Eclipse Bar for druids
function H:ConstructEclipseBar(frame)
    local eclipseBar = CreateFrame('Frame', nil, frame)
    eclipseBar:SetSize(H.width-8, H.height-4)
    eclipseBar:SetFrameStrata("MEDIUM")
    eclipseBar:SetFrameLevel(8)
    eclipseBar:SetTemplate("Default")
    eclipseBar:SetBackdropBorderColor(0,0,0,0)
                    
    local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
    lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
    lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
    lunarBar:SetStatusBarTexture(H.normTex)
    lunarBar:SetStatusBarColor(.30, .52, .90)
    lunarBar:SetOrientation('VERTICAL')
    eclipseBar.LunarBar = lunarBar

    local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
    solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
    solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
    solarBar:SetStatusBarTexture(H.normTex)
    solarBar:SetStatusBarColor(.80, .82,  .60)
    solarBar:SetOrientation('VERTICAL')
    eclipseBar.SolarBar = solarBar
    
    local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
    eclipseBarText:SetPoint("LEFT", eclipseBar, "RIGHT", E:Scale(10), 0)
    eclipseBarText:FontTemplate(LSM:Fetch("font",E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
    
    eclipseBar.PostUpdatePower = H.EclipseDirection
    eclipseBar.Text = eclipseBarText
    
    eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
    eclipseBar.FrameBackdrop:SetTemplate("Default")
    eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", E:Scale(-2), E:Scale(2))
    eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)

    frame.elements["eclipseBar"] = { ['enabled'] = true }
    r(eclipseBar)
    return eclipseBar
end

-- Warlock spec bars
function H:ConstructWarlockBars(frame)
    local wb = CreateFrame("Frame", nil. frame)
    wb:SetHeight(H.height-4)
    wb:SetWidth(H.width-8)
    wb:SetFrameLevel(frame:GetFrameLevel() + 5)
    wb:SetTemplate("Default")
    wb:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 4 do
        wb[i] = CreateFrame("StatusBar", frame:GetName().."_WarlockSpecBar"..i, wb)
        wb[i]:SetWidth(H.width-8)
        wb[i]:SetStatusBarTexture(H.normTex)
        wb[i]:GetStatusBarTexture():SetHorizTile(false)
        wb[i]:SetFrameLevel(wb:GetFrameLevel()+1)
        
        if i == 1 then
            wb[i]:SetPoint("BOTTOM",wb)
        else
            wb[i]:SetPoint("BOTTOM", wb[i-1], "TOP", 0, E:Scale(1))
        end
        
        wb[i]:SetOrientation('VERTICAL')
        wb[i].bg:SetAllPoints(wb[i])
        wb[i]:SetHeight(E:Scale(((H.height - 4) - 2)/4))
        
        wb[i].bg:SetTexture(normTex)                  
        wb[i].bg:SetAlpha(.15)
        r(wb[i])
    end

    wb.FrameBackdrop = CreateFrame("Frame", nil, wb)
    wb.FrameBackdrop:SetTemplate("Default")
    wb.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
    wb.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    wb.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    wb.FrameBackdrop:SetFrameLevel(wb:GetFrameLevel() - 1)

    frame.elements["warlockSpecBars"] = { ['enabled'] = true }
    return wb
end

-- Construct holy power for paladins
function H:ConstructHolyPower(frame)
    local bars = CreateFrame("Frame", nil, frame)
    bars:SetHeight(H.height-4)
    bars:SetWidth(H.width-8)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Default")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 5 do                 
        bars[i]=CreateFrame("StatusBar", frame:GetName().."_Shard"..i, bars)
        bars[i]:SetWidth(H.width-8)           
        bars[i]:SetStatusBarTexture(H.normTex)
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
        bars[i]:SetHeight(E:Scale(((H.height - 4) - 2)/5))
        
        bars[i].bg:SetTexture(H.normTex)                  
        bars[i].bg:SetAlpha(.15)
        r(bars[i])
    end
    
    bars.Override = H.UpdateHoly

    bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
    bars.FrameBackdrop:SetTemplate("Default")
    bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
    bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)

    frame.elements["holypower"] = { ['enabled'] = true }
    return bars 
end

-- Runes for death knights
function H:ConstructRunes(frame)
    local Runes = CreateFrame("Frame", nil, frame)
    Runes:SetHeight(H.height-4)
    Runes:SetWidth(H(.width-8)
    Runes:SetFrameLevel(frame:GetFrameLevel() + 5)
    Runes:SetTemplate("Default")
    Runes:SetBackdropBorderColor(0,0,0,0)

    for i = 1, 6 do
        Runes[i] = CreateFrame("StatusBar", frame:GetName().."_Runes"..i, Runes)
        Runes[i]:SetHeight(((H.height - 4) - 5)/6)
        Runes[i]:SetWidth(H.width-8)
        Runes[i]:SetFrameLevel(Runes:GetFrameLevel() + 1)

        if (i == 1) then
            Runes[i]:SetPoint("BOTTOM", Runes)
        else
            Runes[i]:SetPoint("BOTTOM", Runes[i-1], "TOP", 0, E:Scale(1))
        end
        Runes[i]:SetStatusBarTexture(H.normTex)
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
    frame.elements["runes"] = { ['enabled'] = true }
    return Runes
end

-- Totems for shamans
function H:ConstructTotems(frame)
    local TotemBar = CreateFrame("Frame", nil, frame)
    TotemBar.Destroy = true
    TotemBar:SetHeight(H.height-4)
    TotemBar:SetWidth(H.width-8)
    TotemBar:SetFrameLevel(frame:GetFrameLevel() + 5)

    TotemBar:SetBackdrop(backdrop)
    TotemBar:SetBackdropColor(0, 0, 0)

    for i = 1, 4 do
        TotemBar[i] = CreateFrame("StatusBar", frame:GetName().."_TotemBar"..i, TotemBar)
        TotemBar[i]:SetHeight(((H.height - 4) - 3)/4)
        TotemBar[i]:SetWidth(H.width - 8)
        TotemBar[i]:SetFrameLevel(TotemBar:GetFrameLevel()+1)

        if (i == 1) then
            TotemBar[i]:SetPoint("BOTTOM",TotemBar)
        else
            TotemBar[i]:SetPoint("BOTTOM", TotemBar[i-1], "TOP", 0, E:Scale(1))
        end
        TotemBar[i]:SetStatusBarTexture(H.normTex)
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
    frame.elements['totembar'] = { ['enabled'] = true }
    return TotemBar
end

-- Construct harmony bar for monks
function H:ConstructHarmonyBar(frame)
    local bars = CreateFrame("Frame", nil, frame)
    bars:SetHeight(H.height-4)
    bars:SetWidth(H.width-8)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Default")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 5 do                 
        bars[i]=CreateFrame("StatusBar", frame:GetName().."_Harmory"..i, bars)
        bars[i]:SetWidth(H.width-8)           
        bars[i]:SetStatusBarTexture(H.normTex)
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
        bars[i]:SetHeight(E:Scale(((H.height - 4) - 2)/5))
        
        bars[i].bg:SetTexture(H.normTex)                  
        bars[i].bg:SetAlpha(.15)
        r(bars[i])
    end

    bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
    bars.FrameBackdrop:SetTemplate("Default")
    bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
    bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)

    frame.elements["harmonybar"] = { ['enabled'] = true }
    return bars 
end

-- Construct shadow orb bar for priests
function H:ConstructShadowOrbBar(frame)
    local bars = CreateFrame("Frame", nil, frame)
    bars:SetHeight(H.height-4)
    bars:SetWidth(H.width-8)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Default")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 3 do                 
        bars[i]=CreateFrame("StatusBar", frame:GetName().."_Shard"..i, bars)
        bars[i]:SetWidth(H.width-8)           
        bars[i]:SetStatusBarTexture(H.normTex)
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
        bars[i]:SetHeight(E:Scale(((H.height - 4) - 2)/3))
        
        bars[i].bg:SetTexture(H.normTex)                  
        bars[i].bg:SetAlpha(.15)
        r(bars[i])
    end
    
    bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
    bars.FrameBackdrop:SetTemplate("Default")
    bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
    bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)

    frame.elements["shadoworbs"] = { ['enabled'] = true }
    return bars 
end

-- Construct arcane bar for mages
function H:ConstructArcaneBar(frame)
    local bars = CreateFrame("Frame", nil, frame)
    bars:SetHeight(H.height-4)
    bars:SetWidth(H.width-8)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Default")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 6 do                 
        bars[i]=CreateFrame("StatusBar", frame:GetName().."_Shard"..i, bars)
        bars[i]:SetWidth(H.width-8)           
        bars[i]:SetStatusBarTexture(H.normTex)
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
        bars[i]:SetHeight(E:Scale(((H.height - 4) - 2)/6))
        
        bars[i].bg:SetTexture(H.normTex)                  
        bars[i].bg:SetAlpha(.15)
        r(bars[i])
    end

    bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
    bars.FrameBackdrop:SetTemplate("Default")
    bars.FrameBackdrop:SetPoint("TOPLEFT", E:Scale(-2), E:Scale(2))
    bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)

    frame.elements["arcanebar"] = { ['enabled'] = true }
    return bars 
end

-- Combo points for rogues and druids
function H:ConstructComboPoints(frame)
    -- Setup combo points
    local bars = CreateFrame("Frame", nil, frame)
    bars:SetWidth(H.width-8)
    bars:SetHeight(H.height-4)
    bars:SetTemplate("Default")
    bars:SetBackdropBorderColor(0,0,0,0)
    bars:SetBackdropColor(0,0,0,0)
    
    for i = 1, 5 do                 
        bars[i] = CreateFrame("StatusBar", frame:GetName().."_Combo"..i, bars)
        bars[i]:SetHeight((E:Scale(H.height - 4) - 4)/5)                  
        bars[i]:SetStatusBarTexture(H.normTex)
        bars[i]:GetStatusBarTexture():SetHorizTile(false)
                        
        if i == 1 then
            bars[i]:SetPoint("BOTTOM", bars)
        else
            bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
        end
        bars[i]:SetAlpha(0.15)
        bars[i]:SetWidth(H.width-8)
        bars[i]:SetOrientation('VERTICAL')
        r(bars[i])
    end
    
    bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)     
    bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
    bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
    bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
    bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
    
    bars.Override = H.ComboDisplay
    
    bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
    bars.FrameBackdrop:SetTemplate("Default")
    bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", E:Scale(-2), E:Scale(2))
    bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", E:Scale(2), E:Scale(-2))
    bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
    bars.FrameBackdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))   
    frame:RegisterEvent("UNIT_DISPLAYPOWER", H.ComboDisplay)
    frame.elements['combo'] = { ['enabled'] = true }
    return bars
end

-- Threat bar
function H:ConstructThreat(frame)
    -- Threat Bar Border
    local ThreatFrame = CreateFrame("Frame", nil, frame)
    ThreatFrame:SetHeight(H.height * .75)
    ThreatFrame:SetWidth()
    ThreatFrame:SetFrameLevel(self:GetFrameLevel() + 4)
    
    ThreatFrame:SetTemplate("Default")
    ThreatFrame:SetBackdropBorderColor(unpack(E["media"].bordercolor))
    ThreatFrame:CreateShadow("Default")
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
    ThreatBar.frame = ThreatFrame
    frame.elements['threat'] = { ['enabled'] = true }
    r(ThreatBar)
    return ThreatBar
end

-- TODO: PVP Icon, Combat Icon on player, target markings on all units

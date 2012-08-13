local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

-- Health for all units
function H:ConstructHealth(frame)
    self:AddElement(frame,'health')
	-- Health Bar
    local health = self:ConfigureStatusBar(frame,'health')
    health:SetOrientation("VERTICAL")
    health:SetFrameLevel(frame:GetFrameLevel() + 5)
    
	health.value = self:ConfigureFontString(frame,'health',health)		
	health.PostUpdate = H.PostUpdateHealth
    health.frequentUpdates = true

    health.colorSmooth = false
    --health.colorDisconnected = false
    --health.colorTapping = true	

    return health
end

-- Power for units it is enabled on
function H:ConstructPower(frame)
    self:AddElement(frame,'power')
    
    local power = self:ConfigureStatusBar(frame,'power')
    power:SetOrientation("VERTICAL")
    power:SetFrameLevel(frame:GetFrameLevel()+1)

    power.value = self:ConfigureFontString(frame,'power',power)               
    
    power.PreUpdate = H.PreUpdatePowerHud
    power.PostUpdate = H.PostUpdatePowerHud

    -- Update the Power bar Frequently
    power.frequentUpdates = true

    power.colorTapping = true   
    power.colorPower = true
    power.colorReaction = true
    power.colorDisconnected = true      

    return power
end 

-- Castbar for units it is enabled on
-- For player/target castbar can be (and defaults) to horizontal mode.
-- For pet/targettarget/pettarget castbar is always vertical overlaid on the power bar.
-- Note in this version the castbar is no longer anchored to the power bar, so each
-- element can be disabled indepdently
function H:ConstructCastbar(frame)
    self:AddElement(frame,'castbar')
    local castbar = self:ConfigureStatusBar(frame,'castbar')

    if not E.db.hud.horizCastbar or (frame.unit ~= "player" and frame.unit ~= "target") then
        castbar.PostCastStart = H.PostCastStart
        castbar.PostChannelStart = H.PostChannelStart
        castbar.OnUpdate = H.CastbarUpdate
        --castbar.PostCastInterruptible = H.PostCastInterruptible
        --castbar.PostCastNotInterruptible = H.PostCastNotInterruptible
        castbar:SetOrientation("VERTICAL")
        castbar:SetFrameStrata(frame.Power:GetFrameStrata())
        castbar:SetFrameLevel(frame.Power:GetFrameLevel()+2)
    
        castbar.Time = self:ConfigureFontString(frame,'castbar',castbar,'time')
        castbar.Time:Point("BOTTOM", castbar, "TOP", 0, 4)
        castbar.Time:SetTextColor(0.84, 0.75, 0.65)
        castbar.Time:SetJustifyH("RIGHT")
        
        castbar.Text = self:ConfigureFontString(frame,'castbar',castbar,'text')
        castbar.Text:SetPoint("TOP", castbar, "BOTTOM", 0, -4)
        castbar.Text:SetTextColor(0.84, 0.75, 0.65)
        
        castbar.Spark = castbar:CreateTexture(nil, 'OVERLAY')
        castbar.Spark:SetBlendMode('ADD')
        castbar.Spark:SetVertexColor(1, 1, 1)

        --Set to castbar.SafeZone
        castbar.LatencyTexture = self:ConfigureTexture(frame,'castbar',castbar,'latency')
        castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)   
        castbar.SafeZone = castbar.LatencyTexture
        
        local button = CreateFrame("Frame", nil, castbar)
        button:SetTemplate("Transparent")
        
        button:Point("BOTTOM", castbar, "BOTTOM", 0, 0)
        
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:Point("TOPLEFT", button, 2, -2)
        icon:Point("BOTTOMRIGHT", button, -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, .92)
        icon.bg = button
        
        --Set to castbar.Icon
        castbar.ButtonIcon = icon
    else
        castbar:SetFrameLevel(6)

        castbar.CustomTimeText = H.CustomCastTimeText
        castbar.CustomDelayText = H.CustomCastDelayText
        castbar.PostCastStart = H.CheckCast
        castbar.PostChannelStart = H.CheckCast

        castbar.Time = self:ConfigureFontString(frame,'castbar',castbar,'time')
        castbar.Time:SetPoint("RIGHT", castbar, "RIGHT", -4, 0)
        castbar.Time:SetTextColor(0.84, 0.75, 0.65)
        castbar.Time:SetJustifyH("RIGHT")
        
        castbar.button = CreateFrame("Frame", nil, castbar)
        castbar.button:Size(26)
        castbar.button:SetTemplate("Transparent")
        castbar.button:CreateShadow("Default")

        castbar.Text = self:ConfigureFontString(frame,'castbar',castbar,'text')
        castbar.Text:SetTextColor(0.84, 0.75, 0.65)
        castbar.Text:SetPoint("LEFT", castbar.button, "RIGHT", 4, 0)

        castbar.Icon = castbar.button:CreateTexture(nil, "ARTWORK")
        castbar.Icon:Point("TOPLEFT", castbar.button, 2, -2)
        castbar.Icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
        castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, .92)
    
        castbar.button:SetPoint("LEFT")
    
        --Set to castbar.SafeZone
        castbar.LatencyTexture = self:ConfigureTexture(frame,'castbar',castbar,'latency')
        castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)   
        castbar.SafeZone = castbar.LatencyTexture
    end

    castbar:HookScript("OnShow", function(self) if E.db.hud.hideOOC and not InCombatLockdown() then H:Hide(frame,"PLAYER_REGEN_DISABLED") end end)
    castbar:HookScript("OnHide", function(self) if E.db.hud.hideOOC and not InCombatLockdown() then H:Hide(frame,"PLAYER_REGEN_ENABLED") end end)

    return castbar
end

-- Name element
function H:ConstructName(frame)
    self:AddElement(frame,'name')
    local name = self:ConfigureFontString(frame,'name')
    return name
end

-- Eclipse Bar for druids
function H:ConstructEclipseBar(frame)
    self:AddElement(frame,'classbars')

    local eclipseBar = self:ConfigureFrame(frame,'classbars', true)
    eclipseBar:SetFrameStrata("MEDIUM")
    eclipseBar:SetTemplate('Transparent')
    eclipseBar:SetFrameLevel(8)
    eclipseBar:SetTemplate("Transparent")
    eclipseBar:SetBackdropBorderColor(0,0,0,0)
                    
    local lunarBar = self:ConfigureStatusBar(frame,'classbars',frame,'lunarbar')
    lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
    lunarBar:SetStatusBarColor(.30, .52, .90)
    lunarBar:SetOrientation('VERTICAL')
    eclipseBar.LunarBar = lunarBar

    local solarBar = self:ConfigureStatusBar(frame,'classbars',frame,'solarbar')
    solarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
    solarBar:SetStatusBarColor(.30, .52, .90)
    solarBar:SetOrientation('VERTICAL')
    eclipseBar.SolarBar = solarBar
    
    local eclipseBarText = self:ConfigureFontString(frame,'classbars',eclipsebar,'text')
    eclipseBarText:SetPoint("LEFT", eclipseBar, "RIGHT", E:Scale(10), 0)
    
    eclipseBar.PostUpdatePower = H.EclipseDirection
    eclipseBar.Text = eclipseBarText
    
    return eclipseBar
end

-- Warlock spec bars
function H:ConstructWarlockSpecBars(frame)
    self:AddElement(frame,'classbars')
    local wb = self:ConfigureFrame(frame,'classbars', true)
    wb:SetFrameLevel(frame:GetFrameLevel() + 5)
    wb:SetTemplate("Transparent")
    wb:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 4 do
        wb[i] = self:ConfigureStatusBar(frame,'classbars',wb,'warlockspecbar'..i)
        
        if i == 1 then
            wb[i]:SetPoint("BOTTOM",wb)
        else
            wb[i]:SetPoint("BOTTOM", wb[i-1], "TOP", 0, E:Scale(1))
        end
     
        wb[i]:SetOrientation('VERTICAL')
    end
    wb.value = self:ConfigureFontString(frame,'classbars',wb)                
    wb.value:Hide()
    
    return wb
end

-- Construct holy power for paladins
function H:ConstructHolyPower(frame)
    self:AddElement(frame,'classbars')
    local bars = self:ConfigureFrame(frame,'classbars', true)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Transparent")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 5 do                 
        bars[i]=self:ConfigureStatusBar(frame,'classbars',bars,'holypower'..i)

        bars[i]:SetStatusBarColor(228/255,225/255,16/255)
        bars[i].bg:SetTexture(228/255,225/255,16/255)
        
        if i == 1 then
            bars[i]:SetPoint("BOTTOM", bars)
        else
            bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
        end
        
        bars[i]:SetOrientation('VERTICAL')
                        
        bars[i].bg:SetAlpha(.15)
    end
    
    bars.Override = H.UpdateHoly

    return bars 
end

-- Runes for death knights
function H:ConstructRunes(frame)
    self:AddElement(frame,'classbars')
    local Runes = self:ConfigureFrame(frame,'classbars', true)
    Runes:SetFrameLevel(frame:GetFrameLevel() + 5)
    Runes:SetTemplate("Transparent")
    Runes:SetBackdropBorderColor(0,0,0,0)

    for i = 1, 6 do
        Runes[i] = self:ConfigureStatusBar(frame,'classbars',Runes,'rune'..i)

        if (i == 1) then
            Runes[i]:SetPoint("BOTTOM", Runes)
        else
            Runes[i]:SetPoint("BOTTOM", Runes[i-1], "TOP", 0, E:Scale(1))
        end
        Runes[i]:SetOrientation('VERTICAL')
    end

    return Runes
end

-- Totems for shamans
function H:ConstructTotems(frame)
    self:AddElement(frame,'classbars')
    local TotemBar = self:ConfigureFrame(frame,'classbars',true)
    TotemBar.Destroy = true
    TotemBar:SetFrameLevel(frame:GetFrameLevel() + 5)

    for i = 1, 4 do
        TotemBar[i] = self:ConfigureStatusBar(frame,'classbars',TotemBar,'totem'..i)

        if (i == 1) then
            TotemBar[i]:SetPoint("BOTTOM",TotemBar)
        else
            TotemBar[i]:SetPoint("BOTTOM", TotemBar[i-1], "TOP", 0, E:Scale(1))
        end

        TotemBar[i]:SetOrientation('VERTICAL')
        TotemBar[i]:SetMinMaxValues(0, 1)
    end

    return TotemBar
end

-- Construct harmony bar for monks
function H:ConstructHarmonyBar(frame)
    self:AddElement(frame,'classbars')
    local bars = self:ConfigureFrame(frame,'classbars', true)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Transparent")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 5 do                 
        bars[i]=self:ConfigureStatusBar(frame,'classbars',bars,'harmony'..i)
        
        bars[i]:SetStatusBarColor(228/255,225/255,16/255)
        
        if i == 1 then
            bars[i]:SetPoint("BOTTOM", bars)
        else
            bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
        end
        
        bars[i]:SetOrientation('VERTICAL')
        
        bars[i].bg:SetAlpha(.15)
    end

   return bars 
end
 
-- Construct shadow orb bar for priests
function H:ConstructShadowOrbBar(frame)
    self:AddElement(frame,'classbars')
    local bars = self:ConfigureFrame(frame,'classbars', true)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Transparent")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 3 do                 
        bars[i]=self:ConfigureStatusBar(frame,'classbars',bars,'shadoworb'..i)
        
        bars[i]:SetStatusBarColor(228/255,225/255,16/255)
        
        if i == 1 then
            bars[i]:SetPoint("BOTTOM", bars)
        else
            bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
        end
        
        bars[i]:SetOrientation('VERTICAL')
        
        bars[i].bg:SetAlpha(.15)
    end

   return bars 
end

-- Construct arcane bar for mages
function H:ConstructArcaneBar(frame)
    self:AddElement(frame,'classbars')
    local bars = self:ConfigureFrame(frame,'classbars', true)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Transparent")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 6 do                 
        bars[i]=self:ConfigureStatusBar(frame,'classbars',bars,'arcanecharge'..i)
        
        bars[i]:SetStatusBarColor(228/255,225/255,16/255)

        if i == 1 then
            bars[i]:SetPoint("BOTTOM", bars)
        else
            bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
        end
        
        bars[i]:SetOrientation('VERTICAL')
        
        bars[i].bg:SetAlpha(.15)
    end

   return bars 
end

-- Combo points for rogues and druids
function H:ConstructComboPoints(frame)
    self:AddElement(frame,'cpoints')
    local bars = self:ConfigureFrame(frame,'cpoints', true)
    bars:SetFrameLevel(frame:GetFrameLevel() + 5)
    bars:SetTemplate("Transparent")
    bars:SetBackdropBorderColor(0,0,0,0)
    
    for i = 1, 3 do                 
        bars[i]=self:ConfigureStatusBar(frame,'classbars',bars,'combopoint'..i)
        
        bars[i]:SetStatusBarColor(228/255,225/255,16/255)

        if i == 1 then
            bars[i]:SetPoint("BOTTOM", bars)
        else
            bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, E:Scale(1))
        end
        
        bars[i]:SetOrientation('VERTICAL')
        
        bars[i].bg:SetAlpha(.15)
    end
    
    bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)     
    bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
    bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
    bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
    bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
    
    bars.Override = H.ComboDisplay
    
    frame:RegisterEvent("UNIT_DISPLAYPOWER", H.ComboDisplay)
    return bars
end

function H:ConstructAuraBars()
    local config = P.hud.units.player.elements['aurabars']
    local media = config.media
    local size = config.size
    local bar = self.statusBar
    
    self:SetTemplate('Default')

    bar:Size(size.width,size.height)
    if media.texture.override then
        bar:SetStatusBarTexture(LSM:Fetch("statusbar", media.texture.statusbar))
    else
        bar:SetStatusBarTexture(LSM:Fetch("statusbar", E.db.hud.statusbar))
    end
    
    if media.font.override then
        bar.spelltime:FontTemplate(LSM:Fetch("font", media.font.font), media.font.fontsize, "THINOUTLINE")
        bar.spellname:FontTemplate(LSM:Fetch("font", media.font.font), media.font.fontsize, "THINOUTLINE")
    else
        bar.spelltime:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
        bar.spellname:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
    end
    
    bar.spellname:ClearAllPoints()
    bar.spellname:SetPoint('LEFT', bar, 'LEFT', 2, 0)
    
    bar.iconHolder:SetTemplate('Default')
    bar.icon:SetInside(bar.iconHolder)
    bar.icon:SetDrawLayer('OVERLAY')
    
    
    bar.iconHolder:HookScript('OnEnter', function(self)
        GameTooltip.auraBarLine = true;
    end)    
    
    bar.iconHolder:HookScript('OnLeave', function(self)
        GameTooltip.auraBarLine = nil;
        GameTooltip.numLines = nil
    end)

    bar.iconHolder:RegisterForClicks('RightButtonUp')
    bar.iconHolder:SetScript('OnClick', function(self)
        if not IsShiftKeyDown() then return; end
        local auraName = self:GetParent().aura.name
        
        if auraName then
            E:Print(string.format(L['The spell "%s" has been added to the Blacklist unitframe aura filter.'], auraName))
            E.global['unitframe']['aurafilters']['Blacklist']['spells'][auraName] = {
                ['enable'] = true,
                ['priority'] = 0,           
            }
            UF:Update_AllFrames()
        end
    end)
end

function H:ConstructAuraBarHeader(frame)
    self:AddElement(frame,'aurabars')
    local auraBar = self:ConfigureFrame(frame,'aurabars')
    auraBar.PostCreateBar = H.ConstructAuraBars
    auraBar.gap = 1
    auraBar.spacing = 1
    auraBar.spark = true
    auraBar.sort = true
    auraBar.debuffColor = {0.8, 0.1, 0.1}
    auraBar.filter = H.AuraBarFilter

    hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
        if self.auraBarLine and self.numLines ~= self:NumLines() then
            self:AddLine(L['Hold shift + right click to blacklist this aura.'])
            if not self.numLines then
                self.numLines = self:NumLines()
            end
        end
    end)
    
    local healthColor = UF.db.colors.health

    auraBar.friendlyAuraType = 'HELPFUL'
    auraBar.enemyAuraType = 'HARMFUL'
    auraBar.buffColor = {healthColor.r, healthColor.b, healthColor.g}
    auraBar.down = true

    return auraBar
end

function H:ConstructRaidIcon(frame)
    self:AddElement(frame,'raidicon')
    local f = CreateFrame('Frame', nil, frame)
    f:SetFrameLevel(20)
    
    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp")
    tex:Size(12)

    return tex
end

function H:ConstructRestingIndicator(frame)
    self:AddElement(frame,'resting')
    local resting = frame:CreateTexture(nil, "OVERLAY")
    resting:Size(16)
    
    return resting
end

function H:ConstructCombatIndicator(frame)
    self:AddElement(frame,'combat')
    local combat = frame:CreateTexture(nil, "OVERLAY")
    combat:Size(13)
    combat:SetVertexColor(0.69, 0.31, 0.31)
    
    return combat
end

function H:ConstructPvPIndicator(frame)
    self:AddElement(frame,'pvp')
    local pvp = self:ConfigureFontString(frame,'pvp')
    pvp:SetTextColor(0.69, 0.31, 0.31)
    
    return pvp
end

function H:ConstructHealComm(frame)
    self:AddElement(frame,'healcomm')
    local mhpb = self:ConfigureStatusBar(frame,'healcomm',frame,'mybar')
    mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
    mhpb:SetFrameLevel(frame.Health:GetFrameLevel() - 2)
    mhpb:Hide()
    
    local ohpb = self:ConfigureStatusBar(frame,'healcomm',frame,'otherbar')
    ohpb:SetStatusBarColor(0, 1, 0, 0.25)
    mhpb:SetFrameLevel(mhpb:GetFrameLevel())    
    ohpb:Hide()
    
    if frame.Health then
        ohpb:SetParent(frame.Health)
        mhpb:SetParent(frame.Health)
    end
    
    return {
        myBar = mhpb,
        otherBar = ohpb,
        maxOverflow = 1,
        PostUpdate = function(self)
            if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
            if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
        end
    }
end
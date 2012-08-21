local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local function IsDefaultHelper( tbl1, tbl2 )
    --
    for k,v in pairs(tbl2) do
        --
        if (tbl1[k] ~= v) then
            
            if ((type(tbl1[k])~="table") or (type(v)~="table")) then
                --
                return false    -- some entry didn't exist or was different!
            end
            
            -- Subtables need to be dived into (different refs doesn't mean
            -- different contents).
            --
            if (not IsDefaultHelper( tbl1[k], v )) then
                return false
            end
        end
    end    

    return true     -- covered it all!
end

function H:IsDefault(settingstring)
	local settings = { string.split('.',settingstring) }
	local options,profile = E.db.hud,P.hud
	for _,setting in pairs(settings) do
		options = options[setting]
		profile = profile[setting]
	end
	return IsDefaultHelper(options,profile)
end

function H:GetUnitFrame(unit)
	local stringTitle = E:StringTitle(unit)
	if stringTitle:find('target') then
		stringTitle = gsub(stringTitle, 'target', 'Target')
	end
	return "ElvUF_"..stringTitle.."Hud"
end

function H:GetClassBarName()
	if E.myclass == "DRUID" then
		return 'EclipseBar'
	end

	if E.myclass == "WARLOCK" then
		return 'WarlockSpecBars'
	end

	if E.myclass == "PALADIN" then
		return 'HolyPower'
	end

	if E.myclass == "DEATHKNIGHT" then
		return 'Runes'
	end

	if E.myclass == "SHAMAN" then
		return 'TotemBar'
	end

	if E.myclass == "MONK" then
		return 'HarmonyBar'
	end

	if E.myclass == "PRIEST" then
		return 'ShadowOrbsBar'
	end

	if E.myclass == "MAGE" then
		return 'ArcaneChargeBar'
	end
end

local elements = {
	['health'] = 'Health',
	['power'] = 'Power',
	['castbar'] = 'Castbar',
	['name'] = 'Name',
	['aurabars'] = 'AuraBars',
	['cpoints'] = 'CPoints',
	['raidicon'] = 'RaidIcon',
	['resting'] = 'Resting',
	['combat'] = 'Combat',
	['pvp'] = 'PvPText',
	['healcomm'] = 'HealPrediction',
	['mushroom'] = 'WildMushroom',
	['gcd'] = 'GCD',
	['buffs'] = 'Buffs',
	['debuffs'] = 'Debuffs',
}

function H:GetElement(element)
	if element == 'classbars' then
		return H:GetClassBarName()
	else
		if elements[element] then return elements[element] else return nil end
	end
end
	
function H:GetAnchor(frame,anchor)
	if anchor == 'self' then
		return frame
	elseif anchor == 'ui' then
		return UIParent
	elseif string.find(anchor,':') then
		local f,e = string.split(':',anchor)
		f = H:GetUnitFrame(f)
		e = H:GetElement(e)
		return _G[f][e]
	else
		local e = anchor
		e = H:GetElement(e)
		if e then
			return frame[e]
		else
			e = H:GetUnitFrame(anchor)
			return e
		end
	end

	return frame
end

function H:CheckHealthValue(frame,eclipse)
	local config = E.db.hud.units.player.elements.health.value
	if config.enabled then
		if H:IsDefault('units.player.elements.health.value.anchor') then
        	if eclipse then
        		frame.Health.value:Point('TOPRIGHT',frame.Health,'TOPLEFT',-30,0)
        	else
        		frame.Health.value:Point('TOPRIGHT',frame.Health,'TOPLEFT',-20,0)
        	end
        end
    end
end

-- This function is only responsible for updating bar sizes for class bar children
-- textures work normally as does parent size
function H:UpdateClassBar(frame,element)
	if not E.db.hud.units[frame.unit] then return end
	local config = E.db.hud.units[frame.unit].elements[element]
	local size = config['size']
	
	local spaced = config.spaced
	if element == 'mushroom' then
		local numPoints = 3
		local totalspacing = (config['spacesettings'].offset * 2) + (config['spacesettings'].spacing * numPoints) - numPoints
		for i = 1, numPoints do
			frame.WildMushroom[i]:Size(size.width,(size.height - (spaced and totalspacing or 2))/3)
		end
	end

	if element == "cpoints" then
		local numPoints = 5
		local totalspacing = (config['spacesettings'].offset * 2) + (config['spacesettings'].spacing * numPoints) - numPoints
		for i = 1, numPoints do
			frame.CPoints[i]:Size(size.width,(size.height - (spaced and totalspacing or 4))/5)
		end
	end

	if element == 'classbars' then
		local numPoints
		local maxPoints
		if E.myclass == "DRUID" then
			frame.EclipseBar.LunarBar:Size(frame.EclipseBar:GetSize())
			frame.EclipseBar.SolarBar:Size(frame.EclipseBar:GetSize())
			frame.EclipseBar:ForceUpdate()
			return
		end

		if E.myclass == "WARLOCK" then
			local spec = GetSpecialization()
			if spec == SPEC_WARLOCK_DESTRUCTION then
				numPoints = UnitPowerMax('player',SPELL_POWER_BURNING_EMBERS)
				maxPoints = 4
			elseif spec == SPEC_WARLOCK_DEMONOLOGY then
				numPoints = 1
				maxPoints = 1
			else
				numPoints = UnitPowerMax('player',SPELL_POWER_SOUL_SHARDS)
				maxPoints = 4
			end
			if not frame.WarlockSpecBars.PostUpdate then
				frame.WarlockSpecBars.PostUpdate = function(self)
					H:UpdateClassBar(frame,element)
				end
			end
		end

		if E.myclass == "PALADIN" then
			numPoints = UnitPowerMax('player',SPELL_POWER_HOLY_POWER)
			maxPoints = 5
		end

		if E.myclass == "DEATHKNIGHT" then
			numPoints = 6
			maxPoints = 6
		end

		if E.myclass == "SHAMAN" then
			numPoints = 4
			maxPoints = 4
		end

		if E.myclass == "MONK" then
			numPoints = UnitPowerMax('player',SPELL_POWER_LIGHT_FORCE)
			maxPoints = 5
			if not frame.HarmonyBar.PostUpdate then
				frame.HarmonyBar.PostUpdate = function(self)
					H:UpdateClassBar(frame,element)
				end
			end
		end

		if E.myclass == "PRIEST" then
			numPoints = 3
			maxPoints = 3
		end

		if E.myclass == "MAGE" then
			numPoints = 6
			maxPoints = 6
		end

		local totalspacing = (config['spacesettings'].offset * 2) + (config['spacesettings'].spacing * numPoints) - numPoints
		local e = H:GetElement(element)
		for i = 1, maxPoints do
			frame[e][i]:SetAlpha(0)
		end
		for i = 1, numPoints do
			frame[e][i]:Size(size.width,(size.height - (spaced and totalspacing or 2)) / numPoints)
			frame[e][i]:SetAlpha(1)
		end
	end
end

function H:UpdateClassBarAnchors(frame,element)
	local config = E.db.hud.units[frame.unit].elements[element]
	
	local spaced = config.spaced
	local spacing = config.spacesettings.spacing
	if not spaced then
		spacing = 1
	end

	if element == 'mushroom' then
		for i = 1,3 do
			if i == 1 then
	            frame.WildMushroom[i]:Point("BOTTOM",frame.WildMushroom)
	        else
	            frame.WildMushroom[i]:Point("BOTTOM",frame.WildMushroom[i-1], "TOP", 0, spacing)
	        end
		end
	end

	if element == "cpoints" then
		for i=1,5 do
			if i == 1 then
	            frame.CPoints[i]:Point("BOTTOM",frame.CPoints)
	        else
	            frame.CPoints[i]:Point("BOTTOM",frame.CPoints[i-1], "TOP", 0, spacing)
	        end
		end
	end

	if element == 'classbars' then
		if E.myclass == "DRUID" then
			frame.EclipseBar.LunarBar:SetPoint('LEFT', frame.EclipseBar, 'LEFT', 0, 0)
			frame.EclipseBar.SolarBar:SetPoint('LEFT', frame.EclipseBar, 'LEFT', 0, 0)
		end

		if E.myclass == "WARLOCK" then
			for i=1,4 do
				if i == 1 then
		            frame.WarlockSpecBars[i]:Point("BOTTOM",frame.WarlockSpecBars)
		        else
		            frame.WarlockSpecBars[i]:Point("BOTTOM",frame.WarlockSpecBars[i-1], "TOP", 0, spacing)
		        end
			end
		end

		if E.myclass == "PALADIN" then
			for i=1,5 do
				if i == 1 then
		            frame.HolyPower[i]:Point("BOTTOM",frame.HolyPower)
		        else
		            frame.HolyPower[i]:Point("BOTTOM",frame.HolyPower[i-1], "TOP", 0, spacing)
		        end
			end
		end

		if E.myclass == "DEATHKNIGHT" then
			for i=1,6 do
				if i == 1 then
		            frame.Runes[i]:Point("BOTTOM",frame.Runes)
		        else
		            frame.Runes[i]:Point("BOTTOM",frame.Runes[i-1], "TOP", 0, spacing)
		        end
			end
		end

		if E.myclass == "SHAMAN" then
			for i=1,4 do
				if i == 1 then
		            frame.TotemBar[i]:Point("BOTTOM",frame.TotemBar)
		        else
		            frame.TotemBar[i]:Point("BOTTOM",frame.TotemBar[i-1], "TOP", 0, spacing)
		        end
			end
		end

		if E.myclass == "MONK" then
			for i=1,5 do
				if i == 1 then
		            frame.HarmonyBar[i]:Point("BOTTOM",frame.HarmonyBar)
		        else
		            frame.HarmonyBar[i]:Point("BOTTOM",frame.HarmonyBar[i-1], "TOP", 0, spacing)
		        end
			end
		end

		if E.myclass == "PRIEST" then
			for i=1,3 do
				if i == 1 then
		            frame.ShadowOrbsBar[i]:Point("BOTTOM",frame.ShadowOrbsBar)
		        else
		            frame.ShadowOrbsBar[i]:Point("BOTTOM",frame.ShadowOrbsBar[i-1], "TOP", 0, spacing)
		        end
			end
		end

		if E.myclass == "MAGE" then
			for i=1,6 do
				if i == 1 then
		            frame.ArcaneChargeBar[i]:Point("BOTTOM",frame.ArcaneChargeBar)
		        else
		            frame.ArcaneChargeBar[i]:Point("BOTTOM",frame.ArcaneChargeBar[i-1], "TOP", 0, spacing)
		        end
			end
		end
	end
end

function H:UpdateElement(frame,element)
	local config = E.db.hud.units[frame.unit].elements[element]
	local size = config['size']
	local media = config['media']
	local e = self.units[frame.unit].elements[element]
	if size then
		if e.statusbars then
			if element == 'castbar' and size['vertical'] ~= nil then
				if not E.db.hud.horizCastbar then
					size = size['vertical']
				else
					size = size['horizontal']
				end
			end
			
			for _,statusbar in pairs(e.statusbars) do
				statusbar:Size(size.width,size.height)
			end			
		end
		if e.frame then
			local height = size.height
			if element == 'classbars' or element == 'cpoints' or element == 'mushroom' then
				if config['spaced'] then height = (height + 2) - (config['spacesettings'].offset*2) end
			end
			e.frame:Size(size.width,height)
			if element == 'classbars' or element == 'cpoints' or element == 'mushroom' then
				self:UpdateClassBar(frame,element)
			end
		end
	end
	if media then
		local textureSetting = string.format('units.%s.elements.%s.media.texture',frame.unit,element)
		local fontSetting = string.format('units.%s.elements.%s.media.font',frame.unit,element)
		if e.statusbars then
			for _,statusbar in pairs(e.statusbars) do
				if media.texture.override or not self:IsDefault(textureSetting) then
					statusbar:SetStatusBarTexture(LSM:Fetch("statusbar", media.texture.statusbar))
				else
					statusbar:SetStatusBarTexture(LSM:Fetch("statusbar", E.db.hud.statusbar))
				end
				if media.color and element ~= "castbar" then
					statusbar.defaultColor = media.color
					statusbar:SetStatusBarColor(media.color)
				end
			end
		end
		if e.textures then
			for _,texture in pairs(e.textures) do
				if media.texture.override or not self:IsDefault(textureSetting) then
					texture:SetTexture(LSM:Fetch("statusbar", media.texture.statusbar))
				else
					texture:SetTexture(LSM:Fetch("statusbar", E.db.hud.statusbar))
				end
			end
		end
		if e.fontstrings then
			for n,fs in pairs(e.fontstrings) do
				if media.font.override or not self:IsDefault(fontSetting) then
					fs:FontTemplate(LSM:Fetch("font", media.font.font), media.font.fontsize, "THINOUTLINE")
				else
					fs:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
				end
			end
		end
	end
end

function H:UpdateElementAnchor(frame,element)
	local e = H:GetElement(element)
	local config = E.db.hud.units[frame.unit].elements[element]
	local enabled = config['enabled']
	if element == 'healcomm' then
		if enabled then
			frame:EnableElement(e)
		else
			frame:DisableElement(e)
		end
		return
	end
 	local anchor = config['anchor']
	if element == 'cpoints' and not (E.myclass == "ROGUE" or E.myclass == "DRUID") then return end;
	if element == 'castbar' and anchor['vertical'] ~= nil then
		if not E.db.hud.horizCastbar then
			anchor = anchor['vertical']
		else
			anchor = anchor['horizontal']
		end
	end
	if element == 'mushroom' then
		local WMFrame = CreateFrame('Frame',nil,frame)
		WMFrame:RegisterEvent('PLAYER_TALENT_UPDATE')
		WMFrame:SetScript('OnEvent',function(self,event)
			local config = E.db.hud.units[frame.unit].elements['mushroom']
			local anchor = config['anchor']
			local eclipse
			local spec = GetSpecialization()
			if spec == 1 then
				anchor = anchor['eclipse']
				eclipse = true
			else
				anchor = anchor['default']
				eclipse = false
			end
			local pointFrom = anchor['pointFrom']
			local attachTo = H:GetAnchor(frame,anchor['attachTo'])
			local pointTo = anchor['pointTo']
			local xOffset = anchor['xOffset']
			local yOffset = anchor['yOffset']
			if config['spaced'] then yOffset = yOffset + config['spacesettings'].offset end
			frame.WildMushroom:SetPoint(pointFrom, attachTo, pointTo, xOffset, yOffset)
			H:CheckHealthValue(frame,eclipse)
		end)
		local spec = GetSpecialization()
		if spec == 1 then
			anchor = anchor['eclipse']
		else
			anchor = anchor['default']
		end
	end
	local pointFrom = anchor['pointFrom']
	local attachTo = H:GetAnchor(frame,anchor['attachTo'])
	local pointTo = anchor['pointTo']
	local xOffset = anchor['xOffset']
	local yOffset = anchor['yOffset']
	if (element == 'classbars' or element == 'mushroom' or element == 'cpoints') then
		if config['spaced'] then yOffset = yOffset + config['spacesettings'].offset end
	end
	frame[e]:SetPoint(pointFrom, attachTo, pointTo, xOffset, yOffset)
	if (element == 'classbars' or element == 'mushroom' or element == 'cpoints') then
		self:UpdateClassBarAnchors(frame,element)
	end
	if config['tag'] then
		frame:Tag(frame[e], config['tag'])
	end
	if config['value'] and frame[e].value then
		local venable = config['value']['enabled']
		local vanchor = config['value']['anchor']
		local vpointFrom = vanchor['pointFrom']
		local vattachTo = H:GetAnchor(frame,vanchor['attachTo'])
		local vpointTo = vanchor['pointTo']
		local vxOffset = vanchor['xOffset']
		local vyOffset = vanchor['yOffset']
		frame[e].value:SetPoint(vpointFrom, vattachTo, vpointTo, vxOffset, vyOffset)
		if config['value']['tag'] then
			frame:Tag(frame[e].value,config['value']['tag'])
		end
		if venable then
			frame[e].value:Show()
		else
			frame[e].value:Hide()
		end
	end

	if enabled then
		frame:EnableElement(e)
		if config['value'] and frame[e].value then
			if config['value']['enabled'] then
				frame[e].value:Show()
			else
				frame[e].value:Hide()
			end
		end
		if element ~= 'raidicon' then frame[e]:Show() end
	else
		frame:DisableElement(e)
		if config['value'] then
			frame[e].value:Hide()
		end
		frame[e]:Hide()
	end
end

function H:ConstructHudFrame(frame,unit)
	if not self.units then self.units = { } end
	self.units[unit] = frame
	self.units[unit]['elements'] = { }
	frame.unit = unit
	frame:RegisterForClicks("AnyUp")
	frame:SetScript('OnEnter', UnitFrame_OnEnter)
	frame:SetScript('OnLeave', UnitFrame_OnLeave)	
	
	frame.menu = UF.SpawnMenu
	
	local stringTitle = E:StringTitle(unit)
	if stringTitle:find('target') then
		stringTitle = gsub(stringTitle, 'target', 'Target')
	end
	self["Construct"..stringTitle.."Frame"](self, frame, unit)
	return frame
end

function H:UpdateFrame(unit)
	frame = self.units[unit]
	frame:Size(E.db.hud.units[frame.unit].width,E.db.hud.units[frame.unit].height)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

	if E.db.hud.units[frame.unit].enabled then
		frame:EnableMouse(E.db.hud.enableMouse)
		frame:SetAlpha(E.db.hud.alpha)
		frame:Show()
		local event
		if InCombatLockdown() then
			event = "PLAYER_REGEN_DISABLED"
		else
			event = "PLAYER_REGEN_ENABLED"
		end
		if E.db.hud.hideOOC then H:Hide(frame, event) end
		self:UpdateAllElements(frame)
		self:UpdateAllElementAnchors(frame)

		if E.myclass == 'DRUID' and unit == 'player' then
			local spec = GetSpecialization()
			self:CheckHealthValue(frame,spec==1)
		end
	else
		frame:EnableMouse(false)
		frame:SetAlpha(0)
		frame:Hide()
	end
end

function H:UpdateAllFrames()
	for unit,_ in pairs(self.units) do
		self:UpdateFrame(unit)
	end
end

function H:UpdateAllElements(frame)
	local elements = self.units[frame.unit].elements
	local seenClassbars = false
	for element,_ in pairs(elements) do
		self:UpdateElement(frame,element)
	end
end

function H:UpdateAllElementAnchors(frame)
	local elements = self.units[frame.unit].elements
	local seenClassbars = false

	for element,_ in pairs(elements) do
		if element == 'mushroom' then
			if not seenClassbars then
				self:UpdateElementAnchor(frame,'classbars')
				seenClassbars = true
			end
			self:UpdateElementAnchor(frame,element)
		elseif element == 'classbars' then
			if not seenClassbars then
				self:UpdateElementAnchor(frame,element)
				seenClassbars = true
			end
		else
			self:UpdateElementAnchor(frame,element)
		end
	end
end

function H:AddElement(frame,element)
	if not self.units[frame.unit].elements[element] then
		self.units[frame.unit].elements[element] = { }
	end
end

function H:ConfigureStatusBar(frame,element,parent,name)
	if parent == nil then parent = frame end
	if name == nil then name = "statusbar" end

	-- Create the status bar
	local sb = CreateFrame('StatusBar', nil, parent)
	sb:SetTemplate('Transparent')
	sb:CreateBackdrop("Default")
	sb:CreateShadow("Default")

	-- Dummy texture so we can set colors
	sb:SetStatusBarTexture(E['media'].blankTex)
	sb:GetStatusBarTexture():SetHorizTile(false)
 
	-- Frame strata/level
	sb:SetFrameStrata(parent:GetFrameStrata())
	sb:SetFrameLevel(parent:GetFrameLevel())

	-- Create the status bar background
    local bg = sb:CreateTexture(nil, 'BORDER')
    bg:SetAllPoints()
    bg:SetTexture(E['media'].blankTex)
    bg:SetTexture(.1, .1, .1)
    bg:SetAlpha(.2)
    bg.multiplier = 0.3 
    sb.bg = bg

    if not self.units[frame.unit].elements[element].statusbars then
		self.units[frame.unit].elements[element].statusbars =  { }
	end

    self.units[frame.unit].elements[element].statusbars[name] = sb
    return sb
end

function H:ConfigureFontString(frame,element,parent,name)
	if parent == nil then parent = frame end
	if name == nil then name = 'value' end

	if not self.units[frame.unit].elements[element].fontstrings then
		self.units[frame.unit].elements[element].fontstrings=  { }
	end

	local fs = parent:CreateFontString(nil, "THINOUTLINE")
	-- Dummy font
	fs:FontTemplate(LSM:Fetch("font", "ElvUI Font"), 12, "THINOUTLINE")
	self.units[frame.unit].elements[element].fontstrings[name] = fs

	return fs
end

function H:ConfigureTexture(frame,element,parent,name)
	if parent == nil then parent = frame end
	if name == nil then name = 'texture' end

	if not self.units[frame.unit].elements[element].textures then
		self.units[frame.unit].elements[element].textures =  { }
	end

	local t = parent:CreateTexture(nil, "OVERLAY")
	-- Dummy texture
	t:SetTexture(E['media'].blankTex)
	self.units[frame.unit].elements[element].textures[name] = t
	return t
end

function H:ConfigureFrame(frame,element,visible)
	if visible == nil then visible = false end
	local f = CreateFrame('Frame',nil,frame)
	f.visible = visible
	--[[if visible then
		f:SetTemplate("Default")
		f:CreateBackdrop("Default")
		f:CreateShadow("Default")
	end]]
	self.units[frame.unit].elements[element].frame = f
	return f
end

function H:ResetUnitSettings(unit)
	local frame = self.units[unit]
	if not frame then return end
	E:CopyTable(E.db.hud.units[unit],P.hud.units[unit])
    self:UpdateAllFrames()
end

function H:UpdateElementSizes(unit,isWidth,newSize)
	local elements = self.units[unit].elements
	
	for element,_ in pairs(elements) do
		local config = E.db.hud.units[unit].elements[element]
		local size = config['size']
		if size then
			local config = true
			if element == 'castbar' and (unit == 'player' or unit == 'target') then 
				if E.db.hud.horizCastbar then
					config = false
				else
					size = size['vertical']
				end
			end
			local var = (isWidth and 'width') or 'height'
			if config then size[var] = newSize end
		end
	end
end

function H:SimpleLayout()
	E.db.hud.units.target.enabled = false
	E.db.hud.units.targettarget.enabled = false
	E.db.hud.units.pet.enabled = false
	E.db.hud.units.pettarget.enabled = false
	for element,_ in pairs(E.db.hud.units.player.elements) do
		E.db.hud.units.player.elements[element].enabled = false
	end
	E.db.hud.units.player.elements.health.enabled = true
	E.db.hud.units.player.elements.power.enabled = true
	E.db.hud.units.player.elements.power.anchor.xOffset = 550
	E.db.hud.units.player.elements.classbars.enabled = true
	E.db.hud.units.player.elements.cpoints.enabled = true
end
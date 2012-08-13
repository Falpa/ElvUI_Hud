local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

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
		return 'Totems'
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
}

function H:GetElement(element)
	if element == 'classbars' then
		return H:GetClassBarName()
	else
		return elements[element]
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
		return frame[e]
	end

	return frame
end

-- This function is only responsible for updating bar sizes for class bar children
-- textures work normally as does parent size
function H:UpdateClassBar(frame,element)
	local config = P.hud.units[frame.unit].elements[element]
	local size = config['size']
	
	if element == "cpoints" then
		for i=1,5 do
			frame.CPoints[i].Size(size.width,(size.height - 4)/5)
		end
	end

	if E.myclass == "DRUID" then
		frame.EclipseBar.LunarBar:Size(size.width,size.height)
		frame.EclipseBar.SolarBar:Size(size.width,size.height)
	end

	if E.myclass == "WARLOCK" then
		for i=1,4 do
			frame.WarlockSpecBars[i]:Size(size.width,(size.height - 2) / 4)
		end
	end

	if E.myclass == "PALADIN" then
		for i=1,5 do
			frame.HolyPower[i]:Size(size.width,(size.height - 2) / 5)
		end
	end

	if E.myclass == "DEATHKNIGHT" then
		for i=1,6 do
			frame.Runes[i]:Size(size.width,(size.height - 5) / 6)
		end
	end

	if E.myclass == "SHAMAN" then
		for i=1,4 do
			frame.Totems[i]:Size(size.width,(size.height - 3) / 4)
		end
	end

	if E.myclass == "MONK" then
		for i=1,5 do
			frame.HarmonyBar[i]:Size(size.width,(size.height - 2) / 5)
		end
	end

	if E.myclass == "PRIEST" then
		for i=1,3 do
			frame.ShadowOrbsBar[i]:Size(size.width,(size.height - 2) / 3)
		end
	end

	if E.myclass == "MAGE" then
		for i=1,6 do
			frame.ArcaneChargeBar[i]:Width(size.width)
		end
	end
end

function H:UpdateElement(frame,element)
	local config = P.hud.units[frame.unit].elements[element]
	local size = config['size']
	local media = config['media']
	local e = self.units[frame.unit].elements[element]
	if size then
		if e.frame then
			e.frame:Size(size.width,size.height)
			if element == 'classbars' or element == 'cpoints' then
				self:UpdateClassBar(frame,element)
			end
		end
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
	end
	if media then
		if e.statusbars then
			for _,statusbar in pairs(e.statusbars) do
				if media.texture.override then
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
				if media.texture.override then
					texture:SetTexture(LSM:Fetch("statusbar", media.texture.statusbar))
				else
					texture:SetTexture(LSM:Fetch("statusbar", E.db.hud.statusbar))
				end
			end
		end
		if e.fontstrings then
			for n,fs in pairs(e.fontstrings) do
				if media.font.override then
					fs:FontTemplate(LSM:Fetch("font", media.font.font), media.font.fontsize, "THINOUTLINE")
				else
					fs:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
				end
			end
		end
	end
end

function H:UpdateElementAnchor(frame,element)
	if element == 'healcomm' then return end
	local config = P.hud.units[frame.unit].elements[element]
	local enabled = config['enabled']
	local anchor = config['anchor']
	local e = H:GetElement(element)
	if element == 'cpoints' and not (E.myclass == "ROGUE" or E.myclass == "DRUID") then return end;
	if element == 'castbar' and anchor['vertical'] ~= nil then
		if not E.db.hud.horizCastbar then
			anchor = anchor['vertical']
		else
			anchor = anchor['horizontal']
		end
	end
	local pointFrom = anchor['pointFrom']
	local attachTo = H:GetAnchor(frame,anchor['attachTo'])
	local pointTo = anchor['pointTo']
	local xOffset = anchor['xOffset']
	local yOffset = anchor['yOffset']
	frame[e]:SetPoint(pointFrom, attachTo, pointTo, xOffset, yOffset)
	if config['tag'] then
		frame:Tag(frame[e], config['tag'])
	end
	if config['value'] then
		if element ~= "classbars" or (element == "classbars" and E.myclass == "WARLOCK") then
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
	end

	if enabled then
		frame:EnableElement(e)
		if config['value'] then
			if config['value']['enable'] then
				frame[e].value:Show()
			end
		end
		frame[e]:Show()
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

function H:UpdateAllFrames()
	for _,frame in pairs(self.units) do
		frame:Size(P.hud.units[frame.unit].width,P.hud.units[frame.unit].height)
		_G[frame:GetName()..'Mover']:Size(frame:GetSize())

		if P.hud.units[frame.unit].enabled then
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
		else
			frame:EnableMouse(false)
			frame:SetAlpha(0)
			frame:Hide()
		end
	end
end

function H:UpdateAllElements(frame)
	local elements = self.units[frame.unit].elements
	
	for element,_ in pairs(elements) do
		self:UpdateElement(frame,element)
	end
end

function H:UpdateAllElementAnchors(frame)
	local elements = self.units[frame.unit].elements
	
	for element,_ in pairs(elements) do
		self:UpdateElementAnchor(frame,element)
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
	local sb = CreateFrame('StatusBar', nil, frame)
	sb:SetTemplate('Transparent')
	sb:CreateBackdrop("Default")
	sb:CreateShadow("Default")

	-- Dummy texture so we can set colors
	sb:SetStatusBarTexture(LSM:Fetch("statusbar","Minimalist"))
	sb:SetBackdrop(backdrop)
    sb:SetBackdropColor(0, 0, 0, 0)
	-- Create the status bar background
	-- Health Bar Background
    local bg = sb:CreateTexture(nil, 'BORDER')
    bg:SetAllPoints()
    bg:SetTexture(.1, .1, .1)
    bg:SetAlpha(.2)
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
	t:SetTexture(LSM:Fetch("statusbar","Minimalist"))
	self.units[frame.unit].elements[element].textures[name] = t
	return t
end

function H:ConfigureFrame(frame,element,visible)
	if visible == nil then visible = false end
	local f = CreateFrame('Frame',nil,frame)
	if visible then
		f:SetTemplate('Transparent')
		f:CreateBackdrop("Default")
		f:CreateShadow("Default")
	end
	self.units[frame.unit].elements[element].frame = f
	return f
end

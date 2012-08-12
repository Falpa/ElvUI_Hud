local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

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
	['threat'] = 'Threat',
	['aurabars'] = 'AuraBars',
	['cpoints'] = 'CPoints',
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
		print('anchor: ',anchor)
		local f,e = string.split(':',anchor)
		f = H:GetUnitFrame(f)
		if e == 'power' then 
			e = 'PowerFrame'
		elseif e == 'threat' then 
			e = 'ThreatFrame'
		else
			print('e: ',e)
			e = H:GetElement(e)
		end
		print('f: ',f,'e: ',e)
		return _G[f][e]
	else
		local e = anchor
		if e == 'power' then 
			e = 'PowerFrame'
		elseif e == 'threat' then 
			e = 'ThreatFrame'
		else
			e = H:GetElement(e)
		end
		return frame[e]
	end

	return frame
end

function H:UpdateAndPositionElement(frame,element,config)
	local enabled = config['enabled']
	local anchor = config['anchor']
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
	local e = H:GetElement(element)
	if element == 'power' or element == 'threat' then
		local re = string.format('%sFrame',e)
		frame[re]:SetPoint(pointFrom, attachTo, pointTo, xOffset, yOffset)
	else
		if element == 'health' and anchor['attachTo'] ~= 'self' then
			frame:SetPoint(pointFrom, attachTo, pointTo, xOffset, yOffset)
			if frame.unit == 'target' then
				frame[e]:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
			else
				frame[e]:SetPoint("LEFT", frame, "LEFT", 0, 0)
			end
		else
			frame[e]:SetPoint(pointFrom, attachTo, pointTo, xOffset, yOffset)
		end
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
		if not frame[e] then print ('No element for ',e,'!') end
		frame:DisableElement(e)
		if config['value'] then
			frame[e].value:Hide()
		end
		frame[e]:Hide()
	end
end

H.hud_frames = { }
function H:ConstructHudFrame(frame,unit)
	H:SetUpParameters()

	frame:RegisterForClicks("AnyUp")
	frame:SetScript('OnEnter', UnitFrame_OnEnter)
	frame:SetScript('OnLeave', UnitFrame_OnLeave)	
	
	frame.menu = self.SpawnMenu
	
	frame:SetFrameLevel(5)
	
	local stringTitle = E:StringTitle(unit)
	if stringTitle:find('target') then
		stringTitle = gsub(stringTitle, 'target', 'Target')
	end
	self["Construct"..stringTitle.."Frame"](self, frame, unit)
	tinsert(H.hud_frames,frame)
	return frame
end

function H:UpdateFrames()
	for _,frame in pairs(H.hud_frames) do
		local elements = frame.elements
		
		for _,e in pairs(elements) do
			H:UpdateAndPositionElement(frame,e,P.hud.layout[frame.unit].elements[e])
		end
	end
end
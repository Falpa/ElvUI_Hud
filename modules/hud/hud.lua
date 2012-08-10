local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');

function H:Construct_Hud(frame,unit)
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
	self["Construct"..stringTitle.."Hud"](self, frame, unit)
	self["Update"..stringTitle.."Anchors"](self, frame, unit)
	return frame
end

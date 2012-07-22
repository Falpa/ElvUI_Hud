local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule('UnitFrames');

local db = E.db.hud or P.hud

local backdrop = {
	bgFile = E["media"].blankTex,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
}

local hud_height = E:Scale(db.height)
local hud_width = E:Scale(db.width)
local hud_power_width = E:Scale((hud_width/3)*2)

local function SimpleHealth(self,unit)
	Construct_SimpleHealth(self,unit)

	if db.classBars and unit == "player" then
		if E.myclass == "DRUID" then
			Construct_EclipseBar(self,unit)
		end

		if E.myclass == "WARLOCK" then
			Construct_Shards(self,unit)
		end

		if E.myclass == "PALADIN" then
			Construct_HolyPower(self,unit)
		end

		if E.myclass == "DEATHKNIGHT" then
			Construct_Runes(self,unit)
		end

		if E.myclass == "SHAMAN" then
			Construct_Totems(self,unit)
		end

		if E.myclass == "DRUID" or E.myclass == "ROGUE" then
			Construct_ComboPoints(self,unit)
		end
	end
end

local function SimplePower(self,unit)
	Construct_SimplePower(self,unit)
end

local function Hud(self,unit)
	-- Set Colors
    self.colors = ElvUF["colors"]

    -- Update all elements on show
    self:HookScript("OnShow", H.updateAllElements)
	self:EnableMouse(false) -- HUD should be click-through

	if unit == "player" then
		Construct_PlayerHealth(self,unit)

		Construct_PlayerPower(self,unit)

		if db.classBars then
			if E.myclass == "DRUID" then
				Construct_EclipseBar(self,unit)
			end

			if E.myclass == "WARLOCK" then
				Construct_Shards(self,unit)
			end

			if E.myclass == "DRUID" then
				Construct_HolyPower(self,unit)
			end

			if E.myclass == "DEATHKNIGHT" then
				Construct_Runes(self,unit)
			end

			if E.myclass == "SHAMAN" then
				Construct_Totems(self,unit)
			end
		end

		if db.showThreat then
			Construct_Threat(self,unit)
		end
	elseif unit == "target" then
		Construct_TargetHealth(self,unit)

		Construct_TargetPower(self,unit)

		Construct_ComboPoints(self,unit)
	else
		Construct_PetHealth(self,unit)

		Construct_PetPower(self,unit)
	end
end

ElvUF:RegisterStyle('ElvUI_Hud',Hud)
ElvUF:RegisterStyle('ElvUI_Hud_Simple_Health',SimpleHealth)
ElvUF:RegisterStyle('ElvUI_Hud_Simple_Power',SimplePower)

if db.warningText then
	H:CreateWarningFrame()
end

function H:Construct_Hud()
	if db.simpleLayout then
		local alpha = db.alpha

		ElvUF:SetActiveStyle('ElvUI_Hud_Simple_Health')

		local player_health = ElvUF:Spawn('player', "oUF_Elv_player_HudHealth")
		player_health:SetPoint("RIGHT", UIParent, "CENTER", E:Scale(-db.offset), 0)
		player_health:SetSize(hud_width, hud_height)
		player_health:SetAlpha(alpha)

		H:HideOOC(player_health)

		if db.simpleTarget then
			local target_health = ElvUF:Spawn('target', "oUF_Elv_target_HudHealth")
			target_health:SetPoint("LEFT", player_health, "RIGHT", E:Scale(15) + hud_width, 0)
			target_health:SetSize(hud_width, hud_height)
			target_health:SetAlpha(alpha)
			
			H:HideOOC(target_health)
		end

		ElvUF:SetActiveStyle('ElvUI_Hud_Simple_Power')
		local player_power = ElvUF:Spawn('player', "oUF_Elv_player_HudPower")
		player_power:SetPoint("LEFT", UIParent, "CENTER", E:Scale(db.offset), 0)
		player_power:SetSize(hud_width, hud_height)
		player_power:SetAlpha(alpha)
		
		H:HideOOC(player_power)

		if db.simpleTarget then
			local target_power = ElvUF:Spawn('target', "oUF_Elv_target_HudPower")
			target_power:SetPoint("RIGHT", player_power, "LEFT", E:Scale(-15) - hud_width, 0)
			target_power:SetSize(hud_width, hud_height)
			target_power:SetAlpha(alpha)
			
			H:HideOOC(target_power)
		end
	else
		print("Spawning hud...")
        ElvUF:SetActiveStyle('ElvUI_Hud')
		local width = hud_width
		width = width + hud_power_width + 2

		if db.showThreat then
			width = width + hud_power_width + 2
		end

		local alpha = db.alpha

		local player_hud = ElvUF:Spawn('player', "oUF_Elv_player_Hud")
		player_hud:SetPoint("RIGHT", UIParent, "CENTER", E:Scale(-db.offset), 0)
		player_hud:SetSize(width, hud_height)
		player_hud:SetAlpha(alpha)

		H:HideOOC(player_hud)

		width = hud_width
		width = width + hud_power_width + 2

		local target_hud = ElvUF:Spawn('target', "oUF_Elv_target_Hud")
		target_hud:SetPoint("LEFT", UIParent, "CENTER", E:Scale(db.offset), 0)
		target_hud:SetSize(width, hud_height)
		target_hud:SetAlpha(alpha)

		H:HideOOC(target_hud)

		if db.petHud then
			width = hud_width
			width = width + hud_power_width + 2

			local pet_hud = ElvUF:Spawn('pet', "oUF_Elv_pet_Hud")
			pet_hud:SetPoint("BOTTOMRIGHT", oUF_Elv_player_Hud, "BOTTOMLEFT", -E:Scale(80), 0)
			pet_hud:SetSize(width, hud_height * .75)
			pet_hud:SetAlpha(alpha)
			
			H:HideOOC(pet_hud)
		end
	end
end
